import 'dart:async';
import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:touristsaver/constants/global_colors.dart';
import 'package:touristsaver/constants/style.dart';
import 'package:outline_gradient_button/outline_gradient_button.dart';
import 'package:touristsaver/generated/l10n.dart';

class CustomLoader extends StatelessWidget {
  const CustomLoader({super.key, this.itemCount = 4});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return ScrollConfiguration(
      behavior: const ScrollBehavior(),
      child: SingleChildScrollView(
        child: Column(
          children: [
            GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              padding:
                  const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 300,
                  childAspectRatio: 3 / 4,
                  crossAxisSpacing: 25,
                  mainAxisSpacing: 25),
              itemCount: itemCount,
              itemBuilder: ((context, index) {
                return Container(
                  decoration: BoxDecoration(
                      color: GlobalColors.appWhiteBackgroundColor,
                      borderRadius: BorderRadius.circular(10.0),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.grey.withValues(alpha: 0.2),
                            offset: const Offset(2, 2),
                            spreadRadius: 1,
                            blurRadius: 1)
                      ]),
                  child: Column(
                    children: [
                      // Image
                      Expanded(
                        flex: 5,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 0),
                          child: ClipRRect(
                            borderRadius: const BorderRadius.only(
                                topRight: Radius.circular(10.0),
                                topLeft: Radius.circular(10.0)),
                            child: Image.asset(
                              "assets/images/placeholder.png",
                              height: 50,
                              fit: BoxFit.fitHeight,
                            ),
                          ),
                        ),
                      ),

                      // New Merchant Name
                      const Expanded(
                        flex: 2,
                        child: Padding(
                          padding: EdgeInsets.only(right: 5, left: 5, top: 10),
                          child: Align(
                              alignment: Alignment.center,
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: GlobalColors.loaderColor,
                                ),
                              )),
                        ),
                      ),

                      // Discount
                      Container(
                        height: 40,
                        decoration: BoxDecoration(
                          color: GlobalColors.appGreyBackgroundColor
                              .withValues(alpha: 0.5),
                          borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(10.0),
                              bottomRight: Radius.circular(10.0)),
                        ),
                        padding: const EdgeInsets.only(left: 5.0, right: 5.0),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: AutoSizeText(
                            '...',
                            // textAlign: TextAlign.left,
                            style: merchantDisStyle.copyWith(fontSize: 15.sp),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

// For showing merchant using ListView
class CustomLoader1 extends StatelessWidget {
  const CustomLoader1({super.key});

  @override
  Widget build(BuildContext context) {
    double contWidth = MediaQuery.of(context).size.width / 1.6;
    double contImgHeight = contWidth / 2;
    return SizedBox(
      // height: 320,
      height: 280,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        shrinkWrap: true,
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        separatorBuilder: (context, index) {
          return const SizedBox(width: 25);
        },
        itemCount: 4,
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.only(top: 10.0, bottom: 5.0),
            width: contWidth,
            decoration: BoxDecoration(
                color: GlobalColors.appWhiteBackgroundColor,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                      color: Colors.grey.withValues(alpha: 0.2),
                      offset: const Offset(2, 2),
                      spreadRadius: 1,
                      blurRadius: 1)
                ]),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 0),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(10),
                        topLeft: Radius.circular(10)),
                    child: Image.asset(
                      "assets/images/placeholder.png",
                      width: contWidth,
                      height: contImgHeight,
                      fit: BoxFit.fitHeight,
                    ),
                  ),
                ),

                // Merchant Name
                const Expanded(
                  flex: 2,
                  child: Padding(
                    padding: EdgeInsets.only(right: 5, left: 5, top: 10),
                    child: Align(
                        alignment: Alignment.center,
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: GlobalColors.loaderColor,
                          ),
                        )),
                  ),
                ),

                // Discount
                Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color: GlobalColors.appGreyBackgroundColor
                        .withValues(alpha: 0.5),
                    borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(10),
                        bottomRight: Radius.circular(10)),
                  ),
                  child: Center(
                    child: AutoSizeText(
                      '...',
                      textAlign: TextAlign.center,
                      style: merchantDisStyle,
                    ),
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}

