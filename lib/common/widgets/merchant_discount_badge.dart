import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:new_piiink/constants/decimal_remove.dart';
import 'package:new_piiink/constants/style.dart';
import 'package:new_piiink/generated/l10n.dart';

class MerchantDiscountBadge extends StatelessWidget {
  const MerchantDiscountBadge({
    super.key,
    required this.discount,
    this.alignment = Alignment.centerLeft,
  });

  final String discount;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 5.h),
        decoration: BoxDecoration(
          color: const Color(0xFFEFF7FF),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: const Color(0xFFD7E8FF)),
        ),
        child: AutoSizeText(
          S
              .of(context)
              .upToXdiscount
              .replaceAll('&x', removeTrailingZero(discount)),
          maxLines: 1,
          minFontSize: 9,
          overflow: TextOverflow.ellipsis,
          style: merchantDisStyle.copyWith(
            color: const Color(0xFF0009FE),
            fontSize: 13.5.sp,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}
