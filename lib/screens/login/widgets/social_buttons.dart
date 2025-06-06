import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:trueq/utils/constants/image_strings.dart';
import '../../../utils/constants/colors.dart';
import '../../../utils/constants/sizes.dart';
import '../../bottomNavigation/navigation_menu.dart';
import '../../../main.dart';

class SocialButtons extends StatefulWidget {
  const SocialButtons({super.key});

  @override
  State<SocialButtons> createState() => _SocialButtonsState();
}

class _SocialButtonsState extends State<SocialButtons> {
  String? _userId;

  @override
  void initState() {
    super.initState();
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

  Future<void> _signInWithGoogle() async {
    const webClientId = '374383638060-pbmmhs29ibfq5o6bve87as9tuhrj84k6.apps.googleusercontent.com';
    const iosClientId = '374383638060-grq1cobqh0me18mvj2bfqe4qkqgrrsol.apps.googleusercontent.com';

    final GoogleSignIn googleSignIn = GoogleSignIn(
      clientId: iosClientId,
      serverClientId: webClientId
    );
    await googleSignIn.signOut();
    final googleUser = await googleSignIn.signIn();
    if(googleUser == null){return;}
    final googleAuth = await googleUser.authentication;

    final accessToken = googleAuth.accessToken;
    final idToken = googleAuth.idToken;
    if (accessToken == null) {
      throw 'No Access Token found.';
    }
    if (idToken == null) {
      throw 'No ID Token found.';
    }
    final response = await supabase.auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: idToken,
      accessToken: accessToken,
    );
    final userId = response.user?.id;

    final existingUser = await supabase
        .from('users')
        .select('id')
        .eq('id', userId!)
        .maybeSingle();

    if(existingUser == null) {
      await supabase.from('users').insert({
        'id': response.user?.id,
        'first_name': googleUser.displayName,
        'avatar_url': googleUser.photoUrl,
        'username': googleUser.displayName,
      });

      await _createUserPreferences(userId);
    }

    if(response.session != null){
      final storage = GetStorage();
      storage.write('remember', true);
      _successLoginNotifications();
      Get.offAll(() => const NavigationMenu());
    }
  }

  Future<void> _signInWithFacebook(BuildContext context) async {
    late final StreamSubscription<AuthState> authSubscription;

    try {
      authSubscription = supabase.auth.onAuthStateChange.listen((data) async {
        final session = data.session;
        final user = session?.user;

        if (user != null) {
          final existingUser = await supabase
              .from('users')
              .select('id')
              .eq('id', user.id)
              .maybeSingle();

          if (existingUser == null) {
            final userMetadata = user.userMetadata;
            await supabase.from('users').insert({
              'id': user.id,
              'first_name': userMetadata?['name'] ?? 'Usuario Facebook',
              'avatar_url': userMetadata?['avatar_url'] ?? ImagesTrueq.defaultAvatar,
              'username': userMetadata?['nickname'] ?? 'facebook_user',
            });

            await _createUserPreferences(user.id);
          }

          final storage = GetStorage();
          storage.write('remember', true);

          await authSubscription.cancel();
          _successLoginNotifications();
          Get.offAll(() => const NavigationMenu());
        }
      });

      await supabase.auth.signInWithOAuth(
        OAuthProvider.facebook,
        redirectTo: 'trueq://login-callback',
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error inesperado: $e')),
      );
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: ColorsTrueq.lightGrey),
            borderRadius: BorderRadius.circular(100.r),
          ),
          child: IconButton(
            onPressed: () async {  await _signInWithGoogle();},
            icon: Image(
              image: AssetImage(ImagesTrueq.googleIcon),
              width: 24.w,
              height: 24.h,
            ),
          ),
        ),
        SizedBox(width: SizesTrueq.spaceBtwItems.w),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: ColorsTrueq.lightGrey),
            borderRadius: BorderRadius.circular(100.r),
          ),
          child: IconButton(
            onPressed: () async { await _signInWithFacebook(context);},
            icon: Image(
              image: AssetImage(ImagesTrueq.facebookIcon),
              width: 24.w,
              height: 24.h,
            ),
          ),
        ),
      ],
    );
  }
}
