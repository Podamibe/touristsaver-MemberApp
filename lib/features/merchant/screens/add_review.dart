import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:touristsaver/common/widgets/custom_button.dart';
import 'package:touristsaver/common/widgets/custom_container_box.dart';
import 'package:touristsaver/constants/helper.dart';
import 'package:touristsaver/constants/style.dart';
import '../../../common/widgets/custom_app_bar.dart';
import '../../../common/widgets/custom_snackbar.dart';
import '../../../models/request/rate_merchant_req.dart';
import '../services/dio_reviews.dart';
import 'package:touristsaver/generated/l10n.dart';

class FeedbackScreen extends StatefulWidget {
  static const String routeName = '/feedback-screen';
  const FeedbackScreen({
    super.key,
    this.merchantId,
    this.merchantName,
    this.merchantLogo,
  });
  final String? merchantId;
  final String? merchantName;
  final String? merchantLogo;

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
  static const Color _selectedStarGold = Color(0xFFFFC83D);
  static const Color _unselectedStarGrey = Color(0xFFC7CDD8);
  static const List<String> _positiveFeedbackOptions = [
    'Great Deals',
    'Friendly and Helpful Staff',
    'Excellent Service',
    'Amazing Products',
    'Clean Venue',
    'Would Visit Again',
  ];
  static const List<String> _constructiveFeedbackOptions = [
    'Long Wait Time',
    'Service Could Improve',
    'Difficult Parking',
    'Venue Busy',
    'Not As Expected',
    'Could Be Better',
  ];
  static const String _reviewSuccessMessage =
      '⭐ Thank you for your review\n\nYour feedback helps other TouristSaver members discover great merchants.';

  late double _rating;
  final int _ratingBarMode = 0;
  final double _initialRating = 0;
  final TextEditingController _commentController = TextEditingController();
  IconData? _selectedIcon;
  final Set<String> _selectedFeedbackOptions = <String>{};
  bool reviewLoading = false;

