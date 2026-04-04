# Colleague Radar — Backend Requirements Spec
### Document Version: 1.0
### Date: 2026-04-04

---

## Overview

Colleague Radar allows drivers to see nearby colleagues and request/offer help.
This document describes what the **backend needs to add or modify** to support the full feature.

---

## 1. Help Request — Extended Fields

### Current POST /api/v1/colleague-radar/help-requests Body:

```json
{
  "title": "string",
  "description": "string",
  "latitude": 0,
  "longitude": 0,
  "helpType": "string"
}
```

### Required Changes:

```json
{
  "title": "string",
  "description": "string",
  "latitude": 0,
  "longitude": 0,
  "helpType": "string",
  "orderId": "uuid | null",
  "driverPhone": "string"
}
```

| New Field | Type | Required | Description |
|---|---|---|---|
| `orderId` | UUID, nullable | No | If helpType = "Order", this is the order the driver needs help delivering |
| `driverPhone` | string | Yes | Auto-sent from app — so the responder can call the driver |

---

### Current Response:

```json
{
  "id": "uuid",
  "driverId": "uuid",
  "driverName": "",
  "title": "string",
  "description": "string",
  "latitude": 0,
  "longitude": 0,
  "helpType": "Other",
  "status": "Pending",
  "responderId": null,
  "responderName": null,
  "createdAt": "datetime",
  "resolvedAt": null
}
```

### Required Changes to Response:

```json
{
  "id": "uuid",
  "driverId": "uuid",
  "driverName": "فاطمة محمد",
  "driverPhone": "+201148623985",
  "title": "كاوتش باظ",
  "description": "على طريق الأوتوستراد عند محطة الوقود",
  "latitude": 30.0444,
  "longitude": 31.2357,
  "helpType": "Tire",
  "status": "Pending",
  "distanceKm": 2.3,
  "orderId": null,
  "orderSummary": null,
  "responderId": null,
  "responderName": null,
  "responderPhone": null,
  "createdAt": "2026-04-04T20:50:18Z",
  "resolvedAt": null
}
```

| New Field | Type | Description |
|---|---|---|
| `driverPhone` | string | Phone of the driver who created the request |
| `distanceKm` | double | Distance from the requesting driver (calculated server-side) |
| `orderId` | UUID, nullable | The order that needs to be delivered (if helpType = "Order") |
| `orderSummary` | object, nullable | Summary of the order (see below) |
| `responderPhone` | string, nullable | Phone of the driver who accepted — shown to request creator |

### `orderSummary` object (only when orderId is not null):

```json
{
  "orderNumber": "1234",
  "customerName": "أحمد سالم",
  "deliveryAddress": "15 شارع التحرير، الدقي",
  "amount": 150.0,
  "paymentMethod": 0,
  "customerPhone": "+201012345678"
}
```

---

## 2. driverName Must Be Populated

Currently `driverName` is returned as empty string `""`. 
The backend **must** populate `driverName` from the driver's profile when creating or returning help requests.

---

## 3. Help Types — Standardized Enum

The `helpType` field should accept and return these standard values:

| Value | Arabic Label | Description |
|---|---|---|
| `Mechanical` | عطلة ميكانيكية | Engine, battery, etc. |
| `Tire` | كاوتش | Flat tire |
| `Fuel` | بنزين | Out of fuel |
| `Order` | محتاج حد يكمّل أوردر | Need another driver to complete a delivery |
| `Accident` | حادث | Traffic accident |
| `Other` | تاني | Anything else |

If the client sends an unknown value, default to `Other`.

---

## 4. Push Notifications for Nearby Drivers

### When to Send:

| Event | Notification |
|---|---|
| New help request created | Notify all online drivers within **10 km** radius |
| Help request accepted (responded) | Notify the **request creator** that someone is coming |
| Help request resolved | Notify the **responder** that it's resolved |

### Notification Payload:

#### New Help Request (to nearby drivers):

```json
{
  "notification": {
    "title": "زميلك محتاج مساعدة!",
    "body": "{driverName} — {title} ({distanceKm} كم منك)"
  },
  "data": {
    "type": "HELP_REQUEST_NEARBY",
    "requestId": "uuid",
    "helpType": "Tire",
    "latitude": 30.0444,
    "longitude": 31.2357,
    "distanceKm": 2.3
  }
}
```

