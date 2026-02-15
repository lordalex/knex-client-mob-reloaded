/// All KNEX backend API endpoint path constants.
///
/// Every endpoint is POST-only. Authenticated endpoints wrap the payload in
/// `{ "idToken": "<JWT>", "data": { ...payload } }` -- this wrapping is
/// handled by [AuthInterceptor] in `api_interceptors.dart`.
class Endpoints {
  Endpoints._();

  // ---------------------------------------------------------------------------
  // User Client
  // ---------------------------------------------------------------------------
  static const String createUserClient = '/createUserClient';
  static const String getUserClient = '/getUserClient';
  static const String updateUserClient = '/updateUserClient';
  static const String searchUserClient = '/searchUserClient';
  static const String deleteUserClient = '/deleteUserClient';
  static const String listUserClients = '/listUserClients';

  // ---------------------------------------------------------------------------
  // Vehicle
  // ---------------------------------------------------------------------------
  static const String createVehicle = '/createVehicle';
  static const String listVehicles = '/listVehicles';
  static const String getVehicle = '/getVehicle';
  static const String updateVehicle = '/updateVehicle';
  static const String deleteVehicle = '/deleteVehicle';

  // ---------------------------------------------------------------------------
  // Ticket
  // ---------------------------------------------------------------------------
  static const String createTicket = '/createTicket';
  static const String generatePINandTicket = '/generatePINandticket';
  static const String getLatestTicket = '/getLatestTicket';
  static const String getTicketList = '/getTicketList';
  static const String getTicketByPIN = '/getTicketByPIN';
  static const String setToDeparture = '/setToDeparture';
  static const String setToCancelForClient = '/setToCancelForClient';
  static const String setTicketTip = '/setTicketTip';
  static const String setTicketStatus = '/setTicketStatus';
  static const String updateTicket = '/updateTicket';
  static const String updateTicketPhotos = '/updateTicketPhotos';

  // ---------------------------------------------------------------------------
  // Location
  // ---------------------------------------------------------------------------
  static const String getLocations = '/getLocations';

  // ---------------------------------------------------------------------------
  // Provisional Ticket (no auth required)
  // ---------------------------------------------------------------------------
  static const String createProvisionalTicket = '/createProvisionalTicket';
  static const String linkUserClientToTicketByProvisionalPIN =
      '/linkUserClientToTicketByProvisionalPIN';
  static const String setToDepartureCasual = '/setToDepartureCasual';

  // ---------------------------------------------------------------------------
  // Payment
  // ---------------------------------------------------------------------------
  static const String confirmPayment = '/confirmPayment';

  // ---------------------------------------------------------------------------
  // Search & Enum
  // ---------------------------------------------------------------------------
  static const String search = '/search';
  static const String getEnum = '/get-enum';
}
