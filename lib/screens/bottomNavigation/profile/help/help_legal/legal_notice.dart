import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../utils/constants/colors.dart';
import '../../../../../utils/constants/sizes.dart';
import '../../../../../utils/constants/text_strings.dart';
import '../../../../../utils/helper_functions.dart';

class LegalNotice extends StatelessWidget {
  const LegalNotice({super.key});

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
                // Para detectar si está colapsado o expandido
                final bool isCollapsed = constraints.maxHeight <= kToolbarHeight + MediaQuery.of(context).padding.top;

                return FlexibleSpaceBar(
                  centerTitle: true,
                  titlePadding: EdgeInsets.only(
                    bottom: isCollapsed ? 16.0.h : 20.0.h,
                  ),
                  title: Text(
                    TextsTrueq.to.getText('legalNotice'),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: isCollapsed ? 22.0.sp : null, // Tamaño más pequeño cuando está colapsado
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
                  TextsTrueq.to.getText('lastUpdateLegal'),
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: dark ? ColorsTrueq.lightGrey : ColorsTrueq.darkGrey
                  ),
                ),
                SizedBox(height: SizesTrueq.spaceBtwSections.h),
                Text(
                  TextsTrueq.to.getText('legalIntro'),
                  style: TextStyle(
                    fontSize: 16.sp,
                  ),
                ),
                SizedBox(height: SizesTrueq.spaceBtwSections.h),
                Text(
                  TextsTrueq.to.getText('ownership'),
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: SizesTrueq.spaceBtwItems.h),
                Text(
                  TextsTrueq.to.getText('ownershipInfo'),
                  style: TextStyle(
                    fontSize: 16.sp,
                  ),
                ),
                SizedBox(height: SizesTrueq.spaceBtwSections.h),
                Text(
                  TextsTrueq.to.getText('responsibility'),
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: SizesTrueq.spaceBtwItems.h),
                Text(
                  TextsTrueq.to.getText('responsibilityInfo'),
                  style: TextStyle(
                    fontSize: 16.sp,
                  ),
                ),
                SizedBox(height: SizesTrueq.spaceBtwSections.h),
                Text(
                  TextsTrueq.to.getText('intellectualProperty'),
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: SizesTrueq.spaceBtwItems.h),
                Text(
                  TextsTrueq.to.getText('intellectualPropertyInfo'),
                  style: TextStyle(
                    fontSize: 16.sp,
                  ),
                ),
                SizedBox(height: SizesTrueq.spaceBtwSections.h),
                Text(
                  TextsTrueq.to.getText('applicableLaw'),
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: SizesTrueq.spaceBtwItems.h),
                Text(
                  TextsTrueq.to.getText('applicableLawInfo'),
                  style: TextStyle(
                    fontSize: 16.sp,
                  ),
                ),
                SizedBox(height: SizesTrueq.spaceBtwSections.h),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}
