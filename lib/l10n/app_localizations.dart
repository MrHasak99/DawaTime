import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

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
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'DawaTime'**
  String get appTitle;

  /// No description provided for @addMedication.
  ///
  /// In en, this message translates to:
  /// **'Add New Medication'**
  String get addMedication;

  /// No description provided for @saveMedication.
  ///
  /// In en, this message translates to:
  /// **'Save Medication'**
  String get saveMedication;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUp;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// No description provided for @accept.
  ///
  /// In en, this message translates to:
  /// **'I accept the '**
  String get accept;

  /// No description provided for @terms.
  ///
  /// In en, this message translates to:
  /// **'Terms & Conditions'**
  String get terms;

  /// No description provided for @privacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacy;

  /// No description provided for @mustAccept.
  ///
  /// In en, this message translates to:
  /// **'You must accept the Terms & Conditions and Privacy Policy'**
  String get mustAccept;

  /// No description provided for @passwordsDontMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDontMatch;

  /// No description provided for @verificationSent.
  ///
  /// In en, this message translates to:
  /// **'Verification email sent, please check your inbox'**
  String get verificationSent;

  /// No description provided for @signupFailed.
  ///
  /// In en, this message translates to:
  /// **'Sign up failed, please try again'**
  String get signupFailed;

  /// No description provided for @welcomeToDawaTime.
  ///
  /// In en, this message translates to:
  /// **'Welcome to DawaTime!'**
  String get welcomeToDawaTime;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @dontHaveAccountSignUp.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? Sign Up'**
  String get dontHaveAccountSignUp;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// No description provided for @resetPassword.
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get resetPassword;

  /// No description provided for @pleaseEnterYourEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email'**
  String get pleaseEnterYourEmail;

  /// No description provided for @enterYourPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get enterYourPassword;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @send.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get send;

  /// No description provided for @appGuide.
  ///
  /// In en, this message translates to:
  /// **'App Guide'**
  String get appGuide;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @termsAndConditions.
  ///
  /// In en, this message translates to:
  /// **'Terms & Conditions'**
  String get termsAndConditions;

  /// No description provided for @addNewMedication.
  ///
  /// In en, this message translates to:
  /// **'Add New Medication'**
  String get addNewMedication;

  /// No description provided for @unitOfMeasurement.
  ///
  /// In en, this message translates to:
  /// **'Unit Of Measurement'**
  String get unitOfMeasurement;

  /// No description provided for @dosage.
  ///
  /// In en, this message translates to:
  /// **'Dosage'**
  String get dosage;

  /// No description provided for @every.
  ///
  /// In en, this message translates to:
  /// **'every'**
  String get every;

  /// No description provided for @frequency.
  ///
  /// In en, this message translates to:
  /// **'Frequency'**
  String get frequency;

  /// No description provided for @currentAmount.
  ///
  /// In en, this message translates to:
  /// **'Current Amount'**
  String get currentAmount;

  /// No description provided for @pickNotificationTime.
  ///
  /// In en, this message translates to:
  /// **'Pick Notification Time'**
  String get pickNotificationTime;

  /// No description provided for @notifyAt.
  ///
  /// In en, this message translates to:
  /// **'Notify At'**
  String get notifyAt;

  /// No description provided for @pickScheduleStartDate.
  ///
  /// In en, this message translates to:
  /// **'Pick Schedule Start Date'**
  String get pickScheduleStartDate;

  /// No description provided for @startDate.
  ///
  /// In en, this message translates to:
  /// **'Start Date'**
  String get startDate;

  /// No description provided for @pleaseFillAllFields.
  ///
  /// In en, this message translates to:
  /// **'Please fill all required fields'**
  String get pleaseFillAllFields;

  /// No description provided for @dosageFrequencyGreaterThanZero.
  ///
  /// In en, this message translates to:
  /// **'Dosage and frequency must be greater than zero'**
  String get dosageFrequencyGreaterThanZero;

  /// No description provided for @pleasePickScheduleStartDate.
  ///
  /// In en, this message translates to:
  /// **'Please pick a schedule start date'**
  String get pleasePickScheduleStartDate;

  /// No description provided for @couldNotSaveMedication.
  ///
  /// In en, this message translates to:
  /// **'Could not save medication. Please try again'**
  String get couldNotSaveMedication;

  /// No description provided for @youCanOnlyHaveUpTo12Medications.
  ///
  /// In en, this message translates to:
  /// **'You can only have up to 12 medications'**
  String get youCanOnlyHaveUpTo12Medications;

  /// No description provided for @openAppRegularlyForNotifications.
  ///
  /// In en, this message translates to:
  /// **'Open the app regularly to ensure medication reminders continue'**
  String get openAppRegularlyForNotifications;

  /// No description provided for @notificationContinuityWarning.
  ///
  /// In en, this message translates to:
  /// **'To keep receiving reminders, please open DawaTime at least once a week'**
  String get notificationContinuityWarning;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back,'**
  String get welcomeBack;

  /// No description provided for @noMedicationsFound.
  ///
  /// In en, this message translates to:
  /// **'No medications found'**
  String get noMedicationsFound;

  /// No description provided for @undo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undo;

  /// No description provided for @editMedication.
  ///
  /// In en, this message translates to:
  /// **'Edit Medication'**
  String get editMedication;

  /// No description provided for @takeMedication.
  ///
  /// In en, this message translates to:
  /// **'Take {medication}'**
  String takeMedication(Object medication);

  /// No description provided for @didYouTakeYourMedication.
  ///
  /// In en, this message translates to:
  /// **'Did you take your {medication}?'**
  String didYouTakeYourMedication(Object medication);

  /// No description provided for @youreOutOfMedication.
  ///
  /// In en, this message translates to:
  /// **'You\'re out of {medication}!'**
  String youreOutOfMedication(Object medication);

  /// No description provided for @pleaseRefillYourMedication.
  ///
  /// In en, this message translates to:
  /// **'Please refill your {medication}'**
  String pleaseRefillYourMedication(Object medication);

  /// No description provided for @deleteMedication.
  ///
  /// In en, this message translates to:
  /// **'Delete Medication'**
  String get deleteMedication;

  /// No description provided for @areYouSureDeleteMedication.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete {medication}?'**
  String areYouSureDeleteMedication(Object medication);

  /// No description provided for @changeEmail.
  ///
  /// In en, this message translates to:
  /// **'Change Email'**
  String get changeEmail;

  /// No description provided for @resetPasswordButton.
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get resetPasswordButton;

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get deleteAccount;

  /// No description provided for @contactMe.
  ///
  /// In en, this message translates to:
  /// **'Contact Me'**
  String get contactMe;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @systemTheme.
  ///
  /// In en, this message translates to:
  /// **'System Default'**
  String get systemTheme;

  /// No description provided for @lightTheme.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get lightTheme;

  /// No description provided for @darkTheme.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get darkTheme;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @logOut.
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get logOut;

  /// No description provided for @areYouSureLogOut.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to log out?'**
  String get areYouSureLogOut;

  /// No description provided for @outOfStock.
  ///
  /// In en, this message translates to:
  /// **'Out of stock'**
  String get outOfStock;

  /// No description provided for @nextReminder.
  ///
  /// In en, this message translates to:
  /// **'Next reminder'**
  String get nextReminder;

  /// No description provided for @markedAsTaken.
  ///
  /// In en, this message translates to:
  /// **'Marked {medication} as taken!'**
  String markedAsTaken(Object medication);

  /// No description provided for @couldNotUpdateMedication.
  ///
  /// In en, this message translates to:
  /// **'Could not update your medication, please try again'**
  String get couldNotUpdateMedication;

  /// No description provided for @deleteAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get deleteAccountTitle;

  /// No description provided for @deleteAccountConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete your account?'**
  String get deleteAccountConfirm;

  /// No description provided for @writeYourMessageHere.
  ///
  /// In en, this message translates to:
  /// **'Write your message here...'**
  String get writeYourMessageHere;

  /// No description provided for @contactMeTitle.
  ///
  /// In en, this message translates to:
  /// **'Contact Me'**
  String get contactMeTitle;

  /// No description provided for @contactMeSent.
  ///
  /// In en, this message translates to:
  /// **'Message sent successfully!'**
  String get contactMeSent;

  /// No description provided for @contactMeFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to send message, please try again'**
  String get contactMeFailed;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @profileAndSettings.
  ///
  /// In en, this message translates to:
  /// **'Profile & Settings'**
  String get profileAndSettings;

  /// No description provided for @day.
  ///
  /// In en, this message translates to:
  /// **'day(s)'**
  String get day;

  /// No description provided for @timeToTakeMedication.
  ///
  /// In en, this message translates to:
  /// **'Time to take {medication}!'**
  String timeToTakeMedication(Object medication);

  /// No description provided for @medicationUpdated.
  ///
  /// In en, this message translates to:
  /// **'{medication} updated!'**
  String medicationUpdated(Object medication);

  /// No description provided for @reminderTakeMedication.
  ///
  /// In en, this message translates to:
  /// **'Reminder: Take your {medication}'**
  String reminderTakeMedication(Object medication);

  /// No description provided for @medicationDeleted.
  ///
  /// In en, this message translates to:
  /// **'{medication} deleted!'**
  String medicationDeleted(Object medication);

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'no'**
  String get no;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'ok'**
  String get ok;

  /// No description provided for @welcomeBody.
  ///
  /// In en, this message translates to:
  /// **'DawaTime helps you manage your medications and reminders with ease.'**
  String get welcomeBody;

  /// No description provided for @addMedicationTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Medications'**
  String get addMedicationTitle;

  /// No description provided for @addMedicationBody.
  ///
  /// In en, this message translates to:
  /// **'Tap the \"+\" button to add a new medication and set up reminders.'**
  String get addMedicationBody;

  /// No description provided for @editDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit & Delete'**
  String get editDeleteTitle;

  /// No description provided for @editDeleteBody.
  ///
  /// In en, this message translates to:
  /// **'Swipe right to edit or left to delete a medication from your list.'**
  String get editDeleteBody;

  /// No description provided for @notificationsBody.
  ///
  /// In en, this message translates to:
  /// **'You\'ll get notified when it\'s time to take your medication — even if the app is closed!'**
  String get notificationsBody;

  /// No description provided for @profileAndSettingsBody.
  ///
  /// In en, this message translates to:
  /// **'Manage your profile and app settings from the top right corner.'**
  String get profileAndSettingsBody;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @continueConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Continue?'**
  String get continueConfirmation;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// No description provided for @developed.
  ///
  /// In en, this message translates to:
  /// **'Developed By'**
  String get developed;

  /// No description provided for @developer.
  ///
  /// In en, this message translates to:
  /// **'Hamad AlKhalaf'**
  String get developer;

  /// No description provided for @appInfo.
  ///
  /// In en, this message translates to:
  /// **'App Info'**
  String get appInfo;

  /// No description provided for @light.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get light;

  /// No description provided for @dark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get dark;

  /// No description provided for @failedToLoadUserData.
  ///
  /// In en, this message translates to:
  /// **'Failed to load user data'**
  String get failedToLoadUserData;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @change.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get change;

  /// No description provided for @newEmail.
  ///
  /// In en, this message translates to:
  /// **'New Email'**
  String get newEmail;

  /// No description provided for @currentPassword.
  ///
  /// In en, this message translates to:
  /// **'Current Password'**
  String get currentPassword;

  /// No description provided for @emailChange.
  ///
  /// In en, this message translates to:
  /// **'Email Change Requested'**
  String get emailChange;

  /// No description provided for @verifyNewEmail.
  ///
  /// In en, this message translates to:
  /// **'A verification email has been sent to your new email address. Please verify it, then log in again with your new email'**
  String get verifyNewEmail;

  /// No description provided for @updateEmailFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to update email:'**
  String get updateEmailFailed;

  /// No description provided for @noUser.
  ///
  /// In en, this message translates to:
  /// **'No user is currently logged in'**
  String get noUser;

  /// No description provided for @sendEmail.
  ///
  /// In en, this message translates to:
  /// **'Send Email'**
  String get sendEmail;

  /// No description provided for @resetEmailSent.
  ///
  /// In en, this message translates to:
  /// **'Password reset email sent!'**
  String get resetEmailSent;

  /// No description provided for @resetEmailFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to send reset email:'**
  String get resetEmailFailed;

  /// No description provided for @enterPasswordTwice.
  ///
  /// In en, this message translates to:
  /// **'Please enter your password twice'**
  String get enterPasswordTwice;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @noUserEmail.
  ///
  /// In en, this message translates to:
  /// **'No email found for user'**
  String get noUserEmail;

  /// No description provided for @accountDeleted.
  ///
  /// In en, this message translates to:
  /// **'Account Deleted'**
  String get accountDeleted;

  /// No description provided for @accountDeletedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Your account has been deleted successfully'**
  String get accountDeletedSuccess;

  /// No description provided for @accountDeletedFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete user:'**
  String get accountDeletedFailed;

  /// No description provided for @mustBeLoggedIn.
  ///
  /// In en, this message translates to:
  /// **'You must be logged in to send a message'**
  String get mustBeLoggedIn;

  /// No description provided for @messageSent.
  ///
  /// In en, this message translates to:
  /// **'Message sent!'**
  String get messageSent;

  /// No description provided for @messageFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to send message:'**
  String get messageFailed;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Here\'s how to get started:'**
  String get getStarted;

  /// No description provided for @addMedicationBody2.
  ///
  /// In en, this message translates to:
  /// **'• Add your medications using the \"+\" button.\n'**
  String get addMedicationBody2;

  /// No description provided for @setReminders.
  ///
  /// In en, this message translates to:
  /// **'• Set reminders for each medication so you never miss a dose.\n'**
  String get setReminders;

  /// No description provided for @viewDetails.
  ///
  /// In en, this message translates to:
  /// **'• Tap a medication to view details.\n'**
  String get viewDetails;

  /// No description provided for @swipe.
  ///
  /// In en, this message translates to:
  /// **'• Swipe left to delete or right to edit a medication.\n'**
  String get swipe;

  /// No description provided for @checkReminders.
  ///
  /// In en, this message translates to:
  /// **'• Check your upcoming reminders on the home screen.\n'**
  String get checkReminders;

  /// No description provided for @manageProfile.
  ///
  /// In en, this message translates to:
  /// **'• Manage your profile and settings from the top right.\n'**
  String get manageProfile;

  /// No description provided for @medicationNotifications.
  ///
  /// In en, this message translates to:
  /// **'You\'ll receive notifications when it\'s time to take your medication — even if the app is closed!'**
  String get medicationNotifications;

  /// No description provided for @notification.
  ///
  /// In en, this message translates to:
  /// **'Notification'**
  String get notification;

  /// No description provided for @updateRequired.
  ///
  /// In en, this message translates to:
  /// **'Update Required'**
  String get updateRequired;

  /// No description provided for @pleaseUpdate.
  ///
  /// In en, this message translates to:
  /// **'A new version of the app is available, please update to continue'**
  String get pleaseUpdate;

  /// No description provided for @update.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get update;

  /// No description provided for @accessDenied.
  ///
  /// In en, this message translates to:
  /// **'Access Denied'**
  String get accessDenied;

  /// No description provided for @notAvailable.
  ///
  /// In en, this message translates to:
  /// **'This app is not available in your country'**
  String get notAvailable;

  /// No description provided for @failedUpdateCheck.
  ///
  /// In en, this message translates to:
  /// **'Failed to check for updates, please try again later'**
  String get failedUpdateCheck;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @gotIt.
  ///
  /// In en, this message translates to:
  /// **'Got it!'**
  String get gotIt;

  /// No description provided for @pleaseVerfiy.
  ///
  /// In en, this message translates to:
  /// **'Please verify your email before logging in'**
  String get pleaseVerfiy;

  /// No description provided for @noAccount.
  ///
  /// In en, this message translates to:
  /// **'No account found for this email, please sign up first'**
  String get noAccount;

  /// No description provided for @incorrectPassword.
  ///
  /// In en, this message translates to:
  /// **'Incorrect password, please try again'**
  String get incorrectPassword;

  /// No description provided for @invalidEmail.
  ///
  /// In en, this message translates to:
  /// **'The email address is not valid.'**
  String get invalidEmail;

  /// No description provided for @disabledAccount.
  ///
  /// In en, this message translates to:
  /// **'This account has been disabled, please contact support'**
  String get disabledAccount;

  /// No description provided for @loginFailed.
  ///
  /// In en, this message translates to:
  /// **'Login failed, please check your credentials and try again'**
  String get loginFailed;

  /// No description provided for @emailAlreadyRegistered.
  ///
  /// In en, this message translates to:
  /// **'This email is already registered, please use another email or log in'**
  String get emailAlreadyRegistered;

  /// No description provided for @emailInvalid.
  ///
  /// In en, this message translates to:
  /// **'The email address is not valid, please check and try again'**
  String get emailInvalid;

  /// No description provided for @weakPassword.
  ///
  /// In en, this message translates to:
  /// **'Your password is too weak, please use at least 6 characters'**
  String get weakPassword;

  /// No description provided for @emailMethod.
  ///
  /// In en, this message translates to:
  /// **'This sign up method is not enabled, please contact support'**
  String get emailMethod;

  /// No description provided for @friend.
  ///
  /// In en, this message translates to:
  /// **'Friend'**
  String get friend;

  /// No description provided for @viewProfile.
  ///
  /// In en, this message translates to:
  /// **'View Profile'**
  String get viewProfile;

  /// No description provided for @addMedicationFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to add medication:'**
  String get addMedicationFailed;

  /// No description provided for @allowSettings.
  ///
  /// In en, this message translates to:
  /// **'Please allow \"Schedule exact alarms\" in system settings'**
  String get allowSettings;

  /// No description provided for @openSettings.
  ///
  /// In en, this message translates to:
  /// **'Open Settings'**
  String get openSettings;

  /// No description provided for @scheduleMedicationFailure.
  ///
  /// In en, this message translates to:
  /// **'Failed to schedule notification:'**
  String get scheduleMedicationFailure;

  /// No description provided for @profileUpdated.
  ///
  /// In en, this message translates to:
  /// **'Profile updated!'**
  String get profileUpdated;

  /// No description provided for @updateFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to update:'**
  String get updateFailed;

  /// No description provided for @passwordEmail.
  ///
  /// In en, this message translates to:
  /// **'A password reset email will be sent to:'**
  String get passwordEmail;

  /// No description provided for @selectDaysOfWeek.
  ///
  /// In en, this message translates to:
  /// **'Days of the week'**
  String get selectDaysOfWeek;

  /// No description provided for @everyXDays.
  ///
  /// In en, this message translates to:
  /// **'Every X days'**
  String get everyXDays;

  /// No description provided for @timeToTakeMedicationNow.
  ///
  /// In en, this message translates to:
  /// **'Time to take {medication} now!'**
  String timeToTakeMedicationNow(Object medication);

  /// No description provided for @followUsOnInstagram.
  ///
  /// In en, this message translates to:
  /// **'Follow us on Instagram'**
  String get followUsOnInstagram;

  /// No description provided for @checkForUpdates.
  ///
  /// In en, this message translates to:
  /// **'Check for Updates'**
  String get checkForUpdates;

  /// No description provided for @checkingForUpdates.
  ///
  /// In en, this message translates to:
  /// **'Checking for updates...'**
  String get checkingForUpdates;

  /// No description provided for @upToDate.
  ///
  /// In en, this message translates to:
  /// **'App is up to date'**
  String get upToDate;

  /// No description provided for @lastChecked.
  ///
  /// In en, this message translates to:
  /// **'Last checked: {time}'**
  String lastChecked(Object time);

  /// No description provided for @refillReminder.
  ///
  /// In en, this message translates to:
  /// **'Refill Reminder'**
  String get refillReminder;

  /// No description provided for @refillReminderBody.
  ///
  /// In en, this message translates to:
  /// **'You have {amount} {type} of {medication} left. Time to refill!'**
  String refillReminderBody(Object amount, Object medication, Object type);

  /// No description provided for @refillThreshold.
  ///
  /// In en, this message translates to:
  /// **'(optional) Refill alert at'**
  String get refillThreshold;

  /// No description provided for @refillThresholdDisplay.
  ///
  /// In en, this message translates to:
  /// **'Refill Alert'**
  String get refillThresholdDisplay;

  /// No description provided for @lowStock.
  ///
  /// In en, this message translates to:
  /// **'Low Stock'**
  String get lowStock;

  /// No description provided for @medications.
  ///
  /// In en, this message translates to:
  /// **'Medications'**
  String get medications;

  /// No description provided for @needRefill.
  ///
  /// In en, this message translates to:
  /// **'The following medications need refilling:'**
  String get needRefill;

  /// No description provided for @needRefillShort.
  ///
  /// In en, this message translates to:
  /// **'medications need refilling'**
  String get needRefillShort;

  /// No description provided for @newUpdateAvailable.
  ///
  /// In en, this message translates to:
  /// **'New Update Available!'**
  String get newUpdateAvailable;

  /// No description provided for @updateAvailableBody.
  ///
  /// In en, this message translates to:
  /// **'A new version of DawaTime is available. Tap to update now.'**
  String get updateAvailableBody;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar': return AppLocalizationsAr();
    case 'en': return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
