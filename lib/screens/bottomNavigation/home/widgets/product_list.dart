import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/sizes.dart';
import '../../../../utils/constants/text_strings.dart';
import '../../../../utils/helper_functions.dart';
import '../../profile/my_products/product.dart';

class ProductList extends StatelessWidget {
  final List<dynamic> products;
  final String title;

  const ProductList({super.key, required this.products, required this.title});

  @override
  Widget build(BuildContext context) {
    final dark = HelperFunctions.isDarkMode(context);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            title: Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: dark ? ColorsTrueq.light : ColorsTrueq.dark,
                fontWeight: FontWeight.normal
              ),
            ),
            pinned: true,
          ),
          SliverFillRemaining(
            child: GridView.builder(
              padding: EdgeInsets.only(left: 12.w, right: 12.w, top: 12.h, bottom: SizesTrueq.defaultSpace.h),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.75,
              ),
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];

                return GestureDetector(
                  onTap: () {
                    Get.to(() => ProductPage(product: product));
                  },
                  child: Stack(
                    children: [
                      Card(
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(SizesTrueq.inputFieldRadius),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(SizesTrueq.inputFieldRadius)
                                ),
                                child: Hero(
                                  tag: 'product-image-${product['id']}',
                                  child: CachedNetworkImage(
                                    imageUrl: product['image_url'] ?? '',
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                    errorWidget: (context, url, error) =>
                                    const Icon(Icons.error_rounded),
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.all(8.r),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product['title'] ?? 'Producto',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(context).textTheme.titleLarge?.copyWith(color: dark ? ColorsTrueq.light : ColorsTrueq.dark, fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(height: 4.h),
                                  Text(
                                    product['description'] != '' ? product['description'] : TextsTrueq.to.getText('noDescription'),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(context).textTheme.labelLarge?.copyWith(color: dark ? ColorsTrueq.lightGrey : ColorsTrueq.darkGrey),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ]
      ),
    );
  }
}
