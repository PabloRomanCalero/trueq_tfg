import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:trueq/screens/signup/widgets/terms_conditions_checkbox.dart';
import 'package:trueq/utils/constants/supabase_constants.dart';
import '../../../utils/constants/colors.dart';
import '../../../utils/constants/sizes.dart';
import '../../../utils/constants/text_strings.dart';
import '../../../main.dart';
import '../verify_email.dart';

class SignupForm extends StatefulWidget {
  const SignupForm({super.key});

  @override
  State<SignupForm> createState() => _SignupFormState();
}

class _SignupFormState extends State<SignupForm> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool termsAccepted = false;
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<bool> checkAndDeleteUser(String email) async {
    try {
      final users = await supabaseAdmin.auth.admin.listUsers();
      final user = users.firstWhereOrNull((user) => user.email == email);

      if(user == null){
        return true;
      }

      if (user.emailConfirmedAt != null) {
        Get.snackbar(TextsTrueq.to.getText('error'), TextsTrueq.to.getText('errorMailInUse'), backgroundColor: Colors.red, colorText: ColorsTrueq.light);
        return false;
      }
      await supabaseAdmin.auth.admin.deleteUser(user.id);
      return true;
    } catch (e) {
      Get.snackbar(TextsTrueq.to.getText('error'), TextsTrueq.to.getText('errorTryLater'), backgroundColor: Colors.red, colorText: ColorsTrueq.light);
      return false;
    }
  }

  Future<void> signUpUser() async {
    if (!_formKey.currentState!.validate()) return;
    if (!termsAccepted) {
      Get.snackbar(TextsTrueq.to.getText('error'), TextsTrueq.to.getText('errorTermsAndConditions'), backgroundColor: Colors.red, colorText: ColorsTrueq.light);
      return;
    }
    bool createUser = await checkAndDeleteUser(_emailController.text.toString());
    if(!createUser){return;}
    try {
      final response = await supabase.auth.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        data: {
          'first_name': _firstNameController.text.trim(),
          'last_name': _lastNameController.text.trim(),
          'phone': _phoneController.text.trim(),
          'username': _usernameController.text.trim(),
        },
        emailRedirectTo: SupabaseTrueq.redirectMailConfirm
      );
      if (response.user != null) {
        final box = GetStorage();
        box.write('user_email', _emailController.text.trim());
        box.write('user_password', _passwordController.text.trim());

        Get.to(() => VerifyEmailScreen(email: _emailController.text.trim(), password: _passwordController.text.trim(),));
        Get.snackbar(TextsTrueq.to.getText('verification'), TextsTrueq.to.getText('sendMailVerification'), backgroundColor: ColorsTrueq.primary, colorText: ColorsTrueq.light);
      }
    } catch (e) {
      Get.snackbar(TextsTrueq.to.getText('error'), TextsTrueq.to.getText('errorTryLater'), backgroundColor: Colors.red, colorText: ColorsTrueq.light,);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _firstNameController,
                  decoration: InputDecoration(
                    labelText: TextsTrueq.to.getText('firstName'),
                    floatingLabelStyle: TextStyle(color: ColorsTrueq.primary),
                    prefixIcon: Icon(Icons.person_rounded, size: 24.sp),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(SizesTrueq.inputFieldRadius)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(SizesTrueq.inputFieldRadius),
                      borderSide: BorderSide(
                        color: ColorsTrueq.primary,
                        width: 2.0.w,
                      ),
                    ),
                  ),
                  validator: (value) => value!.isEmpty ? TextsTrueq.to.getText('validatorFirstName') : null,
                ),
              ),
              SizedBox(width: SizesTrueq.spaceBtwInputFields.w),
              Expanded(
                child: TextFormField(
                  controller: _lastNameController,
                  decoration: InputDecoration(
                    labelText: TextsTrueq.to.getText('lastName'),
                    floatingLabelStyle: TextStyle(color: ColorsTrueq.primary),
                    prefixIcon: Icon(Icons.person_rounded, size: 24.sp),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(SizesTrueq.inputFieldRadius)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(SizesTrueq.inputFieldRadius),
                      borderSide: BorderSide(
                        color: ColorsTrueq.primary,
                        width: 2.0.w,
                      ),
                    ),
                  ),
                  validator: (value) => value!.isEmpty ? TextsTrueq.to.getText('validatorLastName') : null,
                ),
              ),
            ],
          ),
          SizedBox(height: SizesTrueq.spaceBtwInputFields.h),
          TextFormField(
            controller: _phoneController,
            decoration: InputDecoration(
              labelText: TextsTrueq.to.getText('phoneNumber'),
              floatingLabelStyle: TextStyle(color: ColorsTrueq.primary),
              prefixIcon: Icon(Icons.phone_rounded, size: 24.sp),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(SizesTrueq.inputFieldRadius)),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(SizesTrueq.inputFieldRadius),
                borderSide: BorderSide(
                  color: ColorsTrueq.primary,
                  width: 2.0.w,
                ),
              ),
            ),
            keyboardType: TextInputType.phone,
          ),
          SizedBox(height: SizesTrueq.spaceBtwInputFields.h),
          TextFormField(
            controller: _emailController,
            decoration: InputDecoration(
              labelText: TextsTrueq.to.getText('emailForm'),
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
            ),
            keyboardType: TextInputType.emailAddress,
            validator: (value) => value!.isEmpty || !value.contains('@') ? TextsTrueq.to.getText('validatorMailSignup') : null,
          ),
          SizedBox(height: SizesTrueq.spaceBtwInputFields.h),
          TextFormField(
            controller: _usernameController,
            decoration: InputDecoration(
              labelText: TextsTrueq.to.getText('username'),
              floatingLabelStyle: TextStyle(color: ColorsTrueq.primary),
              prefixIcon: Icon(Icons.account_circle_rounded, size: 24.sp),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(SizesTrueq.inputFieldRadius)),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(SizesTrueq.inputFieldRadius),
                borderSide: BorderSide(
                  color: ColorsTrueq.primary,
                  width: 2.0.w,
                ),
              ),
            ),
            validator: (value) => value!.isEmpty ? TextsTrueq.to.getText('validatorUsername') : null,
          ),
          SizedBox(height: SizesTrueq.spaceBtwInputFields.h),
          TextFormField(
            controller: _passwordController,
            decoration: InputDecoration(
              labelText: TextsTrueq.to.getText('passwordForm'),
              floatingLabelStyle: TextStyle(color: ColorsTrueq.primary),
              prefixIcon: Icon(Icons.lock_rounded, size: 24.sp),
              suffixIcon: IconButton(
                icon: Icon(_isPasswordVisible ? Icons.visibility_off_rounded : Icons.visibility_rounded, size: 24.sp),
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
            ),
            obscureText: !_isPasswordVisible,
            validator: (value) => value!.length < 6 ? TextsTrueq.to.getText('validatorPasswordSignup') : null,
          ),
          SizedBox(height: SizesTrueq.spaceBtwSections.h),
          TermsAndConditionsCheckbox(
            value: termsAccepted,
            onChanged: (value) => setState(() => termsAccepted = value),
          ),
          SizedBox(height: SizesTrueq.defaultSpace.h),
          SizedBox(
            width: double.infinity,
            height: 50.h,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorsTrueq.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(SizesTrueq.inputFieldRadius)),
              ),
              onPressed: signUpUser,
              child: Text(
                TextsTrueq.to.getText('registerNow'),
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: ColorsTrueq.light, fontWeight: FontWeight.bold
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
