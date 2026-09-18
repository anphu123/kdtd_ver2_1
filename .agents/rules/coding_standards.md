---
trigger: always_on
---

# Codebase Guidelines & UI Standards

## 1. Color System (`AppColors`)
* **Never** hardcode raw hex colors (e.g. `const Color(0xFF2563EB)`, `Color(0xFF0F172A)`).
* **Always** use design tokens from [`AppColors`](file:///d:/Dev/Projects/kdtd_ver2_1/lib/app/core/theme/app_colors.dart):
  * Primary Trade-In Blue: `AppColors.tradeInBlue` (`0xFF2563EB`)
  * Dark/Navy Text & Headers: `AppColors.tradeInNavy` (`0xFF0F172A`)
  * Subdued Text/Labels: `AppColors.tradeInSlate` (`0xFF334155`), `AppColors.tradeInSlateLight` (`0xFF94A3B8`)
  * Borders & Dividers: `AppColors.tradeInBorder` (`0xFFE2E8F0`)
  * Backgrounds: `AppColors.tradeInSurfaceBg` (`0xFFF8FAFC`), `AppColors.white`
  * Accents & Statuses: `AppColors.tradeInEmerald` / `tradeInEmeraldLight`, `AppColors.tradeInGold` / `tradeInGoldLight` / `tradeInGoldDark`, `AppColors.purple`, `AppColors.pink`.
  * For opacities, use `.withValues(alpha: ...)` on semantic tokens (e.g. `AppColors.tradeInBlue.withValues(alpha: 0.1)`).

## 2. Typography (`AppTextStyles`)
* **Never** instantiate raw `TextStyle(...)` directly in widgets without extending standard styles.
* **Always** import and use typography tokens from [`AppTextStyles`](file:///d:/Dev/Projects/kdtd_ver2_1/lib/app/core/theme/app_text_styles.dart) using `.copyWith(...)`:
  * Badges & Tags: `AppTextStyles.badge.copyWith(...)`
  * Card Titles: `AppTextStyles.cardTitle.copyWith(...)`
  * Headings: `AppTextStyles.titleMedium.copyWith(...)`, `AppTextStyles.titleSmall.copyWith(...)`, `AppTextStyles.sectionHeader.copyWith(...)`
  * Body Text: `AppTextStyles.bodyMedium.copyWith(...)`, `AppTextStyles.bodySmall.copyWith(...)`
  * Captions & Footers: `AppTextStyles.caption.copyWith(...)`
  * Buttons: `AppTextStyles.button.copyWith(...)`

## 3. Responsive Dimensions (`flutter_screenutil`)
* Note that `AppTextStyles` exports `flutter_screenutil` and `string_extensions.dart`.
* **Always** use screenutil extensions:
  * Width / Horizontal spacing: `.w`
  * Height / Vertical spacing: `.h`
  * Radius / Padding: `.r`
  * Font sizes: `.sp`

## 4. Localization (`LocaleKeys` & `easy_localization`)
* **Never** hardcode plain user-facing text strings (Vietnamese or English) in UI code.
* **Always** add translation keys in both:
  * [`assets/translations/vi.json`](file:///d:/Dev/Projects/kdtd_ver2_1/assets/translations/vi.json)
  * [`assets/translations/en.json`](file:///d:/Dev/Projects/kdtd_ver2_1/assets/translations/en.json)
* Run the key generator whenever new keys are added:
  ```bash
  flutter pub run easy_localization:generate -S assets/translations -f keys -o locale_keys.g.dart
  ```
* Access translations via `LocaleKeys.<key_name>.trans()` (or with `namedArgs` for interpolation).

## 5. Dynamic Data & Controller State
* **Never** hardcode counts, step totals, or statuses in widgets (e.g. avoid `'13 Bài kiểm định'` hardcoded).
* **Always** bind dynamically to GetX controllers:
  * Test count: `controller.total` or `controller.steps.length`
  * Progress: `controller.completed / controller.total`
  * Status labels: use extensions like `step.status.label`
