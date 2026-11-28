-- Visitor ip addresses (Logan 2026-11-28 07:04Z: "follow the ip", chose "IP address, no cookie").
-- Adds the visitor's ip address and, when the "hit" function has an IPINFO_TOKEN secret, the country and network it
-- belongs to (ipinfo.io Lite, looked up once per address and cached). Records, ip addresses included, are still
-- deleted after 400 days by purge_old_hits(). No cookie is set. Run once after schema.sql and weekly.sql.
alter table public.hits add column if not exists ip text;
alter table public.hits add column if not exists country text;          -- 2-letter code, from the ip address
alter table public.hits add column if not exists network text;          -- the ip address's network (as name), e.g. "Comcast Cable"
create index if not exists hits_ip_idx on public.hits (ip);

create table if not exists public.ip_geo (
  ip text primary key,
  country text, network text,
  looked_up timestamptz not null default now()
);
alter table public.ip_geo enable row level security;

drop function if exists public.record_hit(jsonb, text, text, boolean, text, text, text);
create or replace function public.record_hit(p jsonb, p_ip text, p_ua text, p_bot boolean, p_device text, p_browser text,
                                             p_os text, p_country text default null, p_network text default null)
returns void
language plpgsql
security definer
set search_path = public, extensions
as $$
declare
  d date := (now() at time zone 'America/New_York')::date;
  s text;
  v_ip text := nullif(left(coalesce(p_ip, ''), 45), '');
begin
  delete from daily_salt where day < d;
  insert into daily_salt(day, salt) values (d, encode(gen_random_bytes(32), 'hex')) on conflict (day) do nothing;
  select salt into s from daily_salt where day = d;
  if v_ip is not null and (p_country is not null or p_network is not null) then
    insert into ip_geo(ip, country, network) values (v_ip, left(p_country, 2), left(p_network, 120))
    on conflict (ip) do update set country = excluded.country, network = excluded.network, looked_up = now();
  end if;
  insert into hits(kind, event, label, page, path, referrer_host, utm_source, utm_medium, utm_campaign,
                   device, browser, os, screen_w, screen_h, lang, tz, visitor, session,
                   load_ms, seconds, scroll_pct, is_bot, ip, country, network)
  values (
    coalesce(left(p->>'kind', 10), 'view'), left(p->>'event', 40), left(p->>'label', 120),
    coalesce(left(p->>'page', 60), 'unknown'), left(p->>'path', 200), left(p->>'ref', 120),
    left(p->>'us', 60), left(p->>'um', 60), left(p->>'uc', 80),
    p_device, p_browser, p_os,
    case when p->>'sw' ~ '^\d{1,5}$' then (p->>'sw')::int end,
    case when p->>'sh' ~ '^\d{1,5}$' then (p->>'sh')::int end,
    left(p->>'lang', 20), left(p->>'tz', 60),
    encode(digest(s || coalesce(p_ip, '') || coalesce(p_ua, ''), 'sha256'), 'hex'),
    left(p->>'sid', 40),
    case when p->>'load' ~ '^\d{1,6}$' then (p->>'load')::int end,
    case when p->>'sec' ~ '^\d{1,7}$' then (p->>'sec')::int end,
    case when p->>'scroll' ~ '^\d{1,3}$' then (p->>'scroll')::int end,
    p_bot, v_ip,
    coalesce(left(p_country, 2), (select g.country from ip_geo g where g.ip = v_ip)),
    coalesce(left(p_network, 120), (select g.network from ip_geo g where g.ip = v_ip))
  );
end $$;
revoke all on function public.record_hit(jsonb, text, text, boolean, text, text, text, text, text) from public, anon, authenticated;

-- the "hit" function asks first whether an address is already known, so each address is looked up once
create or replace function public.ip_known(p_ip text) returns boolean
language sql stable security definer set search_path = public as $$
  select exists(select 1 from ip_geo where ip = p_ip and looked_up > now() - interval '30 days');
$$;
revoke all on function public.ip_known(text) from public, anon, authenticated;

-- purge_old_hits() also clears cached addresses no record uses any more
create or replace function public.purge_old_hits() returns bigint
language sql security definer set search_path = public as $$
  with d as (delete from hits where at < now() - interval '400 days' returning 1),
       g as (delete from ip_geo where looked_up < now() - interval '400 days'
             and not exists (select 1 from hits h where h.ip = ip_geo.ip) returning 1)
  select (select count(*) from d) + (select count(*) from g);
$$;
revoke all on function public.purge_old_hits() from public, anon, authenticated;

-- A permanent secret key that turns an ip address into a one-way code (`vid`) for the Jarvis ML dataset, so the
-- ML record can follow a visitor across weeks without holding the ip address. Never leaves the database.
create table if not exists public.ml_key (id int primary key default 1 check (id = 1), key text not null);
insert into public.ml_key(key) values (encode(extensions.gen_random_bytes(32), 'hex')) on conflict (id) do nothing;
alter table public.ml_key enable row level security;

