-- CRM for www.claire-tian.com (Supabase project "claire-tian-analytics"). Logan 2026-11-28: "apply the crm system".
-- Visitors join with their email (Supabase Auth, email link or 6-digit code, no password). Each account gets a members
-- row with a permission level (for advanced access later), a stage (where they are as a client), an optional marketing
-- opt-in with its consent record, sign-in counts and the site visits made while signed in. Claire and Logan read and
-- manage it in crm.html on the site and in the "claire tian crm" mac app.
--
-- Run once in the Supabase SQL editor. It does not depend on analytics/ip.sql and can run before or after it.
-- Then make Logan (and Claire) admins once they have signed in once:
--   update public.members set permission = 'admin' where lower(email) = lower('<their email>');
--
-- Access: row level security is on for every table. A visitor sees only their own member row and consents.
-- staff and admin see everything through the crm_* functions; only admin can change permission levels.
-- The site and the mac app only hold the publishable key; every read goes through these rules.

-- ---- tables --------------------------------------------------------------------------------------

create table if not exists public.members (
  id uuid primary key references auth.users(id) on delete cascade,
  email text not null,
  name text,
  joined timestamptz not null default now(),
  permission text not null default 'member'
    check (permission in ('member', 'insider', 'staff', 'admin')),       -- member: signed up. insider: advanced access (later).
                                                                           -- staff: reads the crm. admin: runs it.
  stage text not null default 'new'
    check (stage in ('new', 'talking', 'booked', 'client', 'past client', 'not a fit')),
  tags text[] not null default '{}',
  marketing boolean not null default false,                                -- current opt-in for marketing email
  marketing_at timestamptz,                                                -- when it last changed
  sign_ins int not null default 0,
  last_sign_in timestamptz,
  last_seen timestamptz,                                                   -- last page viewed while signed in
  first_page text                                                          -- where they joined from
);
create unique index if not exists members_email_idx on public.members (lower(email));
alter table public.members enable row level security;

-- every marketing opt-in and opt-out, with the words the person saw, kept as proof of consent
create table if not exists public.consents (
  id bigint generated always as identity primary key,
  member_id uuid not null references public.members(id) on delete cascade,
  at timestamptz not null default now(),
  kind text not null default 'marketing',
  given boolean not null,
  wording text,
  source text                                                              -- join | account | crm | app
);
create index if not exists consents_member_idx on public.consents (member_id, at desc);
alter table public.consents enable row level security;

-- page views made while signed in. "session" matches hits.session, so the full visit record can be joined.
create table if not exists public.member_visits (
  id bigint generated always as identity primary key,
  member_id uuid not null references public.members(id) on delete cascade,
  at timestamptz not null default now(),
  session text not null,
  page text
);
create unique index if not exists member_visits_session_idx on public.member_visits (member_id, session);
create index if not exists member_visits_member_idx on public.member_visits (member_id, at desc);
alter table public.member_visits enable row level security;

-- sign-ins, joins and crm changes, newest first in the crm
create table if not exists public.member_events (
  id bigint generated always as identity primary key,
  member_id uuid not null references public.members(id) on delete cascade,
  at timestamptz not null default now(),
  event text not null,                                                     -- joined | signed in | changed
  detail text
);
create index if not exists member_events_member_idx on public.member_events (member_id, at desc);
alter table public.member_events enable row level security;

create table if not exists public.crm_notes (
  id bigint generated always as identity primary key,
  member_id uuid not null references public.members(id) on delete cascade,
  at timestamptz not null default now(),
  author text,
  body text not null check (length(body) between 1 and 4000)
);
create index if not exists crm_notes_member_idx on public.crm_notes (member_id, at desc);
alter table public.crm_notes enable row level security;

-- ---- who is asking -------------------------------------------------------------------------------

create or replace function public.crm_role() returns text
language sql stable security definer set search_path = public as $$
  select permission from members where id = auth.uid();
$$;
create or replace function public.crm_is_staff() returns boolean
language sql stable security definer set search_path = public as $$
  select coalesce((select permission in ('staff', 'admin') from members where id = auth.uid()), false);
