#!/usr/bin/env python3
"""Write the Friday site report for www.claire-tian.com as Markdown (v2, 2026-11-28).

    python3 tools/weekly_report.py --data week.json --competition comp.md --out report.md
        [--notes notes.md] [--issues issues.json] [--emails emails.json] [--agents agents.json]

--data         the JSON from Supabase, with the visitor access block merged in:
               select public.weekly_report_data('YYYY-MM-DD') || jsonb_build_object('access', public.weekly_access_data('YYYY-MM-DD'));
--competition  this week's competition section (Markdown), written by the weekly run from its web searches
--notes        optional: the run's short commentary, put under the status board
--issues       optional: issues the run found, [{"title", "severity": high|medium|low, "area", "why", "subtasks": [..]}];
               the report adds the ones it can see itself (SEO gaps, 404s, unregistered browser storage, ...)
--emails       optional: high priority emails of the week, [{"received", "from", "subject", "why", "action"}]
--agents       optional: agent processes completed this week, [{"when", "agent", "process", "result", "link"}]

Logan 2026-11-28 07:03Z: "increase the readability of the report, include more visuals, highlight issues with
sub-tasks to resolve those issues, high priority emails, agent completed processes as well as everything currently
included ... expand upon the user access information, create a cookies register - follow the ip".
The SEO section and the cookies register check are made here from the site files in this repository. Standard library only.
"""
import argparse, datetime, json, pathlib, re
from zoneinfo import ZoneInfo

ROOT = pathlib.Path(__file__).resolve().parent.parent
PAGES = [("home", "index.html"), ("photo dump", "recent.html"), ("photo", "photo.html"),
         ("contact", "contact.html"), ("privacy", "privacy.html"), ("404", "404.html")]
SEV = {"high": "🔴 high", "medium": "🟡 medium", "low": "🟢 low"}
SPARK = "▁▂▃▄▅▆▇█"


# --- small helpers -------------------------------------------------------------------------------------------

def n(x):
    return "–" if x is None else f"{x:,}" if isinstance(x, int) else str(x)


def change(now, before):
    if now is None or before is None:
        return "–"
    if before == 0:
        return "🆕 new" if now else "–"
    pct = round(100 * (now - before) / before)
    return ("▲ " if pct > 0 else "▼ " if pct < 0 else "● ") + f"{pct:+d}%"


def bar(value, top, width=20):
    if not top:
        return ""
    full = round(width * value / top)
    return "█" * max(1 if value else 0, full) + "░" * (width - max(1 if value else 0, full))


def meter(pct, width=10):
    full = round(width * pct / 100)
    return "█" * full + "░" * (width - full) + f" {pct}%"


def spark(values):
    top = max(values or [0])
    if not top:
        return "▁" * len(values)
    return "".join(SPARK[min(7, round(7 * v / top))] for v in values)


def table(head, rows):
    out = ["| " + " | ".join(head) + " |", "|" + "---|" * len(head)]
    out += ["| " + " | ".join(str(c).replace("|", "/") for c in r) + " |" for r in rows]
    return "\n".join(out)


def shares(d, label):
    if not d:
        return f"_{label}: no data._"
    total = sum(d.values())
    rows = sorted(d.items(), key=lambda kv: -kv[1])
    top = rows[0][1]
    return table([label, "visitors", "share", ""], [(k, v, f"{round(100 * v / total)}%", bar(v, top, 12)) for k, v in rows])


def light(level):
    return {"good": "🟢", "watch": "🟡", "act": "🔴", "none": "⚪"}[level]


def when(ts):
    if not ts:
        return "–"
    try:
        t = datetime.datetime.fromisoformat(str(ts).replace("Z", "+00:00"))
        return t.astimezone(ZoneInfo("America/New_York")).strftime("%a %m-%d %H:%M")
    except ValueError:
        return str(ts)[:16]


def mask(ip, full=False):
    """The report is shared by link, so it shows an ip address without its last part (203.0.113.x); the full
    address stays in the visitor log. --full-ip shows it whole."""
    if full or not ip:
        return ip or "–"
    if ":" in ip:
        return ":".join(ip.split(":")[:3]) + ":…"
    return ".".join(ip.split(".")[:3]) + ".x"


