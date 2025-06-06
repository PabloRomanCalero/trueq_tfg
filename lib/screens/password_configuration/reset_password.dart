import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:trueq/utils/constants/sizes.dart';
import 'package:trueq/utils/constants/supabase_constants.dart';
import 'package:trueq/utils/helper_functions.dart';

import '../../utils/constants/colors.dart';
import '../../utils/constants/image_strings.dart';
import '../../utils/constants/text_strings.dart';
import '../../main.dart';
import '../login/login.dart';

class ResetPassword extends StatelessWidget {
  const ResetPassword({super.key, required this.email});
  final String email;

  @override
  Widget build(BuildContext context) {
    final dark = HelperFunctions.isDarkMode(context);
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        actions: [IconButton(onPressed: () => Get.back(), icon: const Icon(Icons.close_rounded))],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(SizesTrueq.defaultSpace.r),
          child: Column(
            children: [
              Image(
                image: AssetImage(ImagesTrueq.verifyEmailImage,),
                width: MediaQuery.of(context).size.width * 0.6.w,
              ),
              Text(
                  TextsTrueq.to.getText('changePasswordTitle'),
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center
              ),
              SizedBox(height: SizesTrueq.spaceBtwItems.h),
              Text(
                TextsTrueq.to.getText('changePasswordSubTitle'),
                style: Theme.of(context).textTheme.labelMedium,
                textAlign: TextAlign.center
              ),
              SizedBox(height: SizesTrueq.spaceBtwSections.h),
              SizedBox(
                width: double.infinity,
                height: 50.r,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorsTrueq.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(SizesTrueq.inputFieldRadius)),
                  ),
                  onPressed: () => Get.back(),
                  child: Text(
                    TextsTrueq.to.getText('done'),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: ColorsTrueq.light, fontWeight: FontWeight.bold
                    ),
                  ),
                ),
              ),
              SizedBox(height: SizesTrueq.spaceBtwItems.h),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () async {
                    try {
                      await supabase.auth.resetPasswordForEmail(email, redirectTo: SupabaseTrueq.redirectPassword);
                      Get.snackbar(TextsTrueq.to.getText('verification'), TextsTrueq.to.getText('resendMailPassword'), backgroundColor: ColorsTrueq.primary, colorText: Colors.white);
                    }catch (e) {
                      Get.snackbar(TextsTrueq.to.getText('error'), TextsTrueq.to.getText('errorTryLater'), backgroundColor: Colors.red, colorText: Colors.white,);
                    }
                  },
                  child: Text(
                    TextsTrueq.to.getText('resendEmail'),
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: dark ? ColorsTrueq.light : ColorsTrueq.dark, fontWeight: FontWeight.normal
                    ),
                  )
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