$$;
create or replace function public.crm_is_admin() returns boolean
language sql stable security definer set search_path = public as $$
  select coalesce((select permission = 'admin' from members where id = auth.uid()), false);
$$;

-- ---- row level security --------------------------------------------------------------------------
-- reads only; every write goes through the functions below

drop policy if exists "own row or staff" on public.members;
create policy "own row or staff" on public.members for select to authenticated
  using (id = (select auth.uid()) or (select public.crm_is_staff()));
drop policy if exists "own consents or staff" on public.consents;
create policy "own consents or staff" on public.consents for select to authenticated
  using (member_id = (select auth.uid()) or (select public.crm_is_staff()));
drop policy if exists "staff" on public.member_visits;
create policy "staff" on public.member_visits for select to authenticated using ((select public.crm_is_staff()));
drop policy if exists "staff" on public.member_events;
create policy "staff" on public.member_events for select to authenticated using ((select public.crm_is_staff()));
drop policy if exists "staff" on public.crm_notes;
create policy "staff" on public.crm_notes for select to authenticated using ((select public.crm_is_staff()));

revoke insert, update, delete on public.members, public.consents, public.member_visits, public.member_events, public.crm_notes
  from anon, authenticated;
revoke all on public.members, public.consents, public.member_visits, public.member_events, public.crm_notes from anon;
grant select on public.members, public.consents, public.member_visits, public.member_events, public.crm_notes to authenticated;

-- ---- accounts: made and kept up to date from supabase auth ----------------------------------------

create or replace function public.crm_on_user_created() returns trigger
language plpgsql security definer set search_path = public as $$
declare
  m jsonb := coalesce(new.raw_user_meta_data, '{}'::jsonb);
  yes boolean := coalesce((m->>'marketing')::boolean, false);
begin
  insert into members(id, email, marketing, marketing_at, first_page)
  values (new.id, coalesce(new.email, ''), yes, case when yes then now() end, left(m->>'from', 60))
  on conflict (id) do nothing;
  insert into member_events(member_id, event, detail) values (new.id, 'joined', left(m->>'from', 60));
  if yes then
    insert into consents(member_id, given, wording, source) values (new.id, true, left(m->>'marketing_text', 400), 'join');
  end if;
  return new;
exception when others then
  raise warning 'crm_on_user_created: %', sqlerrm;   -- never block a sign-up
  return new;
end $$;
drop trigger if exists crm_user_created on auth.users;
create trigger crm_user_created after insert on auth.users for each row execute function public.crm_on_user_created();

create or replace function public.crm_on_user_updated() returns trigger
language plpgsql security definer set search_path = public as $$
begin
  if new.last_sign_in_at is distinct from old.last_sign_in_at and new.last_sign_in_at is not null then
    update members set sign_ins = sign_ins + 1, last_sign_in = new.last_sign_in_at where id = new.id;
    insert into member_events(member_id, event) select new.id, 'signed in' where exists (select 1 from members where id = new.id);
  end if;
  if new.email is distinct from old.email and new.email is not null then
    update members set email = new.email where id = new.id;
  end if;
  return new;
exception when others then
  raise warning 'crm_on_user_updated: %', sqlerrm;
  return new;
end $$;
drop trigger if exists crm_user_updated on auth.users;
create trigger crm_user_updated after update on auth.users for each row execute function public.crm_on_user_updated();

-- ---- for the signed-in visitor ---------------------------------------------------------------------

-- the visitor's own account, for account.html
create or replace function public.my_account() returns jsonb
language sql stable security definer set search_path = public as $$
  select jsonb_build_object('email', email, 'joined', joined, 'marketing', marketing, 'marketing_at', marketing_at,
                            'permission', permission)
  from members where id = auth.uid();
$$;

-- tick or untick "send me news"; every change is kept in consents
create or replace function public.set_marketing(p_on boolean, p_wording text default null, p_source text default 'account')
returns void language plpgsql security definer set search_path = public as $$
begin
  if auth.uid() is null then raise exception 'not signed in'; end if;
  update members set marketing = p_on, marketing_at = now() where id = auth.uid() and marketing is distinct from p_on;
  if found then
    insert into consents(member_id, given, wording, source) values (auth.uid(), p_on, left(p_wording, 400), left(p_source, 20));
  end if;
