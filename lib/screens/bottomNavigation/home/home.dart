import 'package:flutter/material.dart';
import 'package:trueq/screens/bottomNavigation/home/widgets/explore_products.dart';
import 'package:trueq/screens/bottomNavigation/home/widgets/swiper_products.dart';
import 'package:trueq/utils/constants/colors.dart';

import '../../../utils/constants/text_strings.dart';


class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: TabBar(
            indicatorSize: TabBarIndicatorSize.label,
            indicatorColor: ColorsTrueq.primary,
            labelColor: ColorsTrueq.primary,
            unselectedLabelColor: ColorsTrueq.darkGrey,
            tabs: [
              Tab(text: TextsTrueq.to.getText('for_you')),
              Tab(text: TextsTrueq.to.getText('explore')),
            ],
          ),
        ),
        body: const TabBarView(
          physics: NeverScrollableScrollPhysics(),
          children: [
            SwiperProducts(),
            ExploreProducts(),
          ],
        ),
      ),
    );
  }
}


