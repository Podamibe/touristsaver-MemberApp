import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:touristsaver/common/app_variables.dart';
import 'package:touristsaver/common/navigation/safe_primary_navigation.dart';
import 'package:touristsaver/common/widgets/custom_app_bar.dart';
import 'package:touristsaver/common/widgets/custom_snackbar.dart';
import 'package:touristsaver/common/widgets/touristsaver_loading_view.dart';
import 'package:touristsaver/constants/helper.dart';
import 'package:touristsaver/features/discovery_membership/widgets/discovery_savings_limit_sheet.dart';
import 'package:touristsaver/features/payment/services/dio_payment.dart';
import 'package:touristsaver/features/payment/widgets/merchant_claim_proximity_fallback.dart';
import 'package:touristsaver/models/error_res.dart';
import 'package:touristsaver/models/request/apply_piiink_by_merchant_req.dart';
import 'package:touristsaver/models/request/sure_apply_piiink_req.dart';
import 'package:touristsaver/models/response/confirm_piiink_res.dart';
import 'package:touristsaver/models/response/sure_apply_piiink_res.dart';

class ConfimrPaymentScreen extends StatefulWidget {
  static const String routeName = '/confirm-pay';

  final String totalAmount;
  final String qrCode;
  final String hasMerchantPiiinks;
  final String hasUniversalPiiinks;
  final String merchantName;
  final String universalPiiinkBalance;
  final String merchantPiiinkBalance;
  final String merchantRebateToMember;
  final String merchantDiscountPercentage;
  final String discountedTransactionAmount;
  final String totalPiiinkDiscount;
  final String? logo;
  final String universalPiiinkOnHold;
  final String merchantPiiinkOnHold;
  final int? terminalUserId;
  final int? terminalId;
  final int? merchantId;
  final bool returnToSearch;
  final bool isProfileClaim;
  final bool initialRedemptionComplete;
  final String? discoverySavingsMessage;
  final double? claimLatitude;
  final double? claimLongitude;

  const ConfimrPaymentScreen({
    super.key,
    required this.totalAmount,
    required this.qrCode,
    required this.hasMerchantPiiinks,
    required this.hasUniversalPiiinks,
    required this.merchantName,
    required this.universalPiiinkBalance,
    required this.merchantPiiinkBalance,
    required this.merchantRebateToMember,
    required this.merchantDiscountPercentage,
    required this.discountedTransactionAmount,
    required this.totalPiiinkDiscount,
    required this.logo,
    required this.universalPiiinkOnHold,
    required this.merchantPiiinkOnHold,
    this.terminalUserId,
    this.terminalId,
    this.merchantId,
    this.returnToSearch = false,
    this.isProfileClaim = false,
    this.initialRedemptionComplete = false,
    this.discoverySavingsMessage,
    this.claimLatitude,
    this.claimLongitude,
  });

  @override
  State<ConfimrPaymentScreen> createState() => _ConfimrPaymentScreenState();
}

class _ConfimrPaymentScreenState extends State<ConfimrPaymentScreen> {
  static const Color _primaryBlue = Color(0xFF0009FE);
  static const Color _ctaCyan = Color(0xFF18C6FF);
  static const Color _screenBackground = Color(0xFFF8FAFE);
  static const Color _headingColor = Color(0xFF111C44);
  static const Color _bodyColor = Color(0xFF61708A);
  static const Color _borderColor = Color(0xFFE2E8F3);
  static const Color _successGreen = Color(0xFF159455);

  final NumberFormat _currencyFormat = NumberFormat.currency(
    symbol: AppVariables.currency ?? '\$',
    decimalDigits: 2,
  );
  final NumberFormat _numberFormat = NumberFormat('#,##0.##');
  final DateFormat _liveDateFormat = DateFormat('d MMMM yyyy');
  final DateFormat _liveTimeFormat = DateFormat('h:mm:ss a');

  bool isLoading = false;
  late bool _redemptionComplete = widget.initialRedemptionComplete;
  bool _reviewInvitationShown = false;
  DateTime _now = DateTime.now();
  Timer? _clockTimer;

