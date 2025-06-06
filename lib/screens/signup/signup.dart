import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:trueq/screens/login/widgets/form_divider.dart';
import 'package:trueq/screens/login/widgets/social_buttons.dart';
import 'package:trueq/screens/signup/widgets/signup_form.dart';
import 'package:trueq/utils/constants/sizes.dart';
import 'package:trueq/utils/constants/text_strings.dart';

class SignupScreen extends StatelessWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(SizesTrueq.defaultSpace.r),
          child: Column(
            children: [
              Text(
                TextsTrueq.to.getText('signupTitle'),
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: SizesTrueq.spaceBtwSections.h),
              SignupForm(),
              formDivider(dividerText: TextsTrueq.to.getText('orSignUpWith'),),
              SizedBox(height: SizesTrueq.spaceBtwItems.h),
              const SocialButtons(),
            ],
          ),
        ),
      ),
    );
  }
}

