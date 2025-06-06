import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../utils/constants/colors.dart';
import '../../../utils/constants/image_strings.dart';
import '../../../utils/constants/sizes.dart';
import '../../../utils/constants/text_strings.dart';
import '../../../utils/helper_functions.dart';

class loginHeader extends StatelessWidget {
  const loginHeader({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final dark = HelperFunctions.isDarkMode(context);
    return Column(
      children: [
        Center(
          child: ClipOval(
              child: Image(
                image: AssetImage(
                  ImagesTrueq.logo
                ),
                height: 120.h,
                width: 120.w,
                fit: BoxFit.cover,
              )
          ),
        ),
        SizedBox(height: SizesTrueq.spaceBtwSections.h),
        Text(
          TextsTrueq.to.getText('loginTitle'),
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        SizedBox(height: SizesTrueq.spaceBtwItems.h),
        Text(
          TextsTrueq.to.getText('loginSubtitle'),
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: dark ? ColorsTrueq.lightGrey : ColorsTrueq.darkGrey),
        ),
        SizedBox(height: SizesTrueq.spaceBtwSections.h),
      ],
    );
  }
}
