# خطة مشروع سِكّة (Sekka) — Flutter Frontend

---

## ملخص فهمي للمشروع

سِكّة هو تطبيق موبايل (Flutter) يخدم **سائقي الديليفري في مصر** ويساعدهم في:
- إدارة الطلبات اليومية من مصادر متعددة (واتساب، اتصال، مكتب)
- تحسين المسارات الذكية لتوفير الوقت والبنزين
- إدارة الكاش والمحاسبة مع جهات متعددة (مطاعم، شركات، حر)
- توثيق التسليم بالصور والموقع
- العمل بدون إنترنت (Offline-First)

**الأطراف:** سائق (المستخدم الأساسي) ← مرسل (مطعم/شركة/فرد) ← مستلم (العميل)

**الفلسفة:** "كل سائق ديليفري يستاهل أداة تحترم وقته وتحمي فلوسه"

---

## 1. هيكلية المشروع (Project Structure) — Clean Architecture + Feature-First

```
lib/
├── main.dart
├── app.dart                          # MaterialApp + Theme + Router
│
├── core/                             # الطبقة المشتركة
│   ├── constants/
│   │   ├── app_colors.dart           # الألوان المعتمدة فقط
│   │   ├── app_sizes.dart            # المقاسات والمسافات الموحدة
│   │   └── app_strings.dart          # النصوص الثابتة (عربي)
│   │
│   ├── theme/
│   │   ├── app_theme.dart            # ThemeData الموحد (Light + Dark)
│   │   └── app_typography.dart       # أنماط الخطوط (Tajawal)
│   │
│   ├── widgets/                      # المكونات القابلة لإعادة الاستخدام
│   │   ├── sekka_button.dart
│   │   ├── sekka_input_field.dart
│   │   ├── sekka_card.dart
│   │   ├── sekka_search_bar.dart
│   │   ├── status_badge.dart
│   │   ├── sekka_stepper.dart
│   │   ├── sekka_bottom_nav.dart
│   │   ├── action_tile.dart
│   │   ├── sekka_swipe_action.dart
│   │   ├── sekka_empty_state.dart
│   │   └── sekka_loading.dart
│   │
│   ├── extensions/                   # Extension methods
│   │   ├── context_extensions.dart   # theme, mediaQuery shortcuts
│   │   ├── string_extensions.dart    # Arabic number conversion
│   │   └── date_extensions.dart
│   │
│   ├── utils/
│   │   ├── arabic_number_converter.dart
│   │   ├── clipboard_parser.dart     # Smart Clipboard logic
│   │   └── validators.dart
│   │
│   └── routing/
│       ├── app_router.dart           # GoRouter setup
│       └── route_names.dart
│
├── features/                         # الميزات — كل ميزة مستقلة
│   │
│   ├── auth/                         # التسجيل والمصادقة
│   │   ├── data/
│   │   │   ├── models/
│   │   │   └── repositories/
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   └── usecases/
│   │   └── presentation/
│   │       ├── screens/
│   │       │   ├── splash_screen.dart
│   │       │   ├── login_screen.dart
│   │       │   ├── otp_screen.dart
│   │       │   ├── register_screen.dart
│   │       │   └── demo_mode_screen.dart
│   │       └── widgets/
│   │
│   ├── home/                         # الصفحة الرئيسية (Dashboard)
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │       ├── screens/
│   │       │   └── home_screen.dart
│   │       └── widgets/
│   │           ├── current_order_card.dart
│   │           ├── daily_stats_bar.dart
│   │           └── greeting_header.dart
│   │
│   ├── orders/                       # إدارة الطلبات
│   │   ├── data/
│   │   │   ├── models/
│   │   │   │   └── order_model.dart
│   │   │   └── repositories/
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── order.dart
│   │   │   └── enums/
│   │   │       └── order_status.dart
│   │   └── presentation/
│   │       ├── screens/
│   │       │   ├── orders_list_screen.dart
│   │       │   ├── order_details_screen.dart
│   │       │   ├── add_order_screen.dart
│   │       │   └── complete_order_screen.dart
│   │       └── widgets/
│   │           ├── order_card.dart
│   │           ├── order_status_chip.dart
│   │           ├── smart_clipboard_sheet.dart
│   │           └── swipe_to_complete.dart
│   │
│   ├── map/                          # الخريطة والملاحة
│   │   └── presentation/
│   │       ├── screens/
│   │       │   └── map_screen.dart
│   │       └── widgets/
│   │
│   ├── wallet/                       # المحفظة والمالية
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │       ├── screens/
│   │       │   ├── wallet_screen.dart
│   │       │   └── daily_report_screen.dart
│   │       └── widgets/
│   │
│   ├── partners/                     # نظام الجهات (المطاعم/الشركات)
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │
│   ├── customers/                    # إدارة العملاء والتقييم
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │
│   ├── stats/                        # الإحصائيات والتقارير
│   │   └── presentation/
│   │
│   ├── settings/                     # الإعدادات
│   │   └── presentation/
│   │       ├── screens/
│   │       │   ├── settings_screen.dart
│   │       │   └── profile_screen.dart
│   │       └── widgets/
│   │
│   └── camera/                       # كاميرا التوثيق
│       └── presentation/
│
├── shared/                           # Shared state & services
│   ├── providers/                    # Riverpod / Bloc providers
│   └── services/
│       ├── location_service.dart
│       ├── notification_service.dart
│       └── tts_service.dart
│
└── l10n/                             # Localization (Arabic)
    └── app_ar.arb
```