end $$;

-- stats.js calls this once per page view while the visitor is signed in (and only when the visitor log counts them)
create or replace function public.link_visit(p_session text, p_page text) returns void
language plpgsql security definer set search_path = public as $$
begin
  if auth.uid() is null or coalesce(p_session, '') = '' then return; end if;
  insert into member_visits(member_id, session, page)
  select auth.uid(), left(p_session, 40), left(p_page, 60) where exists (select 1 from members where id = auth.uid())
  on conflict (member_id, session) do nothing;
  update members set last_seen = now() where id = auth.uid();
end $$;

-- "delete my account": removes the login and everything in the crm about the person (cascades)
create or replace function public.delete_my_account() returns void
language plpgsql security definer set search_path = public, auth as $$
begin
  if auth.uid() is null then raise exception 'not signed in'; end if;
  delete from auth.users where id = auth.uid();
end $$;

-- ---- for claire and logan: the crm ----------------------------------------------------------------

-- every member with their numbers, for the list
create or replace function public.crm_list() returns jsonb
language plpgsql stable security definer set search_path = public as $$
begin
  if not crm_is_staff() then raise exception 'no access' using errcode = '42501'; end if;
  return coalesce((select jsonb_agg(r order by r->>'joined' desc) from (
    select to_jsonb(m) || jsonb_build_object(
      'visits', (select count(*) from member_visits v where v.member_id = m.id),
      'notes', (select count(*) from crm_notes n where n.member_id = m.id)) r
    from members m) s), '[]'::jsonb);
end $$;

-- one member in full: account, consents, events, notes and their last 200 signed-in page views
-- (joined to the visitor log for device, browser and where they came from)
create or replace function public.crm_member(p_id uuid) returns jsonb
language plpgsql stable security definer set search_path = public as $$
declare has_hits boolean := to_regclass('public.hits') is not null;
        visits jsonb;
begin
  if not crm_is_staff() then raise exception 'no access' using errcode = '42501'; end if;
  if has_hits then
    execute $q$
      select coalesce(jsonb_agg(jsonb_build_object('at', v.at, 'page', v.page, 'device', h.device, 'browser', h.browser,
               'os', h.os, 'from', coalesce(nullif(h.utm_source, ''), nullif(h.referrer_host, '')), 'seconds', l.seconds)
               order by v.at desc), '[]'::jsonb)
      from (select * from member_visits where member_id = $1 order by at desc limit 200) v
      left join lateral (select * from hits where session = v.session and kind = 'view' order by at limit 1) h on true
      left join lateral (select seconds from hits where session = v.session and kind = 'leave' order by at limit 1) l on true
    $q$ into visits using p_id;
  else
    select coalesce(jsonb_agg(jsonb_build_object('at', at, 'page', page) order by at desc), '[]'::jsonb) into visits
    from (select * from member_visits where member_id = p_id order by at desc limit 200) v;
  end if;
  return (select to_jsonb(m) || jsonb_build_object(
    'visits', visits,
    'consents', (select coalesce(jsonb_agg(to_jsonb(c) - 'member_id' order by c.at desc), '[]'::jsonb) from consents c where c.member_id = m.id),
    'events', (select coalesce(jsonb_agg(to_jsonb(e) - 'member_id' order by e.at desc), '[]'::jsonb)
               from (select * from member_events where member_id = m.id order by at desc limit 100) e),
    'notes', (select coalesce(jsonb_agg(to_jsonb(n) - 'member_id' order by n.at desc), '[]'::jsonb) from crm_notes n where n.member_id = m.id))
  from members m where m.id = p_id);
end $$;

-- numbers for the top of the crm
create or replace function public.crm_summary() returns jsonb
language plpgsql stable security definer set search_path = public as $$
begin
  if not crm_is_staff() then raise exception 'no access' using errcode = '42501'; end if;
  return jsonb_build_object(
    'members', (select count(*) from members),
    'new_7d', (select count(*) from members where joined > now() - interval '7 days'),
    'marketing', (select count(*) from members where marketing),
    'active_7d', (select count(*) from members where greatest(last_seen, last_sign_in) > now() - interval '7 days'),
    'stages', coalesce((select jsonb_object_agg(stage, n) from (select stage, count(*) n from members group by stage) s), '{}'::jsonb),
    'role', crm_role());
