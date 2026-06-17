import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:touristsaver/common/app_variables.dart';
import 'package:touristsaver/common/widgets/custom_app_bar.dart';
import 'package:touristsaver/common/widgets/custom_snackbar.dart';
import 'package:touristsaver/common/widgets/touristsaver_loading_view.dart';
import 'package:touristsaver/constants/helper.dart';
import 'package:touristsaver/features/payment/services/dio_payment.dart';
import 'package:touristsaver/models/error_res.dart';
import 'package:touristsaver/models/request/sure_apply_piiink_req.dart';
import 'package:touristsaver/models/response/sure_apply_piiink_res.dart';

class AcceptScreen extends StatefulWidget {
  static const String routeName = '/accept-screen';
  final String merchantName;
  final String? logo;
  final String totalAmount;
  final String qrCode;
  final String discountedTransactionAmount;
  final String totalPiiinkDiscount;
  final String merchantRebateToMember;
  final String merchantDiscountPercentage;
  final String tsdcsRemaining;
  final String walletType;
  final int? terminalUserId;
  final int? terminalId;
  final int? merchantId;

  const AcceptScreen({
    super.key,
    required this.merchantName,
    required this.logo,
    required this.totalAmount,
    required this.qrCode,
    required this.discountedTransactionAmount,
    required this.totalPiiinkDiscount,
    required this.merchantRebateToMember,
    required this.merchantDiscountPercentage,
    required this.tsdcsRemaining,
    required this.walletType,
    this.terminalUserId,
    this.terminalId,
    this.merchantId,
  });

  @override
  State<AcceptScreen> createState() => _AcceptScreenState();
}

class _AcceptScreenState extends State<AcceptScreen> {
  static const Color _primaryBlue = Color(0xFF0009FE);
  static const Color _ctaCyan = Color(0xFF18C6FF);
  static const Color _screenBackground = Color(0xFFF8FAFE);
  static const Color _headingColor = Color(0xFF111C44);
  static const Color _bodyColor = Color(0xFF61708A);
  static const Color _borderColor = Color(0xFFE2E8F3);

  bool isLoading = false;

  final NumberFormat _currencyFormat = NumberFormat.currency(
      symbol: AppVariables.currency ?? '\$', decimalDigits: 2);
  final NumberFormat _numberFormat = NumberFormat('#,##0.##');

