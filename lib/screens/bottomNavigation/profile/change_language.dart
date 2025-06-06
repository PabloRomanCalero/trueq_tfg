import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:country_flags/country_flags.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_storage/get_storage.dart';
import 'package:trueq/utils/constants/colors.dart';
import 'package:trueq/utils/constants/text_strings.dart';

import '../../../utils/constants/sizes.dart';

class Changelanguage extends StatefulWidget {
  const Changelanguage({super.key});

  @override
  State<Changelanguage> createState() => _ChangeLanguageState();
}

class _ChangeLanguageState extends State<Changelanguage> {
  String _selectedLanguage = GetStorage().read('language') ?? 'es';
  final Map<String, String> _languageMap = {
    'Español': 'es',
    'English': 'en',
  };
  final List<Languages> _languages = [
    Languages('Español', 'es'),
    Languages('English', 'en'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          TextsTrueq.to.getText('language'),
          style: TextStyle(
            fontSize: 22.sp,
            fontWeight: FontWeight.bold
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(SizesTrueq.defaultSpace.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              TextsTrueq.to.getText('changeLanguage'),
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            SizedBox(height: SizesTrueq.spaceBtwItems.h),
            CustomDropdown<Languages>(
              items: _languages,
              excludeSelected: true,
              initialItem: _languages.firstWhere((language) => language.icon == _selectedLanguage, orElse: () => _languages[0],
              ),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedLanguage = _languageMap[value.name]!;
                  });
                  _changeLanguage(_languageMap[value.name]!);
                }
              },
              listItemBuilder: (context, item, isSelected, onItemSelect) {
                return ListTile(
                  dense: true,
                  visualDensity: VisualDensity.compact,
                  contentPadding: EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                  leading: CountryFlag.fromLanguageCode(item.icon, shape: const Circle(), width: 35.w),
                  title: Text(item.name, style: TextStyle(color: ColorsTrueq.dark, fontSize: 15.sp)),
                  onTap: onItemSelect,
                );
              },
              decoration: CustomDropdownDecoration(
                closedBorder: Border.all(color: ColorsTrueq.inputBorderDefault),
                expandedBorder: Border.all(color: ColorsTrueq.primary, width: 2.w),
                closedBorderRadius: BorderRadius.circular(SizesTrueq.inputFieldRadius),
                expandedBorderRadius: BorderRadius.circular(SizesTrueq.inputFieldRadius),
                prefixIcon: CountryFlag.fromLanguageCode(
                    _selectedLanguage, shape: const Circle(), width: 35.w,
                ),
                closedSuffixIcon: Icon(Icons.arrow_drop_down_rounded, color: ColorsTrueq.dark, size: 24.sp),
                expandedSuffixIcon: Icon(Icons.arrow_drop_up_rounded, color: ColorsTrueq.dark, size: 24.sp),
                headerStyle: TextStyle(
                    color: ColorsTrueq.dark,
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w500
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _changeLanguage(String languageCode) async {
    TextsTrueq.to.changeLanguage(languageCode);
    GetStorage().write('language', languageCode);
  }
}

class Languages with CustomDropdownListFilter {
  final String name;
  final String icon;

  const Languages(this.name, this.icon);

  @override
  String toString() {
    return name;
  }

  @override
  bool filter(String query) {
    return name.toLowerCase().contains(query.toLowerCase());
  }
}
