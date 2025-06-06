import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:trueq/screens/login/login.dart';
import 'package:trueq/screens/onboarding/onboarding.dart';

import '../screens/bottomNavigation/navigation_menu.dart';

class AuthenticationRepository extends GetxController {
  static AuthenticationRepository get instance => Get.find();

  final deviceStorage = GetStorage();
  handleInitialRedirection() async {
    deviceStorage.writeIfNull('isFirstTime', true);

    if (deviceStorage.read('isFirstTime') == true) {
      Get.offAll(() => const OnBoardingScreen());
    } else {
      if(deviceStorage.read('remember') == true){
        Get.offAll(() => NavigationMenu());
      }
      else {
        Get.offAll(() => const LoginScreen());
      }

    }
  }
}
