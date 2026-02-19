# KNEX Ticket Flow

## Overview
The ticket lifecycle involves two apps (Client + Attendant) communicating via a shared backend. The client requests valet service, and the attendant processes each stage.

## Ticket Statuses (in order)

| Status | Set By | Description |
|--------|--------|-------------|
| `Arrival` | Client | Client submits vehicle info, ticket created. PIN generated for valet verification. |
| `Processing-Arrival` | Attendant | Attendant verifies PIN + captures vehicle photos. Car is being taken to parking. |
| `Parked` | Attendant | Attendant assigns parking spot + key locker slot. Car is safely parked. |
| `Departure` | Client | Client requests pick up via long-press button. |
| `Departed` | Backend | Set by `/setToDeparture` endpoint (attendant-initiated). Not used by client flow. |
| `Processing` | Backend | Generic processing status — used by backend when attendant confirms departure. Treated as departure-in-progress by client. |
| `Processing-Departure` | Attendant | Attendant is retrieving the car. |
| `Completed` | Attendant | Car delivered to client. Tip/payment flow begins. |
| `Cancelled` | Client/Attendant | Ticket cancelled. Only available during Arrival. |

## Client App Screens by Status

### Arrival
- **Screen**: TicketScreen
- **Shows**: PIN + barcode, PIN refresh countdown (30s cycle), Cancel Ticket button
- **Behavior**: PIN regenerates every 30s via `generatePINandTicket` endpoint. Polls `getLatestTicket` every 5s.

### Processing-Arrival
- **Screen**: TicketScreen
- **Shows**: Ticket card with parking icon ("Your car is safely parked" placeholder), "Your valet is parking your car..." message
- **Hidden**: PIN, barcode, refresh timer, Cancel button
- **Behavior**: PIN polling stops. Status polling continues.

### Parked
- **Screen**: TicketScreen
- **Shows**: Ticket card with parking icon ("Your car is safely parked"), "Hold to Request Pick Up" button (long-press + haptic feedback)
- **Hidden**: PIN, barcode, refresh timer, Cancel button

### Departure (Waiting for attendant)
- **Screen**: TicketScreen (stays here, does NOT go to timer yet)
- **Shows**: Ticket card with car icon ("Pick up requested"), spinner + "Waiting for your valet..." + "Your pick up request has been sent"
- **Behavior**: Polls for Processing-Departure status. Once attendant confirms, routes to timer screen.

### Processing-Departure / Departed (Valet on the way)
- **Screen**: TicketTimerScreen
- **Shows**: "On The Way" title, "Your valet is bringing your car" subtitle, elapsed parking time, car icon
- **Behavior**: Polls for Completed status.

### Completed
- **Screen**: TicketCompletedScreen
- **Shows**: Animated checkmark, ticket summary card (ticket #, status, start time, PIN), "Tip Your Valet" button, "Back to Home" button
- **Tip Flow**: Opens `TipBottomSheet` with preset amounts ($3/$5/$10/$20) + custom input. Submits via `setTicketTip` endpoint.
- **Tip Presets**: Currently hardcoded in `AppConstants.tipPresets`. TODO: Replace with backend endpoint when available.
- **Back to Home**: Clears `activeTicketProvider` and navigates to `/home`

### Cancelled
- **Behavior**: Routes back to HomeScreen

## Attendant App Flow

### 1. Arrival → Processing-Arrival
- Attendant taps Arrival tile on dashboard
- Selects ticket from list
- **Step 1**: Verify PIN (PinVerificationBottomSheet)
- **Step 2**: Capture vehicle photos (PhotoCaptureBottomSheet) — inside + outside
- Calls `processArrivalWithPhotos` API
- Returns to Home dashboard on success

### 2. Processing-Arrival → Parked
- Attendant taps Processing tile on dashboard
- Selects ticket from list
- **Step 1**: Enter parking spot number (ParkFormBottomSheet)
- **Step 2**: Enter key locker slot
- Calls `parkTicket` API
- Returns to Home dashboard on success

### 3. Parked → Departure (Client-initiated)
- Client long-presses "Hold to Request Pick Up"
- Client calls `setTicketStatus` with `status: "Departure"`
- Attendant sees ticket appear in Departure tile

### 4. Departure → Processing-Departure
- Attendant taps Departure tile
- Selects ticket, taps process
- Calls `processTicket` API (attendant is retrieving the car)

### 5. Processing-Departure → Completed
- Attendant delivers car to client
- Calls `completeTicket` API
- Client sees TicketCompletedScreen with tip/payment options

## API Endpoints Used

| Endpoint | Used By | Purpose |
|----------|---------|---------|
| `generatePINandTicket` | Client | Creates ticket + generates PIN (during Arrival) |
| `getLatestTicket` | Client | Polls for status updates |
| `setTicketStatus` | Client | Requests departure (status → "Departure") |
| `setToCancelForClient` | Client | Cancels ticket |
| `setTicketTip` | Client | Submits tip amount |
| `getTicketList` | Attendant | Fetches tickets by status for dashboard counts |

## Known Backend Quirks
- `/setToDeparture` sets status to `"Departed"` (not `"Departure"`). Client uses `setTicketStatus` instead for correct status.
- `pin` field may come back as integer from some endpoints — `Ticket.fromJson` uses `.toString()` to handle both.
- `getLatestTicket` returns data as `List<dynamic>` — client unwraps first element.
- Attendant `getTicketList` does not query for `"Departed"` status, only `"Departure"`.
