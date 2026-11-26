#!/usr/bin/env python3
"""Write the Friday site report for www.claire-tian.com as Markdown.

    python3 tools/weekly_report.py --data week.json --competition comp.md --out report.md [--notes notes.md]

--data         the JSON from Supabase: select public.weekly_report_data('YYYY-MM-DD');  (the Friday of issue)
--competition  this week's competition section (Markdown), written by the weekly run from its web searches
--notes        optional: the run's short commentary and actions, put under the headline
The SEO section is checked here from the site files in this repository (titles, descriptions, canonical,
social previews, structured data, robots.txt, sitemap.xml, alt text). Standard library only.
"""
import argparse, json, re, pathlib, datetime

ROOT = pathlib.Path(__file__).resolve().parent.parent
PAGES = [("home", "index.html"), ("photo dump", "recent.html"), ("photo", "photo.html"),
         ("contact", "contact.html"), ("privacy", "privacy.html"), ("404", "404.html")]


def n(x):
    return "–" if x is None else f"{x:,}" if isinstance(x, int) else str(x)


def change(now, before):
    if now is None or before is None:
        return "–"
    if before == 0:
        return "new" if now else "–"
    pct = round(100 * (now - before) / before)
    return f"{pct:+d}%"


def bar(value, top, width=20):
    return "█" * max(1 if value else 0, round(width * value / top)) if top else ""


def table(head, rows):
    out = ["| " + " | ".join(head) + " |", "|" + "---|" * len(head)]
    out += ["| " + " | ".join(str(c) for c in r) + " |" for r in rows]
    return "\n".join(out)


def shares(d, label):
    if not d:
        return f"_{label}: no data._"
    total = sum(d.values())
    rows = sorted(d.items(), key=lambda kv: -kv[1])
    return table([label, "visitors", "share"], [(k, v, f"{round(100 * v / total)}%") for k, v in rows])


