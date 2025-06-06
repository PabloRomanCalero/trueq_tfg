import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:trueq/screens/password_configuration/reset_password.dart';
import 'package:trueq/utils/constants/sizes.dart';
import 'package:trueq/utils/constants/supabase_constants.dart';
import 'package:trueq/utils/helper_functions.dart';

import '../../utils/constants/colors.dart';
import '../../utils/constants/text_strings.dart';
import '../../main.dart';

class ForgetPassword extends StatefulWidget {
  const ForgetPassword({super.key});

  @override
  State<ForgetPassword> createState() => _ForgetPasswordState();}

class _ForgetPasswordState extends State<ForgetPassword> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dark = HelperFunctions.isDarkMode(context);
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: EdgeInsets.all(SizesTrueq.defaultSpace.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              TextsTrueq.to.getText('forgetPasswordTitle'),
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: SizesTrueq.spaceBtwItems.h),
            Text(
              TextsTrueq.to.getText('forgetPasswordSubTitle'),
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: dark ? ColorsTrueq.lightGrey : ColorsTrueq.darkGrey),
            ),
            SizedBox(height: SizesTrueq.spaceBtwSections.h),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: TextsTrueq.to.getText('email'),
                      floatingLabelStyle: TextStyle(color: ColorsTrueq.primary),
                      prefixIcon: Icon(Icons.email_rounded, size: 24.sp),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(SizesTrueq.inputFieldRadius)),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(SizesTrueq.inputFieldRadius),
                        borderSide: BorderSide(
                          color: ColorsTrueq.primary,
                          width: 2.0.w,
                        ),
                      ),
                      contentPadding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 16.w),
                    ),
                    validator: (value) => value!.isEmpty || !value.contains('@') ? TextsTrueq.to.getText('validatorMailSignup') : null,
                  ),
                ]
              )
            ),

            const SizedBox(height: SizesTrueq.spaceBtwItems),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorsTrueq.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(SizesTrueq.inputFieldRadius)),
                ),
                onPressed: () async {
                  if(!_formKey.currentState!.validate()) return;
                  try{
                    final users = await supabaseAdmin.auth.admin.listUsers();
                    final user = users.firstWhereOrNull((user) => user.email == _emailController.text.toString());

                    if (user == null) {
                      Get.snackbar(TextsTrueq.to.getText('error'), TextsTrueq.to.getText('errorMailNotFound'), backgroundColor: Colors.red, colorText: Colors.white,);
                      return;
                    }
                    await supabase.auth.resetPasswordForEmail(
                      _emailController.text.toString(),
                      redirectTo: SupabaseTrueq.redirectPassword);
                    Get.snackbar(TextsTrueq.to.getText('verification'), TextsTrueq.to.getText('sendMailPassword'), backgroundColor: ColorsTrueq.primary, colorText: Colors.white);
                    Get.off(() => ResetPassword(email: _emailController.text.toString()));
                  } catch (e) {
                    Get.snackbar(TextsTrueq.to.getText('error'), TextsTrueq.to.getText('errorTryLater'), backgroundColor: Colors.red, colorText: Colors.white,);
                  }

                },
                child: Text(
                  TextsTrueq.to.getText('submit'),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: ColorsTrueq.light, fontWeight: FontWeight.bold
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
