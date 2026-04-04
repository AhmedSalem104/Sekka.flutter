# Sekka - Push Notifications Specification
### Document Version: 1.0
### Date: 2026-04-02

---

## Overview

This document describes all automatic push notifications that should be sent to the delivery driver.
All notifications are triggered by **backend scheduled jobs or threshold checks** — not by another user.

The driver is the **only user** of the mobile app. There is no admin panel or other party interacting through the app.

---

## Notification Delivery

| Item | Detail |
|---|---|
| **Channel** | Firebase Cloud Messaging (FCM) |
| **Platform** | Android + iOS |
| **Language** | Arabic (RTL) |
| **Fallback** | Store in DB + show in-app notification center if push fails |
| **User Control** | Driver can enable/disable each category from Settings |

---

## Notification Categories

### Category 1: Financial Alerts (تنبيهات مالية)

---

#### 1.1 Cash Threshold Exceeded (الكاش تعدى الحد)

| Field | Value |
|---|---|
| **ID** | `CASH_THRESHOLD_EXCEEDED` |
| **Priority** | High |
| **Trigger** | `cash_on_hand >= cash_alert_threshold` |
| **When to check** | After every order delivery that involves cash payment |
| **Repeat** | Once when threshold is first crossed, then reminder every **3 hours** if not settled |
| **Title** | `تنبيه: الكاش معاك تعدى الحد` |
| **Body** | `عندك {cash_on_hand} جنيه كاش. الحد المسموح {threshold} جنيه. سوّي دلوقتي عشان أمانك.` |
| **Action** | Deep link to Settlements screen |
| **Data Payload** | `{ "type": "CASH_THRESHOLD_EXCEEDED", "cash_on_hand": 1500.0, "threshold": 1000.0 }` |
| **Stop Condition** | Driver makes a settlement that brings `cash_on_hand < threshold` |

---

#### 1.2 Settlement Reminder (تذكير تسوية مع شريك)

| Field | Value |
|---|---|
| **ID** | `SETTLEMENT_REMINDER` |
| **Priority** | Medium |
| **Trigger** | Partner balance > 0 AND no settlement with this partner in the last **48 hours** |
| **When to check** | Daily scheduled job at **10:00 PM** |
| **Repeat** | Once per day per partner until settled |
| **Title** | `تذكير: عندك رصيد مع {partner_name}` |
| **Body** | `رصيدك مع {partner_name} وصل {balance} جنيه. آخر تسوية كانت من {days_since} يوم.` |
| **Action** | Deep link to Partner Balance screen with `partner_id` |
| **Data Payload** | `{ "type": "SETTLEMENT_REMINDER", "partner_id": "xxx", "partner_name": "...", "balance": 750.0, "days_since_last_settlement": 3 }` |
| **Stop Condition** | Driver settles with the partner |

---

#### 1.3 Daily Summary (ملخص يومي)

| Field | Value |
|---|---|
| **ID** | `DAILY_SUMMARY` |
| **Priority** | Low |
| **Trigger** | Scheduled — end of day |
| **When to check** | Daily at **11:00 PM** (or after last delivery + 2 hours, whichever is earlier) |
| **Repeat** | Once per day — skip if driver had 0 orders today |
| **Title** | `ملخص يومك` |
| **Body** | `وصّلت {delivered_count} طلب | كسبت {earnings} جنيه | صافي {net_profit} جنيه` |
| **Action** | Deep link to Wallet screen |
| **Data Payload** | |

```json
{
  "type": "DAILY_SUMMARY",
  "date": "2026-04-02",
  "total_orders": 15,
  "delivered": 13,
  "failed": 2,
  "earnings": 450.0,
  "commissions": 67.5,
  "expenses": 80.0,
  "net_profit": 302.5,
  "cash_on_hand": 1200.0,
  "distance_km": 45.3,
  "time_worked_minutes": 480
}
```

---

#### 1.4 Fine or Deduction (غرامة أو خصم)

