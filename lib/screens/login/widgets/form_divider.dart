import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:trueq/utils/helper_functions.dart';

import '../../../utils/constants/colors.dart';

class formDivider extends StatelessWidget {
  const formDivider({
    super.key,
    required this.dividerText,
  });

  final String dividerText;

  @override
  Widget build(BuildContext context) {
    final dark = HelperFunctions.isDarkMode(context);
    return Row(
      children: [
        Expanded(child: Divider(color: dark ? ColorsTrueq.lightGrey : ColorsTrueq.darkGrey)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 10.0.w),
          child: Text(dividerText, style: Theme.of(context).textTheme.bodyMedium!.apply(
          color: dark ? ColorsTrueq.light : ColorsTrueq.darkGrey )),
        ),
        Expanded(child: Divider(color: dark ? ColorsTrueq.lightGrey : ColorsTrueq.darkGrey)),
      ],
    );
  }
}