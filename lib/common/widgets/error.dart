import 'package:auto_size_text/auto_size_text.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:touristsaver/constants/global_colors.dart';
import 'package:touristsaver/constants/style.dart';
import 'package:touristsaver/generated/l10n.dart';

// All
class Error extends StatelessWidget {
  const Error({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width / 1,
      height: 370,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
      margin: const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
      // margin: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
      decoration: BoxDecoration(
          color: GlobalColors.appWhiteBackgroundColor,
          borderRadius: BorderRadius.circular(5),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.2),
              blurRadius: 4,
              spreadRadius: 1,
              offset: const Offset(2, 2),
            )
          ]),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            child: SizedBox(
                height: 200.h,
                width: 180.w,
                child: Image.asset("assets/images/oops.png")),
          ),
          const SizedBox(height: 10),
          AutoSizeText(
            S.of(context).oops,
            style: topicStyle,
          ),
          const SizedBox(height: 10),
          AutoSizeText(
            S.of(context).somethingWentWrong,
            style: topicStyle,
          )
        ],
      ),
    );
  }
}

//All with top margin
class Error1 extends StatelessWidget {
  const Error1({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width / 1,
      height: 370,
      padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 10.0),
      margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
      // margin: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
      decoration: BoxDecoration(
          color: GlobalColors.appWhiteBackgroundColor,
          borderRadius: BorderRadius.circular(5),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.2),
              blurRadius: 4,
              spreadRadius: 1,
              offset: const Offset(2, 2),
            )
          ]),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            child: SizedBox(
                height: 200.h,
                width: 180.w,
                child: Image.asset("assets/images/oops.png")),
          ),
          const SizedBox(height: 10),
          AutoSizeText(
            S.of(context).oops,
            style: topicStyle,
          ),
          const SizedBox(height: 10),
          AutoSizeText(
            S.of(context).somethingWentWrong,
            style: topicStyle,
          )
        ],
      ),
    );
  }
}

// Profile Error
class ProfileError extends StatelessWidget {
  const ProfileError({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width / 1,
      height: 205,
      margin: const EdgeInsets.symmetric(horizontal: 10.0),
      padding: const EdgeInsets.symmetric(vertical: 20.0),
      decoration: BoxDecoration(
          color: GlobalColors.appWhiteBackgroundColor,
          borderRadius: BorderRadius.circular(5),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.2),
              blurRadius: 4,
              spreadRadius: 1,
              offset: const Offset(2, 2),
            )
          ]),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            child: SizedBox(
                height: 70.h,
                width: 180.w,
                child: Image.asset("assets/images/oops.png")),
          ),
          const SizedBox(height: 10),
          AutoSizeText(
            S.of(context).oops,
            style: topicStyle,
          ),
          const SizedBox(height: 10),
          AutoSizeText(
            S.of(context).somethingWentWrong,
            style: topicStyle,
          ),
        ],
      ),
    );
  }
}

// Slider Error
class SliderError extends StatelessWidget {
  const SliderError({super.key});

  @override
  Widget build(BuildContext context) {
    return CarouselSlider(
      options: CarouselOptions(
        height: 230,
        autoPlay: true,
        autoPlayCurve: Curves.fastOutSlowIn,
        enableInfiniteScroll: true,
        autoPlayAnimationDuration: const Duration(milliseconds: 800),
        viewportFraction: 0.95,
      ),
      items: [
        Container(
          height: 230,
          width: MediaQuery.of(context).size.width,
          margin: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: GlobalColors.appWhiteBackgroundColor,
            borderRadius: BorderRadius.circular(10.0),
            boxShadow: kElevationToShadow[2],
          ),
          padding: const EdgeInsets.symmetric(vertical: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                child: SizedBox(
                    height: 80.h,
                    width: 180.w,
                    child: Image.asset("assets/images/oops.png")),
              ),
              const SizedBox(height: 10),
              AutoSizeText(
                S.of(context).oops,
                style: topicStyle,
              ),
              const SizedBox(height: 10),
              AutoSizeText(
                S.of(context).somethingWentWrong,
                style: topicStyle,
              )
            ],
          ),
        ),
      ],
    );
  }
}

class ErrorData extends StatelessWidget {
  final String text;
  final double? width;
  const ErrorData({super.key, required this.text, this.width});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width ?? MediaQuery.of(context).size.width / 1,
      margin: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
      height: 50,
      decoration: BoxDecoration(
        color: GlobalColors.appWhiteBackgroundColor,
        borderRadius: BorderRadius.circular(5),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.2),
            blurRadius: 4,
            spreadRadius: 1,
            offset: const Offset(2, 2),
          ),
        ],
      ),
      child: Center(child: AutoSizeText(text)),
    );
  }
}
