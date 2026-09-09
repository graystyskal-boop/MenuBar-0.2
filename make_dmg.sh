#!/bin/bash
set -euo pipefail

APP_NAME="MenuBarAssistant"
BUNDLE_ID="com.yourname.menubarassistant"
BUILD_DIR=".build/release"
APP_DIR="dist/${APP_NAME}.app"
DMG_PATH="dist/${APP_NAME}.dmg"

echo "==> Cleaning previous build"
rm -rf dist
mkdir -p dist

echo "==> Building release binary"
swift build -c release

echo "==> Creating .app bundle structure"
mkdir -p "${APP_DIR}/Contents/MacOS"
mkdir -p "${APP_DIR}/Contents/Resources"

cp "${BUILD_DIR}/${APP_NAME}" "${APP_DIR}/Contents/MacOS/${APP_NAME}"

cat > "${APP_DIR}/Contents/Info.plist" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleName</key>
    <string>${APP_NAME}</string>
    <key>CFBundleDisplayName</key>
    <string>${APP_NAME}</string>
    <key>CFBundleIdentifier</key>
    <string>${BUNDLE_ID}</string>
    <key>CFBundleVersion</key>
    <string>1.0</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleExecutable</key>
    <string>${APP_NAME}</string>
    <key>LSUIElement</key>
    <true/>
    <key>NSAppleEventsUsageDescription</key>
    <string>Used to register your custom global keyboard shortcut.</string>
    <key>LSMinimumSystemVersion</key>
    <string>13.0</string>
</dict>
</plist>
PLIST

echo "==> Ad-hoc signing (lets it run locally; not notarized)"
codesign --force --deep --sign - "${APP_DIR}"

echo "==> Building DMG"
STAGING_DIR="dist/dmg-staging"
mkdir -p "${STAGING_DIR}"
cp -R "${APP_DIR}" "${STAGING_DIR}/"
ln -s /Applications "${STAGING_DIR}/Applications"

hdiutil create -volname "${APP_NAME}" \
    -srcfolder "${STAGING_DIR}" \
    -ov -format UDZO \
    "${DMG_PATH}"

rm -rf "${STAGING_DIR}"

echo "==> Done: ${DMG_PATH}"
