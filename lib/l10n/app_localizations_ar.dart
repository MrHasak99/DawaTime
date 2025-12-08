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
  String get signupFailed => 'فشل إنشاء الحساب، يرجى المحاولة مرة أخرى';

  @override
  String get welcomeToDawaTime => 'مرحباً بك في دواء تايم!';

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
  String get pleaseFillAllFields => 'يرجى تعبئة جميع الحقول المطلوبة';

  @override
  String get dosageFrequencyGreaterThanZero => 'يجب أن تكون عدد الجرعة والتكرار أكبر من الصفر';

  @override
  String get pleasePickScheduleStartDate => 'يرجى اختيار تاريخ بدء الجدول.';

  @override
  String get couldNotSaveMedication => 'تعذر حفظ الدواء، يرجى المحاولة مرة أخرى';

  @override
  String get youCanOnlyHaveUpTo7Medications => 'يمكنك إضافة حتى 7 أدوية فقط';

  @override
  String get welcomeBack => 'مرحباً بعودتك،';

  @override
  String get noMedicationsFound => 'لم يتم العثور على أدوية.';

  @override
  String get undo => 'تراجع';

  @override
  String get editMedication => 'تعديل الدواء';

  @override
  String takeMedication(Object medication) {
    return 'أخذ $medication';
  }

  @override
  String didYouTakeYourMedication(Object medication) {
    return 'هل أخذت $medication؟';
  }

  @override
  String youreOutOfMedication(Object medication) {
    return 'لقد نفدت $medication!';
  }

  @override
  String pleaseRefillYourMedication(Object medication) {
    return 'يرجى إعادة تعبئة $medication';
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
  String get theme => 'المظهر';

  @override
  String get language => 'اللغة';

  @override
  String get systemTheme => 'حسب النظام';

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
  String get couldNotUpdateMedication => 'تعذر تحديث الدواء، يرجى المحاولة مرة أخرى';

  @override
  String get deleteAccountTitle => 'حذف الحساب';

  @override
  String get deleteAccountConfirm => 'هل أنت متأكد أنك تريد حذف حسابك؟';

  @override
  String get writeYourMessageHere => 'اكتب رسالتك هنا...';

  @override
  String get contactMeTitle => 'تواصل معي';

  @override
  String get contactMeSent => 'تم إرسال الرسالة بنجاح!';

  @override
  String get contactMeFailed => 'فشل إرسال الرسالة، يرجى المحاولة مرة أخرى';

  @override
  String get notifications => 'التنبيهات';

  @override
  String get profileAndSettings => 'الملف الشخصي والإعدادات';

  @override
  String get day => 'يوم';

  @override
  String timeToTakeMedication(Object medication) {
    return 'حان وقت أخذ $medication!';
  }

  @override
  String medicationUpdated(Object medication) {
    return 'تم تحديث $medication!';
  }

  @override
  String reminderTakeMedication(Object medication) {
    return 'تذكير: أخذ $medication';
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
  String get notificationsBody => 'سيصلك إشعار عندما يحين وقت أخذ دوائك — حتى لو كان التطبيق مغلقاً!';

  @override
  String get profileAndSettingsBody => 'قم بإدارة ملفك الشخصي وإعدادات التطبيق من الزاوية العلوية اليمنى.';

  @override
  String get next => 'التالي';

  @override
  String get back => 'الرجوع';

  @override
  String get continueConfirmation => 'هل تريد المتابعة؟';

  @override
  String get settings => 'الإعدادات';

  @override
  String get version => 'الإصدار';

  @override
  String get developed => 'من تطوير';

  @override
  String get developer => 'حمد الخلف';

  @override
  String get appInfo => 'معلومات التطبيق';

  @override
  String get light => 'فاتح';

  @override
  String get dark => 'داكن';

  @override
  String get failedToLoadUserData => 'فشل تحميل بيانات المستخدم';

  @override
  String get save => 'حفظ';

  @override
  String get change => 'تأكيد';

  @override
  String get newEmail => 'البريد الإلكتروني الجديد';

  @override
  String get currentPassword => 'كلمة المرور الحالية';

  @override
  String get emailChange => 'تم تغيير البريد الإلكتروني';

  @override
  String get verifyNewEmail => 'تم إرسال رسالة تحقق إلى عنوان بريدك الإلكتروني الجديد. يرجى التحقق منه، ثم قم بتسجيل الدخول مرة أخرى باستخدام بريدك الإلكتروني الجديد';

  @override
  String get updateEmailFailed => 'فشل تحديث البريد الإلكتروني:';

  @override
  String get noUser => 'لا يوجد مستخدم مسجل الدخول حالياً';

  @override
  String get sendEmail => 'أرسل البريد الإلكتروني';

  @override
  String get resetEmailSent => 'تم إرسال بريد إلكتروني لإعادة تعيين كلمة المرور!';

  @override
  String get resetEmailFailed => 'فشل إرسال البريد إلكتروني لإعادة تعيين كلمة المرور:';

  @override
  String get enterPasswordTwice => 'يرجى إدخال كلمة المرور مرتين.';

  @override
  String get delete => 'امسح';

  @override
  String get noUserEmail => 'لا يوجد بريد إلكتروني للمستخدم';

  @override
  String get accountDeleted => 'تم مسح الحساب';

  @override
  String get accountDeletedSuccess => 'تم مسح الحساب بنجاح';

  @override
  String get accountDeletedFailed => 'فشل مسح الحساب:';

  @override
  String get mustBeLoggedIn => 'يجب أن تكون مسجلاً للدخول لإرسال رسالة';

  @override
  String get messageSent => 'تم إرسال الرسالة بنجاح!';

  @override
  String get messageFailed => 'فشل إرسال الرسالة:';

  @override
  String get getStarted => 'إليك كيفية البدء:';

  @override
  String get addMedicationBody2 => '• اضف أدويتك بإستخدام زر \"+\".\n';

  @override
  String get setReminders => '• قم بضبط منبهات لكل دواء حتى لا تفوتك أي جرعة.\n';

  @override
  String get viewDetails => '• اضغط على الدواء لرؤية التفاصيل\n';

  @override
  String get swipe => '• اسحب الدواء لليسار لحذفه أو لليمين لتعديله.\n';

  @override
  String get checkReminders => '• تفقد تذكيراتك القادمة على الشاشة الرئيسية.\n';

  @override
  String get manageProfile => '• قم بإدارة ملفك الشخصي والإعدادات من الزاوية العلوية اليمنى.\n';

  @override
  String get medicationNotifications => 'سيصلك إشعار عندما يحين وقت أخذ دوائك — حتى لو كان التطبيق مغلقاً!';

  @override
  String get notification => 'تنبيه';

  @override
  String get updateRequired => 'تحديث مطلوب';

  @override
  String get pleaseUpdate => 'يتوفر إصدار جديد من التطبيق، الرجاء التحديث للمتابعة';

  @override
  String get update => 'حدّث';

  @override
  String get accessDenied => 'الوصول مرفوض';

  @override
  String get notAvailable => 'هذا التطبيق غير متاح في بلدك';

  @override
  String get failedUpdateCheck => 'تعذر التحقق من وجود تحديثات. الرجاء المحاولة مرة أخرى لاحقاً';

  @override
  String get error => 'خطأ';

  @override
  String get gotIt => 'حسناً!';

  @override
  String get pleaseVerfiy => 'الرجاء التحقق من بريدك الإلكتروني قبل تسجيل الدخول';

  @override
  String get noAccount => 'لم يتم العثور على حساب مرتبط بهذا البريد الإلكتروني، الرجاء إنشاء حساب أولاً';

  @override
  String get incorrectPassword => 'كلمة المرور غير صحيحة، الرجاء المحاولة مرة أخرى';

  @override
  String get invalidEmail => 'عنوان البريد الإلكتروني غير صحيح';

  @override
  String get disabledAccount => 'هذا الحساب معطل، يرجى التواصل مع فريق الدعم';

  @override
  String get loginFailed => 'فشل تسجيل الدخول، الرجاء التأكد من بيانات الدخول والمحاولة مرة أخرى';

  @override
  String get emailAlreadyRegistered => 'هذا البريد الإلكتروني مسجل بالفعل، الرجاء استخدام بريد إلكتروني آخر أو تسجيل الدخول';

  @override
  String get emailInvalid => 'عنوان البريد الإلكتروني غير صحيح، يرجى التأكد منه وإعادة المحاولة';

  @override
  String get weakPassword => 'كلمة المرور ضعيفة، يجب أن تتكون من 6 أحرف على الأقل';

  @override
  String get emailMethod => 'طريقة التسجيل هذه غير مفعّلة، الرجاء التواصل مع الدعم الفني';

  @override
  String get friend => 'صديقي';

  @override
  String get viewProfile => 'عرض الملف الشخصي';

  @override
  String get addMedicationFailed => 'تعذّر إضافة الدواء:';

  @override
  String get allowSettings => 'الرجاء السماح بإذن \"المنبهات والتذكيرات\" من إعدادات النظام';

  @override
  String get openSettings => 'افتح الإعدادات';

  @override
  String get scheduleMedicationFailure => 'فشل في جدولة الإشعار:';

  @override
  String get profileUpdated => 'تم تحديث الملف الشخصي!';

  @override
  String get updateFailed => 'فشل التحديث:';

  @override
  String get passwordEmail => 'سيتم إرسال بريد إلكتروني لإعادة تعيين كلمة المرور إلى:';

  @override
  String get selectDaysOfWeek => 'أيام الأسبوع';

  @override
  String get everyXDays => 'كل X يوم';

  @override
  String timeToTakeMedicationNow(Object medication) {
    return 'حان وقت أخذ $medication الآن!';
  }

  @override
  String get followUsOnInstagram => 'تابعنا على انستجرام';

  @override
  String get checkForUpdates => 'البحث عن تحديثات';

  @override
  String get checkingForUpdates => 'جاري البحث عن تحديثات...';

  @override
  String get upToDate => 'التطبيق محدث';

  @override
  String lastChecked(Object time) {
    return 'آخر فحص: $time';
  }

  @override
  String get refillReminder => 'تذكير بإعادة التعبئة';

  @override
  String refillReminderBody(Object amount, Object medication, Object type) {
    return 'لديك $amount $type من $medication متبقية. حان وقت إعادة التعبئة!';
  }

  @override
  String get refillThreshold => 'تنبيه التعبئة عند (إختياري)';

  @override
  String get lowStock => 'مخزون منخفض';

  @override
  String get medications => 'الأدوية';

  @override
  String get needRefill => 'الأدوية التالية تحتاج إلى إعادة تعبئة:';

  @override
  String get needRefillShort => 'أدوية تحتاج إعادة تعبئة';

  @override
  String get newUpdateAvailable => 'تحديث جديد متوفر!';

  @override
  String get updateAvailableBody => 'إصدار جديد من دواء تايم متاح. اضغط للتحديث الآن.';
}
