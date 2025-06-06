import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../utils/constants/sizes.dart';

class OnBoardingPage extends StatelessWidget {
  const OnBoardingPage({
    super.key, required this.image, required this.title, required this.subTitle,
  });

  final String image, title, subTitle;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(SizesTrueq.defaultSpace.r),
      child: Column(
        children: [
          SizedBox(height: SizesTrueq.spaceBtwItems2.h),
          Image(
            width: MediaQuery.of(context).size.width * 0.9,
            height: MediaQuery.of(context).size.width * 0.7,
            image: AssetImage(image)
          ),
          SizedBox(height: SizesTrueq.spaceBtwItems2.r),
          Text(
            title,
            style: Theme.of(context).textTheme.headlineMedium,
            textAlign: TextAlign.center
          ),
          SizedBox(height: SizesTrueq.spaceBtwItems.r),
          Text(
            subTitle,
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center
          ),
        ],
      ),
    );
  }
}