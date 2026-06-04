import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:flutter_barcode_scanner_plus/flutter_barcode_scanner_plus.dart';
// import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
// import 'package:intl/intl.dart';
// import 'package:touristsaver/constants/fixed_decimal.dart';
// import 'package:touristsaver/models/error_res.dart';
// import 'package:touristsaver/models/request/confirm_piiink_req.dart';
// import 'package:touristsaver/models/response/confirm_piiink_res.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:touristsaver/common/app_variables.dart';
import 'package:touristsaver/common/widgets/custom_app_bar.dart';
import 'package:touristsaver/common/widgets/custom_loader.dart';
import 'package:touristsaver/common/widgets/custom_snackbar.dart';
import 'package:touristsaver/common/widgets/error.dart';
import 'package:touristsaver/constants/global_colors.dart';
import 'package:touristsaver/features/connectivity/cubit/internet_cubit.dart';
import 'package:touristsaver/features/payment/services/dio_payment.dart';
import 'package:touristsaver/models/response/is_pay_enable_res.dart';

import '../../../common/services/dio_common.dart';
import '../../../constants/fixed_decimal.dart';
import '../../../models/error_res.dart';
import '../../../models/request/confirm_piiink_req.dart';
import '../../../models/response/confirm_piiink_res.dart';
import '../../../models/response/piiink_info_res.dart';
import '../../connectivity/screens/connectivity.dart';
import '../../connectivity/screens/connectivity_screen.dart';
import 'package:touristsaver/generated/l10n.dart';

class PayScreen extends StatefulWidget {
  static const String routeName = '/pay';
  const PayScreen({super.key, this.merchantName});

  final String? merchantName;

  @override
  State<PayScreen> createState() => _PayScreenState();
}

class _PayScreenState extends State<PayScreen> {
  static const Color _primaryBlue = Color(0xFF0009FE);
  static const Color _ctaCyan = Color(0xFF18C6FF);
  static const Color _screenBackground = Color(0xFFF8FAFE);
  static const Color _borderColor = Color(0xFFE2E8F3);

  TextEditingController amountController = TextEditingController();
  bool? hideMerchantPaymentCode;

  //Flutter BarCode Scanner for QR Code
  String manualQrCode = '';
  String merchantQrCode = '';

  // For Loader
  bool isLoading = false;
  bool isMerchantQrLoading = false;

  //Checking whether the pay is enabled or not
  Future<IsPayEnableResModel?>? payE;
  Future<IsPayEnableResModel?>? payEnabled() async {
    IsPayEnableResModel? isPayEnabledResModel = await DioPay().payEnabled();
    return isPayEnabledResModel;
  }

