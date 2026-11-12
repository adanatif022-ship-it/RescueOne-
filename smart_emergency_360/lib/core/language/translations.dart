import 'app_language.dart';

/// Every user-visible string in the app, keyed by a short identifier.
/// Add new keys here as new screens are built - never hard-code text
/// in a widget.
final Map<String, Map<AppLocale, String>> translations = {
  // ---------------------------------------------------------------- common
  'app_name': {AppLocale.en: 'Rescue One', AppLocale.ar: 'ريسكيو ون'},
  'ok': {AppLocale.en: 'OK', AppLocale.ar: 'موافق'},
  'cancel': {AppLocale.en: 'Cancel', AppLocale.ar: 'إلغاء'},
  'confirm': {AppLocale.en: 'Confirm', AppLocale.ar: 'تأكيد'},
  'save': {AppLocale.en: 'Save', AppLocale.ar: 'حفظ'},
  'edit': {AppLocale.en: 'Edit', AppLocale.ar: 'تعديل'},
  'delete': {AppLocale.en: 'Delete', AppLocale.ar: 'حذف'},
  'add': {AppLocale.en: 'Add', AppLocale.ar: 'إضافة'},
  'back': {AppLocale.en: 'Back', AppLocale.ar: 'رجوع'},
  'next': {AppLocale.en: 'Next', AppLocale.ar: 'التالي'},
  'yes': {AppLocale.en: 'Yes', AppLocale.ar: 'نعم'},
  'no': {AppLocale.en: 'No', AppLocale.ar: 'لا'},
  'close': {AppLocale.en: 'Close', AppLocale.ar: 'إغلاق'},
  'none': {AppLocale.en: 'None', AppLocale.ar: 'لا يوجد'},
  'optional': {AppLocale.en: 'Optional', AppLocale.ar: 'اختياري'},
  'view_all': {AppLocale.en: 'View all', AppLocale.ar: 'عرض الكل'},
  'guest_label': {AppLocale.en: 'Guest', AppLocale.ar: 'ضيف'},
  'view_details': {AppLocale.en: 'View details', AppLocale.ar: 'عرض التفاصيل'},
  'simulated_badge': {AppLocale.en: 'Simulated', AppLocale.ar: 'محاكاة'},

  // --------------------------------------------------------------- splash
  'splash_tagline': {
    AppLocale.en: 'Smart response. Wherever you are.',
    AppLocale.ar: 'استجابة ذكية في وقت الطوارئ، أينما كنت',
  },

  // ---------------------------------------------------------------- login
  'login_title': {AppLocale.en: 'Welcome back', AppLocale.ar: 'مرحبًا بعودتك'},
  'login_subtitle': {
    AppLocale.en: 'Sign in to manage your emergency profile and alerts.',
    AppLocale.ar: 'سجّل الدخول لإدارة ملفك الطارئ وتنبيهاتك.',
  },
  'login_email': {AppLocale.en: 'Email', AppLocale.ar: 'البريد الإلكتروني'},
  'login_password': {AppLocale.en: 'Password', AppLocale.ar: 'كلمة المرور'},
  'login_button': {AppLocale.en: 'Sign In', AppLocale.ar: 'تسجيل الدخول'},
  'login_guest': {
    AppLocale.en: 'Continue as guest',
    AppLocale.ar: 'المتابعة كضيف',
  },
  'login_validation_email': {
    AppLocale.en: 'Enter a valid email',
    AppLocale.ar: 'أدخل بريدًا إلكترونيًا صحيحًا',
  },
  'login_validation_password': {
    AppLocale.en: 'Password must be at least 6 characters',
    AppLocale.ar: 'يجب أن تتكون كلمة المرور من 6 أحرف على الأقل',
  },
  'login_validation_password_empty': {
    AppLocale.en: 'Enter your password',
    AppLocale.ar: 'أدخل كلمة المرور',
  },
  'login_prototype_notice': {
    AppLocale.en:
        'Your account works on any device. Your medical profile, contacts and reports stay on this device. SOS works without an account.',
    AppLocale.ar:
        'حسابك يعمل على أي جهاز. ملفك الطبي وجهات اتصالك وبلاغاتك تبقى على هذا الجهاز. زر الطوارئ يعمل دون حساب.',
  },
  'login_remember_me': {AppLocale.en: 'Remember me', AppLocale.ar: 'تذكرني'},
  'login_forgot_password': {
    AppLocale.en: 'Forgot password?',
    AppLocale.ar: 'نسيت كلمة المرور؟',
  },
  'login_forgot_password_body': {
    AppLocale.en:
        'Enter your account email and we\'ll send you a link to set a new password.',
    AppLocale.ar: 'أدخل بريد حسابك وسنرسل إليك رابطاً لتعيين كلمة مرور جديدة.',
  },
  'login_forgot_password_send': {
    AppLocale.en: 'Send link',
    AppLocale.ar: 'إرسال الرابط',
  },
  'login_forgot_password_sent': {
    AppLocale.en:
        'If an account exists for this email, a reset link is on its way. Check your inbox and spam folder.',
    AppLocale.ar:
        'إن كان لهذا البريد حساب، فسيصلك رابط إعادة التعيين. تحقق من البريد الوارد ومجلد الرسائل غير المرغوبة.',
  },
  'new_password_title': {
    AppLocale.en: 'Set a new password',
    AppLocale.ar: 'تعيين كلمة مرور جديدة',
  },
  'new_password_label': {
    AppLocale.en: 'New password',
    AppLocale.ar: 'كلمة المرور الجديدة',
  },
  'new_password_saved': {
    AppLocale.en: 'Password updated. You\'re signed in.',
    AppLocale.ar: 'تم تحديث كلمة المرور، وأنت الآن مسجّل الدخول.',
  },

  // ------------------------------------------------------- account errors
  'auth_error_invalid_credentials': {
    AppLocale.en: 'Incorrect email or password.',
    AppLocale.ar: 'البريد الإلكتروني أو كلمة المرور غير صحيحة.',
  },
  'auth_error_email_not_confirmed': {
    AppLocale.en:
        'Confirm your email first: open the link we sent you, then sign in.',
    AppLocale.ar:
        'أكّد بريدك أولاً: افتح الرابط الذي أرسلناه إليك ثم سجّل الدخول.',
  },
  'auth_error_user_exists': {
    AppLocale.en: 'An account with this email already exists. Sign in instead.',
    AppLocale.ar: 'يوجد حساب بهذا البريد. سجّل الدخول بدلاً من ذلك.',
  },
  'auth_error_weak_password': {
    AppLocale.en:
        'This password is too weak. Use at least 6 characters, mixing letters and numbers.',
    AppLocale.ar:
        'كلمة المرور ضعيفة. استخدم 6 أحرف على الأقل تجمع بين حروف وأرقام.',
  },
  'auth_error_same_password': {
    AppLocale.en: 'The new password must be different from the current one.',
    AppLocale.ar: 'يجب أن تختلف كلمة المرور الجديدة عن الحالية.',
  },
  'auth_error_email_not_authorized': {
    AppLocale.en:
        'The server can\'t send email to this address yet. Contact the app owner, or continue as a guest.',
    AppLocale.ar:
        'الخادم لا يستطيع الإرسال إلى هذا البريد حالياً. تواصل مع صاحب التطبيق، أو تابع كضيف.',
  },
  'auth_error_signup_disabled': {
    AppLocale.en: 'New accounts can\'t be created right now.',
    AppLocale.ar: 'لا يمكن إنشاء حسابات جديدة حالياً.',
  },
  'auth_error_rate_limit': {
    AppLocale.en: 'Too many attempts. Wait a few minutes and try again.',
    AppLocale.ar: 'محاولات كثيرة. انتظر بضع دقائق ثم حاول مجدداً.',
  },
  'auth_error_network': {
    AppLocale.en:
        'Can\'t reach the server. Check your internet connection and try again. SOS still works as a guest.',
    AppLocale.ar:
        'تعذّر الوصول إلى الخادم. تحقق من اتصالك بالإنترنت وحاول مجدداً. زر الطوارئ يعمل كضيف.',
  },
  'auth_error_unavailable': {
    AppLocale.en:
        'Accounts are unavailable right now. You can continue as a guest.',
    AppLocale.ar: 'الحسابات غير متاحة حالياً. يمكنك المتابعة كضيف.',
  },
  'auth_error_unknown': {
    AppLocale.en: 'Something went wrong. Try again.',
    AppLocale.ar: 'حدث خطأ ما. حاول مجدداً.',
  },
  'login_or_divider': {AppLocale.en: 'or', AppLocale.ar: 'أو'},
  'login_no_account': {
    AppLocale.en: "Don't have an account?",
    AppLocale.ar: 'ليس لديك حساب؟',
  },

  // -------------------------------------------------------------- register
  'register_title': {
    AppLocale.en: 'Create new account',
    AppLocale.ar: 'إنشاء حساب جديد',
  },
  'register_subtitle': {
    AppLocale.en: 'Please fill in your details to create an account.',
    AppLocale.ar: 'الرجاء تعبئة البيانات لإنشاء حساب.',
  },
  'register_full_name': {
    AppLocale.en: 'Full name',
    AppLocale.ar: 'الاسم الكامل',
  },
  'register_phone': {AppLocale.en: 'Phone number', AppLocale.ar: 'رقم الهاتف'},
  'register_confirm_password': {
    AppLocale.en: 'Confirm password',
    AppLocale.ar: 'تأكيد كلمة المرور',
  },
  'register_terms': {
    AppLocale.en: 'I agree to the terms and privacy policy',
    AppLocale.ar: 'أوافق على الشروط وسياسة الخصوصية',
  },
  'register_button': {
    AppLocale.en: 'Create account',
    AppLocale.ar: 'إنشاء حساب',
  },
  'register_already_have_account': {
    AppLocale.en: 'Already have an account?',
    AppLocale.ar: 'لديك حساب بالفعل؟',
  },
  'register_validation_name': {
    AppLocale.en: 'Enter your full name',
    AppLocale.ar: 'أدخل اسمك الكامل',
  },
  'register_validation_phone': {
    AppLocale.en: 'Enter a valid phone number',
    AppLocale.ar: 'أدخل رقم هاتف صحيح',
  },
  'register_validation_confirm_password': {
    AppLocale.en: 'Passwords do not match',
    AppLocale.ar: 'كلمتا المرور غير متطابقتين',
  },
  'register_validation_terms': {
    AppLocale.en: 'You must agree to continue',
    AppLocale.ar: 'يجب الموافقة على الشروط للمتابعة',
  },
  'register_prototype_notice': {
    AppLocale.en:
        'Only your name, email and phone are saved with your account. Your medical profile, contacts and reports stay on this device.',
    AppLocale.ar:
        'يُحفظ مع حسابك اسمك وبريدك ورقم هاتفك فقط. ملفك الطبي وجهات اتصالك وبلاغاتك تبقى على هذا الجهاز.',
  },
  'register_confirm_email_title': {
    AppLocale.en: 'Confirm your email',
    AppLocale.ar: 'أكّد بريدك الإلكتروني',
  },
  'register_confirm_email_body': {
    AppLocale.en:
        'We sent a confirmation link to {email}. Open it, then sign in with your password.',
    AppLocale.ar:
        'أرسلنا رابط تأكيد إلى {email}. افتحه، ثم سجّل الدخول بكلمة المرور.',
  },

  // ----------------------------------------------------------------- splash
  'splash_services_medical': {AppLocale.en: 'Medical', AppLocale.ar: 'طبي'},
  'splash_services_police': {AppLocale.en: 'Police', AppLocale.ar: 'شرطة'},
  'splash_services_fire': {AppLocale.en: 'Fire', AppLocale.ar: 'إطفاء'},
  'splash_services_protection': {
    AppLocale.en: 'Protection',
    AppLocale.ar: 'حماية',
  },

  // ----------------------------------------------------------------- home
  'home_hello': {AppLocale.en: 'Hello', AppLocale.ar: 'مرحبًا'},
  'home_safety_status_title': {
    AppLocale.en: 'Safety status',
    AppLocale.ar: 'حالة السلامة',
  },
  'home_safety_status_ok': {
    AppLocale.en: 'No active emergency',
    AppLocale.ar: 'لا يوجد بلاغ طوارئ نشط',
  },
  'home_safety_status_active': {
    AppLocale.en: 'Active incident in progress',
    AppLocale.ar: 'يوجد بلاغ طوارئ قيد المتابعة',
  },
  'home_sos_button': {AppLocale.en: 'SOS', AppLocale.ar: 'نداء استغاثة'},
  'home_sos_hint': {
    AppLocale.en: 'Press to report an emergency',
    AppLocale.ar: 'اضغط للإبلاغ عن حالة طارئة',
  },
  'home_location_title': {
    AppLocale.en: 'Current location',
    AppLocale.ar: 'الموقع الحالي',
  },
  'home_location_on': {
    AppLocale.en: 'Location ready',
    AppLocale.ar: 'الموقع جاهز',
  },
  'home_location_off': {
    AppLocale.en: 'Location not detected',
    AppLocale.ar: 'لم يتم تحديد الموقع',
  },
  'home_location_detecting': {
    AppLocale.en: 'Detecting location...',
    AppLocale.ar: 'جارٍ تحديد الموقع...',
  },
  'home_quick_services': {
    AppLocale.en: 'Quick emergency services',
    AppLocale.ar: 'خدمات الطوارئ السريعة',
  },
  'home_choose_service': {
    AppLocale.en: 'Choose the service you need',
    AppLocale.ar: 'اختر الخدمة التي تحتاجها',
  },
  'home_call_police': {AppLocale.en: 'Police', AppLocale.ar: 'الشرطة'},
  'home_call_ambulance': {AppLocale.en: 'Ambulance', AppLocale.ar: 'الإسعاف'},
  'home_call_fire': {AppLocale.en: 'Fire', AppLocale.ar: 'الإطفاء'},
  'home_hospital_routing_title': {
    AppLocale.en: 'Smart Hospital Routing',
    AppLocale.ar: 'التوجيه الذكي للمستشفيات',
  },
  'home_hospital_routing_subtitle': {
    AppLocale.en: 'Compare nearby hospitals by wait time, not just distance',
    AppLocale.ar: 'قارن المستشفيات القريبة حسب وقت الانتظار وليس المسافة فقط',
  },
  'home_recommended_hospital': {
    AppLocale.en: 'Recommended hospital',
    AppLocale.ar: 'المستشفى الموصى به',
  },
  'home_trusted_contacts': {
    AppLocale.en: 'Trusted contacts',
    AppLocale.ar: 'جهات الاتصال الموثوقة',
  },
  'home_ai_assistant': {
    AppLocale.en: 'AI Incident Assistant',
    AppLocale.ar: 'مساعد بلاغات الطوارئ الذكي',
  },
  'home_recent_incidents': {
    AppLocale.en: 'Recent incidents',
    AppLocale.ar: 'أحدث البلاغات',
  },
  'home_no_incidents': {
    AppLocale.en: 'No incidents reported yet',
    AppLocale.ar: 'لا توجد حوادث مسجلة بعد',
  },
  'home_nearby_assistance': {
    AppLocale.en: 'Nearby assistance',
    AppLocale.ar: 'المساعدة القريبة',
  },
  'home_personal_protection': {
    AppLocale.en: 'Protection',
    AppLocale.ar: 'الحماية الشخصية',
  },
  'home_shortcuts_title': {
    AppLocale.en: 'Quick shortcuts',
    AppLocale.ar: 'اختصارات سريعة',
  },
  'home_no_notifications': {
    AppLocale.en: 'No notifications yet',
    AppLocale.ar: 'لا توجد إشعارات بعد',
  },
  'home_prototype_notice': {
    AppLocale.en:
        'This is a graduation-project prototype. It does not replace official emergency services.',
    AppLocale.ar:
        'هذه نسخة تجريبية لمشروع تخرج. لا تغني عن خدمات الطوارئ الرسمية.',
  },

  // --------------------------------------------------------- incident type
  'type_medical': {
    AppLocale.en: 'Medical emergency',
    AppLocale.ar: 'حالة طبية طارئة',
  },
  'type_fire': {AppLocale.en: 'Fire', AppLocale.ar: 'حريق'},
  'type_accident': {AppLocale.en: 'Road accident', AppLocale.ar: 'حادث مروري'},
  'type_danger': {AppLocale.en: 'Personal danger', AppLocale.ar: 'خطر شخصي'},
  'type_security': {
    AppLocale.en: 'Security incident',
    AppLocale.ar: 'حادث أمني',
  },
  'type_other': {
    AppLocale.en: 'Other emergency',
    AppLocale.ar: 'حالة طارئة أخرى',
  },
  'type_medical_desc': {
    AppLocale.en: 'Injury or health emergency',
    AppLocale.ar: 'إصابة أو حالة صحية طارئة',
  },
  'type_fire_desc': {
    AppLocale.en: 'Fire or smoke hazard',
    AppLocale.ar: 'حريق أو خطر دخان',
  },
  'type_accident_desc': {
    AppLocale.en: 'Vehicle collision',
    AppLocale.ar: 'اصطدام مركبات',
  },
  'type_danger_desc': {
    AppLocale.en: 'Immediate personal risk',
    AppLocale.ar: 'خطر شخصي مباشر',
  },
  'type_security_desc': {
    AppLocale.en: 'Crime or security threat',
    AppLocale.ar: 'جريمة أو تهديد أمني',
  },
  'type_other_desc': {
    AppLocale.en: 'Anything else urgent',
    AppLocale.ar: 'أي أمر عاجل آخر',
  },

  // ------------------------------------------------------------------ sos
  'sos_select_type_title': {
    AppLocale.en: 'What is the emergency?',
    AppLocale.ar: 'ما هي حالة الطوارئ؟',
  },
  'sos_select_type_subtitle': {
    AppLocale.en: 'Choose the type that best matches the situation',
    AppLocale.ar: 'اختر النوع الأقرب لوصف الحالة',
  },
  'sos_description_label': {
    AppLocale.en: 'Short description (optional)',
    AppLocale.ar: 'وصف مختصر (اختياري)',
  },
  'sos_description_hint': {
    AppLocale.en: 'e.g. Two cars, one person injured',
    AppLocale.ar: 'مثال: سيارتان، شخص واحد مصاب',
  },
  'sos_location_title': {AppLocale.en: 'Your location', AppLocale.ar: 'موقعك'},
  'sos_location_attach': {
    AppLocale.en: 'Attach current location',
    AppLocale.ar: 'إرفاق الموقع الحالي',
  },
  'sos_location_detecting': {
    AppLocale.en: 'Detecting your location...',
    AppLocale.ar: 'جارٍ تحديد موقعك...',
  },
  'sos_location_attached': {
    AppLocale.en: 'Location attached',
    AppLocale.ar: 'تم إرفاق الموقع',
  },
  'sos_location_failed': {
    AppLocale.en: 'Could not detect location. You can still continue.',
    AppLocale.ar: 'تعذر تحديد الموقع. يمكنك المتابعة بدون ذلك.',
  },
  'sos_silent_title': {AppLocale.en: 'Silent SOS', AppLocale.ar: 'بلاغ صامت'},
  'sos_silent_description': {
    AppLocale.en:
        'No sound, no automatic call. Use this if you cannot speak or must stay discreet.',
    AppLocale.ar:
        'بدون صوت وبدون اتصال تلقائي. استخدمه إن لم تستطع التحدث أو أردت التكتم.',
  },
  'sos_continue': {AppLocale.en: 'Continue', AppLocale.ar: 'متابعة'},
  'sos_confirm_title': {
    AppLocale.en: 'Confirm emergency alert',
    AppLocale.ar: 'تأكيد بلاغ الطوارئ',
  },
  'sos_confirm_type_label': {
    AppLocale.en: 'Emergency type',
    AppLocale.ar: 'نوع الطارئة',
  },
  'sos_confirm_location_label': {
    AppLocale.en: 'Location',
    AppLocale.ar: 'الموقع',
  },
  'sos_confirm_mode_label': {
    AppLocale.en: 'Alert mode',
    AppLocale.ar: 'وضع التنبيه',
  },
  'sos_confirm_mode_normal': {
    AppLocale.en: 'Normal alert',
    AppLocale.ar: 'بلاغ عادي',
  },
  'sos_confirm_mode_silent': {
    AppLocale.en: 'Silent SOS',
    AppLocale.ar: 'نداء صامت',
  },
  'sos_confirm_location_yes': {AppLocale.en: 'Attached', AppLocale.ar: 'مرفق'},
  'sos_confirm_location_no': {
    AppLocale.en: 'Not attached',
    AppLocale.ar: 'غير مرفق',
  },
  'sos_confirm_button': {
    AppLocale.en: 'Confirm and create alert',
    AppLocale.ar: 'تأكيد وإنشاء البلاغ',
  },
  'sos_cancel_button': {AppLocale.en: 'Cancel', AppLocale.ar: 'إلغاء'},
  'sos_confirm_contacts_label': {
    AppLocale.en: 'Notifying',
    AppLocale.ar: 'سيتم إخطار',
  },
  'sos_sending_countdown_title': {
    AppLocale.en: 'Sending alert...',
    AppLocale.ar: 'جارٍ إرسال البلاغ...',
  },
  'sos_sending_countdown_body': {
    AppLocale.en: 'Tap Cancel to stop before it is sent.',
    AppLocale.ar: 'اضغط إلغاء لإيقافه قبل الإرسال.',
  },
  'sos_prototype_notice': {
    AppLocale.en:
        'This is a prototype and does not contact a real emergency organization.',
    AppLocale.ar:
        'هذه نسخة تجريبية ولا تقوم بإرسال بلاغ حقيقي إلى أي جهة طوارئ.',
  },
  'sos_created_title': {
    AppLocale.en: 'Alert created',
    AppLocale.ar: 'تم إنشاء البلاغ',
  },
  'sos_created_message': {
    AppLocale.en:
        'Your incident has been created. Use the buttons below to call emergency services or text your trusted contacts.',
    AppLocale.ar:
        'تم إنشاء بلاغك. استخدم الأزرار أدناه للاتصال بالطوارئ أو مراسلة جهات اتصالك الموثوقة.',
  },
  'sos_call_emergency': {
    AppLocale.en: 'Call emergency services',
    AppLocale.ar: 'اتصل بخدمات الطوارئ',
  },
  'sos_call_confirm_title': {
    AppLocale.en: 'Call emergency services?',
    AppLocale.ar: 'هل تريد الاتصال بخدمات الطوارئ؟',
  },
  'sos_call_confirm_body': {
    AppLocale.en: 'This opens your phone app to call {number}.',
    AppLocale.ar: 'سيفتح هذا تطبيق الهاتف للاتصال بالرقم {number}.',
  },
  'sos_view_progress': {
    AppLocale.en: 'Track incident status',
    AppLocale.ar: 'تتبع حالة البلاغ',
  },
  'sos_cancel_request': {
    AppLocale.en: 'Cancel request',
    AppLocale.ar: 'إلغاء الطلب',
  },
  'sos_cancel_confirm_title': {
    AppLocale.en: 'Cancel this request?',
    AppLocale.ar: 'إلغاء هذا الطلب؟',
  },
  'sos_cancel_confirm_body': {
    AppLocale.en: 'This will mark the prototype incident as cancelled.',
    AppLocale.ar: 'سيتم وضع علامة على هذا البلاغ التجريبي بأنه ملغى.',
  },
  'sos_mark_assisted': {
    AppLocale.en: 'Mark assistance received',
    AppLocale.ar: 'تم تلقي المساعدة',
  },
  'sos_estimated_arrival': {
    AppLocale.en: 'Estimated arrival',
    AppLocale.ar: 'الوصول المتوقع',
  },
  'sos_responder_type': {
    AppLocale.en: 'Responder type',
    AppLocale.ar: 'نوع المستجيب',
  },

  // ------------------------------------------------------------- completed
  'completed_title': {
    AppLocale.en: 'Assistance completed',
    AppLocale.ar: 'اكتملت المساعدة',
  },
  'completed_message': {
    AppLocale.en: 'Your incident has been marked as assisted.',
    AppLocale.ar: 'تم تسجيل أن بلاغك تلقّى المساعدة.',
  },
  'completed_need_more_help': {
    AppLocale.en: 'Do you need more help?',
    AppLocale.ar: 'هل تحتاج إلى مزيد من المساعدة؟',
  },
  'completed_no_thanks': {
    AppLocale.en: 'No, thank you',
    AppLocale.ar: 'لا، شكرًا',
  },
  'completed_need_more': {
    AppLocale.en: 'I need more help',
    AppLocale.ar: 'أحتاج مساعدة إضافية',
  },
  'completed_rate_service': {
    AppLocale.en: 'Rate this service',
    AppLocale.ar: 'قيّم هذه الخدمة',
  },
  'completed_feedback_hint': {
    AppLocale.en: 'Optional feedback',
    AppLocale.ar: 'ملاحظات (اختياري)',
  },
  'completed_return_home': {
    AppLocale.en: 'Return to home',
    AppLocale.ar: 'العودة إلى الرئيسية',
  },
  'completed_thanks_feedback': {
    AppLocale.en: 'Thank you! Your rating was saved.',
    AppLocale.ar: 'شكراً لك! تم حفظ تقييمك.',
  },

  // --------------------------------------------------------- status stages
  'status_created': {
    AppLocale.en: 'Alert created',
    AppLocale.ar: 'تم إنشاء البلاغ',
  },
  'status_sent': {AppLocale.en: 'Alert sent', AppLocale.ar: 'تم إرسال البلاغ'},
  'status_received': {
    AppLocale.en: 'Alert received',
    AppLocale.ar: 'تم استلام البلاغ',
  },
  'status_assigned': {
    AppLocale.en: 'Responder assigned',
    AppLocale.ar: 'تم تعيين مستجيب',
  },
  'status_help_on_way': {
    AppLocale.en: 'Help is on the way',
    AppLocale.ar: 'المساعدة في الطريق',
  },
  'status_assisted': {
    AppLocale.en: 'Assistance provided',
    AppLocale.ar: 'تم تقديم المساعدة',
  },
  'status_closed': {
    AppLocale.en: 'Incident completed',
    AppLocale.ar: 'تمت معالجة البلاغ',
  },
  'status_cancelled': {AppLocale.en: 'Cancelled', AppLocale.ar: 'ملغى'},

  // --------------------------------------------------------------- assistant
  'assistant_title': {
    AppLocale.en: 'AI Incident Assistant',
    AppLocale.ar: 'مساعد بلاغات الطوارئ الذكي',
  },
  'assistant_disclaimer': {
    AppLocale.en:
        'This assistant provides general guidance only and does not replace emergency professionals.',
    AppLocale.ar:
        'يقدم هذا المساعد إرشادات عامة فقط ولا يُغني عن المختصين في خدمات الطوارئ.',
  },
  'assistant_intro': {
    AppLocale.en:
        "Hi, I'm here to help you describe the emergency. Choose an option below or type your own message.",
    AppLocale.ar:
        'مرحبًا، أنا هنا لمساعدتك في وصف الحالة الطارئة. اختر خيارًا أدناه أو اكتب رسالتك.',
  },
  'assistant_ask_type': {
    AppLocale.en: 'What type of emergency are you facing?',
    AppLocale.ar: 'ما نوع الحالة الطارئة التي تواجهها؟',
  },
  'assistant_ask_injured': {
    AppLocale.en: 'How many people are injured?',
    AppLocale.ar: 'كم عدد الأشخاص المصابين؟',
  },
  'assistant_ask_conscious': {
    AppLocale.en: 'Are you conscious and able to move safely?',
    AppLocale.ar: 'هل أنت واعٍ وقادر على الحركة بأمان؟',
  },
  'assistant_ask_location': {
    AppLocale.en: 'Would you like to attach your current location?',
    AppLocale.ar: 'هل ترغب في إرفاق موقعك الحالي؟',
  },
  'assistant_ask_note': {
    AppLocale.en: 'Any additional detail you want to add? (or type "no")',
    AppLocale.ar: 'هل هناك تفاصيل إضافية تود إضافتها؟ (أو اكتب "لا")',
  },
  'assistant_summary_title': {
    AppLocale.en: 'Incident summary',
    AppLocale.ar: 'ملخص الحادثة',
  },
  'assistant_summary_type': {
    AppLocale.en: 'Incident type',
    AppLocale.ar: 'نوع الحادثة',
  },
  'assistant_summary_injured': {
    AppLocale.en: 'Number of injured people',
    AppLocale.ar: 'عدد المصابين',
  },
  'assistant_summary_status': {
    AppLocale.en: 'User status',
    AppLocale.ar: 'حالة المستخدم',
  },
  'assistant_summary_location': {
    AppLocale.en: 'Location',
    AppLocale.ar: 'الموقع',
  },
  'assistant_summary_urgency': {
    AppLocale.en: 'Urgency',
    AppLocale.ar: 'مدى الإلحاح',
  },
  'assistant_summary_note': {
    AppLocale.en: 'Additional note',
    AppLocale.ar: 'ملاحظة إضافية',
  },
  'assistant_urgency_high': {AppLocale.en: 'High', AppLocale.ar: 'عالٍ'},
  'assistant_urgency_medium': {AppLocale.en: 'Medium', AppLocale.ar: 'متوسط'},
  'assistant_urgency_low': {AppLocale.en: 'Low', AppLocale.ar: 'منخفض'},
  'assistant_conscious_yes': {AppLocale.en: 'Conscious', AppLocale.ar: 'واعٍ'},
  'assistant_conscious_no': {
    AppLocale.en: 'Not conscious / unclear',
    AppLocale.ar: 'غير واعٍ / غير واضح',
  },
  'assistant_location_attached': {
    AppLocale.en: 'Attached',
    AppLocale.ar: 'مرفق',
  },
  'assistant_location_missing': {
    AppLocale.en: 'Not attached',
    AppLocale.ar: 'غير مرفق',
  },
  'assistant_type_hint': {
    AppLocale.en: 'Type a message...',
    AppLocale.ar: 'اكتب رسالة...',
  },
  'assistant_send': {AppLocale.en: 'Send', AppLocale.ar: 'إرسال'},
  'assistant_urgent_notice': {
    AppLocale.en:
        'If you are in immediate danger, contact official emergency services now.',
    AppLocale.ar: 'إذا كنت في خطر مباشر، فاتصل بخدمات الطوارئ الرسمية فوراً.',
  },
  'assistant_create_incident': {
    AppLocale.en: 'Create a report from this summary',
    AppLocale.ar: 'إنشاء بلاغ من هذا الملخص',
  },
  'assistant_restart': {
    AppLocale.en: 'Start over',
    AppLocale.ar: 'البدء من جديد',
  },
  'assistant_quick_medical': {
    AppLocale.en: 'Medical emergency',
    AppLocale.ar: 'حالة صحية طارئة',
  },
  'assistant_quick_fire': {AppLocale.en: 'Fire', AppLocale.ar: 'حريق'},
  'assistant_quick_accident': {AppLocale.en: 'Accident', AppLocale.ar: 'حادث'},
  'assistant_quick_danger': {
    AppLocale.en: 'Personal danger',
    AppLocale.ar: 'خطر شخصي',
  },
  'assistant_quick_security': {
    AppLocale.en: 'Security issue',
    AppLocale.ar: 'حالة أمنية',
  },
  'assistant_quick_other': {AppLocale.en: 'Other', AppLocale.ar: 'حالة أخرى'},

  // ----------------------------------------------------------------- profile
  'profile_title': {
    AppLocale.en: 'Emergency profile',
    AppLocale.ar: 'ملف الطوارئ',
  },
  'profile_optional_notice': {
    AppLocale.en:
        'All fields are optional. This information is only shown to responders you notify during an emergency.',
    AppLocale.ar:
        'جميع الحقول اختيارية. تُعرض هذه المعلومات فقط للمستجيبين الذين تُخطرهم أثناء الطوارئ.',
  },
  'profile_full_name': {
    AppLocale.en: 'Full name',
    AppLocale.ar: 'الاسم الكامل',
  },
  'profile_phone': {AppLocale.en: 'Phone number', AppLocale.ar: 'رقم الهاتف'},
  'profile_emergency_contact': {
    AppLocale.en: 'Emergency contact',
    AppLocale.ar: 'جهة الاتصال في الطوارئ',
  },
  'profile_blood_type': {
    AppLocale.en: 'Blood type',
    AppLocale.ar: 'فصيلة الدم',
  },
  'profile_allergies': {AppLocale.en: 'Allergies', AppLocale.ar: 'الحساسية'},
  'profile_chronic_conditions': {
    AppLocale.en: 'Chronic conditions',
    AppLocale.ar: 'الأمراض المزمنة',
  },
  'profile_validation_phone': {
    AppLocale.en: 'Enter a valid phone number',
    AppLocale.ar: 'أدخل رقم هاتف صحيح',
  },
  'profile_medication': {
    AppLocale.en: 'Important medication',
    AppLocale.ar: 'أدوية مهمة',
  },
  'profile_notes': {
    AppLocale.en: 'Medical notes',
    AppLocale.ar: 'ملاحظات طبية',
  },
  'profile_org_name': {
    AppLocale.en: 'Organization name',
    AppLocale.ar: 'اسم المؤسسة',
  },
  'profile_id_number': {
    AppLocale.en: 'Student / employee ID',
    AppLocale.ar: 'رقم الطالب / الموظف',
  },
  'profile_saved': {
    AppLocale.en: 'Profile saved',
    AppLocale.ar: 'تم حفظ الملف',
  },

  // ---------------------------------------------------------------- contacts
  'contacts_title': {
    AppLocale.en: 'Trusted contacts',
    AppLocale.ar: 'جهات الاتصال الموثوقة',
  },
  'contacts_add': {
    AppLocale.en: 'Add contact',
    AppLocale.ar: 'إضافة جهة اتصال',
  },
  'contacts_edit': {
    AppLocale.en: 'Edit contact',
    AppLocale.ar: 'تعديل جهة الاتصال',
  },
  'contacts_name': {AppLocale.en: 'Name', AppLocale.ar: 'الاسم'},
  'contacts_phone': {AppLocale.en: 'Phone number', AppLocale.ar: 'رقم الهاتف'},
  'contacts_relationship': {
    AppLocale.en: 'Relationship',
    AppLocale.ar: 'صلة القرابة',
  },
  'contacts_primary': {
    AppLocale.en: 'Primary contact',
    AppLocale.ar: 'جهة الاتصال الأساسية',
  },
  'contacts_set_primary': {
    AppLocale.en: 'Set as primary',
    AppLocale.ar: 'تعيين كجهة أساسية',
  },
  'contacts_notify_during_sos': {
    AppLocale.en: 'Notify during emergency',
    AppLocale.ar: 'إخطار أثناء الطوارئ',
  },
  'contacts_share_live_location': {
    AppLocale.en: 'Share live location',
    AppLocale.ar: 'مشاركة الموقع المباشر',
  },
  'contacts_share_live_location_hint': {
    AppLocale.en:
        'Your location link is included in the SOS text message to this contact.',
    AppLocale.ar: 'يُضاف رابط موقعك إلى رسالة الاستغاثة النصية لهذه الجهة.',
  },
  'contacts_favorites': {AppLocale.en: 'Favorites', AppLocale.ar: 'المفضلة'},
  'contacts_add_new_section': {
    AppLocale.en: 'Add new contact',
    AppLocale.ar: 'إضافة جهة جديدة',
  },
  'contacts_from_device': {
    AppLocale.en: 'From contacts',
    AppLocale.ar: 'من جهات الاتصال',
  },
  'contacts_enter_number': {
    AppLocale.en: 'Enter new number',
    AppLocale.ar: 'إدخال رقم جديد',
  },
  'contacts_call_unsupported': {
    AppLocale.en: "Calling isn't supported on this device/browser.",
    AppLocale.ar: 'الاتصال غير مدعوم على هذا الجهاز/المتصفح.',
  },
  'contacts_message_unsupported': {
    AppLocale.en: "Messaging isn't supported on this device/browser.",
    AppLocale.ar: 'إرسال الرسائل غير مدعوم على هذا الجهاز/المتصفح.',
  },
  'contacts_from_device_unavailable': {
    AppLocale.en:
        'Picking from your phone\'s contacts works in the Android app and in Chrome on Android. On this device, please enter the number manually.',
    AppLocale.ar:
        'اختيار جهة من هاتفك متاح في تطبيق أندرويد وفي متصفح Chrome على أندرويد. على هذا الجهاز أدخل الرقم يدوياً.',
  },
  'contacts_delete_confirm_title': {
    AppLocale.en: 'Delete contact?',
    AppLocale.ar: 'حذف جهة الاتصال؟',
  },
  'contacts_delete_confirm_body': {
    AppLocale.en: 'This contact will be removed from your trusted list.',
    AppLocale.ar: 'ستتم إزالة جهة الاتصال هذه من قائمتك الموثوقة.',
  },
  'contacts_empty': {
    AppLocale.en:
        'No trusted contacts yet. Add one to notify during emergencies.',
    AppLocale.ar:
        'لا توجد جهات اتصال موثوقة بعد. أضف واحدة لإخطارها أثناء الطوارئ.',
  },
  'contacts_simulated_notice': {
    AppLocale.en:
        'Contacts are never messaged automatically. During an SOS you can send them a ready text message with your location in one tap.',
    AppLocale.ar:
        'لا تُرسل أي رسائل تلقائية لجهات الاتصال. أثناء البلاغ يمكنك إرسال رسالة نصية جاهزة بموقعك بضغطة واحدة.',
  },

  // ----------------------------------------------------------------- history
  'history_title': {
    AppLocale.en: 'Incident history',
    AppLocale.ar: 'سجل البلاغات',
  },
  'history_empty': {
    AppLocale.en: 'No past incidents to show yet.',
    AppLocale.ar: 'لا توجد حوادث سابقة لعرضها بعد.',
  },
  'history_incident_number': {
    AppLocale.en: 'Incident',
    AppLocale.ar: 'بلاغ رقم',
  },
  'history_mode_normal': {AppLocale.en: 'Normal', AppLocale.ar: 'عادي'},
  'history_mode_silent': {AppLocale.en: 'Silent', AppLocale.ar: 'صامت'},
  'history_filter_all': {AppLocale.en: 'All', AppLocale.ar: 'الكل'},
  'history_filter_active': {AppLocale.en: 'Active', AppLocale.ar: 'نشط'},
  'history_filter_completed': {
    AppLocale.en: 'Completed',
    AppLocale.ar: 'مكتمل',
  },
  'history_filter_cancelled': {AppLocale.en: 'Cancelled', AppLocale.ar: 'ملغى'},

  // ------------------------------------------------------------ incident details
  'details_title': {
    AppLocale.en: 'Incident details',
    AppLocale.ar: 'تفاصيل الحادثة',
  },
  'details_timeline': {AppLocale.en: 'Timeline', AppLocale.ar: 'الجدول الزمني'},
  'details_location': {AppLocale.en: 'Location', AppLocale.ar: 'الموقع'},
  'details_type': {AppLocale.en: 'Emergency type', AppLocale.ar: 'نوع الطارئة'},
  'details_description': {AppLocale.en: 'Description', AppLocale.ar: 'الوصف'},
  'details_mode': {AppLocale.en: 'Alert mode', AppLocale.ar: 'وضع التنبيه'},
  'details_recommended_hospital': {
    AppLocale.en: 'Recommended hospital',
    AppLocale.ar: 'المستشفى الموصى به',
  },
  'details_responder': {
    AppLocale.en: 'Responder (simulated)',
    AppLocale.ar: 'المستجيب (محاكاة)',
  },
  'details_final_status': {
    AppLocale.en: 'Current status',
    AppLocale.ar: 'الحالة الحالية',
  },
  'details_responder_name': {
    AppLocale.en: 'Prototype Responder Unit 1',
    AppLocale.ar: 'وحدة استجابة تجريبية 1',
  },
  'details_no_description': {
    AppLocale.en: 'No description provided',
    AppLocale.ar: 'لا يوجد وصف',
  },

  // ---------------------------------------------------------------- hospitals
  'hospitals_title': {
    AppLocale.en: 'Smart hospital routing',
    AppLocale.ar: 'التوجيه الذكي للمستشفيات',
  },
  'hospitals_subtitle': {
    AppLocale.en:
        'Real nearby hospitals and clinics from OpenStreetMap. The recommendation weighs real distance, estimated waiting time and the emergency type.',
    AppLocale.ar:
        'مستشفيات وعيادات حقيقية قريبة من OpenStreetMap. تراعي التوصية المسافة الحقيقية ووقت الانتظار التقديري ونوع الحالة.',
  },
  'hospitals_disclaimer': {
    AppLocale.en:
        'Hospital congestion and waiting-time information are simulated prototype estimates and may not reflect current hospital conditions.',
    AppLocale.ar:
        'معلومات ازدحام المستشفى ووقت الانتظار تقديرية في النسخة التجريبية وقد لا تعكس الحالة الفعلية للمستشفى.',
  },
  'hospitals_travel_time': {
    AppLocale.en: 'Travel time',
    AppLocale.ar: 'وقت الوصول',
  },
  'hospitals_congestion': {
    AppLocale.en: 'Congestion',
    AppLocale.ar: 'الازدحام',
  },
  'hospitals_wait_time': {
    AppLocale.en: 'Estimated waiting time',
    AppLocale.ar: 'وقت الانتظار التقديري',
  },
  'hospitals_category_hospital': {
    AppLocale.en: 'Hospital',
    AppLocale.ar: 'مستشفى',
  },
  'hospitals_category_clinic': {AppLocale.en: 'Clinic', AppLocale.ar: 'عيادة'},
  'hospitals_emergency_yes': {
    AppLocale.en: 'Emergency department available',
    AppLocale.ar: 'يتوفر قسم طوارئ',
  },
  'hospitals_emergency_no': {
    AppLocale.en: 'No emergency department',
    AppLocale.ar: 'لا يوجد قسم طوارئ',
  },
  'hospitals_phone': {AppLocale.en: 'Phone', AppLocale.ar: 'الهاتف'},
  'hospitals_website': {
    AppLocale.en: 'Website',
    AppLocale.ar: 'الموقع الإلكتروني',
  },
  'hospitals_hours': {AppLocale.en: 'Hours', AppLocale.ar: 'ساعات العمل'},
  'hospitals_recommended_badge': {
    AppLocale.en: 'Recommended',
    AppLocale.ar: 'موصى به',
  },
  'hospitals_compare': {
    AppLocale.en: 'Other nearby hospitals',
    AppLocale.ar: 'مستشفيات قريبة أخرى',
  },
  'hospitals_open_maps': {
    AppLocale.en: 'Open in Google Maps',
    AppLocale.ar: 'فتح في خرائط جوجل',
  },
  'hospitals_congestion_low': {AppLocale.en: 'Low', AppLocale.ar: 'منخفض'},
  'hospitals_congestion_moderate': {
    AppLocale.en: 'Moderate',
    AppLocale.ar: 'متوسط',
  },
  'hospitals_congestion_high': {AppLocale.en: 'High', AppLocale.ar: 'مرتفع'},
  'hospitals_min_short': {AppLocale.en: 'min', AppLocale.ar: 'د'},
  'hospitals_km_short': {AppLocale.en: 'km', AppLocale.ar: 'كم'},
  'hospitals_reason_prefix': {
    AppLocale.en: 'Why recommended:',
    AppLocale.ar: 'سبب التوصية:',
  },
  'hospitals_reason_wait': {
    AppLocale.en: 'shorter estimated waiting time',
    AppLocale.ar: 'وقت انتظار متوقع أقصر',
  },
  'hospitals_reason_congestion': {
    AppLocale.en: 'less congested',
    AppLocale.ar: 'ازدحام أقل',
  },
  'hospitals_reason_nearest': {
    AppLocale.en: 'closest to you',
    AppLocale.ar: 'الأقرب إليك',
  },
  'hospitals_details_title': {
    AppLocale.en: 'Hospital details',
    AppLocale.ar: 'تفاصيل المستشفى',
  },
  'estimated_prototype_value': {
    AppLocale.en: 'Estimated prototype value',
    AppLocale.ar: 'قيمة تقديرية في النسخة التجريبية',
  },
  'maps_open_failed': {
    AppLocale.en: "Couldn't open Google Maps on this device/browser.",
    AppLocale.ar: 'تعذر فتح خرائط جوجل على هذا الجهاز/المتصفح.',
  },
  'hospitals_loading': {
    AppLocale.en: 'Loading nearby hospitals...',
    AppLocale.ar: 'جارٍ تحميل المستشفيات القريبة...',
  },
  'hospitals_retry': {AppLocale.en: 'Retry', AppLocale.ar: 'إعادة المحاولة'},
  'hospitals_request_permission': {
    AppLocale.en: 'Enable location',
    AppLocale.ar: 'تفعيل الموقع',
  },
  'hospitals_location_error_service_disabled': {
    AppLocale.en: 'Location services are turned off on this device/browser.',
    AppLocale.ar: 'خدمات تحديد الموقع متوقفة على هذا الجهاز/المتصفح.',
  },
  'hospitals_location_error_permission_denied': {
    AppLocale.en: 'Location permission was denied.',
    AppLocale.ar: 'تم رفض إذن الوصول إلى الموقع.',
  },
  'hospitals_location_error_permission_denied_forever': {
    AppLocale.en:
        'Location permission is permanently denied. Enable it from your browser/device settings.',
    AppLocale.ar:
        'تم رفض إذن الموقع بشكل دائم. فعّله من إعدادات المتصفح/الجهاز.',
  },
  'hospitals_location_error_timeout': {
    AppLocale.en: 'Location detection timed out.',
    AppLocale.ar: 'انتهت مهلة تحديد الموقع.',
  },
  'hospitals_location_error_unknown': {
    AppLocale.en: 'Could not detect your current location.',
    AppLocale.ar: 'تعذر تحديد موقعك الحالي.',
  },
  'hospitals_osm_attribution': {
    AppLocale.en: 'Hospital data © OpenStreetMap contributors',
    AppLocale.ar: 'بيانات المستشفيات © مساهمو OpenStreetMap',
  },
  'hospitals_overpass_error_no_results': {
    AppLocale.en:
        'No hospitals or clinics found on OpenStreetMap near your location.',
    AppLocale.ar:
        'لم يتم العثور على مستشفيات أو عيادات في OpenStreetMap بالقرب من موقعك.',
  },
  'hospitals_overpass_error_timeout': {
    AppLocale.en: 'The OpenStreetMap servers took too long to answer.',
    AppLocale.ar: 'استغرقت خوادم OpenStreetMap وقتاً طويلاً في الرد.',
  },
  'hospitals_overpass_error_server': {
    AppLocale.en: "OpenStreetMap's Overpass service returned an error.",
    AppLocale.ar: 'أعادت خدمة Overpass التابعة لـ OpenStreetMap خطأً.',
  },
  'hospitals_overpass_error_network': {
    AppLocale.en: 'Could not reach OpenStreetMap - check your connection.',
    AppLocale.ar: 'تعذر الوصول إلى OpenStreetMap - تحقق من اتصالك بالإنترنت.',
  },

  // -------------------------------------------------------------------- maps
  'maps_title': {
    AppLocale.en: 'Nearby assistance',
    AppLocale.ar: 'المساعدة القريبة',
  },
  'maps_current_location': {
    AppLocale.en: 'Current location',
    AppLocale.ar: 'الموقع الحالي',
  },
  'maps_hospitals': {AppLocale.en: 'Hospitals', AppLocale.ar: 'المستشفيات'},
  'maps_police': {AppLocale.en: 'Police', AppLocale.ar: 'الشرطة'},
  'maps_fire': {AppLocale.en: 'Fire stations', AppLocale.ar: 'الإطفاء'},
  'maps_recommended': {
    AppLocale.en: 'Recommended hospital',
    AppLocale.ar: 'المستشفى الموصى به',
  },
  'maps_open_google_maps': {
    AppLocale.en: 'Open in Google Maps',
    AppLocale.ar: 'فتح في خرائط جوجل',
  },
  'maps_distance': {AppLocale.en: 'Distance', AppLocale.ar: 'المسافة'},
  'maps_locate_me': {AppLocale.en: 'Locate me', AppLocale.ar: 'حدد موقعي'},
  'maps_filter_all': {AppLocale.en: 'All', AppLocale.ar: 'الكل'},

  // ---------------------------------------------------------------- settings
  'settings_title': {AppLocale.en: 'Settings', AppLocale.ar: 'الإعدادات'},
  'settings_language': {AppLocale.en: 'Language', AppLocale.ar: 'اللغة'},
  'settings_english': {AppLocale.en: 'English', AppLocale.ar: 'الإنجليزية'},
  'settings_arabic': {AppLocale.en: 'Arabic', AppLocale.ar: 'العربية'},
  'settings_profile': {
    AppLocale.en: 'Emergency profile',
    AppLocale.ar: 'ملف الطوارئ',
  },
  'settings_contacts': {
    AppLocale.en: 'Trusted contacts',
    AppLocale.ar: 'جهات الاتصال الموثوقة',
  },
  'settings_about_title': {
    AppLocale.en: 'About Rescue One',
    AppLocale.ar: 'حول ريسكيو ون',
  },
  'settings_about_body': {
    AppLocale.en:
        'Rescue One is a graduation-project prototype. It does not replace official ambulance, police, fire, or emergency phone services.',
    AppLocale.ar:
        'ريسكيو ون هو نموذج مشروع تخرج، ولا يغني عن خدمات الإسعاف أو الشرطة أو الإطفاء أو أرقام الطوارئ الرسمية.',
  },
  'settings_logout': {AppLocale.en: 'Log out', AppLocale.ar: 'تسجيل الخروج'},
  'logout_confirm_title': {
    AppLocale.en: 'Log out?',
    AppLocale.ar: 'تسجيل الخروج؟',
  },
  'logout_confirm_body': {
    AppLocale.en: 'You will need to sign in again to use the app.',
    AppLocale.ar: 'ستحتاج إلى تسجيل الدخول مجددًا لاستخدام التطبيق.',
  },
  'settings_account': {AppLocale.en: 'Account', AppLocale.ar: 'الحساب'},
  'settings_notifications': {
    AppLocale.en: 'Notifications',
    AppLocale.ar: 'الإشعارات',
  },
  'settings_notifications_hint': {
    AppLocale.en: 'Show an alert and a badge when an incident status changes.',
    AppLocale.ar: 'عرض تنبيه وشارة عند تغيّر حالة البلاغ.',
  },
  'settings_location_settings': {
    AppLocale.en: 'Location settings',
    AppLocale.ar: 'إعدادات الموقع',
  },
  'settings_location_always_on': {
    AppLocale.en: 'Always detect location',
    AppLocale.ar: 'تحديد الموقع دائمًا',
  },
  'settings_location_only_sos': {
    AppLocale.en: 'Only when needed (SOS / hospitals)',
    AppLocale.ar: 'عند الحاجة فقط (البلاغ / المستشفيات)',
  },
  'settings_silent_mode': {
    AppLocale.en: 'Silent emergency mode by default',
    AppLocale.ar: 'وضع الطوارئ الصامت افتراضيًا',
  },
  'settings_silent_mode_hint': {
    AppLocale.en: 'New SOS alerts start with Silent SOS switched on.',
    AppLocale.ar: 'ستبدأ بلاغات الاستغاثة الجديدة بتفعيل النداء الصامت.',
  },
  'settings_dark_mode': {
    AppLocale.en: 'Dark mode',
    AppLocale.ar: 'الوضع الداكن',
  },
  'settings_dark_mode_hint': {
    AppLocale.en: 'Easier on the eyes at night.',
    AppLocale.ar: 'أريح للعين في الليل.',
  },
  'settings_privacy_security': {
    AppLocale.en: 'Privacy and security',
    AppLocale.ar: 'الخصوصية والأمان',
  },
  'settings_privacy_security_body': {
    AppLocale.en:
        'All your data is stored only on this device. The app sends your location only to OpenStreetMap to find nearby hospitals and services - never to a server of its own.',
    AppLocale.ar:
        'تُخزَّن جميع بياناتك على هذا الجهاز فقط. يرسل التطبيق موقعك إلى OpenStreetMap فقط لإيجاد المستشفيات والخدمات القريبة، ولا يرسله إلى أي خادم خاص به.',
  },
  'settings_help_support': {
    AppLocale.en: 'Help and support',
    AppLocale.ar: 'الدعم والمساعدة',
  },

  // ------------------------------------------------------------------ profile
  'profile_screen_title': {
    AppLocale.en: 'Profile',
    AppLocale.ar: 'الملف الشخصي',
  },
  'profile_personal_info': {
    AppLocale.en: 'Personal information',
    AppLocale.ar: 'المعلومات الشخصية',
  },
  'profile_saved_places': {
    AppLocale.en: 'Saved places',
    AppLocale.ar: 'الأماكن المحفوظة',
  },
  'profile_no_saved_places': {
    AppLocale.en: 'No saved places yet.',
    AppLocale.ar: 'لا توجد أماكن محفوظة بعد.',
  },
  'profile_no_email': {
    AppLocale.en: 'No email (guest session)',
    AppLocale.ar: 'بدون بريد إلكتروني (جلسة ضيف)',
  },

  // --------------------------------------------------------- help & support
  'help_title': {
    AppLocale.en: 'Help and support',
    AppLocale.ar: 'الدعم والمساعدة',
  },
  'help_call_support': {
    AppLocale.en: 'Call support',
    AppLocale.ar: 'الاتصال بالدعم',
  },
  'help_chat_support': {
    AppLocale.en: 'WhatsApp chat',
    AppLocale.ar: 'دردشة واتساب',
  },
  'help_chat_prototype_message': {
    AppLocale.en: 'Couldn\'t open WhatsApp on this device.',
    AppLocale.ar: 'تعذر فتح واتساب على هذا الجهاز.',
  },
  'help_email_support': {
    AppLocale.en: 'Email support',
    AppLocale.ar: 'الدعم عبر البريد الإلكتروني',
  },
  'help_faq_title': {
    AppLocale.en: 'Frequently asked questions',
    AppLocale.ar: 'الأسئلة الشائعة',
  },
  'help_faq_q1': {
    AppLocale.en: 'Does this app contact real emergency services?',
    AppLocale.ar: 'هل يتصل هذا التطبيق بخدمات طوارئ حقيقية؟',
  },
  'help_faq_a1': {
    AppLocale.en:
        'No. Alerts and their tracking are simulated in this version. To reach real help, use "Call emergency services": after you confirm, it dials the number set in Settings.',
    AppLocale.ar:
        'لا. البلاغات وتتبعها محاكاة في هذه النسخة. للوصول إلى مساعدة حقيقية استخدم زر «اتصل بخدمات الطوارئ»، فهو يتصل بعد تأكيدك بالرقم المحدد في الإعدادات.',
  },
  'help_faq_q2': {
    AppLocale.en: 'Is my data sent anywhere?',
    AppLocale.ar: 'هل تُرسل بياناتي إلى أي مكان؟',
  },
  'help_faq_a2': {
    AppLocale.en:
        'No server is connected - everything stays on this device. The app only contacts OpenStreetMap to find nearby hospitals and services.',
    AppLocale.ar:
        'لا يوجد خادم متصل - تبقى كل البيانات على هذا الجهاز. يتصل التطبيق فقط بـ OpenStreetMap لإيجاد المستشفيات والخدمات القريبة.',
  },
  'help_center_button': {
    AppLocale.en: 'Email the support team',
    AppLocale.ar: 'راسل فريق الدعم بالبريد',
  },
  'help_prototype_notice': {
    AppLocale.en: 'Call, WhatsApp and email open the apps on your phone.',
    AppLocale.ar: 'الاتصال وواتساب والبريد تفتح التطبيقات على جهازك.',
  },
  'help_hero_title': {
    AppLocale.en: "We're here to help you",
    AppLocale.ar: 'نحن هنا لمساعدتك',
  },
  'help_hero_subtitle': {
    AppLocale.en: 'Reach us anytime',
    AppLocale.ar: 'تواصل معنا في أي وقت',
  },

  // -------------------------------------------------------------- navigation
  'nav_home': {AppLocale.en: 'Home', AppLocale.ar: 'الرئيسية'},
  'nav_hospitals': {AppLocale.en: 'Hospitals', AppLocale.ar: 'المستشفيات'},
  'nav_assistant': {AppLocale.en: 'Assistant', AppLocale.ar: 'المساعد'},
  'nav_history': {AppLocale.en: 'History', AppLocale.ar: 'السجل'},
  'nav_settings': {AppLocale.en: 'Settings', AppLocale.ar: 'الإعدادات'},
  'nav_sos': {AppLocale.en: 'SOS', AppLocale.ar: 'طوارئ'},

  // ---------------------------------------------------------------- common
  'coming_soon': {AppLocale.en: 'Soon', AppLocale.ar: 'قريباً'},
  'retry': {AppLocale.en: 'Retry', AppLocale.ar: 'إعادة المحاولة'},
  'open_in_maps': {
    AppLocale.en: 'Open in Google Maps',
    AppLocale.ar: 'فتح في خرائط جوجل',
  },
  'copy_link': {AppLocale.en: 'Copy link', AppLocale.ar: 'نسخ الرابط'},
  'link_copied': {AppLocale.en: 'Link copied', AppLocale.ar: 'تم نسخ الرابط'},
  'comma': {AppLocale.en: ', ', AppLocale.ar: '، '},
  'just_now': {AppLocale.en: 'just now', AppLocale.ar: 'الآن'},

  // ---------------------------------------------------------------- splash
  'splash_sos_now': {
    AppLocale.en: 'Emergency? Send SOS now',
    AppLocale.ar: 'طوارئ؟ أرسل نداء استغاثة الآن',
  },
  'splash_sos_hint': {
    AppLocale.en: 'No sign-in needed',
    AppLocale.ar: 'بدون تسجيل دخول',
  },

  // ---------------------------------------------------------------- home
  'home_no_hospitals': {
    AppLocale.en: 'No hospitals found nearby yet.',
    AppLocale.ar: 'لا توجد مستشفيات قريبة حالياً.',
  },
  'home_hospitals_loading': {
    AppLocale.en: 'Finding nearby hospitals...',
    AppLocale.ar: 'جارٍ البحث عن المستشفيات القريبة...',
  },
  'home_find_hospitals': {
    AppLocale.en: 'Find nearby hospitals',
    AppLocale.ar: 'ابحث عن المستشفيات القريبة',
  },
  'home_saved_data_short': {
    AppLocale.en: 'Saved list',
    AppLocale.ar: 'قائمة محفوظة',
  },

  // ---------------------------------------------------------------- notifications
  'notifications_title': {
    AppLocale.en: 'Notifications',
    AppLocale.ar: 'الإشعارات',
  },
  'notifications_empty': {
    AppLocale.en: 'No notifications yet. Incident updates will appear here.',
    AppLocale.ar: 'لا توجد إشعارات بعد. ستظهر تحديثات البلاغات هنا.',
  },
  'notifications_mark_read': {
    AppLocale.en: 'Mark all as read',
    AppLocale.ar: 'تعليم الكل كمقروء',
  },
  'notifications_clear': {AppLocale.en: 'Clear all', AppLocale.ar: 'مسح الكل'},
  'notifications_disabled_hint': {
    AppLocale.en:
        'Alerts are turned off in Settings. Updates are still listed here.',
    AppLocale.ar:
        'التنبيهات متوقفة من الإعدادات، لكن التحديثات ما زالت تُسجَّل هنا.',
  },
  'notifications_view': {AppLocale.en: 'View', AppLocale.ar: 'عرض'},

  // ---------------------------------------------------------------- sos
  'sos_notify_contacts': {
    AppLocale.en: 'Text my trusted contacts',
    AppLocale.ar: 'راسل جهات اتصالي الموثوقة',
  },
  'sos_notify_contacts_hint': {
    AppLocale.en:
        'Opens your SMS app with a ready message and your location. You press Send.',
    AppLocale.ar: 'يفتح تطبيق الرسائل برسالة جاهزة وموقعك، وأنت من يضغط إرسال.',
  },
  'sos_no_contacts': {
    AppLocale.en: 'You have no trusted contacts yet.',
    AppLocale.ar: 'لا توجد جهات اتصال موثوقة بعد.',
  },
  'sos_add_contacts': {
    AppLocale.en: 'Add contacts',
    AppLocale.ar: 'إضافة جهات اتصال',
  },
  'sos_sms_intro': {
    AppLocale.en: 'EMERGENCY - I need help',
    AppLocale.ar: 'طوارئ - أحتاج إلى مساعدة',
  },
  'sos_sms_location': {AppLocale.en: 'My location', AppLocale.ar: 'موقعي'},
  'sos_sms_no_location': {
    AppLocale.en: 'Location not available',
    AppLocale.ar: 'الموقع غير متاح',
  },
  'sos_sms_footer': {
    AppLocale.en: 'Sent from Rescue One',
    AppLocale.ar: 'أُرسلت من تطبيق ريسكيو ون',
  },
  'sos_send_sms': {AppLocale.en: 'Send SMS', AppLocale.ar: 'إرسال رسالة'},
  'sos_sms_failed': {
    AppLocale.en: 'Couldn\'t open the SMS app on this device.',
    AppLocale.ar: 'تعذر فتح تطبيق الرسائل على هذا الجهاز.',
  },
  'sos_call_failed': {
    AppLocale.en: 'Couldn\'t open the phone app on this device.',
    AppLocale.ar: 'تعذر فتح تطبيق الهاتف على هذا الجهاز.',
  },
  'sos_your_location': {AppLocale.en: 'Your location', AppLocale.ar: 'موقعك'},
  'sos_location_not_attached': {
    AppLocale.en: 'Location not attached',
    AppLocale.ar: 'لم يُرفق الموقع',
  },
  'sos_route_to_hospital': {
    AppLocale.en: 'Directions',
    AppLocale.ar: 'الاتجاهات',
  },
  'sos_recommended_hospital': {
    AppLocale.en: 'Recommended hospital',
    AppLocale.ar: 'المستشفى الموصى به',
  },
  'sos_no_hospital': {
    AppLocale.en: 'No hospital data available right now.',
    AppLocale.ar: 'لا تتوفر بيانات مستشفيات حالياً.',
  },
  'sos_call_hospital': {
    AppLocale.en: 'Call hospital',
    AppLocale.ar: 'اتصل بالمستشفى',
  },
  'sos_dials_number': {
    AppLocale.en: 'Dials {number}',
    AppLocale.ar: 'يتصل بالرقم {number}',
  },

  // ---------------------------------------------------------------- completed
  'completed_rating_required': {
    AppLocale.en: 'Choose a star rating first.',
    AppLocale.ar: 'اختر عدد النجوم أولاً.',
  },

  // ---------------------------------------------------------------- details
  'details_rating': {AppLocale.en: 'Your rating', AppLocale.ar: 'تقييمك'},
  'details_feedback': {AppLocale.en: 'Your comment', AppLocale.ar: 'ملاحظتك'},

  // ---------------------------------------------------------------- hospitals
  'hospitals_reason_fastest': {
    AppLocale.en: 'shortest estimated time to care (travel + wait)',
    AppLocale.ar: 'أقصر وقت متوقع لتلقي الرعاية (الطريق + الانتظار)',
  },
  'hospitals_reason_er': {
    AppLocale.en: 'has an emergency department',
    AppLocale.ar: 'يوجد به قسم طوارئ',
  },
  'hospitals_reason_full_hospital': {
    AppLocale.en: 'a full hospital - better than a clinic for this case',
    AppLocale.ar: 'مستشفى متكامل - أنسب من العيادة لهذه الحالة',
  },
  'hospitals_reason_balance': {
    AppLocale.en: 'best balance of distance and waiting time',
    AppLocale.ar: 'أفضل توازن بين المسافة ووقت الانتظار',
  },
  'hospitals_reason_only': {
    AppLocale.en: 'the only facility found nearby',
    AppLocale.ar: 'المنشأة الوحيدة القريبة',
  },
  'hospitals_saved_data': {
    AppLocale.en: 'Showing the list saved on {time}. Pull down to refresh.',
    AppLocale.ar: 'تُعرض القائمة المحفوظة بتاريخ {time}. اسحب للأسفل للتحديث.',
  },
  'hospitals_recommend_for': {
    AppLocale.en: 'Recommend for',
    AppLocale.ar: 'التوصية لحالة',
  },
  'hospitals_empty': {
    AppLocale.en: 'No hospitals to show yet.',
    AppLocale.ar: 'لا توجد مستشفيات لعرضها بعد.',
  },
  'hospitals_save_place': {
    AppLocale.en: 'Save place',
    AppLocale.ar: 'حفظ المكان',
  },
  'hospitals_place_saved': {
    AppLocale.en: 'Saved to your places',
    AppLocale.ar: 'تم الحفظ في أماكنك',
  },
  'hospitals_already_saved': {
    AppLocale.en: 'Already in your saved places',
    AppLocale.ar: 'موجود في أماكنك المحفوظة',
  },
  'hospitals_emergency_unknown': {
    AppLocale.en: 'Emergency department: not listed',
    AppLocale.ar: 'قسم الطوارئ: غير مذكور',
  },

  // ---------------------------------------------------------------- maps
  'maps_pharmacies': {AppLocale.en: 'Pharmacies', AppLocale.ar: 'الصيدليات'},
  'maps_kind_hospital': {AppLocale.en: 'Hospital', AppLocale.ar: 'مستشفى'},
  'maps_kind_clinic': {AppLocale.en: 'Clinic', AppLocale.ar: 'عيادة'},
  'maps_kind_police': {
    AppLocale.en: 'Police station',
    AppLocale.ar: 'مركز شرطة',
  },
  'maps_kind_fire': {AppLocale.en: 'Fire station', AppLocale.ar: 'مركز إطفاء'},
  'maps_kind_pharmacy': {AppLocale.en: 'Pharmacy', AppLocale.ar: 'صيدلية'},
  'maps_services_loading': {
    AppLocale.en: 'Loading nearby services...',
    AppLocale.ar: 'جارٍ تحميل الخدمات القريبة...',
  },
  'maps_services_error': {
    AppLocale.en:
        'Couldn\'t load police, fire stations and pharmacies right now.',
    AppLocale.ar: 'تعذر تحميل مراكز الشرطة والإطفاء والصيدليات حالياً.',
  },
  'maps_no_places': {
    AppLocale.en: 'No places of this type found within 10 km.',
    AppLocale.ar: 'لم يُعثر على أماكن من هذا النوع ضمن 10 كم.',
  },
  'maps_real_data_notice': {
    AppLocale.en:
        'All places are real, from OpenStreetMap. Tap a place to open it in Google Maps.',
    AppLocale.ar:
        'كل الأماكن حقيقية من OpenStreetMap. اضغط على أي مكان لفتحه في خرائط جوجل.',
  },
  'maps_need_location': {
    AppLocale.en: 'Allow location access to see what is near you.',
    AppLocale.ar: 'اسمح بالوصول إلى الموقع لرؤية ما حولك.',
  },

  // ---------------------------------------------------------------- saved places
  'saved_places_add_current': {
    AppLocale.en: 'Save my current location',
    AppLocale.ar: 'حفظ موقعي الحالي',
  },
  'saved_places_name': {AppLocale.en: 'Place name', AppLocale.ar: 'اسم المكان'},
  'saved_places_name_hint': {
    AppLocale.en: 'e.g. Home, Work',
    AppLocale.ar: 'مثل: المنزل، العمل',
  },
  'saved_places_note': {
    AppLocale.en: 'Note (optional)',
    AppLocale.ar: 'ملاحظة (اختياري)',
  },
  'saved_places_locating': {
    AppLocale.en: 'Getting your location...',
    AppLocale.ar: 'جارٍ تحديد موقعك...',
  },
  'saved_places_location_failed': {
    AppLocale.en: 'Couldn\'t get your location. Check the location permission.',
    AppLocale.ar: 'تعذر تحديد موقعك. تحقق من إذن الموقع.',
  },
  'saved_places_saved': {
    AppLocale.en: 'Place saved',
    AppLocale.ar: 'تم حفظ المكان',
  },
  'saved_places_delete_confirm': {
    AppLocale.en: 'Delete this place?',
    AppLocale.ar: 'حذف هذا المكان؟',
  },
  'saved_places_validation_name': {
    AppLocale.en: 'Enter a name for this place',
    AppLocale.ar: 'أدخل اسماً لهذا المكان',
  },

  // ---------------------------------------------------------------- settings
  'settings_emergency_number': {
    AppLocale.en: 'Emergency number',
    AppLocale.ar: 'رقم الطوارئ',
  },
  'settings_emergency_number_hint': {
    AppLocale.en:
        'Dialled by "Call emergency services". Set it for your country.',
    AppLocale.ar:
        'الرقم الذي يتصل به زر «اتصل بخدمات الطوارئ». اضبطه حسب بلدك.',
  },
  'settings_emergency_number_custom': {
    AppLocale.en: 'Other number',
    AppLocale.ar: 'رقم آخر',
  },
  'settings_emergency_number_invalid': {
    AppLocale.en: 'Enter 2 to 6 digits.',
    AppLocale.ar: 'أدخل من 2 إلى 6 أرقام.',
  },
  'settings_emergency_number_saved': {
    AppLocale.en: 'Emergency number updated',
    AppLocale.ar: 'تم تحديث رقم الطوارئ',
  },
  'settings_data': {AppLocale.en: 'Data', AppLocale.ar: 'البيانات'},
  'settings_delete_all': {
    AppLocale.en: 'Delete all data on this device',
    AppLocale.ar: 'حذف كل البيانات من هذا الجهاز',
  },
  'settings_delete_all_confirm_body': {
    AppLocale.en:
        'This deletes your incidents, contacts, medical profile, saved places, notifications and settings, and signs you out. It cannot be undone.',
    AppLocale.ar:
        'سيؤدي هذا إلى حذف بلاغاتك وجهات الاتصال والملف الطبي والأماكن المحفوظة والإشعارات والإعدادات، وتسجيل خروجك. لا يمكن التراجع عن ذلك.',
  },
  'settings_delete_all_done': {
    AppLocale.en: 'All data deleted',
    AppLocale.ar: 'تم حذف كل البيانات',
  },

  // ---------------------------------------------------------------- contacts
  'contacts_validation_name': {
    AppLocale.en: 'Enter a name',
    AppLocale.ar: 'أدخل الاسم',
  },
  'contacts_validation_phone': {
    AppLocale.en: 'Enter a valid phone number',
    AppLocale.ar: 'أدخل رقم هاتف صحيح',
  },
  'contacts_relationship_hint': {
    AppLocale.en: 'e.g. Brother, Friend',
    AppLocale.ar: 'مثل: أخ، صديق',
  },

  // ---------------------------------------------------------------- profile
  'profile_blood_unknown': {
    AppLocale.en: 'Don\'t know',
    AppLocale.ar: 'لا أعرف',
  },

  // ---------------------------------------------------------------- assistant
  'assistant_not_understood_injured': {
    AppLocale.en: 'Please answer with a number: 0, 1, 2 or 3+.',
    AppLocale.ar: 'من فضلك أجب برقم: 0 أو 1 أو 2 أو +3.',
  },
  'assistant_not_understood_yes_no': {
    AppLocale.en: 'Please answer Yes or No.',
    AppLocale.ar: 'من فضلك أجب بنعم أو لا.',
  },
  'assistant_type_detected': {
    AppLocale.en: 'Understood: {type}.',
    AppLocale.ar: 'فهمت: {type}.',
  },
  'assistant_type_unknown': {
    AppLocale.en:
        'I couldn\'t tell the type, so I\'ll mark it as Other and keep your description.',
    AppLocale.ar:
        'لم أتمكن من تحديد النوع، لذا سأسجّله كـ«حالة أخرى» مع الاحتفاظ بوصفك.',
  },
  'assistant_location_ok': {
    AppLocale.en: 'Location attached.',
    AppLocale.ar: 'تم إرفاق الموقع.',
  },
  'assistant_location_failed': {
    AppLocale.en:
        'I couldn\'t get your location. You can still create the report.',
    AppLocale.ar: 'تعذر تحديد موقعك، ويمكنك إنشاء البلاغ مع ذلك.',
  },
  'assistant_critical_detected': {
    AppLocale.en:
        'This sounds life-threatening. If you can, call emergency services now.',
    AppLocale.ar: 'يبدو أن الحالة تهدد الحياة. إن استطعت، اتصل بالطوارئ الآن.',
  },
  'assistant_call_now': {
    AppLocale.en: 'Call {number} now',
    AppLocale.ar: 'اتصل بـ {number} الآن',
  },

  // ---------------------------------------------------------------- help faq
  'help_faq_q3': {
    AppLocale.en: 'How is the recommended hospital chosen?',
    AppLocale.ar: 'كيف يُختار المستشفى الموصى به؟',
  },
  'help_faq_a3': {
    AppLocale.en:
        'By the estimated time until care: the real travel distance plus the estimated waiting time. For medical cases and accidents, full hospitals with an emergency department are preferred over clinics.',
    AppLocale.ar:
        'حسب الوقت المتوقع حتى تلقي الرعاية: المسافة الحقيقية مع وقت الانتظار التقديري. وفي الحالات الطبية والحوادث تُفضَّل المستشفيات التي بها قسم طوارئ على العيادات.',
  },
  'help_faq_q4': {
    AppLocale.en: 'Can I change the emergency number?',
    AppLocale.ar: 'هل يمكنني تغيير رقم الطوارئ؟',
  },
  'help_faq_a4': {
    AppLocale.en: 'Yes - Settings > Emergency number. The default is 999.',
    AppLocale.ar: 'نعم - من الإعدادات > رقم الطوارئ. الرقم الافتراضي 999.',
  },
  'help_faq_q5': {
    AppLocale.en: 'Does it work without internet?',
    AppLocale.ar: 'هل يعمل بدون إنترنت؟',
  },
  'help_faq_a5': {
    AppLocale.en:
        'Mostly. Your data is on the device, and the last downloaded hospital list is saved and shown when you are offline. Calls go through your phone as usual.',
    AppLocale.ar:
        'في الغالب نعم. بياناتك على الجهاز، وتُحفظ آخر قائمة مستشفيات وتُعرض عند انقطاع الإنترنت. والاتصال يتم عبر هاتفك كالمعتاد.',
  },

  // ------------------------------------------------------- v1.2 additions
  'contacts_from_device_hint': {
    AppLocale.en: 'Choose a contact saved on your phone',
    AppLocale.ar: 'اختر جهة محفوظة في هاتفك',
  },
  'help_whatsapp_greeting': {
    AppLocale.en: 'Hello, I need help with the Rescue One app.',
    AppLocale.ar: 'مرحباً، أحتاج مساعدة بخصوص تطبيق ريسكيو ون.',
  },
  'details_delete_incident': {
    AppLocale.en: 'Delete incident',
    AppLocale.ar: 'حذف البلاغ',
  },
  'details_delete_confirm_body': {
    AppLocale.en:
        'This incident will be removed from your history. This cannot be undone.',
    AppLocale.ar: 'سيُحذف هذا البلاغ من سجلك. لا يمكن التراجع عن ذلك.',
  },
  'details_deleted': {
    AppLocale.en: 'Incident deleted',
    AppLocale.ar: 'تم حذف البلاغ',
  },
};
