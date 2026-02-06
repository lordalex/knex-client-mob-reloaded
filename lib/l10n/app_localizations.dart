import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
    Locale('fr'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'KNEX'**
  String get appName;

  /// No description provided for @tabHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get tabHome;

  /// No description provided for @tabProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get tabProfile;

  /// No description provided for @buttonSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get buttonSave;

  /// No description provided for @buttonCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get buttonCancel;

  /// No description provided for @buttonRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get buttonRetry;

  /// No description provided for @buttonOk.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get buttonOk;

  /// No description provided for @buttonSignIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get buttonSignIn;

  /// No description provided for @buttonSignUp.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get buttonSignUp;

  /// No description provided for @buttonSignOut.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get buttonSignOut;

  /// No description provided for @buttonSubmit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get buttonSubmit;

  /// No description provided for @buttonCreateAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get buttonCreateAccount;

  /// No description provided for @buttonForgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get buttonForgotPassword;

  /// No description provided for @buttonRequestValet.
  ///
  /// In en, this message translates to:
  /// **'Request Valet'**
  String get buttonRequestValet;

  /// No description provided for @buttonCall.
  ///
  /// In en, this message translates to:
  /// **'Call'**
  String get buttonCall;

  /// No description provided for @buttonRetrieveMyCar.
  ///
  /// In en, this message translates to:
  /// **'Retrieve My Car'**
  String get buttonRetrieveMyCar;

  /// No description provided for @buttonCancelRequest.
  ///
  /// In en, this message translates to:
  /// **'Cancel Request'**
  String get buttonCancelRequest;

  /// No description provided for @buttonGoHome.
  ///
  /// In en, this message translates to:
  /// **'Go Home'**
  String get buttonGoHome;

  /// No description provided for @buttonPay.
  ///
  /// In en, this message translates to:
  /// **'Pay'**
  String get buttonPay;

  /// No description provided for @buttonSaveInfo.
  ///
  /// In en, this message translates to:
  /// **'Save Info'**
  String get buttonSaveInfo;

  /// No description provided for @buttonSignInWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Sign in with Google'**
  String get buttonSignInWithGoogle;

  /// No description provided for @buttonSignInWithApple.
  ///
  /// In en, this message translates to:
  /// **'Sign in with Apple'**
  String get buttonSignInWithApple;

  /// No description provided for @screenTitleLogin.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get screenTitleLogin;

  /// No description provided for @screenTitleHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get screenTitleHome;

  /// No description provided for @screenTitleProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get screenTitleProfile;

  /// No description provided for @screenTitleProfileCreate.
  ///
  /// In en, this message translates to:
  /// **'Create Profile'**
  String get screenTitleProfileCreate;

  /// No description provided for @screenTitleSiteDetails.
  ///
  /// In en, this message translates to:
  /// **'Site Details'**
  String get screenTitleSiteDetails;

  /// No description provided for @screenTitleAddCars.
  ///
  /// In en, this message translates to:
  /// **'Add Vehicle'**
  String get screenTitleAddCars;

  /// No description provided for @screenTitleTicket.
  ///
  /// In en, this message translates to:
  /// **'Your Ticket'**
  String get screenTitleTicket;

  /// No description provided for @screenTitleTicketTimer.
  ///
  /// In en, this message translates to:
  /// **'Valet Timer'**
  String get screenTitleTicketTimer;

  /// No description provided for @screenTitleTicketCompleted.
  ///
  /// In en, this message translates to:
  /// **'Ticket Completed'**
  String get screenTitleTicketCompleted;

  /// No description provided for @screenTitlePay.
  ///
  /// In en, this message translates to:
  /// **'Payment'**
  String get screenTitlePay;

  /// No description provided for @screenTitleAddCreditCard.
  ///
  /// In en, this message translates to:
  /// **'Add Credit Card'**
  String get screenTitleAddCreditCard;

  /// No description provided for @screenTitleFavorites.
  ///
  /// In en, this message translates to:
  /// **'My Favorites'**
  String get screenTitleFavorites;

  /// No description provided for @screenTitleHistory.
  ///
  /// In en, this message translates to:
  /// **'Service History'**
  String get screenTitleHistory;

  /// No description provided for @screenTitleListConfig.
  ///
  /// In en, this message translates to:
  /// **'List Settings'**
  String get screenTitleListConfig;

  /// No description provided for @screenTitleChangeLanguage.
  ///
  /// In en, this message translates to:
  /// **'Change Language'**
  String get screenTitleChangeLanguage;

  /// No description provided for @screenTitleNavShell.
  ///
  /// In en, this message translates to:
  /// **'KNEX'**
  String get screenTitleNavShell;

  /// No description provided for @labelEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get labelEmail;

  /// No description provided for @labelPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get labelPassword;

  /// No description provided for @labelConfirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get labelConfirmPassword;

  /// No description provided for @labelFirstName.
  ///
  /// In en, this message translates to:
  /// **'First Name'**
  String get labelFirstName;

  /// No description provided for @labelLastName.
  ///
  /// In en, this message translates to:
  /// **'Last Name'**
  String get labelLastName;

  /// No description provided for @labelPhone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get labelPhone;

  /// No description provided for @labelAddress.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get labelAddress;

  /// No description provided for @labelCity.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get labelCity;

  /// No description provided for @labelState.
  ///
  /// In en, this message translates to:
  /// **'State'**
  String get labelState;

  /// No description provided for @labelZipCode.
  ///
  /// In en, this message translates to:
  /// **'Zip Code'**
  String get labelZipCode;

  /// No description provided for @labelMake.
  ///
  /// In en, this message translates to:
  /// **'Make'**
  String get labelMake;

  /// No description provided for @labelModel.
  ///
  /// In en, this message translates to:
  /// **'Model'**
  String get labelModel;

  /// No description provided for @labelColor.
  ///
  /// In en, this message translates to:
  /// **'Color'**
  String get labelColor;

  /// No description provided for @labelLicensePlate.
  ///
  /// In en, this message translates to:
  /// **'License Plate'**
  String get labelLicensePlate;

  /// No description provided for @labelMakeAndModel.
  ///
  /// In en, this message translates to:
  /// **'Make and Model'**
  String get labelMakeAndModel;

  /// No description provided for @labelNotes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get labelNotes;

  /// No description provided for @labelCustomNotes.
  ///
  /// In en, this message translates to:
  /// **'Custom Notes'**
  String get labelCustomNotes;

  /// No description provided for @labelTip.
  ///
  /// In en, this message translates to:
  /// **'Tip'**
  String get labelTip;

  /// No description provided for @labelTipAmount.
  ///
  /// In en, this message translates to:
  /// **'Tip Amount'**
  String get labelTipAmount;

  /// No description provided for @labelCardNumber.
  ///
  /// In en, this message translates to:
  /// **'Card Number'**
  String get labelCardNumber;

  /// No description provided for @labelExpiryDate.
  ///
  /// In en, this message translates to:
  /// **'Expiry Date'**
  String get labelExpiryDate;

  /// No description provided for @labelCvv.
  ///
  /// In en, this message translates to:
  /// **'CVV'**
  String get labelCvv;

  /// No description provided for @labelDistance.
  ///
  /// In en, this message translates to:
  /// **'Distance'**
  String get labelDistance;

  /// No description provided for @labelPrice.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get labelPrice;

  /// No description provided for @labelCompany.
  ///
  /// In en, this message translates to:
  /// **'Company'**
  String get labelCompany;

  /// No description provided for @labelStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get labelStatus;

  /// No description provided for @labelTicketNumber.
  ///
  /// In en, this message translates to:
  /// **'Ticket Number'**
  String get labelTicketNumber;

  /// No description provided for @labelPin.
  ///
  /// In en, this message translates to:
  /// **'PIN'**
  String get labelPin;

  /// No description provided for @labelVersion.
  ///
  /// In en, this message translates to:
  /// **'v1.0'**
  String get labelVersion;

  /// No description provided for @messageLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get messageLoading;

  /// No description provided for @messageNoResults.
  ///
  /// In en, this message translates to:
  /// **'No results found'**
  String get messageNoResults;

  /// No description provided for @messageErrorOccurred.
  ///
  /// In en, this message translates to:
  /// **'An error occurred'**
  String get messageErrorOccurred;

  /// No description provided for @messageNoFavorites.
  ///
  /// In en, this message translates to:
  /// **'You have no favorite sites yet'**
  String get messageNoFavorites;

  /// No description provided for @messageNoHistory.
  ///
  /// In en, this message translates to:
  /// **'No service history yet'**
  String get messageNoHistory;

  /// No description provided for @messageProfileIncomplete.
  ///
  /// In en, this message translates to:
  /// **'Please complete your profile'**
  String get messageProfileIncomplete;

  /// No description provided for @messagePasswordResetSent.
  ///
  /// In en, this message translates to:
  /// **'Password reset email sent'**
  String get messagePasswordResetSent;

  /// No description provided for @messagePasswordsDontMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get messagePasswordsDontMatch;

  /// No description provided for @messageFieldRequired.
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get messageFieldRequired;

  /// No description provided for @messageInvalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email address'**
  String get messageInvalidEmail;

  /// No description provided for @messageSignOutConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to sign out?'**
  String get messageSignOutConfirm;

  /// No description provided for @messageValetDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'By requesting valet service, you agree to our terms of service and acknowledge that KNEX is not liable for any damages.'**
  String get messageValetDisclaimer;

  /// No description provided for @messageTicketActive.
  ///
  /// In en, this message translates to:
  /// **'You have an active valet ticket'**
  String get messageTicketActive;

  /// No description provided for @messageTicketCompleted.
  ///
  /// In en, this message translates to:
  /// **'Your valet service is complete'**
  String get messageTicketCompleted;

  /// No description provided for @messagePaymentSuccess.
  ///
  /// In en, this message translates to:
  /// **'Payment successful'**
  String get messagePaymentSuccess;

  /// No description provided for @messagePaymentFailed.
  ///
  /// In en, this message translates to:
  /// **'Payment failed'**
  String get messagePaymentFailed;

  /// No description provided for @messageSaveSuccess.
  ///
  /// In en, this message translates to:
  /// **'Information saved successfully'**
  String get messageSaveSuccess;

  /// No description provided for @valetLocationNearYou.
  ///
  /// In en, this message translates to:
  /// **'Valet locations available near you'**
  String get valetLocationNearYou;

  /// No description provided for @primarySite.
  ///
  /// In en, this message translates to:
  /// **'Primary Site'**
  String get primarySite;

  /// No description provided for @myFavoriteSites.
  ///
  /// In en, this message translates to:
  /// **'My favorite sites'**
  String get myFavoriteSites;

  /// No description provided for @profileSettings.
  ///
  /// In en, this message translates to:
  /// **'Profile Settings'**
  String get profileSettings;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @helpCenter.
  ///
  /// In en, this message translates to:
  /// **'Help Center'**
  String get helpCenter;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark mode'**
  String get darkMode;

  /// No description provided for @notificationSettings.
  ///
  /// In en, this message translates to:
  /// **'Notification Settings'**
  String get notificationSettings;

  /// No description provided for @logOut.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get logOut;

  /// No description provided for @distanceUnitMetric.
  ///
  /// In en, this message translates to:
  /// **'Metric (km)'**
  String get distanceUnitMetric;

  /// No description provided for @distanceUnitImperial.
  ///
  /// In en, this message translates to:
  /// **'Imperial (mi)'**
  String get distanceUnitImperial;

  /// No description provided for @sortOrderAscending.
  ///
  /// In en, this message translates to:
  /// **'Ascending'**
  String get sortOrderAscending;

  /// No description provided for @sortOrderDescending.
  ///
  /// In en, this message translates to:
  /// **'Descending'**
  String get sortOrderDescending;

  /// No description provided for @sortByDistance.
  ///
  /// In en, this message translates to:
  /// **'Distance'**
  String get sortByDistance;

  /// No description provided for @sortByName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get sortByName;

  /// No description provided for @sortByPrice.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get sortByPrice;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageSpanish.
  ///
  /// In en, this message translates to:
  /// **'Spanish'**
  String get languageSpanish;

  /// No description provided for @languageFrench.
  ///
  /// In en, this message translates to:
  /// **'French'**
  String get languageFrench;

  /// No description provided for @ticketStatusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get ticketStatusPending;

  /// No description provided for @ticketStatusAccepted.
  ///
  /// In en, this message translates to:
  /// **'Accepted'**
  String get ticketStatusAccepted;

  /// No description provided for @ticketStatusInProgress.
  ///
  /// In en, this message translates to:
  /// **'In Progress'**
  String get ticketStatusInProgress;

  /// No description provided for @ticketStatusCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get ticketStatusCompleted;

  /// No description provided for @ticketStatusCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get ticketStatusCancelled;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
