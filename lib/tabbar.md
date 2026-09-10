# TabBar healthLife — cách dùng & hướng dẫn chỉnh giao diện

> Tài liệu tham khảo. Không sửa gì trong các file code khác khi đọc file này.

## 1. Hiểu nhanh: tabbar này hoạt động thế nào

- App dùng **go_router** `StatefulShellRoute.indexedStack` để tạo ra một **shell** (khung chứa) 5 tab.
- `MainTabScreen` nhận `navigationShell` và chỉ làm 2 việc:
  1. Vẽ **thanh bar glass** phía dưới (`bottomNavigationBar`).
  2. Đặt `body` = `navigationShell` — tức là **màn nào đang active** trong shell sẽ được hiển thị ở body.
- Các màn con (HomeScreen, ActivityScreen, ...) **không biết** và **không cần biết** về MainTabScreen. Chúng chỉ được khai báo trong `branches` của router.
- Bấm tab → `navigationShell.goBranch(index)` → shell đổi màn active.

Sơ đồ nối:

```
app_router.dart
  StatefulShellRoute.indexedStack(
    builder: (…) => MainTabScreen(navigationShell: navigationShell),   ← khung chứa bar + body
    branches: [
      StatefulShellBranch(routes: [HomeScreen]),      ← tab 0
      StatefulShellBranch(routes: [ActivityScreen]),  ← tab 1
      StatefulShellBranch(routes: [ChatbotScreen]),   ← tab 2
      StatefulShellBranch(routes: [NutritionScreen]), ← tab 3
      StatefulShellBranch(routes: [ProfileScreen]),   ← tab 4
    ],
  )
```

## 2. Các file nên đọc để hiểu

| File | Vai trò |
|---|---|
| `lib/src/shared/router/app_router.dart` | **Nơi nối tất cả lại với nhau** (shell + branches). Muốn hiểu "ai đưa ai vào đâu" thì đọc file này. |
| `lib/src/features/tab_bar/presentation/page/main_tab_screen.dart` | Khung chính: thanh bar glass, highlight trượt, nhún khi tap, swipe chuyển tab. **Đây là file trung tâm**. |
| `lib/src/features/tab_bar/presentation/widget/tab_bar_item.dart` | 1 item trong bar (icon + chữ + màu chọn/không chọn). |
| `lib/src/features/tab_bar/presentation/widget/app_glass.dart` | Hiệu ứng thủy tinh (liquid glass) của thanh bar. |
| `lib/src/features/home/presentation/pages/home_screen.dart` | Ví dụ 1 màn con — nó không chứa tabbar, chỉ là "nội dung" được shell hiển thị. |
| `lib/src/shared/router/route_names.dart` | Định nghĩa đường dẫn (`home`, `activity`, ...) — mỗi tab = 1 const. |

## 3. Đoạn code nối (trong `app_router.dart`) — chuẩn đúng

**Cần import (đường dẫn được dùng hiện tại):**

```dart
import 'package:healthlife/src/features/home/presentation/pages/home_screen.dart';
import 'package:healthlife/src/features/tab_bar/presentation/page/activity_screen.dart';
import 'package:healthlife/src/features/tab_bar/presentation/page/chatbot_screen.dart';
import 'package:healthlife/src/features/tab_bar/presentation/page/main_tab_screen.dart';
import 'package:healthlife/src/features/tab_bar/presentation/page/nutrition_screen.dart';
import 'package:healthlife/src/features/tab_bar/presentation/page/profile_screen.dart';
```

**Khối shell (dạng hoàn chỉnh — đặt trong list `routes:`)**

```dart
StatefulShellRoute.indexedStack(
  builder: (context, state, navigationShell) =>
      MainTabScreen(navigationShell: navigationShell),
  branches: [
    StatefulShellBranch(routes: [_route(RouteNames.home, (_) => const HomeScreen())]),
    StatefulShellBranch(routes: [_route(RouteNames.activity, (_) => const ActivityScreen())]),
    StatefulShellBranch(routes: [_route(RouteNames.chatbot, (_) => const ChatbotScreen())]),
    StatefulShellBranch(routes: [_route(RouteNames.nutrition, (_) => const NutritionScreen())]),
    StatefulShellBranch(routes: [_route(RouteNames.profile, (_) => const ProfileScreen())]),
  ],
),
```

> ⚠️ Lưu ý trạng thái hiện tại: trong `app_router.dart` bạn đang dán **thiếu** `StatefulShellRoute.indexedStack(...)` ở đầu và **thiếu 6 import** trên — khối `branches:` trần nên chưa compile được. Sửa theo đúng 2 khối trên là hết lỗi.

## 4. `main_tab_screen.dart` — đoạn cốt lõi

```dart
void _onTap(int index) {
  _scaleController.forward(from: 0.0);          // nhún icon
  widget.navigationShell.goBranch(index);        // CHUYỂN TAB
}
```

```dart
body: GestureDetector(
  onHorizontalDragEnd: (details) {              // SWIPE chuyển tab
    final v = details.primaryVelocity ?? 0;
    if (v < -200 && index < _tabs.length - 1) { _onTap(index + 1); }
    else if (v > 200 && index > 0)              { _onTap(index - 1); }
  },
  child: widget.navigationShell,                // body = màn active
),
```

## 5. ✅ RIÊNG: các đoạn CHỈNH GIAO DIỆN (đọc + sửa khi cần)