  // _scanManualQr() async {
  //   if (amountController.text.isEmpty ||
  //       double.parse(amountController.text) <= 0) {
  //     GlobalSnackBar.valid(context, S.of(context).pleaseEnterTheRightAmount);
  //     return;
  //   }
  //   await FlutterBarcodeScanner.scanBarcode(
  //           '#EC4785', 'Cancel', true, ScanMode.QR)
  //       .then((value) async {
  //     setState(() {
  //       manualQrCode = value;
  //       isLoading = true;
  //     });
  //     // log(value);
  //     if (value == '-1') {
  //       setState(() {
  //         isLoading = false;
  //       });
  //       if (!mounted) return;
  //       return GlobalSnackBar(message: S.of(context).invalidQrCode);
  //     }
  //     //     }))
  //     // .then((value) async {
  //     var res = await DioPay().confirmApplyPiiink(
  //       confirmApplyPiiinkReqModel: ConfirmApplyPiiinkReqModel(
  //           totalAmount: double.parse(amountController.text),
  //           transactionQRCode: manualQrCode,
  //           hour: int.parse(DateFormat('HH ').format(DateTime.now())),
  //           week: DateTime.now().weekday % 7,
  //           lang: AppVariables.selectedLanguageNow),
  //     );
  //     // if (!mounted) return;
  //     if (res is ConfirmApplyPiiinkResModel) {
  //       if (res.status == "Success") {
  //         setState(() {
  //           isLoading = false;
  //         });
  //         var data = res.data!;
  //         // ignore: use_build_context_synchronously
  //         context.pushNamed('confirm-pay', extra: {
  //           'merchantId': data.merchantInfo!.id,
  //           'totalAmount': amountController.text.trim(),
  //           'qrCode': manualQrCode,
  //           'hasMerchantPiiinks': data.hasMerchantPiiinks.toString(),
  //           'hasUniversalPiiinks': data.hasUniversalPiiinks.toString(),
  //           'merchantName': data.merchantInfo!.merchantName,
  //           'universalPiiinkBalance':
  //               toFixed2DecimalPlaces(data.universalPiiinkBalance!).toString(),
  //           'merchantPiiinkBalance':
  //               toFixed2DecimalPlaces(data.merchantPiiinkBalance!).toString(),
  //           'merchantRebateToMember': data.merchantRebateToMember.toString(),
  //           'discountedTransactionAmount':
  //               data.discountedTransactionAmount.toString(),
  //           'totalPiiinkDiscount': data.totalPiiinkDiscount.toString(),
  //           'logo': data.merchantInfo?.merchantImageInfo == null
  //               ? 'null'
  //               : data.merchantInfo?.merchantImageInfo?.logoUrl ??
  //                   data.merchantInfo?.merchantImageInfo?.slider1 ??
  //                   'null',
  //           'universalPiiinkOnHold':
  //               data.universalPiiinkBalanceOnHold.toString(),
  //           'merchantPiiinkOnHold': data.merchantPiiinkBalanceOnHold.toString(),
  //         });
  //       } else {
  //         setState(() {
  //           isLoading = false;
  //         });
  //         if (!mounted) return;
  //         return GlobalSnackBar.showError(
  //             context, S.of(context).notEnoughPiiinkCredits);
  //       }
  //     } else if (res is ErrorResModel) {
  //       setState(() {
  //         isLoading = false;
  //       });
  //       if (!mounted) return;
  //       return GlobalSnackBar.showError(context, res.message!);
  //     } else {
  //       setState(() {
  //         isLoading = false;
  //       });
  //       if (!mounted) return;
  //       return GlobalSnackBar.showError(
  //           context, S.of(context).somethingWentWrong);
  //     }
  //   });
  // }

  // _scanMerchantQr() async {
  //   await FlutterBarcodeScanner.scanBarcode(
  //           '#EC4785', 'Cancel', true, ScanMode.QR)
  //       .then((value) async {
  //     setState(() {
  //       merchantQrCode = value;
  //       isMerchantQrLoading = true;
  //     });
  //     // log(value);
  //     if (value == '-1') {
  //       setState(() {
  //         isMerchantQrLoading = false;
  //       });
  //       if (!mounted) return;
  //       return GlobalSnackBar(message: S.of(context).invalidQrCode);
  //     }
  //     var res = await DioPay()
  //         .confirmTerminalApplyPiiink(transactionQrCode: merchantQrCode);