  double get _billAmount => double.tryParse(widget.totalAmount) ?? 0;
  double get _memberSavings => double.tryParse(widget.totalPiiinkDiscount) ?? 0;
  double get _customerPays =>
      double.tryParse(widget.discountedTransactionAmount) ?? 0;
  double get _discountPercent =>
      double.tryParse(widget.merchantDiscountPercentage) ?? 0;
  bool get _canLeaveReview =>
      widget.merchantId != null && widget.merchantName.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        _now = DateTime.now();
      });
    });
  }

  @override
  void dispose() {
    _clockTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop || isLoading) return;
        if (_redemptionComplete) {
          _finishToSavings();
        } else {
          _editBillAmount();
        }
      },
      child: Scaffold(
        backgroundColor: _screenBackground,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight),
          child: CustomAppBar(
            text: 'Member Payment',
            icon: Icons.arrow_back_ios,
            titleIcon: Icons.check_circle_rounded,
            titleIconColor: _successGreen,
            onPressed: isLoading ? null : _editBillAmount,
          ),
        ),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  key: const Key('claim-completion-content-scroll'),
                  padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 12.h),
                  child: _merchantPresentationCard(),
                ),
              ),
              Container(
                key: const Key('claim-completion-actions'),
                padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 16.h),
                decoration: const BoxDecoration(
                  color: _screenBackground,
                  border: Border(top: BorderSide(color: _borderColor)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    isLoading
                        ? TouristSaverLoadingView(height: 54.h, spinnerSize: 24)
                        : _GradientButton(
                            label: 'Close',
                            onTap: _completeAndFinish,
                          ),
                    if (!_redemptionComplete) ...[
                      SizedBox(height: 10.h),
                      _OutlinedButton(
                        label: 'Edit Bill Amount',
                        icon: Icons.edit_outlined,
                        onTap: _editBillAmount,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _merchantPresentationCard() {
    return _PresentationCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: _AnimatedTouristSaverPaymentLogo(),
          ),
          SizedBox(height: 14.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _merchantLogo(),
              SizedBox(width: 14.w),
              Flexible(
                child: Text(
                  widget.merchantName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: _headingColor,
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w900,
                    fontFamily: 'Sans',
                    height: 1.18,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          _livePreparedTime(),
          SizedBox(height: 18.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 20.h),
            decoration: BoxDecoration(
              color: const Color(0xFFF2F7FF),
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(color: const Color(0xFFDCE8FF)),
            ),
            child: Column(
              children: [
                Text(
                  'Amount to Pay',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _headingColor,
                    fontSize: 17.sp,
                    fontWeight: FontWeight.w800,
                    fontFamily: 'Sans',
                  ),
                ),
                SizedBox(height: 5.h),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    _formatCurrency(_customerPays),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: _primaryBlue,
                      fontSize: 45.sp,
                      fontWeight: FontWeight.w900,
                      fontFamily: 'Sans',
                      letterSpacing: -1.2,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20.h),
          if (widget.discoverySavingsMessage?.trim().isNotEmpty == true) ...[
            Container(
              padding: EdgeInsets.all(14.w),
              decoration: BoxDecoration(
                color: const Color(0xFFEAF4FF),
                borderRadius: BorderRadius.circular(14.r),
                border: Border.all(color: const Color(0xFFB9D8FF)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    color: _primaryBlue,
                    size: 21.sp,
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Text(
                      widget.discoverySavingsMessage!,
                      style: TextStyle(
                        color: _headingColor,
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Sans',
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 18.h),
          ],
          _summaryRow('Original Bill', _formatCurrency(_billAmount)),
          SizedBox(height: 12.h),
          if (widget.discoverySavingsMessage?.trim().isNotEmpty == true) ...[
            _summaryRow(
              'Merchant offer',
              '${_numberFormat.format(_discountPercent)}%',
            ),
            SizedBox(height: 12.h),
            _summaryRow(
              'Discovery Saving',
              _formatCurrency(_memberSavings),
              savings: true,
            ),
          ] else
            _summaryRow(
              'You Save',
              '${_formatCurrency(_memberSavings)} (${_numberFormat.format(_discountPercent)}%)',
              savings: true,
            ),
          SizedBox(height: 16.h),
          Text(
            'Show this screen to the cashier.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _headingColor,
              fontSize: 14.sp,
              fontWeight: FontWeight.w900,
              fontFamily: 'Sans',
            ),
          ),
        ],
      ),
    );
  }

  Widget _merchantLogo() {
    final String? logoUrl = _normalizedMerchantLogo(widget.logo);

    return Container(
      width: 62.w,
      height: 62.w,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17.r),
        border: Border.all(color: _borderColor),
      ),
      clipBehavior: Clip.antiAlias,
      child: logoUrl == null
          ? _fallbackMerchantLogo()
          : CachedNetworkImage(
              imageUrl: logoUrl,
              fit: BoxFit.contain,
              errorWidget: (context, url, error) => _fallbackMerchantLogo(),
            ),
    );
  }

  Widget _livePreparedTime() {
    return Column(
      children: [
        Text(
          _liveDateFormat.format(_now),
          textAlign: TextAlign.center,
          style: TextStyle(
            color: _bodyColor,
            fontSize: 13.sp,
            fontWeight: FontWeight.w800,
            fontFamily: 'Sans',
            height: 1.2,
          ),
        ),
        SizedBox(height: 3.h),
        Text(
          _liveTimeFormat.format(_now),
          textAlign: TextAlign.center,
          style: TextStyle(
            color: _headingColor,
            fontSize: 14.sp,
            fontWeight: FontWeight.w900,
            fontFamily: 'Sans',
            letterSpacing: 0.2,
            height: 1.2,
          ),
        ),
      ],
    );
  }

  Widget _fallbackMerchantLogo() {
    return Icon(
      Icons.storefront_rounded,
      color: _primaryBlue,
      size: 31.sp,
    );
  }

  Widget _summaryRow(String label, String value, {bool savings = false}) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: _bodyColor,
              fontSize: 14.sp,
              fontWeight: FontWeight.w700,
              fontFamily: 'Sans',
            ),
          ),
        ),
        SizedBox(width: 12.w),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(
              color: savings ? _successGreen : _headingColor,
              fontSize: 15.sp,
              fontWeight: FontWeight.w900,
              fontFamily: 'Sans',
            ),
          ),
        ),
      ],
    );
  }

  void _completeAndFinish() {
    if (_redemptionComplete) {
      _finishToSavings();
      return;
    }
    if (widget.isProfileClaim) {
      _redeemProfileClaim(onSuccess: _showReviewInvitation);
      return;
    }
    _redeemDiscount(onSuccess: _showReviewInvitation);
  }

  Future<void> _redeemProfileClaim({required VoidCallback onSuccess}) async {
    if (isLoading) return;

    final int? merchantId = widget.merchantId;
    if (merchantId == null) {
      GlobalSnackBar.showError(
        context,
        'The discount could not be redeemed for this merchant.',
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    final res = await DioPay().applyPiiinkByMerchant(
      applyPiiinkByMerchantReqModel: ApplyPiiinkByMerchantReqModel(
        merchantId: merchantId,
        amount: double.parse(widget.totalAmount),
        lang: AppVariables.selectedLanguageNow,
        latitude: widget.claimLatitude,
        longitude: widget.claimLongitude,
      ),
    );

    if (!mounted) return;

    if (res is ConfirmApplyPiiinkResModel && res.status == 'Success') {
      _markRedemptionComplete();
      onSuccess();
    } else {
      setState(() {
        isLoading = false;
      });
      final MerchantClaimProximityFailure? proximityFailure =
          MerchantClaimProximityFailure.fromResponse(res);
      if (proximityFailure != null) {
        final bool scanQr = await showMerchantClaimProximityFallback(
          context: context,
          merchantName: widget.merchantName,
        );
        if (!mounted || !scanQr) return;
        context.pushReplacementNamed(
          'pay',
          extra: merchantClaimQrRouteExtra(
            merchantName: widget.merchantName,
            amount: widget.totalAmount,
            returnToSearch: widget.returnToSearch,
          ),
        );
        return;
      }
      if (await showDiscoverySavingsLimitSheetForResponse(
        context: context,
        response: res,
      )) {
        return;
      }
      if (!mounted) return;
      GlobalSnackBar.showError(
        context,
        _responseMessage(res) ?? 'The discount could not be redeemed.',
      );
    }
  }

  Future<void> _redeemDiscount({required VoidCallback onSuccess}) async {
    if (isLoading) return;

    setState(() {
      isLoading = true;
    });

    final res = await DioPay().sureApplyPiiink(
      payToMainMerchant: widget.terminalUserId == null,
      sureApplyPiiinkReqModel: SureApplyPiiinkReqModel(
        totalAmount: double.parse(widget.totalAmount),
        piiinkWalletType: 'universalWallet',
        transactionQrCode: widget.qrCode,
        hour: int.parse(DateFormat('HH ').format(DateTime.now())),
        week: DateTime.now().weekday % 7,
        terminalUserId: widget.terminalUserId,
        terminalId: widget.terminalId,
      ),
    );

    if (!mounted) return;

    if (res is SureApplyPiiinkResModel && res.status == 'Success') {
      _markRedemptionComplete();
      onSuccess();
    } else {
      setState(() {
        isLoading = false;
      });
      if (await showDiscoverySavingsLimitSheetForResponse(
        context: context,
        response: res,
      )) {
        return;
      }
      if (!mounted) return;
      GlobalSnackBar.showError(
        context,
        _responseMessage(res) ?? 'The discount could not be redeemed.',
      );
    }
  }

  void _markRedemptionComplete() {
    setState(() {
      isLoading = false;
      _redemptionComplete = true;
    });
    AppVariables.payAmountResetSignal.value++;
  }

  void _finishToSavings() {
    navigateToBottomTab(context, 3);
  }

  Future<void> _showReviewInvitation() async {
    if (!mounted) return;
    if (!_canLeaveReview || _reviewInvitationShown) {
      _finishToSavings();
      return;
    }

    _reviewInvitationShown = true;

    final bool leaveReview = await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (dialogContext) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(22),
              ),
              title: Text(
                'How was your experience at ${widget.merchantName}?',
                style: const TextStyle(
                  color: _headingColor,
                  fontWeight: FontWeight.w900,
                  fontFamily: 'Sans',
                ),
              ),
              content: const Text(
                'Your review helps other TouristSaver members discover great places and contributes to your Community recognition.',
                style: TextStyle(
                  color: _bodyColor,
                  fontWeight: FontWeight.w600,
                  height: 1.35,
                  fontFamily: 'Sans',
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(false),
                  child: const Text('Maybe Later'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(true),
                  child: const Text('Leave a Review'),
                ),
              ],
            );
          },
        ) ??
        false;

    if (!mounted) return;

    if (leaveReview) {
      _openReview();
      return;
    }

    _finishToSavings();
  }

  void _openReview() {
    context.pushNamed(
      'feedback-screen',
      extra: {
        'merchantId': widget.merchantId.toString(),
        'merchantName': widget.merchantName,
        'merchantLogo': widget.logo,
      },
    );
  }

  void _editBillAmount() {
    if (isLoading) return;
    FocusManager.instance.primaryFocus?.unfocus();

    if (widget.isProfileClaim) {
      context.pop({
        'editRequested': true,
        'billAmount': widget.totalAmount,
      });
      return;
    }

    if (context.canPop()) {
      context.pop(true);
      return;
    }

    context.goNamed(
      'bottom-bar',
      pathParameters: {'page': '2'},
    );
  }

  String? _responseMessage(dynamic res) {
    if (res is ErrorResModel) {
      return res.message ?? res.error?.status?.toString();
    }
    return null;
  }

  String _formatCurrency(num value) {
    return _currencyFormat.format(value);
  }

  String? _normalizedMerchantLogo(String? imageUrl) {
    final String? trimmed = imageUrl?.trim();
    if (trimmed == null || trimmed.isEmpty) return null;
    final String lower = trimmed.toLowerCase();
    if (lower == 'null' || lower == 'undefined') return null;
    if (trimmed.startsWith('//')) return 'https:$trimmed';

    final Uri? parsed = Uri.tryParse(trimmed);
    if (parsed == null) return trimmed;
    if (parsed.hasScheme) return trimmed;

    final Uri apiHost = Uri.parse(baseUrl);
    final String imagePath = trimmed.startsWith('/') ? trimmed : '/$trimmed';
    return apiHost.replace(path: imagePath, query: '', fragment: '').toString();
  }
}

