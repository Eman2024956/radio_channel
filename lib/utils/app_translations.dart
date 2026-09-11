import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/locale_provider.dart';

class AppTranslations {
  final bool isArabic;

  const AppTranslations({required this.isArabic});

  static AppTranslations of(BuildContext context) {
    final isAr = context.watch<LocaleProvider>().isArabic;
    return AppTranslations(isArabic: isAr);
  }

  // General & Navigation
  String get appName => isArabic ? 'راديو فلاح' : 'FALAH RADIO';
  String get appSubtitle => isArabic ? 'مشغل محطات الراديو العالمية - فلاح كاطع صالح' : 'Global Live Radio by Falah G. Salieh';
  String get navHome => isArabic ? 'الرئيسية' : 'Home';
  String get navCountries => isArabic ? 'الدول' : 'Countries';
  String get navSearch => isArabic ? 'البحث' : 'Search';
  String get navFavorites => isArabic ? 'المفضلة' : 'Favorites';
  String get navDownloads => isArabic ? 'التسجيلات' : 'Downloads';

  // Stats
  String get liveRadios => isArabic ? 'محطة مباشرة' : 'Live Radios';
  String get countriesCount => isArabic ? 'دولة' : 'Countries';
  String get recordable => isArabic ? 'تسجيل MP3' : 'Recordable';

  // Home Screen
  String get featuredLive => isArabic ? 'بث مباشر مميز' : 'FEATURED LIVE';
  String get mostListened => isArabic ? '🔥 الأكثر استماعاً حول العالم' : '🔥 Most Listened Worldwide';
  String get communityTopRated => isArabic ? '⭐ الأعلى تقييماً' : '⭐ Community Top Rated';
  String get countryCategories => isArabic ? 'تصنيفات الدول' : 'Country Categories';
  String get viewAllCountries => isArabic ? 'عرض كل الـ 180+ دولة' : 'View All 180+';
  String get exploreByGenre => isArabic ? 'استكشف حسب النوع والتصنيف' : 'Explore by Genre';
  String get seeAll => isArabic ? 'عرض المزيد' : 'See All';
  String get retry => isArabic ? 'إعادة المحاولة' : 'Retry';
  String get global => isArabic ? 'عالمي' : 'Global';
  String get allCountries => isArabic ? 'جميع الدول' : 'All Countries';

  // Countries Screen
  String get countryCategoriesSubtitle =>
      isArabic ? 'تصفح المحطات الإذاعية حسب الثقافات والدول' : 'Browse channels by nation and culture';
  String get searchCountriesHint =>
      isArabic ? 'ابحث في أكثر من 180 دولة بالاسم أو الرمز...' : 'Search 180+ countries by name or code...';
  String get allNations => isArabic ? '🌍 جميع الدول' : '🌍 All Nations';
  String get arabWorld => isArabic ? '🕌 العالم العربي والشرق الأوسط' : '🕌 Arab & Middle East';
  String get europe => isArabic ? '🏰 أوروبا' : '🏰 Europe';
  String get americas => isArabic ? '🌎 الأمريكتين' : '🌎 Americas';
  String get asia => isArabic ? '🏯 آسيا' : '🏯 Asia';
  String get stationsCount => isArabic ? 'محطة إذاعية' : 'Live Radios';
  String get noMatchingCountries => isArabic ? 'لم يتم العثور على دول مطابقة' : 'No matching countries found';

  // Search Screen
  String get searchStationsHint =>
      isArabic ? 'ابحث عن محطة إذاعية بالاسم أو الكلمة الدلالية...' : 'Search stations by name or keyword...';
  String get advancedFilters => isArabic ? 'خيارات التصفية' : 'Advanced Filters';
  String get searchingChannels => isArabic ? 'جاري البحث عن المحطات...' : 'Searching channels...';
  String foundStations(int count) => isArabic ? 'تم العثور على $count محطة' : 'Found $count stations';
  String get clearAll => isArabic ? 'مسح الكل' : 'Clear All';
  String get noStationsFound => isArabic ? 'لم يتم العثور على محطات إذاعية' : 'No radio stations found';
  String get tryChangingSearch =>
      isArabic ? 'حاول تغيير كلمات البحث أو معايير التصفية' : 'Try changing your search keywords or filter criteria';
  String get resetFilters => isArabic ? 'إعادة ضبط التصفية' : 'Reset All Filters';

