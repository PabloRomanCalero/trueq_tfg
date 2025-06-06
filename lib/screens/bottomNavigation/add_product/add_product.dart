import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:trueq/main.dart';
import 'package:trueq/utils/constants/colors.dart';
import 'package:trueq/utils/constants/sizes.dart';
import 'dart:io';

import '../../../utils/constants/text_strings.dart';

class AddProductPage extends StatefulWidget {
  final String title;
  final Map<String, dynamic>? product;
  const AddProductPage({super.key, required this.title, this.product});

  @override
  State<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  XFile? _profileImage;
  File? _profileImagePreview;
  String? _selectedCategory;
  int _charCountTitle = 0;
  int _charCountDescription = 0;
  CategoryItem? _selectedCategoryItem;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _titleController.text = widget.title;
    if(widget.product != null){
      _descriptionController.text = widget.product?['description'];
      _charCountDescription = _descriptionController.text.length;
    }
    _charCountTitle = widget.title.length;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  final List<CategoryItem> _categories = [
    CategoryItem(TextsTrueq.to.getText('categoryElectronics'), Icons.devices_other_rounded, 'Electrónica'),
    CategoryItem(TextsTrueq.to.getText('categoryFashion'), Icons.checkroom_rounded, 'Moda'),
    CategoryItem(TextsTrueq.to.getText('categoryHome'), Icons.chair_rounded, 'Hogar'),
    CategoryItem(TextsTrueq.to.getText('categorySports'), Icons.sports_soccer_rounded, 'Deportes'),
    CategoryItem(TextsTrueq.to.getText('categoryToys'), Icons.toys_rounded, 'Juguetes'),
    CategoryItem(TextsTrueq.to.getText('categoryOthers'), Icons.category_rounded, 'Otros'),
  ];

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

