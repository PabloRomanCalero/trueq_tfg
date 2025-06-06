import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:trueq/screens/onboarding/widgets/onboarding_dot_navigation.dart';
import 'package:trueq/screens/onboarding/widgets/onboarding_next_button.dart';
import 'package:trueq/screens/onboarding/widgets/onboarding_page.dart';
import 'package:trueq/screens/onboarding/widgets/onboarding_skip.dart';
import 'package:trueq/utils/constants/image_strings.dart';
import 'package:trueq/utils/constants/text_strings.dart';

import '../login/login.dart';


class OnBoardingScreen extends StatelessWidget {
  const OnBoardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(OnBoardingController());

    return Scaffold(
      body: Stack(
        children: [
          PageView(
            controller: controller.pageController,
            onPageChanged: controller.updatePageIndicator,
            children: [
              OnBoardingPage(
                image: ImagesTrueq.onBoardingImage1,
                title: TextsTrueq.to.getText('titleOnBoarding1'),
                subTitle: TextsTrueq.to.getText('subtitleOnBoarding1'),
              ),
              OnBoardingPage(
                image: ImagesTrueq.onBoardingImage2,
                title: TextsTrueq.to.getText('titleOnBoarding2'),
                subTitle: TextsTrueq.to.getText('subtitleOnBoarding2'),
              ),
              OnBoardingPage(
                image: ImagesTrueq.onBoardingImage3,
                title: TextsTrueq.to.getText('titleOnBoarding3'),
                subTitle: TextsTrueq.to.getText('subtitleOnBoarding3'),
              )
            ],
          ),
          const OnBoardingSkip(),
          const OnBoardingDotNavigation(),
          const OnBoardingNextButton(),
        ],
      ),
    );
  }
}

class OnBoardingController extends GetxController{
  static OnBoardingController get instance => Get.find();

  final pageController = PageController();
  Rx<int> currentPageIndex = 0.obs;

  void updatePageIndicator(index) => currentPageIndex.value = index;

  void dotNavigationClick(index){
    currentPageIndex.value = index;
    pageController.jumpTo(index);
  }

  void nextPage(){
    if(currentPageIndex.value == 2){
      final storage = GetStorage();
      storage.write('isFirstTime', false);
      Get.offAll(const LoginScreen());
    } else{
      int page = currentPageIndex.value + 1;
      pageController.jumpToPage(page);
    }
  }

  void skipPage(){
    Get.offAll(const LoginScreen());
  }

}








