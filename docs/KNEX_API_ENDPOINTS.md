# KNEX API Endpoints — Tested & Verified

**Base URL:** `https://client.knex-app.xyz/api`
**Method:** All endpoints use **POST**
**Auth:** Authenticated endpoints wrap the payload in `{ "idToken": "<Firebase JWT>", "data": { ...payload } }`

---

## /searchUserClient

**Purpose:** Search for a user client profile by email.

**Request payload:**
```json
{
  "email": "la@lordalexand.co"
}
```

**Response format:** Standard envelope
```json
{
  "status": {
    "status": "VALID",
    "result": "READ",
    "message": "Documents read."
  },
  "data": [
    {
      "id": "Hun3hNH4t7ypVSjKTsA7",
      "uid": "0YQlwSn8PkMPiE6Bm3Jym55Qru63",
      "email": "la@lordalexand.co",
      "firstName": "LordAled",
      "lastName": "Leon",
      "phoneNumber": "5142950724",
      "photo": "<base64 JPEG string>",
      "address": "8617 St Denis",
      "zipCode": "...",
      "state": "...",
      "city": "..."
    }
  ]
}
```

**Notes:**
- `status.status` is `"VALID"` (not `"success"`)
- `data` is a **List** (array), even for a single result
- Profile fields may appear in both camelCase (`firstName`) and lowercase (`firstname`) variants
- `photo` field contains a full base64-encoded JPEG with EXIF data

---

## /getLocations

**Purpose:** Fetch all valet locations available to the user.

**Request payload:**
```json
{
  "userClientId": "<profile id>"
}
```

**Response format:** **Raw List** (no status/data envelope)
```json
[
  {
    "id": "wvPCzGA3J7UJwpUhmI1H",
    "name": "Valet Pros Inc.",
    "address": "191 Museum Cir, Cape Canaveral, ...",
    "company": {
      "name": "Valet Pros Inc."
    },
    "photos": ["https://..."],
    "bio": "...",
    "price": 10.00,
    "currency": "USD",
    "phone": "...",
    "coordinates": {
      "lat": 28.xxxx,
      "lng": -80.xxxx
    }
  }
]
```

**Notes:**
- Returns a **raw JSON array**, NOT wrapped in `{ status, data }` envelope
- `company` is a **Map/Object** with a `name` field (not a plain string)
- `photos` is an array of URL strings
- `coordinates` is an object with `lat`/`lng` keys
- `price` is a number (double)

---

## /createVehicle

**Purpose:** Create a new vehicle record for the user.

**Request payload:**
```json
{
  "user_client_id": "Hun3hNH4t7ypVSjKTsA7",
  "vehicle_make": "Kia",
  "vehicle_model": "Soul",
  "license_plate": "ABCDHD",
  "color": "Grey"
}
```

**Response format:** Standard envelope
```json
{
  "status": {
    "status": "VALID",
    "result": "CREATE",
    "message": "Doc pvb28fSyaLaI5LaskHp4 created."
  },
  "data": {
    "id": "pvb28fSyaLaI5LaskHp4",
    "user_client_id": "Hun3hNH4t7ypVSjKTsA7",
    "vehicle_make": "Kia",
    "vehicle_model": "Soul",
    "license_plate": "ABCDHD",
    "color": "Grey",
    "email": "la@lordalexand.co",
    "createdBy": "la@lordalexand.co",
    "createdAt": {
      "_seconds": 1770403756,
      "_nanoseconds": 966000000
    },
    "updatedAt": {
      "_seconds": 1770403756,
      "_nanoseconds": 966000000
    }
  }
}
```

**Notes:**
- Uses snake_case field names (`vehicle_make`, `license_plate`, etc.)
- `data` is a **single object** (not a list)
- Backend auto-adds `email`, `createdBy`, `createdAt`, `updatedAt`
- Timestamps are Firestore timestamp objects (`{ _seconds, _nanoseconds }`)

---

## /generatePINandticket

**Purpose:** Generate a valet parking ticket with a unique PIN code. This creates the ticket on the backend and returns the PIN.

**Request payload:**
```json
{
  "email": "la@lordalexand.co",
  "vehicle": "pvb28fSyaLaI5LaskHp4",
  "location": "wvPCzGA3J7UJwpUhmI1H",
  "notes": "This is a note to the attendant."
}
```

**Response format:** **Non-standard** (no status/data envelope)
```json
{
  "pin": "348669"
}
```