def seo_checks():
    rows, site = [], []
    for name, f in PAGES:
        p = ROOT / f
        if not p.exists():
            continue
        h = p.read_text(encoding="utf-8")
        title = re.search(r"<title>(.*?)</title>", h, re.S)
        desc = re.search(r'<meta name="description" content="([^"]*)"', h)
        dl = len(desc.group(1)) if desc else 0
        rows.append((name,
                     title.group(1) if title else "❌ none",
                     ("✅ " if 120 <= dl <= 160 else "⚠ " if dl else "❌ ") + (f"{dl} chars" if dl else "none"),
                     "✅" if 'rel="canonical"' in h else "❌",
                     "✅" if 'property="og:image"' in h else "❌",
                     "✅" if "application/ld+json" in h else "–" if name != "home" else "❌",
                     "✅" if "noindex" in h else "–" if name != "404" else "❌ indexable"))
    robots = (ROOT / "robots.txt").exists()
    sitemap = ROOT / "sitemap.xml"
    site.append(("robots.txt", "✅ present" if robots else "❌ missing"))
    if sitemap.exists():
        site.append(("sitemap.xml", f"✅ {sitemap.read_text().count('<loc>')} addresses"))
    else:
        site.append(("sitemap.xml", "❌ missing"))
    details = ROOT / "photos" / "details.json"
    photos = json.loads((ROOT / "photos.json").read_text())
    count = len(photos) if isinstance(photos, list) else sum(len(v) for v in photos.values())
    site.append(("photos on the site", str(count)))
    site.append(("photo details file", "✅ present" if details.exists() else "❌ missing"))
    return (table(["page", "title", "description", "canonical", "preview image", "structured data", "404 noindex"], rows)
            + "\n\n" + table(["site-wide", "status"], site))


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--data", required=True)
    ap.add_argument("--competition", required=True)
    ap.add_argument("--notes")
    ap.add_argument("--out", required=True)
    a = ap.parse_args()
    d = json.loads(pathlib.Path(a.data).read_text())
    t, p = d.get("totals", {}), d.get("previous", {})
    issue = datetime.date.fromisoformat(d["issue"])
    has_data = bool(t.get("views"))

    L = [f"# claire tian · weekly site report",
         "",
         f"**Week:** {d['week_start']} to {d['week_end']} (Eastern) · **Issued:** {issue:%a %Y-%m-%d}, 8:00 AM ET",
         "**Site:** https://www.claire-tian.com · **Filed:** Jarvis Document Control › projects/Claire-Tian/Weekly Reports",
         ""]
    if a.notes:
        L += [pathlib.Path(a.notes).read_text().strip(), ""]
    if not has_data:
        L += ["> **No visits were recorded this week.** "
              + ("The visitor log has no records yet." if not d.get("first_hit") else "Logging is on; nobody visited, or every visit came from a bot.") , ""]

    L += ["## 1. Headline", "",
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

    L += ["## 2. Full metrics", "", "**2.1 By day**", ""]
    days = d.get("by_day") or []
    top = max([x["views"] for x in days] or [0])
    L += [table(["day", "views", "visitors", ""], [(x["day"], x["views"], x["visitors"], bar(x["views"], top)) for x in days]) if days else "_no data._", ""]
    L += ["**2.2 Pages**", ""]
    pages = d.get("pages") or []
    L += [table(["page", "views", "visitors", "avg. time", "avg. sideways scroll"],
                [(x["page"], x["views"], x["visitors"], f"{x['avg_seconds']} s" if x.get("avg_seconds") is not None else "–",
                  f"{x['avg_scroll']}%" if x.get("avg_scroll") is not None else "–") for x in pages]) if pages else "_no data._", ""]
    L += ["**2.3 Most opened photos**", ""]
    ph = d.get("photos") or []
    L += [table(["photo", "opens"], [(x["photo"], x["opens"]) for x in ph]) if ph else "_no photos opened._", ""]
    L += ["**2.4 Where visitors came from**", ""]
    src = d.get("sources") or []
    L += [table(["source", "views", "visitors"], [(x["source"], x["views"], x["visitors"]) for x in src]) if src else "_no data._", ""]
    camp = d.get("campaigns") or []
    if camp:
        L += ["", table(["campaign", "medium", "views"], [(x["campaign"], x["medium"] or "–", x["views"]) for x in camp]), ""]
    L += ["**2.5 Visitor metadata**", "", shares(d.get("device"), "device"), "", shares(d.get("browser"), "browser"), "",
          shares(d.get("os"), "system"), "", shares(d.get("language"), "language"), "",
          shares(d.get("timezone"), "time zone (approximate region)"), "", shares(d.get("screens"), "screen"), ""]
    hours = d.get("hours") or {}
    if hours:
        top = max(hours.values())
        L += ["**2.6 Time of day (Eastern)**", "",
              table(["hour", "views", ""], [(f"{int(h):02d}:00", hours[h], bar(hours[h], top)) for h in sorted(hours, key=int)]), ""]
    nf = d.get("not_found") or []
    if nf:
        L += ["**2.7 Broken links (404)**", "", table(["address", "views"], [(x["path"], x["views"]) for x in nf]), ""]

    L += ["## 3. SEO", "", f"Checked from the site files on `main` at the time of the run.", "", seo_checks(), "",
          "Google search clicks, impressions and positions appear here once Google Search Console is set up for claire-tian.com.", ""]
    L += ["## 4. Competition", "", pathlib.Path(a.competition).read_text().strip(), ""]
    L += ["## 5. About this data", "",
          "- Counted by the site's own visitor log (stats.js). No cookies, no ip addresses kept; a visitor is a code that changes every day.",
          "- Region is approximate, from the browser's time zone. Browsers that send a Global Privacy Control signal are not counted.",
          "- Logan's and Claire's browsers are left out once they visit any page with ?notrack.",
          "", "_Written automatically by the weekly Claude task._"]
    pathlib.Path(a.out).write_text("\n".join(L) + "\n", encoding="utf-8")


if __name__ == "__main__":
    main()
