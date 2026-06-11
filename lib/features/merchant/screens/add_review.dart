import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:touristsaver/common/widgets/custom_button.dart';
import 'package:touristsaver/common/widgets/custom_container_box.dart';
import 'package:touristsaver/constants/style.dart';
import '../../../common/widgets/custom_app_bar.dart';
import '../../../common/widgets/custom_snackbar.dart';
import '../../../models/request/rate_merchant_req.dart';
import '../services/dio_reviews.dart';
import 'package:touristsaver/generated/l10n.dart';

class FeedbackScreen extends StatefulWidget {
  static const String routeName = '/feedback-screen';
  const FeedbackScreen({super.key, this.merchantId, this.merchantName});
  final String? merchantId;
  final String? merchantName;

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  static const Color _primaryBlue = Color(0xFF0009FE);
  static const Color _ctaCyan = Color(0xFF18C6FF);
  static const Color _headingColor = Color(0xFF111C44);
  static const Color _bodyColor = Color(0xFF61708A);
  static const Color _borderColor = Color(0xFFE2E8F3);
  static const Color _chipBackground = Color(0xFFF5F8FF);
  static const Color _selectedChipBackground = Color(0xFFEAF7FF);
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
    final String merchantName = widget.merchantName?.trim().isNotEmpty == true
        ? widget.merchantName!.trim()
        : 'this merchant';

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
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: _borderColor),
                boxShadow: [
                  BoxShadow(
                    color: _primaryBlue.withValues(alpha: 0.06),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Reviewing',
                    style: TextStyle(
                      color: _bodyColor,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Sans',
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    merchantName,
                    style: TextStyle(
                      color: _headingColor,
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w900,
                      fontFamily: 'Sans',
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 18.h),
            Text(
              S.of(context).rateThisMerchant,
              style: topicStyle.copyWith(
                color: _headingColor,
                fontSize: 20.sp,
              ),
            ),
            SizedBox(height: 15.h),
            Center(child: _ratingBar(_ratingBarMode)),
            SizedBox(height: 15.h),
            const Divider(thickness: 1, color: _borderColor),
            SizedBox(height: 15.h),
            Text(
              S.of(context).yourFeedback,
              style: topicStyle.copyWith(
                color: _headingColor,
                fontSize: 15.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 5.h),
            Text(
              'Choose one that best describes your experience.',
              style: TextStyle(
                color: _bodyColor,
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                fontFamily: 'Sans',
              ),
            ),
            SizedBox(height: 14.h),
            _choiceChips(),
            SizedBox(height: 22.h),
            Center(
                child: reviewLoading == true
                    ? const CustomButtonWithCircular()
                    : _GradientReviewButton(
                        text: S.of(context).sendReview,
                        onPressed: () {
                          onSendReview();
                        },
                      )),
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
          selectedColor: _selectedChipBackground,
          showCheckmark: selected,
          checkmarkColor: _primaryBlue,
          label: Text(
            item,
            overflow: TextOverflow.ellipsis,
          ),
          selected: selected,
          shape: RoundedRectangleBorder(
            side: BorderSide(
              color: selected ? _primaryBlue : _borderColor,
              width: selected ? 1.4 : 1,
            ),
            borderRadius: BorderRadius.circular(16.r),
          ),
          backgroundColor: _chipBackground,
          labelStyle: TextStyle(
            color: selected ? _primaryBlue : _headingColor,
            fontWeight: selected ? FontWeight.w800 : FontWeight.w700,
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
          _showReviewSuccess();
          setState(() {
            reviewLoading = false;
          });
          context.pop();
        }
      });
    }
  }

  void _showReviewSuccess() {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          elevation: 0,
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.fromLTRB(16.w, 0, 16.w, 18.h),
          duration: const Duration(seconds: 4),
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
            side: const BorderSide(color: _borderColor),
          ),
          content: Text(
            _reviewSuccessMessage,
            style: TextStyle(
              color: _headingColor,
              fontSize: 14.sp,
              fontWeight: FontWeight.w700,
              height: 1.3,
              fontFamily: 'Sans',
            ),
          ),
          action: SnackBarAction(
            textColor: _primaryBlue,
            label: S.of(context).ok,
            onPressed: () {},
          ),
        ),
      );
  }
}

class _GradientReviewButton extends StatelessWidget {
  const _GradientReviewButton({
    required this.text,
    required this.onPressed,
  });

  final String text;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18.r),
        onTap: onPressed,
        child: Ink(
          height: 54.h,
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                _FeedbackScreenState._primaryBlue,
                _FeedbackScreenState._ctaCyan,
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(18.r),
            boxShadow: [
              BoxShadow(
                color: _FeedbackScreenState._primaryBlue.withValues(
                  alpha: 0.18,
                ),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16.sp,
                fontWeight: FontWeight.w900,
                fontFamily: 'Sans',
              ),
            ),
          ),
        ),
      ),
    );
  }
}
