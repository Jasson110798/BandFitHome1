BandFit Home v1.3.3 - AI DIAGNOSTIC FIX

Thay đổi quan trọng:
- Không hard-code 1-2 model Gemini nữa.
- App tự gọi models.list để tìm model generateContent thực sự khả dụng với API key của bạn.
- Thêm nút KIỂM TRA AI trong tab AI Calo.
- Nút kiểm tra test: Internet -> API key -> danh sách model -> text generation.
- Khi phân tích ảnh lỗi, app hiển thị Chi tiết kỹ thuật và cho phép sao chép lỗi.
- Workflow GitHub test Gemini API trước khi build APK. API key lỗi/quota/model lỗi thì build dừng ngay.
- Giữ toàn bộ ảnh bài tập người thật và giao diện v1.3.2.

Cách dùng:
1. Upload toàn bộ source v1.3.3 vào repo, ghi đè file cũ.
2. Giữ GitHub Secret GEMINI_API_KEY.
3. Actions > Build Android APK.
4. Nếu step 'Test Gemini API before APK build' xanh => key truy cập Gemini được.
5. Cài APK mới.
6. Mở AI Calo > bấm 'Kiểm tra AI'.
7. Chỉ khi báo 'AI hoạt động' mới chụp/chọn ảnh và bấm 'Phân tích ảnh'.
