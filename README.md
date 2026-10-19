# HuyenThoaiBoy iOS

Xcode export của Unity 2021.3.45f2, bundle ID `com.DefaultCompany.Boy003`.

## Build IPA unsigned trên GitHub

Workflow **Build unsigned IPA** chạy khi push lên `main`, hoặc chạy thủ công tại
**Actions → Build unsigned IPA → Run workflow**.

Runner macOS 15 sử dụng Xcode 16.4 để build bản Release cho thiết bị iOS arm64,
tắt code signing và bitcode, sau đó đóng gói `Payload/*.app` thành
`HuyenThoaiBoy-unsigned.ipa`. Không cần certificate, provisioning profile hay
Apple Developer secret.

Khi workflow thành công, mở lần chạy đó và tải artifact
`HuyenThoaiBoy-unsigned-<run number>`. Giải nén artifact để lấy file `.ipa`.
IPA chưa ký cần được ký trước khi cài lên iPhone/iPad.
Artifact IPA được lưu 14 ngày; log và Xcode result bundle được lưu 7 ngày.

## Build trên máy Mac

```sh
git lfs install
git lfs pull
export DEVELOPER_DIR=/Applications/Xcode_16.4.app/Contents/Developer
bash scripts/build-unsigned-ipa.sh
```

Kết quả nằm trong `build/ipa/`. Các thư viện `Libraries/*.a` được quản lý bằng
Git LFS vì `libiPhone-lib.a` vượt giới hạn 100 MB của GitHub.