#### Request Accepted (to request creator):

```json
{
  "notification": {
    "title": "حد قبل يساعدك!",
    "body": "{responderName} في الطريق ليك"
  },
  "data": {
    "type": "HELP_REQUEST_ACCEPTED",
    "requestId": "uuid",
    "responderName": "محمد علي",
    "responderPhone": "+201098765432"
  }
}
```

#### Request Resolved (to responder):

```json
{
  "notification": {
    "title": "المشكلة اتحلت",
    "body": "{driverName} بيقولك شكراً!"
  },
  "data": {
    "type": "HELP_REQUEST_RESOLVED",
    "requestId": "uuid"
  }
}
```

---

## 5. Respond Endpoint — Return Responder Phone

### Current: `POST /help-requests/{id}/respond`

Response should include `responderPhone` so the request creator can call:

```json
{
  "isSuccess": true,
  "data": {
    "id": "uuid",
    "status": "Accepted",
    "responderId": "uuid",
    "responderName": "محمد علي",
    "responderPhone": "+201098765432",
    "...": "rest of fields"
  }
}
```

---

## 6. Nearby Drivers — Required Response Shape

### Current: `GET /colleague-radar/nearby?latitude=x&longitude=y&radiusKm=5`

Response `data` array items should have:

```json
{
  "driverId": "uuid",
  "driverName": "أحمد سالم",
  "latitude": 30.05,
  "longitude": 31.24,
  "distanceKm": 1.8,
  "vehicleType": 0,
  "isOnline": true
}
```

**Note:** Only return drivers who:
- Are **online** (isOnline = true)
- Have **updated their location** in the last **30 minutes**
- Are **not the requesting driver** themselves

---

## 7. Location Update Endpoint (if not exists)

For nearby to work, drivers must periodically update their location.

If not already implemented, backend needs:

```
POST /api/v1/colleague-radar/location
```

```json
{
  "latitude": 30.0444,
  "longitude": 31.2357
}
```

The mobile app will call this every **5 minutes** when the app is in the foreground.

---

## 8. Auto-Expire Help Requests

Help requests should **auto-expire** after **2 hours** if not resolved.

| Condition | Action |
|---|---|
| Status = `Pending` for > 2 hours | Set status to `Expired` |
| Status = `Accepted` for > 4 hours without resolve | Set status to `Expired` |

Add a scheduled job or use a database trigger.

New status value: `Expired`

---

## 9. Prevent Self-Response

Backend should **reject** `POST /help-requests/{id}/respond` if `responderId == driverId` (driver can't respond to their own request).

Return:
```json
{
  "isSuccess": false,
  "message": "مش ممكن ترد على طلبك أنت",
  "errors": null
}
```

---

## 10. SignalR Hub (Optional — Real-time)

If you want real-time updates without polling, add a `ColleagueRadarHub`:

### Events:

| Event | Direction | Description |
|---|---|---|
| `NewHelpRequest` | Server → Client | New help request in driver's radius |
| `HelpRequestAccepted` | Server → Client | Someone accepted the driver's request |
| `HelpRequestResolved` | Server → Client | Request was resolved |
| `NearbyDriversUpdated` | Server → Client | Nearby drivers list changed |

This is **optional** — push notifications cover the critical cases. SignalR is for real-time UI updates when the app is open.

---

## Summary of Changes

| # | Change | Type | Priority |
|---|---|---|---|
| 1 | Add `orderId`, `driverPhone` to help request create | Modify endpoint | High |
| 2 | Add `orderSummary`, `distanceKm`, `responderPhone` to response | Modify response | High |
| 3 | Populate `driverName` from profile | Bug fix | High |
| 4 | Push notifications for nearby help requests | New feature | High |
| 5 | Push notification when request accepted | New feature | High |
| 6 | Push notification when request resolved | New feature | Medium |
| 7 | Validate nearby drivers response shape | Verify | Medium |
| 8 | Location update endpoint (if missing) | New endpoint | High |
| 9 | Auto-expire requests after 2 hours | Scheduled job | Medium |
| 10 | Prevent self-response | Validation | Low |
| 11 | SignalR hub (optional) | New feature | Low |
