import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:trueq/screens/bottomNavigation/profile/help/help_legal/cookies_policy.dart';
import 'package:trueq/screens/bottomNavigation/profile/help/help_legal/legal_notice.dart';
import 'package:trueq/screens/bottomNavigation/profile/help/help_legal/privacy_policy.dart';
import 'package:trueq/utils/constants/sizes.dart';
import 'package:trueq/utils/constants/text_strings.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../utils/constants/colors.dart';
import 'help_legal/terms_of_use.dart';

class HelpPage extends StatelessWidget {
  const HelpPage({super.key});

  void _openEmailApp() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'contacto.trueq@gmail.com',
      query:  _encodeQueryParameters(<String, String>{
        'subject': 'Consulta desde la App Trueq',
        'body': 'Hola equipo de soporte de Trueq,\n\nTengo la siguiente consulta:\n\n',
      }),
    );

    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    } else {
      Get.snackbar(TextsTrueq.to.getText('error'), TextsTrueq.to.getText('errorTryLater'), backgroundColor: Colors.red, colorText: ColorsTrueq.light);
    }
  }

  String? _encodeQueryParameters(Map<String, String> params) {
    return params.entries.map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}').join('&');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          TextsTrueq.to.getText('help'),
          style: TextStyle(
            fontSize: 22.sp,
            fontWeight: FontWeight.bold
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(padding: EdgeInsets.only(top: SizesTrueq.defaultSpace.h, left: SizesTrueq.defaultSpace.w, right: SizesTrueq.defaultSpace.w),
            child: Text(
              TextsTrueq.to.getText('legal'),
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
          _buildListTile(Icons.article_rounded, TextsTrueq.to.getText('legalNotice'), (){
            Get.to(() => LegalNotice());
          }),
          _buildListTile(Icons.privacy_tip_rounded, TextsTrueq.to.getText('privacyPolicy'), (){
            Get.to(() => PrivacyPolicy());
          }),
          _buildListTile(Icons.cookie_rounded, TextsTrueq.to.getText('privacyCookies'), (){
            Get.to(() => CookiesPolicy());
          }),
          _buildListTile(Icons.gavel_rounded, TextsTrueq.to.getText('termsOfUse'), (){
            Get.to(() => TermsOfUse());
          }),
          Padding(padding: EdgeInsets.only(top: SizesTrueq.defaultSpace.h, left: SizesTrueq.defaultSpace.w, right: SizesTrueq.defaultSpace.w),
            child: Text(
              TextsTrueq.to.getText('contact'),
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
          _buildListTile(Icons.email_rounded, TextsTrueq.to.getText('supportEmail'), (){
            _openEmailApp();
          }),
        ],
      ),
    );
  }



  Widget _buildListTile(IconData icon, String title, VoidCallback onTap, [bool hideIcon = false]) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: SizesTrueq.defaultSpace.w),
      leading: Icon(icon, color: ColorsTrueq.primary),
      title: Text(
        title,
        style: TextStyle(fontSize: 15.sp),
      ),
      trailing: hideIcon ? null : Icon(Icons.chevron_right_rounded, color: ColorsTrueq.darkGrey, size: 24.sp,),
      onTap: onTap,
    );
  }
}
