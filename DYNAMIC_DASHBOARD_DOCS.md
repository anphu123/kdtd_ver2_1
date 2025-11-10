# Dynamic Home Diagnostics Dashboard - Documentation

## 🎨 Overview

Đây là màn hình chính của ứng dụng với thiết kế hiện đại, động và hấp dẫn. Màn hình được xây dựng với các animations và transitions mượt mà để tạo trải nghiệm người dùng tốt nhất.

## ✨ Key Features

### 1. **Collapsing Animated Header**
- Header với animation hình điện thoại đang được quét
- Hiệu ứng phát sáng (glow effect) xung quanh icon
- Thu nhỏ mượt mà khi người dùng cuộn xuống
- Chuyển đổi từ full header sang compact title bar

**Animations:**
- Glow animation (2s, repeat reverse)
- Scan line animation (3s, continuous)
- Collapse animation (based on scroll position)

### 2. **Phone Scanning Animation**
```dart
- Outer glow ring: Pulsing effect
- Middle static ring: Border circle
- Phone icon: Static smartphone icon
- Scanning line: Moving from top to bottom
```

**Effects:**
- Gradient glow với opacity thay đổi
- Blur radius và spread radius động
- Smooth scanning line với gradient

### 3. **Status Summary Section**
- Progress bar animated với TweenAnimationBuilder
- Status pills với icons và counts
- Running indicator với rotating animation
- Section title và description

### 4. **Animated Test List**
- Mỗi item có fade-in animation
- Slide-up effect khi xuất hiện
- Staggered animation (delay based on index)
- Smooth transitions giữa các states

**Animation Details:**
```dart
Duration: 400ms + (index * 50ms)
Max delay: 300ms
Curves: easeOut, easeOutCubic
```

### 5. **Floating Action Button (FAB)**
- Luôn hiển thị ở góc dưới bên phải
- Scale animation khi mount
- Dynamic label: "Start Auto Test" / "Restart Test"
- Loading state với CircularProgressIndicator

### 6. **Test Card Design**
- Left accent bar với màu status
- Icon container với background color
- Title và status text
- Right-side status indicator
- Smooth border color transitions

## 📱 Screen Structure

```
┌─────────────────────────────────────┐
│  Collapsing Header (SliverAppBar)   │
│  ┌──────────────────────────────┐   │
│  │   Phone Scanning Animation   │   │
│  │   Title + Description        │   │
│  │   Device Chip                │   │
│  └──────────────────────────────┘   │
├─────────────────────────────────────┤
│  Status Summary                     │
│  ┌──────────────────────────────┐   │
│  │  Progress Bar: [========>  ] │   │
│  │  Pills: ✓ Passed • ✗ Failed │   │
│  └──────────────────────────────┘   │
├─────────────────────────────────────┤
│  Diagnostic Tests (Scrollable)      │
│  ┌──────────────────────────────┐   │
│  │ 🔋 Battery        [Status]   │   │
│  ├──────────────────────────────┤   │
│  │ 📶 Mobile Network [Status]   │   │
│  ├──────────────────────────────┤   │
│  │ 📡 Wi-Fi          [Status]   │   │
│  │ ...                          │   │
│  └──────────────────────────────┘   │
│                                     │
│                      ┌────────────┐ │
│                      │  FAB Start │ │
│                      └────────────┘ │
└─────────────────────────────────────┘
```

## 🎭 Animation Timeline

### Initial Load
```
0ms   → Start animations
0ms   → Glow controller starts (2s loop)
0ms   → Scan controller starts (3s loop)
0ms   → FAB scale animation (200ms)
50ms  → First item fade in
100ms → Second item fade in
150ms → Third item fade in
...
```

### Scroll Behavior
```
Expanded (320px)
    ↓ User scrolls down
Collapsing... (progress: 0 → 1)
    ↓
Collapsed (56px + status bar)
```

### Item Animations
```
For each item (index: i):
  - Delay: i * 50ms
  - Duration: 400ms + min(i * 50, 300)
  - Fade: 0 → 1
  - Slide: Offset(0, 0.3) → Offset(0, 0)
```

## 🎨 Design Tokens

### Colors
```dart
Background: theme.colorScheme.surface
Header Gradient: primaryContainer → surface
Accent: primary, green, red, orange
```

### Spacing
```dart
Screen padding: 16px
Section spacing: 8-16px
Item spacing: 12px
FAB position: 16px from bottom-right
```

### Border Radius
```dart
Cards: 16px
Pills: 20px
Progress bar: 8px
Icon containers: 12px
```

