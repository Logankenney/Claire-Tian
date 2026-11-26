# Claire-Tian closeout package (the hand off package)

Made on 2026-11-25 when the project was resolved, with `main` at `45c71dd` (Rev 26, PR #27). The logs cover everything up to that point; the pull request that added this folder is Rev 27 (PR #28), and the project story PDF and the Linux and macOS scripts were added after it as Rev 28. Neither changes a page of the site. The site stays live at https://www.claire-tian.com; nothing here changes it, and nothing has been moved.

## What is in this folder

| File | What it is |
|---|---|
| [PROJECT_STORY.pdf](PROJECT_STORY.pdf) | The presentation: 42 pages from conception to current state, pairing Logan's prompts with Claude's responses, the actions taken and the decisions made. |
| [HISTORY_LOG.md](HISTORY_LOG.md) | The project from first message to closeout: plan, DNS and hosting, redesign, photos, layout rounds, photo pages, and what is still open. |
| [ACTION_LOG.md](ACTION_LOG.md) | What was done, when, and by whom (Logan or which Claude thread). |
| [EDIT_LOG.md](EDIT_LOG.md) | Every site edit, Rev 0 to Rev 26, with its pull request, commits, files and Jarvis Document Control filing. |
| [PR_LOG.md](PR_LOG.md) | All 27 pull requests: number, title, state, opened, merged, revision, branch, size and link. |
| [COMPILED_TEXT.md](COMPILED_TEXT.md) | Every text file of the site in one document, plus the first starter page. The project had no PDF files when it was compiled; the project story above is the only one. |
| [FILE_MANIFEST.md](FILE_MANIFEST.md) | Every file in the repository and in the project's shared folder, with size and SHA-256. |
| [claire-tian-closeout.bat](claire-tian-closeout.bat) | Windows: batch file that builds a zip archive ready for a repository move. |
| [claire-tian-closeout.sh](claire-tian-closeout.sh) | Linux: the same archive, as a shell script. |
| [claire-tian-closeout.command](claire-tian-closeout.command) | macOS: the same script, named so Finder runs it on a double-click. |

## Two versions of the hand off package

The package comes in two versions with the same contents and different tools:

- **Windows and Linux**: `claire-tian-closeout.bat` for Windows and `claire-tian-closeout.sh` for Linux.
- **macOS**: `claire-tian-closeout.command`.

A ready-made zip of each is in the Claude project's shared folder under `closeout/`. Every script makes the same archive, described below.

## Making the archive on Windows

1. Install [Git for Windows](https://git-scm.com/download/win) if it is not already installed.
2. Download `claire-tian-closeout.bat` and put it in an empty folder, for example `Documents\claire-tian-archive`.
3. Optional: to include the Claude project's shared folder (the starter page and the review screenshots), put a copy of it next to the batch file in a folder named `project-files`.
4. Double-click the batch file.

It creates `claire-tian-closeout-<date>-<time>.zip` in the same folder, and leaves the unzipped folder beside it. Inside:

- `claire-tian-full-history.bundle`: the whole repository in one file, every commit, branch and tag. The batch file verifies it.
- `repo-mirror.git\`: the same as a bare mirror clone, ready to push to a new home.
- `site-files\`: the site as it stands on `main`.
- `logs\`: the documents in this folder.
- `GIT_LOG.txt`, `GIT_REFS.txt`, `FILE_MANIFEST.txt` and `MOVE_README.txt`.

The batch file only reads from GitHub. It does not push, transfer or delete anything. To archive from another address, run `claire-tian-closeout.bat <repository URL>`.

## Making the archive on Linux

1. Install git if it is missing, for example `sudo apt install git`. Install `zip` too if you want a `.zip`; without it the script makes a `.tar.gz`.
2. Put `claire-tian-closeout.sh` in an empty folder. Optional: put a copy of the shared folder beside it as `project-files`.
3. Run `bash claire-tian-closeout.sh`.

## Making the archive on macOS

1. Put `claire-tian-closeout.command` in an empty folder, for example `Documents/claire-tian-archive`. Optional: put a copy of the shared folder beside it as `project-files`.
2. Double-click it. The first time, macOS may refuse because the file was downloaded: right-click (or Control-click) the file, choose Open, then Open again. If it still will not start, open Terminal, type `bash ` with a space after it, drag the file into the window and press Return.
3. If macOS says git is missing, run `xcode-select --install` in Terminal, follow the prompt, and run the file again.

The Linux and macOS scripts are one script. It was run end to end on Linux. It has not been run on a Mac, and the batch file has not been run on Windows.

## Moving the repository later

Two ways, both written out step by step in the `MOVE_README.txt` the batch file makes:

- **Transfer** (GitHub > Settings > General > Danger Zone > Transfer ownership). Keeps the pull requests, issues and settings, and GitHub redirects the old address.
- **Push a copy** to a new empty repository (`git -C repo-mirror.git push NEW_URL --all`, then the same with `--tags`). Keeps all history, but not the pull requests; `PR_LOG.md` is the record of them.

After either one, put the site back online in the new repository: Settings > Pages > Deploy from a branch, `main`, `/ (root)`; custom domain `www.claire-tian.com`; then Enforce HTTPS. A custom domain can sit on one repository at a time, so remove it from the old one first. If the owner changes, the `www` CNAME at GoDaddy must point to `NEWOWNER.github.io`; the four `A` records stay as they are.

## Where the other records are

- **Jarvis Document Control**, folder `projects/Claire-Tian`: the full site files for every revision, Rev 0 to Rev 26, and this package (Rev 27 and Rev 28).
- **Jarvis Document Control**, `projects/Claire-Tian/Ai Social/Instagram`: "Claire's Posts", 42 images and 5 reel videos.
- **Claude project shared folder**: `site-starter/`, `site-preview/` (review screenshots, rounds v2 to v24) and `closeout/` (a copy of this package and the two ready-made hand off zips).
