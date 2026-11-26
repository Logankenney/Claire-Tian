# Claire-Tian action log

What was done, when, and by whom. Compiled on 2026-11-25 from the project chat, git history, the pull request list and the Jarvis Action Log. All times are UTC on 2026-11-25. Site edits are listed one by one in `EDIT_LOG.md`; this log covers the actions around them.

## Who is who

| Name in this log | What it is |
|---|---|
| Logan | The owner (GitHub `Logankenney`). Gave every instruction and approval. |
| Coordinator | Claude in the project chat. Routed Logan's messages to threads and reported back. |
| Site thread | Claude thread "Edit the photography site design" (first titled "Help me work out a plan for a project"). Built and edited the site, opened and merged the site PRs, filed the revisions. Worked in the cloud. |
| Jarvis/photos thread | Claude thread "Add Instagram photos to the site" (started as "Register site project in Jarvis Main"). Ran on Logan's computer, Comp1. |
| DNS thread | Claude thread "Set up GoDaddy DNS and email forwarding". Worked through Logan's Chrome. |
| Lessons thread | Claude thread "Add lessons learned registers". Worked in the Jarvis repository. |
| Closeout thread | Claude thread "Compile project archive for repo move". Wrote this package. |
| Copilot | GitHub Copilot, which made the repository's first commit. |

## Log

