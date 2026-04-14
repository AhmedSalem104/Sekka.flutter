# تقرير مشاكل Sekka Delivery API — النسخة النهائية

**تاريخ آخر اختبار:** 2026-04-14
**البيئة:** https://sekka.runasp.net
**Swagger:** https://sekka.runasp.net/swagger/index.html
**النطاق:** كل الـ endpoints غير الأدمن وغير الـ Partner Portal
**عدد العمليات اللي اتجربت:** 270+ على يوزرين (فاطمة محمد + Test Delivery + Delete Test)

---

## ✅ ما تم إصلاحه (شغل الباك إند الجيد)

| # | المشكلة | كان | بقى |
|---|---|---|---|
| 001 | `/profile.totalOrders/Delivered` = 0 | 0/0 | 18/5 ✓ |
| 002 | `walletBalance` متناقض مع `/wallet/balance` | 0 vs 4200 | 4200 = 4200 ✓ |
| 005 | `/statistics/weekly` aggregation | 0 / dailyBreakdown=1 | 2200 / dailyBreakdown=7 ✓ |
| 006 | `/statistics/monthly` ناقص + crash بدون params | 3600/2 + HTTP 500 | 5800/18 + 200 ✓ |
| 007 | `/shifts/summary` hardcoded | 31/248/8 لكل سواق | real values 3/2.5/0.8 ✓ |
| 008 | `Shift.id == Driver.id` | متطابقين | مختلفين ✓ |
| 009 | breakdown نسب = 137% | 137% | 100% ✓ |
| 010 | Default date = `0001-01-01` | MinValue | اليوم الحالي ✓ |
| 011 | `/shifts/end` بدون Content-Length | 411 | 200 ✓ |
| 026 | `/routes/active.totalDistanceKm = 4756km` | 4756 | حساب طبيعي ✓ |
| 078 | `/breaks/start` double-start | يقبل الاتنين | 409 "يوجد استراحة نشطة" ✓ |

---

## 🔴 P0 — Critical Financial (لسه مكسور)

### BUG-003 — `cashOnHand` لا يُخصم بالتسويات

**Severity:** Critical
**Endpoints:** `GET /api/v1/wallet/cash-status`, `/wallet/balance`, `/profile`

**الواقع:**
```
totalEarnings    = 5800.00
totalSettlements = 1600.00
المتوقع cashOnHand = 4200
الفعلي  cashOnHand = 5800   ❌
```

**التأثير:** السواق بيشوف رقم كاش أكبر من الحقيقة بـ 1600 ج. تنبيه `cashAlertThreshold` بيشتغل على رقم غلط. التقارير المالية مش متطابقة.

**الحل المقترح:** `cashOnHand` لازم يُحسب من الـ ledger (CashTransactions) أو يُنزل عند POST `/settlements`.

---

### BUG-004 — `pendingBalance` سالب لشريك حقيقي

**Severity:** Critical (financial discrepancy)
**Endpoint:** `GET /api/v1/settlements/partner/{partnerId}/balance`

**مثال حقيقي (مطعم الثورة):**
```json
{
  "totalCollected": 1100.00,
  "totalSettled": 1600.00,
  "pendingBalance": -500.00    ← سالب
}
```

السواق دفع للشريك 500 ج أكتر مما حصّله من أوردراته. **تحقيق مطلوب:** هل في تسويات اتسجلت بالغلط، أو فيه أوردرات للشريك مش متسجلة؟

**الحل المقترح:**
1. التحقيق في الفرق
2. إضافة validation عند POST `/settlements`: `amount <= max(pendingBalance, 0)`

---

## 🛑 Validation Gaps — السيرفر يقبل قيم فاسدة

### BUG-105 — `PUT /settings/cost-params` يقبل قيم سالبة