  //     if (res is ConfirmApplyPiiinkResModel) {
  //       if (res.status == "Success") {
  //         setState(() {
  //           isMerchantQrLoading = false;
  //         });
  //         var data = res.data!;
  //         // ignore: use_build_context_synchronously
  //         context.pushNamed('confirm-pay', extra: {
  //           'merchantId': data.merchantInfo!.id,
  //           'totalAmount': data.totalTransactionAmount.toString(),
  //           'qrCode': data.merchantInfo!.transactionCode,
  //           'hasMerchantPiiinks': data.hasMerchantPiiinks.toString(),
  //           'hasUniversalPiiinks': data.hasUniversalPiiinks.toString(),
  //           'merchantName': data.merchantInfo!.merchantName,
  //           'universalPiiinkBalance':
  //               toFixed2DecimalPlaces(data.universalPiiinkBalance!).toString(),
  //           'merchantPiiinkBalance':
  //               toFixed2DecimalPlaces(data.merchantPiiinkBalance!).toString(),
  //           'merchantRebateToMember': data.merchantRebateToMember.toString(),
  //           'discountedTransactionAmount':
  //               data.discountedTransactionAmount.toString(),
  //           'totalPiiinkDiscount': data.totalPiiinkDiscount.toString(),
  //           'logo': data.merchantInfo?.merchantImageInfo == null
  //               ? 'null'
  //               : data.merchantInfo?.merchantImageInfo?.logoUrl ??
  //                   data.merchantInfo?.merchantImageInfo?.slider1 ??
  //                   'null',
  //           'universalPiiinkOnHold':
  //               data.universalPiiinkBalanceOnHold.toString(),
  //           'merchantPiiinkOnHold': data.merchantPiiinkBalanceOnHold.toString(),
  //           'terminalUserId': data.terminalUserId,
  //           'terminalId': data.terminalId,
  //         });
  //       } else {
  //         setState(() {
  //           isMerchantQrLoading = false;
  //         });
  //         if (!mounted) return;
  //         return GlobalSnackBar.showError(
  //             context, S.of(context).notEnoughPiiinkCredits);
  //       }
  //     } else if (res is ErrorResModel) {
  //       setState(() {
  //         isMerchantQrLoading = false;
  //       });
  //       if (!mounted) return;
  //       return GlobalSnackBar.showError(context, res.message!);
  //     } else {
  //       setState(() {
  //         isMerchantQrLoading = false;
  //       });
  //       if (!mounted) return;
  //       return GlobalSnackBar.showError(
  //           context, S.of(context).somethingWentWrong);
  //     }
  //   });
  // }

  //Checking whether merchant payment code is enabled
  Future<void> getPiiinkInfo() async {
    PiiinkInfoResModel? piiinkInfoResModel = await DioCommon().piiinkInfo();
    if (!mounted) return;
    setState(() {
      hideMerchantPaymentCode =
          piiinkInfoResModel?.data?.hideMerchantPaymentCodeScanOption;
    });
  }

  _scanManualQr(String manualQrCode) async {
    // log('Merchant enter amount QR pay');
    var res = await DioPay().confirmApplyPiiink(
      confirmApplyPiiinkReqModel: ConfirmApplyPiiinkReqModel(
          totalAmount: double.parse(amountController.text.trim()),
          transactionQRCode: manualQrCode,
          hour: int.parse(DateFormat('HH ').format(DateTime.now())),
          week: DateTime.now().weekday % 7,
          lang: AppVariables.selectedLanguageNow),
    );
    // if (!mounted) return;
    if (res is ConfirmApplyPiiinkResModel) {
      if (res.status == "Success") {
        setState(() {
          isLoading = false;
        });
        var data = res.data!;
        context.pushNamed('confirm-pay', extra: {
          'merchantId': data.merchantInfo!.id,
          'totalAmount': amountController.text.trim(),
          'qrCode': manualQrCode,
          'hasMerchantPiiinks': data.hasMerchantPiiinks.toString(),
          'hasUniversalPiiinks': data.hasUniversalPiiinks.toString(),
          'merchantName': data.merchantInfo!.merchantName,
          'universalPiiinkBalance':
              toFixed2DecimalPlaces(data.universalPiiinkBalance!).toString(),
          'merchantPiiinkBalance':
              toFixed2DecimalPlaces(data.merchantPiiinkBalance!).toString(),
          'merchantRebateToMember': data.merchantRebateToMember.toString(),
          'merchantDiscountPercentage':
              data.merchantDiscountPercentage.toString(),
          'discountedTransactionAmount':
              data.discountedTransactionAmount.toString(),
          'totalPiiinkDiscount': data.totalPiiinkDiscount.toString(),
          'logo': data.merchantInfo?.merchantImageInfo == null
              ? 'null'
              : data.merchantInfo?.merchantImageInfo?.logoUrl ??
                  data.merchantInfo?.merchantImageInfo?.slider1 ??
                  'null',
          'universalPiiinkOnHold': data.universalPiiinkBalanceOnHold.toString(),
          'merchantPiiinkOnHold': data.merchantPiiinkBalanceOnHold.toString(),
        });
      } else {
        setState(() {
          isLoading = false;
        });
        if (!mounted) return;
        // context.pop();
        return GlobalSnackBar.showError(
            context, S.of(context).notEnoughTouristSaverCredits);
      }
    } else if (res is ErrorResModel) {
      setState(() {
        isLoading = false;
      });
      if (!mounted) return;
      // context.pop();
      return GlobalSnackBar.showError(context, res.message.toString());
    } else {
      setState(() {
        isLoading = false;
      });
      if (!mounted) return;
      // context.pop();
      return GlobalSnackBar.showError(
          context, S.of(context).somethingWentWrong);
    }
  }

