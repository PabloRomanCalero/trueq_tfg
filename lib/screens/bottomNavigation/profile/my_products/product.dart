import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:rive/rive.dart';
import 'package:trueq/main.dart';
import 'package:trueq/screens/bottomNavigation/profile/my_products/other_profile.dart';
import 'package:trueq/utils/constants/colors.dart';
import 'package:trueq/utils/constants/sizes.dart';
import 'package:trueq/utils/constants/text_strings.dart';

import '../../../../utils/helper_functions.dart';
import '../../add_product/add_product.dart';

class ProductPage extends StatefulWidget {
  final Map<String, dynamic> product;
  final bool otherProfile;

  const ProductPage({super.key, required this.product, this.otherProfile = false});

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> with SingleTickerProviderStateMixin{
  late String productStatus;
  bool isLoading = false;
  Map<String, dynamic>? productUser;
  List<dynamic> myProducts = [];
  Map<String, dynamic> _userPreferences = {};

  BannerAd? _bannerAd;
  bool _isBannerAdReady = false;

  bool isFavorite = false;
  late StateMachineController? _controller;
  late SMITrigger? _tapInput;
  bool showRive = false;

  final ScrollController _scrollController = ScrollController();

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
    _fetchProductUser();
    _checkFavorite();
    _loadBannerFixedWidthAd();
    if (supabase.auth.currentUser?.id != widget.product['user_id']) {
      _updateUserPreference();
    }
    productStatus = widget.product['status'];
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  Future<void> _changeProductStatus() async {
    setState(() => isLoading = true);

    final newStatus = productStatus == 'available' ? 'interchanged' : 'available';

    try {
      final userResponse = await supabaseAdmin
        .from('users')
        .select('num_intercambios')
        .eq('id', widget.product['user_id'])
        .single();

      int currentIntercambios = userResponse['num_intercambios'] ?? 0;
      final int updatedIntercambios = newStatus == 'available'
        ? (currentIntercambios > 0 ? currentIntercambios - 1 : 0)
        : currentIntercambios + 1;

      final response = await Future.wait([
        supabaseAdmin
          .from('products')
          .update({'status': newStatus})
          .eq('id', widget.product['id'])
          .select('status')
          .single(),
        supabaseAdmin
          .from('users')
          .update({'num_intercambios': updatedIntercambios})
          .eq('id', widget.product['user_id'])
          .select(),
      ]);

      final statusUpdated = response[0] as Map<String, dynamic>;

      if (statusUpdated['status'] == newStatus) {
        setState(() {
          productStatus = newStatus;
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
        Get.snackbar(
          TextsTrueq.to.getText('error'),
          TextsTrueq.to.getText('couldNotUpdateStatus'),
          backgroundColor: Colors.red,
          colorText: ColorsTrueq.light,
        );
      }
    } catch (e) {
      setState(() => isLoading = false);
      Get.snackbar(
        TextsTrueq.to.getText('error'),
        TextsTrueq.to.getText('errorTryLater'),
        backgroundColor: Colors.red,
        colorText: ColorsTrueq.light,
      );
    }
  }

  Future<void> _fetchProductUser() async {
    final userId = widget.product['user_id'];
    final response = await supabase
      .from('users')
      .select('username, avatar_url, num_intercambios')
      .eq('id', userId)
      .single();

    setState(() {
      productUser = response;
    });
  }

  Future<void> _checkFavorite() async {
    final currentUserId = supabase.auth.currentSession?.user.id;
    if (currentUserId == null) return;

    final result = await supabase
      .from('favorites')
      .select('id')
      .eq('user_id', currentUserId)
      .eq('product_id', widget.product['id'])
      .maybeSingle();

    setState(() {
      isFavorite = result != null;
    });
  }

  Future<void> _fetchMyProducts() async {
    final currentUserId = supabase.auth.currentUser?.id;
    if (currentUserId == null) return;

    final products = await supabase
        .from('products')
        .select('id, title, image_url')
        .eq('user_id', currentUserId)
        .eq('status', 'available');

    List<Map<String, dynamic>> filteredProducts = [];

    for (final product in products) {
      final like = await supabaseAdmin
          .from('likes')
          .select()
          .match({
            'user_id': currentUserId,
            'offered_product_id': product['id'],
            'product_id': widget.product['id']})
          .maybeSingle();

      if (like == null) {
        filteredProducts.add(product);
      }
    }

    setState(() {
      myProducts = filteredProducts;
    });
  }

  Future<void> _updateUserPreference() async {
    final currentUserId = supabase.auth.currentUser?.id;
    if (currentUserId == null) return;

    final preferencesResponse = await supabaseAdmin
        .from('user_preferences')
        .select('category, like_count, view_count')
        .eq('user_id', currentUserId)
        .order('like_count', ascending: false);

    _userPreferences = {
      for (var preference in preferencesResponse)
        preference['category']: preference
    };

    final currentCategory = widget.product['category'];
    final currentViewCount = _userPreferences[currentCategory]?['view_count'] ?? 0;

    await supabaseAdmin
        .from('user_preferences')
        .update({
          'view_count': currentViewCount + 1})
        .eq('user_id', currentUserId)
        .eq('category', currentCategory);
  }

  void _loadBannerFixedWidthAd() {
    _bannerAd = BannerAd(
      adUnitId: 'ca-app-pub-3940256099942544/6300978111',
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (_) {
          setState(() {
            _isBannerAdReady = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
        },
      ),
    )..load();
  }

  Future<void> _showSuccessAnimation() async {
    final completer = Completer<void>();
    late RiveAnimationController controller;

    controller = OneShotAnimation(
      "Comp 1",
      autoplay: true,
      onStop: () {
        if (!completer.isCompleted) {
          completer.complete();
        }
      },
    );

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) {
        return Center(
          child: SizedBox(
            width: 100.w,
            height: 100.h,
            child: RiveAnimation.asset(
              "assets/animations/success.riv",
              controllers: [controller],
              fit: BoxFit.contain,
            ),
          ),
        );
      },
    );

    await completer.future;
    Navigator.of(context).pop();
  }

  Future<void> _showProductOptions() async {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            _buildListTile(Icons.edit_rounded, TextsTrueq.to.getText('editProduct'), () async {
              if(Navigator.canPop(context)){Navigator.pop(context);}
              final response = await Get.to(() => AddProductPage(title: widget.product['title'], product: widget.product));
              if (response) {
                Get.snackbar(TextsTrueq.to.getText('success'), TextsTrueq.to.getText('productEditedSuccessfully'), backgroundColor: ColorsTrueq.primary, colorText: ColorsTrueq.light,);
              }
            }, true),
            _buildListTile(Icons.delete_rounded, TextsTrueq.to.getText('deleteProduct'), () async {
              if(Navigator.canPop(context)){Navigator.pop(context);}
              showDeleteConfirmation();
            }, true),
            _buildListTile(Icons.close_rounded, TextsTrueq.to.getText('cancel'), () => Navigator.pop(context), true),
            SizedBox(height: SizesTrueq.defaultSpace.h),
          ],
        ),
      ),
    );
  }

  Widget _buildListTile(IconData icon, String title, VoidCallback onTap, [bool hideIcon = false]) {
    return ListTile(
      leading: Icon(icon, color: ColorsTrueq.primary, size: 24.sp),
      title: Text(
        title,
        style: TextStyle(fontSize: 15.sp),
      ),
      trailing: hideIcon ? null : Icon(Icons.chevron_right_rounded, color: ColorsTrueq.darkGrey, size: 24.sp),
      onTap: onTap,
    );
  }

  Future<void> _deleteProduct() async{
    try {
      await supabase.from('products').delete().eq('id', widget.product['id']);
      await _showSuccessAnimation();
      Get.back(result: true);
      Get.snackbar(TextsTrueq.to.getText('productDeleted'), TextsTrueq.to.getText('productDeletedSuccessfully'), backgroundColor: ColorsTrueq.primary, colorText: ColorsTrueq.light,);
    } catch (e) {
      Get.snackbar(TextsTrueq.to.getText('error'), TextsTrueq.to.getText('errorTryLater'), backgroundColor: Colors.red, colorText: ColorsTrueq.light,);
    }
  }

  void showDeleteConfirmation() {
    final dark = HelperFunctions.isDarkMode(context);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(TextsTrueq.to.getText('confirmDeleteProduct')),
          content: Text(TextsTrueq.to.getText('confirmDeleteMessageProduct')),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                TextsTrueq.to.getText('cancel'),
                style: TextStyle(color: dark ? ColorsTrueq.light : ColorsTrueq.dark),
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                _deleteProduct();
              },
              child: Text(
                TextsTrueq.to.getText('delete'),
                style: const TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = supabase.auth.currentSession?.user.id;
    final createdAt = widget.product['created_at'] != null
      ? DateTime.parse(widget.product['created_at']).toLocal()
      : null;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Stack(
              children: [
                Hero(
                  tag: 'product-image-${widget.product['id']}',
                  child: InteractiveViewer(
                    child: CachedNetworkImage(
                      imageUrl: widget.product['image_url'],
                      width: double.infinity,
                      height: 350.h,
                      fit: BoxFit.cover,
                      errorWidget: (context, url, error) => Icon(
                        Icons.error_rounded,
                        size: 50.sp,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 10.h,
                  left: 10.w,
                  child: CircleAvatar(
                    backgroundColor: ColorsTrueq.dark.withAlpha((0.4 * 255).toInt()),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: ColorsTrueq.light),
                      onPressed: () => Get.back(result: true),
                    ),
                  ),
                ),
                if(currentUserId == widget.product['user_id'])
                Positioned(
                  top: 10.h,
                  right: 10.w,
                  child: CircleAvatar(
                    backgroundColor: ColorsTrueq.dark.withAlpha((0.4 * 255).toInt()),
                    child: IconButton(
                      icon: const Icon(Icons.more_vert_outlined, color: ColorsTrueq.light),
                      onPressed: () => _showProductOptions(),
                    ),
                  ),
                ),
                if(currentUserId != widget.product['user_id'])
                  Positioned(
                    top: 10.h,
                    right: 10.w,
                    child: SizedBox(
                      width: 48.sp,
                      height: 48.sp,
                      child: GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: () async {
                          if (!isFavorite) {
                            try {
                              await supabaseAdmin.from('favorites').insert({
                                'user_id': currentUserId,
                                'product_id': widget.product['id'],
                              });
                              if (mounted) {
                                setState(() {
                                  isFavorite = true;
                                });
                              }
                              _tapInput?.fire();
                            } catch (e) {
                              Get.snackbar(
                                TextsTrueq.to.getText('error'),
                                TextsTrueq.to.getText('errorFavorite'),
                                backgroundColor: Colors.red,
                                colorText: ColorsTrueq.light,
                              );
                            }
                          } else {
                            try {
                              await supabaseAdmin
                                  .from('favorites')
                                  .delete()
                                  .eq('user_id', currentUserId!)
                                  .eq('product_id', widget.product['id']);
                              setState(() {
                                isFavorite = false;
                              });
                            } catch (e) {
                              Get.snackbar(
                                TextsTrueq.to.getText('error'),
                                TextsTrueq.to.getText('errorUnfavorite'),
                                backgroundColor: Colors.red,
                                colorText: ColorsTrueq.light,
                              );
                            }
                          }
                        },
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            CircleAvatar(
                              backgroundColor: ColorsTrueq.dark.withAlpha((0.4 * 255).toInt()),
                              child: ShaderMask(
                                shaderCallback: (bounds) => ColorsTrueq.pinkGradient.createShader(bounds),
                                blendMode: BlendMode.srcIn,
                                child: Icon(
                                  isFavorite ? Icons.favorite_rounded : Icons.favorite_border_outlined,
                                  size: 24.sp,
                                  color: ColorsTrueq.light,
                                ),
                              ),
                            ),

                            RiveAnimation.asset(
                              "assets/animations/favorite_animation.riv",
                              fit: BoxFit.contain,
                              stateMachines: ['State Machine'],
                              onInit: (artboard) {
                                _controller = StateMachineController.fromArtboard(
                                  artboard,
                                  'State Machine',
                                );
                                if (_controller != null) {
                                  artboard.addController(_controller!);
                                  _tapInput = _controller!.findInput<SMITrigger>('Tap') as SMITrigger?;
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.only(left: SizesTrueq.defaultSpace.w, right: SizesTrueq.defaultSpace.w, bottom: SizesTrueq.defaultSpace.h, top: SizesTrueq.spaceBtwItems.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            widget.product['title'],
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                          decoration: BoxDecoration(
                            color: productStatus == 'available'
                              ? ColorsTrueq.primary
                              : ColorsTrueq.darkGrey,
                            borderRadius: BorderRadius.circular(SizesTrueq.inputFieldRadius),
                          ),
                          child: Text(
                            productStatus == 'available'
                              ? TextsTrueq.to.getText('available')
                              : TextsTrueq.to.getText('interchanged'),
                            style: TextStyle(
                              color: ColorsTrueq.light,
                              fontWeight: FontWeight.bold,
                              fontSize: 12.sp,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: (SizesTrueq.spaceBtwItems / 2).h),
                    Text(
                      '${TextsTrueq.to.getText('category')}: ${_categoriesMap[widget.product['category']]}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    if (createdAt != null)
                      Padding(
                        padding: EdgeInsets.only(top: (SizesTrueq.spaceBtwItems / 2).h),
                        child: Text(
                          '${TextsTrueq.to.getText('postedOn')}: ${createdAt.day}/${createdAt.month}/${createdAt.year}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: ColorsTrueq.darkGrey),
                        ),
                      ),
                    SizedBox(height: (SizesTrueq.spaceBtwSections - 8).h),
                    widget.product['description'].isNotEmpty ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          TextsTrueq.to.getText('description'),
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: (SizesTrueq.spaceBtwItems / 2).h),
                        Text(
                          widget.product['description'],
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ) : Text(
                      TextsTrueq.to.getText('noDescription'),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: ColorsTrueq.darkGrey),
                    ),
                    if (_isBannerAdReady)
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: SizesTrueq.spaceBtwSections.h / 2),
                        child: Center(
                          child: SizedBox(
                            width: _bannerAd!.size.width.toDouble(),
                            height: _bannerAd!.size.height.toDouble(),
                            child: AdWidget(ad: _bannerAd!),
                          ),
                        ),
                      ),
                    if(currentUserId == widget.product['user_id'])
                    Center(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: productStatus == 'available' ? Colors.red : ColorsTrueq.primary,
                          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(SizesTrueq.inputFieldRadius),
                          ),
                        ),
                        icon: isLoading ? SizedBox(
                          height: 18.h,
                          width: 18.w,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.w,
                            color: ColorsTrueq.light,
                          ),
                        ) : Icon(productStatus == 'available' ? Icons.check_rounded : Icons.undo_rounded, color: ColorsTrueq.light),
                        label: Text(
                          productStatus == 'available'
                            ? TextsTrueq.to.getText('markAsInterchanged')
                            : TextsTrueq.to.getText('markAsAvailable'),
                          style: TextStyle(color: ColorsTrueq.light),
                        ),
                        onPressed: isLoading ? null : _changeProductStatus,
                      ),
                    ),
                    if(currentUserId != widget.product['user_id'] && !widget.otherProfile)
                    _buildUserProfileSection(),
                    if (currentUserId != widget.product['user_id'])
                    Center(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ColorsTrueq.primary,
                          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(SizesTrueq.inputFieldRadius),
                          ),
                        ),
                        icon: Icon(Icons.swap_horiz, color: ColorsTrueq.light, size: 18.sp),
                        label: Text(
                          TextsTrueq.to.getText('startTrueq'),
                          style: TextStyle(color: ColorsTrueq.light, fontSize: 15.sp),
                        ),
                        onPressed: () async {
                          await _fetchMyProducts();
                          if (!context.mounted) return;
                          final chosenProduct = await showDialog<Map<String, dynamic>>(
                            context: context,
                            builder: (alertDialog) => AlertDialog(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
                              title: Text(
                                TextsTrueq.to.getText('chooseProductToOffer'),
                                style: TextStyle(fontSize: 18.sp),
                              ),
                              content: SizedBox(
                                width: double.maxFinite,
                                height: 300.h,
                                child: myProducts.isNotEmpty
                                  ? Scrollbar(
                                  controller: _scrollController,
                                  thumbVisibility: true,
                                  thickness: 4,
                                  radius: Radius.circular(10.r),
                                  trackVisibility: true,
                                  interactive: true,
                                  child: ListView.builder(
                                    controller: _scrollController,
                                    itemCount: myProducts.length,
                                    itemBuilder: (alertDialog, index) {
                                      final product = myProducts[index];
                                      return Padding(
                                        padding: EdgeInsets.only(top: 8.h),
                                        child: ListTile(
                                          leading: CircleAvatar(
                                            radius: 25.r,
                                            backgroundImage: CachedNetworkImageProvider(product['image_url']),
                                          ),
                                          title: Text(
                                            product['title'],
                                            style: TextStyle(fontSize: 16.sp),
                                            maxLines: 1,
                                          ),
                                          onTap: () async {
                                            await _showSuccessAnimation();
                                            Navigator.of(context).pop(product);
                                          },
                                        ),
                                      );
                                    },
                                  ),
                                ) : Center(
                                  child: Text(TextsTrueq.to.getText('noProductsAvailable')),
                                ),
                              ),
                            ),
                          );

                          if (chosenProduct != null) {
                            await supabaseAdmin.from('likes').insert({
                              'user_id': currentUserId,
                              'product_id': widget.product['id'],
                              'offered_product_id': chosenProduct['id']
                            });

                            await supabaseAdmin.from('user_preferences').update({
                              'like_count': (_userPreferences[widget.product['category']]?['like_count']) + 1,
                              'last_interaction': DateTime.now().toIso8601String(),
                            }).eq('user_id', currentUserId ?? '').eq('category', widget.product['category']);

                            final mutualLike = await supabaseAdmin
                              .from('likes')
                              .select('product_id')
                              .eq('user_id', widget.product['user_id'])
                              .eq('offered_product_id', widget.product['id'])
                              .eq('product_id', chosenProduct['id']);

                            if (mutualLike.isNotEmpty) {
                              await supabaseAdmin.from('chats').insert({
                                'user1_id': currentUserId,
                                'user2_id': widget.product['user_id'],
                                'product1_id': chosenProduct['id'],
                                'product2_id': widget.product['id'],
                              });
                            }
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserProfileSection() {
    return Column(
      children: [
        const Divider(),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 30.r,
              backgroundImage: CachedNetworkImageProvider(productUser?['avatar_url'] ?? ''),
              backgroundColor: Colors.transparent,
            ),
            SizedBox(width: 12.w),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  productUser?['username'] ?? '',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    Icon(Icons.swap_horiz_rounded, size: 18.sp, color: ColorsTrueq.primary),
                    SizedBox(width: 4.w),
                    Text(
                      '${productUser?['num_intercambios'] ?? 0} ${TextsTrueq.to.getText('exchangesProduct')}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: ColorsTrueq.darkGrey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const Spacer(),
            TextButton(
              onPressed: () {
                Get.to(() => OtherProfile(userId: widget.product['user_id']));
              },
              style: TextButton.styleFrom(
                foregroundColor: ColorsTrueq.primary,
              ),
              child: Text(
                TextsTrueq.to.getText('viewProfile'),
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const Divider(),
      ],
    );
  }
}