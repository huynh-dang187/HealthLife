# Prompt: Làm tiếp luồng auth + đăng xuất (hướng B)

Project: D:\Nam_3\healthLife (Flutter, đã có go_router + flutter_bloc + easy_localization + FirebaseAuth/Firestore).

## Bối cảnh đã quyết định
- App hiện khởi động bằng `initialLocation: RouteNames.home` HARD-CODE và `_guard` trong
  lib/src/shared/router/app_router.dart đang BỊ COMMENT toàn bộ (có 5 trường hợp TH1-TH5 đã viết sẵn).
- Trước mắt đang áp dụng "Hướng A": Splash (`lib/src/features/splash/presentation/pages/splash_screen.dart`)
  chờ `FirebaseAuth.instance.authStateChanges().first` rồi rẽ hướng (chưa login → /introduction → /signIn;
  đã login + hồ sơ chưa xong → /profile_name; đã login + xong → /home).
- Guard chỉ là safety net, KHÔNG quyết định hướng đi lúc boot.

## Việc cần làm bây giờ (Hướng B — stream + Cubit)
Bạn vừa làm xong chức năng ĐĂNG XUẤT. Giờ tôi muốn:
1. Tạo `AuthCubit` + `AuthState` (state: unknown / unauthenticated / authenticated(uid)) ở đâu hợp lý
   trong kiến trúc này, lắng nghe `FirebaseAuth.instance.authStateChanges()` (stream), không dùng `currentUser` cache.
2. Bỏ comment `_guard` trong app_router.dart, sửa guard đọc trạng thái từ AuthCubit (không từ currentUser),
   real-time: login/logout → tự đá về đúng màn.
3. Sửa `initialLocation` cho hợp flow (đề xuất: /splash).

## Lỗi đã biết phải xử lý khi upgrade
- `RouteNames.complete_information = '/comple_information'` (sai thứ tự chữ, và KHÔNG có GoRoute nào đăng ký path này).
  TH3/TH5 trong guard đang redirect về nó là lỗi → đổi đích thành `RouteNames.profile_name`
  (luồng hồ sơ thật: profile_name → gender → date → height → weight).
- Shell branch 4 trong app_router.dart đăng ký nhầm `RouteNames.activity` (trùng path branch 2)
  thay vì `RouteNames.profile` + ProfileScreen.
- Cần thêm import firebase_auth + cloud_firestore vào app_router.dart.

## Yêu cầu đầu ra
Đọc lại các file: app_router.dart, route_names.dart, splash_screen.dart, signIn, các màn profile,
xem cách project tổ chức Cubit/State hiện có (flutter_bloc), rồi lên FLOW KẾ HOẠCH chi tiết
(file nào tạo/sửa, state model, guard viết lại ra sao, đăng xuất gọi qua đâu) để tôi duyệt trước khi code.