**Severity:** Critical (financial calculations broken)
```json
PUT /settings/cost-params
{"fuelPricePerLiter":-10,"fuelConsumptionPer100Km":-5,"hourlyRate":-100,"depreciationPerKm":-1}
→ HTTP 200 ✅ "تم تحديث الإعدادات بنجاح"
```
**التأثير:** كل حسابات `/orders/calculate-price` و worth-score بتطلع غلط (ممكن سالبة).
**الحل:** `[Range(0.01, ...)]` على كل الحقول.

---

### BUG-083 — `POST /payment-requests` يقبل amount سالب

**Severity:** Critical (financial)
```json
POST /payment-requests
{"amount":-100,"paymentPurpose":0,"paymentMethod":0,"description":"x"}
→ 201 Created with amount:-100
```
**التأثير:** لو الأدمن مرّر بدون مراجعة → عكس القيمة في الـ ledger.
**الحل:** `[Range(0.01, ...)]` على amount.

---

### BUG-080 — `POST /savings-circles` يقبل قيم مالية سالبة

**Severity:** Critical
```json
{"monthlyAmount":-500, "durationMonths":-1, "minHealthScore":-5}
→ 201 Created
```
**الحل:** `[Range(1, ...)]` على monthlyAmount/durationMonths، `[Range(0,100)]` على minHealthScore.

---

### BUG-091 — `POST /vehicles` يقبل قيم مستحيلة

**Severity:** Major
```json
{"vehicleType":99, "plateNumber":"", "year":3000, "currentMileageKm":-100, "fuelConsumptionPer100Km":-1, "fuelPricePerLiter":-1}
→ 201 Created (كل القيم محفوظة كما هي)
```
**التأثير:** Year 3000 يكسر UI sorting، negative mileage يكسر حسابات الصيانة، vehicleType=99 يكسر أي switch على الـ enum.
**الحل:**
- `[Required]` + min length على `plateNumber`
- `[Range(1990, currentYear+1)]` على year
- `[Range(0, ...)]` على mileage و fuel
- `Enum.IsDefined` على vehicleType

---

### BUG-090 — `POST /profile/expenses` يقبل amount سالب + date في 2099

**Severity:** Major
```json
{"amount":-50, "date":"2099-01-01"}
→ 201 Created
```
**التأثير:** يكسر تقارير المصاريف والـ daily/weekly/monthly aggregations.
**الحل:** `[Range(0.01, ...)]` على amount، رفض تواريخ بعد اليوم بأكتر من يوم.

---

### BUG-087/088 — `PUT /profile` يقبل email غلط + vehicleType=99 + threshold سالب

**Severity:** Major
```json
{"email":"not-an-email", "vehicleType":99, "cashAlertThreshold":-100}
→ 200 OK (محفوظة)
```
**التأثير:** Email notifications هتفشل، vehicle features هتكسر، تنبيه الكاش هيفضل شغّال أو متعطّل دائماً.
**الحل:** `[EmailAddress]`, enum validation, `[Range(0, ...)]`.

---

### BUG-086 — `POST /profile/emergency-contacts` يقبل phone و relationship فاضيين

**Severity:** Major
```json
{"name":"تست", "phone":"", "relationship":""}
→ 201 Created
```
**التأثير:** جهة الطوارئ بدون رقم تليفون لا قيمة لها.
**الحل:** `[Required]` + phone regex على phone، `[Required]` على relationship.

---

### BUG-072/073 — `POST /road-reports` يقبل enums خارج النطاق + إحداثيات مستحيلة

**Severity:** Major
```json
{"reportType":99, "severity":99, "latitude":1000, "longitude":-1000}
→ 201 Created
```
**التأثير:** Map clients اللي بتعمل switch على الـ enum هتفشل، البلاغات في إحداثيات مستحيلة هتلوّث الـ nearby query.
**الحل:** `Enum.IsDefined` validation، `[Range(-90,90)]` و `[Range(-180,180)]` على coordinates.

---

### BUG-071 — `POST /colleague-radar/location` يقبل lat=9999

