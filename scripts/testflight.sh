#!/usr/bin/env bash
#
# Dựng IPA phát hành rồi nộp lên TestFlight.
#
# Chỉ dùng công cụ có sẵn của Xcode (xcrun altool) nên KHÔNG cần cài
# fastlane hay Ruby gem nào.
#
#   ./scripts/testflight.sh              # build number = lấy từ pubspec.yaml
#   ./scripts/testflight.sh 7            # build number = 7
#   BUILD_ONLY=1 ./scripts/testflight.sh # chỉ dựng IPA, không upload
#
# Yêu cầu 3 biến môi trường (App Store Connect API key, xem docs/TESTFLIGHT.md):
#   ASC_KEY_ID      Key ID, vd 2X9ABC3DEF
#   ASC_ISSUER_ID   Issuer ID dạng UUID
#   ASC_KEY_PATH    Đường dẫn file AuthKey_<KeyID>.p8
#
set -euo pipefail

cd "$(dirname "$0")/.."

readonly EXPORT_OPTIONS="ios/ExportOptions.plist"
readonly IPA_DIR="build/ios/ipa"

fail() {
  echo ""
  echo "❌ $1" >&2
  echo ""
  exit 1
}

# ==================== KIỂM TRA ĐIỀU KIỆN ====================

bundle_id=$(grep -m1 'PRODUCT_BUNDLE_IDENTIFIER = ' ios/Runner.xcodeproj/project.pbxproj |
  sed 's/.*= \(.*\);/\1/')

if [[ "$bundle_id" == com.example.* ]]; then
  fail "Bundle ID vẫn là placeholder: $bundle_id
   Apple không cho đăng ký App ID thuộc com.example.*.
   Đổi PRODUCT_BUNDLE_IDENTIFIER sang reverse-domain thật (cả 3 chỗ:
   Debug/Profile/Release) rồi đăng ký App ID + tạo app trên App Store Connect.
   Xem docs/TESTFLIGHT.md mục 1."
fi

if ! security find-identity -v -p codesigning | grep -q "Apple Distribution"; then
  fail "Không tìm thấy chứng chỉ 'Apple Distribution' trong Keychain.
   TestFlight không nhận build ký bằng cert Apple Development.
   Xem docs/TESTFLIGHT.md mục 2."
fi

build_number="${1:-}"
if [[ -z "$build_number" ]]; then
  build_number=$(grep -m1 '^version:' pubspec.yaml | sed 's/.*+//')
fi
[[ -n "$build_number" ]] || fail "Không đọc được build number từ pubspec.yaml"

echo "▸ Bundle ID    : $bundle_id"
echo "▸ Build number : $build_number"
echo ""

# ==================== DỰNG IPA ====================

echo "▸ flutter clean && pub get"
flutter clean >/dev/null
flutter pub get >/dev/null

echo "▸ Dựng IPA phát hành (vài phút)..."
flutter build ipa \
  --release \
  --build-number="$build_number" \
  --export-options-plist="$EXPORT_OPTIONS"

ipa_path=$(find "$IPA_DIR" -name '*.ipa' -maxdepth 1 | head -1)
[[ -n "$ipa_path" ]] || fail "Không tìm thấy file .ipa trong $IPA_DIR"

echo ""
echo "✅ Đã dựng: $ipa_path"

if [[ -n "${BUILD_ONLY:-}" ]]; then
  echo "   BUILD_ONLY được bật — dừng ở đây, chưa upload."
  exit 0
fi

# ==================== NỘP LÊN TESTFLIGHT ====================

for var in ASC_KEY_ID ASC_ISSUER_ID ASC_KEY_PATH; do
  [[ -n "${!var:-}" ]] || fail "Thiếu biến môi trường $var.
   Cần App Store Connect API key để upload. Xem docs/TESTFLIGHT.md mục 3.
   (Chỉ muốn dựng IPA thì chạy: BUILD_ONLY=1 ./scripts/testflight.sh)"
done

[[ -f "$ASC_KEY_PATH" ]] || fail "Không thấy file key: $ASC_KEY_PATH"

# altool tìm key theo quy ước ~/.appstoreconnect/private_keys/AuthKey_<id>.p8
key_dir="$HOME/.appstoreconnect/private_keys"
mkdir -p "$key_dir"
cp "$ASC_KEY_PATH" "$key_dir/AuthKey_${ASC_KEY_ID}.p8"

echo ""
echo "▸ Kiểm tra IPA trước khi nộp..."
xcrun altool --validate-app \
  -f "$ipa_path" \
  -t ios \
  --apiKey "$ASC_KEY_ID" \
  --apiIssuer "$ASC_ISSUER_ID"

echo ""
echo "▸ Nộp lên TestFlight..."
xcrun altool --upload-app \
  -f "$ipa_path" \
  -t ios \
  --apiKey "$ASC_KEY_ID" \
  --apiIssuer "$ASC_ISSUER_ID"

echo ""
echo "✅ Đã nộp build $build_number."
echo "   Apple xử lý 5-30 phút, theo dõi ở App Store Connect > TestFlight."
echo "   Nhớ tăng build number cho lần nộp sau — Apple không nhận trùng."
