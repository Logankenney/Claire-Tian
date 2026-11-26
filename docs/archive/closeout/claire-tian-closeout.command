#!/bin/bash
# ---------------------------------------------------------------------------
#  Claire-Tian closeout archive, for Linux and macOS
#
#  Linux:  bash claire-tian-closeout.sh
#  macOS:  double-click claire-tian-closeout.command (the same script), or
#          run   bash claire-tian-closeout.command   in Terminal.
#
#  It:
#    1. makes a full mirror of the GitHub repository (every branch and tag),
#    2. packs that mirror into one git bundle file and verifies it,
#    3. exports the site files as they stand on main,
#    4. copies the closeout logs and the project story PDF to the top,
#    5. adds a copy of the Claude project's shared folder, if you put one
#       next to this file in a folder named "project-files",
#    6. writes a manifest with a SHA-256 checksum for every file,
#    7. writes MOVE_README.txt with the steps for moving the repository,
#    8. zips everything into claire-tian-closeout-<date>-<time>.zip.
#
#  It only reads from GitHub. It does not push, transfer, rename or delete
#  anything, on GitHub or on this computer, outside the folder it creates.
#
#  Needs: git. Optional: pass a repository URL as the first argument to
#  archive from a different address than the one below.
# ---------------------------------------------------------------------------

REPO_URL="${1:-https://github.com/Logankenney/Claire-Tian.git}"
NAME="claire-tian"
HERE="$(cd "$(dirname "$0")" && pwd)"
OS="$(uname -s)"

pause() { if [ -t 0 ]; then printf ' Press Return to close. '; read -r _; fi; }
fail() {
  echo
  echo " A step failed, so the archive is not complete. See the message above."
  echo " If the repository is private, sign in to GitHub when git asks, then run this again."
  [ -n "${OUT:-}" ] && echo " Any partial folder is at: $OUT"
  echo
  pause
  exit 1
}

if ! git --version >/dev/null 2>&1; then
  echo
  echo " Git was not found on this computer."
  if [ "$OS" = "Darwin" ]; then
    echo " Open Terminal, run   xcode-select --install   and follow the prompt, then run this again."
  else
    echo " Install it with your package manager, for example   sudo apt install git   then run this again."
  fi
  echo
  pause
  exit 1
fi

if [ "$OS" = "Darwin" ]; then SHELL_NAME="Terminal"; else SHELL_NAME="a terminal"; fi
STAMP="$(date +%Y%m%d-%H%M%S)"
OUT="$HERE/$NAME-closeout-$STAMP"
ZIP="$OUT.zip"

echo
echo " Claire-Tian closeout archive"
echo " Repository : $REPO_URL"
echo " Working in : $OUT"
echo

mkdir "$OUT" || fail

echo "[1/8] Mirroring the repository with its full history..."
git clone --mirror "$REPO_URL" "$OUT/repo-mirror.git" || fail

echo "[2/8] Packing the history into one bundle file and verifying it..."
git -C "$OUT/repo-mirror.git" bundle create "$OUT/$NAME-full-history.bundle" --all || fail
git -C "$OUT/repo-mirror.git" bundle verify -q "$OUT/$NAME-full-history.bundle" || fail

echo "[3/8] Exporting the site files from main..."
mkdir "$OUT/site-files" || fail
git -C "$OUT/repo-mirror.git" archive main | tar -x -C "$OUT/site-files" || fail
git -C "$OUT/repo-mirror.git" log --date=iso-strict --pretty=format:"%h  %ad  %an  %s" --all > "$OUT/GIT_LOG.txt"
git -C "$OUT/repo-mirror.git" for-each-ref --format="%(refname)  %(objectname)" > "$OUT/GIT_REFS.txt"

echo "[4/8] Copying the closeout logs and the project story..."
if [ -d "$OUT/site-files/docs/archive/closeout" ]; then
  mkdir "$OUT/logs" || fail
  cp "$OUT/site-files/docs/archive/closeout/"*.md "$OUT/logs/" 2>/dev/null
  cp "$OUT/site-files/docs/archive/closeout/"*.pdf "$OUT/logs/" 2>/dev/null
else
  echo "      No closeout logs on main yet. Skipped."
fi

echo "[5/8] Looking for a project-files folder next to this file..."
if [ -d "$HERE/project-files" ]; then
  cp -R "$HERE/project-files" "$OUT/project-files" || fail
  echo "      Added."
else
  echo "      None found. Skipped. This is fine."
fi

