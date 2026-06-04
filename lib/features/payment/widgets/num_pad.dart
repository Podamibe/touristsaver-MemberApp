import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:outline_gradient_button/outline_gradient_button.dart';
import 'package:touristsaver/constants/global_colors.dart';

// KeyPad widget
// This widget is reusable and its buttons are customizable (color, size)
class NumPad extends StatelessWidget {
  final double buttonSize;
  final Color buttonColor;
  final Color iconColor;
  final TextEditingController controller;
  final Function delete;

  const NumPad({
    super.key,
    this.buttonSize = 70,
    this.buttonColor = Colors.indigo,
    this.iconColor = Colors.orange,
    required this.delete,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 30, right: 30),
      child: Column(
        children: [
          SizedBox(height: 10.h),
          // First Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            // implement the number keys (from 0 to 9) with the NumberButton widget
            // the NumberButton widget is defined in the bottom of this file
            children: [
              NumberButton(
                number: "1",
                size: buttonSize,
                color: buttonColor,
                controller: controller,
              ),
              NumberButton(
                number: "2",
                size: buttonSize,
                color: buttonColor,
                controller: controller,
              ),
              NumberButton(
                number: "3",
                size: buttonSize,
                color: buttonColor,
                controller: controller,
              ),
            ],
          ),
          SizedBox(height: 7.h),
          // Second Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              NumberButton(
                number: "4",
                size: buttonSize,
                color: buttonColor,
                controller: controller,
              ),
              NumberButton(
                number: "5",
                size: buttonSize,
                color: buttonColor,
                controller: controller,
              ),
              NumberButton(
                number: "6",
                size: buttonSize,
                color: buttonColor,
                controller: controller,
              ),
            ],
          ),
          SizedBox(height: 7.h),
          // Third Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              NumberButton(
                number: "7",
                size: buttonSize,
                color: buttonColor,
                controller: controller,
              ),
              NumberButton(
                number: "8",
                size: buttonSize,
                color: buttonColor,
                controller: controller,
              ),
              NumberButton(
                number: "9",
                size: buttonSize,
                color: buttonColor,
                controller: controller,
              ),
            ],
          ),
          SizedBox(height: 7.h),
          // Fourth Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              NumberButton(
                number: ".",
                size: buttonSize,
                color: buttonColor,
                controller: controller,
              ),

              NumberButton(
                number: "0",
                size: buttonSize,
                color: buttonColor,
                controller: controller,
              ),

              // Clear Icon this button is used to delete the last number
              OutlineGradientButton(
                strokeWidth: 2,
                gradient: const LinearGradient(
                  colors: [GlobalColors.appColor, GlobalColors.appColor1],
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                ),
                radius: const Radius.circular(50),
                child: Center(
                  child: IconButton(
                    onPressed: () => delete(),
                    icon: Icon(
                      Icons.backspace,
                      color: iconColor,
                    ),
                    iconSize: 25,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// define NumberButton widget
// its shape is round
class NumberButton extends StatelessWidget {
  final String number;
  final double size;
  final Color color;
  final TextEditingController controller;

  const NumberButton({
    super.key,
    required this.number,
    required this.size,
    required this.color,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: OutlineGradientButton(
        strokeWidth: 2,
        gradient: const LinearGradient(
          colors: [GlobalColors.appColor, GlobalColors.appColor1],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        radius: const Radius.circular(50),
        onTap: () {
          final currentText = controller.text;
          final newText = currentText + number;
          final regex = RegExp(r'^\d+(\.\d{0,2})?$');
          if (regex.hasMatch(newText)) {
            controller.text = newText;
          }
        },
        child: Center(
          child: AutoSizeText(
            number.toString(),
            style: const TextStyle(
                fontWeight: FontWeight.w500, color: Colors.black, fontSize: 30),
          ),
        ),
      ),
    );
  }
}