  // Sort By
  String get sortBy => isArabic ? 'ترتيب حسب' : 'Sort By';
  String get sortPopular => isArabic ? '🔥 الأكثر شعبية' : '🔥 Most Popular';
  String get sortTopVoted => isArabic ? '⭐ الأعلى تصويتاً' : '⭐ Top Voted';
  String get sortHighQuality => isArabic ? '🎵 أعلى جودة' : '🎵 High Quality';
  String get sortName => isArabic ? '🔤 الاسم (أ - ي)' : '🔤 Name (A-Z)';
  String get sortRandom => isArabic ? '🎲 عشوائي' : '🎲 Random';

  // Filter Sheet
  String get audioCodec => isArabic ? 'صيغة الصوت' : 'Audio Codec';
  String get minBitrate => isArabic ? 'أدنى معدل بت' : 'Minimum Bitrate';
  String get languageFilter => isArabic ? 'تصفية حسب اللغة' : 'Language Filter';
  String get countryFilter => isArabic ? 'تصفية حسب الدولة' : 'Country Filter';
  String get genreFilter => isArabic ? 'التصنيف / النوع' : 'Genre / Category';
  String get applyFilters => isArabic ? 'تطبيق خيارات التصفية' : 'Apply Filters';
  String get any => isArabic ? 'أي معدل' : 'Any';
  String get allLanguages => isArabic ? '🌐 جميع اللغات' : '🌐 All Languages';

  // Player Screen
  String get nowStreaming => isArabic ? 'جاري البث المباشر' : 'NOW STREAMING';
  String get stationDetails => isArabic ? 'تفاصيل المحطة وبيانات البث' : 'Station Details & Stream Specs';
  String get streamType => isArabic ? 'نوع البث' : 'Stream Type';
  String get votes => isArabic ? 'أصوات المجتمع' : 'Community Votes';
  String get totalListens => isArabic ? 'إجمالي الاستماعات' : 'Total Listens';
  String get recordMp3 => isArabic ? 'تسجيل MP3' : 'Record MP3';
  String get copyUrl => isArabic ? 'نسخ الرابط' : 'Copy URL';
  String get website => isArabic ? 'الموقع الرسمي' : 'Website';
  String get urlCopied => isArabic ? 'تم نسخ رابط البث إلى الحافظة!' : 'Stream URL copied to clipboard!';
  String get tagsGenres => isArabic ? 'التصنيفات والأنواع:' : 'Tags / Genres:';

  // Recording & Download Modal
  String get recordDownloadMp3 => isArabic ? 'تسجيل / تحميل MP3' : 'Record / Download MP3';
  String get selectDuration => isArabic ? 'اختر مدة التسجيل:' : 'Select Recording Duration:';
  String get quickClip => isArabic ? 'مقطع سريع' : 'Quick Clip';
  String get standard => isArabic ? 'قياسي' : 'Standard';
  String get songTrack => isArabic ? 'أغنية' : 'Song Track';
  String get segment => isArabic ? 'فقرة كاملة' : 'Segment';
  String get fullShow => isArabic ? 'برنامج كامل' : 'Full Show';
  String get savedInDownloadsNote => isArabic
      ? 'يتم الحفظ مباشرة بصيغة MP3 في مجلد التنزيلات بالجهاز (RadioRecordings).'
      : 'Saved directly as MP3 to your real device Download folder (RadioRecordings).';
  String get startRecording => isArabic ? 'بدء التسجيل' : 'Start Recording';
  String get recordingInProgress => isArabic ? 'جاري التسجيل...' : 'Recording in progress...';
  String get stopAndSaveNow => isArabic ? 'إيقاف وحفظ التسجيل الآن' : 'Stop & Save Recording Now';

  // Downloads Screen
  String get mp3Downloads => isArabic ? 'تسجيلات MP3' : 'MP3 Downloads';
  String get savedInStorage => isArabic ? 'الملفات المحفوظة في ذاكرة الجهاز' : 'Saved recordings in device storage';
  String get noRecordingsYet => isArabic ? 'لا توجد تسجيلات MP3 بعد' : 'No MP3 Recordings Yet';
  String get recordGuidance => isArabic
      ? 'اضغط على زر التسجيل عند الاستماع لأي محطة لحفظ الصوت في مجلد التنزيلات بجهازك.'
      : 'Tap the record button on any radio channel to save live audio to your device downloads folder.';
  String get browseChannels => isArabic ? 'تصفح محطات الراديو' : 'Browse Radio Channels';

