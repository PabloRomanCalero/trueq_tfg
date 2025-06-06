import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:trueq/screens/bottomNavigation/profile/my_products/product.dart';
import '../../../../main.dart';
import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/sizes.dart';
import '../../../../utils/constants/text_strings.dart';
import '../../../../utils/helper_functions.dart';

class OtherProfile extends StatefulWidget {
  final String userId;

  const OtherProfile({super.key, required this.userId});

  @override
  State<OtherProfile> createState() => _OtherProfileState();
}

class _OtherProfileState extends State<OtherProfile> {
  Map<String, dynamic>? userData;
  List<dynamic> products = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUser();
    _loadProducts();
  }

  Future<void> _loadUser() async {
    final userResponse = await supabase
      .from('users')
      .select()
      .eq('id', widget.userId)
      .single();

    setState(() {
      userData = userResponse;
    });
  }

  Future<void> _loadProducts() async {
    setState(() => _isLoading = true);

    final productResponse = await supabase
        .from('products')
        .select()
        .eq('user_id', widget.userId)
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
      body: userData == null
        ? const Center(child: CircularProgressIndicator(color: ColorsTrueq.primary))
        : CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            title: Text(
              userData!['username'],
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SliverFillRemaining(
            child: Column(
              children: [
                _buildProfileHeader(dark),
                Divider(color: ColorsTrueq.lightGrey,),
                Expanded(
                  child: _isLoading ? const Center(child: CircularProgressIndicator(color: ColorsTrueq.primary))
                  : products.isEmpty ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.inventory_2_outlined,
                          size: 60.sp,
                          color: ColorsTrueq.primary
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          TextsTrueq.to.getText('noFavorites'),
                          style: TextStyle(
                            fontSize: 16.sp,
                            color: dark ? ColorsTrueq.lightGrey : ColorsTrueq.darkGrey,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ) : GridView.builder(
                    padding: EdgeInsets.only(left: 12.w, right: 12.w, bottom: SizesTrueq.defaultSpace.h),
                    gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.75,
                    ),
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final product = products[index];
                      final available = product['status'] == 'available';

                      return GestureDetector(
                        onTap: available ? () => Get.to(() => ProductPage(product: product, otherProfile: true)) : null,
                        child: Stack(
                          children: [
                            Opacity(
                              opacity: available ? 1.0 : 0.5,
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
                                          top: Radius.circular(SizesTrueq.inputFieldRadius),
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
                                            maxLines: 2,
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
                                  color: available ? ColorsTrueq.primary : ColorsTrueq.darkGrey,
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(SizesTrueq.inputFieldRadius),
                                    bottomRight: Radius.circular(SizesTrueq.inputFieldRadius),
                                  ),
                                ),
                                child: Text(
                                  available ? TextsTrueq.to.getText('available') : TextsTrueq.to.getText('interchanged'),
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
                    }
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(bool dark) {
    final createdAt = userData?['created_at'] != null
      ? DateTime.parse(userData?['created_at']).toLocal()
      : null;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 12.h),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 50.r,
                backgroundImage: CachedNetworkImageProvider(userData?['avatar_url']),
                backgroundColor: Colors.transparent,
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.person_rounded,
                          color: dark ? ColorsTrueq.lightGrey : ColorsTrueq.darkGrey,
                          size: 16.sp
                        ),
                        SizedBox(width: 6.w),
                        Expanded(
                          child: Text(
                            '${userData!['first_name']} ${userData!['last_name'] ?? ''}',
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: dark ? ColorsTrueq.lightGrey : ColorsTrueq.darkGrey,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          color: dark ? ColorsTrueq.lightGrey : ColorsTrueq.darkGrey,
                          size: 16.sp
                        ),
                        SizedBox(width: 6.w),
                        Expanded(
                          child: Text(
                            userData!['address'] ?? TextsTrueq.to.getText('locationNotAvailable'),
                            style: TextStyle(
                              color: dark ? ColorsTrueq.lightGrey : ColorsTrueq.darkGrey,
                              fontSize: 14.sp,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_month_rounded,
                          color: dark ? ColorsTrueq.lightGrey : ColorsTrueq.darkGrey,
                          size: 16.sp
                        ),
                        SizedBox(width: 6.sp),
                        Expanded(
                          child: Text(
                            '${TextsTrueq.to.getText('memberSince')}: ${createdAt?.day}/${createdAt?.month}/${createdAt?.year}',
                            style: TextStyle(
                              color: dark ? ColorsTrueq.lightGrey : ColorsTrueq.darkGrey,
                              fontSize: 14.sp,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Icon(
                          Icons.swap_horiz_rounded,
                          color: ColorsTrueq.primary,
                          size: 16.sp
                        ),
                        SizedBox(width: 6.w),
                        Text(
                          "${TextsTrueq.to.getText('exchanges')} ${userData!['num_intercambios']}",
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: dark ? ColorsTrueq.light : ColorsTrueq.dark,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