| Field | Value |
|---|---|
| **ID** | `FINE_DEDUCTED` |
| **Priority** | High |
| **Trigger** | New transaction with `type = Fine (5)` or negative `Adjustment (8)` is created |
| **When to check** | Immediately when transaction is inserted |
| **Repeat** | Once per transaction |
| **Title** | `تم خصم {amount} جنيه من رصيدك` |
| **Body** | `{description}. رصيدك الحالي {balance_after} جنيه.` |
| **Action** | Deep link to Wallet screen, filtered to transaction detail |
| **Data Payload** | `{ "type": "FINE_DEDUCTED", "transaction_id": "xxx", "amount": 50.0, "description": "...", "balance_after": 400.0 }` |

---

#### 1.5 Bonus Received (مكافأة)

| Field | Value |
|---|---|
| **ID** | `BONUS_RECEIVED` |
| **Priority** | Low |
| **Trigger** | New transaction with `type = Bonus (4)` or `Tip (2)` |
| **When to check** | Immediately when transaction is inserted |
| **Repeat** | Once per transaction |
| **Title** | `حصلت على {amount} جنيه {type_name}!` |
| **Body** | `رصيدك الحالي {balance_after} جنيه. كمّل شغل حلو!` |
| **Action** | Deep link to Wallet screen |
| **Data Payload** | `{ "type": "BONUS_RECEIVED", "transaction_id": "xxx", "amount": 25.0, "transaction_type": "tip", "balance_after": 425.0 }` |

---

### Category 2: Order Reminders (تذكيرات الطلبات)

---

#### 2.1 Retry Pending Reminder (طلب محتاج إعادة محاولة)

| Field | Value |
|---|---|
| **ID** | `RETRY_PENDING_REMINDER` |
| **Priority** | High |
| **Trigger** | Order status = `retryPending (9)` for more than **1 hour** |
| **When to check** | Every **1 hour** scan for retryPending orders |
| **Repeat** | Every **2 hours** until driver takes action (max 3 reminders per order) |
| **Title** | `طلب #{order_number} مستني إعادة محاولة` |
| **Body** | `طلب {customer_name} في {delivery_address} فشل ومحتاج تحاول تاني.` |
| **Action** | Deep link to Order Detail screen with `order_id` |
| **Data Payload** | `{ "type": "RETRY_PENDING_REMINDER", "order_id": "xxx", "order_number": "1234", "customer_name": "...", "delivery_address": "...", "failed_at": "2026-04-02T14:30:00Z", "fail_reason": "customer_unavailable" }` |
| **Stop Condition** | Order status changes from `retryPending` |

---

#### 2.2 Recurring Order Tomorrow (طلب متكرر بكرة)

| Field | Value |
|---|---|
| **ID** | `RECURRING_ORDER_TOMORROW` |
| **Priority** | Medium |
| **Trigger** | Active recurring order has next execution = tomorrow |
| **When to check** | Daily at **9:00 PM** |
| **Repeat** | Once per recurring order per day |
| **Title** | `بكرة عندك {count} طلب متكرر` |
| **Body** | `طلبات من {partner_names} هتتفعل بكرة الصبح. جهّز نفسك!` |
| **Action** | Deep link to Orders List screen, filtered to recurring |
| **Data Payload** | |

```json
{
  "type": "RECURRING_ORDER_TOMORROW",
  "date": "2026-04-03",
  "count": 3,
  "orders": [
    {
      "order_id": "xxx",
      "order_number": "1234",
      "partner_name": "...",
      "pickup_address": "...",
      "estimated_time": "08:00"
    }
  ]
}
```

---

#### 2.3 Stale Orders (طلبات واقفة من فترة)

