import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:touristsaver/constants/global_colors.dart';
import 'package:touristsaver/constants/style.dart';
import 'package:touristsaver/generated/l10n.dart';

class RangeContainer extends StatelessWidget {
  final String text1;
  const RangeContainer({super.key, required this.text1});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          height: 30,
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(5.0),
              border: Border.all(color: GlobalColors.appColor)),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 5.0),
            child: AutoSizeText(
              text1,
              style: dopdownTextStyle,
            ),
          ),
        ),
        const SizedBox(width: 10),
        AutoSizeText(
          S.of(context).km,
          // 'KM',
          style: const TextStyle(
              fontSize: 15, color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
