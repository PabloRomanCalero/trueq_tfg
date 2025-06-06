import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:trueq/screens/bottomNavigation/add_product/add_product.dart';
import 'package:trueq/screens/bottomNavigation/profile/my_products/product.dart';
import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/sizes.dart';
import '../../../../utils/constants/text_strings.dart';
import '../../../../utils/helper_functions.dart';
import '../../../../main.dart';

class MyProducts extends StatefulWidget {
  const MyProducts({super.key});

  @override
  State<MyProducts> createState() => _MyProductsState();
}

class _MyProductsState extends State<MyProducts> {
  List<dynamic> products = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() => _isLoading = true);
    final user = supabase.auth.currentUser;
    if (user == null) return;

    final productResponse = await supabase
        .from('products')
        .select()
        .eq('user_id', user.id)
        .order('status', ascending: true)
        .order('created_at', ascending: true);

    setState(() {
      products = productResponse;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final dark = HelperFunctions.isDarkMode(context);
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            title: Text(
              TextsTrueq.to.getText('myProducts'),
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: true,
          ),
          SliverFillRemaining(
            child: _isLoading ? const Center(child: CircularProgressIndicator(color: ColorsTrueq.primary)) : products.isEmpty
            ? Center(
              child: Padding(
                padding: EdgeInsets.only(bottom: 120.h),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.inventory_2_outlined, size: 65.sp, color: ColorsTrueq.primary),
                    SizedBox(height: 16.h),
                    Text(
                      TextsTrueq.to.getText('noProducts'),
                      style: TextStyle(
                        fontSize: 18.sp,
                        color: dark ? ColorsTrueq.lightGrey : ColorsTrueq.darkGrey,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
            : GridView.builder(
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
                  onTap: () async {
                    final response = await Get.to(() => ProductPage(product: product));
                    if (response) {
                      _loadProducts();
                    }
                  },
                  child: Stack(
                    children: [
                      Opacity(
                        opacity: product['status'] == 'available' ? 1.0 : 0.5,
                        child: Card(
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
                                      imageUrl: product['image_url'],
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
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        top: 4.h,
                        left: 4.w,
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                          decoration: BoxDecoration(
                            color: product['status'] == 'available' ? ColorsTrueq.primary : ColorsTrueq.darkGrey,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(SizesTrueq.inputFieldRadius),
                              bottomRight: Radius.circular(SizesTrueq.inputFieldRadius),
                            ),
                          ),
                          child: Text(
                            product['status'] == 'available' ? TextsTrueq.to.getText('available') : TextsTrueq.to.getText('interchanged'),
                            style: TextStyle(
                              color: ColorsTrueq.light,
                              fontWeight: FontWeight.bold,
                              fontSize: 12.sp,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
