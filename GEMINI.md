# Project Coding Standards & Guidelines

## 1. Brand Identity & Color System (`AppColors`)
* **Brand Guidelines (PVI Insurance Theme)**:
  * **PVI Star Red**: `AppColors.pviRed` (`0xFFE21F26`) / `AppColors.tradeInBlue`: Primary CTA action buttons, star highlights, alert accents.
  * **PVI Corporate Navy**: `AppColors.pviNavy` (`0xFF173665`) / `AppColors.tradeInNavy`: Corporate headers, app bars, card titles, primary dark text.
  * **PVI Accent Blue**: `AppColors.pviBlue` (`0xFF0055A5`): Connectivity icons, secondary links.
  * **PVI Light Surfaces**: `AppColors.tradeInSurfaceBg` / `AppColors.background` (`0xFFF4F7FB`), `AppColors.white`.
  * **PVI Border**: `AppColors.tradeInBorder` / `AppColors.border` (`0xFFDCE4EE`).
* **Never** hardcode raw hex colors (e.g. `const Color(0xFF2563EB)`, `Color(0xFF0F172A)`).
* **Pure Solid Colors (No Shadow, No Alpha)**:
  * **Never** use shadows (`boxShadow`).
  * **Never** use transparency/alpha (`.withValues(alpha: ...)`, `.withOpacity(...)`).
  * **Always** use pure solid color tokens from `AppColors` (e.g. `pviRedLighter`, `pviRedBorder`, `pviNavyLighter`, `pviNavyBorder`, `pviBlueLighter`, `pviBlueBorder`, `tradeInEmeraldBorder`, `tradeInSurfaceBg`).

## 2. Typography (`AppTextStyles`)
* **Never** instantiate raw `TextStyle(...)` directly in widgets without extending standard styles.
* **Always** use typography tokens from `AppTextStyles` (`package:kdtd_ver2_1/app/core/theme/app_text_styles.dart`) using `.copyWith(...)`:
  * Badges & Tags: `AppTextStyles.badge.copyWith(...)`
  * Card Titles: `AppTextStyles.cardTitle.copyWith(...)`
  * Headings: `AppTextStyles.titleMedium.copyWith(...)`, `AppTextStyles.titleSmall.copyWith(...)`
  * Body: `AppTextStyles.bodyMedium.copyWith(...)`, `AppTextStyles.bodySmall.copyWith(...)`
  * Captions: `AppTextStyles.caption.copyWith(...)`
  * Buttons: `AppTextStyles.button.copyWith(...)`

## 3. Responsive Dimensions (`flutter_screenutil`)
* Note that `AppTextStyles` already exports `flutter_screenutil` and `string_extensions.dart`.
* **Always** use `.w`, `.h`, `.r`, `.sp` for all sizes, margins, paddings, and font sizes.

## 4. Localization (`LocaleKeys` & `easy_localization`)
* **Never** hardcode raw user-facing text strings in widgets.
* **Always** declare translation keys in:
  * `assets/translations/vi.json`
  * `assets/translations/en.json`
* Run:
  `flutter pub run easy_localization:generate -S assets/translations -f keys -o locale_keys.g.dart`
* In widgets, use `LocaleKeys.<key_name>.trans()` (and `namedArgs` when needed).

## 5. Dynamic Data & Controller State
* **Never** hardcode counts, step totals, or statuses in widgets.
* **Always** read dynamically from GetX controllers (`controller.total`, `controller.steps.length`, `controller.completed`).