def load_json(path, default):
    return json.loads(pathlib.Path(path).read_text()) if path else default


# --- checks made from the site files --------------------------------------------------------------------------

def seo_checks():
    rows, site, issues, passed, total = [], [], [], 0, 0
    for name, f in PAGES:
        p = ROOT / f
        if not p.exists():
            continue
        h = p.read_text(encoding="utf-8")
        title = re.search(r"<title>(.*?)</title>", h, re.S)
        desc = re.search(r'<meta name="description" content="([^"]*)"', h)
        dl = len(desc.group(1)) if desc else 0
        checks = {"title": bool(title), "description": 120 <= dl <= 160, "canonical": 'rel="canonical"' in h,
                  "preview image": 'property="og:image"' in h}
        if name == "home":
            checks["structured data"] = "application/ld+json" in h
        if name == "404":
            checks = {"noindex": "noindex" in h}
        total += len(checks)
        passed += sum(checks.values())
        if name != "404" and not checks["description"]:
            issues.append(f"{name}: description is {dl} characters (aim for 120 to 160)" if dl else f"{name}: no description")
        rows.append((name,
                     title.group(1) if title else "❌ none",
                     ("✅ " if 120 <= dl <= 160 else "⚠ " if dl else "❌ ") + (f"{dl} chars" if dl else "none"),
                     "✅" if 'rel="canonical"' in h else "❌",
                     "✅" if 'property="og:image"' in h else "❌",
                     "✅" if "application/ld+json" in h else "–" if name != "home" else "❌",
                     "✅" if "noindex" in h else "–" if name != "404" else "❌ indexable"))
    robots = (ROOT / "robots.txt").exists()
    sitemap = ROOT / "sitemap.xml"
    total += 2
    passed += robots + sitemap.exists()
    site.append(("robots.txt", "✅ present" if robots else "❌ missing"))
    site.append(("sitemap.xml", f"✅ {sitemap.read_text().count('<loc>')} addresses" if sitemap.exists() else "❌ missing"))
    if not robots:
        issues.append("robots.txt is missing")
    if not sitemap.exists():
        issues.append("sitemap.xml is missing")
    verify = sorted(p.name for p in ROOT.glob("google*.html"))
    site.append(("Google Search Console file", f"✅ {verify[0]}" if verify else "❌ missing"))
    photos = json.loads((ROOT / "photos.json").read_text())
    count = len(photos) if isinstance(photos, list) else sum(len(v) for v in photos.values())
    site.append(("photos on the site", str(count)))
    site.append(("photo details file", "✅ present" if (ROOT / "photos" / "details.json").exists() else "❌ missing"))
    score = round(100 * passed / total) if total else 0
    text = (f"**SEO score:** {meter(score)} ({passed} of {total} checks pass)\n\n"
            + table(["page", "title", "description", "canonical", "preview image", "structured data", "404 noindex"], rows)
            + "\n\n" + table(["site-wide", "status"], site))
    return text, score, issues


