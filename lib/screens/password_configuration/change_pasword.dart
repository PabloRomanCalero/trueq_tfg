import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:trueq/utils/constants/colors.dart';
import 'package:trueq/utils/constants/sizes.dart';
import 'package:trueq/utils/constants/text_strings.dart';
import 'package:trueq/utils/helper_functions.dart';

import '../login/login.dart';
import '../../main.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> resetPassword() async {
    if (!_formKey.currentState!.validate()) return;
    try {
      await supabase.auth.updateUser(
        UserAttributes(password: _passwordController.text),
      );

      Get.snackbar(TextsTrueq.to.getText('success'), TextsTrueq.to.getText('passwordChanged'), backgroundColor: ColorsTrueq.primary, colorText: Colors.white,);
      Get.offAll(() => const LoginScreen());
    } catch (e) {
      Get.snackbar(TextsTrueq.to.getText('error'), TextsTrueq.to.getText('errorTryLater'), backgroundColor: Colors.red, colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final dark = HelperFunctions.isDarkMode(context);
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        actions: [IconButton(onPressed: () => Get.offAll(const LoginScreen()), icon: const Icon(Icons.close_rounded))],
      ),
      body: Padding(
        padding: EdgeInsets.all(SizesTrueq.defaultSpace),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              TextsTrueq.to.getText('changeNewPasswordTitle'),
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: SizesTrueq.spaceBtwItems.h),
            Text(
              TextsTrueq.to.getText('changeNewPasswordSubTitle'),
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: dark ? ColorsTrueq.lightGrey : ColorsTrueq.darkGrey),
            ),
            SizedBox(height: SizesTrueq.spaceBtwSections.h),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _passwordController,
                    obscureText: !_isPasswordVisible,
                    decoration: InputDecoration(
                      labelText: TextsTrueq.to.getText('password'),
                      floatingLabelStyle: TextStyle(color: ColorsTrueq.primary),
                      prefixIcon: Icon(Icons.lock_rounded, size: 24.sp),
                      suffixIcon: IconButton(
                        icon: Icon(_isPasswordVisible ? Icons.visibility_off_rounded : Icons.visibility_rounded, size: 24.sp,),
                        onPressed: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                      ),
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
                    validator: (value) => value!.isEmpty ? TextsTrueq.to.getText('validatorPasswordLogin') : null,
                  ),
                ],
              ),
            ),
            const SizedBox(height: SizesTrueq.spaceBtwItems),
            SizedBox(
              width: double.infinity,
              height: 50.r,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorsTrueq.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(SizesTrueq.inputFieldRadius)
                  ),
                ),
                onPressed: resetPassword,
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