| Time | Action | By | Result or reference |
|---|---|---|---|
| 07:08 | Project opened; planning thread started | Logan, Coordinator | Site thread created |
| 07:09 to 07:14 | Requirements given: repo and public page first, domain www.claire-tian.com at GoDaddy, style after petra-collins.com with Lorde elements | Logan | Recorded in project memory |
| 07:13 | GoDaddy DNS steps written out | Coordinator | Used at 08:21 |
| 07:16 | First starter page drafted with day and night looks | Site thread | Shared folder `site-starter/` |
| 07:18 to 07:20 | Asked for the project to be logged with Jarvis and to use unified memory; allowed Claude to work on Comp1 | Logan | Jarvis/photos thread created |
| 07:25 | Repository `Logankenney/Claire-Tian` created and initialised | Logan, Copilot | Commit `d16b13f` |
| 07:33 | Claire-Tian project, folder and memory card prepared for Jarvis | Jarvis/photos thread | Jarvis PR #191 (Action Log 58k), merged 08:09 |
| 07:44 | Starter site and `CNAME` pushed; PR #1 opened | Site thread | PR #1 |
| 08:09 | Standing rule given: every merge is a revision filed with Jarvis Document Control | Logan | Jarvis PR #194 (Action Log 58l), merged 09:41 |
| 08:10 | PR #1 merged; repository public | Logan | Rev 0, filed by Jarvis PR #193 |
| 08:18 | Booking address given; asked for DNS and forwarding to be done for him | Logan | DNS thread created |
| 08:21 to 08:25 | GoDaddy DNS changed: four `A` records for `@`, `www` `CNAME` to `logankenney.github.io` | DNS thread, in Logan's Chrome | Domain points at GitHub Pages |
| 08:24 | Found no free email forwarding on the GoDaddy account; asked Logan to choose | DNS thread | Logan chose "Skip email for now" |
| 08:25 to 08:35 | Found Pages set to a workflow that does not exist; asked Logan; switched to deploy from `main` | DNS thread, Logan's approval | Pages source: `main`, `/ (root)` |
| 08:38 to 08:39 | First preview shown; Logan pins comments on it | Site thread, Logan | Shared folder `site-preview/` |
| 08:43 to 09:29 | Site restyled to the black and white, lowercase, no-scroll direction | Site thread | PR #2 |
| 09:31 to 09:36 | Deployment checked on request; Pages setting re-saved; site confirmed live over HTTPS | DNS thread, Site thread | https://www.claire-tian.com live, HTTPS enforced |
| 09:40 | Standing rule given: auto-merge all open PRs once checks pass, and auto-deploy | Logan | Applied from PR #2 onward |
| 09:41 to 09:49 | PR #2 and PR #3 merged and filed | Site thread | Rev 1, Rev 2 |
| 09:47 | Asked for all pinned ("clicked") edits to be audited | Logan | 16 of 17 live; the 17th (photos) became PR #4 |
| 09:50 to 09:52 | Asked for Jarvis screen grab to capture the Instagram photos; confirmed permission to use them | Logan | Jarvis Action Log 58z |
| 09:52 to 10:01 | Photos captured from instagram.com/maisonsumika on Comp1; 26 portrait frames added to the site | Jarvis/photos thread | PR #4, Rev 3 |
| 09:58 to 10:00 | Filing rules given: "Claire's Posts" under Ai Social > Instagram; all project documentation under "Claire-Tian" | Logan | Jarvis PR #211 |
| 10:12 to 10:23 | "Claire's Posts" filed: 42 images and 5 reel videos; Photo Repository folder created | Jarvis/photos thread | Jarvis PR #211, merged 10:20 |
| 10:15 | Stated that all faces, images and likenesses are approved and owned by Claire Tian, and that he acts on her behalf | Logan | Recorded in project memory |
| 10:17 to 10:30 | Home made static; work page given ten frames; shuffle on load; style links versioned | Site thread | PRs #5 to #7, Rev 4 to 6 |
| 10:50 | Photo rule given: no posed portraits of people. Asked for lessons learned registers in Jarvis | Logan | Lessons thread created |
| 10:51 | Posed wedding portrait removed from the site; rule written into `photos/README.md` | Site thread | PR #8, Rev 7 |
| 10:51 to 13:40 | Lessons learned register, Lessons Learned folder, "keep all lessons" and the chief of staff override rule built in Jarvis | Lessons thread | Jarvis PRs #221, #232, #237 (Action Log 59j, 59f, 59g, 59m, 59n) |
| 12:00 to 12:07 | Home images enlarged and centred; contact trimmed to the idea box | Site thread | PRs #9, #10, Rev 8, 9 |
| 12:14 to 13:01 | Work paused on a usage limit, then resumed at Logan's word | Coordinator | No change to the site |
| 12:16 to 12:57 | Recent shots relaid; photos converted to WebP with a saved list; work page removed; photo dump named; name enlarged | Site thread | PRs #11 to #14, Rev 10 to 13 |
| 13:03 to 13:05 | Full check requested and run: no vertical scrolling at any size, images load and shuffle, send works, no broken links, deploys clean; one unmerged Jarvis filing (Rev 13) fixed | Logan, Site thread | Passed; email forwarding noted as the one gap |
| 13:06 | Told Claude to ignore the missing forwarding for now | Logan | Not raised again |
| 13:07 to 13:29 | Photo dump copy and strip, contact alignment, line break, shared photo rules, captions | Site thread | PRs #15 to #19, Rev 14 to 18 |
| 14:02 to 14:32 | Photo dump cleared; numbers removed; colour on hover; ten photos in the strip | Site thread | PRs #20 to #23, Rev 19 to 22 |
| 14:30 to 14:36 | Photo pages built in three looks and put up for choice | Site thread | PR #24 opened, held |
| 14:41 | Colour held across the whole tile | Site thread | PR #25, Rev 23 |
| 15:40 | Photo dump line moved under the photos | Site thread | PR #26, Rev 24 |
| 22:29 to 22:38 | Look A chosen; looks B and C removed; PR #24 merged | Logan, Site thread | Rev 25, filed by Jarvis PR #253 |
| 22:44 to 22:47 | Photo pages limited to photo dump; photo shown in colour on its page | Logan, Site thread | PR #27, Rev 26, filed by Jarvis PR #254 |
| 23:56 | Asked for the project to be resolved with a closeout package | Logan | Closeout thread created |
| 23:57 onward | History, action, edit and PR logs, compiled text, manifest and Windows batch written | Closeout thread | This folder |

## Notes on attribution

- Site commits are authored as "Claude". Merge commits are authored as `Logankenney`, because merges run under Logan's GitHub connection. PR #1 was merged at Logan's step from the chat instructions; from 09:40 Claude merged under his auto-merge rule.
- Jarvis Action Log letters (58k, 58l, 58z, 59f, 59g, 59j, 59m, 59n) are entries in `logs/Action_Log.md` of the private repository `Logankenney/ai-multi-agent-vm`.
- Nothing in this project was sent, posted or published outside the website itself. No social media post was made.