  @override
  void initState() {
    super.initState();
    _rating = _initialRating;
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String merchantName = widget.merchantName?.trim().isNotEmpty == true
        ? widget.merchantName!.trim()
        : 'this merchant';
    final String? merchantLogo = _normalizedMerchantLogo(widget.merchantLogo);

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
      body: Column(
        children: [
          Expanded(
            child: CustomContainerBox(
              padVer: 10.h,
              child: SingleChildScrollView(
                padding: EdgeInsets.only(bottom: 18.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _merchantHeader(merchantName, merchantLogo),
                    SizedBox(height: 8.h),
                    Text(
                      S.of(context).rateThisMerchant,
                      style: topicStyle.copyWith(
                        color: _headingColor,
                        fontSize: 18.sp,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Center(child: _ratingBar(_ratingBarMode)),
                    SizedBox(height: 7.h),
                    const Divider(thickness: 1, color: _borderColor),
                    SizedBox(height: 7.h),
                    Text(
                      S.of(context).yourFeedback,
                      style: topicStyle.copyWith(
                        color: _headingColor,
                        fontSize: 15.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 3.h),
                    Text(
                      'Choose any that describe your experience.',
                      style: TextStyle(
                        color: _bodyColor,
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Sans',
                      ),
                    ),
                    SizedBox(height: 8.h),
                    _choiceChips(),
                    SizedBox(height: 10.h),
                    _optionalCommentField(),
                  ],
                ),
              ),
            ),
          ),
          _StickySubmitBar(
            isLoading: reviewLoading,
            child: _GradientReviewButton(
              text: S.of(context).sendReview,
              onPressed: onSendReview,
            ),
          ),
        ],
      ),
    );
  }

  Widget _merchantHeader(String merchantName, String? merchantLogo) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: _borderColor),
        boxShadow: [
          BoxShadow(
            color: _primaryBlue.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          _merchantAvatar(merchantLogo),
          SizedBox(width: 9.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Reviewing',
                  style: TextStyle(
                    color: _bodyColor,
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Sans',
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  merchantName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: _headingColor,
                    fontSize: 17.sp,
                    fontWeight: FontWeight.w900,
                    fontFamily: 'Sans',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _merchantAvatar(String? imageUrl) {
    return Container(
      width: 48.w,
      height: 48.w,
      decoration: BoxDecoration(
        color: const Color(0xFFEFF7FF),
        borderRadius: BorderRadius.circular(16.r),
      ),
      clipBehavior: Clip.antiAlias,
      child: imageUrl == null
          ? Icon(
              Icons.storefront_outlined,
              color: _primaryBlue,
              size: 28.sp,
            )
          : CachedNetworkImage(
              imageUrl: imageUrl,
              fit: BoxFit.cover,
              errorWidget: (context, url, error) => Icon(
                Icons.storefront_outlined,
                color: _primaryBlue,
                size: 28.sp,
              ),
            ),
    );
  }

  Widget _choiceChips() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _feedbackSection(
          label: 'Positive Feedback',
          options: _positiveFeedbackOptions,
        ),
        Padding(
          padding: EdgeInsets.symmetric(vertical: 9.h),
          child: const Divider(
            height: 1,
            thickness: 1,
            color: Color(0xFFE5EAF2),
          ),
        ),
        _feedbackSection(
          label: 'Constructive Feedback',
          options: _constructiveFeedbackOptions,
        ),
      ],
    );
  }

  Widget _feedbackSection({
    required String label,
    required List<String> options,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: _headingColor,
            fontSize: 12.5.sp,
            fontWeight: FontWeight.w900,
            fontFamily: 'Sans',
          ),
        ),
        SizedBox(height: 6.h),
        _feedbackChips(options),
      ],
    );
  }

  Widget _feedbackChips(List<String> options) {
    return Wrap(
      spacing: 8.w,
      runSpacing: 6.h,
      children: options.map((item) {
        final bool selected = _selectedFeedbackOptions.contains(item);
        return ChoiceChip(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          visualDensity: const VisualDensity(horizontal: -1, vertical: -3),
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
              if (isChipSelected) {
                _selectedFeedbackOptions.add(item);
              } else {
                _selectedFeedbackOptions.remove(item);
              }
            });
          },
        );
      }).toList(),
    );
  }

  Widget _optionalCommentField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Additional Comments (Optional)',
          style: TextStyle(
            color: _headingColor,
            fontSize: 14.sp,
            fontWeight: FontWeight.w900,
            fontFamily: 'Sans',
          ),
        ),
        SizedBox(height: 6.h),
        TextField(
          controller: _commentController,
          maxLength: 100,
          maxLines: 1,
          minLines: 1,
          cursorColor: _primaryBlue,
          decoration: InputDecoration(
            hintText: 'Share a brief note',
            hintStyle: TextStyle(
              color: _bodyColor.withValues(alpha: 0.72),
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              fontFamily: 'Sans',
            ),
            counterText: '',
            filled: true,
            fillColor: const Color(0xFFF7FAFE),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 14.w,
              vertical: 10.h,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16.r),
              borderSide: const BorderSide(color: _borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16.r),
              borderSide: const BorderSide(color: _primaryBlue, width: 1.4),
            ),
          ),
        ),
      ],
    );
  }

  Widget _ratingBar(int mode) {
    return RatingBar.builder(
      initialRating: 0,
      minRating: 0,
      direction: Axis.horizontal,
      allowHalfRating: true,
      unratedColor: _unselectedStarGrey,
      itemCount: 5,
      itemSize: 30.0,
      itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
      itemBuilder: (context, _) => Icon(
        _selectedIcon ?? Icons.star_rounded,
        color: _selectedStarGold,
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

    final String? reviewPayload = _reviewPayload();

    if (_rating == 0.0 && reviewPayload == null) {
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
              review: reviewPayload));
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

  String? _normalizedMerchantLogo(String? imageUrl) {
    final String? trimmed = imageUrl?.trim();
    if (trimmed == null || trimmed.isEmpty || trimmed == 'null') return null;
    if (trimmed.startsWith('//')) return 'https:$trimmed';

    final Uri? parsed = Uri.tryParse(trimmed);
    if (parsed == null) return trimmed;
    if (parsed.hasScheme) return trimmed;

    final Uri apiHost = Uri.parse(baseUrl);
    final String imagePath = trimmed.startsWith('/') ? trimmed : '/$trimmed';
    return apiHost.replace(path: imagePath, query: '', fragment: '').toString();
  }

  String? _reviewPayload() {
    final List<String> selectedFeedback = [
      ..._positiveFeedbackOptions
          .where((item) => _selectedFeedbackOptions.contains(item)),
      ..._constructiveFeedbackOptions
          .where((item) => _selectedFeedbackOptions.contains(item)),
    ];
    final String feedbackText = selectedFeedback.join(', ');
    final String note = _commentController.text.trim();

    if (feedbackText.isEmpty && note.isEmpty) return null;
    if (note.isEmpty) return feedbackText;
    if (feedbackText.isEmpty) return 'Note: $note';
    return '$feedbackText | Note: $note';
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

class _StickySubmitBar extends StatelessWidget {
  const _StickySubmitBar({
    required this.isLoading,
    required this.child,
  });

  final bool isLoading;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 12.h),
        decoration: BoxDecoration(
          color: Colors.white,
          border: const Border(
            top: BorderSide(color: _FeedbackScreenState._borderColor),
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0A236B).withValues(alpha: 0.08),
              blurRadius: 18,
              offset: const Offset(0, -8),
            ),
          ],
        ),
        child: isLoading ? const CustomButtonWithCircular() : child,
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