### 5.1 Đổi danh sách 5 tab (icon + tên) — `main_tab_screen.dart`
Tìm biến `_tabs` (giữa file):
```dart
const _tabs = [
  _TabInfo(Icons.home_outlined, 'Trang chủ'),
  _TabInfo(Icons.access_alarm, 'Hoạt động'),
  _TabInfo(Icons.smart_toy_outlined, 'Chatbot'),
  _TabInfo(Icons.restaurant_outlined, 'Dinh dưỡng'),
  _TabInfo(Icons.person_outline, 'Hồ sơ'),
];
```
- Đổi **icon**: thay `Icons.xxx` bằng icon Material khác.
- Đổi **tên**: sửa chữ trong `''`.
- **Thêm/bớt tab**: thêm 1 dòng `_TabInfo` → nhớ thêm 1 `StatefulShellBranch` tương ứng trong `app_router.dart`.

### 5.2 Màu mốc chọn / không chọn — `tab_bar_item.dart`
```dart
final color = selected
    ? (isDark ? UIColors.white : UIColors.pink)        // tab đang chọn
    : (isDark ? UIColors.textBody : UIColors.lightGray); // tab chưa chọn
```
Đổi `UIColors.pink` (đã có trong `lib/src/common/constants/colors.dart`) là đổi màu thương hiệu.

### 5.3 Hiệu ứng "thủy tinh" — `app_glass.dart`
```dart
LiquidGlassSettings.figma(
  refraction: 80,   // độ khúc xạ (gương)
  depth: 20,        // độ dày
  dispersion: 50,   // tán sắc (viền cầu vồng)
  frost: 4,         // độ mờ nền (mờ hơn = nhìn rõ hơn)
  lightAngle: -pi / 4, // hướng nguồn sáng
)
```
Muốn nền **trắng mờ đơn giản** (nhanh, nhẹ) thì truyền `isFigma: false` + `color: ...`:
```dart
AppGlass(borderRadius: 40, isFigma: false, color: const Color(0x99FFFFFF), child: ...)
```

### 5.4 Highlight pill trượt (vệt hồng theo tab chọn) — `main_tab_screen.dart`
```dart
AnimatedPositioned(
  left: 16 + (barWidth - 32) * (index / _tabs.length), // vị trí nằm ngang
  width: (barWidth - 32) / _tabs.length,                // bề rộng 1 ô
  child: AnimatedContainer(
    decoration: BoxDecoration(
      gradient: RadialGradient(colors: [pink.withAlpha(80), pink.withAlpha(150), pink.withAlpha(0)]),
      borderRadius: BorderRadius.circular(24),
    ),
  ),
)
```
- Đổi `left`/`width` → thay đổi hành trình trượt.
- Đổi mảng `colors:` → đổi màu vệt.

### 5.5 Kích thước item trong bar — `tab_bar_item.dart`
```dart
SizedBox(height: 48, ...)   // chiều cao ô tab
Icon(icon, size: 22, ...)    // kích cỡ icon
AppText.semiBold(title, fontSize: 12, ...) // cỡ chữ
```
### 5.6 Khoảng cách/vỉnh quanh thanh bar — `main_tab_screen.dart`
```dart
Padding(padding: EdgeInsets.only(left: 8, right: 8, bottom: context.bottomPadding))
AppGlass(borderRadius: 40, child: Padding(padding: EdgeInsets.all(8), child: Row(...)))
// giữa 2 item: 4.gap
```
### 5.7 Tốc độ/nhún khi bấm — `main_tab_screen.dart`
`TweenSequence 1.0 → 0.95 → 1.0` + `duration: 250ms` (AnimationController) — tăng/giảm số `0.95` hoặc `duration` là thay đổi độ nhún.

## 6. Cách dùng / tái sử dụng

### 6.1 Chuyển tab từ bất kỳ màn nào
Không cần dùng event bus — chỉ cần điều hướng theo đường dẫn:
```dart
import 'package:healthlife/src/shared/router/route_names.dart';
import 'package:go_router/go_router.dart';

context.go(RouteNames.nutrition);   // nhảy sang tab "Dinh dưỡng"
context.go(RouteNames.home);        // về tab "Trang chủ"
```

### 6.2 Màn con có cần import tabbar không?
**Không.** Màn con chỉ cần là 1 `Scaffold`/`Widget` bình thường — shell tự đặt nó vào body. Muốn giữ lại tabbar thì mọi điều hướng nội bộ màn con dùng `context.go(...)` (không dùng `Navigator.push` kiểu cũ).

### 6.3 "Nạp lại dữ liệu" khi vào tab
Không có sự kiện "RefreshTabBar". Màn con tự nạp dữ liệu khi khởi tạo (trong cubit của màn đó) là đủ.

### 6.4 Đổi màn nào chạm tabbar?
Sửa 1 dòng trong `app_router.dart` (builder của branch) — phần còn lại giữ nguyên. Thứ tự branch = thứ tự tab trong `_tabs`.

## 7. Khi chạy thử
- Để vào thẳng tabbar khi dev: `initialLocation: RouteNames.home` (trong `app_router.dart`). Xong nhớ đổi lại `RouteNames.splash`.
- Hiệu ứng glass dùng shader → **chỉ hiện đủ trên Android/iOS**, không hiện trên web, yếu trên Windows desktop.
- Nền màn con nên có màu/sắc (không trắng trơn) thì mới thấy được hiệu ứng kính.