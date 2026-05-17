import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:new_piiink/constants/style.dart';
import 'package:new_piiink/constants/global_colors.dart';

class CustomButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String text;
  final double? height;
  final double? width;

  const CustomButton(
      {super.key, required this.text, this.onPressed, this.height, this.width});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration:
          BoxDecoration(borderRadius: BorderRadius.circular(5.0), boxShadow: [
        BoxShadow(
            color: Colors.grey.withValues(alpha: 0.2),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(2, 2))
      ]),
      width: width ?? MediaQuery.of(context).size.width / 1.2,
      height: height ?? 45.h,
      child: ElevatedButton(
        onPressed: onPressed,
        style: styleMainButton,
        child: AutoSizeText(
          text,
          style: buttonText,
        ),
      ),
    );
  }
}

class TopUpButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String text;
  final double? height;
  final double? width;
  final Color? buttonSideColor;
  final Color? buttonBackGroundColor;
  final Color? buttonTextColor;

  const TopUpButton(
      {super.key,
      required this.text,
      this.onPressed,
      this.height,
      this.width,
      this.buttonSideColor,
      this.buttonBackGroundColor,
      this.buttonTextColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration:
          BoxDecoration(borderRadius: BorderRadius.circular(10.0), boxShadow: [
        BoxShadow(
            color: Colors.grey.shade800,
            spreadRadius: 1,
            blurRadius: 1,
            offset: const Offset(3, 3))
      ]),
      width: width ?? MediaQuery.of(context).size.width / 1.2,
      height: height ?? 35.h,
      child: ElevatedButton(
        onPressed: onPressed,
        style: styleMainButton.copyWith(
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          side: WidgetStateProperty.all(BorderSide(
              color: buttonSideColor ?? GlobalColors.appColor1, width: 2)),
          backgroundColor: WidgetStateProperty.all(
              buttonBackGroundColor ?? GlobalColors.appWhiteBackgroundColor),
        ),
        child: AutoSizeText(
          text,
          maxLines: 1,
          style: buttonText.copyWith(
              fontSize: 15, color: buttonTextColor ?? GlobalColors.appColor1),
        ),
      ),
    );
  }
}

class TopUpWithCircular extends StatelessWidget {
  final VoidCallback? onPressed;
  final double? height;
  final double? width;
  final Color? buttonSideColor;
  final Color? buttonBackGroundColor;
  final Color? buttonTextColor;
  final Color? circleColor;
  // final Widget widget;

  const TopUpWithCircular(
      {super.key,
      this.onPressed,
      this.height,
      this.width,
      this.buttonSideColor,
      this.buttonBackGroundColor,
      this.buttonTextColor,
      this.circleColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5.0),
          boxShadow: const [
            BoxShadow(
                color: Colors.grey,
                spreadRadius: 1,
                blurRadius: 4,
                offset: Offset(0, 2))
          ]),
      width: width ?? MediaQuery.of(context).size.width / 1.2,
      height: height ?? 35.h,
      child: ElevatedButton(
        onPressed: onPressed,
        style: styleMainButton.copyWith(
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          side: WidgetStateProperty.all(BorderSide(
              color: buttonSideColor ?? GlobalColors.appColor1, width: 2)),
          backgroundColor: WidgetStateProperty.all(
              buttonBackGroundColor ?? GlobalColors.appWhiteBackgroundColor),
        ),
        child: Container(
          width: 24,
          height: 24,
          padding: const EdgeInsets.all(2.0),
          child: CircularProgressIndicator(
            color: circleColor ?? GlobalColors.loaderColor,
            strokeWidth: 3,
          ),
        ),
      ),
    );
  }
}

class CustomIconButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final double? width;
  // final String text;
  final Icon? icon;

  const CustomIconButton({super.key, this.icon, this.onPressed, this.width});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration:
          BoxDecoration(borderRadius: BorderRadius.circular(5.0), boxShadow: [
        BoxShadow(
            color: Colors.grey.withValues(alpha: 0.2),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(2, 2))
      ]),
      width: width ?? MediaQuery.of(context).size.width / 1.1,
      height: 45.h,
      child: ElevatedButton(
          onPressed: onPressed, style: styleMainButton, child: icon),
    );
  }
}

class CustomButtonWithCircular extends StatelessWidget {
  final VoidCallback? onPressed;
  // final Widget widget;

  const CustomButtonWithCircular({super.key, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration:
          BoxDecoration(borderRadius: BorderRadius.circular(5.0), boxShadow: [
        BoxShadow(
            color: Colors.grey.withValues(alpha: 0.2),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(2, 2))
      ]),
      width: MediaQuery.of(context).size.width / 1.2,
      height: 45,
      child: ElevatedButton(
        onPressed: onPressed,
        style: styleMainButton,
        child: Container(
          width: 24,
          height: 24,
          padding: const EdgeInsets.all(2.0),
          child: const CircularProgressIndicator(
            color: GlobalColors.loaderColor,
            strokeWidth: 3,
          ),
        ),
      ),
    );
  }
}

class CustomButton1 extends StatelessWidget {
  final VoidCallback? onPressed;
  final String text;
  final double? height;
  final double? width;
  const CustomButton1(
      {super.key, required this.text, this.onPressed, this.height, this.width});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(5.0)),
      width: width ?? MediaQuery.of(context).size.width / 1.2,
      height: height ?? 45,
      child: ElevatedButton(
        onPressed: onPressed,
        style: styleMainButton.copyWith(
          side: WidgetStateProperty.all(
              const BorderSide(color: GlobalColors.appColor1, width: 2)),
          backgroundColor:
              WidgetStateProperty.all(GlobalColors.appWhiteBackgroundColor),
        ),
        child: AutoSizeText(
          text,
          style: buttonText.copyWith(color: GlobalColors.appColor1),
        ),
      ),
    );
  }
}

//For Modal BottomSheet
class ModalCustomButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String text;

  const ModalCustomButton({super.key, required this.text, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration:
          BoxDecoration(borderRadius: BorderRadius.circular(5.0), boxShadow: [
        BoxShadow(
            color: Colors.grey.withValues(alpha: 0.2),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(2, 2))
      ]),
      width: MediaQuery.of(context).size.width / 1.2,
      height: 45,
      child: ElevatedButton(
        onPressed: onPressed,
        style: styleMainButton,
        child: AutoSizeText(
          text,
          style: buttonText.copyWith(fontSize: 20.sp),
        ),
      ),
    );
  }
}

class ModalCustomButton1 extends StatelessWidget {
  final VoidCallback? onPressed;
  final String text;
  const ModalCustomButton1({super.key, required this.text, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(5.0)),
      width: MediaQuery.of(context).size.width / 1.2,
      height: 45,
      child: ElevatedButton(
        onPressed: onPressed,
        style: styleMainButton.copyWith(
          side: WidgetStateProperty.all(
              const BorderSide(color: GlobalColors.appColor1, width: 2)),
          backgroundColor:
              WidgetStateProperty.all(GlobalColors.appWhiteBackgroundColor),
        ),
        child: AutoSizeText(
          text,
          style: buttonText.copyWith(
              color: GlobalColors.appColor1, fontSize: 20.sp),
        ),
      ),
    );
  }
}
