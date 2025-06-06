import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:trueq/screens/password_configuration/forget_password.dart';
import 'package:trueq/screens/signup/signup.dart';

import '../../../utils/constants/colors.dart';
import '../../../utils/constants/sizes.dart';
import '../../../utils/constants/text_strings.dart';
import '../../../utils/helper_functions.dart';
import '../../bottomNavigation/navigation_menu.dart';
import '../../../main.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  bool rememberMe = false;
  bool _isPasswordVisible = false;
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<AuthResponse?> signInUser(String email, String password) async {
    try {
      final response = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      if (rememberMe) {
        final storage = GetStorage();
        storage.write('remember', rememberMe);
      }
      return response;
    } catch (e) {
      return null;
    }
  }

  Future<void> _successLoginNotifications() async {
    OneSignal.Notifications.requestPermission(true);
    final pushSubscription = OneSignal.User.pushSubscription;
    final playerId = pushSubscription.id;
    await supabase.from('users').update({
      'player_id': playerId
    }).eq('id', supabase.auth.currentUser!.id);
  }

  @override
  Widget build(BuildContext context) {
    final dark = HelperFunctions.isDarkMode(context);
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _emailController,
            decoration: InputDecoration(
              labelText: TextsTrueq.to.getText('email'),
              floatingLabelStyle: TextStyle(color: ColorsTrueq.primary),
              prefixIcon: Icon(Icons.email_rounded, size: 24.sp),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(SizesTrueq.inputFieldRadius),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(SizesTrueq.inputFieldRadius),
                borderSide: BorderSide(
                  color: ColorsTrueq.primary,
                  width: 2.0.w,
                ),
              ),
              contentPadding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 16.w),
            ),
            validator: (value) => value!.isEmpty ? TextsTrueq.to.getText('validatorMailLogin') : null,
          ),
          SizedBox(height: SizesTrueq.spaceBtwInputFields.h),
          TextFormField(
            controller: _passwordController,
            obscureText: !_isPasswordVisible,
            decoration: InputDecoration(
              labelText: TextsTrueq.to.getText('password'),
              floatingLabelStyle: TextStyle(color: ColorsTrueq.primary),
              prefixIcon: Icon(Icons.lock_rounded, size: 24.sp,),
              suffixIcon: IconButton(
                icon: Icon(_isPasswordVisible ? Icons.visibility_off_rounded : Icons.visibility_rounded, size: 24.sp),
                onPressed: () {
                  setState(() {
                    _isPasswordVisible = !_isPasswordVisible;
                  });
                },
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(SizesTrueq.inputFieldRadius),
              ),
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
          SizedBox(height: (SizesTrueq.spaceBtwInputFields / 2).h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Checkbox(
                    value: rememberMe,
                    onChanged: (value) {
                      setState(() => rememberMe = value!);
                    },
                    activeColor: ColorsTrueq.primary,
                  ),
                  Text(
                    TextsTrueq.to.getText('remember'),
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: dark ? ColorsTrueq.lightGrey : Colors.black87,
                    ),
                  ),
                ],
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Get.to(() => const ForgetPassword()),
                  child: Text(TextsTrueq.to.getText('forgotPassword')),
                ),
              ),
            ],
          ),
          SizedBox(height: SizesTrueq.spaceBtwSections.h),
          SizedBox(
            width: double.infinity,
            height: 50.h,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorsTrueq.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(SizesTrueq.inputFieldRadius),
                ),
              ),
              onPressed: () async {
                final response = await signInUser(
                  _emailController.text.trim(),
                  _passwordController.text.trim(),
                );
                if (response != null && response.user != null) {
                  _successLoginNotifications();
                  Get.offAll(() => const NavigationMenu());
                } else {
                  Get.snackbar(
                    TextsTrueq.to.getText('error'),
                    TextsTrueq.to.getText('errorLogin'),
                    backgroundColor: Colors.red,
                    colorText: ColorsTrueq.light,
                  );
                }
              },
              child: Text(
                TextsTrueq.to.getText('loginButton'),
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: ColorsTrueq.light,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          SizedBox(height: SizesTrueq.spaceBtwItems.h),
          SizedBox(
            width: double.infinity,
            height: 50.h,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                  color: dark ? ColorsTrueq.lightGrey : ColorsTrueq.darkGrey,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(SizesTrueq.inputFieldRadius),
                ),
              ),
              onPressed: () => Get.to(() => const SignupScreen()),
              child: Text(
                TextsTrueq.to.getText('registerNow'),
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: dark ? ColorsTrueq.light : ColorsTrueq.dark,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          SizedBox(height: SizesTrueq.spaceBtwSections.h),
        ],
      ),
    );
  }
}