  // Retained for terminal QR flows that include the transaction amount in the QR.
  // ignore: unused_element
  _scanMerchantQr(String merchantQrCode) async {
    // log('Merchant QR pay');
    var res = await DioPay()
        .confirmTerminalApplyPiiink(transactionQrCode: merchantQrCode);

    if (res is ConfirmApplyPiiinkResModel) {
      if (res.status == "Success") {
        setState(() {
          isMerchantQrLoading = false;
        });
        var data = res.data!;
        context.pushNamed('confirm-pay', extra: {
          'merchantId': data.merchantInfo!.id,
          'totalAmount': data.totalTransactionAmount.toString(),
          'qrCode': data.merchantInfo!.transactionCode,
          'hasMerchantPiiinks': data.hasMerchantPiiinks.toString(),
          'hasUniversalPiiinks': data.hasUniversalPiiinks.toString(),
          'merchantName': data.merchantInfo!.merchantName,
          'universalPiiinkBalance':
              toFixed2DecimalPlaces(data.universalPiiinkBalance!).toString(),
          'merchantPiiinkBalance':
              toFixed2DecimalPlaces(data.merchantPiiinkBalance!).toString(),
          'merchantRebateToMember': data.merchantRebateToMember.toString(),
          'merchantDiscountPercentage':
              data.merchantDiscountPercentage.toString(),
          'discountedTransactionAmount':
              data.discountedTransactionAmount.toString(),
          'totalPiiinkDiscount': data.totalPiiinkDiscount.toString(),
          'logo': data.merchantInfo?.merchantImageInfo == null
              ? 'null'
              : data.merchantInfo?.merchantImageInfo?.logoUrl ??
                  data.merchantInfo?.merchantImageInfo?.slider1 ??
                  'null',
          'universalPiiinkOnHold': data.universalPiiinkBalanceOnHold.toString(),
          'merchantPiiinkOnHold': data.merchantPiiinkBalanceOnHold.toString(),
          'terminalUserId': data.terminalUserId,
          'terminalId': data.terminalId,
        });
      } else {
        setState(() {
          isMerchantQrLoading = false;
        });
        if (!mounted) return;
        // context.pop();
        return GlobalSnackBar.showError(
            context, S.of(context).notEnoughTouristSaverCredits);
      }
    } else if (res is ErrorResModel) {
      setState(() {
        isMerchantQrLoading = false;
      });
      if (!mounted) return;
      // context.pop();
      return GlobalSnackBar.showError(context, res.message.toString());
    } else {
      setState(() {
        isMerchantQrLoading = false;
      });
      if (!mounted) return;
      // context.pop();
      return GlobalSnackBar.showError(
          context, S.of(context).somethingWentWrong);
    }
  }

  @override
  void initState() {
    getPiiinkInfo();
    payE = payEnabled();
    // log(AppVariables.currency!);
    super.initState();
  }

