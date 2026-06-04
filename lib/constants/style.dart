// Text InputDecoration
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:touristsaver/constants/global_colors.dart';

InputDecoration textInputDecoration = InputDecoration(
  contentPadding: const EdgeInsets.fromLTRB(11.0, 0.0, 11.0, 0.0),
  border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(2.r),
    borderSide: const BorderSide(
      width: 0,
      style: BorderStyle.none,
    ),
  ),
  hintText: "Search",
  hintStyle: TextStyle(
      color: GlobalColors.gray.withValues(alpha: 0.7),
      fontSize: 15.sp,
      fontWeight: FontWeight.w600),
);

InputDecoration textInputDecoration1 = InputDecoration(
  // contentPadding: const EdgeInsets.fromLTRB(11.0, 10.0, 11.0, 10.0),
  contentPadding: const EdgeInsets.symmetric(vertical: 17.0, horizontal: 25.0),
  border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(5.0),
    borderSide: const BorderSide(
      width: 0,
      style: BorderStyle.none,
    ),
  ),
  filled: true,
  fillColor: GlobalColors.paleGray,
  hintText: "",
  hintStyle: TextStyle(
      color: GlobalColors.gray.withValues(alpha: 0.8),
      fontSize: 15.sp,
      fontWeight: FontWeight.w500),
);

InputDecoration textInputDecoration2 = InputDecoration(
  // contentPadding: const EdgeInsets.fromLTRB(11.0, 10.0, 11.0, 10.0),
  contentPadding: const EdgeInsets.symmetric(vertical: 17.0, horizontal: 25.0),
  border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(5.0),
    borderSide: const BorderSide(
      width: 0,
      style: BorderStyle.none,
    ),
  ),
  filled: true,
  fillColor: GlobalColors.paleGray,
  labelText: "",
  labelStyle: TextStyle(
    fontWeight: FontWeight.w500,
    fontSize: 15.sp,
    color: GlobalColors.gray.withValues(alpha: 0.8),
  ),
);

InputDecoration otpDecoration = const InputDecoration(
  focusedBorder: UnderlineInputBorder(
    borderSide: BorderSide(color: GlobalColors.appColor),
  ),
);

//Button
ButtonStyle styleMainButton = ButtonStyle(
  backgroundColor: WidgetStateProperty.all(GlobalColors.appColor1),
  shape: WidgetStateProperty.all(
    RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(5),
    ),
  ),
  elevation: WidgetStateProperty.all(0.0),
);

// AppBar Text Style
TextStyle appbarTitleStyle = TextStyle(
  fontSize: 18.sp,
  fontWeight: FontWeight.bold,
  color: Colors.black.withValues(alpha: 0.8),
);

// Search style
TextStyle searchStyle = TextStyle(
    color: GlobalColors.gray.withValues(alpha: 0.7),
    fontSize: 15.sp,
    fontWeight: FontWeight.w500);

// 20 fs text style
TextStyle textStyle15 = TextStyle(
    fontSize: 15.sp,
    fontWeight: FontWeight.w500,
    color: Colors.black.withValues(alpha: 0.8));

// 20 fs text style
TextStyle textStyle15h = TextStyle(
    fontSize: 15.sp,
    fontWeight: FontWeight.w400,
    height: 1.4,
    color: Colors.black.withValues(alpha: 0.8));

// button text
TextStyle buttonText = TextStyle(
    fontSize: 18.sp, fontWeight: FontWeight.bold, color: Colors.white);

// Topic style
TextStyle topicStyle = TextStyle(
    fontSize: 20.sp,
    fontWeight: FontWeight.bold,
    color: Colors.black.withValues(alpha: 0.8));

//Table Header TextStyle
TextStyle tableHeaderTextStyle = TextStyle(
  fontSize: 16.sp,
  fontWeight: FontWeight.w500,
  color: GlobalColors.textColor,
);
//Table Body TextStyle
TextStyle tableBodyTextStyle = TextStyle(
  fontSize: 15.sp,
  fontWeight: FontWeight.w400,
  color: GlobalColors.gray,
);

//Table No Data Found
TextStyle tableNoDataTextStyle = TextStyle(
  fontSize: 15.sp,
  color: GlobalColors.textColor,
  fontWeight: FontWeight.bold,
);

//View All
TextStyle viewAllStyle = TextStyle(
  fontSize: 14.sp,
  fontWeight: FontWeight.w400,
  color: GlobalColors.appColor,
);

//Profile/Charity List Style
TextStyle profileListStyle = TextStyle(
  fontSize: 17.sp,
  fontWeight: FontWeight.w500,
);

//  Location Text Style
TextStyle locationStyle = TextStyle(
    color: Colors.black.withValues(alpha: 0.5),
    fontSize: 15.sp,
    fontWeight: FontWeight.w500);

// transaction Text Style
TextStyle transactionTextStyle = TextStyle(
    fontWeight: FontWeight.w500,
    // fontSize: 18.sp,
    fontSize: 17.sp,
    decoration: TextDecoration.none,
    color: Colors.black,
    fontFamily: 'Sans');

// Merchant Name Text Style
TextStyle merchantNameStyle = TextStyle(
    // fontSize: 18.sp,
    fontSize: 16.sp,
    fontWeight: FontWeight.w600,
    color: Colors.black.withValues(alpha: 0.8));

// Merchant Discount TextStyle
TextStyle merchantDisStyle = TextStyle(
    fontSize: 16.sp, color: GlobalColors.appColor, fontWeight: FontWeight.w600);

// DropDown TextStyle
TextStyle dopdownTextStyle = TextStyle(
    fontSize: 15.sp,
    // fontSize: 18.sp,
    color: Colors.black,
    fontWeight: FontWeight.w500);

//Transaction TextStyle
TextStyle transUni = TextStyle(
  fontSize: 16.sp,
  fontWeight: FontWeight.w500,
  color: Colors.black.withValues(alpha: 0.8),
);

TextStyle transUniBal = TextStyle(
  fontSize: 28.sp,
  fontWeight: FontWeight.bold,
  color: Colors.white,
);

TextStyle transacAmtStyle = TextStyle(
  fontSize: 16.sp,
  fontWeight: FontWeight.bold,
  color: Colors.black,
);

TextStyle discountAmtStyle = TextStyle(
  color: GlobalColors.appColor,
  fontSize: 16.sp,
  fontWeight: FontWeight.bold,
);

TextStyle transConTitl = TextStyle(
  fontSize: 18.sp,
  fontWeight: FontWeight.bold,
  color: Colors.black,
);

TextStyle transConSubTitl = TextStyle(
  fontSize: 16.sp,
  fontWeight: FontWeight.w500,
  color: Colors.grey,
);

//Notification Header Screen
TextStyle notiHeaderTextStyle = TextStyle(
  fontSize: 20.sp,
  fontWeight: FontWeight.bold,
  color: GlobalColors.appColor1,
);

//Notification Header Screen
TextStyle noteTextStyle = TextStyle(
  fontSize: 16.sp,
  fontWeight: FontWeight.bold,
  color: GlobalColors.appColor1,
);

//Notification Sub Header Screen
TextStyle notiSubHeaderTextStyle = TextStyle(
  fontSize: 17.sp,
  fontWeight: FontWeight.w500,
  color: GlobalColors.gray,
);

//Notification Date TextStyle
TextStyle notiDateTextStyle = TextStyle(
  fontSize: 14.sp,
  fontWeight: FontWeight.w400,
  color: GlobalColors.gray,
);
