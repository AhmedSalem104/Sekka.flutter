abstract final class AppStrings {
  // App
  static const String appName = 'سِكّة';
  static const String appTagline = 'شريك شغلك في الديليفري';

  // Auth — General
  static const String welcome = 'أهلاً بيك!';
  static const String welcomeSubtitle = 'سجّل دخولك أو افتح حساب جديد';
  static const String login = 'دخول';
  static const String signUp = 'حساب جديد';
  static const String tryWithoutRegister = 'جرّب التطبيق من غير تسجيل';

  // Auth — Login
  static const String enterPhone = 'رقم الموبايل';
  static const String enterPhoneHint = 'مثال: ٠١٠١٢٣٤٥٦٧٨';
  static const String enterPassword = 'كلمة السر';
  static const String forgotPassword = 'نسيت كلمة السر؟';

  // Auth — OTP
  static const String otpVerification = 'كود التحقق';
  static const String otpSentTo = 'بعتنالك كود على الرقم';
  static const String enterOtpCode = 'أدخل الكود';
  static const String resendOtp = 'ابعتلي الكود تاني';
  static const String resendIn = 'إعادة الإرسال بعد';
  static const String seconds = 'ثانية';
  static const String sendVerificationCode = 'ابعتلي الكود';
  static const String verify = 'تأكيد';

  // Auth — Register
  static const String completeProfile = 'كمّل بياناتك';
  static const String completeProfileSubtitle = 'عايزين نعرفك أكتر';
  static const String driverName = 'اسمك إيه؟';
  static const String password = 'كلمة السر';
  static const String passwordHint = '٦ حروف أو أرقام على الأقل';
  static const String confirmPassword = 'كلمة السر تاني';
  static const String vehicleType = 'بتوصّل بإيه؟';
  static const String emailOptional = 'الإيميل (مش لازم)';
  static const String createAccount = 'يلا نسجّل!';

  // Auth — Forgot / Reset Password
  static const String resetPassword = 'كلمة سر جديدة';
  static const String forgotPasswordSubtitle = 'اكتب رقم موبايلك وهنبعتلك كود';
  static const String newPassword = 'كلمة السر الجديدة';
  static const String confirmNewPassword = 'كلمة السر الجديدة تاني';
  static const String passwordResetSuccess = 'تمام! كلمة السر اتغيّرت';

  // Auth — Change Password
  static const String changePassword = 'غيّر كلمة السر';
  static const String currentPassword = 'كلمة السر الحالية';

  // Auth — Success
  static const String accountCreated = 'حسابك جاهز!';
  static const String welcomeToSekka = 'أهلاً بيك في سِكّة\nيلا نبدأ شغل';
  static const String startNow = 'يلا بينا!';

  // Auth — Sessions
  static const String activeSessions = 'الأجهزة النشطة';
  static const String logoutAll = 'اطلع من كل الأجهزة';
  static const String terminateSession = 'اقفل الجلسة دي';

  // Auth — Delete Account
  static const String deleteAccount = 'حذف الحساب';
  static const String deleteAccountWarning = 'متأكد؟ مفيش رجوع بعد كدا!';
  static const String deleteReason = 'قولنا السبب (اختياري)';
  static const String confirmDeletion = 'أيوا امسح';

  // Errors
  static const String networkError = 'النت فصل عندك، شيّك على الاتصال';
  static const String unknownError = 'حصلت مشكلة، جرّب تاني';
  static const String sessionExpired = 'الجلسة خلصت، سجّل دخولك تاني';
  static const String serverError = 'السيرفر تعبان، جرّب بعد شوية';
  static const String timeoutError = 'النت بطيء عندك، جرّب تاني';

  // Validation — friendly
  static const String phoneRequired = 'اكتب رقم الموبايل';
  static const String phoneInvalid = 'الرقم ده مش صح، لازم يكون ١١ رقم مصري';
  static const String passwordRequired = 'اكتب كلمة السر';
  static const String passwordTooShort = 'كلمة السر قصيرة، لازم ٦ حروف على الأقل';
  static const String passwordMismatch = 'كلمتين السر مش زي بعض!';
  static const String otpRequired = 'اكتب الكود اللي وصلك';
  static const String otpInvalid = 'الكود لازم يكون ٤ أرقام';
  static const String nameRequired = 'قولنا اسمك إيه';
  static const String nameTooShort = 'الاسم قصير أوي، حرفين على الأقل';
  static const String emailInvalid = 'الإيميل ده مش صح';
  static const String vehicleTypeRequired = 'اختار بتوصّل بإيه';
  static const String confirmPasswordRequired = 'اكتب كلمة السر تاني';

  // Vehicle Types (Arabic mapping)
  static const Map<String, String> vehicleTypesArabic = {
    'Motorcycle': 'موتوسيكل',
    'Car': 'عربية',
    'Van': 'فان',
    'Truck': 'تراك',
    'Bicycle': 'عجلة',
  };

  // Dialog
  static const String ok = 'تمام';
  static const String errorTitle = 'أوبس!';
  static const String successTitle = 'تمام!';

  // Home
  static const String goodMorning = 'صباح الخير';
  static const String goodEvening = 'مساء الخير';
  static const String todayOrders = 'طلبات اليوم';
  static const String startTrip = 'يلا نبدأ!';
  static const String noOrders = 'مفيش طلبات — أضف طلباتك';

  // Orders
  static const String orders = 'الطلبات';
  static const String addOrder = 'إضافة طلب';
  static const String orderDetails = 'تفاصيل الطلب';
  static const String clientName = 'اسم العميل';
  static const String phone = 'رقم الموبايل';
  static const String address = 'العنوان';
  static const String amount = 'المبلغ';
  static const String note = 'ملاحظة';
  static const String confirmAdd = 'تأكيد وإضافة';
  static const String swipeToDeliver = 'اسحب لإتمام التسليم';
  static const String delivered = 'تم التسليم!';

  // Order Status
  static const String statusNew = 'جديد';
  static const String statusOnTheWay = 'في الطريق';
  static const String statusArrived = 'وصلت';
  static const String statusDelivered = 'تم التسليم';
  static const String statusFailed = 'فشل';
  static const String statusCancelled = 'ملغي';
  static const String statusReturned = 'مرتجع';
  static const String statusPostponed = 'مؤجّل';

  // Wallet
  static const String wallet = 'المحفظة';
  static const String todayEarnings = 'أرباح اليوم';
  static const String totalCollected = 'إجمالي التحصيل';
  static const String netProfit = 'صافي الربح';

  // Settings
  static const String settings = 'الإعدادات';
  static const String profile = 'الملف الشخصي';
  static const String logout = 'تسجيل الخروج';

  // Customers
  static const String customers = 'العملاء';
  static const String customerDetails = 'تفاصيل العميل';
  static const String searchCustomer = 'بحث عن عميل';
  static const String totalDeliveries = 'إجمالي التوصيلات';
  static const String successfulDeliveries = 'توصيلات ناجحة';
  static const String averageRating = 'متوسط التقييم';
  static const String blocked = 'محظور';
  static const String unblocked = 'غير محظور';
  static const String rateCustomer = 'تقييم العميل';
  static const String blockCustomer = 'حظر العميل';
  static const String unblockCustomer = 'إلغاء حظر العميل';
  static const String blockReason = 'سبب الحظر';
  static const String reportToCommunity = 'إبلاغ المجتمع';
  static const String customerBlocked = 'تم حظر العميل بنجاح';
  static const String customerUnblocked = 'تم إلغاء حظر العميل بنجاح';
  static const String voiceMemo = 'مذكرة صوتية';
  static const String interests = 'الاهتمامات';
  static const String engagement = 'مستوى التفاعل';

  // Rating Tags
  static const String quickResponse = 'رد سريع';
  static const String clearAddress = 'عنوان واضح';
  static const String respectfulBehavior = 'تعامل محترم';
  static const String easyPayment = 'دفع سهل';
  static const String wrongAddress = 'عنوان غلط';
  static const String noAnswer = 'مبيردش';
  static const String delayedPickup = 'تأخير في الاستلام';
  static const String paymentIssue = 'مشكلة في الدفع';
  static const String ratingSuccess = 'تم تقييم العميل بنجاح';

  // Partners
  static const String partners = 'الشركاء';
  static const String partnerDetails = 'تفاصيل الشريك';
  static const String searchPartner = 'بحث عن شريك';
  static const String commission = 'العمولة';
  static const String pickupPoints = 'نقاط الاستلام';
  static const String verification = 'التوثيق';
  static const String submitDocument = 'رفع مستند';

  // Partner Types
  static const String restaurantType = 'مطعم';
  static const String shopType = 'محل';
  static const String pharmacyType = 'صيدلية';
  static const String supermarketType = 'سوبرماركت';
  static const String warehouseType = 'مخزن';
  static const String eCommerceType = 'تجارة إلكترونية';

  // Verification Status
  static const String statusPending = 'قيد المراجعة';
  static const String statusVerified = 'موثّق';
  static const String statusRejected = 'مرفوض';
  static const String statusDocumentRequested = 'مطلوب مستند إضافي';

  // Address Types
  static const String addressHome = 'منزل';
  static const String addressWork = 'عمل';
  static const String addressShop = 'محل';
  static const String addressRestaurant = 'مطعم';
  static const String addressWarehouse = 'مخزن';
  static const String addressOther = 'أخرى';

  // Addresses
  static const String addresses = 'العناوين';
  static const String addAddress = 'إضافة عنوان';
  static const String editAddress = 'تعديل العنوان';
  static const String deleteAddressConfirm = 'هل تريد حذف هذا العنوان؟';
  static const String landmarks = 'معالم قريبة';
  static const String deliveryNotes = 'ملاحظات التوصيل';
  static const String nearbyAddresses = 'عناوين قريبة';

  // Caller ID
  static const String callerId = 'معرّف المتصل';
  static const String callerNote = 'ملاحظة عن المتصل';

  // Payment Methods
  static const String paymentCash = 'كاش';
  static const String paymentWallet = 'محفظة';
  static const String paymentCard = 'بطاقة';
  static const String paymentInstaPay = 'إنستاباي';

  // Commission Types
  static const String fixedPerOrder = 'مبلغ ثابت لكل طلب';
  static const String percentagePerOrder = 'نسبة من كل طلب';
  static const String monthlyFlat = 'اشتراك شهري';

  // General
  static const String save = 'حفظ';
  static const String cancel = 'إلغاء';
  static const String confirm = 'تأكيد';
  static const String skip = 'تخطي';
  static const String next = 'التالي';
  static const String back = 'رجوع';
  static const String search = 'بحث...';
  static const String currency = 'ج.م';
  static const String km = 'كم';
  static const String minutes = 'دقيقة';
}
