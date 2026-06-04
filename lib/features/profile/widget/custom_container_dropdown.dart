//Custom Container for DropDown
import 'package:auto_size_text/auto_size_text.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:touristsaver/constants/style.dart';

import '../../../constants/global_colors.dart';

class CustomContDropDown extends StatelessWidget {
  final double? contWidth;
  final String hintText;
  final List<DropdownMenuItem<Object>> items;
  final double? dropdownWidth;
  final String? valueObject;
  final Function(Object?) onChanged;
  const CustomContDropDown(
      {super.key,
      this.contWidth,
      required this.hintText,
      required this.items,
      required this.valueObject,
      required this.onChanged,
      this.dropdownWidth});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 55,
      width: contWidth ?? MediaQuery.of(context).size.width / 1.1,
      decoration: BoxDecoration(
        color: GlobalColors.paleGray,
        borderRadius: BorderRadius.circular(5.0),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton2(
          hint: Padding(
            padding: const EdgeInsets.only(left: 25),
            child: AutoSizeText(
              hintText,
              style: searchStyle,
            ),
          ),
          iconStyleData: const IconStyleData(
            icon: Padding(
              padding: EdgeInsets.only(right: 10),
              child: Icon(
                Icons.expand_more,
                color: GlobalColors.appColor,
              ),
            ),
            openMenuIcon: Padding(
              padding: EdgeInsets.only(right: 25),
              child: Icon(
                Icons.expand_less,
                color: GlobalColors.appColor,
              ),
            ),
          ),
          items: items,
          onChanged: onChanged,
          value: valueObject,
          dropdownStyleData: DropdownStyleData(
            maxHeight: 250,
            width: dropdownWidth ?? MediaQuery.of(context).size.width / 1.1,
            padding: null,
            scrollbarTheme: ScrollbarThemeData(
              radius: const Radius.circular(40),
              thickness: WidgetStateProperty.all(6),
              thumbVisibility: WidgetStateProperty.all(true),
            ),
          ),
          isExpanded: true,
        ),
      ),
    );
  }
}
