// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'دواء تايم';

  @override
  String get addMedication => 'إضافة دواء جديد';

  @override
  String get saveMedication => 'حفظ الدواء';

  @override
  String get signUp => 'إنشاء حساب';

  @override
  String get name => 'الاسم';

  @override
  String get email => 'البريد الإلكتروني';

  @override
  String get password => 'كلمة المرور';

  @override
  String get confirmPassword => 'تأكيد كلمة المرور';

  @override
  String get accept => 'أوافق على ';

  @override
  String get terms => 'الشروط والأحكام';

  @override
  String get privacy => 'سياسة الخصوصية';

  @override
  String get mustAccept => 'يجب عليك قبول الشروط والأحكام وسياسة الخصوصية';

  @override
  String get passwordsDontMatch => 'كلمات المرور غير متطابقة';

  @override
  String get verificationSent => 'تم إرسال بريد التحقق، يرجى مراجعة بريدك';

  @override
  String get signupFailed => 'فشل إنشاء الحساب. يرجى المحاولة مرة أخرى';

  @override
  String get welcomeToDawaTime => 'مرحبًا بك في دواء تايم!';

  @override
  String get login => 'تسجيل الدخول';

  @override
  String get dontHaveAccountSignUp => 'ليس لديك حساب؟ أنشئ حساب';

  @override
  String get forgotPassword => 'نسيت كلمة المرور؟';

  @override
  String get resetPassword => 'إعادة تعيين كلمة المرور';

  @override
  String get pleaseEnterYourEmail => 'يرجى إدخال بريدك الإلكتروني';

  @override
  String get enterYourPassword => 'أدخل كلمة المرور';

  @override
  String get cancel => 'إلغاء';

  @override
  String get send => 'إرسال';

  @override
  String get appGuide => 'دليل التطبيق';

  @override
  String get privacyPolicy => 'سياسة الخصوصية';

  @override
  String get termsAndConditions => 'الشروط والأحكام';

  @override
  String get addNewMedication => 'إضافة دواء جديد';

  @override
  String get unitOfMeasurement => 'وحدة القياس';

  @override
  String get dosage => 'الجرعة';

  @override
  String get every => 'كل';

  @override
  String get frequency => 'التكرار';

  @override
  String get currentAmount => 'الكمية الحالية';

  @override
  String get pickNotificationTime => 'اختر وقت التنبيه';

  @override
  String get notifyAt => 'التنبيه عند';

  @override
  String get pickScheduleStartDate => 'اختر تاريخ بدء الجدول';

  @override
  String get startDate => 'تاريخ البدء';

  @override
  String get pleaseFillAllFields => 'يرجى تعبئة جميع الحقول';

  @override
  String get dosageFrequencyGreaterThanZero => 'يجب أن تكون عدد الجرعة والتكرار أكبر من الصفر';

  @override
  String get pleasePickScheduleStartDate => 'يرجى اختيار تاريخ بدء الجدول.';

  @override
  String get couldNotSaveMedication => 'تعذر حفظ الدواء. يرجى المحاولة مرة أخرى.';

  @override
  String get youCanOnlyHaveUpTo7Medications => 'يمكنك إضافة حتى 7 أدوية فقط.';

  @override
  String get welcomeBack => 'مرحبًا بعودتك،';

  @override
  String get noMedicationsFound => 'لم يتم العثور على أدوية.';

  @override
  String get undo => 'تراجع';

  @override
  String get editMedication => 'تعديل الدواء';

  @override
  String get takeMedication => 'تناول الدواء';

  @override
  String get didYouTakeYourMedication => 'هل تناولت دوائك؟';

  @override
  String youreOutOfMedication(Object medication) {
    return 'لقد نفدت $medication!';
  }

  @override
  String pleaseRefillYourMedication(Object medication) {
    return 'يرجى إعادة تعبئة $medication.';
  }

  @override
  String get deleteMedication => 'حذف الدواء';

  @override
  String areYouSureDeleteMedication(Object medication) {
    return 'هل أنت متأكد أنك تريد حذف$medication؟';
  }

  @override
  String get changeEmail => 'تغيير البريد الإلكتروني';

  @override
  String get resetPasswordButton => 'إعادة تعيين كلمة المرور';

  @override
  String get deleteAccount => 'حذف الحساب';

  @override
  String get contactMe => 'تواصل معي';

  @override
  String get theme => 'السمة';

  @override
  String get language => 'اللغة';

  @override
  String get systemTheme => 'النظام';

  @override
  String get lightTheme => 'فاتح';

  @override
  String get darkTheme => 'داكن';

  @override
  String get editProfile => 'تعديل الملف الشخصي';

  @override
  String get close => 'إغلاق';

  @override
  String get logOut => 'تسجيل الخروج';

  @override
  String get areYouSureLogOut => 'هل أنت متأكد أنك تريد تسجيل الخروج؟';

  @override
  String get outOfStock => 'نفدت الكمية';

  @override
  String get nextReminder => 'التنبيه القادم';

  @override
  String markedAsTaken(Object medication) {
    return 'تم التحديد $medication كمأخوذ!';
  }

  @override
  String get couldNotUpdateMedication => 'تعذر تحديث الدواء. يرجى المحاولة مرة أخرى.';

  @override
  String get deleteAccountTitle => 'حذف الحساب';

  @override
  String get deleteAccountConfirm => 'هل أنت   متأكد أنك تريد حذف حسابك؟';

  @override
  String get writeYourMessageHere => 'اكتب رسالتك هنا...';

  @override
  String get contactMeTitle => 'تواصل معي';

  @override
  String get contactMeSent => 'تم إرسال الرسالة بنجاح!';

  @override
  String get contactMeFailed => 'فشل إرسال الرسالة. يرجى المحاولة مرة أخرى.';

  @override
  String get notifications => 'التنبيهات';

  @override
  String get profileAndSettings => 'الملف الشخصي والإعدادات';

  @override
  String get day => 'يوم';

  @override
  String timeToTakeMedication(Object medication) {
    return 'حان وقت تناول $medication!';
  }

  @override
  String get medicationUpdated => 'تم تحديث الدواء!';

  @override
  String reminderTakeMedication(Object medication) {
    return 'تذكير: تناول دوائك $medication';
  }

  @override
  String medicationDeleted(Object medication) {
    return 'تم حذف $medication!';
  }

  @override
  String get yes => 'نعم';

  @override
  String get no => 'لا';

  @override
  String get ok => 'حسناً';

  @override
  String get welcomeBody => 'دواء تايم يساعدك على إدارة أدويتك ومواعيدها بكل سهولة.';

  @override
  String get addMedicationTitle => 'إضافة أدوية';

  @override
  String get addMedicationBody => 'اضغط على زر \"+\" لإضافة دواء جديد وضبط المنبهات.';

  @override
  String get editDeleteTitle => 'تعديل وحذف';

  @override
  String get editDeleteBody => 'اسحب لليمين للتعديل أو لليسار لحذف الدواء من القائمة.';

  @override
  String get notificationsBody => 'سيصلك إشعار عندما يحين وقت تناول دوائك — حتى لو كان التطبيق مغلقاً!';

  @override
  String get profileAndSettingsBody => 'قم بإدارة ملفك الشخصي وإعدادات التطبيق من الزاوية العلوية اليمنى.';

  @override
  String get next => 'التالي';

  @override
  String get back => 'الرجوع';
}
