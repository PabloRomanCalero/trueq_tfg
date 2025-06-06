import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:trueq/screens/onboarding/onboarding.dart';

import '../../../utils/constants/sizes.dart';
import '../../../utils/constants/text_strings.dart';


class OnBoardingSkip extends StatelessWidget {
  const OnBoardingSkip({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
        top: kToolbarHeight.h,
        right: SizesTrueq.defaultSpace.w,
        child: TextButton(
            onPressed: () => OnBoardingController.instance.skipPage(),
            child: Text(TextsTrueq.to.getText('skip'))
        )
    );
  }
}