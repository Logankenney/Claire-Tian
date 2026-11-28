# Claire Tian CRM for Mac

A Mac app that shows the CRM: everyone who has joined on www.claire-tian.com, their access level, stage, tags,
marketing opt-in (with the consent history), sign-ins, pages they looked at while signed in, and notes. It can export
the list, or just the opted-in emails, as a CSV. It is the same screen as https://www.claire-tian.com/crm.html, built
into a native window.

It holds no secret. It signs in as you, with a 6-digit code emailed to you, and only shows what your account may see
(staff and admin; see `crm/schema.sql`). The sign-in is kept in the Mac's Keychain. Works offline only to the extent of
showing the sign-in page: the data is always read live from Supabase.

## Getting the app (from Windows)

1. **After the pull request is merged:** open
   https://github.com/Logankenney/Claire-Tian/releases/latest/download/Claire-Tian-CRM-mac.zip
   (no sign-in needed). Before that, a test build is on the pull request: Checks > "mac app" > Summary > Artifacts.
2. Send `Claire-Tian-CRM-mac.zip` to the MacBook: AirDrop is not available from Windows, so use a USB stick,
   Google Drive, or email it to yourself. (You can also just open the link above on the MacBook.)
3. On the MacBook, double-click the zip. It unpacks to **Claire Tian CRM**. Drag it into **Applications**.

## Opening it the first time (Gatekeeper)

The app is not notarised by Apple (that needs a paid Apple Developer account, $99 a year), so macOS stops the first
open with "Apple could not verify ... is free of malware". To allow it, once:

- **macOS 15 Sequoia and later:** double-click the app, click **Done**. Open **System Settings > Privacy & Security**,
  scroll down to "Claire Tian CRM was blocked", click **Open Anyway**, then enter the Mac's password and click
  **Open Anyway** again.
- **macOS 12 to 14:** right-click (or Control-click) the app in Applications, choose **Open**, then **Open** again.

After that it opens normally. If macOS says the app "is damaged", the zip was unpacked by something other than
Finder: open Terminal and run `xattr -cr "/Applications/Claire Tian CRM.app"`, then open it again.

The first sign-in after an update may ask to use "com.claire-tian.crm" in your keychain: click **Always Allow**.

## Using it

Enter your email, then the 6 numbers from the email. Logan and Claire need **admin** access (set once in Supabase, see
`crm/README.md`); anyone else sees "no crm access". **View > Reload** (Cmd-R) refreshes; the list also refreshes when
the window comes to the front. **Export list** saves what the filters show; **export opted-in emails** saves only the
people who ticked the marketing box.

## Building it yourself (optional, on a Mac)

Install the Xcode command line tools (`xcode-select --install`), then `cd mac && ./build.sh`. The zip lands in
`mac/dist/`.

## Signing properly later

To skip the Gatekeeper step, join the Apple Developer Program, add the "Developer ID Application" certificate and an
app-specific password as GitHub secrets, and add `codesign --options runtime --sign "Developer ID Application: ..."`
plus `xcrun notarytool submit --wait` and `xcrun stapler staple` to `build.sh`.