-- weekly_access_data(issue date): who visited, by ip address, for the Friday report's "visitor access" section.
-- The weekly run merges it into the report data:
--   select public.weekly_report_data('2026-12-04') || jsonb_build_object('access', public.weekly_access_data('2026-12-04'));
create or replace function public.weekly_access_data(issue date)
returns jsonb
language sql
stable
security definer
set search_path = public, extensions
as $$
with bounds as (
  select ((issue - 7)::timestamp at time zone 'America/New_York') as w0,
         (issue::timestamp at time zone 'America/New_York') as w1
),
k as (select key from ml_key where id = 1),
h as (select hits.* from hits, bounds where at >= w0 and at < w1 and not is_bot and ip is not null),
v as (select * from h where kind = 'view'),
firsts as (select ip, min(at) as first_seen from hits where not is_bot and ip is not null group by ip),
per_ip as (
  select v.ip,
         max(v.country) as country, max(v.network) as network,
         (select f.first_seen from firsts f where f.ip = v.ip) as first_seen,
         max(v.at) as last_seen,
         count(*) as views,
         count(distinct (v.at at time zone 'America/New_York')::date) as days,
         array_agg(distinct v.page) as pages,
         (array_agg(v.page order by v.at))[1] as entry_page,
         (array_agg(coalesce(nullif(v.utm_source,''), nullif(v.referrer_host,''), 'direct') order by v.at))[1] as source,
         mode() within group (order by v.device) as device,
         mode() within group (order by v.browser) as browser,
         mode() within group (order by v.os) as os,
         mode() within group (order by v.tz) as tz
  from v group by v.ip
)
select jsonb_build_object(
  'ips', (select count(*) from per_ip),
  'new_ips', (select count(*) from per_ip, bounds where first_seen >= w0),
  'returning_ips', (select count(*) from per_ip, bounds where first_seen < w0),
  'located_ips', (select count(*) from per_ip where country is not null),
  'visitors', coalesce((select jsonb_agg(r order by (r->>'views')::int desc) from (
      select jsonb_build_object(
        'ip', p.ip, 'vid', left(encode(hmac(p.ip, (select key from k), 'sha256'), 'hex'), 16), 'country', p.country, 'network', p.network,
        'first_seen', p.first_seen, 'last_seen', p.last_seen, 'returning', p.first_seen < b.w0,
        'views', p.views, 'days', p.days, 'pages', to_jsonb(p.pages), 'entry_page', p.entry_page, 'source', p.source,
        'device', p.device, 'browser', p.browser, 'os', p.os, 'tz', p.tz,
        'seconds', (select coalesce(sum(seconds), 0) from h where h.ip = p.ip and kind = 'leave' and seconds between 0 and 3600),
        'photo_opens', (select count(*) from h where h.ip = p.ip and event = 'photo_open'),
        'ig_clicks', (select count(*) from h where h.ip = p.ip and event = 'ig_click'),
        'contact_sends', (select count(*) from h where h.ip = p.ip and event = 'contact_send')) r
      from per_ip p, bounds b order by p.views desc limit 25) s), '[]'),
  -- every visitor of the week for the Jarvis ML dataset: no ip address, only its one-way code
  'ml_rows', coalesce((select jsonb_agg(jsonb_build_object(
        'vid', left(encode(hmac(p.ip, (select key from k), 'sha256'), 'hex'), 16), 'country', p.country, 'network', p.network,
        'returning', p.first_seen < b.w0, 'views', p.views, 'days', p.days, 'pages', to_jsonb(p.pages),
        'entry_page', p.entry_page, 'source', p.source, 'device', p.device, 'browser', p.browser, 'os', p.os, 'tz', p.tz,
        'seconds', (select coalesce(sum(seconds), 0) from h where h.ip = p.ip and kind = 'leave' and seconds between 0 and 3600),
        'photo_opens', (select count(*) from h where h.ip = p.ip and event = 'photo_open'),
        'ig_clicks', (select count(*) from h where h.ip = p.ip and event = 'ig_click'),
        'contact_sends', (select count(*) from h where h.ip = p.ip and event = 'contact_send')))
      from per_ip p, bounds b), '[]'),
  'countries', coalesce((select jsonb_object_agg(c, n) from (
      select coalesce(country, 'unknown') c, count(*) n from per_ip group by 1) s), '{}'),
  'networks', coalesce((select jsonb_object_agg(nw, n) from (
      select coalesce(network, 'unknown') nw, count(*) n from per_ip group by 1 order by 2 desc limit 10) s), '{}'),
  'bots', coalesce((select jsonb_agg(r) from (
      select jsonb_build_object('ip', ip, 'network', max(network), 'hits', count(*)) r
      from hits, bounds where at >= w0 and at < w1 and is_bot and ip is not null
      group by ip order by count(*) desc limit 10) s), '[]')
)
from bounds;
$$;
revoke all on function public.weekly_access_data(date) from public, anon, authenticated;
