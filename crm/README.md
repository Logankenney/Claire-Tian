# CRM

Visitors can **join** (the "join" link at the bottom of every page, `account.html`) with their email: no password,
Supabase emails them a link and a 6-digit code. Joining makes a member record; the optional tick box records marketing
consent. While signed in, the pages they view are linked to their account. Claire and Logan manage everyone in the CRM:
`crm.html` on the site (not linked anywhere, `noindex`) or the Mac app (`mac/`).

| File | What it is |
|---|---|
| `crm/schema.sql` | Tables (`members`, `consents`, `member_visits`, `member_events`, `crm_notes`), row level security, the sign-up and sign-in triggers on `auth.users`, and the functions the pages call |
| `auth.js` | Sign-in (email link or code), keeps the session (`ct-auth`), calls the database functions. Publishable key only |
| `account.html`, `account.js` | Join, sign in, marketing tick box, sign out, delete my account |
| `crm.html`, `crm.css`, `crm.js` | The CRM screen: list with search and filters, one person (name, stage, access, tags, consents, notes, pages seen, history), CSV export |
| `stats.js` | Also links each counted page view to the member's account when they are signed in (`link_visit`) |
| `mac/` | The Mac app (see `mac/README.md`) |

**Access levels** (`members.permission`): `member` (joined), `insider` (for advanced access later), `staff` (reads and
works the CRM, cannot change access), `admin` (everything). **Stages**: new, talking, booked, client, past client,
not a fit.

## Turning it on (once, after the pull request is merged)

1. **Database:** run `crm/schema.sql` in the Supabase SQL editor (project `claire-tian-analytics`). It does not need
   `analytics/ip.sql` first.
2. **Supabase > Authentication > URL Configuration:** Site URL `https://www.claire-tian.com`; add Redirect URLs
   `https://www.claire-tian.com/account.html` and `https://www.claire-tian.com/crm.html`.
3. **Authentication > Emails > Templates:** in both **Confirm signup** and **Magic Link**, put the code in the email
   so the Mac app (and phones that open the link in another browser) can sign in:

   Subject: `your claire tian sign-in`

   ```html
   <p>sign in to claire tian:</p>
   <p><a href="{{ .ConfirmationURL }}">sign in</a></p>
   <p>or type this code: <b>{{ .Token }}</b></p>
   <p>if you did not ask for this, ignore it.</p>
   ```
4. **Authentication > Emails > SMTP Settings:** Supabase's own email service only sends to the Supabase team's own
   addresses and a few per hour, which is enough for Logan and Claire to test. Before telling the public, connect a
   sender, e.g. Resend (free up to 3,000 a month): verify `claire-tian.com` there (three DNS records at GoDaddy),
   then enter its SMTP details here with sender `hello@claire-tian.com`.
5. **Make Logan and Claire admins:** each signs in once on `https://www.claire-tian.com/account.html`, then in the SQL
   editor: `update public.members set permission = 'admin' where lower(email) = lower('<their email>');`
   (Emails are not written in this repository.)

**Housekeeping:** the weekly run calls `select public.crm_purge_stale();` which deletes member accounts with no sign-in
for two years (as `legal.html` says). Staff and admin accounts are never purged.