  // Favorites Screen
  String get favoriteStations => isArabic ? 'المحطات المفضلة' : 'Favorite Stations';
  String get playbackHistory => isArabic ? 'سجل الاستماع' : 'Playback History';
  String get noFavoritesYet => isArabic ? 'لا توجد محطات مفضلة بعد' : 'No Favorite Stations Yet';
  String get noFavoritesNote => isArabic
      ? 'اضغط على رمز القلب عند أي محطة لحفظها هنا والوصول إليها بلمسة واحدة.'
      : 'Tap the heart icon on any channel to bookmark it here for fast one-tap listening.';
  String get noHistoryYet => isArabic ? 'لا يوجد سجل استماع بعد' : 'No Listening History';
  String get noHistoryNote => isArabic
      ? 'المحطات التي تستمع إليها ستظهر تلقائياً هنا.'
      : 'Stations you listen to will automatically appear here.';
  String get filterFavoritesHint => isArabic ? 'ابحث في محطاتك المحفوظة...' : 'Filter your saved stations...';
  String get clear => isArabic ? 'مسح' : 'Clear';
  String get exploreStations => isArabic ? 'استكشف المحطات المباشرة' : 'Explore Live Stations';

  // Language Switch Button
  String get currentLangDisplay => isArabic ? 'English' : 'عربي';

  // Copyright
  String get developerCopyright =>
      isArabic ? 'حقوق النشر © 2025 للمطور العراقي فلاح كاطع صالح' : 'COPYRIGHT BY Iraqi Developer Falah.G.Salieh 2025 co.';

  // Side Menu & Drawer
  String get menuTitle => isArabic ? 'القائمة الرئيسية' : 'Main Menu';
  String get menuHomeMain => isArabic ? 'الرئيسية (Home Main)' : 'Home Main';
  String get menuHelpDocs => isArabic ? 'وثائق المساعدة والدليل' : 'Help Documentation';
  String get menuDevProfile => isArabic ? 'ملف المطور' : 'Developer Profile';
  String get quickToggles => isArabic ? 'التبديل السريع' : 'Quick Toggles';
  String get darkModeToggle => isArabic ? 'الوضع الداكن' : 'Dark Mode';
  String get darkModeSubtitle => isArabic ? 'المظهر الليلي عالي الأناقة' : 'Sleek Cyber Dark Palette';
  String get translateToggle => isArabic ? 'الترجمة (English / عربي)' : 'Translating (EN / AR)';
  String get translateSubtitle => isArabic ? 'تغيير لغة التطبيق الفوري' : 'Instant bilingual switch';

  // User Profile & Sign In / Sign Out
  String get userProfile => isArabic ? 'الملف الشخصي للمستخدم' : 'User Profile';
  String get guestUser => isArabic ? 'مستخدم زائر' : 'Guest User';
  String get signedInAs => isArabic ? 'مسجل الدخول باسم' : 'Signed in as';
  String get signIn => isArabic ? 'تسجيل الدخول' : 'Sign In';
  String get signOut => isArabic ? 'تسجيل الخروج' : 'Sign Out';
  String get enterYourName => isArabic ? 'أدخل اسمك الكريم' : 'Enter your name';
  String get nameHint => isArabic ? 'مثال: فلاح أو أحمد' : 'e.g. Falah or Alex';
  String get cancel => isArabic ? 'إلغاء' : 'Cancel';
  String get saveAndSignIn => isArabic ? 'حفظ وتسجيل الدخول' : 'Save & Sign In';
  String get pleaseEnterName => isArabic ? 'يرجى كتابة الاسم أولاً' : 'Please enter a name first';
  String get profileCachedLocally => isArabic ? 'البيانات محفوظة محلياً في ذاكرة الجهاز' : 'Profile data cached locally';
  String get confirmSignOut => isArabic ? 'هل تريد بالتأكيد تسجيل الخروج؟' : 'Are you sure you want to sign out?';
  String get memberSince => isArabic ? 'تاريخ التسجيل:' : 'Member since:';

