import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:touristsaver/common/widgets/custom_app_bar.dart';
import 'package:touristsaver/common/widgets/custom_loader.dart';
import 'package:touristsaver/common/widgets/error.dart';
import 'package:touristsaver/common/widgets/touristsaver_loading_view.dart';
import 'package:touristsaver/constants/global_colors.dart';
import 'package:touristsaver/features/more_offers/bloc/discount_bloc.dart';
import 'package:touristsaver/features/more_offers/bloc/discount_events.dart';
import 'package:touristsaver/features/more_offers/bloc/discount_states.dart';
import 'package:touristsaver/features/more_offers/services/dio_more_offer.dart';
import 'package:touristsaver/features/more_offers/widgets/day_time_dis.dart';
import 'package:touristsaver/models/response/get_all_discount.dart';
import 'package:touristsaver/generated/l10n.dart';

class MoreOffersScreen extends StatefulWidget {
  static const String routeName = '/more-offers';

  final List argImageList;
  final String merchantID;
  const MoreOffersScreen({
    super.key,
    required this.argImageList,
    required this.merchantID,
  });

  @override
  State<MoreOffersScreen> createState() => _MoreOffersScreenState();
}

class _MoreOffersScreenState extends State<MoreOffersScreen> {
  static const Color _headingColor = Color(0xFF111C44);
  static const Color _bodyColor = Color(0xFF63708A);

  //For showing Images
  List imageList = [];
  int current = 0;