  Future<void> _showImageOptions() async {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            _buildListTile(Icons.image_rounded, TextsTrueq.to.getText('libraryImage'), _pickImage, true),
            _buildListTile(Icons.photo_camera_rounded, TextsTrueq.to.getText('takePhoto'), _takePhoto, true),
            _buildListTile(Icons.close_rounded, TextsTrueq.to.getText('cancel'), (){Navigator.pop(context);}, true),
            SizedBox(height: SizesTrueq.defaultSpace.h)
          ],
        ),
      ));
  }

  Future<void> _addProductDatabase(XFile ?image) async {
    setState(() {
      _isUploading = true;
    });
    try {
      if(image != null) {
        final userId = supabase.auth.currentUser?.id;
        if (userId == null) {
          return;
        }
        final fileExtension = p.extension(image.name).toLowerCase();
        const allowedExtensions = ['.png', '.jpg', '.jpeg'];
        if (!allowedExtensions.contains(fileExtension)) {
          Get.snackbar(TextsTrueq.to.getText('error'),
              "${TextsTrueq.to.getText('invalidFileType')} (${allowedExtensions
                  .join(', ')})", backgroundColor: Colors.red,
              colorText: ColorsTrueq.light);
          return;
        }
        final timestamp = DateTime.now().millisecondsSinceEpoch;

        var storagePath = '';
        if(widget.product != null){
          final fileName = '${widget.product?['id']}${p.extension(image.name)}';
          storagePath = '$userId/$fileName';
        }
        final file = File(image.path);
        final storage = supabaseAdmin.storage.from('products');

        if(widget.product != null){
          await storage.upload(
            storagePath,
            file,
            fileOptions: const FileOptions(upsert: true),
          );
        }
        // Añadimos un timestamp para "cache busting" (evitar que el navegador muestre la imagen vieja)

        final publicUrl = '${storage.getPublicUrl(storagePath)}?t=$timestamp';

        if(widget.product == null){
          final product = await supabaseAdmin
            .from('products')
            .insert({
              'user_id': userId,
              'title': cleanText(_titleController.text),
              'description': cleanText(_descriptionController.text),
              'category': _selectedCategory ?? 'Otros',
              'image_url': '',
            }).select('id').single();

          final fileName = '${product['id']}${p.extension(image.name)}';
          storagePath = '$userId/$fileName';
          await storage.upload(
            storagePath,
            file,
            fileOptions: const FileOptions(upsert: true),
          );

          final newPublicUrl = '${storage.getPublicUrl(storagePath)}?t=$timestamp';
          await supabaseAdmin
            .from('products')
            .update({'image_url': newPublicUrl,})
            .eq('id', product['id']);

        } else {
          await supabaseAdmin
            .from('products')
            .update({
              'title': _titleController.text,
              'description': _descriptionController.text,
              'category': _selectedCategory ?? 'Otros',
              'image_url': publicUrl,
            }).eq('id', widget.product?['id']);
        }
      } else {
        await supabaseAdmin
          .from('products')
          .update({
            'title': _titleController.text,
            'description': _descriptionController.text,
            'category': _selectedCategory ?? 'Otros',
          }).eq('id', widget.product?['id']);
      }


      setState(() {
        _titleController.clear();
        _descriptionController.clear();
        _profileImage = null;
        _profileImagePreview = null;
        _selectedCategory = null;
        _selectedCategoryItem = null;
      });

    } catch (e) {
      print('error $e');
      Get.snackbar(TextsTrueq.to.getText('error'), TextsTrueq.to.getText('errorTryLater'), backgroundColor: Colors.red, colorText: ColorsTrueq.light);
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  CategoryItem? getInitialCategoryItem() {
    if (widget.product != null) {
      return _categories.firstWhere(
          (category) => category.esName == widget.product?['category'], orElse: () => _categories.first,
      );
    }
    return null;
  }

  String cleanText(String text) {
    return text.replaceAll(RegExp(r'\s+'), ' ').trim(); //Elimina los saltos de linea y espacios de inicio y final
  }

  Widget _buildListTile(IconData icon, String title, VoidCallback onTap, [bool hideIcon = false]) {
    return ListTile(
      leading: Icon(icon, color: ColorsTrueq.primary, size: 24.sp,),
      title: Text(
        title,
        style: TextStyle(fontSize: 15.sp),
      ),
      trailing: hideIcon ? null : Icon(Icons.chevron_right_rounded, color: Colors.grey),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(left: SizesTrueq.defaultSpace.w, right: SizesTrueq.defaultSpace.w, top: SizesTrueq.defaultSpace.h),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: _showImageOptions,
                child: Container(
                  height: 180.h,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: ColorsTrueq.noImageGrey,
                    borderRadius: BorderRadius.circular(SizesTrueq.inputFieldRadius),
                    image: _profileImage != null
                      ? DecorationImage(
                        image: FileImage(_profileImagePreview!),
                        fit: BoxFit.cover,
                      ) : widget.product != null
                        ? DecorationImage(
                          image: CachedNetworkImageProvider(widget.product?['image_url'] ?? ''),
                          fit: BoxFit.cover,
                        ) : null,
                  ),
                  child: _profileImagePreview == null && widget.product == null
                    ? Center(
                    child: Icon(Icons.add_a_photo_rounded, size: 40.sp, color: ColorsTrueq.darkGrey),
                  ) : null,
                ),
              ),
              SizedBox(height: SizesTrueq.spaceBtwItems.h),
              CustomDropdown<CategoryItem>.search(
                hintText: TextsTrueq.to.getText('selectCategory'),
                items: _categories,
                initialItem: getInitialCategoryItem(),
                excludeSelected: true,
                onChanged: (value) {
                  setState(() {
                    _selectedCategoryItem = value;
                    _selectedCategory = value?.esName;
                  });
                },
                listItemBuilder: (context, item, isSelected, onItemSelect) {
                  return ListTile(
                    dense: true,
                    visualDensity: VisualDensity.compact,
                    contentPadding: EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                    leading: Icon(item.icon, color: ColorsTrueq.dark, size: 24.sp),
                    title: Text(item.name, style: TextStyle(color: ColorsTrueq.dark, fontSize: 15.sp)),
                    onTap: onItemSelect,
                  );
                },
                decoration: CustomDropdownDecoration(
                  closedBorder: Border.all(color: ColorsTrueq.inputBorderDefault),
                  expandedBorder: Border.all(color: ColorsTrueq.primary, width: 2.w),
                  closedBorderRadius: BorderRadius.circular(SizesTrueq.inputFieldRadius),
                  expandedBorderRadius: BorderRadius.circular(SizesTrueq.inputFieldRadius),
                  prefixIcon: Icon(Icons.category_rounded, color: ColorsTrueq.dark, size: 24.sp),
                  closedSuffixIcon: Icon(Icons.arrow_drop_down_rounded, color: ColorsTrueq.dark, size: 24.sp),
                  expandedSuffixIcon: Icon(Icons.arrow_drop_up_rounded, color: ColorsTrueq.dark, size: 24.sp),
                  headerStyle: TextStyle(
                    color: ColorsTrueq.dark,
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w500
                  ),
                ),
              ),
              SizedBox(height: SizesTrueq.defaultSpace.h),
              TextFormField(
                controller: _titleController,
                maxLength: 40,
                decoration: InputDecoration(
                  floatingLabelStyle: TextStyle(color: ColorsTrueq.primary),
                  counterText: "$_charCountTitle/40",
                  labelText: TextsTrueq.to.getText('productTitle'),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(SizesTrueq.inputFieldRadius),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(SizesTrueq.inputFieldRadius),
                    borderSide: BorderSide(
                      color: ColorsTrueq.primary,
                      width: 2.0.w,
                    ),
                  ),
                ),
                onChanged: (text) {
                  setState(() {
                    _charCountTitle = text.length;
                  });
                },
                validator: (value) => value == null || value.isEmpty ? TextsTrueq.to.getText('validatorTitle') : null,
              ),
              SizedBox(height: SizesTrueq.spaceBtwInputFields.h),
              TextFormField(
                controller: _descriptionController,
                maxLength: 150,
                maxLines: 4,
                decoration: InputDecoration(
                  floatingLabelStyle: TextStyle(color: ColorsTrueq.primary),
                  counterText: "$_charCountDescription/150",
                  labelText: TextsTrueq.to.getText('productDescription'),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(SizesTrueq.inputFieldRadius),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(SizesTrueq.inputFieldRadius),
                    borderSide: BorderSide(
                      color: ColorsTrueq.primary,
                      width: 2.0.w,
                    ),
                  ),
                ),
                onChanged: (text) {
                  setState(() {
                    _charCountDescription = text.length;
                  });
                },
              ),
              SizedBox(height: SizesTrueq.spaceBtwItems.h),
              SizedBox(
                width: double.infinity,
                height: 50.h,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorsTrueq.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(SizesTrueq.inputFieldRadius),
                    ),
                  ),
                  icon: _isUploading ? SizedBox(
                    height: 18.h,
                    width: 18.w,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.w,
                      color: ColorsTrueq.light,
                    ),
                  ) : null,
                  onPressed: _isUploading ? null : () async {
                    if (_formKey.currentState!.validate()) {
                      try {
                        if (widget.product != null) {
                          await _addProductDatabase(_profileImage);
                          Get.back(result: true);
                        } else {
                          if (_profileImage != null) {
                            await _addProductDatabase(_profileImage!);
                            Get.back(result: true);
                          } else {
                            Get.snackbar(TextsTrueq.to.getText('error'),
                              TextsTrueq.to.getText('imageRequired'),
                              backgroundColor: Colors.red,
                              colorText: ColorsTrueq.light);
                          }
                        }
                      } catch (e) {
                        Get.snackbar(TextsTrueq.to.getText('error'),
                          TextsTrueq.to.getText('errorTryLater'),
                          backgroundColor: Colors.red,
                          colorText: ColorsTrueq.light);
                      }
                    }
                  },
                  label: Text(
                    widget.product == null ? TextsTrueq.to.getText('post') : TextsTrueq.to.getText('saveChanges'),
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: ColorsTrueq.light,
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

class CategoryItem with CustomDropdownListFilter {
  final String name;
  final IconData icon;
  final String esName;

  const CategoryItem(this.name, this.icon, this.esName);

  @override
  String toString() {
    return name;
  }

  @override
  bool filter(String query) {
    return name.toLowerCase().contains(query.toLowerCase());
  }
}