  @override
  void dispose() {
    amountController.dispose();
    ConnectivityCubit().close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _screenBackground,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: CustomAppBar(
            text: widget.merchantName ?? 'Redeem discount',
            icon: widget.merchantName == null ? null : Icons.arrow_back_ios,
            onPressed: widget.merchantName == null
                ? null
                : () {
                    context.pop();
                  }),
      ),
      body: Focus(
        autofocus: true,
        onKeyEvent: _handleDebugManualCodeShortcut,
        child: BlocBuilder<ConnectivityCubit, ConnectivityState>(
          builder: (context, state) {
            if (state == ConnectivityState.loading) {
              return const NoInternetLoader();
            } else if (state == ConnectivityState.disconnected) {
              return const NoConnectivityScreen();
            } else if (state == ConnectivityState.connected) {
              return SingleChildScrollView(
                child: FutureBuilder<IsPayEnableResModel?>(
                    future: payE,
                    builder: (context, snapShot) {
                      if (snapShot.hasError) {
                        return const Error1();
                      } else if (!snapShot.hasData) {
                        return const CustomAllLoader();
                      } else {
                        return snapShot.data!.data!.transactionIsEnabled == true
                            ? Container(
                                margin: EdgeInsets.symmetric(
                                    horizontal: 16.w, vertical: 14.h),
                                padding: EdgeInsets.symmetric(
                                    horizontal: 18.w, vertical: 20.h),
                                width: MediaQuery.of(context).size.width / 1,
                                constraints: const BoxConstraints(
                                  //To make height expandable according to the text
                                  maxHeight: double.infinity,
                                ),
                                decoration: BoxDecoration(
                                    color: GlobalColors.appWhiteBackgroundColor,
                                    borderRadius: BorderRadius.circular(22.r),
                                    border: Border.all(color: _borderColor),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFF0A236B)
                                            .withValues(alpha: 0.06),
                                        blurRadius: 18,
                                        offset: const Offset(0, 10),
                                      )
                                    ]),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    _billAmountCard(),
                                    SizedBox(height: 16.h),
                                    _merchantSelectionCard(),
                                    SizedBox(height: 16.h),
                                    _redemptionHelpImage(),
                                  ],
                                ),
                              )
                            : daysMoreToGo(snapShot.data!);
                      }
                    }),
              );
            } else {
              return const SizedBox();
            }
          },
        ),
      ),
    );
  }

  Widget _billAmountCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: const Color(0xFFF7FAFF),
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: _borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Enter bill amount',
            style: TextStyle(
              color: const Color(0xFF111C44),
              fontSize: 19.sp,
              fontWeight: FontWeight.w900,
              fontFamily: 'Sans',
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            'TouristSaver will check your available member discount.',
            style: TextStyle(
              color: GlobalColors.textColor,
              fontSize: 13.5.sp,
              fontWeight: FontWeight.w600,
              fontFamily: 'Sans',
            ),
          ),
          SizedBox(height: 14.h),
          TextFormField(
            controller: amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            textInputAction: TextInputAction.done,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
              TextInputFormatter.withFunction((oldValue, newValue) {
                final String value = newValue.text;
                if (value.isEmpty) return newValue;
                if ('.'.allMatches(value).length > 1) return oldValue;
                final int decimalIndex = value.indexOf('.');
                if (decimalIndex != -1 &&
                    value.substring(decimalIndex + 1).length > 2) {
                  return oldValue;
                }
                return newValue;
              }),
            ],
            style: TextStyle(
              color: const Color(0xFF111C44),
              fontSize: 28.sp,
              fontWeight: FontWeight.w900,
              fontFamily: 'Sans',
            ),
            decoration: InputDecoration(
              prefixIcon: Padding(
                padding: EdgeInsets.only(left: 16.w, right: 8.w),
                child: Text(
                  '\$ ',
                  style: TextStyle(
                    color: _primaryBlue,
                    fontSize: 28.sp,
                    fontWeight: FontWeight.w900,
                    fontFamily: 'Sans',
                  ),
                ),
              ),
              prefixIconConstraints:
                  const BoxConstraints(minWidth: 0, minHeight: 0),
              hintText: '0.00',
              hintStyle: TextStyle(
                color: GlobalColors.textColor.withValues(alpha: 0.45),
                fontSize: 28.sp,
                fontWeight: FontWeight.w800,
                fontFamily: 'Sans',
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 16.w, vertical: 15.h),
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
                borderSide: const BorderSide(color: _primaryBlue, width: 1.4),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _merchantSelectionCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: const Color(0xFFF7FAFF),
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: _borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Check merchant offer',
            style: TextStyle(
              color: const Color(0xFF111C44),
              fontSize: 17.sp,
              fontWeight: FontWeight.w900,
              fontFamily: 'Sans',
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            'Scan the TouristSaver QR at the counter, table, menu, window or EFTPOS terminal.',
            style: TextStyle(
              color: GlobalColors.textColor,
              fontSize: 13.5.sp,
              fontWeight: FontWeight.w600,
              fontFamily: 'Sans',
            ),
          ),
          SizedBox(height: 14.h),
          _scanMerchantQrButton(
            isLoading: isLoading,
            onTap: isMerchantQrLoading ? null : _openOfferQrScanner,
          ),
        ],
      ),
    );
  }

  Widget _redemptionHelpImage() {
    // TODO: Add 30-second onboarding/help video for first-time redemption flow.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18.r),
            border: Border.all(color: _borderColor),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0A236B).withValues(alpha: 0.06),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: Image.asset(
              'assets/images/onboarding/scanning_at_counter.webp',
              fit: BoxFit.cover,
            ),
          ),
        ),
        SizedBox(height: 9.h),
        Text(
          'Scan the merchant QR code before paying the bill.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: GlobalColors.textColor,
            fontSize: 13.sp,
            fontWeight: FontWeight.w700,
            height: 1.3,
            fontFamily: 'Sans',
          ),
        ),
      ],
    );
  }

  Widget _scanMerchantQrButton({
    required VoidCallback? onTap,
    bool isLoading = false,
  }) {
    final bool enabled = onTap != null;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18.r),
        onTap: enabled ? onTap : null,
        child: Ink(
          height: 54.h,
          padding: EdgeInsets.symmetric(horizontal: 18.w),
          decoration: BoxDecoration(
            gradient: enabled
                ? const LinearGradient(
                    colors: [_primaryBlue, _ctaCyan],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  )
                : null,
            color:
                enabled ? null : GlobalColors.textColor.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(18.r),
            boxShadow: enabled
                ? [
                    BoxShadow(
                      color: _primaryBlue.withValues(alpha: 0.20),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              isLoading
                  ? SizedBox(
                      width: 20.w,
                      height: 20.w,
                      child: const CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.2,
                      ),
                    )
                  : Icon(
                      Icons.qr_code_scanner_rounded,
                      color: Colors.white,
                      size: 21.sp,
                    ),
              SizedBox(width: 10.w),
              Text(
                'Scan merchant QR',
                style: TextStyle(
                  color: Colors.white,
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

  void _openOfferQrScanner() {
    if (!_hasValidAmount()) {
      GlobalSnackBar.valid(context, S.of(context).pleaseEnterTheRightAmount);
      return;
    }

    context.pushNamed('qr_screen', extra: {'title': S.of(context).pay}).then(
      (result) async {
        if (result != null && result.toString().isNotEmpty) {
          setState(() {
            isLoading = true;
          });
          await _scanManualQr(result.toString());
          if (mounted) {
            setState(() {
              isLoading = false;
            });
          }
        }
      },
    );
  }

  KeyEventResult _handleDebugManualCodeShortcut(
    FocusNode node,
    KeyEvent event,
  ) {
    if (!kDebugMode || event is! KeyDownEvent) {
      return KeyEventResult.ignored;
    }

    final bool isHashKey =
        event.character == '#' || event.logicalKey.keyLabel == '#';
    if (!isHashKey) {
      return KeyEventResult.ignored;
    }

    _openManualMerchantCode();
    return KeyEventResult.handled;
  }

  // ignore: unused_element
  void _openManualMerchantCode() {
    if (!_hasValidAmount()) {
      GlobalSnackBar.valid(context, S.of(context).pleaseEnterTheRightAmount);
      return;
    }

    context.pushNamed('manual-code',
        pathParameters: {'totalAmount': amountController.text.trim()});
  }

  bool _hasValidAmount() {
    final double? amount = double.tryParse(amountController.text.trim());
    return amount != null && amount > 0;
  }

  //Showing how many more days to go for a pay section
  daysMoreToGo(IsPayEnableResModel? getData) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
      width: MediaQuery.of(context).size.width / 1,
      constraints: const BoxConstraints(
        maxHeight: double.infinity,
      ),
      child: Column(
        children: [
          const SizedBox(height: 30),
          SizedBox(
            child: Image.asset(
              "assets/images/coming-soon-icon.png",
              height: 200.h,
              width: MediaQuery.of(context).size.width / 2,
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
    );
  }
}
