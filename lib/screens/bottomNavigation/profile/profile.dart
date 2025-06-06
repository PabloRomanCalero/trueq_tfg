import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:path/path.dart' as p;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:trueq/screens/bottomNavigation/profile/edit_profile/edit_profile.dart';
import 'package:trueq/screens/bottomNavigation/profile/help/help.dart';
import 'package:trueq/screens/bottomNavigation/profile/my_products/my_products.dart';
import 'package:trueq/screens/bottomNavigation/profile/notifications.dart';
import 'package:trueq/utils/constants/image_strings.dart';
import 'package:trueq/utils/constants/text_strings.dart';
import '../../../utils/constants/colors.dart';
import '../../../utils/constants/sizes.dart';
import '../../../utils/helper_functions.dart';
import '../../login/login.dart';
import 'change_language.dart';
import '../../../main.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map<String, dynamic>? userData;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    final userResponse = await supabase
        .from('users')
        .select()
        .eq('id', user.id)
        .single();

    setState(() {
      userData = userResponse;
    });
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      await _addImageDatabase(image);
    }
  }

  Future<void> _takePhoto() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      await _addImageDatabase(image);
    }
  }

  Future<void> _addImageDatabase(XFile image) async {
    try {
      final userId = userData?['id'];
      final fileExtension = p.extension(image.name).toLowerCase();
      const allowedExtensions = ['.png', '.jpg', '.jpeg'];
      if (!allowedExtensions.contains(fileExtension)) {
        Get.snackbar(TextsTrueq.to.getText('error'), "${TextsTrueq.to.getText('invalidFileType')} (${allowedExtensions.join(', ')})", backgroundColor: Colors.red, colorText: Colors.white);
        return;
      }

      final storagePath = '$userId/avatar$fileExtension';
      final file = File(image.path);
      final storage = supabaseAdmin.storage.from('avatars');

      await storage.upload(
        storagePath,
        file,
        fileOptions: const FileOptions(upsert: true),
      );
      // Añadimos un timestamp para "cache busting" (evitar que el navegador muestre la imagen vieja)
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final publicUrl = '${storage.getPublicUrl(storagePath)}?t=$timestamp';

      await supabaseAdmin
          .from('users')
          .update({'avatar_url': publicUrl})
          .eq('id', userId);

      setState(() {
        if (userData != null) {
          userData!['avatar_url'] = publicUrl;
        }
      });
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
    } catch (e) {
      print('error ' + e.toString());
      Get.snackbar(TextsTrueq.to.getText('error'), TextsTrueq.to.getText('errorTryLater'), backgroundColor: Colors.red, colorText: Colors.white);
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
    }
  }

  Future<void> _deleteImage() async {
    try{
      await supabase
        .from('users')
        .update({'avatar_url': ImagesTrueq.defaultAvatar})
        .eq('id', userData?['id']);

      setState(() {
        userData?['avatar_url'] = ImagesTrueq.defaultAvatar;
      });

      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }

    }catch(e){
      Get.snackbar(TextsTrueq.to.getText('error'), TextsTrueq.to.getText('errorTryLater'), backgroundColor: Colors.red, colorText: Colors.white,);
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
    }
  }

  Future<void> _showImageOptions() async {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            _buildListTile(Icons.image_rounded, TextsTrueq.to.getText('libraryImage'), _pickImage, true),
            _buildListTile(Icons.photo_camera_rounded, TextsTrueq.to.getText('takePhoto'), _takePhoto, true),
            _buildListTile(Icons.delete_rounded, TextsTrueq.to.getText('deleteImage'), _deleteImage, true),
            _buildListTile(Icons.close_rounded, TextsTrueq.to.getText('cancel'), (){Navigator.pop(context);}, true),
            SizedBox(height: SizesTrueq.defaultSpace.h)
          ],
        ),
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    final dark = HelperFunctions.isDarkMode(context);
    return Scaffold(
      body: userData == null
        ? const Center(child: CircularProgressIndicator(color: ColorsTrueq.primary))
        : Column(
        children: [
          SizedBox(height: kBottomNavigationBarHeight.h),
          _buildProfileHeader(dark),
          Divider(color: ColorsTrueq.lightGrey),
          _buildSettingsSection(),
          SizedBox(height: SizesTrueq.spaceBtwSections.h),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(bool dark) {
    final createdAt = userData?['created_at'] != null
      ? DateTime.parse(userData?['created_at']).toLocal()
      : null;

    return Padding(
      padding: EdgeInsets.only(left: 18.w, right: 18.w, bottom: 12.h, top: 12.h),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () {_showImageOptions();},
                child: CircleAvatar(
                  radius: 50.r,
                  backgroundImage: CachedNetworkImageProvider(userData?['avatar_url']),
                  backgroundColor: Colors.transparent,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: Text(
                            userData!['username'] ?? TextsTrueq.to.getText('usernameNotAvailable'),
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                              color: dark ? ColorsTrueq.light : ColorsTrueq.dark,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        GestureDetector(
                          onTap: () async {
                            final response = await Get.to(() => EditProfile());
                            if(response == true){
                              await _loadProfile();
                            }
                          },
                          child: Icon(Icons.edit_rounded, color: ColorsTrueq.primary, size: 18.sp),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Icon(
                          Icons.person_rounded,
                          color: dark ? ColorsTrueq.lightGrey : ColorsTrueq.darkGrey,
                          size: 16.sp,
                        ),
                        SizedBox(width: 6.w),
                        Expanded(
                          child: Text(
                            '${userData!['first_name']} ${userData!['last_name'] ?? ''}',
                            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                              color: dark ? ColorsTrueq.lightGrey : ColorsTrueq.darkGrey
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
                          size: 16.sp,
                        ),
                        SizedBox(width: 6.w),
                        Expanded(
                          child: Text(
                            userData!['address'] ?? TextsTrueq.to.getText('locationNotAvailable'),
                            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                              color: dark ? ColorsTrueq.lightGrey : ColorsTrueq.darkGrey
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
                          size: 16.sp,
                        ),
                        SizedBox(width: 6.w),
                        Expanded(
                          child: Text(
                            '${TextsTrueq.to.getText('memberSince')}: ${createdAt?.day}/${createdAt?.month}/${createdAt?.year}',
                            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                              color: dark ? ColorsTrueq.lightGrey : ColorsTrueq.darkGrey
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Icon(Icons.swap_horiz_rounded, color: ColorsTrueq.primary, size: 16.sp,),
                        SizedBox(width: 6.w),
                        Text(
                          "${TextsTrueq.to.getText('exchanges')} ${userData!['num_intercambios']}",
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: dark ? ColorsTrueq.lightGrey : ColorsTrueq.dark, fontWeight: FontWeight.normal
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

  Widget _buildSettingsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildListTile(Icons.inventory_2_rounded, TextsTrueq.to.getText('myProducts'), (){
          Get.to(() => MyProducts());
        }),
        _buildListTile(Icons.language_rounded, TextsTrueq.to.getText('language'), (){
          Get.to(() => Changelanguage());
        }),
        _buildListTile(Icons.notifications_rounded, TextsTrueq.to.getText('notifications'), (){
          Get.to(() => NotificationsPage());
        }),
        _buildListTile(Icons.help_rounded, TextsTrueq.to.getText('help'), (){
          Get.to(() => HelpPage());
        }),
        _buildListTile(Icons.delete_rounded, TextsTrueq.to.getText('deleteAccount'), () async {
          _showDeleteConfirmationDialog();
        }),
        _buildListTile(Icons.logout_rounded, TextsTrueq.to.getText('logout'), () async {
          try{
            await supabase.auth.signOut();
            final storage = GetStorage();
            storage.write('remember', false);
            Get.snackbar(TextsTrueq.to.getText('logoutDone'), TextsTrueq.to.getText('logoutSuccess'), backgroundColor: ColorsTrueq.primary, colorText: Colors.white);
            Get.to(() => const LoginScreen());
          }catch (e) {
            Get.snackbar(TextsTrueq.to.getText('error'), TextsTrueq.to.getText('errorTryLater'), backgroundColor: Colors.red, colorText: ColorsTrueq.light);
          }
        }),
      ],
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

  Future<void> _deleteAcount() async{
    try{
      final user = supabase.auth.currentUser;
      await supabaseAdmin.auth.admin.deleteUser(user!.id);
      await supabase.auth.signOut();
      final storage = GetStorage();
      storage.write('remember', false);
      Get.snackbar(TextsTrueq.to.getText('accountDeleted'), TextsTrueq.to.getText('accountDeletedSuccess'), backgroundColor: ColorsTrueq.primary, colorText: Colors.white);
      Get.to(() => const LoginScreen());
    }catch (e){
      Get.snackbar(TextsTrueq.to.getText('error'), TextsTrueq.to.getText('errorTryLater'), backgroundColor: Colors.red, colorText: ColorsTrueq.light);
    }
  }

  void _showDeleteConfirmationDialog() {
    final dark = HelperFunctions.isDarkMode(context);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(TextsTrueq.to.getText('confirmDeleteUser')),
          content: Text(TextsTrueq.to.getText('confirmDeleteMessageUser')),
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
                if(Navigator.canPop(context)){
                  Navigator.pop(context);
                }
                await _deleteAcount();
              },
              child: Text(
                TextsTrueq.to.getText('delete'),
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }
}
