import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:trueq/screens/password_configuration/change_pasword.dart';
import 'package:trueq/splash_screen.dart';
import 'package:trueq/utils/constants/supabase_constants.dart';
import 'package:trueq/utils/themes.dart';
import 'package:trueq/utils/constants/text_strings.dart';

import 'data/authentication_repository.dart';
import 'screens/signup/success_screen.dart';


final supabaseAdmin = SupabaseClient(SupabaseTrueq.url, SupabaseTrueq.service_role);
final supabase = Supabase.instance.client;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await MobileAds.instance.initialize();
  Get.put(TextsTrueq());
  await GetStorage.init();
  await Supabase.initialize(
    url: SupabaseTrueq.url,
    anonKey: SupabaseTrueq.anonKey,
  );
  OneSignal.initialize('68df6e32-d8f2-4c69-8859-0a1ed1571559');
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown
  ]);
  Get.put(AuthenticationRepository());
  runApp(const MyApp());
  Future.delayed(Duration.zero, () {
    AuthenticationRepository.instance.handleInitialRedirection();
  });
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    _handleDeepLinks(context);
    _initializeLanguage();
  }

  void _handleDeepLinks(BuildContext context) async {
    final appLinks = AppLinks();

    appLinks.uriLinkStream.listen((uri){
      if(uri.host == SupabaseTrueq.passwordHost) {
        Get.off(() => ChangePasswordScreen());
      } else if(uri.host == SupabaseTrueq.mailConfirmHost){
        Get.to(() => SuccessScreen());
      }
    });
  }

  void _initializeLanguage() async {
    var storedLanguage = GetStorage().read('language') ?? 'es';
    TextsTrueq.to.changeLanguage(storedLanguage);
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return GetMaterialApp(
          locale: Get.locale ?? Get.deviceLocale,
          translations: MyTranslations(),
          debugShowCheckedModeBanner: false,
          theme: CustomTheme(false),
          darkTheme: CustomTheme(true),
          builder: (context, child) {
            return MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaler: TextScaler.linear(1.0),
              ),
              child: child!,
            );
          },
          home: child,
        );
      },
      child: const SplashScreen(),
    );

  }


}

class MyTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
    'es': TextsTrueq.to.translations['es'] ?? {},
    'en': TextsTrueq.to.translations['en'] ?? {},
  };
}
