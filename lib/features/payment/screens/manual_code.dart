import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:new_piiink/common/app_variables.dart';
import 'package:new_piiink/common/widgets/custom_app_bar.dart';
import 'package:new_piiink/common/widgets/custom_loader.dart';
import 'package:new_piiink/common/widgets/custom_snackbar.dart';
import 'package:new_piiink/constants/fixed_decimal.dart';
import 'package:new_piiink/features/payment/services/dio_payment.dart';
import 'package:new_piiink/models/error_res.dart';
import 'package:new_piiink/models/request/confirm_piiink_req.dart';
import 'package:new_piiink/models/response/confirm_piiink_res.dart';
import 'package:new_piiink/generated/l10n.dart';

class ManualCode extends StatefulWidget {
  static const String routeName = '/manual-code';
  final String totalAmount;
  const ManualCode({super.key, required this.totalAmount});

  @override
  State<ManualCode> createState() => _ManualCodeState();
}

class _ManualCodeState extends State<ManualCode> {
  static const Color _primaryBlue = Color(0xFF0009FE);
  static const Color _ctaCyan = Color(0xFF18C6FF);
  static const Color _screenBackground = Color(0xFFF8FAFE);
  static const Color _headingColor = Color(0xFF111C44);
  static const Color _bodyColor = Color(0xFF61708A);
  static const Color _borderColor = Color(0xFFE2E8F3);

  final merchantCodeKey = GlobalKey<FormState>();
  final TextEditingController qrCodeController = TextEditingController();
  bool isLoading = false;

  @override
  void dispose() {
    qrCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _screenBackground,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: CustomAppBar(
          text: 'Merchant code',
          icon: Icons.arrow_back_ios,
          onPressed: context.pop,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 28.h),
          child: Form(
            key: merchantCodeKey,
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(20.r),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22.r),
                border: Border.all(color: _borderColor),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0A236B).withValues(alpha: 0.06),
                    blurRadius: 18,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.qr_code_2_rounded,
                    color: _primaryBlue,
                    size: 42.sp,
                  ),
                  SizedBox(height: 14.h),
                  Text(
                    'Enter merchant code',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: _headingColor,
                      fontSize: 22.sp,
                      fontWeight: FontWeight.w900,
                      fontFamily: 'Sans',
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'We’ll check the merchant offer for your bill amount.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: _bodyColor,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      height: 1.4,
                      fontFamily: 'Sans',
                    ),
                  ),
                  SizedBox(height: 22.h),
                  TextFormField(
                    controller: qrCodeController,
                    cursorColor: _primaryBlue,
                    textCapitalization: TextCapitalization.characters,
                    decoration: InputDecoration(
                      hintText: 'Merchant code',
                      hintStyle: TextStyle(
                        color: _bodyColor.withValues(alpha: 0.75),
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                      prefixIcon: Icon(
                        Icons.confirmation_number_outlined,
                        color: _primaryBlue,
                        size: 22.sp,
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF7FAFF),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 16.h,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16.r),
                        borderSide: const BorderSide(color: _borderColor),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16.r),
                        borderSide: const BorderSide(color: _borderColor),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16.r),
                        borderSide:
                            const BorderSide(color: _primaryBlue, width: 1.4),
                      ),
                    ),
                  ),
                  SizedBox(height: 24.h),
                  isLoading
                      ? const Center(child: CustomAllLoader())
                      : _GradientButton(
                          label: 'Check offer',
                          onTap: _checkOffer,
                        ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _checkOffer() async {
    if (!merchantCodeKey.currentState!.validate()) return;

    if (qrCodeController.text.trim().isEmpty) {
      GlobalSnackBar.valid(context, S.of(context).pleaseEnterTheCode);
      return;
    }

    setState(() {
      isLoading = true;
    });

    final res = await DioPay().confirmApplyPiiink(
      confirmApplyPiiinkReqModel: ConfirmApplyPiiinkReqModel(
        totalAmount: double.parse(widget.totalAmount),
        transactionQRCode: qrCodeController.text.trim(),
        hour: int.parse(DateFormat('HH ').format(DateTime.now())),
        week: DateTime.now().weekday % 7,
        lang: AppVariables.selectedLanguageNow,
      ),
    );

    if (!mounted) return;

    if (res is ConfirmApplyPiiinkResModel && res.status == "Success") {
      context.pushNamed('confirm-pay', extra: {
        'merchantId': res.data!.merchantInfo!.id,
        'totalAmount': widget.totalAmount,
        'qrCode': qrCodeController.text.trim(),
        'hasMerchantPiiinks': res.data!.hasMerchantPiiinks.toString(),
        'hasUniversalPiiinks': res.data!.hasUniversalPiiinks.toString(),
        'merchantName': res.data!.merchantInfo!.merchantName,
        'universalPiiinkBalance':
            toFixed2DecimalPlaces(res.data!.universalPiiinkBalance!).toString(),
        'merchantPiiinkBalance':
            toFixed2DecimalPlaces(res.data!.merchantPiiinkBalance!).toString(),
        'merchantRebateToMember': res.data!.merchantRebateToMember.toString(),
        'merchantDiscountPercentage':
            res.data!.merchantDiscountPercentage.toString(),
        'discountedTransactionAmount':
            res.data!.discountedTransactionAmount.toString(),
        'totalPiiinkDiscount': res.data!.totalPiiinkDiscount.toString(),
        'logo': res.data!.merchantInfo?.merchantImageInfo == null
            ? 'null'
            : res.data!.merchantInfo?.merchantImageInfo?.logoUrl ??
                res.data!.merchantInfo?.merchantImageInfo?.slider1 ??
                'null',
        'universalPiiinkOnHold':
            res.data!.universalPiiinkBalanceOnHold.toString(),
        'merchantPiiinkOnHold':
            res.data!.merchantPiiinkBalanceOnHold.toString(),
      });
    } else if (res is ErrorResModel) {
      GlobalSnackBar.showError(context, res.message ?? '');
    } else {
      GlobalSnackBar.showError(context, S.of(context).somethingWentWrong);
    }

    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
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
                _ManualCodeState._primaryBlue,
                _ManualCodeState._ctaCyan
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(18.r),
            boxShadow: [
              BoxShadow(
                color: _ManualCodeState._primaryBlue.withValues(alpha: 0.20),
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