**Notes:**
- Returns **only** `{ "pin": "<6-digit string>" }` — no `status` or `data` wrapper
- `email` is the user's email (not `user_client` ID)
- `vehicle` is the vehicle document ID
- `location` is the location document ID
- `notes` is optional
- The PIN is a 6-digit numeric string
- The ticket is created server-side but the full ticket object is NOT returned

---

## /getLatestTicket

**Purpose:** Fetch the most recent active ticket for a user client.

**Request payload:**
```json
{
  "email": "la@lordalexand.co"
}
```

**Response format (on success):** Standard envelope (expected, not yet verified with success)
```json
{
  "status": {
    "status": "...",
    "result": "READ",
    "message": "..."
  },
  "data": {
    "id": "...",
    "ticket_number": "...",
    "user_client_id": "...",
    "vehicle_id": "...",
    "location_id": "...",
    "status": "Arrived",
    "pin": "348669",
    "notes": "...",
    "created_at": "...",
    "updated_at": "..."
  }
}
```

**Error response (400):**
```json
{
  "status": 400,
  "error": "Client with email la@lordalexand.co not found",
  "trace": [
    "[+0ms] Trace started: getLatestTicket",
    "[+0ms] Searching for user client with email: la@lordalexand.co",
    "[+131ms] User client not found"
  ]
}
```

**Notes:**
- Backend searches by **email** (the `trace` confirms: "Searching for user client with email:")
- Error response has `status` as an **integer** (400), not the standard status object
- Currently returns 400 for our test user — the backend's user_client collection may not have the user registered (separate from the profile/auth system)
- The success response format has not been verified in testing

---

## /getTicketByPIN

**Purpose:** Fetch a ticket by its PIN code.

**Request payload (expected):**
```json
{
  "pin": "348669"
}
```

**Response:** Returns **400 — "not implemented"**
```json
{
  "status": 400,
  "error": "not implemented",
  "trace": [
    "[+0ms] Trace started: makeKnexApiRequest: getTicketByPIN",
    "[+0ms] Making POST request to https://api.knex-app.xyz/api/getTicketByPIN"
  ]
}
```

**Notes:**
- This endpoint is **NOT IMPLEMENTED** on the backend
- The backend proxies to `https://api.knex-app.xyz/api/getTicketByPIN` which returns "not implemented"

---

## /createTicket (deprecated — use /generatePINandticket instead)

**Purpose:** Create a ticket directly (without PIN generation).

**Request payload:**
```json
{
  "user_client": "<profile id>",
  "vehicle": "<vehicle id>",
  "location": "<location id>",
  "status": "Arrived",
  "notes": "optional notes"
}
```

**Error response (400):**
```json
{
  "status": 400,
  "error": "Failed to insert document: Value for argument \"data\" is not a valid Firestore document. Cannot use \"undefined\" as a Firestore value (found in field \"user_client\").",
  "trace": [...]
}
```

**Notes:**
- Field names are `user_client`, `vehicle`, `location` (NOT `user_client_id`, `vehicle_id`, `location_id`)
- This endpoint errored with "undefined" Firestore value — the backend may expect different field names or the endpoint may not be designed for client use
- Recommend using `/generatePINandticket` instead, which handles ticket + PIN creation together

---

## Common Response Patterns

### Standard Envelope (most endpoints)
```json
{
  "status": {
    "status": "VALID" | "success",
    "result": "READ" | "CREATE" | "UPDATE" | "DELETE",
    "message": "Human-readable message"
  },
  "data": <object or array>
}
```

### Error Response
```json
{
  "status": 400,
  "error": "Error description",
  "trace": ["[+0ms] step1", "[+Nms] step2"]
}
```

### Auth Error (401)
```json
{
  "error": "Invalid ID Token",
  "trace": [
    "[+0ms] Trace started: htmlServerImplementation",
    "[+Nms] Request received: POST /api/<endpoint>",
    "[+Nms] Protected endpoint, verifying token",
    "[+Nms] Invalid ID token"
  ]
}
```

### Key Observations
1. `status.status` can be either `"VALID"` or `"success"` — always check case-insensitively
2. Some endpoints return `data` as a **List** (e.g. `/searchUserClient`) even for single results
3. `/getLocations` returns a **raw array** with no envelope at all
4. `/generatePINandticket` returns a **raw object** `{"pin": "..."}` with no envelope
5. Error responses use `status` as an **integer** (HTTP code), not the standard status object
6. Firestore timestamps are objects: `{ "_seconds": int, "_nanoseconds": int }`
7. Auth token expiry returns 401 with message "Your session has expired. Please sign in again."
