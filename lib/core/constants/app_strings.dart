abstract final class AppStrings {
  static String _lang = 'ar';
  static void setLocale(String lang) => _lang = lang;
  static bool get _isAr => _lang == 'ar';
  static String get currentLang => _lang;

  // App
  static String get appName => 'سِكّة'; // Brand name — always Arabic
  static String get appTagline =>
      _isAr ? 'شريك شغلك في الديليفري' : 'Your delivery work partner';

  // Bottom Nav
  static String get navHome => _isAr ? 'الرئيسية' : 'Home';
  static String get navOrders => _isAr ? 'الطلبات' : 'Orders';
  static String get navCustomers => _isAr ? 'عملائي' : 'Contacts';
  static String get navWallet => _isAr ? 'جيبي' : 'Wallet';
  static String get navAccounts => _isAr ? 'الحسابات' : 'Accounts';

  // Force Update
  static String get forceUpdateTitle =>
      _isAr ? 'لازم تحدّث التطبيق' : 'Update Required';
  static String get forceUpdateMessage =>
      _isAr ? 'فيه نسخة جديدة مهمة. حدّث عشان تقدر تكمّل.' : 'A critical update is available. Please update to continue.';
  static String get forceUpdateButton =>
      _isAr ? 'حدّث دلوقتي' : 'Update Now';
  static String get optionalUpdateTitle =>
      _isAr ? 'فيه تحديث جديد' : 'Update Available';
  static String get optionalUpdateMessage =>
      _isAr ? 'نسخة جديدة نزلت. عايز تحدّث؟' : 'A new version is available. Would you like to update?';
  static String get later =>
      _isAr ? 'بعدين' : 'Later';

  // Auth — General
  static String get welcome => _isAr ? 'أهلاً بيك!' : 'Welcome!';
  static String get welcomeSubtitle =>
      _isAr ? 'سجّل دخولك أو افتح حساب جديد' : 'Log in or create a new account';
  static String get login => _isAr ? 'دخول' : 'Log In';
  static String get signUp => _isAr ? 'حساب جديد' : 'Sign Up';
  static String get tryWithoutRegister =>
      _isAr ? 'جرّب التطبيق من غير تسجيل' : 'Try the app without signing up';

  // Auth — Login
  static String get enterPhone => _isAr ? 'رقم الموبايل' : 'Phone number';
  static String get enterPhoneHint =>
      _isAr ? 'مثال: ٠١٠١٢٣٤٥٦٧٨' : 'e.g. 01012345678';
  static String get enterPassword => _isAr ? 'كلمة السر' : 'Password';
  static String get forgotPassword =>
      _isAr ? 'نسيت كلمة السر؟' : 'Forgot password?';

  // Auth — OTP
  static String get otpVerification =>
      _isAr ? 'كود التحقق' : 'Verification Code';
  static String get otpSentTo =>
      _isAr ? 'بعتنالك كود على الرقم' : 'We sent a code to';
  static String get enterOtpCode => _isAr ? 'أدخل الكود' : 'Enter the code';
  static String get resendOtp =>
      _isAr ? 'ابعتلي الكود تاني' : 'Resend the code';
  static String get resendIn => _isAr ? 'إعادة الإرسال بعد' : 'Resend in';
  static String get seconds => _isAr ? 'ثانية' : 'seconds';
  static String get sendVerificationCode =>
      _isAr ? 'ابعتلي الكود' : 'Send code';
  static String get verify => _isAr ? 'تأكيد' : 'Verify';

  // Auth — Register
  static String get completeProfile =>
      _isAr ? 'كمّل بياناتك' : 'Complete your profile';
  static String get completeProfileSubtitle =>
      _isAr ? 'عايزين نعرفك أكتر' : 'We need a bit more info';
  static String get driverName => _isAr ? 'اسمك إيه؟' : 'Your name';
  static String get password => _isAr ? 'كلمة السر' : 'Password';
  static String get passwordHint =>
      _isAr ? '٦ حروف أو أرقام على الأقل' : 'At least 6 characters';
  static String get confirmPassword =>
      _isAr ? 'كلمة السر تاني' : 'Confirm password';
  static String get vehicleType =>
      _isAr ? 'بتوصّل بإيه؟' : 'Vehicle type';
  static String get emailOptional =>
      _isAr ? 'الإيميل (مش لازم)' : 'Email (optional)';
  static String get createAccount =>
      _isAr ? 'سجّل دلوقتي!' : 'Create Account';

  // Auth — Forgot / Reset Password
  static String get resetPassword =>
      _isAr ? 'كلمة سر جديدة' : 'New Password';
  static String get forgotPasswordSubtitle =>
      _isAr
          ? 'اكتب رقم موبايلك وهنبعتلك كود'
          : 'Enter your phone number and we\'ll send you a code';
  static String get newPassword =>
      _isAr ? 'كلمة السر الجديدة' : 'New password';
  static String get confirmNewPassword =>
      _isAr ? 'كلمة السر الجديدة تاني' : 'Confirm new password';
  static String get passwordResetSuccess =>
      _isAr ? 'تمام! كلمة السر اتغيّرت' : 'Password changed successfully!';

  // Auth — Change Password
  static String get changePassword =>
      _isAr ? 'غيّر كلمة السر' : 'Change Password';
  static String get currentPassword =>
      _isAr ? 'كلمة السر الحالية' : 'Current password';

  // Auth — Success
  static String get accountCreated =>
      _isAr ? 'حسابك جاهز!' : 'Account created!';
  static String get welcomeToSekka =>
      _isAr ? 'أهلاً بيك في سِكّة\nنبدأ شغل' : 'Welcome to Sekka\nLet\'s get to work';
  static String get startNow => _isAr ? 'نبدأ!' : 'Let\'s Go!';

  // Auth — Sessions
  static String get activeSessions =>
      _isAr ? 'الأجهزة النشطة' : 'Active Sessions';
  static String get logoutAll =>
      _isAr ? 'اطلع من كل الأجهزة' : 'Log out all devices';
  static String get terminateSession =>
      _isAr ? 'اقفل الجلسة دي' : 'End this session';

  // Auth — Delete Account
  static String get deleteAccount =>
      _isAr ? 'حذف الحساب' : 'Delete Account';
  static String get deleteAccountWarning =>
      _isAr ? 'متأكد؟ مفيش رجوع بعد كدا!' : 'Are you sure? This cannot be undone!';
  static String get deleteReason =>
      _isAr ? 'قولنا السبب (اختياري)' : 'Reason (optional)';
  static String get confirmDeletion =>
      _isAr ? 'أيوا امسح' : 'Yes, delete';
  static String get deleteAccountTitle =>
      _isAr ? 'حذف الحساب نهائياً' : 'Delete Account Permanently';
  static String get deleteAccountDesc =>
      _isAr
          ? 'لو مسحت حسابك هيبقى موقوف نهائياً ومش هتقدر ترجعه.'
          : 'Your account will be permanently deactivated and cannot be recovered.';
  static String get deleteAccountSendOtp =>
      _isAr ? 'إبعت كود التأكيد' : 'Send Confirmation Code';
  static String get deleteAccountOtpSent =>
      _isAr ? 'بعتنالك كود تأكيد على رقمك' : 'We sent a confirmation code to your phone';
  static String get deleteAccountOtpTitle =>
      _isAr ? 'أدخل كود التأكيد' : 'Enter Confirmation Code';
  static String get deleteAccountConfirm =>
      _isAr ? 'امسح حسابي نهائياً' : 'Delete My Account';
  static String get deleteAccountDeleted =>
      _isAr ? 'اتمسح الحساب بنجاح' : 'Account successfully deleted';

  // Break
  static String get breakSuggestionTitle =>
      _isAr ? 'وقت الاستراحة!' : 'Break Time!';
  static String get breakTakeBreak =>
      _isAr ? 'خذ استراحة دلوقتي' : 'Take a Break Now';
  static String get breakStart =>
      _isAr ? 'ابدأ الاستراحة' : 'Start Break';
  static String get breakEnd =>
      _isAr ? 'إنهاء الاستراحة' : 'End Break';
  static String get breakEndBreak =>
      _isAr ? 'إنهاء الاستراحة' : 'End Break';
  static String get breakActiveTitle =>
      _isAr ? 'في استراحة' : 'On Break';
  static String get breakMinutes =>
      _isAr ? 'دقيقة' : 'min';
  static String get breakLocation =>
      _isAr ? 'مكانك دلوقتي' : 'Your current location';
  static String get breakLocationHint =>
      _isAr ? 'مثال: كافيه، حديقة...' : 'e.g. Cafe, park...';
  static String get breakLocationRequired =>
      _isAr ? 'اكتب مكانك' : 'Enter your location';
  static String get breakEnergyBeforeTitle =>
      _isAr ? 'كيف حالتك الآن؟' : 'How do you feel right now?';
  static String get breakEnergyAfterTitle =>
      _isAr ? 'كيف حالتك بعد الاستراحة؟' : 'How do you feel after the break?';
  static String get breakEnergySubtitle =>
      _isAr ? 'اختار مستوى طاقتك' : 'Select your energy level';
  static String get breakEnergyBefore =>
      _isAr ? 'قبل' : 'Before';
  static String get breakEnergyAfter =>
      _isAr ? 'بعد' : 'After';
  static String get breakHistoryTitle =>
      _isAr ? 'سجل الاستراحات' : 'Break History';
  static String get breakHistoryEmpty =>
      _isAr ? 'مفيش استراحات' : 'No breaks yet';
  static String get breakHistoryEmptyDesc =>
      _isAr ? 'الاستراحات هتظهر هنا' : 'Your breaks will appear here';

  // Energy level labels (Arabic-only, used in energy selector)
  static const String energyLevel1 = 'تعبان';
  static const String energyLevel2 = 'خفيف';
  static const String energyLevel3 = 'معقول';
  static const String energyLevel4 = 'كويس';
  static const String energyLevel5 = 'ممتاز';

  // Errors
  static String get networkError =>
      _isAr ? 'النت فصل عندك، شيّك على الاتصال' : 'No internet connection. Check your network.';
  static String get unknownError =>
      _isAr ? 'حصلت مشكلة، جرّب تاني' : 'Something went wrong. Try again.';
  static String get sessionExpired =>
      _isAr ? 'الجلسة خلصت، سجّل دخولك تاني' : 'Session expired. Please log in again.';
  static String get serverError =>
      _isAr ? 'السيرفر تعبان، جرّب بعد شوية' : 'Server error. Try again later.';
  static String get timeoutError =>
      _isAr ? 'النت بطيء عندك، جرّب تاني' : 'Connection timed out. Try again.';

  // Error Mapper — user-friendly error messages
  static String get passwordComplexity =>
      _isAr ? 'كلمة السر لازم تكون فيها حروف كبيرة وصغيرة وأرقام' : 'Password must contain uppercase, lowercase letters and numbers';
  static String get wrongCredentials =>
      _isAr ? 'رقم الموبايل أو كلمة السر غلط' : 'Wrong phone number or password';
  static String get phoneAlreadyRegistered =>
      _isAr ? 'الرقم ده مسجّل قبل كدا، جرّب تسجّل دخول' : 'This number is already registered. Try logging in.';
  static String get wrongOtpCode =>
      _isAr ? 'الكود غلط، تأكد منه وجرّب تاني' : 'Wrong code. Check and try again.';
  static String get otpExpired =>
      _isAr ? 'الكود خلص وقته، ابعت كود جديد' : 'Code expired. Send a new one.';
  static String get tooManyAttempts =>
      _isAr ? 'جرّبت كتير، استنى شوية وحاول تاني' : 'Too many attempts. Wait and try again.';
  static String get accountSuspended =>
      _isAr ? 'الحساب متوقف، تواصل مع الدعم' : 'Account suspended. Contact support.';
  static String get accountNotFound =>
      _isAr ? 'مفيش حساب بالرقم ده' : 'No account found with this number';
  static String get sessionNotFound =>
      _isAr ? 'الجلسة دي مش موجودة' : 'This session does not exist';
  static String get smsSendFailed =>
      _isAr ? 'مقدرناش نبعت الرسالة، جرّب تاني' : 'Could not send the message. Try again.';
  static String get serviceUnavailable =>
      _isAr ? 'الخدمة مش متاحة دلوقتي، جرّب بعد شوية' : 'Service unavailable. Try again later.';
  static String get somethingWentWrong =>
      _isAr ? 'حصلت مشكلة' : 'Something went wrong';
  static String get noInternetConnection =>
      _isAr ? 'مفيش إنترنت — تأكد من الاتصال' : 'No internet — check your connection';
  static String get requestTimedOut =>
      _isAr ? 'انتهت المهلة — جرّب تاني' : 'Request timed out — try again';
  static String get requestCancelled =>
      _isAr ? 'تم إلغاء الطلب' : 'Request cancelled';
  static String get unexpectedError =>
      _isAr ? 'حصلت مشكلة غير متوقعة' : 'An unexpected error occurred';

  // Time Ago
  static String get justNow => _isAr ? 'الآن' : 'Just now';
  static String minutesAgo(int n) => _isAr ? 'من $n دقيقة' : '$n minutes ago';
  static String hoursAgo(int n) => _isAr ? 'من $n ساعة' : '$n hours ago';
  static String daysAgo(int n) => _isAr ? 'من $n يوم' : '$n days ago';

  // Customers — Search
  static String get searchCustomerHint =>
      _isAr ? 'بحث باسم العميل أو رقمه...' : 'Search by customer name or number...';
  static String get tryDifferentSearch =>
      _isAr ? 'جرّب اسم أو رقم تاني' : 'Try a different name or number';
  static String get noFavoriteCustomers =>
      _isAr ? 'مفيش عملاء مفضلين' : 'No favorite customers';
  static String get addFavoriteCustomerHint =>
      _isAr ? 'اضغطي على القلب في صفحة العميل عشان تضيفيه هنا' : 'Tap the heart on a customer page to add them here';

  // Validation — friendly
  static String get phoneRequired =>
      _isAr ? 'اكتب رقم الموبايل' : 'Phone number is required';
  static String get phoneInvalid =>
      _isAr ? 'الرقم ده مش صح، لازم يكون ١١ رقم مصري' : 'Invalid number. Must be 11 digits.';
  static String get passwordRequired =>
      _isAr ? 'اكتب كلمة السر' : 'Password is required';
  static String get passwordTooShort =>
      _isAr ? 'كلمة السر قصيرة، لازم ٦ حروف على الأقل' : 'Password too short. At least 6 characters.';
  static String get passwordMismatch =>
      _isAr ? 'كلمتين السر مش زي بعض!' : 'Passwords don\'t match!';
  static String get otpRequired =>
      _isAr ? 'اكتب الكود اللي وصلك' : 'Enter the code you received';
  static String get otpInvalid =>
      _isAr ? 'الكود لازم يكون ٤ أرقام' : 'Code must be 4 digits';
  static String get nameRequired =>
      _isAr ? 'قولنا اسمك إيه' : 'Name is required';
  static String get nameTooShort =>
      _isAr ? 'الاسم قصير أوي، حرفين على الأقل' : 'Name too short. At least 2 characters.';
  static String get emailInvalid =>
      _isAr ? 'الإيميل ده مش صح' : 'Invalid email address';
  static String get vehicleTypeRequired =>
      _isAr ? 'اختار بتوصّل بإيه' : 'Select a vehicle type';
  static String get confirmPasswordRequired =>
      _isAr ? 'اكتب كلمة السر تاني' : 'Confirm your password';

  // Vehicle Types
  static const Map<String, String> vehicleTypesArabic = {
    'Motorcycle': 'موتوسيكل',
    'Car': 'عربية',
    'Van': 'فان',
    'Truck': 'تراك',
    'Bicycle': 'عجلة',
  };

  static Map<String, String> get vehicleTypes => _isAr
      ? vehicleTypesArabic
      : const {
          'Motorcycle': 'Motorcycle',
          'Car': 'Car',
          'Van': 'Van',
          'Truck': 'Truck',
          'Bicycle': 'Bicycle',
        };

  // Dialog
  static String get ok => _isAr ? 'تمام' : 'OK';
  static String get errorTitle => _isAr ? 'أوبس!' : 'Oops!';
  static String get successTitle => _isAr ? 'تمام!' : 'Done!';

  // Wallet
  static String get walletTitle => _isAr ? 'محفظتك' : 'Wallet';
  static String get walletNavLabel => _isAr ? 'جيبي' : 'My Wallet';
  static String get walletMoneyWithYou =>
      _isAr ? 'الفلوس اللي معاك' : 'Money with you';
  static String get walletPendingNote =>
      _isAr ? 'منهم للشركاء' : 'Owed to partners';
  static String get walletToday => _isAr ? 'النهارده' : 'Today';
  static String get walletYesterday => _isAr ? 'إمبارح' : 'Yesterday';
  static String get walletSharePdf =>
      _isAr ? 'شارك PDF' : 'Share PDF';

  // Wallet — Transaction Types
  static String get txOrderEarning => _isAr ? 'ربح من طلب' : 'Order Earning';
  static String get txCommission => _isAr ? 'عمولة' : 'Commission';
  static String get txSettlement => _isAr ? 'تسوية' : 'Settlement';
  static String transactionTypeName(int type) => switch (type) {
        0 => txOrderEarning,
        1 => txCommission,
        2 => txSettlement,
        _ => _isAr ? 'معاملة' : 'Transaction',
      };
  static String get pdfWalletSummaryTitle =>
      _isAr ? 'سِكّة — ملخص المحفظة' : 'Sekka — Wallet Summary';
  static String get pdfMoneyWithYou =>
      _isAr ? 'الفلوس اللي معاك' : 'Money with you';
  static String get pdfTotalEarned =>
      _isAr ? 'إجمالي اللي جالك' : 'Total earned';
  static String get pdfTotalSettled =>
      _isAr ? 'إجمالي اللي سلّمته' : 'Total settled';
  static String get pdfPendingPartners =>
      _isAr ? 'لسه للشركاء' : 'Pending for partners';
  static String get pdfTransactionCount =>
      _isAr ? 'عدد المعاملات' : 'Transaction count';
  static String get pdfRecentTransactions =>
      _isAr ? 'آخر المعاملات' : 'Recent transactions';
  static String get pdfGeneratedBy =>
      _isAr ? 'تم الإنشاء من تطبيق سِكّة' : 'Generated by Sekka app';
  static String get pdfShareText =>
      _isAr ? 'ملخص جيبي — سِكّة' : 'Wallet summary — Sekka';
  static String get currentBalance =>
      _isAr ? 'رصيدك عند الشركة' : 'Your balance';
  static String get cashOnHand => _isAr ? 'كاش معاك (فلوس شغل)' : 'Cash with you (work money)';
  static String get pendingAmount => _isAr ? 'لازم ترجعه للشركاء' : 'Owed to partners';
  static String get todayCollected =>
      _isAr ? 'حصّلت النهارده' : 'Collected today';
  static String get todayCommissions =>
      _isAr ? 'عمولتك النهارده' : 'Your commission today';
  static String get availableBalance =>
      _isAr ? 'تقدر تسحب' : 'Available to withdraw';
  static String get newSettlement =>
      _isAr ? 'سلّم فلوس' : 'Settle Cash';
  static String get allTransactions => _isAr ? 'الكل' : 'All';
  static String get incomeFilter => _isAr ? 'جالك' : 'Income';
  static String get expenseFilter => _isAr ? 'راح منك' : 'Expenses';
  static String get settlementsFilter => _isAr ? 'سلّمته' : 'Settled';
  static String get noTransactions =>
      _isAr ? 'مفيش حركات لسه — لما تشتغل هتلاقيها هنا' : 'No transactions yet — they\'ll appear here once you start';
  static String get cashStatusSafe =>
      _isAr ? 'كاشك لسه في الأمان' : 'Your cash is safe';
  static String get cashStatusWarning =>
      _isAr ? 'الكاش بدأ يكتر، فكّر تسلّم' : 'Cash is piling up, consider settling';
  static String get cashStatusDanger =>
      _isAr ? 'الكاش كتر عندك، سلّم بسرعة!' : 'Too much cash! Settle soon!';
  static String get cashStatusCritical =>
      _isAr ? 'خطر! لازم تسلّم الفلوس دلوقتي!' : 'Danger! You must settle now!';

  // Wallet — Hints
  static String get hintWalletBalance =>
      _isAr
          ? 'ده كل اللي معاك — كاش + فلوس في المحفظة'
          : 'This is everything you have — cash + wallet balance';
  static String get hintCashStatus =>
      _isAr
          ? 'لما الشريط يوصل للأحمر يبقى عندك كاش كتير ومحتاج تسلّم'
          : 'When the bar turns red, you have too much cash and need to settle';
  static String get hintWalletSummary =>
      _isAr
          ? 'ده ملخص حركاتك — فلوس دخلت، فلوس طلعت، وفلوس سلّمتها'
          : 'Your summary — money in, money out, and money settled';

  // Account Handover (Settlement)
  static String get accountHandover =>
      _isAr ? 'الحسابات' : 'Accounts';
  static String get accountHandoverSubtitle =>
      _isAr ? 'سلّم فلوس شركائك بسهولة' : 'Settle partner money easily';
  static String get settlementsTitle =>
      _isAr ? 'التسليمات' : 'Handovers';
  static String get createSettlement =>
      _isAr ? 'سلّم فلوس' : 'Settle Cash';
  static String get newHandover =>
      _isAr ? 'سلّم فلوس' : 'Settle Cash';
  static String get settlementAmount => _isAr ? 'هتسلّم كام؟' : 'Amount to settle';
  static String get settlementType =>
      _isAr ? 'هتسلّم إزاي؟' : 'How will you pay?';
  static String get settlementPartner => _isAr ? 'هتسلّم لمين؟' : 'Settle to whom?';
  static String get settlementNotes => _isAr ? 'عايز تضيف حاجة؟' : 'Any notes?';
  static String get orderCount => _isAr ? 'عدد الطلبات' : 'Order count';
  static String get sendWhatsApp =>
      _isAr ? 'ابعتله واتساب' : 'Send WhatsApp';
  static String get callNow => _isAr ? 'كلّمه دلوقتي' : 'Call now';
  static String get copyNumber => _isAr ? 'انسخ الرقم' : 'Copy number';
  static String get uploadReceipt =>
      _isAr ? 'صوّر الوصل' : 'Upload receipt';
  static String get todaySettlements =>
      _isAr ? 'سلّمت النهارده' : 'Settled today';
  static String get noSettlements =>
      _isAr ? 'مسلّمتش حاجة لسه' : 'No handovers yet';
  static String get settlementCashToPartner =>
      _isAr ? 'كاش في إيده' : 'Cash in hand';
  static String get settlementBankTransfer =>
      _isAr ? 'حوالة بنكي' : 'Bank transfer';
  static String get settlementVodafoneCash =>
      _isAr ? 'فودافون كاش' : 'Vodafone Cash';
  static String get settlementInstapay =>
      _isAr ? 'إنستاباي' : 'InstaPay';
  static String get settlementFawry => _isAr ? 'فوري' : 'Fawry';

  // Account Handover — Summary
  static String get dailySummary =>
      _isAr ? 'يومك النهاردا' : 'Today\'s Summary';
  static String get totalCollectedToday =>
      _isAr ? 'جمعت من العملاء' : 'Collected from customers';
  static String get totalSettledToday =>
      _isAr ? 'رجّعت للشركاء' : 'Returned to partners';
  static String get remainingBalance =>
      _isAr ? 'لسه معاك' : 'Still with you';
  static String get pendingPartnersCount =>
      _isAr ? 'شركاء مستنيين' : 'Partners waiting';
  static String get settlementCountToday =>
      _isAr ? 'عدد التسليمات' : 'Handovers';

  // Account Handover — Partner Balance
  static String get partnerBalance =>
      _isAr ? 'حساب الشريك' : 'Partner balance';
  static String get pendingOrderCount =>
      _isAr ? 'طلبات لسه مخلصتش' : 'Unfinished orders';
  static String get pendingBalance =>
      _isAr ? 'فلوسه عندك' : 'Owed to partner';
  static String get noPartnerBalances =>
      _isAr ? 'مفيش فلوس عند حد — كلها متسلّمة' : 'All clear — nothing owed';

  // Account Handover — Actions
  static String get selectPartner =>
      _isAr ? 'اختار الشريك' : 'Select partner';
  static String get swipeToConfirmHandover =>
      _isAr ? 'اسحب عشان تأكد التسليم' : 'Swipe to confirm';
  static String get handoverSuccess =>
      _isAr ? 'تمام! اتسلّم بنجاح' : 'Handover complete!';
  static String get handoverHistory =>
      _isAr ? 'التسليمات اللي فاتت' : 'Past handovers';

  // Account Handover — Filters
  static String get filterByPartner =>
      _isAr ? 'فلتر بالشريك' : 'Filter by partner';
  static String get filterByType =>
      _isAr ? 'فلتر بالنوع' : 'Filter by type';
  static String get filterByDate =>
      _isAr ? 'فلتر بالتاريخ' : 'Filter by date';
  static String get today => _isAr ? 'النهارده' : 'Today';
  static String get yesterday => _isAr ? 'امبارح' : 'Yesterday';
  static String get pickDay => _isAr ? 'اختار يوم' : 'Pick a day';
  static String get pickPeriod => _isAr ? 'من / إلى' : 'Date range';
  static String get singleDay => _isAr ? 'يوم واحد' : 'Single day';
  static String get dateFromLabel => _isAr ? 'من تاريخ' : 'From';
  static String get dateToLabel => _isAr ? 'إلى تاريخ' : 'To';
  static String get filterByPaymentMethod =>
      _isAr ? 'فلتر بطريقة الدفع' : 'Filter by payment';
  static String get allPaymentMethods => _isAr ? 'الكل' : 'All';
  static String get clearFilter => _isAr ? 'مسح الفلتر' : 'Clear filter';
  static String get apply => _isAr ? 'تطبيق' : 'Apply';
  static String get allPartners => _isAr ? 'كل الشركاء' : 'All partners';
  static String get allTypes => _isAr ? 'كل الأنواع' : 'All types';

  // Account Handover — Onboarding
  static String get onboardingHandoverTitle =>
      _isAr ? 'إيه الحكاية هنا؟' : 'What\'s this about?';
  static String get onboardingHandoverDesc =>
      _isAr
          ? 'بعد ما تخلّص توصيلات الشريك، بتسلّمه فلوسه من هنا.\nكده كل حاجة بتتسجّل وبتبقى مرتّبة.'
          : 'After finishing deliveries, settle partner money here.\nEverything gets recorded and organized.';
  static String get onboardingStep1 =>
      _isAr ? 'اختار الشريك اللي هتسلّمه' : 'Pick the partner';
  static String get onboardingStep2 =>
      _isAr ? 'حط المبلغ وكام طلب سلّمت' : 'Enter amount & orders';
  static String get onboardingStep3 =>
      _isAr ? 'اسحب وخلاص — هيتسجّل تلقائي' : 'Swipe & done — auto-logged';
  static String get gotIt => _isAr ? 'تمام فهمت!' : 'Got it!';

  // Account Handover — Hints
  static String get hintDailySummary =>
      _isAr
          ? 'ده ملخص يومك — حصّلت كام وسلّمت كام والباقي كام'
          : 'Your daily overview — collected, settled, and remaining';
  static String get hintPartnerBalance =>
      _isAr
          ? 'دي فلوس الشريك اللي عندك — لما تسلّمها هتنزل من هنا'
          : 'Partner money you hold — it decreases as you settle';
  static String get hintHandoverHistory =>
      _isAr
          ? 'كل تسليمة عملتها متسجّلة هنا عشان تبقى مرجع ليك'
          : 'Every handover you made is logged here for your records';

  // Statistics
  static String get statsTitle => _isAr ? 'الإحصائيات' : 'Statistics';
  static String get dailyStats => _isAr ? 'يومي' : 'Daily';
  static String get weeklyStats => _isAr ? 'أسبوعي' : 'Weekly';
  static String get monthlyStats => _isAr ? 'شهري' : 'Monthly';
  static String get heatmapStats => _isAr ? 'الخريطة الحرارية' : 'Heatmap';
  static String get statsToday => _isAr ? 'النهاردة' : 'Today';
  static String get selectDay => _isAr ? 'اختار يوم' : 'Select day';
  static String get selectWeek => _isAr ? 'اختار أسبوع' : 'Select week';
  static String get peakHoursTitle =>
      _isAr ? 'أزحم الساعات' : 'Peak hours';
  static String get peakHoursHint => _isAr
      ? 'الأيام والساعات اللي بتعمل فيها أكبر كسب'
      : 'Days & hours where you earn the most';
  static String get noHeatmapData =>
      _isAr ? 'لسه مفيش بيانات كفاية لعرض الخريطة' : 'Not enough data yet';
  static String get totalOrders =>
      _isAr ? 'إجمالي الطلبات' : 'Total orders';
  static String get totalEarningsLabel =>
      _isAr ? 'الإجمالي' : 'Total earnings';
  static String get weeklyEarningsChartTitle =>
      _isAr ? 'كسبك ع مدار الأسبوع' : 'Earnings across the week';
  static String get monthlyEarningsChartTitle =>
      _isAr ? 'كسبك ع مدار الشهر' : 'Earnings across the month';
  static String get totalDistance => _isAr ? 'المسافة' : 'Distance';
  static String get successRate =>
      _isAr ? 'نسبة النجاح' : 'Success rate';
  static String get avgOrderValue =>
      _isAr ? 'متوسط الطلب' : 'Avg. order value';
  static String get moreDetails =>
      _isAr ? 'تفاصيل أكتر' : 'More details';
  static String get exportReport =>
      _isAr ? 'تصدير تقرير' : 'Export report';
  static String get myStats =>
      _isAr ? 'إحصائياتي' : 'My Statistics';
  static String get commissions =>
      _isAr ? 'العمولات' : 'Commissions';
  static String get expensesLabel =>
      _isAr ? 'المصاريف' : 'Expenses';
  static String get timeWorked =>
      _isAr ? 'وقت الشغل' : 'Time worked';
  static String get cashCollected =>
      _isAr ? 'كاش متحصّل' : 'Cash collected';
  static String get bestRegion =>
      _isAr ? 'أحسن منطقة' : 'Best region';
  static String get bestTimeSlot =>
      _isAr ? 'أحسن وقت' : 'Best time';
  static String get noStatsYet =>
      _isAr ? 'مفيش إحصائيات لسه' : 'No statistics yet';
  static String get noStatsHint =>
      _isAr ? 'لما تبدأ توصّل طلبات هتلاقي إحصائياتك هنا' : 'Your statistics will appear here once you start delivering';
  static String get hours => _isAr ? 'ساعة' : 'h';
  static String get minutes => _isAr ? 'دقيقة' : 'min';
  static String get peakHour =>
      _isAr ? 'ساعة الذروة' : 'Peak hour';
  static String get ordersLabel =>
      _isAr ? 'طلب' : 'orders';
  static String get successful =>
      _isAr ? 'ناجح' : 'Successful';
  static String get failed => _isAr ? 'فشل' : 'Failed';
  static String get cancelled => _isAr ? 'ملغي' : 'Cancelled';
  static String get avgDailyOrders =>
      _isAr ? 'متوسط يومي' : 'Daily average';
  static String get avgDailyEarnings =>
      _isAr ? 'متوسط أرباح يومي' : 'Daily avg. earnings';
  static String get comparedToLast =>
      _isAr ? 'مقارنة بالسابق' : 'Compared to previous';

  // Payment Requests
  static String get paymentRequestsTitle =>
      _isAr ? 'طلبات الدفع' : 'Payment Requests';
  static String get createPaymentRequest =>
      _isAr ? 'طلب دفع جديد' : 'New payment request';
  static String get uploadProof =>
      _isAr ? 'ارفع إثبات التحويل' : 'Upload transfer proof';
  static String get cancelRequest =>
      _isAr ? 'إلغاء الطلب' : 'Cancel request';
  static String get noPaymentRequests =>
      _isAr ? 'مفيش طلبات دفع' : 'No payment requests';
  static String get paymentPending => _isAr ? 'قيد الانتظار' : 'Pending';
  static String get paymentUnderReview =>
      _isAr ? 'قيد المراجعة' : 'Under review';
  static String get paymentApproved => _isAr ? 'مقبول' : 'Approved';
  static String get paymentRejected => _isAr ? 'مرفوض' : 'Rejected';
  static String get paymentCancelled => _isAr ? 'ملغي' : 'Cancelled';

  // Invoices
  static String get invoicesTitle => _isAr ? 'كشف حسابك' : 'Invoices';
  static String get invoiceDetail =>
      _isAr ? 'تفاصيل الكشف' : 'Invoice details';
  static String get downloadPdf => _isAr ? 'نزّل PDF' : 'Download PDF';
  static String get shareAsImage =>
      _isAr ? 'ابعتها صورة' : 'Share as image';
  static String get noInvoices => _isAr ? 'مفيش كشوفات لسه' : 'No invoices yet';
  static String get noInvoicesDesc =>
      _isAr ? 'أول ما يطلعلك كشف حساب هيظهر هنا' : 'Your invoices will show up here';
  static String get invoicePending => _isAr ? 'مستنية' : 'Pending';
  static String get invoicePaid => _isAr ? 'اتدفعت' : 'Paid';
  static String get invoiceOverdue => _isAr ? 'متأخرة' : 'Overdue';
  static String get invoiceVoided => _isAr ? 'ملغية' : 'Voided';
  static String get invoiceAll => _isAr ? 'الكل' : 'All';
  static String get invoiceNumber => _isAr ? 'كشف رقم ' : 'Invoice #';
  static String get invoicePeriod => _isAr ? 'من — لـ' : 'Period';
  static String get invoiceIssuedAt =>
      _isAr ? 'طلع يوم' : 'Issued';
  static String get invoiceDueDate =>
      _isAr ? 'مستحق يوم' : 'Due';
  static String get invoicePaidAt =>
      _isAr ? 'اتدفع يوم' : 'Paid on';
  static String get invoiceTotalOrders =>
      _isAr ? 'طلباتك' : 'Your orders';
  static String get invoiceTotalEarnings =>
      _isAr ? 'كسبت' : 'Earned';
  static String get invoiceCommissions =>
      _isAr ? 'عمولة الشركة' : 'Commission';
  static String get invoiceExpenses =>
      _isAr ? 'مصاريف' : 'Expenses';
  static String get invoiceNetAmount =>
      _isAr ? 'اللي ليك' : 'Your take';
  static String get invoiceLineItems =>
      _isAr ? 'التفاصيل' : 'Details';
  static String get invoiceSummaryTitle =>
      _isAr ? 'حسابك باختصار' : 'Your summary';
  static String get invoiceTotalPaid =>
      _isAr ? 'قبضته' : 'Received';
  static String get invoiceTotalOutstanding =>
      _isAr ? 'فاضلّك' : 'Remaining';
  static String get invoicePdfSaved =>
      _isAr ? 'تمام! الكشف اتنزّل' : 'Invoice downloaded';
  static String get invoicePdfError =>
      _isAr ? 'مقدرش أنزّل الكشف — جرّب تاني' : 'Download failed — try again';
  static String get invoiceImageSaved =>
      _isAr ? 'تمام! الصورة جاهزة' : 'Image ready';

  // Home
  static String get goodMorning => _isAr ? 'صباح الخير' : 'Good morning';
  static String get goodEvening => _isAr ? 'مساء الخير' : 'Good evening';
  static String get todayOrders => _isAr ? 'طلبات اليوم' : 'Today\'s orders';
  static String get startTrip => _isAr ? 'ابدأ الرحلة!' : 'Let\'s go!';
  static String get noOrders =>
      _isAr ? 'مفيش طلبات — أضف طلباتك' : 'No orders — add your orders';

  // Orders
  static String get orders => _isAr ? 'الطلبات' : 'Orders';
  static String get addOrder => _isAr ? 'ضيف طلب' : 'Add Order';
  static String get orderDetails =>
      _isAr ? 'تفاصيل الطلب' : 'Order Details';
  static const String trackOnMap = 'تابع ع الخريطة';
  static String get clientName => _isAr ? 'اسم العميل' : 'Client name';
  static String get phone => _isAr ? 'رقم الموبايل' : 'Phone number';
  static String get address => _isAr ? 'العنوان' : 'Address';
  static String get amount => _isAr ? 'المبلغ' : 'Amount';
  static String get note => _isAr ? 'ملاحظة' : 'Note';
  static String get confirmAdd => _isAr ? 'ضيف' : 'Add';
  static String get pickupAddress =>
      _isAr ? 'هتستلم منين؟' : 'Pickup address';
  static String get deliveryAddress =>
      _isAr ? 'هتوصّل فين؟' : 'Delivery address';
  static String get paymentMethodLabel =>
      _isAr ? 'طريقة الدفع' : 'Payment method';
  static String get priorityLabel => _isAr ? 'الأولوية' : 'Priority';
  static String get itemCount => _isAr ? 'كام قطعة؟' : 'Item count';
  static String get scheduledDate =>
      _isAr ? 'هتوصّل إمتى؟' : 'Delivery date';
  static String get notScheduled => _isAr ? 'مش محدد' : 'Not scheduled';
  static String get deliveryAddressRequired =>
      _isAr ? 'لازم تكتب عنوان التسليم' : 'Delivery address is required';
  static String get deliveryLocationRequired => _isAr
      ? 'لازم تحدد مكان التسليم على الخريطة'
      : 'Pick the delivery location on the map';
  static String get amountRequired =>
      _isAr ? 'لازم تكتب المبلغ' : 'Amount is required';
  static String get amountInvalid =>
      _isAr ? 'المبلغ لازم يكون أكبر من صفر' : 'Amount must be greater than zero';
  static String get swipeToDeliver =>
      _isAr ? 'اسحب عشان تسلّم' : 'Swipe to deliver';
  static String get delivered => _isAr ? 'اتسلّم!' : 'Delivered!';
  static String get saveChanges =>
      _isAr ? 'حفظ التعديلات' : 'Save Changes';
  static String get duplicateWarning =>
      _isAr
          ? 'الطلب ده ممكن يكون مكرر، عايز تكمل؟'
          : 'This order might be a duplicate. Continue?';
  static String get yesContinue => _isAr ? 'أيوا كمّل' : 'Yes, continue';
  static String get bulkImportTitle =>
      _isAr ? 'استيراد طلبات' : 'Import Orders';
  static String get pasteOrdersHere =>
      _isAr ? 'الصق الطلبات هنا...' : 'Paste orders here...';
  static String get bulkImportHint =>
      _isAr
          ? 'انسخ الطلبات من واتساب أو أي مكان والصقها هنا.\nكل سطر = طلب واحد'
          : 'Copy orders from WhatsApp or anywhere and paste here.\nOne order per line';
  static String get importOrders =>
      _isAr ? 'استورد دلوقتي!' : 'Import';
  static String get separator => _isAr ? 'الفاصل' : 'Separator';

  // Address Selection
  static String get savedAddresses =>
      _isAr ? 'العناوين المحفوظة' : 'Saved Addresses';
  static String get nearbyAddresses =>
      _isAr ? 'عناوين قريبة' : 'Nearby Addresses';
  static String get noSavedAddresses =>
      _isAr ? 'مفيش عناوين محفوظة للعميل ده' : 'No saved addresses for this customer';
  static String get noNearbyAddresses =>
      _isAr ? 'مفيش عناوين قريبة' : 'No nearby addresses';
  static String get addNewAddress =>
      _isAr ? 'إضافة عنوان جديد' : 'Add New Address';
  static String get selectAddress =>
      _isAr ? 'اختر عنوان' : 'Select Address';
  static String get searchAddress =>
      _isAr ? 'ابحث عن عنوان...' : 'Search address...';
  static String get addressLandmarks =>
      _isAr ? 'علامات مميزة' : 'Landmarks';
  static String get addressDeliveryNotes =>
      _isAr ? 'ملاحظات التوصيل' : 'Delivery Notes';
  static String get addressSaved =>
      _isAr ? 'تم حفظ العنوان' : 'Address saved';
  static String get addressDeleted =>
      _isAr ? 'تم مسح العنوان' : 'Address deleted';
  static String get visits =>
      _isAr ? 'زيارات' : 'visits';
  static String get pickFromMap =>
      _isAr ? 'اختر من الخريطة' : 'Pick from map';
  static String get locationSelected =>
      _isAr ? 'تم تحديد الموقع ✓' : 'Location selected ✓';

  // Order — Create Steps (legacy const kept for non-duplicates)
  static const String stepCustomerInfo = 'العميل';
  static const String stepAddresses = 'العناوين';
  static const String stepDetails = 'التفاصيل';
  static const String previousStep = 'السابق';
  static const String nextStep = 'التالي';
  static const String shipmentDescription = 'وصف الشحنة';
  static const String expectedChange = 'مبلغ الفكة';
  static const String noPartner = 'من غير شريك';
  static const String orderTypeLabel = 'نوع الطلب';
  static const String orderTypeNormal = 'طلب عادي';
  static const String orderTypeRecurring = 'طلب متكرر';
  static const String recurringOrder = 'الطلب ده بيتكرر؟';
  static const String recurrencePatternLabel = 'بيتكرر إزاي؟';
  static const String recurrenceDaily = 'كل يوم';
  static const String recurrenceWeekly = 'كل أسبوع';
  static const String recurrenceMonthly = 'كل شهر';
  static const String recurrenceStartDate = 'تاريخ البداية';
  static const String recurrenceEndDate = 'تاريخ النهاية (اختياري)';
  static const String recurrenceStartDateRequired = 'لازم تحدد تاريخ بداية التكرار';
  static const String timeWindowLabel = 'عايز توصّل من إمتى لإمتى؟';
  static const String timeWindowFrom = 'من الساعة';
  static const String timeWindowTo = 'لحد الساعة';
  // locationPermissionDenied moved to i18n getter below
  static const String fetchingLocation = 'ثانية بنحدد موقعك...';
  static const String customerPhoneRequired = 'اكتب رقم موبايل العميل';
  static const String selectPickupPoint = 'اختار نقطة الاستلام';
  static const String loadingPickupPoints = 'بنجيب نقاط الاستلام...';
  static const String noPickupPoints = 'الشريك ده مسجلش نقاط استلام';
  static const String pickOnMap = 'حدد ع الخريطة';
  static const String pickLocationOnMap = 'حدد الموقع على الخريطة';
  static const String manualEntry = 'اكتب بإيدك';
  static const String bulkImport = 'الصق طلبات';
  static const String voiceEntry = 'قول بصوتك';
  static const String ocrEntry = 'صوّر فاتورة';

  // OCR Tab strings
  static const String ocrTabTitle = 'مسح فاتورة بالكاميرا';
  static const String ocrScanSingle = 'صوّر فاتورة';
  static const String ocrScanDirect = 'إنشاء فوري';
  static const String ocrScanBatch = 'مسح مجمّع';
  static const String ocrScanSingleDesc = 'صوّر الفاتورة وراجع البيانات قبل ما تعمل الطلب';
  static const String ocrScanDirectDesc = 'صوّر الفاتورة والطلب يتعمل أوتوماتيك';
  static const String ocrScanBatchDesc = 'صوّر كذا فاتورة مرة واحدة';
  static const String ocrScanning = 'جاري المسح...';
  static const String ocrReviewData = 'راجع البيانات';
  static const String ocrConfirmOrder = 'أكّد وأنشئ الطلب';
  static const String ocrPickImage = 'اختار صورة';
  static const String ocrTakePhoto = 'صوّر بالكاميرا';
  static const String ocrChooseGallery = 'اختار من المعرض';
  static const String ocrNoDataFound = 'مقدرش أقرأ بيانات من الصورة دي';
  static const String ocrScanSuccess = 'تمام! الفاتورة اتقرأت';
  static const String ocrDirectSuccess = 'تمام! الطلب اتعمل من الفاتورة';
  static const String ocrBatchSuccess = 'تمام! الفواتير اتقرأت';
  static const String ocrSelectImages = 'اختار الصور';
  static const String ocrImageCount = 'صورة';
  static const String ocrExtractedData = 'البيانات المستخرجة';
  static const String ocrCustomerName = 'اسم العميل';
  static const String ocrAddress = 'العنوان';
  static const String ocrAmount = 'المبلغ';
  static const String ocrItems = 'الأصناف';
  static const String ocrConfidence = 'نسبة الدقة';
  static const String availableSlots = 'المواعيد اللي متاحة';
  static const String loadSlots = 'حمّل المواعيد';
  static const String loadSlotsHint = 'اضغط "حمّل المواعيد" عشان تشوف المتاح';
  static const String slotLabel = 'موعد';
  static const String suggestedDeliveryPrice = 'سعر التوصيل المتوقع';
  static const String calculatePrice = 'احسب السعر';
  static const String suggestedPrice = 'السعر المتوقع';
  static const String calculatePriceHint = 'اكتب العنوان واضغط "احسب السعر"';

  // Order Detail Actions
  static String get acceptOrder => _isAr ? 'اقبل الطلب' : 'Accept Order';
  static String get pickedUpOrder =>
      _isAr ? 'استلمت الشحنة' : 'Picked Up';
  static String get startDelivery =>
      _isAr ? 'ابدأ التوصيل!' : 'Start Delivery';
  static String get failDelivery =>
      _isAr ? 'معرفتش أسلّم' : 'Delivery Failed';
  static String get cancelOrder => _isAr ? 'ألغي الطلب' : 'Cancel Order';
  static String get retryDelivery =>
      _isAr ? 'جرّب تاني' : 'Retry Delivery';
  static String get confirmDelivery =>
      _isAr ? 'أكّد التسليم' : 'Confirm Delivery';
  static String get deliverShort => _isAr ? 'سلّم' : 'Deliver';
  static String get collectedAmount =>
      _isAr ? 'حصّلت كام؟' : 'Amount collected';
  static String get failReason => _isAr ? 'إيه السبب؟' : 'Reason';
  static String get cancelReason =>
      _isAr ? 'ليه بتلغي؟' : 'Cancellation reason';
  static String get orderNumberLabel =>
      _isAr ? 'رقم الطلب' : 'Order number';
  static String get distance => _isAr ? 'المسافة' : 'Distance';
  static String get additionalNotes =>
      _isAr ? 'عايز تضيف حاجة؟' : 'Additional notes';
  static String get notes => _isAr ? 'ملاحظات' : 'Notes';
  static String get editOrder => _isAr ? 'عدّل الطلب' : 'Edit Order';
  static String get deleteOrder => _isAr ? 'امسح الطلب' : 'Delete Order';
  static String get deleteOrderConfirm =>
      _isAr ? 'متأكد إنك عايز تمسح الطلب ده؟' : 'Are you sure you want to delete this order?';
  static String get phoneCopied =>
      _isAr ? 'الرقم اتنسخ' : 'Number copied';
  static String get quickMessages =>
      _isAr ? 'رسائل سريعة' : 'Quick messages';
  static String get messageCopied =>
      _isAr ? 'الرسالة اتنسخت' : 'Message copied';
  static String get createdAt => _isAr ? 'اتعمل إمتى' : 'Created at';
  static String get deliveredAt =>
      _isAr ? 'اتسلّم إمتى' : 'Delivered at';

  // Order Actions — Success Messages
  static String get orderCreatedSuccess =>
      _isAr ? 'تمام! الطلب اتضاف' : 'Order added!';
  static String get orderUpdatedSuccess =>
      _isAr ? 'تمام! الطلب اتعدّل' : 'Order updated!';
  static String get orderDeletedSuccess =>
      _isAr ? 'تمام! الطلب اتمسح' : 'Order deleted!';
  static String get orderStatusUpdatedSuccess =>
      _isAr ? 'تمام! الحالة اتغيّرت' : 'Status updated!';
  static String get orderDeliveredSuccess =>
      _isAr ? 'برافو! الطلب اتسلّم' : 'Order delivered!';
  static String get orderFailedSuccess =>
      _isAr ? 'تم تسجيل المحاولة' : 'Attempt recorded';
  static String get orderCancelledSuccess =>
      _isAr ? 'الطلب اتلغى' : 'Order cancelled';
  static String get savedOffline =>
      _isAr ? 'تمام! اتحفظ عندك — هيتبعت أول ما النت يرجع' : 'Saved! Will be sent when you\'re back online';
  static String get pendingSync =>
      _isAr ? 'مستني النت' : 'Waiting for connection';
  static String get orderSyncedSuccess =>
      _isAr ? 'تمام! الطلب اتأكد' : 'Done! Order confirmed';
  static String get photoUploadedSuccess =>
      _isAr ? 'تمام! الصورة اترفعت' : 'Photo uploaded!';
  static String get addressSwappedSuccess =>
      _isAr ? 'تمام! العنوان اتغيّر' : 'Address swapped!';
  static String get bulkImportSuccess =>
      _isAr ? 'تمام! الطلبات اتضافت' : 'Orders imported!';
  static String get transferSuccess =>
      _isAr ? 'تمام! الطلب اتحوّل' : 'Order transferred!';
  static String get transferToColleague =>
      _isAr ? 'حوّل لزميل' : 'Transfer to colleague';
  static String get transferPickColleague =>
      _isAr ? 'اختار زميل قريب منك' : 'Pick a nearby colleague';
  static String get transferReason =>
      _isAr ? 'السبب (اختياري)' : 'Reason (optional)';
  static String get transferConfirmMsg =>
      _isAr ? 'هتحوّل الطلب لـ' : 'Transfer order to';
  static String get transferNoNearby =>
      _isAr ? 'مفيش زملاء قريبين دلوقتي' : 'No colleagues nearby';
  static String get transferLoading =>
      _isAr ? 'بنجيب الزملاء القريبين...' : 'Loading nearby colleagues...';
  static String get partialDeliverySuccess =>
      _isAr ? 'تمام! التسليم الجزئي اتسجّل' : 'Partial delivery recorded!';
  static String get waitingStarted =>
      _isAr ? 'المؤقت شغال' : 'Timer started';
  static String get waitingStopped =>
      _isAr ? 'المؤقت وقف' : 'Timer stopped';
  static String get disclaimerAdded =>
      _isAr ? 'تمام! إخلاء المسؤولية اتضاف' : 'Disclaimer added!';
  static String get disputeCreated =>
      _isAr ? 'تمام! النزاع اتفتح' : 'Dispute created!';
  static String get refundRequested =>
      _isAr ? 'تمام! طلب الاسترداد اتبعت' : 'Refund requested!';
  static String get slotBooked =>
      _isAr ? 'تمام! الموعد اتحجز' : 'Slot booked!';

  // Order Status
  static String get statusNew => _isAr ? 'جديد' : 'New';
  static String get statusOnTheWay =>
      _isAr ? 'ف السكة' : 'On the way';
  static String get statusArrived => _isAr ? 'وصلت' : 'Arrived';
  static String get statusDelivered =>
      _isAr ? 'تم التسليم' : 'Delivered';
  static String get statusFailed => _isAr ? 'معرفتش أسلّم' : 'Failed';
  static String get statusPartiallyDelivered => _isAr ? 'تسليم جزئي' : 'Partially Delivered';
  static String get statusCancelled => _isAr ? 'ملغي' : 'Cancelled';
  static String get statusReturned => _isAr ? 'مرتجع' : 'Returned';
  static String get statusPostponed => _isAr ? 'مؤجّل' : 'Postponed';

  // Wallet
  static String get wallet => _isAr ? 'المحفظة' : 'Wallet';
  static String get todayEarnings =>
      _isAr ? 'كسب النهارده' : 'Today\'s earnings';
  static String get totalCollected =>
      _isAr ? 'إجمالي التحصيل' : 'Total collected';
  static String get netProfit => _isAr ? 'الصافي' : 'Net profit';

  // Profile
  static String get profileTitle => _isAr ? 'البروفايل' : 'Profile';
  static String get editProfile =>
      _isAr ? 'تعديل البيانات' : 'Edit Profile';
  static String get profileCompletion =>
      _isAr ? 'اكتمال الملف' : 'Profile completion';
  static String get profileComplete =>
      _isAr ? 'ملفك مكتمل!' : 'Profile complete!';
  static String get profileIncomplete =>
      _isAr ? 'كمّل ملفك عشان تبدأ شغل' : 'Complete your profile to start working';
  static String get requiredStep => _isAr ? 'مطلوب' : 'Required';
  static String get level => _isAr ? 'المستوى' : 'Level';
  static String get points => _isAr ? 'نقطة' : 'points';
  static String get memberSince => _isAr ? 'عضو من' : 'Member since';
  static String get online => _isAr ? 'متاح' : 'Online';
  static String get offline => _isAr ? 'غير متاح' : 'Offline';
  static String get referralCode =>
      _isAr ? 'ادعو سائق واكسب نقاط' : 'Invite a driver & earn points';
  static String get referralCodeLabel =>
      _isAr ? 'كود الدعوة' : 'Invite code';
  static String get referralSubtitle =>
      _isAr ? 'شارك الكود ده مع سائقين تانيين — لما حد يسجل بيه، هتكسبوا نقاط الاتنين!' : 'Share this code with other drivers — when someone signs up with it, you both earn points!';
  static String get copyCode => _isAr ? 'نسخ الكود' : 'Copy code';
  static String get shareCode => _isAr ? 'شارك الكود' : 'Share code';
  static String get shareTrackingLink =>
      _isAr ? 'مشاركة رابط التتبع' : 'Share tracking link';
  static String get trackingLinkCopied =>
      _isAr ? 'تم نسخ رابط التتبع!' : 'Tracking link copied!';
  static String get codeCopied =>
      _isAr ? 'تم نسخ الكود!' : 'Code copied!';
  static String get referralsTitle =>
      _isAr ? 'دعواتك' : 'Your invites';
  static String get referralsTotalInvited =>
      _isAr ? 'دعيتهم' : 'Invited';
  static String get referralsActive =>
      _isAr ? 'شغالين' : 'Active';
  static String get referralsEarned =>
      _isAr ? 'كسبت منهم' : 'Earned';
  static String get referralsPending =>
      _isAr ? 'مكافآت جاية' : 'Pending rewards';
  static String get referralsEmpty =>
      _isAr ? 'مدعيتش حد لسه' : 'No invites yet';
  static String get referralsEmptyDesc =>
      _isAr ? 'شارك كودك مع سواقين تانيين واكسبوا مع بعض' : 'Share your code with other drivers and earn together';
  static String get referralStatusPending =>
      _isAr ? 'مستني يسجل' : 'Pending';
  static String get referralStatusActive =>
      _isAr ? 'شغال' : 'Active';
  static String get referralStatusExpired =>
      _isAr ? 'انتهى' : 'Expired';
  static String get referralJoined =>
      _isAr ? 'سجّل يوم' : 'Joined';
  static String get haveInviteCode =>
      _isAr ? 'عندك كود دعوة من سائق تاني؟' : 'Got an invite code from another driver?';
  static String get enterInviteCode =>
      _isAr ? 'اكتب كود الدعوة (اختياري)' : 'Enter invite code (optional)';
  static String get inviteCodeHint =>
      _isAr ? 'مثال: SEK-XXXXXXXX' : 'Example: SEK-XXXXXXXX';
  static String get detailedStats =>
      _isAr ? 'إحصائياتك بالتفصيل' : 'Detailed statistics';
  static String get expenses => _isAr ? 'المصروفات' : 'Expenses';
  static String get addExpense => _isAr ? 'إضافة مصروف' : 'Add expense';
  static String get noExpenses => _isAr ? 'مفيش مصروفات' : 'No expenses';
  static String get achievements => _isAr ? 'الإنجازات' : 'Achievements';
  static String get challenges => _isAr ? 'التحديات' : 'Challenges';
  static String get leaderboard => _isAr ? 'الترتيب' : 'Leaderboard';
  static String get myRank => _isAr ? 'ترتيبي' : 'My rank';
  static String get topDrivers =>
      _isAr ? 'أفضل السائقين' : 'Top drivers';
  static String get noAchievements =>
      _isAr ? 'مفيش إنجازات لسه' : 'No achievements yet';
  static String get noChallenges =>
      _isAr ? 'مفيش تحديات لسه' : 'No challenges yet';
  static String get totalFailed => _isAr ? 'فشل' : 'Failed';
  static String get totalCancelled => _isAr ? 'ملغي' : 'Cancelled';
  static String get avgDeliveryTime =>
      _isAr ? 'متوسط وقت التسليم' : 'Avg. delivery time';
  static String get bestDay => _isAr ? 'أفضل يوم' : 'Best day';
  static String get uploadPhoto => _isAr ? 'ارفع صورة' : 'Upload photo';
  static String get changePhoto => _isAr ? 'غيّر الصورة' : 'Change photo';
  static String get camera => _isAr ? 'الكاميرا' : 'Camera';
  static String get gallery => _isAr ? 'المعرض' : 'Gallery';
  static String get removePhoto => _isAr ? 'امسح الصورة' : 'Remove photo';
  static String get uploadLicense =>
      _isAr ? 'ارفع صورة الرخصة' : 'Upload license photo';
  static String get profileUpdated =>
      _isAr ? 'تم تحديث البيانات!' : 'Profile updated!';
  static String get subscription => _isAr ? 'الاشتراك' : 'Subscription';
  static String get noSubscription =>
      _isAr ? 'مفيش اشتراك' : 'No subscription';
  static String get profile => _isAr ? 'الملف الشخصي' : 'Profile';
  static String get logout => _isAr ? 'تسجيل الخروج' : 'Log Out';
  static String get logoutConfirm =>
      _isAr ? 'متأكد عايز تطلع؟' : 'Are you sure you want to log out?';
  static String get expenseCategory => _isAr ? 'النوع' : 'Category';
  static String get expenseAmount => _isAr ? 'المبلغ' : 'Amount';
  static String get expenseNotes => _isAr ? 'ملاحظات' : 'Notes';

  // Health Score
  static String get healthScore => _isAr ? 'أداءك عامل إزاي' : 'Health Score';
  static String get successRateScore =>
      _isAr ? 'نسبة التوصيل' : 'Success Rate';
  static String get customerRatingScore =>
      _isAr ? 'رأي الزباين' : 'Customer Rating';
  static String get commitmentScore =>
      _isAr ? 'التزامك' : 'Commitment';
  static String get activityScore =>
      _isAr ? 'نشاطك' : 'Activity';
  static String get cashHandlingScore =>
      _isAr ? 'تعاملك مع الفلوس' : 'Cash Handling';
  static String get healthStatusGood => _isAr ? 'تمام' : 'Good';
  static String get healthStatusAverage => _isAr ? 'نص نص' : 'Average';
  static String get healthStatusPoor => _isAr ? 'محتاج تحسين' : 'Poor';
  static String get trendUp => _isAr ? 'بيتحسن' : 'Improving';
  static String get trendDown => _isAr ? 'بينزل' : 'Declining';
  static String get trendStable => _isAr ? 'ثابت' : 'Stable';

  // Settings
  static String get settings => _isAr ? 'الإعدادات' : 'Settings';
  static String get appearance => _isAr ? 'المظهر' : 'Appearance';
  static String get themeSystem => _isAr ? 'تلقائي' : 'System';
  static String get themeLight => _isAr ? 'فاتح' : 'Light';
  static String get themeDark => _isAr ? 'غامق' : 'Dark';
  static String get languageLabel => _isAr ? 'اللغة' : 'Language';
  static String get arabic => _isAr ? 'عربي' : 'Arabic';
  static String get english => 'English';
  static String get numberFormatLabel =>
      _isAr ? 'شكل الأرقام' : 'Number format';
  static String get highContrast =>
      _isAr ? 'تباين عالي' : 'High contrast';
  static String get notifications =>
      _isAr ? 'الإشعارات' : 'Notifications';
  static String get notifyNewOrder =>
      _isAr ? 'طلب جديد' : 'New order';
  static String get notifyCashAlert =>
      _isAr ? 'تنبيه الكاش' : 'Cash alert';
  static String get notifyBreakReminder =>
      _isAr ? 'تذكير الاستراحة' : 'Break reminder';
  static String get notifyMaintenance =>
      _isAr ? 'الصيانة' : 'Maintenance';
  static String get notifySettlement =>
      _isAr ? 'التسويات' : 'Settlements';
  static String get notifyAchievement =>
      _isAr ? 'الإنجازات' : 'Achievements';
  static String get notifySound => _isAr ? 'الصوت' : 'Sound';
  static String get notifyVibration => _isAr ? 'الاهتزاز' : 'Vibration';
  static String get quietHours =>
      _isAr ? 'ساعات الهدوء' : 'Quiet hours';
  static String get quietHoursFrom => _isAr ? 'من' : 'From';
  static String get quietHoursTo => _isAr ? 'إلى' : 'To';
  static String get focusMode =>
      _isAr ? 'وضع التركيز' : 'Focus mode';
  static String get focusModeEnabled =>
      _isAr ? 'تفعيل وضع التركيز' : 'Enable focus mode';
  static String get focusModeDescription =>
      _isAr
          ? 'يمنع كل الإشعارات عشان تركّز في الشغل'
          : 'Blocks all notifications so you can focus';
  static String get speedAlert =>
      _isAr ? 'تحذير السرعة' : 'Speed alert';
  static String get speedAlertEnabled =>
      _isAr ? 'تفعيل تحذير السرعة' : 'Enable speed alert';
  static String get speedAlertLimit =>
      _isAr ? 'حد السرعة (كم/س)' : 'Speed limit (km/h)';
  static String get speedAlertDescription =>
      _isAr
          ? 'هيجيلك تحذير لو سرعتك عدّت الحد ده'
          : 'You will be warned if you exceed this speed';
  static String get speedAlertWarning =>
      _isAr ? 'سرعتك عالية! هدّي شوية' : 'Slow down! You are speeding';
  static String get deliveryPreferences =>
      _isAr ? 'تفضيلات التوصيل' : 'Delivery preferences';
  static String get preferredMap =>
      _isAr ? 'تطبيق الخريطة' : 'Map app';
  static String get maxOrdersShift =>
      _isAr ? 'أقصى عدد طلبات بالشفت' : 'Max orders per shift';
  static String get autoReceipt =>
      _isAr ? 'إرسال إيصال تلقائي' : 'Auto-send receipt';
  static String get locationSettings => _isAr ? 'الموقع' : 'Location';
  static String get homeLocation =>
      _isAr ? 'موقع البيت' : 'Home location';
  static String get setHomeLocation =>
      _isAr ? 'حدد موقع البيت' : 'Set home location';
  static String get backToBase =>
      _isAr ? 'تنبيه الرجوع للبيت' : 'Return home alert';
  static String get backToBaseRadius =>
      _isAr ? 'نطاق التنبيه (كم)' : 'Alert radius (km)';
  static String get technicalSettings =>
      _isAr ? 'إعدادات تقنية' : 'Technical settings';
  static String get locationInterval =>
      _isAr ? 'فترة تتبع الموقع (ثانية)' : 'Location tracking interval (sec)';
  static String get syncInterval =>
      _isAr ? 'فترة المزامنة (ثانية)' : 'Sync interval (sec)';
  static String get textToSpeech =>
      _isAr ? 'القراءة الصوتية' : 'Text to speech';
  static String get hapticFeedback =>
      _isAr ? 'الاهتزاز عند اللمس' : 'Haptic feedback';
  static String get settingsSaved =>
      _isAr ? 'تم حفظ الإعدادات!' : 'Settings saved!';
  static String get arabicNumerals =>
      _isAr ? 'عربية (١٢٣)' : 'Arabic (١٢٣)';
  static String get westernNumerals =>
      _isAr ? 'غربية (123)' : 'Western (123)';
  static String get googleMaps => 'Google Maps';
  static String get waze => 'Waze';
  static String get otherMapApp => _isAr ? 'أخرى' : 'Other';
  static String get unlimited => _isAr ? 'بدون حد' : 'Unlimited';
  static String get enterAddress =>
      _isAr ? 'اكتب العنوان' : 'Enter address';
  static String get notSet => _isAr ? 'غير محدد' : 'Not set';
  static String get useCurrentLocation =>
      _isAr ? 'استخدم موقعي الحالي' : 'Use my current location';
  static String get detectingLocation =>
      _isAr ? 'بنحدد مكانك...' : 'Detecting location...';
  static String get locationDetected =>
      _isAr ? 'لقيناك!' : 'Location detected';
  static String get locationPermissionDenied =>
      _isAr ? 'لازم تسمح بالموقع' : 'Location permission required';
  static String get locationServiceDisabled =>
      _isAr ? 'فعّل خدمة الموقع الأول' : 'Enable location services first';

  // Privacy & Data
  static String get privacySettings =>
      _isAr ? 'الخصوصية والبيانات' : 'Privacy & Data';
  static String get consentsSectionTitle =>
      _isAr ? 'الموافقات' : 'Consents';
  static String get consentLocationTracking =>
      _isAr ? 'تتبع الموقع' : 'Location Tracking';
  static String get consentLocationTrackingDesc =>
      _isAr
          ? 'السماح بتتبع موقعك لتحسين التوصيل'
          : 'Allow tracking your location to optimize delivery';
  static String get consentMarketing =>
      _isAr ? 'الرسائل التسويقية' : 'Marketing Messages';
  static String get consentMarketingDesc =>
      _isAr
          ? 'استقبال عروض وتحديثات تسويقية'
          : 'Receive promotional offers and updates';
  static String get myDataSectionTitle =>
      _isAr ? 'بياناتي' : 'My Data';
  static String get exportMyData =>
      _isAr ? 'تصدير بياناتي' : 'Export My Data';
  static String get exportMyDataDesc =>
      _isAr
          ? 'هنجهّزلك ملف فيه كل بياناتك وهنبعتهولك'
          : 'We will prepare a file with all your data and send it to you';
  static String get requestExport =>
      _isAr ? 'اطلب تصدير' : 'Request Export';
  static String get exportRequestSent =>
      _isAr
          ? 'تم تقديم طلب تصدير البيانات بنجاح'
          : 'Data export request submitted successfully';
  static String get deleteMyData =>
      _isAr ? 'حذف بياناتي' : 'Delete My Data';
  static String get deleteMyDataDesc =>
      _isAr
          ? 'طلب حذف كل بياناتك من النظام. العملية دي مش ممكن التراجع عنها'
          : 'Request deletion of all your data. This action cannot be undone';
  static String get requestDeletion =>
      _isAr ? 'اطلب حذف' : 'Request Deletion';
  static String get deleteRequestSent =>
      _isAr
          ? 'تم تقديم طلب حذف البيانات بنجاح'
          : 'Data deletion request submitted successfully';
  static String get deleteDataConfirmTitle =>
      _isAr ? 'حذف البيانات' : 'Delete Data';
  static String get deleteDataConfirmDesc =>
      _isAr
          ? 'لو أكدت، هنبدأ نحذف كل بياناتك. العملية دي مينفعش نرجع فيها.'
          : 'Once confirmed, we will begin deleting all your data. This cannot be reversed.';
  static String get deleteDataReason =>
      _isAr ? 'إيه السبب؟ (اختياري)' : 'Reason (optional)';
  static String get confirmDeleteData =>
      _isAr ? 'تأكيد الحذف' : 'Confirm Deletion';
  static String get deleteStatusTitle =>
      _isAr ? 'حالة طلب الحذف' : 'Deletion Request Status';
  static String get deleteStatusPending =>
      _isAr ? 'الطلب قيد المراجعة' : 'Request is under review';

  // Customers
  static String get customers => _isAr ? 'العملاء' : 'Customers';
  static String get customerDetails =>
      _isAr ? 'تفاصيل العميل' : 'Customer Details';
  static String get searchCustomer =>
      _isAr ? 'دوّر على عميل' : 'Search customer';
  static String get totalDeliveries =>
      _isAr ? 'كل التوصيلات' : 'Total deliveries';
  static String get successfulDeliveries =>
      _isAr ? 'توصيلات تمام' : 'Successful deliveries';
  static String get averageRating =>
      _isAr ? 'التقييم' : 'Average rating';
  static String get blocked => _isAr ? 'محظور' : 'Blocked';
  static String get unblocked => _isAr ? 'مش محظور' : 'Unblocked';
  static String get rateCustomer =>
      _isAr ? 'قيّم العميل' : 'Rate customer';
  static String get blockCustomer =>
      _isAr ? 'احظر العميل' : 'Block customer';
  static String get unblockCustomer =>
      _isAr ? 'شيل الحظر' : 'Unblock customer';
  static String get blockReason =>
      _isAr ? 'إيه سبب الحظر؟' : 'Block reason';
  static String get reportToCommunity =>
      _isAr ? 'بلّغ عنه' : 'Report to community';
  static String get customerBlocked =>
      _isAr ? 'تمام! العميل اتحظر' : 'Customer blocked successfully';
  static String get customerUnblocked =>
      _isAr ? 'تمام! الحظر اتشال' : 'Customer unblocked successfully';
  static String get voiceMemo => _isAr ? 'رسالة صوتية' : 'Voice memo';
  static String get interests => _isAr ? 'اهتماماته' : 'Interests';
  static String get engagement =>
      _isAr ? 'التفاعل' : 'Engagement level';
  static String get insightsProfile =>
      _isAr ? 'ملف التحليلات' : 'Insights Profile';
  static String get rfmScore => _isAr ? 'تقييم العميل' : 'Customer Score';
  static String get recency => _isAr ? 'آخر مرة' : 'Recency';
  static String get frequency => _isAr ? 'التكرار' : 'Frequency';
  static String get monetary => _isAr ? 'القيمة' : 'Monetary';
  static String get customerSegment =>
      _isAr ? 'نوع العميل' : 'Customer Segment';
  static String get recommendations =>
      _isAr ? 'نصايح' : 'Recommendations';
  static String get markAsRead => _isAr ? 'قرأت' : 'Read';
  static String get dismiss => _isAr ? 'تجاهل' : 'Dismiss';
  static String get actOnIt => _isAr ? 'نفّذ' : 'Act';
  static String get recentOrders =>
      _isAr ? 'آخر الطلبات' : 'Recent Orders';
  static String get engagementScore =>
      _isAr ? 'نقاط التفاعل' : 'Engagement Score';
  static String get lastInteraction =>
      _isAr ? 'آخر تعامل' : 'Last Interaction';
  static String get daysSinceLastOrder =>
      _isAr ? 'من آخر طلب' : 'Days Since Last Order';
  static String get lifetimeValue =>
      _isAr ? 'إجمالي اللي صرفه' : 'Lifetime Value';
  static String get noRecommendations =>
      _isAr ? 'مفيش نصايح دلوقتي' : 'No recommendations';
  static String get behaviorAnalysis =>
      _isAr ? 'سلوك العميل' : 'Behavior Analysis';
  static String get preferredOrderTime =>
      _isAr ? 'بيطلب امتى' : 'Preferred Order Time';
  static String get preferredDay =>
      _isAr ? 'يومه المفضل' : 'Preferred Day';
  static String get orderFrequency =>
      _isAr ? 'معدل الطلب' : 'Orders/Month';
  static String get spendingTier =>
      _isAr ? 'مستوى الصرف' : 'Spending Tier';
  static String get preferredAreas =>
      _isAr ? 'أماكنه المفضلة' : 'Preferred Areas';
  static String get insightsInterests =>
      _isAr ? 'اهتمامات العميل' : 'Customer Insights Interests';

  // Rating Tags
  static String get quickResponse => _isAr ? 'رد سريع' : 'Quick response';
  static String get clearAddress =>
      _isAr ? 'عنوان واضح' : 'Clear address';
  static String get respectfulBehavior =>
      _isAr ? 'تعامل محترم' : 'Respectful';
  static String get easyPayment => _isAr ? 'دفع سهل' : 'Easy payment';
  static String get wrongAddress =>
      _isAr ? 'عنوان غلط' : 'Wrong address';
  static String get noAnswer => _isAr ? 'مبيردش' : 'No answer';
  static String get delayedPickup =>
      _isAr ? 'تأخير في الاستلام' : 'Delayed pickup';
  static String get paymentIssue =>
      _isAr ? 'مشكلة في الدفع' : 'Payment issue';
  static String get ratingSuccess =>
      _isAr ? 'تم تقييم العميل بنجاح' : 'Customer rated successfully';

  // Partners
  static String get partners => _isAr ? 'الشركاء' : 'Partners';
  static String get partnerDetails =>
      _isAr ? 'تفاصيل الشريك' : 'Partner Details';
  static String get searchPartner =>
      _isAr ? 'دوّر على شريك' : 'Search partner';
  static String get addPartner =>
      _isAr ? 'ضيف شريك' : 'Add Partner';
  static String get partnerName =>
      _isAr ? 'اسم الشريك' : 'Partner name';
  static String get partnerPhone =>
      _isAr ? 'رقم التلفون' : 'Phone number';
  static String get partnerAddress => _isAr ? 'العنوان' : 'Address';
  static String get partnerType =>
      _isAr ? 'نوع الشريك' : 'Partner type';
  static String get commissionTypeLabel =>
      _isAr ? 'نوع العمولة' : 'Commission type';
  static String get commissionValue =>
      _isAr ? 'قيمة العمولة' : 'Commission value';
  static String get commissionFixed =>
      _isAr ? 'ثابت لكل طلب' : 'Fixed per order';
  static String get commissionPercentage =>
      _isAr ? 'نسبة لكل طلب' : 'Percentage per order';
  static String get commissionMonthly =>
      _isAr ? 'شهري ثابت' : 'Monthly flat';
  static String get defaultPaymentMethod =>
      _isAr ? 'طريقة الدفع الافتراضية' : 'Default payment method';
  static String get receiptHeader =>
      _isAr ? 'عنوان الإيصال' : 'Receipt header';
  static String get partnerColor =>
      _isAr ? 'لون الشريك' : 'Partner color';
  static String get partnerAddedSuccess =>
      _isAr ? 'تمام! الشريك اتضاف' : 'Partner added successfully!';
  static String get commission => _isAr ? 'العمولة' : 'Commission';
  static String get pickupPoints =>
      _isAr ? 'نقاط الاستلام' : 'Pickup points';
  static String get verification =>
      _isAr ? 'التوثيق' : 'Verification';
  static String get submitDocument =>
      _isAr ? 'ارفع الورق' : 'Submit document';

  // Partner Types
  static String get restaurantType => _isAr ? 'مطعم' : 'Restaurant';
  static String get shopType => _isAr ? 'محل' : 'Shop';
  static String get pharmacyType => _isAr ? 'صيدلية' : 'Pharmacy';
  static String get supermarketType =>
      _isAr ? 'سوبرماركت' : 'Supermarket';
  static String get warehouseType => _isAr ? 'مخزن' : 'Warehouse';
  static String get eCommerceType =>
      _isAr ? 'تجارة إلكترونية' : 'E-Commerce';

  // Verification Status
  static String get statusPending =>
      _isAr ? 'لسه بيتراجع' : 'Under review';
  static String get statusVerified => _isAr ? 'متوثّق' : 'Verified';
  static String get statusRejected => _isAr ? 'اترفض' : 'Rejected';
  static String get statusDocumentRequested =>
      _isAr ? 'محتاج ورق تاني' : 'Additional document required';

  // Address Types
  static String get addressHome => _isAr ? 'منزل' : 'Home';
  static String get addressWork => _isAr ? 'عمل' : 'Work';
  static String get addressShop => _isAr ? 'محل' : 'Shop';
  static String get addressRestaurant => _isAr ? 'مطعم' : 'Restaurant';
  static String get addressWarehouse => _isAr ? 'مخزن' : 'Warehouse';
  static String get addressOther => _isAr ? 'أخرى' : 'Other';

  // Addresses
  static String get addresses => _isAr ? 'العناوين' : 'Addresses';
  static String get addAddress => _isAr ? 'إضافة عنوان' : 'Add Address';
  static String get editAddress =>
      _isAr ? 'تعديل العنوان' : 'Edit Address';
  static String get deleteAddressConfirm =>
      _isAr ? 'هل تريد حذف هذا العنوان؟' : 'Delete this address?';
  static String get landmarks => _isAr ? 'معالم قريبة' : 'Nearby landmarks';
  static String get deliveryNotes =>
      _isAr ? 'ملاحظات التوصيل' : 'Delivery notes';
  static String get noResults =>
      _isAr ? 'مفيش نتائج' : 'No results';

  // Caller ID
  static String get callerId => _isAr ? 'معرّف المتصل' : 'Caller ID';
  static String get callerNote =>
      _isAr ? 'ملاحظة عن المتصل' : 'Caller note';
  static String get callerAddNote =>
      _isAr ? 'ضيف ملاحظة' : 'Add note';
  static String get callerEditNote =>
      _isAr ? 'عدّل الملاحظة' : 'Edit note';
  static String get callerNoteHint =>
      _isAr ? 'اكتب أي ملاحظة تفتكرها عن الرقم ده' : 'Write any note about this contact';
  static String get callerNoteHintCustomer =>
      _isAr ? 'مثلاً: بيتأخر في الاستلام' : 'e.g. Often late for pickup';
  static String get callerNoteHintPartner =>
      _isAr ? 'مثلاً: بيتأخر في تجهيز الأوردرات' : 'e.g. Slow order preparation';
  static String get callerNoteSaved =>
      _isAr ? 'تم حفظ الملاحظة' : 'Note saved';
  static String get callerNoteDeleted =>
      _isAr ? 'تم مسح الملاحظة' : 'Note deleted';
  static String get callerLastOrder =>
      _isAr ? 'آخر أوردر' : 'Last order';
  static String get callerSpamWarning =>
      _isAr ? 'الرقم ده ممكن يكون spam' : 'This number might be spam';
  static String get callerContactType =>
      _isAr ? 'نوع جهة الاتصال' : 'Contact type';
  static String get callerTypeUnknown =>
      _isAr ? 'مش معروف' : 'Unknown';
  static String get callerTypeCustomer =>
      _isAr ? 'عميل' : 'Customer';
  static String get callerTypePartner =>
      _isAr ? 'شريك' : 'Partner';
  static String get callerTypeDriver =>
      _isAr ? 'سائق' : 'Driver';
  static String get callerTypeOther =>
      _isAr ? 'تاني' : 'Other';
  static String get callerCheckTruecaller =>
      _isAr ? 'فحص الرقم' : 'Check number';

  // Payment Methods
  static String get paymentCash => _isAr ? 'كاش' : 'Cash';
  static String get paymentWallet => _isAr ? 'محفظة' : 'Wallet';
  static String get paymentCard => _isAr ? 'بطاقة' : 'Card';
  static String get paymentInstaPay => _isAr ? 'إنستاباي' : 'InstaPay';

  // Commission Types
  static String get fixedPerOrder =>
      _isAr ? 'مبلغ ثابت لكل طلب' : 'Fixed amount per order';
  static String get percentagePerOrder =>
      _isAr ? 'نسبة من كل طلب' : 'Percentage per order';
  static String get monthlyFlat =>
      _isAr ? 'اشتراك شهري' : 'Monthly subscription';

  // Notifications
  static String get notificationsTitle =>
      _isAr ? 'الإشعارات' : 'Notifications';
  static String get readAll => _isAr ? 'قراءة الكل' : 'Read all';
  static String get noNotifications =>
      _isAr ? 'مفيش إشعارات' : 'No notifications';
  static String get noNotificationsDesc =>
      _isAr
          ? 'هيظهرلك هنا لما يكون فيه إشعارات جديدة'
          : 'New notifications will appear here';

  // Chat
  static String get chatTitle => _isAr ? 'تواصل معنا' : 'Contact Us';
  static String get chatNoConversations =>
      _isAr ? 'مفيش محادثات' : 'No conversations';
  static String get chatNoConversationsDesc =>
      _isAr
          ? 'ابدأ محادثة جديدة مع فريق الدعم'
          : 'Start a new conversation with support';
  static String get chatNewConversation =>
      _isAr ? 'محادثة جديدة' : 'New Conversation';
  static String get chatInitialMessage =>
      _isAr ? 'مرحبا، محتاج مساعدة' : 'Hello, I need help';
  static String get chatTypeSupport =>
      _isAr ? 'دعم فني' : 'Technical support';
  static String get chatTypeComplaint => _isAr ? 'شكوى' : 'Complaint';
  static String get chatTypeSuggestion =>
      _isAr ? 'اقتراح' : 'Suggestion';
  static String get chatTypeGeneral => _isAr ? 'عام' : 'General';
  static String get chatConversation => _isAr ? 'محادثة' : 'Conversation';
  static String get chatStartConversation =>
      _isAr ? 'ابدأ المحادثة...' : 'Start the conversation...';
  static String get chatMessageHint =>
      _isAr ? 'اكتب رسالة...' : 'Type a message...';
  static String get chatCloseConversation =>
      _isAr ? 'قفل المحادثة' : 'Close conversation';
  static String get chatCloseConfirm =>
      _isAr
          ? 'متأكد عايز تقفل المحادثة دي؟'
          : 'Are you sure you want to close this conversation?';
  static String get chatClosed =>
      _isAr ? 'المحادثة مقفولة' : 'Conversation closed';
  static String get chatClosedDesc =>
      _isAr
          ? 'المحادثة دي اتقفلت. افتح محادثة جديدة لو محتاج مساعدة.'
          : 'This conversation is closed. Start a new one if you need help.';

  // General
  static String get retry => _isAr ? 'حاول تاني' : 'Retry';
  static String get save => _isAr ? 'حفظ' : 'Save';
  static String get edit => _isAr ? 'تعديل' : 'Edit';
  static String get delete => _isAr ? 'مسح' : 'Delete';
  static String get deleteConfirm =>
      _isAr ? 'متأكد عايز تمسح؟' : 'Are you sure you want to delete?';
  static String get cancel => _isAr ? 'إلغاء' : 'Cancel';
  static String get confirm => _isAr ? 'تأكيد' : 'Confirm';
  static String get skip => _isAr ? 'تخطي' : 'Skip';
  static String get next => _isAr ? 'التالي' : 'Next';
  static String get back => _isAr ? 'رجوع' : 'Back';
  static String get search => _isAr ? 'بحث...' : 'Search...';
  static String get searchGlobal =>
      _isAr ? 'دوّر على طلب أو عميل أو شريك...' : 'Search orders, customers, partners...';
  static String get searchNoResults =>
      _isAr ? 'مفيش نتايج' : 'No results';
  static String get currency => _isAr ? 'ج.م' : 'EGP';
  static String get km => _isAr ? 'كم' : 'km';

  // ── Duplicate Check ──
  static const String duplicateWarningTitle = 'طلب مشابه موجود!';
  static const String duplicateWarningMessage =
      'في طلب شبه ده موجود قبل كده. متأكد إنك عايز تكمّل؟';
  static const String duplicateContinue = 'كمّل برضو';
  static const String duplicateCancel = 'لا، ارجع';
  static const String checkingDuplicate = 'بنتحقق من الطلب...';

  // ── Recurring Orders Management ──
  static const String recurringOrders = 'الطلبات المتكررة';
  static const String noRecurringOrders = 'مفيش طلبات متكررة';
  static const String noRecurringOrdersHint = 'أنشئ طلب متكرر من شاشة إضافة طلب';
  static const String pauseRecurring = 'إيقاف مؤقت';
  static const String resumeRecurring = 'تشغيل';
  static const String deleteRecurring = 'حذف';
  static const String recurringPaused = 'تم الإيقاف المؤقت';
  static const String recurringResumed = 'تم التشغيل';
  static const String recurringDeleted = 'تم حذف الطلب المتكرر';
  static const String nextScheduled = 'التسليم الجاي';
  static const String totalOccurrences = 'مرات التكرار';
  static const String confirmDeleteRecurring = 'متأكد إنك عايز تحذف الطلب المتكرر ده؟';

  // ── Navigation (Routes + Parking) ──
  static const String navigationTitle = 'التنقل';
  static const String tabRouteOptimize = 'حسّن مسارك';
  static const String tabParkingSpots = 'أماكن الركن';

  // ── Routes ──
  static const String routeOptimization = 'تحسين المسار';
  static const String optimizeRoute = 'حسّن مسارك';
  static const String activeRoute = 'المسار الحالي';
  static const String noActiveRoute = 'مفيش مسار نشط';
  static const String noActiveRouteHint = 'رتّب طلباتك وحسّن مسار التوصيل';
  static const String routeOptimized = 'تم تحسين المسار بنجاح';
  static const String routeCompleted = 'تم إنهاء المسار';
  static const String completeRoute = 'إنهاء المسار';
  static const String reorderRoute = 'إعادة ترتيب';
  static const String addToRoute = 'أضف للمسار';
  static const String estimatedTime = 'الوقت المتوقع';
  static const String totalRouteDistance = 'المسافة الكلية';
  static const String efficiencyScore = 'نقاط الكفاءة';
  static const String confirmCompleteRoute = 'متأكد إنك عايز تنهي المسار ده؟';
  static const String orderAddedToRoute = 'تم إضافة الطلب للمسار';
  static const String routeReordered = 'تم إعادة ترتيب المسار';
  static const String enterYourRoute = 'دخّل مسارك';
  static const String selectOrders = 'اختار الطلبات';
  static const String startPoint = 'نقطة البداية';
  static const String yourCurrentLocation = 'موقعك الحالي';
  static const String optimizationTypeLabel = 'نوع التحسين';
  static const String fastestRoute = 'أسرع مسار';
  static const String shortestRoute = 'أقصر مسار';
  static const String lowestCost = 'أقل تكلفة';
  static const String noActiveOrders = 'مفيش طلبات نشطة';
  static const String addOrderToRoute = 'ضيف طلب للمسار';
  static const String routeIsEmpty = 'المسار فاضي';
  static const String addOrdersToRoute = 'ضيف طلبات للمسار';
  static const String dragToReorder = 'اسحب عشان تعيد الترتيب';
  static const String noCoordinatesAvailable =
      'مفيش إحداثيات للطلبات — مينفعش نفتح الخريطة';
  static const String couldNotOpenNavigation = 'مش قادرين نفتح التنقل';
  static const String routeStats = 'إحصائيات المسار';
  static const String reOptimize = 'حسّن المسار';
  static const String deliverNext = 'وصّل';
  static const String allOrdersDelivered = 'كل الطلبات اتسلمت';
  static const String navigate = 'تنقّل';

  // ── Sync / Connection ──
  static const String syncStatus = 'حالة الاتصال';
  static const String syncing = 'جاري التحديث...';
  static const String syncComplete = 'متصل';
  static const String syncFailed = 'فشل التحديث';
  static const String syncNow = 'حدّث دلوقتي';
  static const String lastSyncAt = 'آخر تحديث';
  static const String pendingChanges = 'في انتظار الرفع';
  static const String conflicts = 'تعارضات';
  static const String resolveConflict = 'حل التعارض';
  static const String useLocal = 'استخدم المحلي';
  static const String useServer = 'استخدم من السيرفر';
  static const String syncOffline = 'أنت أوفلاين';
  static const String connectionStrong = 'النت كويس';
  static const String connectionWeak = 'النت ضعيف';
  static const String connectionOffline = 'مفيش نت';
  static const String connectionRestored = 'تمام! النت رجع';
  static const String connectionOfflineHint = 'شغلك محفوظ — هيترفع أول ما النت يرجع';
  static const String pendingUploads = 'حاجات مستنية ترتفع';

  // Badge
  static String get badgeTitle => _isAr ? 'بطاقتي' : 'My Badge';
  static String get badgeQrTitle =>
      _isAr ? 'كود QR الخاص بيك' : 'Your QR Code';
  static String get badgeQrSubtitle =>
      _isAr
          ? 'اعرض الكود للعميل عشان يتأكد من هويتك'
          : 'Show this code to customers to verify your identity';
  static String get badgeShare => _isAr ? 'شارك البطاقة' : 'Share badge';
  static String get badgeScanQr =>
      _isAr ? 'امسح QR سائق' : 'Scan Driver QR';
  static String get badgeScanHint =>
      _isAr
          ? 'وجّه الكاميرا على كود QR السائق'
          : 'Point camera at driver QR code';
  static String get badgeScanSubhint =>
      _isAr
          ? 'سيتم التحقق تلقائياً'
          : 'Verification will happen automatically';
  static String get badgeVerifyValid =>
      _isAr ? 'سائق موثّق' : 'Verified driver';
  static String get badgeVerifyInvalid =>
      _isAr ? 'الكود مش صالح' : 'Invalid QR code';
  static String get badgeLoadError =>
      _isAr ? 'مش قادرين نجيب البطاقة' : 'Could not load badge';
  static String get badgeShareText =>
      _isAr ? 'أنا سائق موثّق في سِكّة!' : 'I am a verified Sekka driver!';
  static String get badgeSectionLabel =>
      _isAr ? 'بطاقتي الرقمية' : 'My Digital Badge';

  // ── Parking ──
  static String get nearbyParking =>
      _isAr ? 'ركنة قريبة' : 'Nearby Parking';
  static String get myParkingSpots =>
      _isAr ? 'أماكن الركنة بتاعتي' : 'My Parking Spots';
  static String get addParkingSpot =>
      _isAr ? 'حفظ مكان ركن' : 'Save Parking Spot';
  static String get noParkingSpots =>
      _isAr ? 'مفيش أماكن ركن' : 'No Parking Spots';
  static String get noParkingSpotsHint =>
      _isAr ? 'احفظ أماكن الركن اللي بتستخدمها عشان ترجعلها بسهولة' : 'Save parking spots you use for easy access';
  static String get parkingPaid =>
      _isAr ? 'مدفوع' : 'Paid';
  static String get parkingFree =>
      _isAr ? 'مجاني' : 'Free';
  static String get parkingSaved =>
      _isAr ? 'تمام! المكان اتحفظ' : 'Parking spot saved';
  static String get parkingDeleted =>
      _isAr ? 'تمام! المكان اتمسح' : 'Parking spot deleted';
  static String get parkingAddress =>
      _isAr ? 'عنوان المكان' : 'Location Address';
  static String get parkingRating =>
      _isAr ? 'تقييم المكان' : 'Location Rating';
  static String get parkingIsPaid =>
      _isAr ? 'بفلوس؟' : 'Paid parking?';
  static String get deleteParkingConfirm =>
      _isAr ? 'متأكد إنك عايز تمسح المكان ده؟' : 'Are you sure you want to delete this spot?';
  static String get usageCount =>
      _isAr ? 'استخدمته كام مرة' : 'Usage Count';

  // ── Gamification ──
  static String get gamificationTitle =>
      _isAr ? 'التحديات والإنجازات' : 'Challenges & Achievements';
  static String get gamificationChallenges =>
      _isAr ? 'تحديات' : 'Challenges';
  static String get gamificationAchievements =>
      _isAr ? 'إنجازات' : 'Achievements';
  static String get gamificationLeaderboard =>
      _isAr ? 'الترتيب' : 'Leaderboard';
  static String get gamificationPoints =>
      _isAr ? 'نقطة' : 'Points';
  static String get gamificationLevel =>
      _isAr ? 'المستوى' : 'Level';
  static String get gamificationTotalPoints =>
      _isAr ? 'إجمالي النقاط' : 'Total Points';
  static String get gamificationClaimReward =>
      _isAr ? 'استلم المكافأة' : 'Claim Reward';
  static String get gamificationClaimed =>
      _isAr ? 'تم الاستلام' : 'Claimed';
  static String get gamificationProgress =>
      _isAr ? 'التقدم' : 'Progress';
  static String get gamificationRewardPoints =>
      _isAr ? 'نقاط المكافأة' : 'Reward Points';
  static String get gamificationNoChallenges =>
      _isAr ? 'لسه مفيش تحديات' : 'No challenges available';
  static String get gamificationNoChallengesHint =>
      _isAr ? 'استنى شوية — التحديات هتنزل قريب' : 'Challenges will appear here when available';
  static String get gamificationNoAchievements =>
      _isAr ? 'لسه مكسبتش إنجازات' : 'No achievements yet';
  static String get gamificationNoAchievementsHint =>
      _isAr ? 'خلّص التحديات وهتلاقي إنجازاتك هنا' : 'Complete challenges to earn achievements';
  static String get gamificationNoLeaderboard =>
      _isAr ? 'مفيش ترتيب لسه' : 'No leaderboard data';
  static String get gamificationNoLeaderboardHint =>
      _isAr ? 'لما المنافسة تبدأ هتلاقي ترتيبك هنا' : 'Leaderboard will show when competition starts';
  static String get gamificationYourRank =>
      _isAr ? 'ترتيبك' : 'Your Rank';
  static String get gamificationPointsHistory =>
      _isAr ? 'سجل النقاط' : 'Points History';
  static String get gamificationNoHistory =>
      _isAr ? 'مفيش نقاط لسه' : 'No points history';
  static String get gamificationNoHistoryHint =>
      _isAr ? 'كل نقطة هتكسبها هتتسجل هنا' : 'Points you earn will appear here';
  static String get gamificationPeriodMonthly =>
      _isAr ? 'الشهر ده' : 'Monthly';
  static String get gamificationPeriodWeekly =>
      _isAr ? 'الأسبوع ده' : 'Weekly';
  static String get gamificationOrdersThisMonth =>
      _isAr ? 'أوردر الشهر ده' : 'Orders this month';
  static String get gamificationClaimSuccess =>
      _isAr ? 'مبروك! المكافأة وصلتك' : 'Reward claimed!';
  static String get gamificationLoadError =>
      _isAr ? 'مش قادرين نجيب البيانات' : 'Could not load data';

  // ── Colleague Radar ──
  static String get radarTitle =>
      _isAr ? 'رادار الزملاء' : 'Colleague Radar';
  static String get radarTab =>
      _isAr ? 'الزملاء' : 'Colleagues';
  static String get radarNearbyDrivers =>
      _isAr ? 'سواقين قريبين' : 'Nearby Drivers';
  static String get radarNoNearby =>
      _isAr ? 'مفيش زملاء قريبين منك' : 'No colleagues nearby';
  static String get radarNoNearbyHint =>
      _isAr ? 'الزملاء هيظهروا هنا لما يكونوا في نطاقك' : 'Colleagues will appear when nearby';
  static String get radarHelpRequests =>
      _isAr ? 'طلبات مساعدة' : 'Help Requests';
  static String get radarMyRequests =>
      _isAr ? 'طلباتي' : 'My Requests';
  static String get radarNoRequests =>
      _isAr ? 'مفيش طلبات مساعدة' : 'No help requests';
  static String get radarNoRequestsHint =>
      _isAr ? 'لو احتجت مساعدة ابعت طلب والزملاء هيوصلوك' : 'Send a help request and colleagues will reach you';
  static String get radarSendHelp =>
      _isAr ? 'ابعت طلب مساعدة' : 'Send Help Request';
  static String get radarHelpTitle =>
      _isAr ? 'عنوان المشكلة' : 'Problem Title';
  static String get radarHelpDesc =>
      _isAr ? 'وصف المشكلة' : 'Problem Description';
  static String get radarHelpType =>
      _isAr ? 'نوع المساعدة' : 'Help Type';
  static String get radarRespond =>
      _isAr ? 'هساعدك' : 'I\'ll Help';
  static String get radarResolve =>
      _isAr ? 'المشكلة اتحلت' : 'Resolved';
  static String get radarRespondSuccess =>
      _isAr ? 'تمام! انت قبلت تساعد' : 'You accepted to help!';
  static String get radarResolveSuccess =>
      _isAr ? 'الحمد لله اتحلت!' : 'Resolved!';
  static String get radarAway =>
      _isAr ? 'كم' : 'km';
  static String get radarHelpTypeMechanical =>
      _isAr ? 'عطلة ميكانيكية' : 'Mechanical';
  static String get radarHelpTypeTire =>
      _isAr ? 'كاوتش' : 'Tire';
  static String get radarHelpTypeFuel =>
      _isAr ? 'بنزين' : 'Fuel';
  static String get radarHelpTypeOrder =>
      _isAr ? 'محتاج حد يكمّل أوردر' : 'Need order help';
  static String get radarHelpTypeOther =>
      _isAr ? 'تاني' : 'Other';

  // ── Home Screen ──
  static String get statOrders =>
      _isAr ? 'طلبات' : 'Orders';
  static String get statDelivered =>
      _isAr ? 'تسليم' : 'Delivered';
  static String get statSuccess =>
      _isAr ? 'نجاح' : 'Success';
  static String get welcomeBack =>
      _isAr ? 'أهلاً بيك' : 'Welcome back';
  static String get homeReadyToStart =>
      _isAr ? 'جاهز تبدأ يومك؟' : 'Ready to start your day?';
  static String get homeShiftRunningFor =>
      _isAr ? 'الوردية شغّالة لـ' : 'Shift running for';
  static String get homeDeliveringNow =>
      _isAr ? 'بتوصّل دلوقتي' : 'Delivering now';
  static String get homeMarkDelivered =>
      _isAr ? 'وصلت ✓' : 'Delivered ✓';
  static String get homeOpenOrder =>
      _isAr ? 'افتح الطلب' : 'Open order';
  static String get homeAddOrderCta =>
      _isAr ? 'ضيف أوردر جديد' : 'Add new order';
  static String get homeQuickAddOrder =>
      _isAr ? 'أوردر' : 'Order';
  static String get homeQuickSettle =>
      _isAr ? 'سلّم كاش' : 'Settle';
  static String get homeQuickBreak =>
      _isAr ? 'استراحة' : 'Break';
  static String get homeQuickToday =>
      _isAr ? 'اليوم' : 'Today';
  static String get homePendingOrders =>
      _isAr ? 'طلبات مستنياك' : 'Pending orders';
  static String get homeSeeAllOrders =>
      _isAr ? 'شوف كل الطلبات' : 'See all orders';
  static String get homeActiveRoute =>
      _isAr ? 'مسار النهارده' : 'Today\'s route';
  static String get homeOpenRoute =>
      _isAr ? 'افتح المسار' : 'Open route';
  static String get homeCashTooMuch =>
      _isAr ? 'الكاش معاك كتير — وقت تسليم' : 'Cash is high — time to settle';
  static String get homeQuietDay =>
      _isAr ? 'اليوم هادي' : 'Quiet day';
  static String get homeQuietDaySubtitle =>
      _isAr ? 'ضيف أوردر تبدأ' : 'Add an order to start';
  static String get homeMinutes =>
      _isAr ? 'دقيقة' : 'min';
  static String get homeHour =>
      _isAr ? 'ساعة' : 'hr';
  static String get deliveryBusyTitle =>
      _isAr ? 'في طلب لسه في السكة' : 'Already delivering';
  static String get deliveryBusyBody =>
      _isAr
          ? 'خلّص اللي بتوصله الأول، وبعدين ابدأ التاني.'
          : 'Finish the order on the road first.';
  static String get deliveryBusyGoToCurrent =>
      _isAr ? 'ارجع للطلب اللي شغال' : 'Go to current order';
  static String get homeShiftEarnings =>
      _isAr ? 'كسبت في الوردية' : 'Earned this shift';
  static String get homeShiftOrders =>
      _isAr ? 'طلبات الوردية' : 'Shift orders';
  static String get homeOrdersUnit =>
      _isAr ? 'طلب' : 'orders';
  static String get homeCashLabel =>
      _isAr ? 'الكاش معاك دلوقتي' : 'Cash on hand now';
  static String get homeCashHint =>
      _isAr ? 'فلوس عملاء لسه ما اتسلّمتش' : 'Customer cash not yet settled';
  static String get homeOthersInTransit =>
      _isAr ? 'في السكة' : 'on the road';
  static String get homeOpenForDelivery =>
      _isAr ? 'افتح وسلّم' : 'Open & deliver';
  static String get homeFollowOnMap =>
      _isAr ? 'تابع على الخريطة' : 'Follow on map';
  static String get homeNextOrder =>
      _isAr ? 'الطلب الجاي' : 'Next order';
  static String get homeOrderNoCustomer =>
      _isAr ? 'طلب' : 'Order';
  static String get homeRouteHintTitle =>
      _isAr ? 'حسّن مسار التوصيل' : 'Optimize your route';
  static String get homeRouteHintSubtitle =>
      _isAr ? 'رتّب طلباتك وفّر وقت ووقود' : 'Reorder stops, save time & fuel';
  static String get homeViewAll =>
      _isAr ? 'عرض الكل' : 'View all';
  static String get homeRouteActiveTitle =>
      _isAr ? 'المسار شغّال' : 'Route active';
  static String get homeRouteActiveSubtitle =>
      _isAr ? 'افتح عشان ترتّب أو تعدّل' : 'Open to reorder or adjust';
  // ── Settlements — compact stats + checklist UI ──
  static String get settleTodayLabel =>
      _isAr ? 'اليوم' : 'Today';
  static String get settleCollectedShort =>
      _isAr ? 'جمعت' : 'Collected';
  static String get settleSettledShort =>
      _isAr ? 'سلّمت' : 'Settled';
  static String get settleRemainingShort =>
      _isAr ? 'باقي' : 'Remaining';
  static String get settleCollectedFromCustomers =>
      _isAr ? 'جمعت من العملاء' : 'Collected from customers';
  static String get settleSettledToPartners =>
      _isAr ? 'سلّمت للشركاء' : 'Settled to partners';
  static String get settleRemainingWithYou =>
      _isAr ? 'باقي معاك' : 'Remaining with you';
  static String get settleCountToday =>
      _isAr ? 'عدد التسليمات' : 'Handover count';
  static String get settleUnsettledTitle =>
      _isAr ? 'لسه عليك شركاء' : 'Unsettled partners';
  static String get settleAllDoneTitle =>
      _isAr ? 'كله اتسلّم!' : 'All settled!';
  static String get settleAllDoneSubtitle =>
      _isAr ? 'كل الشركاء واخدين حقهم' : 'All partners are settled';
  static String get settleTodayCompletedTitle =>
      _isAr ? 'سلّمت لهم النهاردا' : 'Settled today';
  static String get settleFullHistoryLink =>
      _isAr ? 'اللي فات' : 'Past settlements';
  static String get settleShareSummary =>
      _isAr ? 'شارك الملخص' : 'Share summary';
  static String get settleDetailsHeader =>
      _isAr ? 'تفاصيل التسليم' : 'Settlement details';
  static String get orderCountShort =>
      _isAr ? 'كام طلب؟' : 'Orders';
  static String get advancedSettings =>
      _isAr ? 'تفاصيل زيادة؟' : 'More details?';
  static String get settleTapForDetails =>
      _isAr ? 'اضغط عشان تشوف التفاصيل' : 'Tap for details';
  static String get settleNow =>
      _isAr ? 'سلّم' : 'Settle';
  static String settleFromOrders(int count) =>
      _isAr ? 'من $count طلب' : 'from $count orders';
  static String get settleEmptyStateTitle =>
      _isAr ? 'مفيش شركاء لسه' : 'No partners yet';
  static String get settleEmptyStateSubtitle =>
      _isAr ? 'ضيف أول شريك عشان تبدأ' : 'Add your first partner to start';
  static String get startDeliveringNow =>
      _isAr ? 'ابدأ وصّل طلباتك!' : 'Start delivering your orders!';
  static String get addOrdersToStart =>
      _isAr ? 'ضيف طلباتك وابدأ التوصيل' : 'Add your orders and start delivering';
  static String get startShiftWithOrder =>
      _isAr ? 'يلا ابدأ ورديتك' : 'Start your shift';
  static String get deliverFirstOrder =>
      _isAr ? 'ابدأ بتوصيل أول طلب' : 'Start by delivering the first order';
  static String get detailedStatistics =>
      _isAr ? 'إحصائياتك بالتفصيل' : 'Detailed Statistics';
  static String get viewDetailedStatsHint =>
      _isAr ? 'تابع أداءك وأرباحك بالتفصيل' : 'Track your performance and earnings in detail';
  static String get optimizeYourRoute =>
      _isAr ? 'إنشاء مسار' : 'Create Route';
  static String get optimizeRouteHint =>
      _isAr ? 'رتّب طلباتك ووفّر وقت ومسافة' : 'Sort your orders and save time & distance';
  static String get enterYourRouteBtn =>
      _isAr ? 'دخّل مسارك' : 'Enter Your Route';
  static String get locatingPosition =>
      _isAr ? 'بنحدد مكانك...' : 'Locating...';
  static String get locationFailed =>
      _isAr ? 'مقدرناش نحدد مكانك' : 'Could not determine location';

  // Shifts
  static String get shiftStart =>
      _isAr ? 'ابدأ الوردية' : 'Start Shift';
  static String get shiftEnd =>
      _isAr ? 'إنهي الوردية' : 'End Shift';
  static String get shiftActive =>
      _isAr ? 'الوردية شغّالة' : 'Shift Active';
  static String get shiftInactive =>
      _isAr ? 'مفيش وردية' : 'No Active Shift';
  static String get shiftStarted =>
      _isAr ? 'الوردية بدأت!' : 'Shift started!';
  static String get shiftEnded =>
      _isAr ? 'الوردية خلصت!' : 'Shift ended!';
  static String get shiftSummaryTitle =>
      _isAr ? 'ملخص الورديات' : 'Shift Summary';
  static String get shiftPerformanceTitle =>
      _isAr ? 'أداءك والورديات' : 'Performance & Shifts';
  static String get totalShifts =>
      _isAr ? 'إجمالي الورديات' : 'Total Shifts';
  static String get totalHoursWorked =>
      _isAr ? 'ساعات العمل' : 'Hours Worked';
  static String get totalOrdersCompleted =>
      _isAr ? 'الطلبات المكتملة' : 'Orders Completed';
  static String get totalEarnings =>
      _isAr ? 'إجمالي الأرباح' : 'Total Earnings';
  static String get totalDistanceKm =>
      _isAr ? 'المسافة (كم)' : 'Distance (km)';
  static String get avgShiftDuration =>
      _isAr ? 'متوسط مدة الوردية' : 'Avg Shift Duration';
  static String get shiftEndConfirm =>
      _isAr ? 'متأكد إنك عايز تنهي الوردية؟' : 'Are you sure you want to end the shift?';
  static String get shiftEarnings =>
      _isAr ? 'كسبت الورديه' : 'Shift Earnings';
  static String get shiftOrders =>
      _isAr ? 'طلبات الورديه' : 'Shift Orders';
  static String get cashWithYouNow =>
      _isAr ? 'الكاش معاك دلوقتي' : 'Cash With You Now';
  static String get addNewOrder =>
      _isAr ? 'ضيف أوردر جديد' : 'Add New Order';
  static String get quickAddOrder =>
      _isAr ? 'أوردر' : 'Order';
  static String get quickSettleCash =>
      _isAr ? 'سلّم كاش' : 'Settle Cash';
  static String get hour => _isAr ? 'س' : 'h';
  static String get minute => _isAr ? 'د' : 'm';

  // Analytics
  static String get analyticsTitle =>
      _isAr ? 'تحليلات الأداء' : 'Performance Analytics';
  static String get analyticsProfitabilityTrends =>
      _isAr ? 'اتجاهات الربحية' : 'Profitability Trends';
  static String get analyticsTimeAnalysis =>
      _isAr ? 'أوقات الذروة' : 'Peak Hours';
  static String get analyticsRegionAnalysis =>
      _isAr ? 'تحليل المناطق' : 'Region Analysis';
  static String get analyticsSourceBreakdown =>
      _isAr ? 'مصادر الأوردرات' : 'Order Sources';
  static String get analyticsCustomerProfitability =>
      _isAr ? 'أعلى عملاء ربحية' : 'Top Customers';
  static String get analyticsCancellationReport =>
      _isAr ? 'تقرير الإلغاءات' : 'Cancellation Report';
  static String get analyticsRevenue =>
      _isAr ? 'الإيراد' : 'Revenue';
  static String get analyticsExpenses =>
      _isAr ? 'المصاريف' : 'Expenses';
  static String get analyticsNetProfit =>
      _isAr ? 'صافي الربح' : 'Net Profit';
  static String get analyticsProfitMargin =>
      _isAr ? 'هامش الربح' : 'Profit Margin';
  static String get analyticsOrders =>
      _isAr ? 'طلب' : 'orders';
  static String get analyticsNoData =>
      _isAr ? 'مفيش بيانات كافية لسه' : 'Not enough data yet';

  // Contacts Screen
  static String get favoriteCustomers =>
      _isAr ? 'العملاء المفضلين' : 'Favorite Customers';
  static String get noCustomers =>
      _isAr ? 'مفيش عملاء' : 'No customers';
  static String get noCustomersDesc =>
      _isAr ? 'العملاء هيظهروا هنا لما تبدأ توصيل' : 'Customers will appear here when you start delivering';
  static String get noPartners =>
      _isAr ? 'مفيش شركاء' : 'No partners';
  static String get noPartnersDesc =>
      _isAr ? 'مفيش شركاء متاحين دلوقتي' : 'No partners available right now';
  static String get otherType =>
      _isAr ? 'أخرى' : 'Other';

  // Onboarding
  static String get onboardingTitle =>
      _isAr ? 'طريقك أخضر.. ومكسبك أكبر' : 'Your path is clear.. and your profit is bigger';
  static String get onboardingDesc =>
      _isAr
          ? 'أوردراتك قريبة، خريطتك دقيقة، وفلوسك بتزيد مع كل مشوار. سِكّة هو اللي شايل عنك التفكير.'
          : 'Your orders are nearby, your map is accurate, and your earnings grow with every trip. Sekka takes care of the thinking for you.';
  static String get letsStart =>
      _isAr ? 'نبدأ دلوقتي!' : 'Let\'s start!';
  static String get tryWithoutRegistration =>
      _isAr ? 'جرّب بدون تسجيل' : 'Try without registration';

  // Map Picker
  static String get searchPlace =>
      _isAr ? 'ابحث عن مكان...' : 'Search for a place...';
  static String get fetchingAddress =>
      _isAr ? 'بنجيب العنوان...' : 'Getting address...';
  static String get moveMapToSelect =>
      _isAr ? 'حرّك الخريطة عشان تحدد المكان' : 'Move the map to select location';
  static String get confirmLocation =>
      _isAr ? 'تأكيد الموقع' : 'Confirm Location';

  // Dialog
  static String get infoTitle =>
      _isAr ? 'معلومة' : 'Info';

  // Validators
  static String get thisField =>
      _isAr ? 'هذا الحقل' : 'This field';
  static String get isRequired =>
      _isAr ? 'مطلوب' : 'is required';
  static String get enterAmount =>
      _isAr ? 'أدخل المبلغ' : 'Enter amount';
  static String get enterValidAmount =>
      _isAr ? 'أدخل مبلغ صحيح' : 'Enter a valid amount';
  static String get enterAddressValidation =>
      _isAr ? 'أدخل العنوان' : 'Enter address';
  static String get addressTooShort =>
      _isAr ? 'العنوان قصير جداً' : 'Address is too short';

  // Orders — Detail Screen (Menu)
  static String get menuEditOrder => _isAr ? 'عدّل الطلب' : 'Edit Order';
  static String get menuDeleteOrder => _isAr ? 'امسح الطلب' : 'Delete Order';
  static String get menuSwapAddress => _isAr ? 'غيّر العنوان' : 'Change Address';
  static String get menuPhotoOrder => _isAr ? 'صوّر الطلب' : 'Photo Order';
  static String get menuDisclaimer => _isAr ? 'إخلاء مسؤولية' : 'Disclaimer';
  static String get menuOpenDispute => _isAr ? 'فتح نزاع' : 'Open Dispute';
  static String get menuRequestRefund => _isAr ? 'طلب استرداد' : 'Request Refund';
  static String get menuBookSlot => _isAr ? 'احجز موعد تسليم' : 'Book Delivery Slot';

  // Orders — Detail Screen (Labels)
  static String get deliveryDestination => _isAr ? 'هيتوصّل فين' : 'Delivery destination';
  static String get pickupSource => _isAr ? 'هيتستلم منين' : 'Pickup source';
  static String get partnerMerchant => _isAr ? 'الشريك/التاجر' : 'Partner/Merchant';
  static String get shipmentDescriptionLabel => _isAr ? 'وصف الشحنة' : 'Shipment description';
  static String get worthScoreLabel => _isAr ? 'نقاط القيمة' : 'Worth score';
  static String get deliverySequence => _isAr ? 'ترتيب التوصيل' : 'Delivery sequence';

  // Orders — Detail Screen (Buttons)
  static String get partialDelivery => _isAr ? 'تسليم جزئي' : 'Partial Delivery';
  static String get couldNotDeliver => _isAr ? 'معرفتش أسلّم' : 'Could not deliver';
  static String get cancelThisOrder => _isAr ? 'ألغي الطلب' : 'Cancel Order';

  // Orders — Detail Screen (Timer)
  static String get waitingTimer => _isAr ? 'مؤقت الانتظار' : 'Waiting Timer';
  static String get timerRunning => _isAr ? 'المؤقت شغال...' : 'Timer running...';
  static String get timerStopped => _isAr ? 'المؤقت واقف' : 'Timer stopped';
  static String get stopTimer => _isAr ? 'وقّف المؤقت' : 'Stop Timer';
  static String get startTimer => _isAr ? 'ابدأ المؤقت' : 'Start Timer';

  // Orders — Detail Screen (Terminal Banners)
  static String get orderDeliveredBanner => _isAr ? 'الطلب اتسلّم بنجاح' : 'Order delivered successfully';
  static String get orderPartialBanner => _isAr ? 'اتسلّم جزء من الطلب' : 'Partially delivered';
  static String get orderCancelledBanner => _isAr ? 'الطلب ده اتلغى' : 'Order cancelled';
  static String get orderReturnedBanner => _isAr ? 'الطلب رجع تاني' : 'Order returned';

  // Orders — Detail Screen (Photo)
  static String get choosePhotoType => _isAr ? 'اختار نوع الصورة' : 'Choose photo type';
  static String orderPhotos(int count) => _isAr ? 'صور الطلب ($count)' : 'Order photos ($count)';

  // Orders — Detail Screen (Forms)
  static String get moreDetailsOptional => _isAr ? 'تفاصيل أكتر (اختياري)' : 'More details (optional)';
  static String get howManyDelivered => _isAr ? 'كام قطعة سلّمت؟' : 'How many items delivered?';
  static String get totalItems => _isAr ? 'إجمالي القطع' : 'Total items';
  static String get collectedAmountHint => _isAr ? 'المبلغ اللي حصّلته' : 'Amount collected';
  static String get remainingAmountHint => _isAr ? 'المبلغ المتبقي' : 'Remaining amount';
  static String get reasonOptional => _isAr ? 'السبب (اختياري)' : 'Reason (optional)';

  // Orders — Detail Screen (Swap Address)
  static String get swapAddressTitle => _isAr ? 'غيّر العنوان' : 'Change Address';
  static String get pickNewAddress => _isAr ? 'حدد العنوان الجديد' : 'Pick new address';
  static String get tapToPickNewAddress => _isAr ? 'اضغط عشان تحدد العنوان الجديد' : 'Tap to pick new address';

  // Orders — Detail Screen (Disclaimer)
  static String get disclaimerTitle => _isAr ? 'إخلاء مسؤولية' : 'Disclaimer';
  static String get shipmentCondition => _isAr ? 'حالة الشحنة' : 'Shipment condition';
  static String get shipmentConditionHint => _isAr ? 'حالة الشحنة (مثلاً: مكسورة، مفتوحة)' : 'Condition (e.g. broken, opened)';
  static String get contentsDescription => _isAr ? 'وصف المحتويات' : 'Contents description';
  static String get contentsDescriptionHint => _isAr ? 'وصف المحتويات (مثلاً: 2 كرتونة، علبة)' : 'Contents (e.g. 2 boxes, 1 bag)';

  // Orders — Detail Screen (Dispute)
  static String get openDisputeTitle => _isAr ? 'فتح نزاع' : 'Open Dispute';
  static String get describeProblemInDetail => _isAr ? 'اوصف المشكلة بالتفصيل' : 'Describe the problem in detail';

  // Orders — Detail Screen (Refund)
  static String get requestRefundTitle => _isAr ? 'طلب استرداد' : 'Request Refund';
  static String get refundAmount => _isAr ? 'مبلغ الاسترداد' : 'Refund amount';
  static String get refundReason => _isAr ? 'سبب الاسترداد' : 'Refund reason';

  // Orders — Detail Screen (Booking)
  static String get bookSlotTitle => _isAr ? 'احجز موعد تسليم' : 'Book Delivery Slot';
  static String get slotNumber => _isAr ? 'رقم الموعد' : 'Slot number';
  static String get dateLabel => _isAr ? 'التاريخ' : 'Date';
  static String get datePlaceholder => _isAr ? 'التاريخ (مثال: 2026-03-28)' : 'Date (e.g. 2026-03-28)';
  static String get bookSlotAction => _isAr ? 'احجز الموعد' : 'Book Slot';

  // Orders — List Screen
  static String get noOrdersTitle => _isAr ? 'مفيش طلبات' : 'No orders';
  static String get noOrdersWithFilter => _isAr ? 'مفيش طلبات بالحالة دي' : 'No orders with this status';
  static String get noSearchResults => _isAr ? 'مفيش نتايج' : 'No results';
  static String get tryDifferentSearchOrder => _isAr ? 'جرّب اسم عميل أو رقم تاني' : 'Try a different customer name or number';

  // Orders — Duplicate Warning
  static String get orderNumberPrefix => _isAr ? 'رقم الطلب' : 'Order number';
  static String matchScoreLabel(int score) => _isAr ? 'نسبة التشابه: $score%' : 'Match score: $score%';

  // Orders — Create Screen (Voice Tab)
  static String get voiceOrderTitle => _isAr ? 'قول الطلب بصوتك' : 'Say your order';
  static String get voiceOrderHint =>
      _isAr
          ? 'اضغط على المايك وقول بيانات الطلب\nزي: "طلب لمحمد، العنوان المعادي، المبلغ 150 جنيه"'
          : 'Press the mic and say order details\ne.g. "Order for Mohamed, address Maadi, amount 150 EGP"';
  static String get voiceComingSoon => _isAr ? 'الميزة دي جاية قريب' : 'Coming soon';

  // Date — Localized
  static String get greetingMorning =>
      _isAr ? 'صباح الخير' : 'Good morning';
  static String get greetingEvening =>
      _isAr ? 'مساء الخير' : 'Good evening';
  static String get greetingNight =>
      _isAr ? 'أهلا بيك' : 'Welcome';
  static String get amPeriod => _isAr ? 'ص' : 'AM';
  static String get pmPeriod => _isAr ? 'م' : 'PM';
  static List<String> get dayNames => _isAr
      ? const ['الاثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة', 'السبت', 'الأحد']
      : const ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
  static List<String> get monthNames => _isAr
      ? const ['يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو', 'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر']
      : const ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];

  // Favorite Drivers
  static String get favoriteDriversTitle =>
      _isAr ? 'زملائي المفضلين' : 'My Favorites';
  static String get favoriteDriversEmpty =>
      _isAr ? 'مفيش زملاء مفضلين' : 'No favorite colleagues';
  static String get favoriteDriversEmptyDesc =>
      _isAr
          ? 'أضف زملاءك عشان تحوّلهم أوردرات بسرعة'
          : 'Add colleagues for quick order transfers';
  static String get addFavoriteDriver =>
      _isAr ? 'أضف زميل' : 'Add colleague';
  static String get colleagueName =>
      _isAr ? 'اسم الزميل' : 'Colleague name';
  static String get colleaguePhone =>
      _isAr ? 'رقم الزميل' : 'Colleague phone';
  static String get onApp =>
      _isAr ? 'على التطبيق' : 'On app';
  static String get notOnApp =>
      _isAr ? 'مش على التطبيق' : 'Not on app';
  static String get sendViaWhatsApp =>
      _isAr ? 'ابعت على واتساب' : 'Send via WhatsApp';
  static String get transferDirect =>
      _isAr ? 'حوّل مباشر' : 'Transfer directly';
  static String get searchByPhone =>
      _isAr ? 'ابحث برقم الموبايل' : 'Search by phone';
  static String get removeFavoriteConfirm =>
      _isAr ? 'هتشيل الزميل ده من المفضلين؟' : 'Remove this colleague from favorites?';
  static String get remove =>
      _isAr ? 'شيّل' : 'Remove';
  static String get maxFavoritesReached =>
      _isAr ? 'وصلت الحد الأقصى (30 زميل)' : 'Maximum reached (30 colleagues)';
  static String get phoneHintEgyptian =>
      _isAr ? 'مثال: ٠١٠١٢٣٤٥٦٧٨' : 'e.g. 01012345678';
  static String get transferChooseMethod =>
      _isAr ? 'اختار طريقة التحويل' : 'Choose transfer method';
  static String get orSearchNewColleague =>
      _isAr ? 'أو ابحث عن زميل جديد' : 'Or search for a new colleague';
}
