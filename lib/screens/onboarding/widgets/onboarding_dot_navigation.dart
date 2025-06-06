import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:trueq/screens/onboarding/onboarding.dart';

import '../../../utils/constants/sizes.dart';
import '../../../utils/helper_functions.dart';



class OnBoardingDotNavigation extends StatelessWidget {
  const OnBoardingDotNavigation({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final controller = OnBoardingController.instance;
    final dark = HelperFunctions.isDarkMode(context);

    return Positioned(
      left: SizesTrueq.defaultSpace.w,
      bottom: kBottomNavigationBarHeight.h + 25.h,
      child: SmoothPageIndicator(
        controller: controller.pageController,
        onDotClicked: controller.dotNavigationClick,
        count: 3,
        effect: ExpandingDotsEffect(activeDotColor: dark ? Colors.white54 : Colors.black87, dotHeight: 6.h),
      ),
    );
  }
}