import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:touristsaver/common/app_variables.dart';
import 'package:touristsaver/common/widgets/custom_app_bar.dart';
import 'package:touristsaver/common/widgets/custom_loader.dart';
import 'package:touristsaver/common/widgets/custom_snackbar.dart';
import 'package:touristsaver/features/payment/services/dio_payment.dart';
import 'package:touristsaver/models/request/sure_apply_piiink_req.dart';
import 'package:touristsaver/models/response/sure_apply_piiink_res.dart';

class ConfimrPaymentScreen extends StatefulWidget {
  static const String routeName = "/confirm-pay";
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
  final String logo;
  final String universalPiiinkOnHold;
  final String merchantPiiinkOnHold;
  final int? terminalUserId;
  final int? terminalId;
  final int? merchantId;

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

  final NumberFormat _currencyFormat = NumberFormat.currency(
      symbol: AppVariables.currency ?? '\$', decimalDigits: 2);
  final NumberFormat _numberFormat = NumberFormat('#,##0.##');

  bool isLoading = false;

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
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 28.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _merchantCard(),
              SizedBox(height: 16.h),
              _summaryCard(),
              SizedBox(height: 16.h),
              _walletChoiceCard(
                title: 'Use Available Discount Credits',
                subtitle: 'Available for participating merchants generally.',
                balance: widget.universalPiiinkBalance,
                remaining: widget.universalPiiinkOnHold,
                enabled: widget.hasUniversalPiiinks == 'true',
                walletType: 'universalWallet',
              ),
              if (double.tryParse(widget.merchantPiiinkBalance) != 0) ...[
                SizedBox(height: 12.h),
                _walletChoiceCard(
                  title: 'Use Merchant Discount Credits for this merchant',
                  subtitle:
                      'Merchant-specific credits usable toward eligible future purchases here.',
                  balance: widget.merchantPiiinkBalance,
                  remaining: widget.merchantPiiinkOnHold,
                  enabled: widget.hasMerchantPiiinks == 'true',
                  walletType: 'merchantWallet',
                ),
              ],
              SizedBox(height: 18.h),
              TextButton(
                onPressed: () => context.pop(),
                child: Text(
                  'Try again / Cancel',
                  style: TextStyle(
                    color: _bodyColor,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w800,
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

  Widget _merchantCard() {
    return _PayCard(
      child: Row(
        children: [
          _merchantLogo(),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.merchantName,
                  style: TextStyle(
                    color: _headingColor,
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w900,
                    fontFamily: 'Sans',
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  'TouristSaver found an available member discount.',
                  style: _bodyStyle(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _merchantLogo() {
    final bool hasLogo = widget.logo.isNotEmpty && widget.logo != 'null';

    return Container(
      width: 58.w,
      height: 58.w,
      decoration: BoxDecoration(
        color: const Color(0xFFEFF7FF),
        borderRadius: BorderRadius.circular(18.r),
      ),
      clipBehavior: Clip.antiAlias,
      child: hasLogo
          ? CachedNetworkImage(
              imageUrl: widget.logo,
              fit: BoxFit.cover,
              errorWidget: (context, url, error) => _fallbackLogo(),
            )
          : _fallbackLogo(),
    );
  }

  Widget _fallbackLogo() {
    return Icon(Icons.storefront_outlined, color: _primaryBlue, size: 30.sp);
  }

  Widget _summaryCard() {
    return _PayCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader(Icons.local_offer_outlined, 'Your discount summary'),
          SizedBox(height: 14.h),
          _summaryRow('Bill amount', _formatCurrency(_billAmount)),
          _summaryRow('Member discount',
              '${_formatCurrency(_memberSavings)} (${_numberFormat.format(_discountPercent)}%)'),
          _summaryRow('You pay merchant', _formatCurrency(_customerPays),
              emphasized: true),
          _summaryRow('Discount Credits required',
              _numberFormat.format(_memberSavings)),
        ],
      ),
    );
  }

  Widget _walletChoiceCard({
    required String title,
    required String subtitle,
    required String balance,
    required String remaining,
    required bool enabled,
    required String walletType,
  }) {
    final double availableValue = double.tryParse(balance) ?? 0;
    final double remainingValue =
        (availableValue - _memberSavings).clamp(0, double.infinity);

    return _PayCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.savings_outlined, color: _primaryBlue, size: 22.sp),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: _headingColor,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w900,
                    fontFamily: 'Sans',
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(subtitle, style: _bodyStyle()),
          SizedBox(height: 12.h),
          _summaryRow('Available Discount Credits',
              _numberFormat.format(availableValue)),
          _summaryRow('Discount Credit balance after redeeming',
              _numberFormat.format(remainingValue)),
          SizedBox(height: 14.h),
          isLoading
              ? const Center(child: CustomAllLoader())
              : _GradientButton(
                  label: 'Redeem Discount',
                  enabled: enabled,
                  onTap: () {
                    if (!enabled) {
                      GlobalSnackBar.showError(
                        context,
                        'Not enough TouristSaver Discount Credits.',
                      );
                      return;
                    }

                    _redeemDiscount(walletType: walletType);
                  },
                ),
        ],
      ),
    );
  }

  Future<void> _redeemDiscount({required String walletType}) async {
    if (isLoading) return;

    setState(() {
      isLoading = true;
    });

    final res = await DioPay().sureApplyPiiink(
      payToMainMerchant: widget.terminalUserId == null,
      sureApplyPiiinkReqModel: SureApplyPiiinkReqModel(
        totalAmount: double.parse(widget.totalAmount),
        piiinkWalletType: walletType,
        transactionQrCode: widget.qrCode,
        hour: int.parse(DateFormat('HH ').format(DateTime.now())),
        week: DateTime.now().weekday % 7,
        terminalUserId: widget.terminalUserId,
        terminalId: widget.terminalId,
      ),
    );

    if (!mounted) return;

    if (res is SureApplyPiiinkResModel && res.status == "Success") {
      setState(() {
        isLoading = false;
      });
      context.pushReplacementNamed('payment-complete', extra: {
        'merchantId': widget.merchantId,
        'merchantName': widget.merchantName,
        'totalAmount': widget.totalAmount,
        'discountedTransactionAmount': widget.discountedTransactionAmount,
        'totalPiiinkDiscount': widget.totalPiiinkDiscount,
        'merchantRebateToMember': widget.merchantRebateToMember,
        'merchantDiscountPercentage': widget.merchantDiscountPercentage,
        'walletType': walletType,
      });
    } else {
      GlobalSnackBar.showError(context, 'The discount could not be redeemed.');
      setState(() {
        isLoading = false;
      });
    }
  }

  Widget _sectionHeader(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: _primaryBlue, size: 22.sp),
        SizedBox(width: 8.w),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: _headingColor,
              fontSize: 17.sp,
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
      padding: EdgeInsets.only(bottom: 10.h),
      child: Row(
        children: [
          Expanded(child: Text(label, style: _bodyStyle())),
          SizedBox(width: 12.w),
          Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(
              color: emphasized ? _primaryBlue : _headingColor,
              fontSize: emphasized ? 17.sp : 14.sp,
              fontWeight: FontWeight.w900,
              fontFamily: 'Sans',
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
}

class _PayCard extends StatelessWidget {
  const _PayCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(18.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22.r),
        border: Border.all(color: _ConfimrPaymentScreenState._borderColor),
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
    this.enabled = true,
  });

  final String label;
  final VoidCallback onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18.r),
        onTap: enabled ? onTap : onTap,
        child: Ink(
          height: 54.h,
          decoration: BoxDecoration(
            gradient: enabled
                ? const LinearGradient(
                    colors: [
                      _ConfimrPaymentScreenState._primaryBlue,
                      _ConfimrPaymentScreenState._ctaCyan,
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  )
                : null,
            color: enabled ? null : const Color(0xFFE8ECF5),
            borderRadius: BorderRadius.circular(18.r),
            boxShadow: enabled
                ? [
                    BoxShadow(
                      color: _ConfimrPaymentScreenState._primaryBlue
                          .withValues(alpha: 0.20),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: enabled
                    ? Colors.white
                    : _ConfimrPaymentScreenState._bodyColor,
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