---

## 2. لوحة الألوان المعتمدة (Global Palette)

| العنصر | Hex | متغير Dart |
|--------|-----|------------|
| Primary (البرتقالي) | `#FC5D01` | `AppColors.primary` |
| Background (خلفية) | `#F7FAFC` | `AppColors.background` |
| Surface (أسطح) | `#FFFFFF` | `AppColors.surface` |
| Borders (حدود) | `#E2E8F0` | `AppColors.border` |
| Success (نجاح) | `#38A169` | `AppColors.success` |
| Error (خطأ) | `#E53E3E` | `AppColors.error` |
| Warning (تنبيه) | `#ECC94B` | `AppColors.warning` |
| Headline Text | `#1A202C` | `AppColors.textHeadline` |
| Body Text | `#4A5568` | `AppColors.textBody` |
| Caption Text | `#718096` | `AppColors.textCaption` |

---

## 3. نظام الخطوط (Typography System)

| النوع | الحجم | الوزن | اللون |
|-------|-------|-------|-------|
| Headline Large | 24sp | Bold (700) | `#1A202C` |
| Headline Medium | 20sp | Bold (700) | `#1A202C` |
| Headline Small | 18sp | Bold (700) | `#1A202C` |
| Title Large | 16sp | SemiBold (600) | `#1A202C` |
| Title Medium | 14sp | SemiBold (600) | `#1A202C` |
| Body Large | 16sp | Medium (500) | `#4A5568` |
| Body Medium | 14sp | Medium (500) | `#4A5568` |
| Body Small | 12sp | Medium (500) | `#4A5568` |
| Caption | 12sp | Light (300) | `#718096` |
| Caption Small | 10sp | Light (300) | `#718096` |

- **الخط:** Tajawal
- **line-height:** 1.5 لكل النصوص
- **letterSpacing:** 0.0 (للعربي)

---

## 4. المكونات القابلة لإعادة الاستخدام (Custom Widgets)

