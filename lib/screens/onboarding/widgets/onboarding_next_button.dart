import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:trueq/screens/onboarding/onboarding.dart';
import 'package:trueq/utils/constants/colors.dart';

import '../../../utils/constants/sizes.dart';
import '../../../utils/helper_functions.dart';


class OnBoardingNextButton extends StatelessWidget {
  const OnBoardingNextButton({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = HelperFunctions.isDarkMode(context);

    return Positioned(
      right: SizesTrueq.defaultSpace.w,
      bottom: kBottomNavigationBarHeight.h,
      child: ElevatedButton(
        onPressed: () => OnBoardingController.instance.nextPage(),
        style: ElevatedButton.styleFrom(
          shape: const CircleBorder(),
          backgroundColor: dark ? Colors.white54 : Colors.black87,
          padding: EdgeInsets.all(15.r),
        ),
        child: Icon(
          Icons.keyboard_arrow_right_rounded,
          color: dark ? ColorsTrueq.dark : ColorsTrueq.light,
          size: 32.sp,
        ),
      ),
    );
  }
}

