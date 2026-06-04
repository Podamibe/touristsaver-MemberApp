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
import '../../../constants/global_colors.dart';
import '../../../models/error_res.dart';
import '../../../models/response/get_all_merchant_reviews.dart';
import 'package:dartz/dartz.dart' as dartz;
import 'package:touristsaver/generated/l10n.dart';

class MerchantRating extends StatefulWidget {
  static const String routeName = '/merchant-rating';
  const MerchantRating({super.key, this.merchantId});
  final String? merchantId;

  @override
  State<MerchantRating> createState() => _MerchantRatingState();
}

class _MerchantRatingState extends State<MerchantRating> {
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
                                shrinkWrap: true,
                                itemCount: r.data!.length,
                                itemBuilder: (context, index) {
                                  var data = r.data!.elementAt(index);
                                  return Padding(
                                    padding: const EdgeInsets.all(5.0),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 15.0, vertical: 5.0),
                                      decoration: BoxDecoration(
                                          color: Colors.white,
                                          boxShadow: const [
                                            BoxShadow(
                                                color: GlobalColors.gray,
                                                blurRadius: 0.1,
                                                offset: Offset(0.5, 0.5))
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
                                                AutoSizeText(DateFormat.yMMMd()
                                                    .format(data.createdAt!))
                                              ],
                                            ),
                                            reviewerName(
                                                data.member!.firstname!),
                                            SizedBox(height: 5.h),
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
                    : SizedBox(
                        child:
                            Center(child: Text(S.of(context).noReviewsToShow)),
                      );
              });
            }
          }),
      floatingActionButton: AppVariables.accessToken == null
          ? null
          : Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: GlobalColors.appColor1),
              child: MaterialButton(
                  child: Text(
                    S.of(context).addReview,
                    maxLines: 1,
                    style: buttonText,
                  ),
                  onPressed: () {
                    context.pushNamed('feedback-screen',
                        extra: {'merchantId': widget.merchantId});
                  })),
    );
  }

  Widget reviewerName(String text) => Column(
        children: [
          Text(
            text,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 16.0,
            ),
          ),
        ],
      );

  Widget reviewDescription(String text) => Column(
        children: [
          Text(
            text,
            style: const TextStyle(
              fontWeight: FontWeight.w400,
              color: GlobalColors.textColor,
              fontSize: 14.0,
            ),
          ),
        ],
      );

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