### 4.1 SekkaButton
- الزر الرئيسي للتطبيق
- `borderRadius: 12`
- خلفية: `AppColors.primary` (#FC5D01)
- نص: أبيض، Tajawal Bold
- ارتفاع: 56px
- حالات: `enabled` / `disabled` / `loading`
- أنواع: `primary` / `secondary` (outline) / `text`

### 4.2 SekkaInputField
- حقل إدخال موحد
- خلفية: أبيض
- حدود: `AppColors.border`
- Focus border: `AppColors.primary`
- `borderRadius: 12`
- يدعم: `prefix icon` / `suffix icon` / `error text` / `hint`
- RTL ready

### 4.3 SekkaCard
- الحاوية الأساسية
- `borderRadius: 16`
- ظل ناعم: `BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: Offset(0, 2))`
- خلفية: `AppColors.surface`
- padding: 16

### 4.4 SekkaSearchBar
- شريط بحث minimalist
- أيقونة بحث + حقل نص
- `borderRadius: 12`
- خلفية: `AppColors.surface`

### 4.5 StatusBadge
- ملصق حالة صغير
- يتغير لونه حسب الحالة:
  - `new` → أزرق
  - `onTheWay` → برتقالي
  - `arrived` → أصفر
  - `delivered` → أخضر
  - `failed` → أحمر
  - `cancelled` → رمادي
  - `returned` → بنفسجي
  - `postponed` → رمادي فاتح
- `borderRadius: 20` (pill shape)
- padding: `horizontal: 12, vertical: 6`

### 4.6 SekkaStepper
- يوضح مراحل تقدم العملية
- نقاط متصلة بخطوط
- النقطة النشطة: `AppColors.primary`
- النقاط المكتملة: `AppColors.success`
- النقاط المستقبلية: `AppColors.border`

### 4.7 SekkaBottomNav
- شريط تنقل سفلي
- 4 عناصر: الرئيسية | الطلبات | المحفظة | الإعدادات
- العنصر النشط: `AppColors.primary`
- الباقي: `AppColors.textCaption`
- بدون labels (أيقونات فقط + dot indicator)

### 4.8 ActionTile
- بطاقة بيانات شخص/جهة
- صورة دائرية + اسم + معلومة ثانوية + تقييم نجوم
- trailing action (سهم / زر)

### 4.9 SekkaSwipeAction
- مكون السحب لتأكيد العمليات
- شريط قابل للسحب من اليمين لليسار (RTL)
- ارتفاع: 56px
- `borderRadius: 28`
- خلفية: `AppColors.primary`
- أيقونة دائرية تتحرك

### 4.10 SekkaEmptyState
- حالة فارغة موحدة
- أيقونة كبيرة + عنوان + وصف + زر اختياري

### 4.11 SekkaLoading
- مؤشر تحميل موحد
- Shimmer effect للقوائم
- Circular progress للأزرار

---

## 5. مراحل التطوير (خطة التنفيذ)

### المرحلة 0: البنية التحتية (الأساس)
> **يتم بناؤها أولاً قبل أي شاشة**

1. إنشاء مشروع Flutter جديد
2. إعداد `pubspec.yaml` (dependencies)
3. بناء هيكل المجلدات (Feature-First)
4. إعداد `AppColors` + `AppSizes` + `AppStrings`
5. إعداد `AppTheme` (ThemeData كامل مع Tajawal)
6. إعداد `AppTypography` (كل أنماط النصوص)
7. بناء **كل الـ Custom Widgets** (11 مكون)
8. إعداد GoRouter (الـ Routing)
9. إعداد Extensions (context, string, date)

### المرحلة 1: MVP — الشاشات الأساسية (Phase 1)

#### Auth Flow:
1. **Splash Screen** — شاشة البداية + لوجو سِكّة
2. **Login Screen** — إدخال رقم الهاتف + زر "جرّب بدون تسجيل"
3. **OTP Screen** — إدخال كود التحقق + عداد تنازلي
4. **Register Screen** — إكمال البيانات (اسم، صورة، نوع مركبة، منطقة)

#### Main Flow:
5. **Home Screen (Dashboard)** — الطلب الحالي + إحصائيات اليوم + زر بدء الرحلة
6. **Orders List Screen** — قائمة الطلبات مع فلترة حسب الحالة
7. **Add Order Screen** — إضافة طلب (يدوي + Smart Clipboard)
8. **Order Details Screen** — تفاصيل الطلب + أزرار الإجراءات
9. **Complete Order Screen** — إتمام التسليم (المبلغ + صورة + سحب للتأكيد)
10. **Wallet Screen** — المحفظة + ملخص اليوم المالي
11. **Settings Screen** — الإعدادات والبروفايل

### المرحلة 2: Smart Features
12. Map Screen — عرض الطلبات على الخريطة
13. Route Optimization — ترتيب المسار الذكي
14. Customer Rating — تقييم العملاء بعد التسليم
15. Customer Card — بطاقة العميل الكاملة
16. Partners Screen — إدارة الجهات (مطاعم/شركات)
17. Settlement Screen — تسوية العهدة مع الشركاء
18. Daily Report — التقرير اليومي التفصيلي

### المرحلة 3: Advanced
19. Offline Mode
20. Camera POD (Proof of Delivery)
21. Quick Messages + WhatsApp
22. Statistics & Charts
23. Subscriptions
24. Digital ID Badge

---

## 6. Dependencies المقترحة

```yaml
dependencies:
  flutter:
    sdk: flutter

  # UI & Design
  google_fonts: ^6.0.0          # Tajawal font
  flutter_svg: ^2.0.0           # SVG icons
  shimmer: ^3.0.0               # Loading shimmer

  # Navigation
  go_router: ^14.0.0

  # State Management
  flutter_riverpod: ^2.5.0      # أو flutter_bloc

  # Local Storage
  isar: ^3.1.0                  # Offline DB
  isar_flutter_libs: ^3.1.0
  shared_preferences: ^2.2.0

  # Network
  dio: ^5.4.0

  # Maps & Location
  flutter_map: ^6.0.0           # OpenStreetMap (مجاني)
  geolocator: ^11.0.0
  url_launcher: ^6.2.0          # Deep Link for Google Maps

  # Camera & Media
  image_picker: ^1.0.0
  flutter_image_compress: ^2.1.0

  # Notifications
  firebase_messaging: ^14.0.0
  flutter_local_notifications: ^17.0.0

  # Text-to-Speech
  flutter_tts: ^3.8.0

  # Utils
  intl: ^0.19.0                 # Date/Number formatting
  uuid: ^4.2.0
  permission_handler: ^11.0.0
```

---

## 7. قواعد الكود (Development Standards)

1. **const constructors** في كل مكان ممكن
2. **Stateless widgets** قدر الإمكان
3. **ThemeData** — لا ألوان hardcoded أبداً
4. **Feature-First** — كل feature مستقلة بالكامل
5. **Arabic numbers** — دعم الأرقام العربية والإنجليزية
6. **RTL** — كل التصميم Right-to-Left
7. **Dart 3+ features** — Records, Pattern Matching, Sealed Classes
8. **line-height: 1.5** لكل النصوص العربية
9. **Performance** — const, lazy loading, image compression
10. **Naming** — ملفات snake_case، classes PascalCase

---

## 8. ترتيب العمل خطوة بخطوة

```
الخطوة 1: ✅ قراءة وفهم المشروع (تم)
الخطوة 2: ✅ إعداد الخطة الكاملة (تم — هذا الملف)
الخطوة 3: 🔲 إنشاء مشروع Flutter + هيكل المجلدات
الخطوة 4: 🔲 بناء Core (Colors, Theme, Typography, Sizes)
الخطوة 5: 🔲 بناء Custom Widgets (11 مكون)
الخطوة 6: 🔲 إعداد Router + Extensions
الخطوة 7: 🔲 نبدأ الشاشات — شاشة شاشة بموافقتك
```

> **ملاحظة:** مش هبدأ أي شاشة إلا لما نتفق على تصميمها سوا وتقولي "ابدأ"

---

## 9. الشاشات المطلوبة للـ MVP (بالترتيب)

| # | الشاشة | الوصف | الأولوية |
|---|--------|-------|----------|
| 1 | Splash | لوجو + تحقق من الإصدار | عالية |
| 2 | Login | رقم الهاتف + زر التجربة | عالية |
| 3 | OTP | كود التحقق | عالية |
| 4 | Register | بيانات التسجيل | عالية |
| 5 | Home | Dashboard يومي | عالية |
| 6 | Orders List | قائمة الطلبات + فلاتر | عالية |
| 7 | Add Order | إضافة طلب يدوي/clipboard | عالية |
| 8 | Order Details | تفاصيل + إجراءات | عالية |
| 9 | Complete Order | تأكيد التسليم بالسحب | عالية |
| 10 | Wallet | المحفظة + ملخص مالي | عالية |
| 11 | Settings | الإعدادات + البروفايل | متوسطة |
