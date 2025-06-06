import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:trueq/utils/constants/image_strings.dart';
import '../../utils/constants/colors.dart';
import '../../utils/constants/sizes.dart';
import '../../utils/constants/text_strings.dart';
import '../login/login.dart';
import '../../main.dart';

class SuccessScreen extends StatefulWidget {
  const SuccessScreen({super.key});

  @override
  State<SuccessScreen> createState() => _SuccessScreen();
}

Future<void> _createUserPreferences(String userId) async {
  final categories = ['Electrónica', 'Moda', 'Hogar', 'Deportes', 'Juguetes', 'Otros'];

  await Future.wait(categories.map((category) {
    return supabase.from('user_preferences').insert({
      'user_id': userId,
      'category': category,
      'like_count': 0,
      'view_count': 0,
      'last_interaction': DateTime.now().toIso8601String(),
    });
  }));
}

Future<User?> signInUser() async {
  try {
    final box = GetStorage();
    final email = box.read('user_email');
    final password = box.read('user_password');
    box.remove('user_email');
    box.remove('user_password');
    final response = await supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
    final user = response.user;

    final responseInsert = await supabase.from('users').insert({
      'id': user?.id,
      'first_name': user?.userMetadata?['first_name'],
      'last_name': user?.userMetadata?['last_name'],
      'phone_number': user?.userMetadata?['phone'],
      'username': user?.userMetadata?['username'],
      'avatar_url': ImagesTrueq.defaultAvatar
    });


    if (responseInsert != null) {
      Get.snackbar(TextsTrueq.to.getText('error'), TextsTrueq.to.getText('errorInsertUser'), backgroundColor: Colors.red, colorText: ColorsTrueq.light);
    } else {
      await _createUserPreferences(user!.id);
    }

    await supabase.auth.signOut();

  } catch (e) {
    return null;
  }
  return null;
}

class _SuccessScreen extends State<SuccessScreen> {
  @override
  void initState() {
    super.initState();
    signInUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(
            top: (56.0 * 2).h,
            bottom: (SizesTrueq.defaultSpace * 2).h,
            left: (SizesTrueq.defaultSpace * 2).w,
            right: (SizesTrueq.defaultSpace * 2).w,
          ),
          child: Column(
            children: [
              Image(
                image: AssetImage(ImagesTrueq.createdAccountImage),
                width: MediaQuery.of(context).size.width * 0.6.w,
              ),
              Text(
                TextsTrueq.to.getText('accountCreated'),
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center
              ),
              SizedBox(height: SizesTrueq.spaceBtwItems.h),
              Text(TextsTrueq.to.getText('accountCreatedSubTitle'), style: Theme.of(context).textTheme.labelMedium, textAlign: TextAlign.center,),
              SizedBox(height: SizesTrueq.spaceBtwSections.h),
              SizedBox(
                width: double.infinity,
                height: 50.h,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorsTrueq.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(SizesTrueq.inputFieldRadius)),
                  ),
                  onPressed: () => Get.to(()=> const LoginScreen()),
                  child: Text(
                    TextsTrueq.to.getText('continue'),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: ColorsTrueq.light, fontWeight: FontWeight.bold
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
