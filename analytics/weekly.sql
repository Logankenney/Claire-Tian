-- weekly_report_data(issue date): everything the Friday report needs, as one JSON value.
-- The week is the seven days before the issue date, Eastern time (Fri 00:00 to Thu 23:59).
-- Called by the weekly run through the Supabase connector: select public.weekly_report_data('2026-12-04');
create or replace function public.weekly_report_data(issue date)
returns jsonb
language sql
stable
security definer
set search_path = public
as $$
with bounds as (
  select ((issue - 7)::timestamp at time zone 'America/New_York') as w0,
         (issue::timestamp at time zone 'America/New_York') as w1,
         ((issue - 14)::timestamp at time zone 'America/New_York') as p0
),
h as (select hits.* from hits, bounds where at >= w0 and at < w1 and not is_bot),
prev as (select hits.* from hits, bounds where at >= p0 and at < w0 and not is_bot),
v as (select * from h where kind = 'view'),
pv as (select * from prev where kind = 'view'),
lv as (select * from h where kind = 'leave')
select jsonb_build_object(
  'week_start', (issue - 7), 'week_end', (issue - 1), 'issue', issue,
  'first_hit', (select min(at) from hits),
  'bots_filtered', (select count(*) from hits, bounds where at >= w0 and at < w1 and is_bot),
  'totals', jsonb_build_object(
    'views', (select count(*) from v),
    'visitors', (select count(distinct visitor) from v),
    'visits', (select count(distinct (visitor, (at at time zone 'America/New_York')::date)) from v),
    'photo_opens', (select count(*) from h where event = 'photo_open'),
    'ig_clicks', (select count(*) from h where event = 'ig_click'),
    'contact_sends', (select count(*) from h where event = 'contact_send'),
    'avg_seconds', (select round(avg(seconds)) from lv where seconds between 0 and 3600),
    'avg_load_ms', (select round(avg(load_ms)) from v where load_ms between 1 and 60000)),
  'previous', jsonb_build_object(
    'views', (select count(*) from pv),
    'visitors', (select count(distinct visitor) from pv),
    'visits', (select count(distinct (visitor, (at at time zone 'America/New_York')::date)) from pv),
    'photo_opens', (select count(*) from prev where event = 'photo_open'),
    'ig_clicks', (select count(*) from prev where event = 'ig_click'),
    'contact_sends', (select count(*) from prev where event = 'contact_send')),
  'by_day', coalesce((select jsonb_agg(d order by d->>'day') from (
      select jsonb_build_object('day', day, 'views', count(*), 'visitors', count(distinct visitor)) d
      from (select (at at time zone 'America/New_York')::date as day, visitor from v) x group by day) s), '[]'),
  'pages', coalesce((select jsonb_agg(r order by (r->>'views')::int desc) from (
      select jsonb_build_object('page', v.page, 'views', count(*), 'visitors', count(distinct v.visitor),
        'avg_seconds', (select round(avg(l.seconds)) from lv l where l.page = v.page and l.seconds between 0 and 3600),
        'avg_scroll', (select round(avg(l.scroll_pct)) from lv l where l.page = v.page and l.scroll_pct is not null)) r
      from v group by v.page) s), '[]'),
  'photos', coalesce((select jsonb_agg(r) from (
      select jsonb_build_object('photo', label, 'opens', count(*)) r from h where event = 'photo_open'
      group by label order by count(*) desc limit 10) s), '[]'),
  'sources', coalesce((select jsonb_agg(r) from (
      select jsonb_build_object('source', src, 'views', count(*), 'visitors', count(distinct visitor)) r
      from (select coalesce(nullif(utm_source,''), nullif(referrer_host,''), 'direct') as src, visitor from v) x
      group by src order by count(*) desc limit 15) s), '[]'),
  'campaigns', coalesce((select jsonb_agg(r) from (
      select jsonb_build_object('campaign', utm_campaign, 'medium', utm_medium, 'views', count(*)) r
      from v where coalesce(utm_campaign,'') <> '' group by utm_campaign, utm_medium order by count(*) desc limit 10) s), '[]'),
  'device', coalesce((select jsonb_object_agg(device, n) from (select device, count(distinct visitor) n from v group by device) s), '{}'),
  'browser', coalesce((select jsonb_object_agg(browser, n) from (select browser, count(distinct visitor) n from v group by browser) s), '{}'),
  'os', coalesce((select jsonb_object_agg(os, n) from (select os, count(distinct visitor) n from v group by os) s), '{}'),
  'language', coalesce((select jsonb_object_agg(lang, n) from (select coalesce(nullif(lang,''),'unknown') lang, count(distinct visitor) n from v group by 1 order by 2 desc limit 10) s), '{}'),
  'timezone', coalesce((select jsonb_object_agg(tz, n) from (select coalesce(nullif(tz,''),'unknown') tz, count(distinct visitor) n from v group by 1 order by 2 desc limit 12) s), '{}'),
  'screens', coalesce((select jsonb_object_agg(sz, n) from (select screen_w || 'x' || screen_h sz, count(distinct visitor) n from v where screen_w is not null group by 1 order by 2 desc limit 8) s), '{}'),
  'hours', coalesce((select jsonb_object_agg(hr, n) from (select extract(hour from at at time zone 'America/New_York')::int hr, count(*) n from v group by 1) s), '{}'),
  'not_found', coalesce((select jsonb_agg(r) from (select jsonb_build_object('path', path, 'views', count(*)) r from v where page = '404' group by path order by count(*) desc limit 10) s), '[]')
)
from bounds;
$$;
revoke all on function public.weekly_report_data(date) from public, anon, authenticated;
