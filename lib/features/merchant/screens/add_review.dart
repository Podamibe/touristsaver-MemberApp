import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:touristsaver/common/widgets/custom_button.dart';
import 'package:touristsaver/common/widgets/custom_container_box.dart';
import 'package:touristsaver/constants/style.dart';
import '../../../common/widgets/custom_app_bar.dart';
import '../../../common/widgets/custom_snackbar.dart';
import '../../../constants/global_colors.dart';
import '../../../models/request/rate_merchant_req.dart';
import '../services/dio_reviews.dart';
import 'package:touristsaver/generated/l10n.dart';

class FeedbackScreen extends StatefulWidget {
  static const String routeName = '/feedback-screen';
  const FeedbackScreen({super.key, this.merchantId});
  final String? merchantId;

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  static const List<String> _feedbackOptions = [
    'Great Value',
    'Friendly Staff',
    'Excellent Service',
    'Quality Products',
    'Clean Venue',
    'Would Visit Again',
  ];
  static const String _reviewSuccessMessage =
      '⭐ Thank you for your review\n\nYour feedback helps other TouristSaver members discover great merchants.';

  late double _rating;
  final int _ratingBarMode = 0;
  final double _initialRating = 0;
  IconData? _selectedIcon;
  int? _defaultChoiceIndex;
  String? selectedString;
  bool reviewLoading = false;
  bool isSelected = false;

  @override
  void initState() {
    super.initState();
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
    return Wrap(
      spacing: 8.w,
      runSpacing: 8.h,
      children: _feedbackOptions.map((item) {
        final int index = _feedbackOptions.indexOf(item);
        final bool selected = _defaultChoiceIndex == index && isSelected;
        return ChoiceChip(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 9.h),
          selectedColor: GlobalColors.appColor1,
          label: Text(
            item,
            overflow: TextOverflow.ellipsis,
          ),
          selected: selected,
          shape: RoundedRectangleBorder(
            side: BorderSide(
              color:
                  selected ? GlobalColors.appColor1 : const Color(0xFFE2E8F3),
            ),
            borderRadius: BorderRadius.circular(16.r),
          ),
          backgroundColor: const Color(0xFFF7FAFE),
          labelStyle: TextStyle(
            color: selected
                ? GlobalColors.appWhiteBackgroundColor
                : GlobalColors.appColor1,
            fontWeight: FontWeight.w700,
          ),
          onSelected: (bool isChipSelected) {
            setState(() {
              _defaultChoiceIndex = isChipSelected ? index : null;
              isSelected = isChipSelected;
              selectedString = isChipSelected ? item : null;
            });
          },
        );
      }).toList(),
    );
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
          GlobalSnackBar.showSuccess(context, _reviewSuccessMessage);
          setState(() {
            reviewLoading = false;
          });
          context.pop();
        }
      });
    }
  }
}
