import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:trueq/screens/bottomNavigation/profile/help/help_legal/terms_of_use.dart';
import 'package:trueq/utils/helper_functions.dart';

import '../../../utils/constants/colors.dart';
import '../../../utils/constants/sizes.dart';
import '../../../utils/constants/text_strings.dart';
import '../../bottomNavigation/profile/help/help_legal/privacy_policy.dart';

class TermsAndConditionsCheckbox extends StatelessWidget {
  const TermsAndConditionsCheckbox({super.key, required this.value, required this.onChanged});
  final bool value;
  final ValueChanged onChanged;

  @override
  Widget build(BuildContext context) {
    final dark = HelperFunctions.isDarkMode(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 24.w,
          height: 24.h,
          child: Checkbox(
            value: value,
            onChanged: onChanged,
            activeColor: ColorsTrueq.primary,
          ),
        ),
        SizedBox(width: SizesTrueq.spaceBtwItems.w),
        Flexible(
          child: Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                '${TextsTrueq.to.getText('iAgreeTo')} ',
                style: Theme.of(context).textTheme.bodyMedium!.apply(
                  color: dark ? ColorsTrueq.lightGrey : ColorsTrueq.dark,
                ),
              ),
              GestureDetector(
                onTap: () => Get.to(() => PrivacyPolicy()),
                child: Text(
                  TextsTrueq.to.getText('privacyPolicy'),
                  style: TextStyle(
                    color: dark ? ColorsTrueq.lightGrey : ColorsTrueq.primary,
                    decoration: TextDecoration.underline,
                    decorationColor: dark ? ColorsTrueq.lightGrey : ColorsTrueq.primary,
                  ),
                ),
              ),
              Text(
                ' ${TextsTrueq.to.getText('and')} ',
                style: Theme.of(context).textTheme.bodyMedium!.apply(
                  color: dark ? ColorsTrueq.lightGrey : ColorsTrueq.dark,
                ),
              ),
              GestureDetector(
                onTap: () => Get.to(() => TermsOfUse()),
                child: Text(
                  TextsTrueq.to.getText('termsOfUse'),
                  style: TextStyle(
                    color: dark ? ColorsTrueq.lightGrey : ColorsTrueq.primary,
                    decoration: TextDecoration.underline,
                    decorationColor: dark ? ColorsTrueq.lightGrey : ColorsTrueq.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
