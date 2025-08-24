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
  String get mustAccept => 'You must accept the Terms & Conditions and Privacy Policy.';

  @override
  String get passwordsDontMatch => 'Passwords do not match';

  @override
  String get verificationSent => 'Verification email sent. Please check your inbox.';

  @override
  String get signupFailed => 'Sign up failed. Please try again.';

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
  String get dosageFrequencyGreaterThanZero => 'Dosage and frequency must be greater than zero.';

  @override
  String get pleasePickScheduleStartDate => 'Please pick a schedule start date.';

  @override
  String get couldNotSaveMedication => 'Could not save medication. Please try again.';

  @override
  String get youCanOnlyHaveUpTo7Medications => 'You can only have up to 7 medications.';

  @override
  String get welcomeBack => 'Welcome back,';

  @override
  String get noMedicationsFound => 'No medications found.';

  @override
  String get undo => 'Undo';

  @override
  String get editMedication => 'Edit Medication';

  @override
  String get takeMedication => 'Take Medication';

  @override
  String get didYouTakeYourMedication => 'Did you take your medication?';

  @override
  String get youreOutOfMedication => 'You\'re out of medication!';

  @override
  String get pleaseRefillYourMedication => 'Please refill your medication.';

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
  String get systemTheme => 'System';

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
  String get couldNotUpdateMedication => 'Could not update your medication. Please try again.';

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
  String get contactMeFailed => 'Failed to send message. Please try again.';

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
}
