-- visitor log for www.claire-tian.com (Supabase project "claire-tian-analytics").
-- Row level security is on with no policies, so only the server side (the "hit" edge function, the weekly run) can read or write.
create extension if not exists pgcrypto with schema extensions;

create table if not exists public.hits (
  id bigint generated always as identity primary key,
  at timestamptz not null default now(),
  kind text not null default 'view',          -- view | leave | event
  event text,                                  -- photo_open | ig_click | contact_send
  label text,                                  -- for photo_open: the photo's file name
  page text not null,                          -- home | photo dump | photo | contact | privacy | 404
  path text,
  referrer_host text,
  utm_source text, utm_medium text, utm_campaign text,
  device text, browser text, os text,
  screen_w int, screen_h int,
  lang text, tz text,
  visitor text,                                -- one-way daily code; cannot be rebuilt once the day's salt is deleted
  session text,                                -- random per page load, ties a view to its leave
  is_new boolean,                              -- unused (nothing is stored on the visitor's device)
  load_ms int,
  seconds int,
  scroll_pct int,
  is_bot boolean not null default false
);
create index if not exists hits_at_idx on public.hits (at);
alter table public.hits enable row level security;

create table if not exists public.daily_salt (day date primary key, salt text not null);
alter table public.daily_salt enable row level security;

create or replace function public.record_hit(p jsonb, p_ip text, p_ua text, p_bot boolean, p_device text, p_browser text, p_os text)
returns void
language plpgsql
security definer
set search_path = public, extensions
as $$
declare
  d date := (now() at time zone 'America/New_York')::date;
  s text;
begin
  delete from daily_salt where day < d;
  insert into daily_salt(day, salt) values (d, encode(gen_random_bytes(32), 'hex')) on conflict (day) do nothing;
  select salt into s from daily_salt where day = d;
  insert into hits(kind, event, label, page, path, referrer_host, utm_source, utm_medium, utm_campaign,
                   device, browser, os, screen_w, screen_h, lang, tz, visitor, session,
                   load_ms, seconds, scroll_pct, is_bot)
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
    p_bot
  );
end $$;
revoke all on function public.record_hit(jsonb, text, text, boolean, text, text, text) from public, anon, authenticated;

-- records older than 400 days are deleted by the weekly run: select public.purge_old_hits();
create or replace function public.purge_old_hits() returns bigint
language sql security definer set search_path = public as $$
  with d as (delete from hits where at < now() - interval '400 days' returning 1) select count(*) from d;
$$;
revoke all on function public.purge_old_hits() from public, anon, authenticated;
