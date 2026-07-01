import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:touristsaver/common/app_variables.dart';
import 'package:touristsaver/common/navigation/safe_primary_navigation.dart';
import 'package:touristsaver/common/widgets/custom_app_bar.dart';
import 'package:touristsaver/constants/helper.dart';

class PaymentCompleted extends StatefulWidget {
  static const String routeName = "/payment-complete";
  final String merchantName;
  final String totalAmount;
  final String discountedTransactionAmount;
  final String totalPiiinkDiscount;
  final String merchantRebateToMember;
  final String merchantDiscountPercentage;
  final String walletType;
  final int? merchantId;
  final String? merchantLogo;

  const PaymentCompleted({
    super.key,
    required this.merchantName,
    required this.totalAmount,
    required this.discountedTransactionAmount,
    required this.totalPiiinkDiscount,
    required this.merchantRebateToMember,
    required this.merchantDiscountPercentage,
    required this.walletType,
    required this.merchantId,
    this.merchantLogo,
  });

  @override
  State<PaymentCompleted> createState() => _PaymentCompletedState();
}

class _PaymentCompletedState extends State<PaymentCompleted> {
  static const Color _primaryBlue = Color(0xFF0009FE);
  static const Color _ctaCyan = Color(0xFF18C6FF);
  static const Color _screenBackground = Color(0xFFF8FAFE);
  static const Color _headingColor = Color(0xFF111C44);
  static const Color _bodyColor = Color(0xFF61708A);
  static const Color _borderColor = Color(0xFFE2E8F3);

  final NumberFormat _currencyFormat = NumberFormat.currency(
      symbol: AppVariables.currency ?? '\$', decimalDigits: 2);

  double get _billAmount => double.tryParse(widget.totalAmount) ?? 0;
  double get _memberSavings => double.tryParse(widget.totalPiiinkDiscount) ?? 0;
  double get _customerPays =>
      double.tryParse(widget.discountedTransactionAmount) ?? 0;
  double get _merchantTsdcsEarned =>
      double.tryParse(widget.merchantRebateToMember) ?? 0;
  bool get _canLeaveReview =>
      widget.merchantId != null && widget.merchantName.trim().isNotEmpty;

  void _finishPaymentFlowToSavings() {
    AppVariables.payAmountResetSignal.value++;
    navigateToBottomTab(context, 3);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _finishPaymentFlowToSavings();
        }
      },
      child: Scaffold(
        backgroundColor: _screenBackground,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight),
          child: CustomAppBar(text: 'Discount Approved'),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 28.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _ProofCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _merchantApprovalHeader(),
                      SizedBox(height: 16.h),
                      _approvalTitle(),
                      SizedBox(height: 8.h),
                      Center(
                        child: Text(
                          'Show this screen to the merchant. Customer pays merchant ${_formatCurrency(_customerPays)} directly.',
                          textAlign: TextAlign.center,
                          style: _bodyStyle(),
                        ),
                      ),
                      SizedBox(height: 22.h),
                      _summaryRow('Bill amount', _formatCurrency(_billAmount)),
                      _summaryRow(
                          'Member savings', _formatCurrency(_memberSavings)),
                      _summaryRow('Customer pays merchant',
                          _formatCurrency(_customerPays),
                          emphasized: true),
                      _summaryRow('Premium Savings Applied',
                          _formatCurrency(_memberSavings)),
                      if (_merchantTsdcsEarned > 0)
                        _summaryRow(
                          'Merchant Savings Earned',
                          '+${_formatCurrency(_merchantTsdcsEarned)}',
                        ),
                    ],
                  ),
                ),
                SizedBox(height: 18.h),
                _GradientButton(
                  label: 'Done',
                  onTap: _finishPaymentFlowToSavings,
                ),
                if (_canLeaveReview) ...[
                  SizedBox(height: 12.h),
                  _SecondaryButton(
                    label: 'Leave a Review',
                    onTap: () {
                      context.pushNamed(
                        'feedback-screen',
                        extra: {
                          'merchantId': widget.merchantId.toString(),
                          'merchantName': widget.merchantName,
                          'merchantLogo': widget.merchantLogo,
                        },
                      );
                    },
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _merchantApprovalHeader() {
    return Row(
      children: [
        _merchantLogo(),
        SizedBox(width: 14.w),
        Expanded(
          child: Text(
            widget.merchantName,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: _headingColor,
              fontSize: 22.sp,
              fontWeight: FontWeight.w900,
              fontFamily: 'Sans',
            ),
          ),
        ),
        SizedBox(width: 10.w),
        Container(
          width: 42.w,
          height: 42.w,
          decoration: BoxDecoration(
            color: const Color(0xFFEFF7FF),
            borderRadius: BorderRadius.circular(15.r),
          ),
          child: Icon(
            Icons.verified_rounded,
            color: _primaryBlue,
            size: 26.sp,
          ),
        ),
      ],
    );
  }

  Widget _approvalTitle() {
    return Center(
      child: Text(
        'Discount Approved',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: _headingColor,
          fontSize: 24.sp,
          fontWeight: FontWeight.w900,
          fontFamily: 'Sans',
        ),
      ),
    );
  }

  Widget _merchantLogo() {
    final String? logoUrl = _normalizedMerchantLogo(widget.merchantLogo);

    return Container(
      width: 62.w,
      height: 62.w,
      decoration: BoxDecoration(
        color: const Color(0xFFEFF7FF),
        borderRadius: BorderRadius.circular(18.r),
      ),
      clipBehavior: Clip.antiAlias,
      child: logoUrl != null
          ? CachedNetworkImage(
              imageUrl: logoUrl,
              fit: BoxFit.cover,
              errorWidget: (context, url, error) => _fallbackLogo(),
            )
          : _fallbackLogo(),
    );
  }

  Widget _fallbackLogo() {
    return Icon(Icons.storefront_outlined, color: _primaryBlue, size: 31.sp);
  }

  Widget _summaryRow(String label, String value, {bool emphasized = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        children: [
          Expanded(child: Text(label, style: _bodyStyle())),
          SizedBox(width: 12.w),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                color: emphasized ? _primaryBlue : _headingColor,
                fontSize: emphasized ? 17.sp : 14.sp,
                fontWeight: FontWeight.w900,
                fontFamily: 'Sans',
              ),
            ),
          ),
        ],
      ),
    );
  }

  TextStyle _bodyStyle() {
    return TextStyle(
      color: _bodyColor,
      fontSize: 13.5.sp,
      fontWeight: FontWeight.w600,
      height: 1.38,
      fontFamily: 'Sans',
    );
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

class _ProofCard extends StatelessWidget {
  const _ProofCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: _PaymentCompletedState._borderColor),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0A236B).withValues(alpha: 0.06),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _GradientButton extends StatelessWidget {
  const _GradientButton({
    required this.label,
    required this.onTap,
  });

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
          height: 54.h,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                _PaymentCompletedState._primaryBlue,
                _PaymentCompletedState._ctaCyan,
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(18.r),
            boxShadow: [
              BoxShadow(
                color:
                    _PaymentCompletedState._primaryBlue.withValues(alpha: 0.20),
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

class _SecondaryButton extends StatelessWidget {
  const _SecondaryButton({
    required this.label,
    required this.onTap,
  });

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
          height: 54.h,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18.r),
            border: Border.all(
              color: _PaymentCompletedState._primaryBlue,
              width: 1.2,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: _PaymentCompletedState._primaryBlue,
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