  // Developer Profile
  String get developerTitle => isArabic ? 'المطور العراقي فلاح كاطع صالح' : 'Iraqi Developer Falah.G.Salieh';
  String get developerCompany => isArabic ? 'شركة فلاح كاطع صالح 2025' : 'Falah.G.Salieh 2025 Co.';
  String get leadEngineer => isArabic ? 'كبير مهندسي البرمجيات وتطبيقات الموبايل' : 'Lead Mobile & Software Systems Engineer';
  String get devBio => isArabic
      ? 'مهندس ومطور برمجيات عراقي شغوف بابتكار تطبيقات صوتية وتفاعلية فائقة السرعة وعالمية المستوى بتقنيات فلاتر الحديثة، داعمة للمجتمع العراقي والعربي والعالمي.'
      : 'Passionate Iraqi software engineer dedicated to building high-performance, world-class streaming applications using modern Flutter, delivering seamless digital experiences worldwide.';
  String get appVersion => isArabic ? 'الإصدار 1.0.0 (Release AAB)' : 'Version 1.0.0 (Release AAB)';
  String get builtWithLove => isArabic ? 'صُنع بكل فخر بواسطة مهندس عراقي 🇮🇶' : 'Built with pride by Iraqi Developer 🇮🇶';
  String get techStack => isArabic ? 'التقنيات المستخدمة' : 'Technology Stack';
  String get coreFramework => isArabic ? 'فلاتر 3 و دارت 3' : 'Flutter 3 & Dart 3';
  String get radioBrowserApi => isArabic ? 'واجهة Radio-Browser المفتوحة' : 'Radio-Browser Open API';
  String get contactDeveloper => isArabic ? 'تواصل مع المطور' : 'Contact Developer';
  String get shareApp => isArabic ? 'مشاركة التطبيق' : 'Share Application';

  // Help Documentation
  String get helpDocsTitle => isArabic ? 'دليل استخدام راديو تشانل' : 'Radio Channel User Guide';
  String get helpDocsSubtitle => isArabic ? 'كل ما تحتاج لمعرفته للاستمتاع بأكثر من 30,000 محطة' : 'Everything you need to enjoy 30,000+ stations';
  String get guideStationsSearch => isArabic ? 'البحث والتصفية الدقيقة' : 'Searching & Smart Filters';
  String get guideStationsSearchBody => isArabic
      ? 'يمكنك البحث الفوري عن أي محطة حسب اسمها، أو تصفيتها حسب الدولة (أكثر من 180 دولة)، أو لغة البث، أو نوع الموسيقى، أو صيغة الصوت (MP3, AAC, OGG) ومعدل البت (Bitrate).'
      : 'Search instantly for any channel by name, filter across 180+ nations, broadcast languages, music genres, audio codecs (MP3, AAC, OGG), or minimum bitrates.';
  String get guideRecording => isArabic ? 'تسجيل البث بصيغة MP3' : 'Live Stream MP3 Recording';
  String get guideRecordingBody => isArabic
      ? 'اضغط على زر التسجيل في شاشة المشغل، وحدد المدة المطلوبة (30 ثانية، 1 دقيقة، 3 دقائق، 5 دقائق، أو تسجيل يدوي مفتوح). يتم حفظ الملف فوراً في مجلد التنزيلات الحقيقي بجهازك (RadioRecordings).'
      : 'Tap the Record button on the player screen, pick your desired time (30s, 1m, 3m, 5m, or custom). Audio streams are recorded in real-time and saved directly into your device Downloads folder (RadioRecordings).';
  String get guideFavorites => isArabic ? 'المفضلة وسجل الاستماع' : 'Favorites & Playback History';
  String get guideFavoritesBody => isArabic
      ? 'اضغط على أيقونة القلب عند أي محطة لحفظها في قائمة مفضلاتك السريعة. كما يتم حفظ آخر المحطات التي تم تشغيلها تلقائياً في سجل الاستماع.'
      : 'Tap the heart icon on any channel card to store it in your Favorites for 1-tap tuning. Recently played stations automatically populate your history.';
  String get guideThemesAndLanguages => isArabic ? 'الوضع الداكن واللغات' : 'Dark Mode & Translating';
  String get guideThemesAndLanguagesBody => isArabic
      ? 'يمكنك التبديل بسهولة بين الوضع الليلي عالي التباين والوضع الفاتح الأنيق، والتبديل بنقرة واحدة بين اللغتين العربية (مع دعم كامل للاتجاه من اليمين لليسار RTL) والإنجليزية.'
      : 'Seamlessly toggle between the sleek cyber Dark Theme and clean Light Theme, and switch with a single tap between English and Arabic with complete RTL layout adaptation.';
}