// For All Please Wait
class CustomAllLoader extends StatelessWidget {
  const CustomAllLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Dialog(
        backgroundColor: Colors.white,
        alignment: Alignment.center,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18.r),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 24.h, horizontal: 28.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              AutoSizeText(
                S.of(context).pleaseWait,
                textAlign: TextAlign.center,
                style: textStyle15,
              ),
              SizedBox(height: 14.h),
              const CircularProgressIndicator(
                color: GlobalColors.loaderColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// For All Circle Loader
class CustomAllLoader1 extends StatefulWidget {
  const CustomAllLoader1({super.key});

  @override
  CustomAllLoader1State createState() => CustomAllLoader1State();
}

class CustomAllLoader1State extends State<CustomAllLoader1>
    with SingleTickerProviderStateMixin {
  double radius = 20.0;
  double pi = 3.14;
  late final AnimationController _animationController =
      AnimationController(vsync: this, duration: const Duration(seconds: 3))
        ..repeat();

  List<Color> colors = [GlobalColors.loaderColor, GlobalColors.loaderColor];
  Color colorNow = GlobalColors.loaderColor;
  int colorIndex = 0;
  void changeColor() {
    setState(() {
      colorNow = colors[colorIndex];
    });
  }

  Timer? timer;

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(
      const Duration(seconds: 2),
      (timer) => changeColor(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (BuildContext context, Widget? child) {
        return Transform.rotate(
          angle:
              _animationController.value * 2 * pi, // decide the angle to circle
          child: SizedBox(
            width: 100.0,
            height: 100.0,
            child: Stack(
              children: [
                // Middle Circle
                const Dot(
                  radius: 30.0,
                  color: Colors.transparent,
                ),
                Transform.translate(
                  offset: Offset(
                    radius * cos(pi / 4),
                    radius * sin(pi / 4),
                  ),
                  child: Dot(radius: 10.0, color: colorNow),
                ),
                Transform.translate(
                  offset: Offset(
                    radius * cos(2 * pi / 4),
                    radius * sin(2 * pi / 4),
                  ),
                  child: Dot(
                    radius: 10.0,
                    color: colorNow,
                  ),
                ),
                Transform.translate(
                  offset: Offset(
                    radius * cos(3 * pi / 4),
                    radius * sin(3 * pi / 4),
                  ),
                  child: Dot(
                    radius: 10.0,
                    color: colorNow,
                  ),
                ),
                Transform.translate(
                  offset: Offset(
                    radius * cos(4 * pi / 4),
                    radius * sin(4 * pi / 4),
                  ),
                  child: Dot(
                    radius: 10.0,
                    color: colorNow,
                  ),
                ),
                Transform.translate(
                  offset: Offset(
                    radius * cos(5 * pi / 4),
                    radius * sin(5 * pi / 4),
                  ),
                  child: Dot(
                    radius: 10.0,
                    color: colorNow,
                  ),
                ),
                Transform.translate(
                  offset: Offset(
                    radius * cos(6 * pi / 4),
                    radius * sin(6 * pi / 4),
                  ),
                  child: Dot(
                    radius: 10.0,
                    color: colorNow,
                  ),
                ),
                Transform.translate(
                  offset: Offset(
                    radius * cos(7 * pi / 4),
                    radius * sin(7 * pi / 4),
                  ),
                  child: Dot(
                    radius: 10.0,
                    color: colorNow,
                  ),
                ),
                Transform.translate(
                  offset: Offset(
                    radius * cos(8 * pi / 4),
                    radius * sin(8 * pi / 4),
                  ),
                  child: Dot(
                    radius: 10.0,
                    color: colorNow,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    timer?.cancel();
    super.dispose();
  }
}

class Dot extends StatelessWidget {
  final double? radius;
  final Color color;
  const Dot({super.key, this.radius, required this.color});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: radius,
        height: radius,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

// For Profile Loader
class ProfileLoader extends StatelessWidget {
  final double height;
  const ProfileLoader({super.key, this.height = 200.0});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width / 1,
      height: height,
      margin: const EdgeInsets.symmetric(horizontal: 10.0),
      decoration: BoxDecoration(
          color: GlobalColors.appWhiteBackgroundColor,
          borderRadius: BorderRadius.circular(5.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.2),
              blurRadius: 4,
              spreadRadius: 1,
              offset: const Offset(2, 2),
            )
          ]),
      child: const Center(child: CustomAllLoader1()),
    );
  }
}

// Slider Loader
class SliderLoader extends StatelessWidget {
  const SliderLoader({super.key});

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
          width: MediaQuery.of(context).size.width,
          height: 230,
          margin: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: GlobalColors.appWhiteBackgroundColor,
            borderRadius: BorderRadius.circular(10.0),
            boxShadow: kElevationToShadow[2],
          ),
          child: const Center(child: CustomAllLoader1()),
        ),
      ],
    );
  }
}

//Merchant Wallet Loader
class MerchantWalletLoader extends StatelessWidget {
  const MerchantWalletLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return ScrollConfiguration(
      behavior: const ScrollBehavior(),
      child: SingleChildScrollView(
        child: GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 300,
              childAspectRatio: 4 / 5,
              crossAxisSpacing: 25,
              mainAxisSpacing: 25),
          itemCount: 10,
          itemBuilder: ((context, index) {
            return OutlineGradientButton(
              padding: const EdgeInsets.all(5.0),
              strokeWidth: 1,
              radius: const Radius.circular(5.0),
              backgroundColor: GlobalColors.appWhiteBackgroundColor,
              elevation: 2,
              gradient: const LinearGradient(
                colors: [
                  GlobalColors.loaderColor,
                  Color(0xffE8F7FD),
                ],
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
              ),
              child: Column(children: [
                Expanded(
                  flex: 5,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(5.0),
                        topLeft: Radius.circular(5.0)),
                    child: Image.asset(
                      'assets/images/placeholder.png',
                      width: MediaQuery.of(context).size.width / 1.3,
                      fit: BoxFit.fitHeight,
                    ),
                  ),
                ),

                // Merchant Name
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.only(
                        right: 5.0, left: 5.0, top: 5.0, bottom: 5.0),
                    child: Align(
                      alignment: Alignment.center,
                      child: AutoSizeText(
                        '..........',
                        style: merchantNameStyle.copyWith(fontSize: 16.sp),
                      ),
                    ),
                  ),
                ),

                // Piiink Points in terms of Merchant
                SizedBox(
                  height: 30,
                  child: Center(
                    child: AutoSizeText(
                      '..........',
                      style:
                          topicStyle.copyWith(color: GlobalColors.loaderColor),
                    ),
                  ),
                )
              ]),
            );
          }),
        ),
      ),
    );
  }
}
