import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:touristsaver/common/app_variables.dart';
import 'package:touristsaver/constants/style.dart';
import 'package:touristsaver/features/merchant/services/dio_reviews.dart';

import '../../../common/widgets/custom_app_bar.dart';
import '../../../common/widgets/custom_loader.dart';
import '../../../common/widgets/error.dart';
import '../../../models/error_res.dart';
import '../../../models/response/get_all_merchant_reviews.dart';
import 'package:dartz/dartz.dart' as dartz;
import 'package:touristsaver/generated/l10n.dart';

class MerchantRating extends StatefulWidget {
  static const String routeName = '/merchant-rating';
  const MerchantRating({
    super.key,
    this.merchantId,
    this.merchantName,
    this.merchantLogo,
  });
  final String? merchantId;
  final String? merchantName;
  final String? merchantLogo;

  @override
  State<MerchantRating> createState() => _MerchantRatingState();
}

class _MerchantRatingState extends State<MerchantRating> {
  static const Color _primaryBlue = Color(0xFF0009FE);
  static const Color _ctaCyan = Color(0xFF18C6FF);
  static const Color _headingColor = Color(0xFF111C44);
  static const Color _bodyColor = Color(0xFF61708A);
  static const Color _borderColor = Color(0xFFE2E8F3);

  IconData? _selectedIcon;
  Future<dartz.Either<ErrorResModel, GetAllMerchantReviewsResModel>?>?
      getMerchantReviews;
  Future<dartz.Either<ErrorResModel, GetAllMerchantReviewsResModel>?>?
      getMerchantReview() async {
    dartz.Either<ErrorResModel, GetAllMerchantReviewsResModel>?
        getAllMerchantReviewRes =
        await DioReviews().getAllMerchantReviews(int.parse(widget.merchantId!));

    return getAllMerchantReviewRes!
        .fold((l) => getAllMerchantReviewRes, (r) => getAllMerchantReviewRes);
  }

  @override
  void initState() {
    super.initState();
    getMerchantReviews = getMerchantReview();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: CustomAppBar(
          text: S.of(context).reviews,
          icon: Icons.arrow_back_ios,
          onPressed: (() {
            context.pop();
          }),
        ),
      ),
      body: FutureBuilder<
              dartz.Either<ErrorResModel, GetAllMerchantReviewsResModel>?>(
          future: getMerchantReview(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Error1();
            } else if (!snapshot.hasData) {
              return const Column(
                children: [
                  CustomAllLoader(),
                ],
              );
            } else {
              return snapshot.data!.fold((l) {
                return ErrorData(text: l.message!);
              }, (r) {
                return r.data!.isNotEmpty
                    ? Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              height: 10.h,
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 5.sp),
                              child: Row(
                                children: [
                                  Text(S.of(context).userReviews,
                                      style: topicStyle),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  Text('( ${r.count} )',
                                      style: topicStyle.copyWith(
                                          fontWeight: FontWeight.w500)),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: 10.h,
                            ),
                            Expanded(
                              child: ListView.builder(
                                padding: EdgeInsets.only(bottom: 88.h),
                                shrinkWrap: true,
                                itemCount: r.data!.length,
                                itemBuilder: (context, index) {
                                  var data = r.data!.elementAt(index);
                                  return Padding(
                                    padding: const EdgeInsets.all(5.0),
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 15.w, vertical: 12.h),
                                      decoration: BoxDecoration(
                                          color: Colors.white,
                                          border: Border.all(
                                              color: _borderColor, width: 1),
                                          boxShadow: [
                                            BoxShadow(
                                                color: _primaryBlue.withValues(
                                                    alpha: 0.06),
                                                blurRadius: 16,
                                                offset: const Offset(0, 8))
                                          ],
                                          borderRadius:
                                              BorderRadius.circular(7)),
                                      child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                _ratingBar(data.rating!),
                                                AutoSizeText(
                                                  DateFormat.yMMMd()
                                                      .format(data.createdAt!),
                                                  style: TextStyle(
                                                    color: _bodyColor,
                                                    fontSize: 12.sp,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                )
                                              ],
                                            ),
                                            SizedBox(height: 8.h),
                                            reviewerName(
                                                data.member!.firstname!),
                                            SizedBox(height: 6.h),
                                            data.review == '' ||
                                                    data.review == null
                                                ? const SizedBox()
                                                : reviewDescription(
                                                    data.review ?? '')
                                          ]),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      )
                    : _emptyReviewsState();
              });
            }
          }),
      floatingActionButton: AppVariables.accessToken == null
          ? null
          : Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: const LinearGradient(
                  colors: [_primaryBlue, _ctaCyan],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: _primaryBlue.withValues(alpha: 0.18),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: MaterialButton(
                  child: Text(
                    S.of(context).addReview,
                    maxLines: 1,
                    style: buttonText,
                  ),
                  onPressed: () {
                    context.pushNamed(
                      'feedback-screen',
                      extra: {
                        'merchantId': widget.merchantId,
                        'merchantName': widget.merchantName,
                        'merchantLogo': widget.merchantLogo,
                      },
                    );
                  })),
    );
  }

  Widget _emptyReviewsState() => Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 28.w),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 22.w, vertical: 28.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18.r),
              border: Border.all(color: _borderColor),
              boxShadow: [
                BoxShadow(
                  color: _primaryBlue.withValues(alpha: 0.06),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 58.w,
                  height: 58.w,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [_primaryBlue, _ctaCyan],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(18.r),
                  ),
                  child: Icon(
                    Icons.rate_review_outlined,
                    color: Colors.white,
                    size: 30.sp,
                  ),
                ),
                SizedBox(height: 16.h),
                Text(
                  'Be the first to review this merchant',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _headingColor,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w900,
                    fontFamily: 'Sans',
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'Share your experience and help other TouristSaver members discover great places.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _bodyColor,
                    fontSize: 13.5.sp,
                    fontWeight: FontWeight.w600,
                    height: 1.35,
                    fontFamily: 'Sans',
                  ),
                ),
              ],
            ),
          ),
        ),
      );

  Widget reviewerName(String text) => Column(
        children: [
          Text(
            _displayName(text),
            style: TextStyle(
              color: _headingColor,
              fontWeight: FontWeight.w800,
              fontSize: 16.sp,
              fontFamily: 'Sans',
            ),
          ),
        ],
      );

  Widget reviewDescription(String text) => Column(
        children: [
          Text(
            text,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: _bodyColor,
              fontSize: 14.sp,
              height: 1.35,
              fontFamily: 'Sans',
            ),
          ),
        ],
      );

  String _displayName(String name) {
    return name
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .map((part) => part[0].toUpperCase() + part.substring(1))
        .join(' ');
  }

  Widget _ratingBar(String mode) {
    return RatingBar.builder(
      ignoreGestures: true,
      initialRating: double.parse(mode),
      minRating: 0,
      allowHalfRating: true,
      direction: Axis.horizontal,
      unratedColor: Colors.orange.withAlpha(50),
      itemCount: 5,
      itemSize: 20.0,
      itemBuilder: (context, _) => Icon(
        _selectedIcon ?? Icons.star,
        color: Colors.orange,
      ),
      onRatingUpdate: (rating) {},
    );
  }
}
