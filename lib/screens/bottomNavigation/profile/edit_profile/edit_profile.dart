import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:trueq/utils/constants/colors.dart';
import 'package:trueq/utils/constants/sizes.dart';
import 'package:trueq/utils/constants/text_strings.dart';

import '../../../../main.dart';
import 'location.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({super.key});

  @override
  State<EditProfile> createState() => _EditProfileState();
}
//Hacer que si cambio la imagen que devuelva a la pagina anterior un bool para que recargue en el profile la imagen. Para que cambie en la UI.
class _EditProfileState extends State<EditProfile> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();

  Map<String, dynamic>? userData;
  final _formKey = GlobalKey<FormState>();

  XFile? _profileImage;
  File? _profileImagePreview;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _locationController.dispose();
    _usernameController.dispose();
    super.dispose();
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
      _firstNameController.text = userData?['first_name'] ?? '';
      _lastNameController.text = userData?['last_name'] ?? '';
      _locationController.text = userData?['address'] ?? '';
      _usernameController.text = userData?['username'] ?? '';

    });
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _profileImage = image;
        _profileImagePreview = File(image.path);
      });
      if(Navigator.canPop(context)){
        Navigator.pop(context);
      }
    }
  }

  Future<void> _takePhoto() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      setState(() {
        _profileImage = image;
        _profileImagePreview = File(image.path);
      });
      if(Navigator.canPop(context)){
        Navigator.pop(context);
      }
    }
  }

  Future<void> _addImageDatabase(XFile image) async {
    try {
      final userId = userData?['id'];
      final fileExtension = p.extension(image.name).toLowerCase();
      const allowedExtensions = ['.png', '.jpg', '.jpeg'];
      if (!allowedExtensions.contains(fileExtension)) {
        Get.snackbar(TextsTrueq.to.getText('error'), "${TextsTrueq.to.getText('invalidFileType')} (${allowedExtensions.join(', ')})", backgroundColor: Colors.red, colorText: ColorsTrueq.light);
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

    } catch (e) {
      print('error ' + e.toString());
      Get.snackbar(TextsTrueq.to.getText('error'), TextsTrueq.to.getText('errorTryLater'), backgroundColor: Colors.red, colorText: ColorsTrueq.light);
    }
  }

  Future<void> _deleteImage() async {
    try{
      setState(() {
        _profileImage = null;
        _profileImagePreview = null;
      });
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
    }catch(e){
      Get.snackbar(TextsTrueq.to.getText('error'), TextsTrueq.to.getText('errorTryLater'), backgroundColor: Colors.red, colorText: ColorsTrueq.light);
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
              _buildListTile(Icons.image, TextsTrueq.to.getText('libraryImage'), _pickImage, true),
              _buildListTile(Icons.photo_camera, TextsTrueq.to.getText('takePhoto'), _takePhoto, true),
              _buildListTile(Icons.delete, TextsTrueq.to.getText('deleteImage'), _deleteImage, true),
              _buildListTile(Icons.close_rounded, TextsTrueq.to.getText('cancel'), (){Navigator.pop(context);}, true),
              SizedBox(height: SizesTrueq.defaultSpace.h)
            ],
          ),
        ));
  }

  Widget _buildListTile(IconData icon, String title, VoidCallback onTap, [bool hideIcon = false]) {
    return ListTile(
      leading: Icon(icon, color: ColorsTrueq.primary),
      title: Text(
        title,
        style: TextStyle(fontSize: 15.sp),
      ),
      trailing: hideIcon ? null : Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          TextsTrueq.to.getText('editProfile'),
          style: TextStyle(
              fontSize: 22.sp,
              fontWeight: FontWeight.bold
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(SizesTrueq.defaultSpace.r),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              GestureDetector(
                onTap: _showImageOptions,
                child: CircleAvatar(
                  radius: 50.r,
                  backgroundColor: ColorsTrueq.noImageGrey,
                  backgroundImage: _profileImage != null ? FileImage(_profileImagePreview!) : null,
                  child: _profileImage == null
                    ? Icon(Icons.add_a_photo_rounded, size: 40.sp, color: ColorsTrueq.darkGrey)
                    : null,
                ),
              ),
              SizedBox(height: SizesTrueq.spaceBtwSections.h),
              TextFormField(
                controller: _firstNameController,
                decoration: InputDecoration(
                  labelText: TextsTrueq.to.getText('firstName'),
                  floatingLabelStyle: TextStyle(color: ColorsTrueq.primary),
                  prefixIcon: Icon(Icons.person_rounded, size: 24.sp,),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(SizesTrueq.inputFieldRadius)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(SizesTrueq.inputFieldRadius),
                    borderSide: BorderSide(
                      color: ColorsTrueq.primary,
                      width: 2.0.w,
                    ),
                  ),
                ),
                validator: (value) => value!.isEmpty ? TextsTrueq.to.getText('validatorFirstName') : null,
              ),
              SizedBox(height: SizesTrueq.spaceBtwInputFields.h),
              TextFormField(
                controller: _lastNameController,
                decoration: InputDecoration(
                  labelText: TextsTrueq.to.getText('lastName'),
                  floatingLabelStyle: TextStyle(color: ColorsTrueq.primary),
                  prefixIcon: Icon(Icons.person_rounded, size: 24.sp,),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(SizesTrueq.inputFieldRadius)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(SizesTrueq.inputFieldRadius),
                    borderSide: BorderSide(
                      color: ColorsTrueq.primary,
                      width: 2.0.w,
                    ),
                  ),
                ),
                validator: (value) => value!.isEmpty ? TextsTrueq.to.getText('validatorLastName') : null,
              ),
              SizedBox(height: SizesTrueq.spaceBtwInputFields.h),
              TextFormField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: TextsTrueq.to.getText('username'),
                  floatingLabelStyle: TextStyle(color: ColorsTrueq.primary),
                  prefixIcon: Icon(Icons.account_circle_rounded, size: 24.sp,),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(SizesTrueq.inputFieldRadius)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(SizesTrueq.inputFieldRadius),
                    borderSide: BorderSide(
                      color: ColorsTrueq.primary,
                      width: 2.0.w,
                    ),
                  ),
                ),
                validator: (value) => value!.isEmpty ? TextsTrueq.to.getText('validatorUsername') : null,
              ),
              SizedBox(height: SizesTrueq.spaceBtwInputFields.h),
              GestureDetector(
                child: TextFormField(
                  controller: _locationController,
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: TextsTrueq.to.getText('location'),
                    floatingLabelStyle: TextStyle(color: ColorsTrueq.primary),
                    prefixIcon: Icon(Icons.location_on_rounded, size: 24.sp,),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(SizesTrueq.inputFieldRadius)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(SizesTrueq.inputFieldRadius),
                      borderSide: BorderSide(
                        color: ColorsTrueq.primary,
                        width: 2.0.w,
                      ),
                    ),
                    suffixIcon: _locationController.text.isNotEmpty
                      ? GestureDetector(
                        onTap: () {
                          setState(() {
                            _locationController.clear();
                          });
                        },
                        child: Icon(Icons.clear_rounded, size: 24.sp,),
                      ) : null,
                  ),
                  onTap: () async {
                    if (_locationController.text.isEmpty) {
                      final result = await Get.to(() => LocationScreen());
                      if (result != null) {
                        setState(() {
                          _locationController.text = result;
                        });
                      }
                    }
                  },
                )
              ),

              SizedBox(height: SizesTrueq.spaceBtwSections.h),
              SizedBox(
                width: double.infinity,
                height: 50.h,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorsTrueq.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(SizesTrueq.inputFieldRadius),
                    ),
                  ),
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      try{
                        await supabaseAdmin
                            .from('users')
                            .update({
                              'first_name': _firstNameController.text.trim(),
                              'last_name': _lastNameController.text.trim(),
                              'username': _usernameController.text.trim(),
                              'address': _locationController.text == '' ? null : _locationController.text,
                            })
                            .eq('id', userData?['id']);
                        if(_profileImagePreview != null){
                          await _addImageDatabase(_profileImage!);
                        }
                        Get.back(result: true);
                        Get.snackbar(TextsTrueq.to.getText('success'), TextsTrueq.to.getText('changesSaved'), backgroundColor: ColorsTrueq.primary, colorText: ColorsTrueq.light);
                      } catch(e){
                        print('error' + e.toString());
                        Get.snackbar(TextsTrueq.to.getText('error'), TextsTrueq.to.getText('errorTryLater'), backgroundColor: Colors.red, colorText: ColorsTrueq.light);
                      }
                    }
                  },
                  child: Text(
                    TextsTrueq.to.getText('saveChanges'),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: ColorsTrueq.light, fontWeight: FontWeight.bold
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