**Severity:** Major
```json
{"latitude":9999, "longitude":-9999} → 200
```
**التأثير:** يلوّث الـ nearby drivers query ويكسر map distance calculations.
**الحل:** `[Range(-90,90)]` و `[Range(-180,180)]`.

---

## 🔵 Schema/Swagger Mismatches (Swagger ≠ Server)

### BUG-014 — `POST /auth/register-device`
- **Swagger:** `{token: string, platform: string}`
- **السيرفر:** يطلب `platform` كـ enum integer (0,1,...)
- يردّ 400 لو الـ body فلات بـ `platform: "android"`

### BUG-033 — `POST /auth/refresh-token`
- **Swagger:** `{refreshToken}`
- **السيرفر:** يطلب الحقل اسمه `Token`

### BUG-015 — `GET /config/check-version`
- **Swagger:** query param `version`
- **السيرفر:** يطلب `currentVersion`

### BUG-101 — `POST /privacy/delete-data`
- **Swagger:** `{reason}`
- **السيرفر:** يطلب `RequestType` غير موثّق

### BUG-102 — `POST /webhooks`
- **Swagger:** `{url, events, secret}`
- **السيرفر:** يطلب `Name` غير موثّق

### BUG-103 — `POST /sync/resolve-conflict`
- **Swagger:** `{entityId, resolution}`
- **السيرفر:** يطلب `EntityType` غير موثّق

### BUG-031/032 — `POST /auth/reset-password` و `/auth/change-password`
- **Swagger:** بدون `ConfirmPassword`
- **السيرفر:** يطلبه

### BUG-X — `POST /auth/account/confirm-deletion`
- **Swagger:** `{otpCode}`
- **السيرفر:** يطلب الحقل اسمه `confirmationCode`

---

## 🟠 External Provider Issues (Map)

### BUG-013/022/023 — Map endpoints معطّلة

| Endpoint | السلوك |
|---|---|
| `GET /map/geocode?address=Cairo` | بيرد `data:[]` دائماً (Provider: OpenRouteService) |
| `GET /map/reverse-geocode` لوسط القاهرة | 404 "لم يتم العثور على عنوان" |
| `GET /map/distance` | 400 "تعذر حساب المسافة" |

**السبب المحتمل:** OpenRouteService API key مش مضبوط أو quota انتهت.

---

## ⚪ Stubs ("قيد التطوير")

7 endpoints بترد HTTP 400 برسالة "قيد التطوير":
- `POST /api/v1/profile/subscription/upgrade`
- `GET /api/v1/invoices/{id}/pdf`
- `GET /api/v1/partner/dashboard`
- `GET /api/v1/partner/orders`
- `GET /api/v1/partner/stats`
- `GET /api/v1/partner/settlements`
- `GET /api/v1/partner/invoices`