def storage_checks():
    """What the site's scripts store in a browser, checked against docs/cookies-register.json."""
    reg_path = ROOT / "docs" / "cookies-register.json"
    reg = json.loads(reg_path.read_text()) if reg_path.exists() else {"cookies": [], "storage": [], "third_parties": []}
    found = {}
    for js in sorted(ROOT.glob("*.js")):
        src = js.read_text(encoding="utf-8")
        for kind, name in re.findall(r"(localStorage|sessionStorage)\.setItem\(\s*['\"]([^'\"]+)['\"]", src):
            found[name] = (kind, js.name)
        for m in re.findall(r"document\.cookie\s*=\s*['\"`]?([A-Za-z0-9_\-]+)=", src):
            found[m] = ("cookie", js.name)
        # a storage key kept in a constant (auth.js: const SLOT = 'ct-auth'; store.set(SLOT, ...))
        if re.search(r"(localStorage|sessionStorage)\.setItem\(\s*[A-Za-z_]", src):
            kind = "localStorage" if "localStorage.setItem" in src else "sessionStorage"
            for name in re.findall(r"const\s+[A-Z_]+\s*=\s*['\"](ct-[a-z0-9\-]+)['\"]", src):
                found.setdefault(name, (kind, js.name))
    known = {x["name"] for x in reg.get("storage", []) + reg.get("cookies", [])}
    unregistered = sorted(set(found) - known)
    rows = [(x["name"], x["type"], x["set_by"], x["purpose"], x["kept"], x["category"],
             "✅ seen in code" if x["name"] in found else "⚠ not in code") for x in reg.get("cookies", []) + reg.get("storage", [])]
    rows += [(k, found[k][0], found[k][1], "❌ not registered", "–", "–", "❌ add to register") for k in unregistered]
    cookies = len(reg.get("cookies", [])) + sum(1 for k in unregistered if found[k][0] == "cookie")
    text = [f"**Cookies set:** {cookies} · **browser storage items:** {len(rows) - cookies} · "
            f"**unregistered:** {len(unregistered)} · register updated {reg.get('updated', '–')} (`docs/cookies-register.json`)", "",
            table(["name", "type", "set by", "purpose", "kept", "category", "check"], rows) if rows else "_nothing stored._", "",
            "**Outside services a page load reaches**", "",
            table(["service", "what for", "receives", "cookies"],
                  [(t["name"], t["what"], t["receives"], t["cookies"]) for t in reg.get("third_parties", [])])]
    return "\n".join(text), unregistered


