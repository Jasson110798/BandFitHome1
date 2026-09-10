BandFit Home v1.3.1 - FULL BUILD FIX

File này là bản đầy đủ, gồm:
- lib/ : toàn bộ code Flutter
- assets/exercises/ : toàn bộ ảnh minh họa bài tập người thật
- pubspec.yaml
- .github/workflows/build-apk.yml : workflow GitHub Actions
- BUILD_APK.yml : bản copy workflow để bạn nhìn thấy ngay trên Windows

CÁCH CẬP NHẬT DỄ NHẤT:
1. Giải nén file ZIP.
2. Upload lib/, assets/, pubspec.yaml lên repo GitHub.
3. Trên GitHub mở .github/workflows/build-apk.yml.
4. Xóa nội dung cũ và copy toàn bộ nội dung từ file BUILD_APK.yml ở thư mục gốc vào.
5. Commit changes.
6. Vào Actions > Build Android APK.
7. Khi thành công tải artifact BandFitHome-v1.3.1-APK.

Repository Secret phải có tên chính xác:
GEMINI_API_KEY
