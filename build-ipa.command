#!/bin/bash

set -Eeuo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"
BUILD_ROOT="$(mktemp -d "${TMPDIR:-/tmp}/mafia-ipa.XXXXXX")"
STAMP="$(date +%Y%m%d-%H%M%S)"
DOWNLOADS="$HOME/Downloads"
IPA="$DOWNLOADS/Mafia-unsigned-$STAMP.ipa"
APP="$BUILD_ROOT/DerivedData/Build/Products/Release-iphoneos/Mafia.app"

cleanup() {
  rm -rf "$BUILD_ROOT"
}

fail() {
  printf '\nОшибка: %s\n' "$1" >&2
  exit 1
}

trap cleanup EXIT
trap 'fail "сборка остановлена на строке $LINENO"' ERR

command -v xcodebuild >/dev/null || fail "xcodebuild не найден. Установи полный Xcode."
command -v zip >/dev/null || fail "zip не найден."
command -v unzip >/dev/null || fail "unzip не найден."
test -d "$ROOT/Mafia.xcodeproj" || fail "Mafia.xcodeproj не найден рядом со скриптом."

mkdir -p "$DOWNLOADS"

printf 'Собираю неподписанное приложение для физического iPhone...\n\n'

xcodebuild \
  -project "$ROOT/Mafia.xcodeproj" \
  -scheme Mafia \
  -configuration Release \
  -sdk iphoneos \
  -destination "generic/platform=iOS" \
  -derivedDataPath "$BUILD_ROOT/DerivedData" \
  CODE_SIGNING_ALLOWED=NO \
  CODE_SIGNING_REQUIRED=NO \
  CODE_SIGN_IDENTITY="" \
  COMPILER_INDEX_STORE_ENABLE=NO \
  build

test -d "$APP" || fail "Xcode не создал Mafia.app."
test -f "$APP/Info.plist" || fail "в Mafia.app отсутствует Info.plist."

EXECUTABLE_NAME="$(/usr/libexec/PlistBuddy -c 'Print :CFBundleExecutable' "$APP/Info.plist")"
EXECUTABLE="$APP/$EXECUTABLE_NAME"

test -n "$EXECUTABLE_NAME" || fail "CFBundleExecutable не указан в Info.plist."
test -f "$EXECUTABLE" || fail "в Mafia.app отсутствует исполняемый файл $EXECUTABLE_NAME."
test -x "$EXECUTABLE" || fail "исполняемый файл $EXECUTABLE_NAME не имеет права запуска."
file "$EXECUTABLE" | grep -q 'Mach-O' || fail "$EXECUTABLE_NAME не является Mach-O файлом."
lipo -archs "$EXECUTABLE" | grep -qw arm64 || fail "$EXECUTABLE_NAME собран не для arm64."

rm -rf "$APP/_CodeSignature"
xattr -cr "$APP" 2>/dev/null || true

mkdir -p "$BUILD_ROOT/package/Payload"
ditto "$APP" "$BUILD_ROOT/package/Payload/Mafia.app"

(
  cd "$BUILD_ROOT/package"
  /usr/bin/zip -qry "$IPA" Payload
)

unzip -tq "$IPA" >/dev/null || fail "созданный IPA повреждён."
unzip -Z1 "$IPA" | grep -Fx "Payload/Mafia.app/Info.plist" >/dev/null ||
  fail "в IPA отсутствует Info.plist."
unzip -Z1 "$IPA" | grep -Fx "Payload/Mafia.app/$EXECUTABLE_NAME" >/dev/null ||
  fail "в IPA отсутствует исполняемый файл $EXECUTABLE_NAME."

printf '\nIPA успешно создан:\n%s\n' "$IPA"
ls -lh "$IPA"
open -R "$IPA"