  @override
  void initState() {
    imageList = widget.argImageList;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: CustomAppBar(
            text: S.of(context).merchantOffers,
            icon: Icons.arrow_back_ios,
            onPressed: () {
              context.pop(context);
            }),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            // Showing Image
            imageSection(),
            const SizedBox(height: 20),

            _scheduleHeader(),
            SizedBox(height: 16.h),

            BlocProvider(
              lazy: false,
              create: (context) => MerchantDiscountBloc(
                RepositoryProvider.of<DioMoreOffer>(context),
                int.parse(widget.merchantID),
              )..add(LoadMerchantDiscountEvent()),
              child: BlocBuilder<MerchantDiscountBloc, MerchantDiscountState>(
                  builder: (context, state) {
                //Loading State
                if (state is MerchantDiscountLoadingState) {
                  return const TouristSaverLoadingView();
                }
                //Loaded State
                if (state is MerchantDiscountLoadedState) {
                  GetAllDiscountResModel discountAll = state.merchantDiscount;
                  return _scheduleList(discountAll.data);
                }
                //Error State
                else if (state is MerchantDiscountErrorState) {
                  return const Error();
                } else {
                  return const SizedBox();
                }
              }),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _scheduleHeader() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 18.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AutoSizeText(
            'Offer schedule',
            style: TextStyle(
              color: _headingColor,
              fontSize: 22.sp,
              fontWeight: FontWeight.w900,
              fontFamily: 'Sans',
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Discounts may change by day and time. TouristSaver checks the current offer when you scan the merchant QR.',
            style: TextStyle(
              color: _bodyColor,
              fontSize: 14.sp,
              height: 1.35,
              fontWeight: FontWeight.w600,
              fontFamily: 'Sans',
            ),
          ),
        ],
      ),
    );
  }

  Widget _scheduleList(Data? discountData) {
    if (discountData == null) {
      return _emptySchedule();
    }

    final int today = DateTime.now().weekday;
    final List<Widget> cards = [
      _daySchedule(
        dayText: S.of(context).monday,
        offers: discountData.monday ?? [],
        isToday: today == DateTime.monday,
      ),
      _daySchedule(
        dayText: S.of(context).tuesday,
        offers: discountData.tuesday ?? [],
        isToday: today == DateTime.tuesday,
      ),
      _daySchedule(
        dayText: S.of(context).wednesday,
        offers: discountData.wednesday ?? [],
        isToday: today == DateTime.wednesday,
      ),
      _daySchedule(
        dayText: S.of(context).thursday,
        offers: discountData.thursday ?? [],
        isToday: today == DateTime.thursday,
      ),
      _daySchedule(
        dayText: S.of(context).friday,
        offers: discountData.friday ?? [],
        isToday: today == DateTime.friday,
      ),
      _daySchedule(
        dayText: S.of(context).saturday,
        offers: discountData.saturday ?? [],
        isToday: today == DateTime.saturday,
      ),
      _daySchedule(
        dayText: S.of(context).sunday,
        offers: discountData.sunday ?? [],
        isToday: today == DateTime.sunday,
      ),
    ].where((widget) => widget is! SizedBox).toList();

    if (cards.isEmpty) {
      return _emptySchedule();
    }

    return Column(
      children: [
        for (int index = 0; index < cards.length; index++) ...[
          if (index > 0) SizedBox(height: 12.h),
          cards[index],
        ],
      ],
    );
  }

  Widget _daySchedule({
    required String dayText,
    required List<Day> offers,
    required bool isToday,
  }) {
    if (offers.isEmpty) {
      return const SizedBox.shrink();
    }

    return DayTimeDis(
      itemCount: offers.length,
      day: offers,
      dayText: dayText,
      isToday: isToday,
    );
  }

  Widget _emptySchedule() {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 18.w),
      padding: EdgeInsets.all(18.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: const Color(0xFFE2E8F3)),
      ),
      child: Text(
        'No scheduled offers are available for this merchant yet.',
        style: TextStyle(
          color: _bodyColor,
          fontSize: 14.sp,
          height: 1.35,
          fontWeight: FontWeight.w600,
          fontFamily: 'Sans',
        ),
      ),
    );
  }

  // Showing Images
  imageSection() {
    return Column(
      children: [
        Center(
          child: Container(
            width: MediaQuery.of(context).size.width / 1.04,
            height: 180.h,
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
                color: GlobalColors.appWhiteBackgroundColor,
                borderRadius: BorderRadius.circular(5.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 2,
                    spreadRadius: 0,
                    offset: const Offset(0, 2),
                  )
                ]),
            child: imageList.isEmpty
                ? Image.asset('assets/images/no_image.jpg')
                : CarouselSlider(
                    options: CarouselOptions(
                      height: 180.h,
                      autoPlay: true,
                      autoPlayCurve: Curves.fastOutSlowIn,
                      enableInfiniteScroll: true,
                      autoPlayAnimationDuration:
                          const Duration(milliseconds: 800),
                      viewportFraction: 0.95,
                      onPageChanged: (index, ok) {
                        setState(() {
                          current = index;
                        });
                      },
                    ),
                    items: imageList.map<Widget>((i) {
                      return Builder(
                        builder: (BuildContext context) {
                          return SizedBox(
                            width: MediaQuery.of(context).size.width / 1.2,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(5.0),
                              child: GestureDetector(
                                onTap: () {
                                  openImage(i);
                                },
                                child: CachedNetworkImage(
                                  imageUrl: i,
                                  fit: BoxFit.fitHeight,
                                  placeholder: (context, url) {
                                    return const Center(
                                        child: FittedBox(
                                            child: CustomAllLoader1()));
                                  },
                                  errorWidget: (context, url, error) => Center(
                                      child: Image.asset(
                                          'assets/images/no_image.jpg')),
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    }).toList(),
                  ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: imageList.map<Widget>(
            (image) {
              int index = imageList.indexOf(image);
              return Container(
                width: 8.0,
                height: 8.0,
                margin: const EdgeInsets.only(top: 10.0, left: 2.0, right: 2.0),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: current == index
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

  //Opening Image in modal
  openImage(String i) {
    return showGeneralDialog(
      barrierLabel: 'Label',
      barrierDismissible: true, //to dismiss the container once opened
      barrierColor: Colors.black.withValues(
          alpha:
              0.5), //to change the background color once the container is opened
      transitionDuration: const Duration(milliseconds: 300),
      context: context,
      pageBuilder: (context, anim1, anim2) {
        return Align(
          alignment: Alignment.center,
          child: Dismissible(
            direction: DismissDirection.vertical,
            onDismissed: (_) => context.pop(),
            key: const Key('key'),
            child: FittedBox(
              fit: BoxFit.fill,
              child: SizedBox(
                width: MediaQuery.of(context).size.width / 1.05,
                child: CachedNetworkImage(
                  imageUrl: i,
                  fit: BoxFit.fitHeight,
                  placeholder: (context, url) {
                    return const Center(
                        child: FittedBox(child: CustomAllLoader1()));
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
}