# --- the report -------------------------------------------------------------------------------------------------

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--data", required=True)
    ap.add_argument("--competition", required=True)
    ap.add_argument("--notes")
    ap.add_argument("--issues")
    ap.add_argument("--emails")
    ap.add_argument("--agents")
    ap.add_argument("--full-ip", action="store_true", help="show whole ip addresses (only for a report that is not shared)")
    ap.add_argument("--out", required=True)
    a = ap.parse_args()
    ipf = lambda ip: mask(ip, a.full_ip)
    d = json.loads(pathlib.Path(a.data).read_text())
    t, p, acc = d.get("totals", {}), d.get("previous", {}), d.get("access") or {}
    issue = datetime.date.fromisoformat(d["issue"])
    week0 = datetime.date.fromisoformat(d["week_start"])
    has_data = bool(t.get("views"))
    seo_text, seo_score, seo_issues = seo_checks()
    storage_text, unregistered = storage_checks()
    emails = load_json(a.emails, [])
    agents = load_json(a.agents, [])

    # issues: the run's own, then what the report can see itself
    issues = list(load_json(a.issues, []))
    if seo_issues:
        issues.append({"title": "Search listing text needs work", "severity": "medium", "area": "SEO",
                       "why": f"{len(seo_issues)} thing(s) to fix in how the pages show up in search results.",
                       "subtasks": [f"Fix: {s}" for s in seo_issues[:5]] + ["Re-check in next Friday's report"]})
    if not d.get("search_console"):
        issues.append({"title": "Google Search Console not connected", "severity": "high", "area": "SEO",
                       "why": "Without it Google may not index the site, and the report has no search clicks or rankings.",
                       "subtasks": ["Open search.google.com/search-console and add www.claire-tian.com (the verification file is already on the site)",
                                    "Submit https://www.claire-tian.com/sitemap.xml",
                                    "Request indexing of the home page",
                                    "Tell Claude it is done so the report starts reading it"]})
    if d.get("not_found"):
        issues.append({"title": "Broken links (404) were visited", "severity": "medium", "area": "Site health",
                       "why": ", ".join(x["path"] for x in d["not_found"][:5]),
                       "subtasks": ["Find where each address is linked from", "Fix the link or add a redirect page"]})
    if unregistered:
        issues.append({"title": "Browser storage not in the cookies register", "severity": "high", "area": "Privacy",
                       "why": ", ".join(unregistered),
                       "subtasks": ["Add each item to docs/cookies-register.json", "Check the privacy page still describes it"]})
    if acc.get("ips") and not acc.get("located_ips"):
        issues.append({"title": "Visitor locations are off", "severity": "low", "area": "Visitor access",
                       "why": "No ip address had a country or network: the IPINFO_TOKEN secret is not set on the hit function.",
                       "subtasks": ["Make a free ipinfo.io account and copy its token",
                                    "Add it as IPINFO_TOKEN in Supabase > Edge Functions > Secrets"]})
    if has_data and not t.get("contact_sends"):
        issues.append({"title": "No enquiries this week", "severity": "low", "area": "Business",
                       "why": f"{t.get('visits', 0)} visits and no contact sends.",
                       "subtasks": ["Share the site link from Instagram (bio or story)", "Watch next week's sources table"]})
    order = {"high": 0, "medium": 1, "low": 2}
    issues.sort(key=lambda i: order.get(i.get("severity", "low"), 3))

    # status board
    v, pv = t.get("visits") or 0, p.get("visits") or 0
    traffic = "none" if not has_data else "good" if v >= pv else "watch"
    enquiries = "good" if t.get("contact_sends") else "watch" if has_data else "none"
    seo_light = "good" if seo_score >= 85 else "watch" if seo_score >= 60 else "act"
    search = "good" if d.get("search_console") else "act"
    health = "act" if d.get("not_found") else "good" if (t.get("avg_load_ms") or 0) < 2000 else "watch"
    privacy = "act" if unregistered else "good"
    high = sum(1 for i in issues if i.get("severity") == "high")

    L = ["# claire tian · weekly site report", "",
         f"**Week:** {d['week_start']} to {d['week_end']} (Eastern) · **Issued:** {issue:%a %Y-%m-%d}, 8:00 AM ET",
         "**Site:** https://www.claire-tian.com · **Filed:** Jarvis Document Control › projects/Claire-Tian/Reports/"
         f"{issue:%Y-%m-%d}", "",
         "## At a glance", "",
         table(["area", "status", "this week"], [
             ("traffic", light(traffic), f"{n(t.get('visits'))} visits, {n(t.get('views'))} pages ({change(t.get('visits'), p.get('visits'))})"),
             ("enquiries", light(enquiries), f"{n(t.get('contact_sends'))} contact sends"),
             ("search (SEO)", light(seo_light), meter(seo_score)),
             ("found on Google", light(search), "Search Console connected" if d.get("search_console") else "not connected yet"),
             ("site health", light(health), f"{n(t.get('avg_load_ms'))} ms average load, {len(d.get('not_found') or [])} broken links"),
             ("privacy register", light(privacy), "everything registered" if not unregistered else f"{len(unregistered)} unregistered"),
             ("open issues", "🔴" if high else "🟡" if issues else "🟢", f"{len(issues)} ({high} high)"),
             ("priority emails", "🟡" if emails else "🟢", f"{len(emails)}"),
             ("agent processes done", "🟢", f"{len(agents)}"),
         ]), "",
         "🟢 good · 🟡 watch · 🔴 act now · ⚪ no data", ""]
    if a.notes:
        L += [pathlib.Path(a.notes).read_text().strip(), ""]
    if not has_data:
        L += ["> **No visits were recorded this week.** "
              + ("The visitor log has no records yet." if not d.get("first_hit") else "Logging is on; nobody visited, or every visit came from a bot."), ""]

    # 1. issues
    L += ["## 1. Issues and what to do", ""]
    if issues:
        L += [table(["#", "issue", "priority", "area"], [(i + 1, x["title"], SEV.get(x.get("severity"), x.get("severity", "–")), x.get("area", "–"))
                                                        for i, x in enumerate(issues)]), ""]
        for i, x in enumerate(issues, 1):
            L += [f"**{i}. {x['title']}** · {SEV.get(x.get('severity'), '')}", ""]
            if x.get("why"):
                L += [f"_{x['why']}_", ""]
            L += [f"- ☐ {s}" for s in x.get("subtasks", [])] + [""]
    else:
        L += ["🟢 No open issues.", ""]

    # 2. emails
    L += ["## 2. High priority emails", ""]
    L += [table(["received", "from", "subject", "why it matters", "next step"],
                [(when(e.get("received")), e.get("from", "–"), e.get("subject", "–"), e.get("why", "–"), e.get("action", "–")) for e in emails])
          if emails else "_None this week._", ""]

    # 3. agents
    L += ["## 3. Agent processes completed", ""]
    L += [table(["when", "agent", "process", "result", "link"],
                [(when(x.get("when")), x.get("agent", "–"), x.get("process", "–"), x.get("result", "–"), x.get("link", "–")) for x in agents])
          if agents else "_None recorded this week._", ""]

    # 4. traffic
    days = {x["day"]: x for x in d.get("by_day") or []}
    week = [week0 + datetime.timedelta(i) for i in range(7)]
    views7 = [days.get(str(dd), {}).get("views", 0) for dd in week]
    L += ["## 4. Traffic", "",
          f"**Pages viewed each day:** `{spark(views7)}`  ({' · '.join(f'{dd:%a} {v}' for dd, v in zip(week, views7))})", "",
          table(["", "this week", "last week", "change"], [
              ("visits", n(t.get("visits")), n(p.get("visits")), change(t.get("visits"), p.get("visits"))),
              ("unique visitors", n(t.get("visitors")), n(p.get("visitors")), change(t.get("visitors"), p.get("visitors"))),
              ("pages viewed", n(t.get("views")), n(p.get("views")), change(t.get("views"), p.get("views"))),
              ("photos opened", n(t.get("photo_opens")), n(p.get("photo_opens")), change(t.get("photo_opens"), p.get("photo_opens"))),
              ("ig clicks", n(t.get("ig_clicks")), n(p.get("ig_clicks")), change(t.get("ig_clicks"), p.get("ig_clicks"))),
              ("contact sends (enquiries)", n(t.get("contact_sends")), n(p.get("contact_sends")), change(t.get("contact_sends"), p.get("contact_sends"))),
              ("average time on a page", f"{t['avg_seconds']} s" if t.get("avg_seconds") is not None else "–", "", ""),
              ("average load time", f"{t['avg_load_ms']} ms" if t.get("avg_load_ms") is not None else "–", "", ""),
          ]), "",
          f"_Bots and crawlers left out: {n(d.get('bots_filtered'))}. Visitors are counted per day, so one person on two days counts twice._", ""]
    top = max(views7 or [0])
    L += ["**4.1 By day**", "", table(["day", "views", ""], [(f"{dd:%a %m-%d}", v, bar(v, top)) for dd, v in zip(week, views7)]), ""]
    pages = d.get("pages") or []
    top = max([x["views"] for x in pages] or [0])
    L += ["**4.2 Pages**", "",
          table(["page", "views", "visitors", "avg. time", "avg. sideways scroll", ""],
                [(x["page"], x["views"], x["visitors"], f"{x['avg_seconds']} s" if x.get("avg_seconds") is not None else "–",
                  f"{x['avg_scroll']}%" if x.get("avg_scroll") is not None else "–", bar(x["views"], top, 12)) for x in pages]) if pages else "_no data._", ""]
    ph = d.get("photos") or []
    L += ["**4.3 Most opened photos**", "", table(["photo", "opens"], [(x["photo"], x["opens"]) for x in ph]) if ph else "_no photos opened._", ""]
    src = d.get("sources") or []
    top = max([x["views"] for x in src] or [0])
    L += ["**4.4 Where visitors came from**", "",
          table(["source", "views", "visitors", ""], [(x["source"], x["views"], x["visitors"], bar(x["views"], top, 12)) for x in src]) if src else "_no data._", ""]
    camp = d.get("campaigns") or []
    if camp:
        L += [table(["campaign", "medium", "views"], [(x["campaign"], x["medium"] or "–", x["views"]) for x in camp]), ""]
    hours = d.get("hours") or {}
    if hours:
        top = max(hours.values())
        L += ["**4.5 Time of day (Eastern)**", "",
              table(["hour", "views", ""], [(f"{int(h):02d}:00", hours[h], bar(hours[h], top)) for h in sorted(hours, key=int)]), ""]
    nf = d.get("not_found") or []
    if nf:
        L += ["**4.6 Broken links (404)**", "", table(["address", "views"], [(x["path"], x["views"]) for x in nf]), ""]

    # 5. visitor access
    L += ["## 5. Visitor access", ""]
    if acc:
        L += [table(["", "count"], [("ip addresses", n(acc.get("ips"))), ("🆕 new this week", n(acc.get("new_ips"))),
                                    ("↩ returning (seen before this week)", n(acc.get("returning_ips"))),
                                    ("with a known country and network", n(acc.get("located_ips")))]), ""]
        vis = acc.get("visitors") or []
        if vis:
            L += ["**5.1 Each visitor by ip address** (top 25 by pages viewed; the visitor code stays the same week to week, "
                  "the last part of each ip address is hidden because this report is shared by link)", "",
                  table(["visitor", "ip address", "new / returning", "country", "network", "first seen", "last seen", "days", "pages",
                         "came in on", "from", "device", "time on site", "photos", "ig", "enquiry"],
                        [(x.get("vid", "")[:6] or "–", ipf(x["ip"]), "↩ returning" if x.get("returning") else "🆕 new", x.get("country") or "–", x.get("network") or "–",
                          when(x.get("first_seen")), when(x.get("last_seen")), x.get("days"), x.get("views"), x.get("entry_page") or "–",
                          x.get("source") or "–", f"{x.get('device', '–')} · {x.get('browser', '–')} · {x.get('os', '–')}",
                          f"{x.get('seconds', 0)} s", x.get("photo_opens", 0), x.get("ig_clicks", 0), "✉" if x.get("contact_sends") else "–")
                         for x in vis]), ""]
            L += ["**5.2 Pages seen by each visitor**", "",
                  table(["visitor", "ip address", "pages"], [(x.get("vid", "")[:6] or "–", ipf(x["ip"]), " → ".join(x.get("pages") or [])) for x in vis]), ""]
        L += ["**5.3 Countries**", "", shares(acc.get("countries"), "country"), "",
              "**5.4 Networks**", "", shares(acc.get("networks"), "network"), ""]
        bots = acc.get("bots") or []
        if bots:
            L += ["**5.5 Bots and crawlers by ip address**", "",
                  table(["ip address", "network", "hits"], [(ipf(b["ip"]), b.get("network") or "–", b["hits"]) for b in bots]), ""]
    else:
        L += ["_ip addresses are not logged yet (this starts once analytics/ip.sql and the new hit function are live)._", ""]
    L += ["**5.6 Visitor metadata**", "", shares(d.get("device"), "device"), "", shares(d.get("browser"), "browser"), "",
          shares(d.get("os"), "system"), "", shares(d.get("language"), "language"), "",
          shares(d.get("timezone"), "time zone"), "", shares(d.get("screens"), "screen"), ""]

    # 6. cookies register
    L += ["## 6. Cookies and browser storage register", "", storage_text, ""]

    # 7. SEO, 8. competition, 9. about
    L += ["## 7. SEO", "", "Checked from the site files on `main` at the time of the run.", "", seo_text, "",
          "Google search clicks, impressions and positions appear here once Google Search Console is set up for claire-tian.com.", ""]
    L += ["## 8. Competition", "", pathlib.Path(a.competition).read_text().strip(), ""]
    L += ["## 9. About this data", "",
          "- Counted by the site's own visitor log (stats.js). No cookies. The visitor's ip address is kept with each record "
          "and deleted after 400 days, like the rest of the log; country and network come from the ip address (ipinfo.io). "
          "This report shows ip addresses without their last part.",
          "- A daily code still counts unique visitors per day; \"returning\" means the ip address was seen before this week "
          "(shared or changing addresses, such as phones and offices, can over- or under-count).",
          "- Browsers that send a Global Privacy Control signal are not counted. Logan's and Claire's browsers are left out once they visit any page with ?notrack.",
          "- Visitor metadata is also logged to the Jarvis ML system each week, with each ip address replaced by a one-way code.",
          "", "_Written automatically by the weekly Claude task._"]
    pathlib.Path(a.out).write_text("\n".join(L) + "\n", encoding="utf-8")


if __name__ == "__main__":
    main()