### Animations
```dart
Glow: 2000ms, repeat reverse
Scan: 3000ms, repeat
Collapse: Based on scroll
Item fade: 400-700ms
FAB scale: 200ms
```

## 🔧 Components

### 1. `HomeDiagnosticsView`
Main view with CustomScrollView and FAB

### 2. `_AnimatedHeader`
SliverAppBar with collapsing behavior

### 3. `_PhoneScanningAnimation`
Animated phone icon with glow and scan effects

### 4. `_DeviceChip`
Chip showing device brand and model

### 5. `_StatusSummary`
Progress bar and status pills

### 6. `_StatusPill`
Individual status indicator with count

### 7. `_AnimatedTestItem`
Wrapper for test cards with animations

### 8. `_TestCard`
Individual diagnostic test card

### 9. `_AnimatedFAB`
Floating action button with animations

## 🚀 Usage

### Navigate to Dashboard
```dart
Get.toNamed(Routes.HOME_DIAGNOSTICS);
```

### From Onboarding
```dart
Get.offAllNamed(Routes.HOME_DIAGNOSTICS);
```

## 📊 Performance Considerations

### Optimizations
1. **Animation Controllers**: Disposed properly in dispose()
2. **List Building**: SliverList for efficient scrolling
3. **Staggered Animations**: Limited max delay to 300ms
4. **Conditional Rendering**: Running indicator only when needed

### Best Practices
- Use `const` constructors where possible
- Dispose animation controllers
- Limit animation complexity on low-end devices
- Use `Obx()` for reactive updates only where needed

## 🎯 User Flow

```
App Launch
    ↓
Onboarding (3 pages)
    ↓
Home Diagnostics Dashboard
    ↓
User scrolls to see tests
    ↓
User taps FAB to start
    ↓
Tests run with animations
    ↓
Results shown in real-time
    ↓
FAB changes to "Restart Test"
```

## 🔄 State Management

### Controller States
```dart
isRunning: bool              // Test execution state
passedCount: int             // Number of passed tests
failedCount: int             // Number of failed tests
skippedCount: int            // Number of skipped tests
steps: List<DiagStep>        // All diagnostic steps
info: Map<String, dynamic>   // Device information
```

### Reactive Updates
```dart
Obx(() {
  // UI rebuilds when:
  - isRunning changes
  - counts change
  - steps status updates
})
```

## 🎨 Visual States

### Test Card States
1. **Pending**: Gray border, unchecked icon
2. **Running**: Orange border, loading spinner
3. **Passed**: Green border, check icon
4. **Failed**: Red border, cancel icon
5. **Skipped**: Gray border, skip icon

### FAB States
1. **Idle (First Run)**: "Start Auto Test"
2. **Idle (After Run)**: "Restart Test"
3. **Running**: "Running..." with spinner

## 📐 Responsive Design

### Layout Breakpoints
- Mobile: Single column list
- Tablet: Same as mobile (optimized for portrait)
- Large screens: Same layout, better spacing

### Adaptive Components
- Header height: 320px (fixed)
- FAB size: Extended FAB (dynamic width)
- Card height: Auto (based on content)

## 🌈 Theme Integration

Fully integrated with Material 3 theming:
- Uses `colorScheme` for all colors
- Adapts to light/dark mode
- Follows Material Design guidelines
- Custom animations enhance the experience

## 📝 Code Example

### Basic Implementation
```dart
// In your app
GetMaterialApp(
  initialRoute: AppPages.INITIAL,
  getPages: AppPages.routes,
)

// Navigate
Get.toNamed(Routes.HOME_DIAGNOSTICS);
```

### Custom Styling
```dart
// Override theme
ThemeData(
  colorScheme: ColorScheme.fromSeed(
    seedColor: Colors.blue,
  ),
)
```

## ✅ Features Checklist

- [x] Collapsing animated header
- [x] Phone scanning animation with glow
- [x] Smooth scroll transitions
- [x] Fade-in/slide-up item animations
- [x] Floating Action Button (always visible)
- [x] Progress tracking with animated bar
- [x] Status pills with counts
- [x] Real-time state updates
- [x] Responsive layout
- [x] Material 3 theming
- [x] Clean architecture (GetX MVC)
- [x] Proper animation disposal

## 🎬 Next Steps

1. Add haptic feedback on interactions
2. Implement test details modal
3. Add export/share results
4. Create report generation
5. Add more test types
6. Implement offline mode
7. Add multi-language support

---

**Created**: November 10, 2025
**Version**: 1.0.0
**Framework**: Flutter + GetX