echo "[6/8] Writing MOVE_README.txt..."
cat > "$OUT/MOVE_README.txt" <<README
Claire-Tian closeout archive, made $STAMP
Source: $REPO_URL

WHAT IS IN HERE
  $NAME-full-history.bundle   the whole repository in one file: every commit, branch and tag
  repo-mirror.git/                  the same thing as a bare mirror clone, ready to push
  site-files/                       the site exactly as it stands on main
  logs/                             the project story PDF, the history, action, edit and PR logs,
                                    the compiled text and the manifest
  project-files/                    the Claude project shared folder, if one was supplied
  GIT_LOG.txt, GIT_REFS.txt         every commit and every branch, as plain text
  FILE_MANIFEST.txt                 SHA-256, size and path of every file in this archive

NOTHING HAS BEEN MOVED. This archive is a copy. The steps below are for when you decide to move.

OPTION A: TRANSFER THE REPOSITORY (keeps pull requests, issues and settings)
  1. On GitHub open the repository, then Settings, General, Danger Zone, Transfer ownership.
  2. Enter the new owner and confirm. GitHub redirects the old address to the new one.
  3. Go on to "AFTER EITHER OPTION".

OPTION B: PUSH A COPY TO A NEW, EMPTY REPOSITORY (keeps all history, not the pull requests)
  1. Create a new empty repository on GitHub. Do not add a README or a licence to it.
  2. Open $SHELL_NAME in this folder and run, with your new address in place of NEW_URL:
       git -C repo-mirror.git push NEW_URL --all
       git -C repo-mirror.git push NEW_URL --tags
     Use these two commands and not "push --mirror": the mirror also holds GitHub's own
     pull request refs, which a new repository refuses, and --mirror would report errors for them.
     If repo-mirror.git is missing, rebuild it from the bundle first:
       git clone --mirror $NAME-full-history.bundle repo-mirror.git
  3. The pull requests do not travel with a push. logs/PR_LOG.md is the record of them.

AFTER EITHER OPTION: PUT THE WEBSITE BACK ONLINE
  1. In the new repository: Settings, Pages, Source "Deploy from a branch", branch main, folder / (root), Save.
  2. On the same page set Custom domain to www.claire-tian.com and Save. The CNAME file in the
     repository already holds this name. Only one repository on GitHub can hold a custom domain at
     a time, so remove it from the old repository's Pages settings first.
  3. If the new repository is under a different GitHub account or organisation, change one DNS record
     at GoDaddy: the CNAME named www must point to NEWOWNER.github.io. The four A records for @
     (185.199.108.153, 185.199.109.153, 185.199.110.153, 185.199.111.153) stay as they are.
  4. Wait for the DNS check on the Pages settings page, then tick Enforce HTTPS.
  5. Open https://www.claire-tian.com and check home, photo dump, a photo page and contact.
  6. The repository must be public for free GitHub Pages.

TO CHECK THIS ARCHIVE LATER
  git bundle verify $NAME-full-history.bundle
  git clone $NAME-full-history.bundle check-copy
README

echo "[7/8] Writing the file manifest with checksums..."
if command -v sha256sum >/dev/null 2>&1; then
  sum() { sha256sum "$1" | cut -d' ' -f1; }
else
  sum() { shasum -a 256 "$1" | cut -d' ' -f1; }
fi
(
  cd "$OUT" || exit 1
  find . -type f ! -name FILE_MANIFEST.txt | LC_ALL=C sort | while IFS= read -r f; do
    printf '%s  %12s  %s\n' "$(sum "$f")" "$(wc -c < "$f" | tr -d ' ')" "${f#./}"
  done > FILE_MANIFEST.txt
) || fail

echo "[8/8] Zipping..."
if command -v zip >/dev/null 2>&1; then
  ( cd "$HERE" && COPYFILE_DISABLE=1 zip -q -r -X "$ZIP" "$(basename "$OUT")" ) || fail
elif [ "$OS" = "Darwin" ]; then
  ditto -c -k --norsrc --keepParent "$OUT" "$ZIP" || fail
else
  ZIP="$OUT.tar.gz"
  tar -czf "$ZIP" -C "$HERE" "$(basename "$OUT")" || fail
  echo "      zip is not installed, so a .tar.gz was made instead."
fi
[ -f "$ZIP" ] || fail

echo
echo " Done."
echo " Archive : $ZIP"
echo " Folder  : $OUT"
echo " Read MOVE_README.txt inside for the steps to move the repository."
echo " Nothing was changed on GitHub."
echo
pause
exit 0