| Field | Value |
|---|---|
| **ID** | `STALE_ORDERS` |
| **Priority** | Medium |
| **Trigger** | Orders with status `accepted (1)` and no status change in the last **4 hours** during working hours (8AM-11PM) |
| **When to check** | Every **4 hours** during working hours |
| **Repeat** | Once, then again after **8 hours** if still stale |
| **Title** | `عندك {count} طلب واقف من فترة` |
| **Body** | `{count} طلب في حالة "مقبول" من أكتر من {hours} ساعة. ابدأ توصيل أو ألغيهم.` |
| **Action** | Deep link to Orders List screen, filtered to `accepted` |
| **Data Payload** | `{ "type": "STALE_ORDERS", "count": 3, "oldest_accepted_at": "2026-04-02T08:00:00Z", "order_ids": ["xxx", "yyy", "zzz"] }` |
| **Stop Condition** | All accepted orders move to next status |

---

### Category 3: Driver Wellness (صحة السائق)

---

#### 3.1 Break Suggestion (اقتراح استراحة)

| Field | Value |
|---|---|
| **ID** | `BREAK_SUGGESTION` |
| **Priority** | Medium |
| **Trigger** | Driver has been actively delivering for **3+ hours** without a break |
| **When to check** | Track time since last break end (or shift start). Check every **30 minutes**. |
| **Repeat** | Once after 3 hours, then every **1 hour** if still no break (max 3 reminders) |
| **Title** | `وقت استراحة!` |
| **Body** | `شغال من {hours} ساعة من غير وقفة. خد {suggested_minutes} دقيقة راحة عشان تكمّل بنشاط.` |
| **Action** | Deep link to Break screen |
| **Data Payload** | `{ "type": "BREAK_SUGGESTION", "hours_since_last_break": 3.5, "suggested_duration_minutes": 15, "urgency": 3, "nearby_spots": ["كافيه المحطة", "جنينة الحي"] }` |
| **Stop Condition** | Driver starts a break |

---

### Category 4: Achievements (إنجازات)

---

#### 4.1 Milestone Reached (إنجاز جديد)

| Field | Value |
|---|---|
| **ID** | `MILESTONE_REACHED` |
| **Priority** | Low |
| **Trigger** | `total_deliveries` reaches a milestone number |
| **Milestones** | 10, 25, 50, 100, 250, 500, 1000, 2500, 5000 |
| **When to check** | After each successful delivery |
| **Repeat** | Once per milestone |
| **Title** | `مبروك! وصلت {milestone} توصيلة!` |
| **Body** | `{milestone_message}` |
| **Action** | Deep link to Badge screen |
| **Data Payload** | `{ "type": "MILESTONE_REACHED", "milestone": 100, "total_deliveries": 100, "level": 3, "message": "..." }` |

**Milestone Messages:**

| Milestone | Message |
|---|---|
| 10 | `بداية حلوة! كمّل على كده` |
| 25 | `ماشي صح! ربع المية الأولى` |
| 50 | `نص الطريق للمية! شغل جامد` |
| 100 | `أول مية توصيلة! أنت محترف` |
| 250 | `ربع ألف! أنت نجم سِكّة` |
| 500 | `نص ألف توصيلة! أسطورة` |
| 1000 | `ألف توصيلة! أنت وحش الطريق` |
| 2500 | `أنت من أفضل سواقين سِكّة!` |
| 5000 | `5000 توصيلة! أنت أسطورة حقيقية` |

---

#### 4.2 Level Up (ترقية مستوى)

| Field | Value |
|---|---|
| **ID** | `LEVEL_UP` |
| **Priority** | Low |
| **Trigger** | Driver's `level` field increases |
| **When to check** | After level recalculation (post-delivery or daily) |
| **Repeat** | Once per level change |
| **Title** | `ترقية! وصلت المستوى {new_level}` |
| **Body** | `أداءك ممتاز ووصلت المستوى {new_level}. كمّل!` |
| **Action** | Deep link to Badge screen |
| **Data Payload** | `{ "type": "LEVEL_UP", "previous_level": 2, "new_level": 3, "total_deliveries": 150, "average_rating": 4.8 }` |

---

## Notification Settings (إعدادات الإشعارات)

The driver should be able to toggle each category on/off from the Settings screen:

