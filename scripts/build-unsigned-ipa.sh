#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."
project_root="$PWD"
build_dir="$(mktemp -d "$project_root/build-work.XXXXXX")"
mkdir -p "$project_root/build/ipa"

# Fail early if Git LFS left pointer files in place of the static libraries.
for library in Libraries/libiPhone-lib.a Libraries/libil2cpp.a Libraries/baselib.a; do
  if [[ ! -s "$library" ]] || head -c 100 "$library" | grep -q 'git-lfs.github.com/spec'; then
    echo "::error::Missing Unity library: $library. Run git lfs pull."
    exit 1
  fi
done

xcodebuild build \
  -project Unity-iPhone.xcodeproj \
  -scheme Unity-iPhone \
  -configuration Release \
  -sdk iphoneos \
  -destination 'generic/platform=iOS' \
  -derivedDataPath "$build_dir/DerivedData" \
  -resultBundlePath "$project_root/build/Build.xcresult" \
  ARCHS=arm64 \
  ONLY_ACTIVE_ARCH=NO \
  ENABLE_BITCODE=NO \
  CODE_SIGNING_ALLOWED=NO \
  CODE_SIGNING_REQUIRED=NO \
  CODE_SIGN_IDENTITY= \
  DEVELOPMENT_TEAM= \
  PROVISIONING_PROFILE_SPECIFIER= \
  2>&1 | tee "$project_root/build/xcodebuild.log"

products_dir="$build_dir/DerivedData/Build/Products/Release-iphoneos"
app_path=""
app_count=0
for candidate in "$products_dir"/*.app; do
  [[ -d "$candidate" ]] || continue
  app_path="$candidate"
  app_count=$((app_count + 1))
done
if [[ "$app_count" -ne 1 ]]; then
  echo "::error::Expected one iOS app; found $app_count in $products_dir."
  exit 1
fi

executable=$(/usr/libexec/PlistBuddy -c 'Print :CFBundleExecutable' "$app_path/Info.plist")
lipo "$app_path/$executable" -verify_arch arm64
if codesign -dv "$app_path" 2>/dev/null; then
  echo '::error::The app is signed; expected an unsigned build.'
  exit 1
fi

mkdir -p "$build_dir/Payload"
ditto "$app_path" "$build_dir/Payload/$(basename "$app_path")"
ipa_path="$project_root/build/ipa/${executable}-unsigned.ipa"
(
  cd "$build_dir"
  /usr/bin/zip -q -r -y "$ipa_path" Payload
)
unzip -tq "$ipa_path"
echo "IPA: $ipa_path"
if [[ -n "${GITHUB_STEP_SUMMARY:-}" ]]; then
  {
    echo '### Unsigned IPA built successfully'
    echo
    echo "- File: $(basename "$ipa_path")"
    echo '- Platform: iOS device, arm64, Release'
    echo '- Code signing: disabled (app must be signed before installation)'
    echo '- Download the IPA from this workflow run’s Artifacts section.'
  } >> "$GITHUB_STEP_SUMMARY"
fi
