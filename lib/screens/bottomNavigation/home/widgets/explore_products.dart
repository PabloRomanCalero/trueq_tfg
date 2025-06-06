import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:trueq/main.dart';
import 'package:trueq/screens/bottomNavigation/home/widgets/product_list.dart';
import 'package:trueq/screens/bottomNavigation/profile/my_products/product.dart';
import 'package:trueq/utils/constants/colors.dart';
import 'package:trueq/utils/constants/sizes.dart';
import 'package:trueq/utils/constants/text_strings.dart';
import 'package:trueq/utils/helper_functions.dart';

class ExploreProducts extends StatefulWidget {
  const ExploreProducts({super.key});

  @override
  State<ExploreProducts> createState() => _ExploreProductsState();
}

class _ExploreProductsState extends State<ExploreProducts> {
  final TextEditingController _controllerSearchBar = TextEditingController();
  Map<String, List<dynamic>> categorizedProducts = {};
  bool _loading = true;
  String _searchProduct = '';
  List<dynamic> _allProducts = [];
  List<dynamic> productsSearchBar = [];

  final Map<String, String> _categoriesMap = {
    'Electrónica': TextsTrueq.to.getText('categoryElectronics'),
    'Moda': TextsTrueq.to.getText('categoryFashion'),
    'Hogar': TextsTrueq.to.getText('categoryHome'),
    'Deportes': TextsTrueq.to.getText('categorySports'),
    'Juguetes': TextsTrueq.to.getText('categoryToys'),
    'Otros': TextsTrueq.to.getText('categoryOthers'),
  };

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  @override
  void dispose() {
    _controllerSearchBar.dispose();
    super.dispose();
  }

  Future<void> _loadProducts() async {
    final userId = supabase.auth.currentUser?.id ?? '';

    try {
      setState(() => _loading = true);

      final preferencesResponse = await supabaseAdmin
          .from('user_preferences')
          .select('category')
          .eq('user_id', userId)
          .order('like_count', ascending: false);

      List preferredCategories = preferencesResponse.map((pref) => pref['category']).toList();

      if (preferredCategories.isEmpty) {
        setState(() {
          categorizedProducts = {};
          _allProducts = [];
          _loading = false;
        });
        return;
      }

      final results = await Future.wait([
        supabaseAdmin
            .from('products')
            .select()
            .eq('status', 'available')
            .neq('user_id', userId)
            .inFilter('category', preferredCategories)
            .order('created_at', ascending: false)
            .limit(40),
        supabaseAdmin
            .from('products')
            .select()
            .eq('status', 'available')
            .neq('user_id', userId),
      ]);

      final categorizedProductsResponse = results[0];
      final allProductsResponse = results[1];

      Map<String, List<dynamic>> newCategorizedProducts = {};
      for (var product in categorizedProductsResponse) {
        final category = product['category'];
        newCategorizedProducts.putIfAbsent(category, () => []).add(product);
      }

      final productsSearchBarTitles = allProductsResponse.map((product) => product['title']).toSet().toList();

      setState(() {
        categorizedProducts = newCategorizedProducts;
        _allProducts = allProductsResponse;
        productsSearchBar = productsSearchBarTitles;
        _loading = false;
      });

    } catch (e) {
      setState(() => _loading = false);
    }
  }

  List<dynamic> _filterProducts() {
    return productsSearchBar.where((title) {
      return title.toLowerCase().contains(_searchProduct);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final dark = HelperFunctions.isDarkMode(context);

    return Scaffold(
      body: SafeArea(
        child: _loading
          ? const Center(child: CircularProgressIndicator(color: ColorsTrueq.primary))
          : ListView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: EdgeInsets.all(12.r),
            children: [
              Container(
                decoration: BoxDecoration(
                  color: ColorsTrueq.light,
                  borderRadius: BorderRadius.circular(SizesTrueq.inputFieldRadius),
                  boxShadow: [
                    BoxShadow(
                      color: ColorsTrueq.dark.withAlpha((0.2 * 255).toInt()),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.0.w),
                      child: Icon(Icons.search_rounded, color: ColorsTrueq.darkGrey),
                    ),
                    Expanded(
                      child: TextField(
                        controller: _controllerSearchBar,
                        onChanged: (value) {
                          setState(() {
                            _searchProduct = value.toLowerCase();
                          });
                        },
                        decoration: InputDecoration(
                          hintText: TextsTrueq.to.getText('exploreProducts'),
                          hintStyle: TextStyle(color: ColorsTrueq.darkGrey),
                          border: InputBorder.none,
                        ),
                        style: TextStyle(
                          color: ColorsTrueq.darkGrey,
                        ),
                      ),
                    ),
                    if(_searchProduct.isNotEmpty)
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12.w),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _searchProduct = '';
                            _controllerSearchBar.clear();
                          });
                        },
                        child: Icon(Icons.clear_rounded, color: ColorsTrueq.darkGrey, size: 18.sp),
                      )
                    )
                  ],
                ),
              ),
              if (_searchProduct.isNotEmpty)
                Container(
                  constraints: BoxConstraints(maxHeight: 300.h),
                  child: ListView(
                    shrinkWrap: true,
                    children: _filterProducts().map((title) {
                      return ListTile(
                        title: Text(title),
                        onTap: () {
                          FocusManager.instance.primaryFocus?.unfocus();
                          setState(() {
                            _controllerSearchBar.text = title;
                            _searchProduct = title;
                          });
                          final matchingProducts = _allProducts.where((product) => product['title'] == title).toList();
                          Get.to(() => ProductList(products: matchingProducts, title: title));
                        },
                      );
                    }).toList(),
                  ),
                ),
              SizedBox(height: 12.h),
              ...categorizedProducts.entries.map((entry) {
                final category = entry.key;
                final products = entry.value;
  
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.0.h, horizontal: 4.0.w),
                      child: Text(
                        _categoriesMap[category]!,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: dark ? ColorsTrueq.light : ColorsTrueq.dark, fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(
                      height: 240.h,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: products.length,
                        separatorBuilder: (_, __) => SizedBox(width: 12.w),
                        itemBuilder: (context, index) {
                          final product = products[index];
  
                          return GestureDetector(
                            onTap: () {Get.to(() => ProductPage(product: product));},
                            child: SizedBox(
                              width: 160.w,
                              child: Card(
                                elevation: 3,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(SizesTrueq.inputFieldRadius)
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
                                            fit: BoxFit.cover,
                                            width: double.infinity,
                                            errorWidget: (context, url, error) => const Icon(Icons.error_rounded),
                                          ),
                                        )
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.all(8.0.r),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            product['title'],
                                            maxLines: 2,
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
                            )
                          );
                        },
                      ),
                    ),
                  ],
                );
              }),
            ],
          ),
      ),
    );
  }
}
