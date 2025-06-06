import 'package:flutter/material.dart';
import 'package:trueq/utils/constants/image_strings.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: ClipOval(
          child: Image(
            image: AssetImage(
                ImagesTrueq.logo
            ),
            height: 240,
            width: 240,
            fit: BoxFit.cover,
          )
        ),
      ),
    );
  }
}
