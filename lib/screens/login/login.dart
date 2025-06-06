import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:trueq/screens/login/widgets/form_divider.dart';
import 'package:trueq/screens/login/widgets/login_header.dart';
import 'package:trueq/screens/login/widgets/social_buttons.dart';
import 'package:trueq/utils/constants/sizes.dart';
import 'package:trueq/utils/constants/text_strings.dart';
import 'package:trueq/screens/login/widgets/login_form.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(
            top: 56.0.h,
            bottom: SizesTrueq.defaultSpace.h,
            left: SizesTrueq.defaultSpace.w,
            right: SizesTrueq.defaultSpace.w,
          ),
          child: Column(
            children: [
              loginHeader(),
              LoginForm(),
              formDivider(dividerText: TextsTrueq.to.getText('orContinueWith')),
              SizedBox(height: SizesTrueq.spaceBtwItems.h),
              SocialButtons(),
            ],
          ),
        ),
      ),
    );
  }
}