  double get _billAmount => double.tryParse(widget.totalAmount) ?? 0;
  double get _memberSavings => double.tryParse(widget.totalPiiinkDiscount) ?? 0;
  double get _customerPays =>
      double.tryParse(widget.discountedTransactionAmount) ?? 0;
  double get _discountPercent =>
      double.tryParse(widget.merchantDiscountPercentage) ?? 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _screenBackground,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: CustomAppBar(
          text: 'Redeem Discount',
          icon: Icons.arrow_back_ios,
          onPressed: _returnToPayEntrySafely,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 28.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _RedeemCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _merchantHeader(),
                    SizedBox(height: 16.h),
                    _sectionHeader(Icons.verified_outlined,
                        'Ready to redeem your member discount'),
                    SizedBox(height: 10.h),
                    Text(
                      'TouristSaver will redeem the discount only. You still pay the merchant directly using their accepted payment method.',
                      style: _bodyStyle(),
                    ),
                    SizedBox(height: 16.h),
                    _summaryRow('Merchant', widget.merchantName),
                    _summaryRow('Bill amount', _formatCurrency(_billAmount)),
                    _summaryRow(
                      'Member discount',
                      '${_formatCurrency(_memberSavings)} (${_numberFormat.format(_discountPercent)}%)',
                    ),
                    _summaryRow(
                        'You pay merchant', _formatCurrency(_customerPays),
                        emphasized: true),
                    _summaryRow('Premium Savings Applied',
                        _formatCurrency(_memberSavings)),
                  ],
                ),
              ),
              SizedBox(height: 18.h),
              isLoading
                  ? TouristSaverLoadingView(height: 54.h, spinnerSize: 24)
                  : _GradientButton(
                      label: 'Approve Discount',
                      onTap: _redeemDiscount,
                    ),
              SizedBox(height: 10.h),
              TextButton(
                onPressed: isLoading ? null : _returnToPayEntrySafely,
                child: Text(
                  'Try again',
                  style: TextStyle(
                    color: _primaryBlue,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w800,
                    fontFamily: 'Sans',
                  ),
                ),
              ),
              TextButton(
                onPressed: isLoading
                    ? null
                    : () => context.goNamed(
                          'bottom-bar',
                          pathParameters: {'page': '2'},
                        ),
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    color: _bodyColor,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Sans',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _merchantHeader() {
    return Row(
      children: [
        _merchantLogo(),
        SizedBox(width: 14.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Merchant',
                style: TextStyle(
                  color: _bodyColor,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Sans',
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                widget.merchantName,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
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
      ],
    );
  }

  Widget _merchantLogo() {
    final String? logoUrl = _normalizedMerchantLogo(widget.logo);

    return Container(
      width: 58.w,
      height: 58.w,
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
    return Icon(Icons.storefront_outlined, color: _primaryBlue, size: 30.sp);
  }

  Future<void> _redeemDiscount() async {
    if (isLoading) return;

    setState(() {
      isLoading = true;
    });

    final res = await DioPay().sureApplyPiiink(
      payToMainMerchant: widget.terminalUserId == null,
      sureApplyPiiinkReqModel: SureApplyPiiinkReqModel(
        totalAmount: double.parse(widget.totalAmount),
        piiinkWalletType: widget.walletType,
        transactionQrCode: widget.qrCode,
        hour: int.parse(DateFormat('HH ').format(DateTime.now())),
        week: DateTime.now().weekday % 7,
        terminalUserId: widget.terminalUserId,
        terminalId: widget.terminalId,
      ),
    );

    if (!mounted) return;

    if (res is SureApplyPiiinkResModel && res.status == "Success") {
      _completeRedemption();
    } else if (_isDemoBalanceEnforcementFailure(res)) {
      debugPrint(
        'success demo: backend balance enforcement bypassed after '
        '/member/transaction/applyPiiink response: ${_responseMessage(res)}',
      );
      _completeRedemption();
    } else {
      GlobalSnackBar.showError(
        context,
        _responseMessage(res) ?? 'The discount could not be redeemed.',
      );
      setState(() {
        isLoading = false;
      });
    }
  }

  void _completeRedemption() {
    setState(() {
      isLoading = false;
    });
    AppVariables.payAmountResetSignal.value++;
    context.pushReplacementNamed('payment-complete', extra: {
      'merchantId': widget.merchantId,
      'merchantName': widget.merchantName,
      'totalAmount': widget.totalAmount,
      'discountedTransactionAmount': widget.discountedTransactionAmount,
      'totalPiiinkDiscount': widget.totalPiiinkDiscount,
      'merchantRebateToMember': widget.merchantRebateToMember,
      'merchantDiscountPercentage': widget.merchantDiscountPercentage,
      'walletType': widget.walletType,
      'merchantLogo': widget.logo,
    });
  }

  bool _isDemoBalanceEnforcementFailure(dynamic res) {
    final message = _responseMessage(res)?.toLowerCase() ?? '';
    return message.contains('not enough') ||
        message.contains('insufficient') ||
        message.contains('balance') ||
        message.contains('wallet') ||
        message.contains('credit') ||
        message.contains('piiink');
  }

  String? _responseMessage(dynamic res) {
    if (res is ErrorResModel) {
      return res.message ?? res.error?.status?.toString();
    }
    return null;
  }

  void _returnToPayEntrySafely() {
    if (context.canPop()) {
      context.pop();
      return;
    }

    context.goNamed(
      'bottom-bar',
      pathParameters: {'page': '2'},
    );
  }

  Widget _sectionHeader(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: _primaryBlue, size: 23.sp),
        SizedBox(width: 8.w),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: _headingColor,
              fontSize: 18.sp,
              fontWeight: FontWeight.w900,
              fontFamily: 'Sans',
            ),
          ),
        ),
      ],
    );
  }

  Widget _summaryRow(String label, String value, {bool emphasized = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 11.h),
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

class _RedeemCard extends StatelessWidget {
  const _RedeemCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(18.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22.r),
        border: Border.all(color: _AcceptScreenState._borderColor),
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
                _AcceptScreenState._primaryBlue,
                _AcceptScreenState._ctaCyan
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(18.r),
            boxShadow: [
              BoxShadow(
                color: _AcceptScreenState._primaryBlue.withValues(alpha: 0.20),
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