end $$;

-- change a member: name, stage and tags (staff and admin); permission (admin only)
create or replace function public.crm_update(p_id uuid, p_patch jsonb) returns void
language plpgsql security definer set search_path = public as $$
declare before members; changed text[] := '{}';
begin
  if not crm_is_staff() then raise exception 'no access' using errcode = '42501'; end if;
  if p_patch ? 'permission' and not crm_is_admin() then raise exception 'only an admin can change access' using errcode = '42501'; end if;
  if p_patch ? 'permission' and p_id = auth.uid() and p_patch->>'permission' <> 'admin' then
    raise exception 'you cannot take away your own admin access';
  end if;
  select * into before from members where id = p_id;
  if not found then raise exception 'no such member'; end if;
  update members set
    name = case when p_patch ? 'name' then nullif(left(trim(p_patch->>'name'), 120), '') else name end,
    stage = coalesce(case when p_patch ? 'stage' then p_patch->>'stage' end, stage),
    permission = coalesce(case when p_patch ? 'permission' then p_patch->>'permission' end, permission),
    tags = case when p_patch ? 'tags' then
             array(select distinct lower(left(trim(t), 40)) from jsonb_array_elements_text(p_patch->'tags') t where trim(t) <> '')
           else tags end
  where id = p_id;
  if p_patch ? 'stage' and p_patch->>'stage' is distinct from before.stage then changed := changed || ('stage: ' || (p_patch->>'stage')); end if;
  if p_patch ? 'permission' and p_patch->>'permission' is distinct from before.permission then changed := changed || ('access: ' || (p_patch->>'permission')); end if;
  if p_patch ? 'name' then changed := changed || 'name'::text; end if;
  if p_patch ? 'tags' then changed := changed || 'tags'::text; end if;
  if array_length(changed, 1) > 0 then
    insert into member_events(member_id, event, detail)
    values (p_id, 'changed', array_to_string(changed, ', ') || ' (by ' || coalesce((select email from members where id = auth.uid()), '?') || ')');
  end if;
end $$;

create or replace function public.crm_add_note(p_id uuid, p_body text) returns void
language plpgsql security definer set search_path = public as $$
begin
  if not crm_is_staff() then raise exception 'no access' using errcode = '42501'; end if;
  insert into crm_notes(member_id, author, body)
  values (p_id, (select coalesce(name, email) from members where id = auth.uid()), left(trim(p_body), 4000));
end $$;

-- accounts with no sign-in for two years are deleted (legal.html section 9). the weekly run calls it:
--   select public.crm_purge_stale();
create or replace function public.crm_purge_stale() returns bigint
language sql security definer set search_path = public, auth as $$
  with d as (delete from auth.users u using members m
             where m.id = u.id and m.permission in ('member', 'insider')
               and coalesce(m.last_sign_in, m.joined) < now() - interval '2 years' returning 1)
  select count(*) from d;
$$;
revoke all on function public.crm_purge_stale() from public, anon, authenticated;

-- ---- who may call what -----------------------------------------------------------------------------

revoke all on function public.crm_on_user_created(), public.crm_on_user_updated() from public, anon, authenticated;
revoke all on function public.crm_role(), public.crm_is_staff(), public.crm_is_admin(), public.my_account(),
  public.set_marketing(boolean, text, text), public.link_visit(text, text), public.delete_my_account(),
  public.crm_list(), public.crm_member(uuid), public.crm_summary(), public.crm_update(uuid, jsonb),
  public.crm_add_note(uuid, text) from public, anon;
grant execute on function public.crm_role(), public.crm_is_staff(), public.crm_is_admin(), public.my_account(),
  public.set_marketing(boolean, text, text), public.link_visit(text, text), public.delete_my_account(),
  public.crm_list(), public.crm_member(uuid), public.crm_summary(), public.crm_update(uuid, jsonb),
  public.crm_add_note(uuid, text) to authenticated;
