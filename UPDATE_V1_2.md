BandFit Home v1.2 - Real exercise images + AI calorie patch

Nội dung cập nhật:
1. Thêm ảnh minh họa người thật cho các bài:
   - Band/Banded Squat
   - Glute Bridge / Hip Thrust
   - Lateral Walk / Monster Walk
   - Biceps Curl
   - Shoulder Press
   Các bài chưa có ảnh riêng sẽ tự dùng hình minh họa vector fallback.

2. Tối ưu hiển thị điện thoại:
   - Danh sách bài tập có thumbnail rõ hơn.
   - Màn hình chi tiết có phần Minh họa nổi bật.
   - Màn hình khi đang tập hiển thị ổn định hơn trên màn hình nhỏ.
   - Có thể chạm vào ảnh minh họa lớn để xem full màn hình.

3. Vá AI Calo:
   - Cập nhật service gọi Gemini.
   - Thêm fallback endpoint để giảm lỗi.
   - Thông báo lỗi tiếng Việt dễ hiểu hơn.
   - Thêm nút phân tích lại.
   - Thêm hướng dẫn chụp ảnh để AI dễ nhận diện.

4. Workflow build APK:
   - Tự tạo pubspec đầy đủ dependencies.
   - Build kèm --dart-define=GEMINI_API_KEY từ GitHub Secret.
   - Tự thêm quyền Internet / Camera / Read images vào AndroidManifest.

Cách dùng:
- Upload toàn bộ file trong gói này lên repository của bạn rồi commit.
- Đảm bảo GitHub Secret tên GEMINI_API_KEY đã tồn tại.
- Vào Actions > Build Android APK > Run workflow.
- Khi build xong, tải artifact BandFitHome-APK.