```json
{
  "notification_preferences": {
    "financial_alerts": true,
    "settlement_reminders": true,
    "daily_summary": true,
    "order_reminders": true,
    "break_suggestions": true,
    "achievements": true
  },
  "quiet_hours": {
    "enabled": false,
    "start": "23:00",
    "end": "07:00"
  }
}
```

**Quiet Hours:** When enabled, all **Low** and **Medium** priority notifications are queued and delivered after quiet hours end. **High** priority notifications (cash threshold, fines) are always delivered immediately.

---

## Backend Implementation Notes

### Required Scheduled Jobs

| Job | Schedule | Description |
|---|---|---|
| `SettlementReminderJob` | Daily 10:00 PM | Check partner balances, send reminders |
| `DailySummaryJob` | Daily 11:00 PM | Compute daily stats, send summary |
| `RecurringOrderReminderJob` | Daily 9:00 PM | Check tomorrow's recurring orders |
| `StaleOrdersJob` | Every 4 hours (8AM-11PM) | Find stale accepted orders |
| `RetryPendingJob` | Every 1 hour | Find forgotten retry-pending orders |
| `BreakSuggestionJob` | Every 30 minutes | Check active drivers without breaks |

### Event-Driven Triggers (No Scheduled Job Needed)

| Event | Notification |
|---|---|
| Cash payment received on delivery | Check `CASH_THRESHOLD_EXCEEDED` |
| Transaction inserted with type Fine/Adjustment | Send `FINE_DEDUCTED` |
| Transaction inserted with type Bonus/Tip | Send `BONUS_RECEIVED` |
| Order delivered successfully | Check `MILESTONE_REACHED` + `LEVEL_UP` |
| Level field updated | Send `LEVEL_UP` |

### API Endpoints Needed

```
PUT  /api/drivers/{id}/notification-preferences
GET  /api/drivers/{id}/notification-preferences
POST /api/drivers/{id}/notifications/{notification_id}/read
POST /api/drivers/{id}/notifications/read-all
GET  /api/drivers/{id}/notifications?page={page}&size={size}
```

### FCM Payload Structure

```json
{
  "to": "{driver_fcm_token}",
  "notification": {
    "title": "...",
    "body": "...",
    "sound": "default",
    "click_action": "FLUTTER_NOTIFICATION_CLICK"
  },
  "data": {
    "type": "NOTIFICATION_TYPE_ID",
    "action": "deep_link_route",
    "...": "notification-specific fields"
  },
  "android": {
    "priority": "high",
    "notification": {
      "channel_id": "sekka_{category}"
    }
  },
  "apns": {
    "payload": {
      "aps": {
        "sound": "default",
        "badge": 1
      }
    }
  }
}
```

### Android Notification Channels

| Channel ID | Name | Importance |
|---|---|---|
| `sekka_financial` | تنبيهات مالية | High |
| `sekka_orders` | تذكيرات الطلبات | Default |
| `sekka_wellness` | صحة السائق | Low |
| `sekka_achievements` | إنجازات | Low |

---

## Summary Table

| # | Notification ID | Category | Trigger Type | Priority |
|---|---|---|---|---|
| 1 | `CASH_THRESHOLD_EXCEEDED` | Financial | Event + Repeat | High |
| 2 | `SETTLEMENT_REMINDER` | Financial | Scheduled | Medium |
| 3 | `DAILY_SUMMARY` | Financial | Scheduled | Low |
| 4 | `FINE_DEDUCTED` | Financial | Event | High |
| 5 | `BONUS_RECEIVED` | Financial | Event | Low |
| 6 | `RETRY_PENDING_REMINDER` | Orders | Scheduled | High |
| 7 | `RECURRING_ORDER_TOMORROW` | Orders | Scheduled | Medium |
| 8 | `STALE_ORDERS` | Orders | Scheduled | Medium |
| 9 | `BREAK_SUGGESTION` | Wellness | Scheduled | Medium |
| 10 | `MILESTONE_REACHED` | Achievements | Event | Low |
| 11 | `LEVEL_UP` | Achievements | Event | Low |

**Total: 11 notification types | 6 scheduled jobs | 5 event-driven triggers**
