# HuyenThoaiBoy iOS

Xcode export của Unity 2021.3.45f2, bundle ID `com.DefaultCompany.Boy003`.

## Build IPA unsigned trên Codemagic

File `codemagic.yaml` ở gốc repo định nghĩa workflow `ios-unsigned`.

1. Đăng nhập [Codemagic](https://codemagic.io/apps), chọn **Add application**.
2. Chọn repo `AnhhPhuong06/NROV2` từ GitHub, hoặc thêm bằng URL
   `https://github.com/AnhhPhuong06/NROV2.git` và chọn loại **Other** nếu được hỏi.
3. Dùng cấu hình `codemagic.yaml`, chọn branch `main` và workflow
   **HuyenThoaiBoy - unsigned IPA** (`ios-unsigned`).
4. Chọn **Start new build**. Khi thành công, tải
   `HuyenThoaiBoy-unsigned.ipa` trong **Artifacts** của lần build.

Workflow sử dụng Mac mini M2 và Xcode 16.4, tải thư viện Unity qua Git LFS,
build bản Release cho thiết bị iOS arm64, tắt code signing và bitcode,
sau đó đóng gói `Payload/*.app` thành IPA. Không cần Unity license,
certificate, provisioning profile hay Apple Developer secret vì đây là
Xcode export có sẵn.

Sau khi repo được kết nối và webhook được thiết lập trong Codemagic, push lên
`main` sẽ kích hoạt workflow. IPA chưa ký cần được ký trước khi cài lên thiết bị.
Log được lưu cùng artifact để kiểm tra nếu build lỗi.

Tài liệu: [thêm ứng dụng](https://docs.codemagic.io/getting-started/adding-apps/),
[cấu hình YAML](https://docs.codemagic.io/yaml-basic-configuration/yaml-getting-started/).

## GitHub Actions (chạy thủ công)

Workflow **Build unsigned IPA** chỉ chạy thủ công tại
**Actions → Build unsigned IPA → Run workflow** để tránh chạy song song với
Codemagic mỗi lần push. Artifact IPA trên GitHub được lưu 14 ngày.

## Build trên máy Mac

```sh
git lfs install
git lfs pull
export DEVELOPER_DIR=/Applications/Xcode_16.4.app/Contents/Developer
bash scripts/build-unsigned-ipa.sh
```

Kết quả nằm trong `build/ipa/`. Các thư viện `Libraries/*.a` được quản lý bằng
Git LFS vì `libiPhone-lib.a` vượt giới hạn 100 MB của GitHub.
