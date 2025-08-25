// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'DawaTime';

  @override
  String get addMedication => 'Add New Medication';

  @override
  String get saveMedication => 'Save Medication';

  @override
  String get signUp => 'Sign Up';

  @override
  String get name => 'Name';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get confirmPassword => 'Confirm Password';

  @override
  String get accept => 'I accept the ';

  @override
  String get terms => 'Terms & Conditions';

  @override
  String get privacy => 'Privacy Policy';

  @override
  String get mustAccept => 'You must accept the Terms & Conditions and Privacy Policy';

  @override
  String get passwordsDontMatch => 'Passwords do not match';

  @override
  String get verificationSent => 'Verification email sent, please check your inbox';

  @override
  String get signupFailed => 'Sign up failed, please try again';

  @override
  String get welcomeToDawaTime => 'Welcome to DawaTime!';

  @override
  String get login => 'Login';

  @override
  String get dontHaveAccountSignUp => 'Don\'t have an account? Sign Up';

  @override
  String get forgotPassword => 'Forgot Password?';

  @override
  String get resetPassword => 'Reset Password';

  @override
  String get pleaseEnterYourEmail => 'Please enter your email';

  @override
  String get enterYourPassword => 'Enter your password';

  @override
  String get cancel => 'Cancel';

  @override
  String get send => 'Send';

  @override
  String get appGuide => 'App Guide';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get termsAndConditions => 'Terms & Conditions';

  @override
  String get addNewMedication => 'Add New Medication';

  @override
  String get unitOfMeasurement => 'Unit Of Measurement';

  @override
  String get dosage => 'Dosage';

  @override
  String get every => 'every';

  @override
  String get frequency => 'Frequency';

  @override
  String get currentAmount => 'Current Amount';

  @override
  String get pickNotificationTime => 'Pick Notification Time';

  @override
  String get notifyAt => 'Notify At';

  @override
  String get pickScheduleStartDate => 'Pick Schedule Start Date';

  @override
  String get startDate => 'Start Date';

  @override
  String get pleaseFillAllFields => 'Please fill all fields.';

  @override
  String get dosageFrequencyGreaterThanZero => 'Dosage and frequency must be greater than zero';

  @override
  String get pleasePickScheduleStartDate => 'Please pick a schedule start date';

  @override
  String get couldNotSaveMedication => 'Could not save medication. Please try again';

  @override
  String get youCanOnlyHaveUpTo7Medications => 'You can only have up to 7 medications';

  @override
  String get welcomeBack => 'Welcome back,';

  @override
  String get noMedicationsFound => 'No medications found';

  @override
  String get undo => 'Undo';

  @override
  String get editMedication => 'Edit Medication';

  @override
  String get takeMedication => 'Take Medication';

  @override
  String get didYouTakeYourMedication => 'Did you take your medication?';

  @override
  String youreOutOfMedication(Object medication) {
    return 'You\'re out of $medication!';
  }

  @override
  String pleaseRefillYourMedication(Object medication) {
    return 'Please refill your $medication.';
  }

  @override
  String get deleteMedication => 'Delete Medication';

  @override
  String areYouSureDeleteMedication(Object medication) {
    return 'Are you sure you want to delete $medication?';
  }

  @override
  String get changeEmail => 'Change Email';

  @override
  String get resetPasswordButton => 'Reset Password';

  @override
  String get deleteAccount => 'Delete Account';

  @override
  String get contactMe => 'Contact Me';

  @override
  String get theme => 'Theme';

  @override
  String get language => 'Language';

  @override
  String get systemTheme => 'System Default';

  @override
  String get lightTheme => 'Light';

  @override
  String get darkTheme => 'Dark';

  @override
  String get editProfile => 'Edit Profile';

  @override
  String get close => 'Close';

  @override
  String get logOut => 'Log Out';

  @override
  String get areYouSureLogOut => 'Are you sure you want to log out?';

  @override
  String get outOfStock => 'Out of stock';

  @override
  String get nextReminder => 'Next reminder';

  @override
  String markedAsTaken(Object medication) {
    return 'Marked $medication as taken!';
  }

  @override
  String get couldNotUpdateMedication => 'Could not update your medication, please try again';

  @override
  String get deleteAccountTitle => 'Delete Account';

  @override
  String get deleteAccountConfirm => 'Are you sure you want to delete your account?';

  @override
  String get writeYourMessageHere => 'Write your message here...';

  @override
  String get contactMeTitle => 'Contact Me';

  @override
  String get contactMeSent => 'Message sent successfully!';

  @override
  String get contactMeFailed => 'Failed to send message, please try again';

  @override
  String get notifications => 'Notifications';

  @override
  String get profileAndSettings => 'Profile & Settings';

  @override
  String get day => 'day';

  @override
  String timeToTakeMedication(Object medication) {
    return 'Time to take $medication!';
  }

  @override
  String get medicationUpdated => 'Medication updated!';

  @override
  String reminderTakeMedication(Object medication) {
    return 'Reminder: Take your $medication';
  }

  @override
  String medicationDeleted(Object medication) {
    return '$medication deleted!';
  }

  @override
  String get yes => 'yes';

  @override
  String get no => 'no';

  @override
  String get ok => 'ok';

  @override
  String get welcomeBody => 'DawaTime helps you manage your medications and reminders with ease.';

  @override
  String get addMedicationTitle => 'Add Medications';

  @override
  String get addMedicationBody => 'Tap the \"+\" button to add a new medication and set up reminders.';

  @override
  String get editDeleteTitle => 'Edit & Delete';

  @override
  String get editDeleteBody => 'Swipe right to edit or left to delete a medication from your list.';

  @override
  String get notificationsBody => 'You\'ll get notified when it\'s time to take your medication — even if the app is closed!';

  @override
  String get profileAndSettingsBody => 'Manage your profile and app settings from the top right corner.';

  @override
  String get next => 'Next';

  @override
  String get back => 'Back';

  @override
  String get continueConfirmation => 'Continue?';

  @override
  String get settings => 'Settings';

  @override
  String get version => 'Version';

  @override
  String get developed => 'Developed By';

  @override
  String get developer => 'Hamad AlKhalaf';

  @override
  String get appInfo => 'App Info';

  @override
  String get light => 'Light';

  @override
  String get dark => 'Dark';

  @override
  String get failedToLoadUserData => 'Failed to load user data.';

  @override
  String get save => 'Save';

  @override
  String get change => 'Change';

  @override
  String get newEmail => 'New Email';

  @override
  String get currentPassword => 'Current Password';

  @override
  String get emailChange => 'Email Change Requested';

  @override
  String get verifyNewEmail => 'A verification email has been sent to your new email address. Please verify it, then log in again with your new email.';

  @override
  String get updateEmailFailed => 'Failed to update email:';

  @override
  String get noUser => 'No user is currently logged in.';

  @override
  String get sendEmail => 'Send Email';

  @override
  String get resetEmailSent => 'Password reset email sent!';

  @override
  String get resetEmailFailed => 'Failed to send reset email:';

  @override
  String get enterPasswordTwice => 'Please enter your password twice.';

  @override
  String get delete => 'Delete';

  @override
  String get noUserEmail => 'No email found for user.';

  @override
  String get accountDeleted => 'Account Deleted';

  @override
  String get accountDeletedSuccess => 'Your account has been deleted successfully.';

  @override
  String get accountDeletedFailed => 'Failed to delete user:';

  @override
  String get mustBeLoggedIn => 'You must be logged in to send a message.';

  @override
  String get messageSent => 'Message sent!';

  @override
  String get messageFailed => 'Failed to send message:';

  @override
  String get getStarted => 'Here\'s how to get started:';

  @override
  String get addMedicationBody2 => '• Add your medications using the \"+\" button.\n';

  @override
  String get setReminders => '• Set reminders for each medication so you never miss a dose.\n';

  @override
  String get viewDetails => '• Tap a medication to view details.\n';

  @override
  String get swipe => '• Swipe left to delete or right to edit a medication.\n';

  @override
  String get checkReminders => '• Check your upcoming reminders on the home screen.\n';

  @override
  String get manageProfile => '• Manage your profile and settings from the top right.\n';

  @override
  String get medicationNotifications => 'You\'ll receive notifications when it\'s time to take your medication — even if the app is closed!';

  @override
  String get notification => 'Notification';

  @override
  String get updateRequired => 'Update Required';

  @override
  String get pleaseUpdate => 'A new version of the app is available. Please update to continue.';

  @override
  String get update => 'Update';

  @override
  String get accessDenied => 'Access Denied';

  @override
  String get notAvailable => 'This app is not available in your country.';

  @override
  String get failedUpdateCheck => 'Failed to check for updates. Please try again later.';

  @override
  String get error => 'Error';

  @override
  String get gotIt => 'Got it!';
}
