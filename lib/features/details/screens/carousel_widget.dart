import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../common/widgets/custom_loader.dart';
import '../../../constants/global_colors.dart';

class CarouselWidget extends StatefulWidget {
  const CarouselWidget({
    super.key,
    required this.imageList,
    this.heroTitle,
    this.onBack,
    this.heroMode = false,
    this.autoPlay = true,
  });

  final List<dynamic> imageList;
  final String? heroTitle;
  final VoidCallback? onBack;
  final bool heroMode;
  final bool autoPlay;

  @override
  State<CarouselWidget> createState() => _CarouselWidgetState();
}

class _CarouselWidgetState extends State<CarouselWidget> {
  int currentIndex = 0;

  showImageDialog(String i) {
    return showGeneralDialog(
      barrierLabel: 'Label',
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      transitionDuration: const Duration(milliseconds: 300),
      context: context,
      pageBuilder: (context, anim1, anim2) {
        return Align(
          alignment: Alignment.center,
          child: Dismissible(
            key: UniqueKey(),
            direction: DismissDirection.vertical,
            onDismissed: (_) => context.pop(),
            child: FittedBox(
              fit: BoxFit.fill,
              child: SizedBox(
                width: MediaQuery.of(context).size.width / 1.05,
                child: CachedNetworkImage(
                  imageUrl: i,
                  fit: BoxFit.contain,
                  placeholder: (context, url) {
                    return const Center(child: CustomAllLoader1());
                  },
                  errorWidget: (context, url, error) =>
                      Center(child: Image.asset('assets/images/no_image.jpg')),
                ),
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return SlideTransition(
          position: Tween(begin: const Offset(0, 1), end: const Offset(0, 0))
              .animate(anim1),
          child: child,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final double sliderWidth = MediaQuery.of(context).size.width;
    final double sliderHeight = widget.heroMode ? sliderWidth / 1.5 : 180.h;
    final BorderRadius imageRadius =
        BorderRadius.circular(widget.heroMode ? 0 : 5.0);

    return Column(
      children: [
        Container(
          alignment: Alignment.center,
          width: widget.heroMode ? sliderWidth : sliderWidth / 1.04,
          height: sliderHeight,
          padding: EdgeInsets.symmetric(vertical: widget.heroMode ? 0 : 10),
          decoration: widget.heroMode
              ? null
              : BoxDecoration(
                  color: GlobalColors.appWhiteBackgroundColor,
                  borderRadius: BorderRadius.circular(5.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 2,
                      spreadRadius: 0,
                      offset: const Offset(0, 2),
                    )
                  ],
                ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              widget.imageList.isEmpty
                  ? Image.asset(
                      'assets/images/no_image.jpg',
                      fit: widget.heroMode ? BoxFit.cover : BoxFit.contain,
                    )
                  : CarouselSlider(
                      options: CarouselOptions(
                        height: sliderHeight,
                        autoPlay: widget.autoPlay,
                        autoPlayCurve: Curves.fastOutSlowIn,
                        enableInfiniteScroll: true,
                        autoPlayAnimationDuration:
                            const Duration(milliseconds: 800),
                        viewportFraction: widget.heroMode ? 1.0 : 0.95,
                        onPageChanged: (index, ok) {
                          setState(() {
                            currentIndex = index;
                          });
                        },
                      ),
                      items: widget.imageList.map<Widget>((i) {
                        return SizedBox(
                          width:
                              widget.heroMode ? sliderWidth : sliderWidth / 1.2,
                          child: ClipRRect(
                            borderRadius: imageRadius,
                            child: GestureDetector(
                              onTap: () {
                                showImageDialog(i);
                              },
                              child: CachedNetworkImage(
                                imageUrl: i,
                                fit: widget.heroMode
                                    ? BoxFit.cover
                                    : BoxFit.fitHeight,
                                placeholder: (context, url) {
                                  return const Center(
                                      child:
                                          FittedBox(child: CustomAllLoader1()));
                                },
                                errorWidget: (context, url, error) =>
                                    Image.asset(
                                  'assets/images/no_image.jpg',
                                  fit: widget.heroMode
                                      ? BoxFit.cover
                                      : BoxFit.contain,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
              if (widget.heroMode) ...[
                _HeroGradient(
                  title: widget.heroTitle ?? '',
                  onBack: widget.onBack,
                ),
                _HeroDots(
                  count: widget.imageList.length,
                  currentIndex: currentIndex,
                ),
              ],
            ],
          ),
        ),

        //Dots indicator
        if (!widget.heroMode)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: widget.imageList.map<Widget>(
              (image) {
                int index = widget.imageList.indexOf(image);
                return Container(
                  width: 8.0,
                  height: 8.0,
                  margin:
                      const EdgeInsets.only(top: 10.0, left: 2.0, right: 2.0),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: currentIndex == index
                        ? GlobalColors.appColor
                        : GlobalColors.appColor1,
                  ),
                );
              },
            ).toList(),
          ),
      ],
    );
  }
}

class _HeroGradient extends StatelessWidget {
  const _HeroGradient({
    required this.title,
    required this.onBack,
  });

  final String title;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        height: 172,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withValues(alpha: 0.72),
              Colors.black.withValues(alpha: 0.42),
              Colors.black.withValues(alpha: 0.12),
              Colors.transparent,
            ],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(10, 8, 18, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconButton(
                  onPressed: onBack,
                  icon: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Colors.white,
                  ),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.black.withValues(alpha: 0.30),
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 25.sp,
                      fontWeight: FontWeight.w700,
                      height: 1.06,
                      fontFamily: 'Sans',
                      shadows: [
                        Shadow(
                          color: Colors.black.withValues(alpha: 0.55),
                          offset: const Offset(0, 1),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HeroDots extends StatelessWidget {
  const _HeroDots({
    required this.count,
    required this.currentIndex,
  });

  final int count;
  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    if (count <= 1) return const SizedBox();
    return Positioned(
      left: 0,
      right: 0,
      bottom: 14,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(count, (index) {
          return Container(
            width: currentIndex == index ? 18 : 7,
            height: 7,
            margin: const EdgeInsets.symmetric(horizontal: 3),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(99),
              color: currentIndex == index
                  ? Colors.white
                  : Colors.white.withValues(alpha: 0.45),
            ),
          );
        }),
      ),
    );
  }
}
