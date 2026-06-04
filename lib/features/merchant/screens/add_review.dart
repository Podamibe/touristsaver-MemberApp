import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:touristsaver/common/widgets/custom_button.dart';
import 'package:touristsaver/common/widgets/custom_container_box.dart';
import 'package:touristsaver/constants/style.dart';
import 'package:touristsaver/models/response/get_all_reviews_suggestion.dart';
import '../../../common/widgets/custom_app_bar.dart';
import '../../../common/widgets/custom_loader.dart';
import '../../../common/widgets/custom_snackbar.dart';
import '../../../common/widgets/error.dart';
import '../../../constants/global_colors.dart';
import '../../../models/error_res.dart';
import '../../../models/request/rate_merchant_req.dart';
import '../services/dio_reviews.dart';
import 'package:dartz/dartz.dart' as dartz;
import 'package:touristsaver/generated/l10n.dart';

class FeedbackScreen extends StatefulWidget {
  static const String routeName = '/feedback-screen';
  const FeedbackScreen({super.key, this.merchantId});
  final String? merchantId;

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  late double _rating;
  final int _ratingBarMode = 0;
  final double _initialRating = 0;
  IconData? _selectedIcon;
  var _defaultChoiceIndex;
  String? selectedString;
  bool reviewLoading = false;
  bool isSelected = false;

// For filling the edit form
  Future<dartz.Either<ErrorResModel, GetAllReviewSuggestionResModel>?>?
      getReviews;
  Future<dartz.Either<ErrorResModel, GetAllReviewSuggestionResModel>?>?
      getSuggestionReview() async {
    dartz.Either<ErrorResModel, GetAllReviewSuggestionResModel>?
        getSuggestionReviewRes = await DioReviews().getAllReviews();

    return getSuggestionReviewRes!
        .fold((l) => getSuggestionReviewRes, (r) => getSuggestionReviewRes);
  }

  @override
  void initState() {
    super.initState();
    getReviews = getSuggestionReview();
    _rating = _initialRating;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: CustomAppBar(
          text: S.of(context).addReview,
          icon: Icons.arrow_back_ios,
          onPressed: (() {
            context.pop();
          }),
        ),
      ),
      body: CustomContainerBox(
        padVer: 25.h,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              S.of(context).rateThisMerchant,
              style: topicStyle.copyWith(fontSize: 20.sp),
            ),
            SizedBox(height: 15.h),
            Center(child: _ratingBar(_ratingBarMode)),
            SizedBox(height: 15.h),
            const Divider(
              thickness: 2,
            ),
            SizedBox(height: 15.h),
            Text(S.of(context).yourFeedback,
                style: topicStyle.copyWith(
                    fontSize: 15.sp, fontWeight: FontWeight.bold)),
            SizedBox(height: 15),
            _choiceChips(),
            SizedBox(height: 5),
            Center(
                child: reviewLoading == true
                    ? const CustomButtonWithCircular()
                    : CustomButton(
                        onPressed: () {
                          onSendReview();
                        },
                        text: S.of(context).sendReview)),
          ],
        ),
      ),
    );
  }

  Widget _choiceChips() {
    return FutureBuilder<
            dartz.Either<ErrorResModel, GetAllReviewSuggestionResModel>?>(
        future: getReviews,
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
              var realData = r.data?.where((x) => x.isActive == true).toList();
              return r.data!.isNotEmpty
                  ? Expanded(
                      child: SingleChildScrollView(
                        child: Wrap(
                          children: realData!.map((item) {
                            // log("Chip item: ${item.reviewText}");
                            return Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: ChoiceChip(
                                padding: EdgeInsets.all(10),
                                selectedColor: Colors.orange.shade300,
                                label: Text(
                                  item.reviewText ?? '',
                                  overflow: TextOverflow.ellipsis,
                                ),
                                selected: _defaultChoiceIndex ==
                                    realData.indexOf(item),
                                shape: RoundedRectangleBorder(
                                    side: const BorderSide(
                                        color: GlobalColors.appColor1),
                                    borderRadius: BorderRadius.circular(15)),
                                backgroundColor:
                                    GlobalColors.appWhiteBackgroundColor,
                                labelStyle: _defaultChoiceIndex ==
                                            realData.indexOf(item) &&
                                        isSelected
                                    ? const TextStyle(
                                        color: GlobalColors
                                            .appWhiteBackgroundColor)
                                    : const TextStyle(
                                        color: GlobalColors.appColor1),
                                onSelected: (bool selected) {
                                  setState(() {
                                    _defaultChoiceIndex =
                                        selected ? realData.indexOf(item) : 0;
                                    isSelected = true;
                                    selectedString = item.reviewText ?? '';
                                  });
                                },
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    )
                  : SizedBox();
            });
          }
        });
  }

  Widget _ratingBar(int mode) {
    return RatingBar.builder(
      initialRating: 0,
      minRating: 0,
      direction: Axis.horizontal,
      allowHalfRating: true,
      unratedColor: Colors.orange.withAlpha(50),
      itemCount: 5,
      itemSize: 30.0,
      itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
      itemBuilder: (context, _) => Icon(
        _selectedIcon ?? Icons.star,
        color: Colors.orange,
      ),
      onRatingUpdate: (rating) {
        setState(() {
          _rating = rating;
        });
      },
      updateOnDrag: true,
    );
  }

  onSendReview() async {
    setState(() {
      reviewLoading = true;
    });

    if (_rating == 0.0 && selectedString == null) {
      GlobalSnackBar.valid(
          context, S.of(context).pleaseRateThisMerchantOrProvideFeedback);
      setState(() {
        reviewLoading = false;
      });
    } else {
      var rez = await DioReviews().createMerchantReviews(
          rateMerchantReqModel: RateMerchantReqModel(
              rating: _rating,
              merchantId: int.parse(widget.merchantId!),
              review: selectedString));
      rez?.fold((l) {
        GlobalSnackBar.showError(context, l.message!);
        setState(() {
          reviewLoading = false;
        });
        return;
      }, (r) {
        if (r.status == 'Success') {
          GlobalSnackBar.showSuccess(
              context, S.of(context).reviewAddedSuccessfully);
          setState(() {
            reviewLoading = false;
          });
          context.pop();
        }
      });
    }
  }
}
