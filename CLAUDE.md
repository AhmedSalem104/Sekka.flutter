# Sekka (سِكّة) — Project Rules

## Architecture
- Clean Architecture + Feature-First folder structure
- All shared UI in `lib/core/widgets/` — NEVER create one-off widgets outside core
- All colors from `AppColors` — ZERO hardcoded colors
- All text styles from `AppTypography` — ZERO inline TextStyle
- All sizes from `AppSizes` — responsive via `Responsive` utility
- Import via barrel: `import 'package:sekka/core/core.dart';`

## Design System
- Font: Tajawal (Arabic) — all weights in assets/fonts/
- Primary: #FC5D01 | Background: #F7FAFC | Surface: #FFFFFF
- Border radius: buttons=12, cards=16, pills=100
- RTL (Right-to-Left) — always TextDirection.rtl
- Responsive: design base 390x844, scales via Responsive.w/h/sp/r

## Custom Widgets (MUST use these, not raw Flutter widgets)
- SekkaButton (primary/secondary/text)
- SekkaInputField (with label, RTL, validation)
- SekkaCard (shadow, rounded, tappable)
- SekkaSearchBar
- StatusBadge (8 order statuses)
- SekkaStepper (timeline)
- SekkaBottomNav (safe area aware)
- ActionTile (person/entity card)
- SekkaSwipeAction (swipe to confirm — RTL)
- SekkaEmptyState
- SekkaLoading / SekkaShimmerList

## Code Standards
- Dart 3+ features: records, pattern matching, sealed classes
- const constructors everywhere possible
- prefer_final_locals, require_trailing_commas
- Stateless over Stateful when possible
- Arabic UI text from AppStrings — no inline Arabic in widgets
- All phone input: normalize Arabic numerals via .toEnglishNumbers
- Validate with Validators class

## Performance
- const widgets reduce rebuilds
- Image compression before upload (flutter_image_compress)
- Shimmer loading instead of spinners for lists
- Lazy loading for long lists
- Portrait lock only

## Don'ts
- Do NOT start any screen without user approval
- Do NOT use hardcoded colors, sizes, or text styles
- Do NOT create new widgets that duplicate existing core widgets
- Do NOT use Google Maps API (use Deep Link + flutter_map)
