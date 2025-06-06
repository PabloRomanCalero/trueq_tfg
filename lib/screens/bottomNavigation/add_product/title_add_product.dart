import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:trueq/utils/constants/colors.dart';
import 'package:trueq/utils/constants/image_strings.dart';

import '../../../utils/constants/sizes.dart';
import '../../../utils/constants/text_strings.dart';
import 'add_product.dart';

class TitleAddProduct extends StatefulWidget {
  const TitleAddProduct({super.key});

  @override
  State<TitleAddProduct> createState() => _TitleAddProductState();
}

class _TitleAddProductState extends State<TitleAddProduct> {
  final TextEditingController _titleController = TextEditingController();
  int _charCount = 0;
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: EdgeInsets.only(
          left: SizesTrueq.defaultSpace.w,
          right: SizesTrueq.defaultSpace.w,
          top: 56.h + SizesTrueq.defaultSpace.h,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image(
                width: MediaQuery.of(context).size.width * 0.9.w,
                height: MediaQuery.of(context).size.width * 0.7.h,
                image: AssetImage(ImagesTrueq.addProductImage),
              ),
              SizedBox(height: SizesTrueq.spaceBtwSections.h),
              Center(
                child: Text(
                  textAlign: TextAlign.center,
                  TextsTrueq.to.getText('titleAddTitleProduct'),
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: SizesTrueq.spaceBtwItems.h),
              Text(
                TextsTrueq.to.getText('subtitleAddTitleProduct'),
                style: TextStyle(
                  fontSize: 15.sp,
                ),
              ),
              SizedBox(height: SizesTrueq.spaceBtwSections.h),
              TextFormField(
                controller: _titleController,
                maxLength: 40,
                decoration: InputDecoration(
                  hintText: TextsTrueq.to.getText('exampleTitle'),
                  counterText: "$_charCount/40",
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
                validator: (value) =>
                value == null || value.isEmpty ? TextsTrueq.to.getText('validatorTitle') : null,
                onChanged: (text) {
                  setState(() {
                    _charCount = text.length;
                  });
                },
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
                    FocusScope.of(context).unfocus();
                    if (_formKey.currentState!.validate()) {
                      final response = await Get.to(() => AddProductPage(title: _titleController.text, product: null,));
                      if (response == true) {
                        Get.snackbar(
                          TextsTrueq.to.getText('success'),
                          TextsTrueq.to.getText('productAddedSuccessfully'),
                          backgroundColor: ColorsTrueq.primary,
                          colorText: ColorsTrueq.light,
                        );
                        setState(() {
                          _titleController.clear();
                          _charCount = 0;
                        });
                      }
                    }
                  },
                  child: Text(
                    TextsTrueq.to.getText('continue'),
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
    );
  }
}
