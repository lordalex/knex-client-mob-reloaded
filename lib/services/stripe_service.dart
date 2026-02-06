import 'dart:developer' as developer;

import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

import '../config/app_constants.dart';

/// Service for processing Stripe payments via Firebase Cloud Functions.
///
/// Payment intents are created server-side via `initStripeTestPayment` /
/// `initStripePayment` Cloud Functions. This service handles the client-side
/// flow of presenting the Stripe payment sheet and confirming payment.
class StripeService {
  /// Initializes the Stripe SDK with the publishable key.
  Future<void> initialize() async {
    Stripe.publishableKey = AppConstants.stripePublishableKey;
    Stripe.merchantIdentifier = 'merchant.com.knex';
    await Stripe.instance.applySettings();
  }

  /// Processes a payment for the given amount.
  ///
  /// [amount] - payment amount in cents.
  /// [currency] - ISO 4217 currency code (e.g. "usd").
  /// [ticketId] - the ticket this payment is for.
  ///
  /// Returns the payment intent ID on success, or null on failure/cancellation.
  Future<String?> processPayment({
    required int amount,
    required String currency,
    required String ticketId,
  }) async {
    try {
      // 1. Create payment intent via Cloud Function
      final callable = FirebaseFunctions.instance.httpsCallable(
        'initStripeTestPayment',
      );
      final result = await callable.call<Map<String, dynamic>>({
        'amount': amount,
        'currency': currency,
        'ticketId': ticketId,
      });

      final data = result.data;
      final clientSecret = data['clientSecret'] as String?;
      if (clientSecret == null) return null;

      // 2. Initialize payment sheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: AppConstants.merchantDisplayName,
        ),
      );

      // 3. Present payment sheet
      await Stripe.instance.presentPaymentSheet();

      return data['paymentIntentId'] as String?;
    } on StripeException catch (e) {
      developer.log(
        'Stripe error: ${e.error.localizedMessage}',
        name: 'StripeService',
      );
      return null;
    } catch (e) {
      developer.log('Payment error: $e', name: 'StripeService');
      return null;
    }
  }

  /// Processes a tip payment for a completed valet ticket.
  ///
  /// Returns the payment intent ID on success, or null on failure/cancellation.
  Future<String?> processTip({
    required int amount,
    required String currency,
    required String ticketId,
  }) async {
    return processPayment(
      amount: amount,
      currency: currency,
      ticketId: ticketId,
    );
  }
}
