import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../../utils/constants/colors.dart';
import '../../../../../utils/constants/sizes.dart';
import '../../../../../utils/constants/text_strings.dart';
import '../../../../../utils/helper_functions.dart';

class PrivacyPolicy extends StatelessWidget {
  const PrivacyPolicy({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = HelperFunctions.isDarkMode(context);
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 36.h,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            flexibleSpace: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                final bool isCollapsed = constraints.maxHeight <= kToolbarHeight + MediaQuery.of(context).padding.top;

                return FlexibleSpaceBar(
                  centerTitle: true,
                  titlePadding: EdgeInsets.only(
                    left: isCollapsed ? 16.0.w : SizesTrueq.defaultSpace.w,
                    bottom: isCollapsed ? 16.0.w : 20.0.w,
                  ),
                  title: Text(
                    TextsTrueq.to.getText('privacyPolicy'),
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: isCollapsed ? 22.0.sp : null,
                    ),
                  ),
                  background: Container(
                    color: Theme.of(context).scaffoldBackgroundColor,
                  ),
                );
              },
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.all(SizesTrueq.defaultSpace.r),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Text(
                  TextsTrueq.to.getText('lastUpdatePrivacy'),
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: dark ? ColorsTrueq.lightGrey : ColorsTrueq.darkGrey,
                  ),
                ),
                SizedBox(height: SizesTrueq.spaceBtwSections),
                Text(
                  TextsTrueq.to.getText('privacyPolicyIntro'),
                  style: TextStyle(fontSize: 16.sp),
                ),
                SizedBox(height: SizesTrueq.spaceBtwSections.h),
                Text(
                  TextsTrueq.to.getText('dataRecopilation'),
                  style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: SizesTrueq.spaceBtwItems.h),
                Text(
                  TextsTrueq.to.getText('dataRecopilationInfo'),
                  style: TextStyle(fontSize: 16.sp),
                ),
                SizedBox(height: SizesTrueq.spaceBtwSections.h),
                Text(
                  TextsTrueq.to.getText('dataUsage'),
                  style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: SizesTrueq.spaceBtwItems.h),
                Text(
                  TextsTrueq.to.getText('dataUsageInfo'),
                  style: TextStyle(fontSize: 16.sp),
                ),
                SizedBox(height: SizesTrueq.spaceBtwSections.h),
                Text(
                  TextsTrueq.to.getText('cookieTechnologies'),
                  style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: SizesTrueq.spaceBtwItems.h),
                Text(
                  TextsTrueq.to.getText('cookieTechnologiesInfo'),
                  style: TextStyle(fontSize: 16.sp),
                ),
                GestureDetector(
                  onTap: () async {
                    final url = Uri.parse(TextsTrueq.to.getText('privacyPolicyGoogle'));
                    if (await canLaunchUrl(url)) {
                      await launchUrl(url, mode: LaunchMode.externalApplication);
                    }
                  },
                  child: Text(
                    TextsTrueq.to.getText('privacyPolicyGoogle'),
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: dark ? ColorsTrueq.lightGrey : ColorsTrueq.primary,
                      decoration: TextDecoration.underline,
                      decorationColor: dark ? ColorsTrueq.lightGrey : ColorsTrueq.primary,
                    ),
                  ),
                ),
                SizedBox(height: SizesTrueq.spaceBtwSections.h),
                Text(
                  TextsTrueq.to.getText('contact'),
                  style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: SizesTrueq.spaceBtwItems.h),
                Text(
                  TextsTrueq.to.getText('contactPolicyInfo'),
                  style: TextStyle(fontSize: 16.sp),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}