class _PresentationCard extends StatelessWidget {
  const _PresentationCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(20.w, 18.h, 20.w, 20.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26.r),
        border: Border.all(color: _ConfimrPaymentScreenState._borderColor),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0A236B).withValues(alpha: 0.07),
            blurRadius: 22,
            offset: const Offset(0, 11),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _AnimatedTouristSaverPaymentLogo extends StatefulWidget {
  const _AnimatedTouristSaverPaymentLogo();

  @override
  State<_AnimatedTouristSaverPaymentLogo> createState() =>
      _AnimatedTouristSaverPaymentLogoState();
}

class _AnimatedTouristSaverPaymentLogoState
    extends State<_AnimatedTouristSaverPaymentLogo>
    with TickerProviderStateMixin {
  late final AnimationController _ringController = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 7),
  )..repeat();

  late final AnimationController _pulseController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2600),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _ringController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 258.w,
      height: 104.h,
      child: Stack(
        alignment: Alignment.center,
        children: [
          FadeTransition(
            opacity: Tween<double>(begin: 0.18, end: 0.34).animate(
              CurvedAnimation(
                parent: _pulseController,
                curve: Curves.easeInOut,
              ),
            ),
            child: Container(
              width: 214.w,
              height: 74.h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(40.r),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFD9A441).withValues(alpha: 0.42),
                    blurRadius: 28,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
          ),
          RotationTransition(
            turns: _ringController,
            child: Container(
              width: 238.w,
              height: 90.h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(46.r),
                gradient: const SweepGradient(
                  colors: [
                    Color(0xFFEACB73),
                    Color(0xFFFFF3BE),
                    Color(0xFFC8932F),
                    Color(0xFFF5D77C),
                    Color(0xFFEACB73),
                  ],
                  stops: [0, 0.28, 0.55, 0.82, 1],
                ),
              ),
            ),
          ),
          Container(
            width: 228.w,
            height: 80.h,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(42.r),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0A236B).withValues(alpha: 0.08),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            child: Image.asset(
              'assets/images/touristSaver.png',
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
    );
  }
}

class _GradientButton extends StatelessWidget {
  const _GradientButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18.r),
        onTap: onTap,
        child: Ink(
          height: 56.h,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                _ConfimrPaymentScreenState._primaryBlue,
                _ConfimrPaymentScreenState._ctaCyan,
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(18.r),
            boxShadow: [
              BoxShadow(
                color: _ConfimrPaymentScreenState._primaryBlue
                    .withValues(alpha: 0.22),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18.sp,
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

class _OutlinedButton extends StatelessWidget {
  const _OutlinedButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18.r),
        onTap: onTap,
        child: Ink(
          height: 54.h,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18.r),
            border: Border.all(
              color: _ConfimrPaymentScreenState._primaryBlue,
              width: 1.2,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: _ConfimrPaymentScreenState._primaryBlue,
                size: 20.sp,
              ),
              SizedBox(width: 9.w),
              Text(
                label,
                style: TextStyle(
                  color: _ConfimrPaymentScreenState._primaryBlue,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w900,
                  fontFamily: 'Sans',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
