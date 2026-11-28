#!/bin/bash
# Builds "Claire Tian CRM.app" (one app for Apple silicon and Intel Macs) and zips it.
# Runs on GitHub's Mac machines (.github/workflows/mac-app.yml), or on any Mac with the Xcode command line tools:
#   cd mac && ./build.sh            ->  mac/dist/Claire-Tian-CRM-mac.zip
# The app is signed "ad hoc" (no Apple developer account), so the first open needs the steps in mac/README.md.
set -euo pipefail
cd "$(dirname "$0")"
VERSION="${VERSION:-1.0.0}"
BUILD="${BUILD:-$(date +%Y%m%d%H%M)}"
APP="dist/Claire Tian CRM.app"

swift build -c release --arch arm64 --arch x86_64
BIN="$(swift build -c release --arch arm64 --arch x86_64 --show-bin-path)/ClaireTianCRM"

rm -rf dist && mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources/web"
cp "$BIN" "$APP/Contents/MacOS/ClaireTianCRM"
sed -e "s/VERSION/$VERSION/" -e "s/BUILD/$BUILD/" Info.plist > "$APP/Contents/Info.plist"
# the crm screen: the same files the website serves
cp ../crm.html ../crm.css ../crm.js ../auth.js "$APP/Contents/Resources/web/"

# icon, from icon.png (1024 x 1024)
if [ -f icon.png ]; then
  IS=dist/AppIcon.iconset; mkdir -p "$IS"
  for s in 16 32 128 256 512; do
    sips -z $s $s icon.png --out "$IS/icon_${s}x${s}.png" >/dev/null
    sips -z $((s*2)) $((s*2)) icon.png --out "$IS/icon_${s}x${s}@2x.png" >/dev/null
  done
  iconutil -c icns "$IS" -o "$APP/Contents/Resources/AppIcon.icns" && rm -rf "$IS"
fi

codesign --force --deep --sign - "$APP"
codesign --verify --verbose "$APP"
lipo -info "$APP/Contents/MacOS/ClaireTianCRM"
(cd dist && ditto -c -k --sequesterRsrc --keepParent "Claire Tian CRM.app" "Claire-Tian-CRM-mac.zip")
echo "built mac/dist/Claire-Tian-CRM-mac.zip ($VERSION, $BUILD)"
