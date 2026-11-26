@echo off
setlocal EnableExtensions
title Claire-Tian closeout archive

rem ---------------------------------------------------------------------------
rem  Claire-Tian closeout archive
rem
rem  Double-click this file, or run it from a Command Prompt. It:
rem    1. makes a full mirror of the GitHub repository (every branch and tag),
rem    2. packs that mirror into one git bundle file and verifies it,
rem    3. exports the site files as they stand on main,
rem    4. copies the closeout logs and the project story PDF to the top,
rem    5. adds a copy of the Claude project's shared folder, if you put one
rem       next to this file in a folder named "project-files",
rem    6. writes a manifest with a SHA-256 checksum for every file,
rem    7. writes MOVE_README.txt with the steps for moving the repository,
rem    8. zips everything into claire-tian-closeout-<date>-<time>.zip.
rem
rem  It only reads from GitHub. It does not push, transfer, rename or delete
rem  anything, on GitHub or on this computer, outside the folder it creates.
rem
rem  Needs: Windows 10 or 11, and Git for Windows (https://git-scm.com).
rem  Optional: run it as   claire-tian-closeout.bat <repository URL>
rem  to archive from a different address than the one below.
rem ---------------------------------------------------------------------------

set "REPO_URL=https://github.com/Logankenney/Claire-Tian.git"
if not "%~1"=="" set "REPO_URL=%~1"
set "NAME=claire-tian"

where git >nul 2>nul
if errorlevel 1 goto :nogit

for /f "usebackq delims=" %%T in (`powershell -NoProfile -Command "Get-Date -Format yyyyMMdd-HHmmss"`) do set "STAMP=%%T"
if not defined STAMP goto :nostamp

set "HERE=%~dp0"
set "OUT=%HERE%%NAME%-closeout-%STAMP%"
set "ZIP=%HERE%%NAME%-closeout-%STAMP%.zip"

echo.
echo  Claire-Tian closeout archive
echo  Repository : %REPO_URL%
echo  Working in : %OUT%
echo.

mkdir "%OUT%" || goto :fail

echo [1/8] Mirroring the repository with its full history...
git clone --mirror "%REPO_URL%" "%OUT%\repo-mirror.git" || goto :fail

echo [2/8] Packing the history into one bundle file and verifying it...
git -C "%OUT%\repo-mirror.git" bundle create "%OUT%\%NAME%-full-history.bundle" --all || goto :fail
git -C "%OUT%\repo-mirror.git" bundle verify "%OUT%\%NAME%-full-history.bundle" || goto :fail

echo [3/8] Exporting the site files from main...
git clone --quiet --branch main "%OUT%\repo-mirror.git" "%OUT%\site-files" || goto :fail
git -C "%OUT%\repo-mirror.git" log --date=iso-strict --pretty=format:"%%h  %%ad  %%an  %%s" --all > "%OUT%\GIT_LOG.txt"
git -C "%OUT%\repo-mirror.git" for-each-ref --format="%%(refname)  %%(objectname)" > "%OUT%\GIT_REFS.txt"
rmdir /s /q "%OUT%\site-files\.git"

echo [4/8] Copying the closeout logs...
if exist "%OUT%\site-files\docs\archive\closeout\*.md" (
    mkdir "%OUT%\logs"
    copy /y "%OUT%\site-files\docs\archive\closeout\*.md" "%OUT%\logs\" >nul
    if exist "%OUT%\site-files\docs\archive\closeout\*.pdf" copy /y "%OUT%\site-files\docs\archive\closeout\*.pdf" "%OUT%\logs\" >nul
) else (
    echo       No closeout logs on main yet. Skipped.
)

echo [5/8] Looking for a project-files folder next to this file...
if exist "%HERE%project-files\" (
    robocopy "%HERE%project-files" "%OUT%\project-files" /e /njh /njs /ndl /nfl /np >nul
    echo       Added.
) else (
    echo       None found. Skipped. This is fine.
)

echo [6/8] Writing the file manifest with checksums...
powershell -NoProfile -ExecutionPolicy Bypass -Command "$root = (Resolve-Path -LiteralPath $env:OUT).Path; Get-ChildItem -LiteralPath $root -Recurse -File -Force | ForEach-Object { '{0}  {1,12}  {2}' -f (Get-FileHash -LiteralPath $_.FullName -Algorithm SHA256).Hash, $_.Length, $_.FullName.Substring($root.Length + 1) } | Set-Content -LiteralPath (Join-Path $root 'FILE_MANIFEST.txt') -Encoding UTF8" || goto :fail

