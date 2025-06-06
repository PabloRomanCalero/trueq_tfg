import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:trueq/main.dart';

import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/sizes.dart';
import '../../../../utils/constants/text_strings.dart';
import '../../../../utils/helper_functions.dart';
import '../profile/my_products/product.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  final supabase = Supabase.instance.client;
  List<dynamic> products = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchFavorites();
  }

  Future<void> fetchFavorites() async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) return;

      final favorites = await supabaseAdmin
        .from('favorites')
        .select('product_id')
        .eq('user_id', userId)
        .order('created_at', ascending: false);

      final favoriteProductsIds = favorites.map((favorite) => favorite['product_id']).toList();

      final favoriteProducts = await supabaseAdmin
        .from('products')
        .select()
        .eq('status', 'available')
        .inFilter('id', favoriteProductsIds);

      favoriteProducts.sort((a, b) => favoriteProductsIds.indexOf(a['id']) - favoriteProductsIds.indexOf(b['id']));

      setState(() {
        products = favoriteProducts;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      Get.snackbar(
        TextsTrueq.to.getText('error'),
        TextsTrueq.to.getText('errorLoadingFavorites'),
        backgroundColor: Colors.red,
        colorText: ColorsTrueq.light,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final dark = HelperFunctions.isDarkMode(context);
    return Scaffold(
      body: SafeArea(
        child: isLoading
          ? const Center(child: CircularProgressIndicator(color: ColorsTrueq.primary))
          : products.isEmpty
          ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.favorite_border_outlined, size: 60.sp, color: ColorsTrueq.primary),
                SizedBox(height: 16.h),
                Text(
                  TextsTrueq.to.getText('noFavorites'),
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: ColorsTrueq.darkGrey, fontWeight: FontWeight.normal),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          )
          : GridView.builder(
            padding: EdgeInsets.all(12.r),
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
                onTap: () async {
                  final response = await Get.to(() => ProductPage(product: product));

                  if(response == true){
                    fetchFavorites();
                  }
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
                                top: Radius.circular(SizesTrueq.inputFieldRadius),
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
    );
  }
}
