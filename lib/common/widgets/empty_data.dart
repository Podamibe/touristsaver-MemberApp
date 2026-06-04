import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:touristsaver/constants/global_colors.dart';

class EmptyData extends StatelessWidget {
  final String text;
  const EmptyData({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      margin: const EdgeInsets.symmetric(horizontal: 10.0),
      height: 50,
      decoration: BoxDecoration(
          color: GlobalColors.appWhiteBackgroundColor,
          border: Border.all(color: Colors.black)),
      child: Center(child: AutoSizeText(text)),
    );
  }
}