echo [7/8] Writing MOVE_README.txt...
set "R=%OUT%\MOVE_README.txt"
> "%R%" echo Claire-Tian closeout archive, made %STAMP%
>>"%R%" echo Source: %REPO_URL%
>>"%R%" echo.
>>"%R%" echo WHAT IS IN HERE
>>"%R%" echo   %NAME%-full-history.bundle   the whole repository in one file: every commit, branch and tag
>>"%R%" echo   repo-mirror.git\             the same thing as a bare mirror clone, ready to push
>>"%R%" echo   site-files\                  the site exactly as it stands on main
>>"%R%" echo   logs\                        project story PDF, history, action, edit and PR logs, compiled text, manifest
>>"%R%" echo   project-files\               the Claude project shared folder, if one was supplied
>>"%R%" echo   GIT_LOG.txt, GIT_REFS.txt    every commit and every branch, as plain text
>>"%R%" echo   FILE_MANIFEST.txt            SHA-256, size and path of every file in this archive
>>"%R%" echo.
>>"%R%" echo NOTHING HAS BEEN MOVED. This archive is a copy. The steps below are for when you decide to move.
>>"%R%" echo.
>>"%R%" echo OPTION A: TRANSFER THE REPOSITORY (keeps pull requests, issues and settings)
>>"%R%" echo   1. On GitHub open the repository, then Settings, General, Danger Zone, Transfer ownership.
>>"%R%" echo   2. Enter the new owner and confirm. GitHub redirects the old address to the new one.
>>"%R%" echo   3. Go on to "AFTER EITHER OPTION".
>>"%R%" echo.
>>"%R%" echo OPTION B: PUSH A COPY TO A NEW, EMPTY REPOSITORY (keeps all history, not the pull requests)
>>"%R%" echo   1. Create a new empty repository on GitHub. Do not add a README or a licence to it.
>>"%R%" echo   2. Open a Command Prompt in this folder and run, with your new address in place of NEW_URL:
>>"%R%" echo        git -C repo-mirror.git push NEW_URL --all
>>"%R%" echo        git -C repo-mirror.git push NEW_URL --tags
>>"%R%" echo      Use these two commands and not "push --mirror": the mirror also holds GitHub's own
>>"%R%" echo      pull request refs, which a new repository refuses, and --mirror would report errors for them.
>>"%R%" echo      If repo-mirror.git is missing, rebuild it from the bundle first:
>>"%R%" echo        git clone --mirror %NAME%-full-history.bundle repo-mirror.git
>>"%R%" echo   3. The pull requests do not travel with a push. logs\PR_LOG.md is the record of them.
>>"%R%" echo.
>>"%R%" echo AFTER EITHER OPTION: PUT THE WEBSITE BACK ONLINE
>>"%R%" echo   1. In the new repository: Settings, Pages, Source "Deploy from a branch", branch main, folder / (root), Save.
>>"%R%" echo   2. On the same page set Custom domain to www.claire-tian.com and Save. The CNAME file in the
>>"%R%" echo      repository already holds this name. Only one repository on GitHub can hold a custom domain at
>>"%R%" echo      a time, so remove it from the old repository's Pages settings first.
>>"%R%" echo   3. If the new repository is under a different GitHub account or organisation, change one DNS record
>>"%R%" echo      at GoDaddy: the CNAME named www must point to NEWOWNER.github.io. The four A records for @
>>"%R%" echo      (185.199.108.153, 185.199.109.153, 185.199.110.153, 185.199.111.153) stay as they are.
>>"%R%" echo   4. Wait for the DNS check on the Pages settings page, then tick Enforce HTTPS.
>>"%R%" echo   5. Open https://www.claire-tian.com and check home, photo dump, a photo page and contact.
>>"%R%" echo   6. The repository must be public for free GitHub Pages.
>>"%R%" echo.
>>"%R%" echo TO CHECK THIS ARCHIVE LATER
>>"%R%" echo   git bundle verify %NAME%-full-history.bundle
>>"%R%" echo   git clone %NAME%-full-history.bundle check-copy

echo [8/8] Zipping...
powershell -NoProfile -ExecutionPolicy Bypass -Command "Compress-Archive -LiteralPath $env:OUT -DestinationPath $env:ZIP -CompressionLevel Optimal -Force" || goto :fail
if not exist "%ZIP%" goto :fail

echo.
echo  Done.
echo  Zip    : %ZIP%
echo  Folder : %OUT%
echo  Read MOVE_README.txt inside for the steps to move the repository.
echo  Nothing was changed on GitHub.
echo.
pause
exit /b 0

:nogit
echo.
echo  Git was not found on this computer.
echo  Install Git for Windows from https://git-scm.com/download/win and run this file again.
echo.
pause
exit /b 1

:nostamp
echo.
echo  Could not read the date from PowerShell. Nothing was created.
echo.
pause
exit /b 1

:fail
echo.
echo  A step failed, so the archive is not complete. See the message above.
echo  If the repository is private, sign in to GitHub when Git asks, then run this file again.
echo  Any partial folder is at: %OUT%
echo.
pause
exit /b 1
