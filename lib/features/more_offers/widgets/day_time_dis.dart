import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:touristsaver/constants/decimal_remove.dart';
import 'package:touristsaver/models/response/get_all_discount.dart';

class DayTimeDis extends StatelessWidget {
  final int itemCount;
  final List<Day> day;
  final String dayText;
  final bool isToday;

  const DayTimeDis({
    super.key,
    required this.itemCount,
    required this.day,
    required this.dayText,
    this.isToday = false,
  });

  @override
  Widget build(BuildContext context) {
    if (itemCount == 0) {
      return const SizedBox.shrink();
    }

    const Color primaryBlue = Color(0xFF0009FE);
    const Color headingColor = Color(0xFF111C44);
    const Color bodyColor = Color(0xFF63708A);
    const Color borderColor = Color(0xFFE2E8F3);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 18.w),
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(
          color: isToday ? primaryBlue.withValues(alpha: 0.5) : borderColor,
          width: isToday ? 1.3 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0A236B).withValues(alpha: 0.06),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AutoSizeText(
                dayText,
                style: TextStyle(
                  color: headingColor,
                  fontSize: 17.sp,
                  fontWeight: FontWeight.w900,
                  fontFamily: 'Sans',
                ),
              ),
              if (isToday) ...[
                SizedBox(width: 8.w),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF7FF),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    'Today',
                    style: TextStyle(
                      color: primaryBlue,
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w800,
                      fontFamily: 'Sans',
                    ),
                  ),
                ),
              ],
            ],
          ),
          SizedBox(height: 12.h),
          ...List.generate(itemCount, (index) {
            final Day offer = day[index];
            final bool allDay = offer.start == offer.end;

            return Padding(
              padding: EdgeInsets.only(top: index == 0 ? 0 : 10.h),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: AutoSizeText(
                      allDay
                          ? 'All day'
                          : '${_formatHour(offer.start)} - ${_formatHour(offer.end)}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: bodyColor,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Sans',
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF4F8FF),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: borderColor),
                    ),
                    child: Text(
                      '${allDay ? 'Up to ' : ''}${removeTrailingZero(offer.discount.toString())}% off',
                      style: TextStyle(
                        color: primaryBlue,
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w900,
                        fontFamily: 'Sans',
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  String _formatHour(int? hour) {
    final int value = hour ?? 0;
    final int normalized = value % 24;
    final int hour12 = normalized == 0
        ? 12
        : normalized > 12
            ? normalized - 12
            : normalized;
    final String period = normalized < 12 ? 'am' : 'pm';
    return '$hour12:00 $period';
  }
}
