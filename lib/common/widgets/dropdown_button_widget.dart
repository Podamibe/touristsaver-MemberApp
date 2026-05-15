import 'package:auto_size_text/auto_size_text.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../constants/global_colors.dart';
import '../../constants/style.dart';
import 'package:new_piiink/generated/l10n.dart';

class DropdownButtonWidget extends StatelessWidget {
  const DropdownButtonWidget({
    super.key,
    required this.label,
    required this.searchController,
    this.items,
    this.onChanged,
    this.value,
    this.dropWidth,
    this.lPadding,
    this.iHeight,
    this.dropHeight,
    this.isExpanded,
    this.bWidth,
    this.searchHeight,
    this.selectedItemBuilder,
    this.fillColor,
    this.borderColor,
    this.borderRadius,
    this.iconColor,
    this.hintStyle,
    this.height,
    this.buttonHeight,
    this.buttonPadding,
  });

  final String label;
  final TextEditingController searchController;
  final List<DropdownMenuItem<Object>>? items;
  final void Function(Object?)? onChanged;
  final Object? value;
  final double? dropWidth;
  final double? lPadding;
  final double? iHeight;
  final double? dropHeight;
  final double? searchHeight;
  final double? bWidth;
  final bool? isExpanded;
  final DropdownButtonBuilder? selectedItemBuilder;
  final Color? fillColor;
  final Color? borderColor;
  final double? borderRadius;
  final Color? iconColor;
  final TextStyle? hintStyle;
  final double? height;
  final double? buttonHeight;
  final EdgeInsetsGeometry? buttonPadding;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height ?? 55,
      width: bWidth ?? MediaQuery.of(context).size.width / 1.2,
      decoration: BoxDecoration(
        color: fillColor ?? GlobalColors.paleGray,
        borderRadius: BorderRadius.circular(borderRadius ?? 5.0),
        border: borderColor == null ? null : Border.all(color: borderColor!),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton2<Object>(
          isExpanded: true,
          hint: Padding(
            padding: EdgeInsets.only(left: lPadding ?? 25),
            child: AutoSizeText(
              label,
              style: hintStyle ??
                  dopdownTextStyle.copyWith(
                      color: GlobalColors.gray.withValues(alpha: 0.8)),
            ),
          ),
          buttonStyleData: ButtonStyleData(
            padding:
                buttonPadding ?? const EdgeInsets.symmetric(horizontal: 10),
            height: buttonHeight ?? 55,
            width: bWidth ?? 250,
          ),
          dropdownStyleData: DropdownStyleData(
            maxHeight: dropHeight ?? MediaQuery.of(context).size.height * 0.4,
            width: dropWidth ?? MediaQuery.of(context).size.width / 1.2,
            decoration: BoxDecoration(
              color: fillColor ?? GlobalColors.paleGray,
              borderRadius: BorderRadius.circular(borderRadius ?? 5.0),
            ),
          ),
          menuItemStyleData: MenuItemStyleData(
            height: iHeight ?? kMinInteractiveDimension,
          ),
          iconStyleData: IconStyleData(
            icon: Padding(
              padding: EdgeInsets.only(right: lPadding ?? 25),
              child: Icon(
                Icons.expand_more,
                color: iconColor ?? GlobalColors.appColor,
              ),
            ),
            openMenuIcon: Padding(
              padding: EdgeInsets.only(right: lPadding ?? 25),
              child: Icon(
                Icons.expand_less,
                color: iconColor ?? GlobalColors.appColor,
              ),
            ),
          ),
          dropdownSearchData: DropdownSearchData(
            searchController: searchController,
            searchInnerWidgetHeight: 30,
            searchInnerWidget: Padding(
              padding: const EdgeInsets.only(
                top: 8,
                bottom: 4,
                right: 8,
                left: 8,
              ),
              child: SizedBox(
                height: searchHeight,
                child: TextFormField(
                  controller: searchController,
                  decoration: textInputDecoration1.copyWith(
                    hintText: S.of(context).search,
                    fillColor: GlobalColors.paleGray,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                      borderSide: const BorderSide(
                        width: 2,
                        color: GlobalColors.appGreyBackgroundColor,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                      borderSide: BorderSide(
                        width: 2,
                        color: Colors.grey.shade300,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            searchMatchFn: (item, searchValue) {
              return item.value
                  .toString()
                  .toLowerCase()
                  .contains(searchValue.toLowerCase());
            },
          ),
          onMenuStateChange: (isOpen) => searchController.clear(),
          items: items,
          onChanged: onChanged,
          value: value,
          selectedItemBuilder: selectedItemBuilder,
        ),
      ),
    );
  }
}
// searchMatchFn: (item, searchValue) {
//   return item.value
//       .toString()
//       .toLowerCase()
//       .contains(searchValue.toLowerCase());
// },
// itemHeight: iHeight ?? kMinInteractiveDimension,
// dropdownMaxHeight:
//     dropHeight ?? MediaQuery.of(context).size.height * 0.4,
// dropdownWidth: dropWidth ?? MediaQuery.of(context).size.width / 1.2,
// icon: Padding(
//   padding: EdgeInsets.only(right: lPadding ?? 25),
//   child: const Icon(
//     Icons.expand_more,
//     color: GlobalColors.appColor,
//   ),
// ),
// iconOnClick: Padding(
//   padding: EdgeInsets.only(right: lPadding ?? 25),
//   child: const Icon(
//     Icons.expand_less,
//     color: GlobalColors.appColor,
//   ),
// ),
// searchController: searchController,
// searchInnerWidgetHeight: 20,
// searchInnerWidget: Padding(
//   padding: const EdgeInsets.only(
//     top: 8,
//     bottom: 4,
//     right: 8,
//     left: 8,
//   ),
//   child: SizedBox(
//     height: searchHeight,
//     child: TextFormField(
//       controller: searchController,
//       decoration: textInputDecoration1.copyWith(
//         hintText: S.of(context).search,
//         fillColor: GlobalColors.paleGray,
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(5.0),
//           borderSide: const BorderSide(
//             width: 2,
//             color: GlobalColors.appGreyBackgroundColor,
//           ),
//         ),
//         focusedBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(5.0),
//           borderSide: BorderSide(
//             width: 2,
//             color: Colors.grey.shade300,
//           ),
//         ),
//       ),
//     ),
//   ),
// ),