**ملاحظة:** الأنسب يكون status code = 501 Not Implemented بدل 400. الـ partner/* لو مفيش Partner App مخطط، يفضل تتشال من Swagger.

---

## 🟢 Response Quality Issues (Minor)

### BUG-027 — `POST/PUT /parking` يهمل حقول
**Endpoint:** `POST /api/v1/parking`, `PUT /api/v1/parking/{id}`
**Description:** Request بيبعت `paidAmount, isShared, notes` لكن response مش بيرجعهم. السيرفر إما مش بيحفظهم أو الـ DTO response ناقصة.

### BUG-028 — `PUT /parking/{id}` يزوّد `usageCount` كل update
**Description:** Calling PUT 3 مرات بنفس البيانات → usageCount = 1 → 2 → 3. الـ counter ده المفروض يزيد لما السواق يستخدم المكان فعلاً، مش لما يعدّل بياناته.

### BUG-019 — Timestamps inconsistent
بعض الردود بتحط `Z` (UTC) وبعضها بدون. مثلاً `startTime` في POST shifts/start فيها Z، في GET shifts/current بدونها.

### BUG-035 — `/orders/bulk` يقول "نجح" حتى لو فشل الكل
**Description:** Response: `{successfulImports:0, failedImports:1, message:"تم استيراد الطلبات بنجاح"}`. الرسالة لازم تتغيّر حسب النتيجة.

### BUG-036 — `/orders/bulk` format غير موثّق
الـ rawText محتاج أجزاء مفصولة بـ `|` لكن Swagger مش بيقول الـ format.

### BUG-037 — `/orders/{id}/transfer` response فيها null
```json
{
  "orderNumber": null,
  "fromDriverName": null,
  "toDriverName": null,
  "deepLinkToken": null
}
```
كل الحقول المهمة null. UI مش هيعرف يعرض التفاصيل بعد التحويل.

### BUG-039 — `/orders/{id}/swap-address` ناقصة `timeDifferenceMinutes` و `costDifference`
بيحسب `distanceDifferenceKm` بس. الباقي null.

### BUG-055 — `POST /customers/{id}/rate` لا يحفظ tag flags
Request: `quickResponse:true, clearAddress:true, ...` → Response: `positiveTags:[], negativeTags:[]`.

### BUG-056 — `POST /chat/conversations` مع `initialMessage`
Response: `lastMessage: null` لكن `lastMessageAt` set. UI يعرض وقت بدون نص.

### BUG-057 — Chat messages: `senderName` دائماً null
UI يعرض فقاعات بدون اسم المرسل.

### BUG-058 — `/customers/{id}/engagement` يرجع `daysSinceLastOrder: -1` بدل null
UI يعرض "-1 أيام من آخر تواصل".

### BUG-059 — `/addresses/search` schema mismatch
Swagger يعرّف `Page/PageSize` (بيوحي بـ pagination)، لكن response array مسطّح بدون `items/totalCount`.

### BUG-060 — `/addresses/autocomplete` بيرجع `[]` دائماً
حتى لعناوين موجودة في النظام (تم إنشاؤها بـ `POST /addresses`).

### BUG-093 — Response format inconsistency
بعض mutations ترجع `data: true` (boolean)، تانية ترجع DTO، تالتة ترجع `null`. Mobile clients بتفشل في deserialization.

### BUG-094 — `/referrals/apply` status codes inconsistent
- Fake code → 404
- Own code → 400
- Empty code → 400

كلهم validation failures، لازم يكونوا 400.

---

## 📊 الملخص النهائي

| Category | Total | Fixed | Still Open |
|---|---|---|---|
| **P0 Critical (Aggregation/Math)** | 11 | 11 | 0 ✅ |
| **P0 Critical (Financial reconciliation)** | 2 | 0 | 2 |
| **Validation gaps** | 11 | 0 | 11 |
| **Schema/Swagger mismatches** | 8 | 0 | 8 |
| **External provider (Map)** | 3 | 0 | 3 |
| **Stubs ("قيد التطوير")** | 7 | 0 | 7 |
| **Response quality** | 13 | 1 | 12 |

---

## 🎯 الأولوية المقترحة للباك إند

### Phase 1 — حرج (يومين)
1. BUG-003 — `cashOnHand` يتنزل بالتسويات
2. BUG-004 — التحقيق في `pendingBalance: -500`
3. BUG-105, BUG-083, BUG-080 — رفض القيم المالية السالبة

### Phase 2 — Validation شاملة (3 أيام)
5. إضافة `[Range]`, `[Required]`, `[EmailAddress]`, `Enum.IsDefined` على كل DTOs (BUG-071, 072, 073, 086, 087, 088, 090, 091)

### Phase 3 — Swagger/Schema (يومين)
6. إصلاح كل الـ schema mismatches (BUG-014, 015, 031, 032, 033, 101, 102, 103)
7. توحيد response formats (BUG-093)
8. Stubs → status code 501 + إخفاء من Swagger لو مش جاهزة

### Phase 4 — Response polish (3 أيام)
9. Fields ناقصة في responses (BUG-027, 037, 039, 055, 056, 057)
10. Status code consistency (BUG-058, 094)
11. Map provider integration (BUG-013, 022, 023)

---

**انتهى التقرير**
