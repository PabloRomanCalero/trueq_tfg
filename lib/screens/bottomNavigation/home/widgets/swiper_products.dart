import 'dart:async';
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:rive/rive.dart';
import 'package:trueq/main.dart';
import 'package:trueq/utils/constants/colors.dart';
import 'package:trueq/utils/helper_functions.dart';

import '../../../../utils/constants/text_strings.dart';

class SwiperProducts extends StatefulWidget {
  const SwiperProducts({super.key});

  @override
  State<SwiperProducts> createState() => _SwiperProducts();
}

class _SwiperProducts extends State<SwiperProducts> {
  final List<dynamic> _products = [];
  bool _loading = true;
  final int _limit = 10;
  bool _isFetchingMore = false;
  bool _hasMore = true;
  int _swipeCount = 0;
  InterstitialAd? _interstitialAd;

  Map<String, Map<String, dynamic>> _userPreferences = {};
  final CardSwiperController _controller = CardSwiperController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    fetchProducts();
    _loadInterstitialAd();
  }

  Future<void> fetchProducts() async {
    if (_isFetchingMore || !_hasMore) return;
    setState(() => _isFetchingMore = true);

    final userId = supabase.auth.currentUser?.id ?? '';
    final results = await Future.wait([
      supabaseAdmin
          .from('likes')
          .select('product_id')
          .eq('user_id', userId),
      supabaseAdmin
          .from('user_preferences')
          .select('category, like_count, view_count')
          .eq('user_id', userId)
          .order('like_count', ascending: false),
    ]);

    final likedResponse = results[0];
    final preferencesResponse = results[1];

    final likedProductIds = likedResponse.map((like) => like['product_id']).toList();

    _userPreferences = {for (var preference in preferencesResponse) preference['category']: preference};

    final preferredCategories = preferencesResponse.map((p) => p['category']).toList();

    if (preferredCategories.isEmpty) {
      setState(() {
        _loading = false;
        _isFetchingMore = false;
      });
      return;
    }

    final int totalWeight = preferredCategories.length * (preferredCategories.length + 1) ~/ 2;

    final categoryFutures = <Future<List<dynamic>>>[];

    for (int i = 0; i < preferredCategories.length; i++) {
      final category = preferredCategories[i];
      final weight = preferredCategories.length - i;
      int count = (_limit * weight / totalWeight).round();
      count = count < 1 ? 1 : count;

      final future = () async {
        final totalCountResponse = await supabaseAdmin
            .from('products')
            .select('id')
            .eq('status', 'available')
            .neq('user_id', userId)
            .eq('category', category)
            .not('id', 'in', likedProductIds.isNotEmpty ? likedProductIds : [''])
            .count();

        final totalCount = totalCountResponse.count;
        final maxOffset = (totalCount - count).clamp(0, totalCount);
        final randomOffset = Random().nextInt(maxOffset + 1);

        final response = await supabaseAdmin
            .from('products')
            .select()
            .eq('status', 'available')
            .neq('user_id', userId)
            .eq('category', category)
            .not('id', 'in', likedProductIds.isNotEmpty ? likedProductIds : [''])
            .range(randomOffset, randomOffset + count - 1);

        return response;
      }();
      categoryFutures.add(future);
    }

    final allProductsLists = await Future.wait(categoryFutures);
    final newProducts = allProductsLists.expand((product) => product).toList();
    newProducts.shuffle(Random());

    setState(() {
      _products.addAll(newProducts);
      _isFetchingMore = false;
      _loading = false;
    });
  }

  void _loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: 'ca-app-pub-3940256099942544/1033173712',
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          _interstitialAd = ad;
        },
        onAdFailedToLoad: (LoadAdError error) {
          _interstitialAd = null;
        },
      ),
    );
  }

  void _showInterstitialAd() {
    if (_interstitialAd != null) {
      _interstitialAd!.show();
      _interstitialAd = null;
      _loadInterstitialAd(); //Para precargar el siguiente
    }
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

  @override
  Widget build(BuildContext context) {
    final dark = HelperFunctions.isDarkMode(context);
    if (_loading) return const Center(child: CircularProgressIndicator(color: ColorsTrueq.primary,));

    if (_products.isEmpty || _products.length == 1) {
      return Center(child: Text(TextsTrueq.to.getText('noProductsAvailable')));
    }

    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: CardSwiper(
              controller: _controller,
              isLoop: false,
              cardsCount: _products.length,
              onSwipe: (previousIndex, currentIndex, direction) async {
                _swipeCount ++;
                if (_swipeCount % 10 == 0) {
                  _showInterstitialAd();
                }
                if (_hasMore && currentIndex! >= _products.length - 2) {
                  fetchProducts();
                }
                final likedProduct = _products[previousIndex];
                final userId = supabase.auth.currentUser?.id;

                if (direction == CardSwiperDirection.left) {
                  if(userId != null){
                    await supabaseAdmin.from('user_preferences').update({
                      'view_count': (_userPreferences[likedProduct['category']]?['view_count']) + 1,
                    }).eq('user_id', userId).eq('category', likedProduct['category']);
                  }
                }
                else if (direction == CardSwiperDirection.right) {
                  if (userId != null) {
                    final products = await supabase
                        .from('products')
                        .select('id, title, image_url')
                        .eq('user_id', userId)
                        .eq('status', 'available');

                    List<Map<String, dynamic>> filteredProducts = [];

                    for (final product in products) {
                      final like = await supabaseAdmin
                          .from('likes')
                          .select()
                          .match({
                            'user_id': userId,
                            'offered_product_id': product['id'],
                            'product_id': likedProduct['id']})
                          .maybeSingle();

                      if (like == null) {
                        filteredProducts.add(product);
                      }
                    }

                    final myProducts = List<dynamic>.from(filteredProducts);

                    if (myProducts.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(TextsTrueq.to.getText('noAvailableProductsTrueq'))),
                      );
                      _controller.undo();
                      return true;
                    }
                    
                    if (!context.mounted) return true;
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
                          )
                              : Center(
                            child: Text(TextsTrueq.to.getText('noProductsAvailable')),
                          ),
                        ),
                      ),
                    );

                    if (chosenProduct == null){
                      _controller.undo();
                      return true;
                    }

                    await supabaseAdmin.from('likes').insert({
                      'user_id': userId,
                      'product_id': likedProduct['id'],
                      'offered_product_id': chosenProduct['id'],
                    });

                    await supabaseAdmin.from('user_preferences').update({
                      'view_count': (_userPreferences[likedProduct['category']]?['view_count']) + 1,
                      'like_count': (_userPreferences[likedProduct['category']]?['like_count']) + 1,
                      'last_interaction': DateTime.now().toIso8601String(),
                    }).eq('user_id', userId).eq('category', likedProduct['category']);

                    final mutualLike = await supabaseAdmin
                      .from('likes')
                      .select('product_id')
                      .eq('user_id', likedProduct['user_id'])
                      .eq('product_id', chosenProduct['id']);

                    if (mutualLike.isNotEmpty) {
                      await supabaseAdmin.from('chats').insert({
                        'user1_id': userId,
                        'user2_id': likedProduct['user_id'],
                        'product1_id': chosenProduct['id'],
                        'product2_id': likedProduct['id'],
                      });
                    }
                  }
                }
                return true;
              },
              allowedSwipeDirection: const AllowedSwipeDirection.only(left: true, right: true),
              cardBuilder: (context, index, percentThresholdX, percentThresholdY) {
                final product = _products[index];
                return SizedBox(
                  width: MediaQuery.of(context).size.width * 0.9.w,
                  height: MediaQuery.of(context).size.height * 0.6.h,
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.r)
                    ),
                    elevation: 5,
                    child: Column(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(20.r)
                            ),
                            child: CachedNetworkImage(
                              imageUrl: product['image_url'],
                              fit: BoxFit.cover,
                              width: double.infinity,
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(12.0.r),
                          child: Column(
                            children: [
                              Text(product['title'],
                                style: TextStyle(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.bold
                                )
                              ),
                              SizedBox(height: 6.h),
                              if(product['description'] != null && product['description'].toString().trim().isNotEmpty)
                              Text(product['description'],
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: dark ? ColorsTrueq.lightGrey : ColorsTrueq.darkGrey,
                                )
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          SizedBox(height: 16.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              RawMaterialButton(
                onPressed: () => _controller.swipe(CardSwiperDirection.left),
                fillColor: Colors.redAccent,
                shape: const CircleBorder(),
                elevation: 6.0,
                constraints: BoxConstraints.tightFor(
                  width: 60.0.w,
                  height: 60.0.h,
                ),
                child: Icon(Icons.close_rounded, color: ColorsTrueq.light, size: 32.sp),
              ),
              SizedBox(width: 20.w),
              RawMaterialButton(
                onPressed: () => _controller.swipe(CardSwiperDirection.right),
                fillColor: Colors.green,
                shape: const CircleBorder(),
                elevation: 6.0,
                constraints: BoxConstraints.tightFor(
                  width: 60.0.w,
                  height: 60.0.h,
                ),
                child: Icon(Icons.check_rounded, color: ColorsTrueq.light, size: 32.sp),
              ),
            ],
          ),
          SizedBox(height: 30.h),
        ],
      ),
    );
  }
}
