import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:trueq/utils/constants/image_strings.dart';
import 'package:trueq/utils/constants/sizes.dart';
import 'package:trueq/utils/constants/supabase_constants.dart';
import 'package:trueq/utils/constants/text_strings.dart';
import '../../utils/constants/colors.dart';
import '../../utils/helper_functions.dart';
import '../login/login.dart';
import '../../main.dart';

class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({super.key, required this.email, required this.password});
  final String email, password;

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

Future<User?> signInUser(String email, String password) async {
  try {
    final response = await supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
    final user = response.user;
    return user;
  } catch (e) {
    return null;
  }
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {

  @override
  Widget build(BuildContext context) {
    final dark = HelperFunctions.isDarkMode(context);
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () => Get.offAll(() => const LoginScreen()),
            icon: const Icon(Icons.clear_rounded),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(SizesTrueq.defaultSpace.r),
          child: Column(
            children: [
              Image(
                image: AssetImage(ImagesTrueq.verifyEmailImage),
                width: MediaQuery.of(context).size.width * 0.6.w,
              ),
              SizedBox(height: SizesTrueq.spaceBtwSections.h),
              Text(
                TextsTrueq.to.getText('confirmEmail'),
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: SizesTrueq.spaceBtwItems.h),
              Text(
                widget.email,
                style: Theme.of(context).textTheme.labelLarge,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: SizesTrueq.spaceBtwItems.h),
              Text(
                TextsTrueq.to.getText('confirmSubTitle'),
                style: Theme.of(context).textTheme.labelMedium,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: SizesTrueq.spaceBtwSections.h),
              SizedBox(
                width: double.infinity,
                height: 50.h,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorsTrueq.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(SizesTrueq.inputFieldRadius)),
                  ),
                  onPressed: () async {
                    try {
                      final User? user = await signInUser(widget.email, widget.password);
                      if(user == null) {
                        Get.snackbar(TextsTrueq.to.getText('error'), TextsTrueq.to.getText('errorNotConfirmedMail'), backgroundColor: Colors.red, colorText: ColorsTrueq.light);
                      }
                    } catch (e) {
                      Get.snackbar(TextsTrueq.to.getText('error'), TextsTrueq.to.getText('errorNotConfirmedMail2'), backgroundColor: Colors.red, colorText: Colors.white);
                    }
                  },
                  child: Text(
                    TextsTrueq.to.getText('continue'),
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
                    try{
                      await supabase.auth.resend(type: OtpType.signup, email: widget.email, emailRedirectTo: SupabaseTrueq.redirectMailConfirm);
                      Get.snackbar(TextsTrueq.to.getText('verification'), TextsTrueq.to.getText('resendMailVerification'), backgroundColor: ColorsTrueq.primary, colorText: Colors.white);
                    }catch (e) {
                      Get.snackbar(TextsTrueq.to.getText('error'), TextsTrueq.to.getText('errorTryLater'), backgroundColor: Colors.red, colorText: Colors.white);
                    }
                  },
                  child: Text(
                    TextsTrueq.to.getText('resendEmail'),
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: dark ? ColorsTrueq.light : ColorsTrueq.dark, fontWeight: FontWeight.normal
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
