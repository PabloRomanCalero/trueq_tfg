import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:trueq/screens/bottomNavigation/add_product/title_add_product.dart';
import 'package:trueq/screens/bottomNavigation/profile/profile.dart';
import 'package:trueq/utils/constants/colors.dart';
import '../../utils/constants/text_strings.dart';
import 'chats/chats.dart';
import 'favourites/favorites.dart';
import 'home/home.dart';

class NavigationMenu extends StatelessWidget {
  const NavigationMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(NavigationController());
    return Scaffold(
      bottomNavigationBar: Obx(
        () => NavigationBarTheme(
          data: NavigationBarThemeData(
            indicatorColor: ColorsTrueq.primary,
            backgroundColor: ColorsTrueq.primary,
            iconTheme: WidgetStateProperty.resolveWith<IconThemeData>(
              (Set<WidgetState> states) {
                if (states.contains(WidgetState.selected)) {
                  return const IconThemeData(color: ColorsTrueq.light);
                }
                return const IconThemeData(color: ColorsTrueq.lightGrey);
              },
            ),
            labelTextStyle: WidgetStateProperty.resolveWith<TextStyle?>(
                  (Set<WidgetState> states) {
                if (states.contains(WidgetState.selected)) {
                  return TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.bold,
                    color: ColorsTrueq.light,
                  );
                }
                return TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.normal,
                  color: ColorsTrueq.light,
                );
              },
            ),
          ),
          child: NavigationBar(
            selectedIndex: controller.selectedIndex.value,
            onDestinationSelected: (index) => controller.selectedIndex.value = index,
            destinations: <Widget>[
              NavigationDestination(icon: Icon(Icons.home_rounded, size: 24.sp), label: TextsTrueq.to.getText('home')),
              NavigationDestination(icon: Icon(Icons.favorite_rounded, size: 24.sp), label: TextsTrueq.to.getText('favourites')),
              NavigationDestination(icon: Icon(Icons.add_circle_rounded, size: 24.sp), label: ''),
              NavigationDestination(icon: Icon(Icons.message_rounded, size: 24.sp), label: 'Trueqs'),
              NavigationDestination(icon: Icon(Icons.person_rounded, size: 24.sp), label: TextsTrueq.to.getText('profile')),
            ],
          ),
        ),
      ),
      body: Obx(() => controller.screens[controller.selectedIndex.value]),
    );
  }
}

class NavigationController extends GetxController{
  final Rx<int> selectedIndex = 0.obs;

  final screens = [
    const HomePage(),
    const FavoritesPage(),
    const TitleAddProduct(),
    const ChatsPage(),
    const ProfilePage(),
  ];
}
