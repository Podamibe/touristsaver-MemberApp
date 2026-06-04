import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:touristsaver/common/app_variables.dart';
import 'package:touristsaver/common/widgets/custom_app_bar.dart';

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
  final NumberFormat _numberFormat = NumberFormat('#,##0.##');

  double get _billAmount => double.tryParse(widget.totalAmount) ?? 0;
  double get _memberSavings => double.tryParse(widget.totalPiiinkDiscount) ?? 0;
  double get _customerPays =>
      double.tryParse(widget.discountedTransactionAmount) ?? 0;
  double get _merchantTsdcsEarned =>
      double.tryParse(widget.merchantRebateToMember) ?? 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                    Center(
                      child: Container(
                        width: 72.w,
                        height: 72.w,
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF7FF),
                          borderRadius: BorderRadius.circular(24.r),
                        ),
                        child: Icon(
                          Icons.verified_rounded,
                          color: _primaryBlue,
                          size: 40.sp,
                        ),
                      ),
                    ),
                    SizedBox(height: 18.h),
                    Center(
                      child: Text(
                        'Discount Approved',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: _headingColor,
                          fontSize: 25.sp,
                          fontWeight: FontWeight.w900,
                          fontFamily: 'Sans',
                        ),
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Center(
                      child: Text(
                        'Show this screen to the merchant. Customer pays merchant ${_formatCurrency(_customerPays)} directly.',
                        textAlign: TextAlign.center,
                        style: _bodyStyle(),
                      ),
                    ),
                    SizedBox(height: 22.h),
                    _summaryRow('Merchant', widget.merchantName),
                    _summaryRow('Bill amount', _formatCurrency(_billAmount)),
                    _summaryRow(
                        'Member savings', _formatCurrency(_memberSavings)),
                    _summaryRow('Customer pays merchant',
                        _formatCurrency(_customerPays),
                        emphasized: true),
                    _summaryRow(
                        'TSDCs redeemed', _numberFormat.format(_memberSavings)),
                    if (_merchantTsdcsEarned > 0)
                      _summaryRow(
                        'Merchant TSDCs earned',
                        '+${_numberFormat.format(_merchantTsdcsEarned)}',
                      ),
                  ],
                ),
              ),
              SizedBox(height: 18.h),
              _GradientButton(
                label: 'Done',
                onTap: () {
                  context.goNamed(
                    'bottom-bar',
                    pathParameters: {'page': '3'},
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
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
