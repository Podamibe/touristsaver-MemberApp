import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:touristsaver/common/widgets/custom_loader.dart';
import 'package:touristsaver/common/widgets/custom_snackbar.dart';
import 'package:touristsaver/common/widgets/dropdown_button_widget.dart';
import 'package:touristsaver/common/widgets/error.dart';
import 'package:touristsaver/common/widgets/not_available.dart';
import 'package:touristsaver/features/location/services/dio_location.dart';
import 'package:touristsaver/features/profile/bloc/profile_wallet_blocs.dart';
import 'package:touristsaver/features/profile/bloc/profile_wallet_events.dart';
import 'package:touristsaver/features/profile/bloc/profile_wallet_states.dart';
import 'package:touristsaver/features/transfer_piiinks/services/dio_transfer.dart';
import 'package:touristsaver/features/wallet/services/dio_wallet.dart';
import 'package:touristsaver/models/request/tranfer_piiink_req.dart';
import 'package:touristsaver/models/response/location_get_all.dart';
import 'package:touristsaver/models/response/merchant_get_my_wallet.dart';
import 'package:touristsaver/models/response/tranfer_piiink_res.dart';

import '../../../constants/fixed_decimal.dart';
import 'package:touristsaver/generated/l10n.dart';

// import '../../../models/request/transfer_piiinks_req_model.dart';

const Color _sharePrimaryBlue = Color(0xFF0009FE);
const Color _shareCtaCyan = Color(0xFF18C6FF);
const Color _shareNavy = Color(0xFF111C44);
const Color _shareMuted = Color(0xFF61708A);
const Color _shareBorder = Color(0xFFE2E8F3);
const Color _shareBackground = Color(0xFFF8FAFE);

class TransferPiiinks extends StatefulWidget {
  static const String routeName = '/transfer-piiinks';
  const TransferPiiinks({super.key});

  @override
  State<TransferPiiinks> createState() => _TransferPiiinksState();
}

class _TransferPiiinksState extends State<TransferPiiinks> {
  TextEditingController receiverNumberController = TextEditingController();
  TextEditingController transferredPiiinksController = TextEditingController();
  TextEditingController searchController = TextEditingController();
  bool walletLoaded = false;

  // For dropDown of selecting country
  String? selectedMerchantPiiinks;
  int? selectedMerchantID;
  double? selectedMerchantBalance;
  String? phPrefix;
  Future<LocationGetAllResModel?>? phonePrefix;
  Future<LocationGetAllResModel?> getPhonePrefix() async {
    LocationGetAllResModel? locationGetAllResModel =
        await DioLocation().getCurrency();
    phPrefix = locationGetAllResModel!.data![0].phonePrefix;
    return locationGetAllResModel;
  }

  dynamic memberQrCode;
  bool isLoading = false;
  bool qrScanLoading = false;

  _scanMemberQr() async {
    if (selectedMerchantPiiinks == null) {
      GlobalSnackBar.valid(context, S.of(context).pleaseSelectMerchant);
      return;
    }

    if (transferredPiiinksController.text.isEmpty) {
      GlobalSnackBar.valid(context,
          S.of(context).pleaseEnterNumberOfTouristSaversToBeTransferred);
      return;
    }

    if (double.parse(transferredPiiinksController.text) == 0) {
      GlobalSnackBar.valid(context,
          S.of(context).pleaseEnterValidNumberOfTouristSaversToBeTransferred);
      return;
    }

    if (double.parse(transferredPiiinksController.text) >
        selectedMerchantBalance!) {
      GlobalSnackBar.valid(
          context, S.of(context).insufficientTouristSaverCredits);
      return;
    }
    // await FlutterBarcodeScanner.scanBarcode(
    //         '#EC4785', 'Cancel', true, ScanMode.QR)
    //     .then((value) => setState(() {
    //           if (value != '-1') {
    //             memberQrCode = value.split('=').last;
    //           }
    //         }))
    //     .then((value) async {
    //   setState(() {
    //     qrScanLoading = true;
    //   });
    //   var res = await DioTransfer().tansferPiiinksQR(
    //     transferPiiinksReqModel: TransferPiiinksReqModel(
    //         merchantId: selectedMerchantID,
    //         balance: double.parse(transferredPiiinksController.text.trim()),
    //         uniqueMemberCode: memberQrCode),
    //   );
    //   if (!mounted) return;
    //   if (res is TransferPiiinkResModel) {
    //     if (res.status == "Success") {
    //       GlobalSnackBar.showSuccess(
    //           context, S.of(context).piiinkTransferredSuccessfully);
    //       setState(() {
    //         isLoading = false;
    //         qrScanLoading = false;
    //         memberQrCode = null;
    //       });
    //       context.pop();
    //       return;
    //     }
    //   } else if (res == 400) {
    //     GlobalSnackBar.showError(context, S.of(context).invalidQrCode);
    //     setState(() {
    //       isLoading = false;
    //       qrScanLoading = false;
    //     });
    //     return;
    //   } else {
    //     GlobalSnackBar.showError(context, S.of(context).pleaseTryAgain);
    //     setState(() {
    //       isLoading = false;
    //       qrScanLoading = false;
    //       memberQrCode = null;
    //     });
    //     return;
    //   }
    // });
  }

  @override
  void initState() {
    phonePrefix = getPhonePrefix();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _shareBackground,
      appBar: _shareCreditsAppBar(),
      body: BlocProvider(
        lazy: false,
        create: (context) =>
            ProfileWalletBloc(RepositoryProvider.of<DioWallet>(context))
              ..add(GetMerchantUserWalletEvent()),
        child: BlocBuilder<ProfileWalletBloc, ProfileWalletState>(
          builder: (context, state) {
            // Loading State
            if (state is ProfileWalletLoadingState) {
              return const Column(
                children: [
                  CustomAllLoader(),
                ],
              );
            }
            // Loaded State
            else if (state is ProfileWalletLoadedState) {
              Data? data = state.merchantWallet?.data;
              if (data?.merchantWallet == null ||
                  data!.merchantWallet!.isEmpty) {
                return noMerchantAvailable();
              } else {
                List<MerchantWallet> totalMerchantWallets =
                    data.merchantWallet!;
                if (!walletLoaded) {
                  List<MerchantWallet>? merchantFranchiseWallet =
                      data.merchantFranchiseWallet;
                  if (merchantFranchiseWallet != null &&
                      merchantFranchiseWallet.isNotEmpty) {
                    totalMerchantWallets.addAll(merchantFranchiseWallet);
                  }
                  walletLoaded = true;
                }
                return SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 26.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _ShareCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Share unused Merchant Discount Credits with another TouristSaver member.',
                              style: _headingStyle(),
                            ),
                            SizedBox(height: 8.h),
                            Text(
                              'For example, you can share leftover merchant credits with a friend so they can save on their next visit.',
                              style: _helperStyle(),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 14.h),
                      _ShareCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Merchant credits', style: _labelStyle()),
                            SizedBox(height: 8.h),
                            merchantPiiink(totalMerchantWallets),
                            SizedBox(height: 16.h),
                            Text(
                              'Enter the TouristSaver Discount Credits you would like to transfer.',
                              style: _helperStyle(),
                            ),
                            SizedBox(height: 8.h),
                            _discountCreditsAmountRow(),
                          ],
                        ),
                      ),
                      SizedBox(height: 14.h),
                      _ShareCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text('Send to another member',
                                style: _headingStyle()),
                            SizedBox(height: 12.h),
                            _SharePrimaryButton(
                              text: 'Scan Recipient QR Code',
                              isLoading: qrScanLoading,
                              onPressed: isLoading ? () {} : _scanMemberQr,
                            ),
                            SizedBox(height: 14.h),
                            Center(
                              child: Text(
                                S.of(context).or.toUpperCase(),
                                style: TextStyle(
                                  color: _shareMuted,
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w900,
                                  fontFamily: 'Sans',
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ),
                            SizedBox(height: 14.h),
                            Text('Enter mobile number', style: _labelStyle()),
                            SizedBox(height: 8.h),
                            preNumSection(),
                          ],
                        ),
                      ),
                      SizedBox(height: 16.h),
                      _SharePrimaryButton(
                        text: S.of(context).send,
                        isLoading: isLoading,
                        onPressed: qrScanLoading ? () {} : manualTransfer,
                      ),
                      SizedBox(height: 10.h),
                      _ShareSecondaryButton(
                        text: S.of(context).cancel,
                        onPressed: () {
                          context.pop();
                        },
                      ),
                    ],
                  ),
                );
              }
            } else if (state is ProfileWalletErrorState) {
              return const Error1();
            } else {
              return const SizedBox();
            }
          },
        ),
      ),
    );
  }

  PreferredSizeWidget _shareCreditsAppBar() {
    return AppBar(
      flexibleSpace: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF6F6F6),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.2),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(2, 2),
            ),
          ],
        ),
      ),
      elevation: 0,
      centerTitle: true,
      leadingWidth: 40,
      titleSpacing: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios),
        color: Colors.black.withValues(alpha: 0.8),
        iconSize: 20,
        onPressed: () {
          context.pop();
        },
      ),
      title: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 4),
        child: AutoSizeText(
          'Share Merchant Discount Credits',
          maxLines: 1,
          minFontSize: 13,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: _shareNavy,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      actions: const [
        SizedBox(width: 40),
      ],
    );
  }

//Mannual Transfer using phone number
  manualTransfer() async {
    if (selectedMerchantPiiinks == null) {
      GlobalSnackBar.valid(context, S.of(context).pleaseSelectMerchant);
      return;
    }
    if (transferredPiiinksController.text.isEmpty) {
      GlobalSnackBar.valid(context,
          S.of(context).pleaseEnterNumberOfTouristSaversToBeTransferred);
      return;
    }

    if (double.parse(transferredPiiinksController.text) == 0) {
      GlobalSnackBar.valid(context,
          S.of(context).pleaseEnterValidNumberOfTouristSaversToBeTransferred);
      return;
    }

    if (double.parse(transferredPiiinksController.text) >
        selectedMerchantBalance!) {
      GlobalSnackBar.valid(
          context, S.of(context).insufficientTouristSaverCredits);
      return;
    }
    if (receiverNumberController.text.isEmpty) {
      GlobalSnackBar.valid(context, S.of(context).pleaseEnterMobileNumber);
      return;
    }
    if (receiverNumberController.text.length < 7) {
      GlobalSnackBar.valid(
          context, S.of(context).mobileNumberMustBeAtLeast7Digits);
      return;
    }
    setState(() {
      isLoading = true;
    });
    var res = await DioTransfer().tansferPiiink(
      transferPiiinkReqModel: TransferPiiinkReqModel(
        merchantId: selectedMerchantID,
        balance: double.parse(transferredPiiinksController.text.trim()),
        phonePrefix: phPrefix,
        phoneNumber: receiverNumberController.text.trim(),
      ),
    );
    if (!mounted) return;
    if (res is TransferPiiinkResModel) {
      if (res.status == "Success") {
        GlobalSnackBar.showSuccess(
            context, S.of(context).touristSaverTransferredSuccessfully);
        setState(() {
          isLoading = false;
        });
        context.pop();
        return;
      }
    } else if (res == 400) {
      GlobalSnackBar.showError(
          context, S.of(context).pleaseEnterCorrectMobileNumber);
      setState(() {
        isLoading = false;
      });
      return;
    } else {
      GlobalSnackBar.showError(context, S.of(context).pleaseTryAgain);
      setState(() {
        isLoading = false;
      });
      return;
    }
  }

  // No Merchant Piiink Available
  noMerchantAvailable() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
      child: NotAvailable(
        titleText: S.of(context).noMerchantTouristSaverAvailable,
        bodyText: S
            .of(context)
            .firstTryShoppingWithSomeMerchantsToGainAndTransferMerchantTouristSavers,
        image: "assets/images/shopping-bag.png",
      ),
    );
  }

  Widget _discountCreditsAmountRow() {
    return Row(
      children: [
        Expanded(
          child: Text(
            'Discount Credits \$',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: _labelStyle(),
          ),
        ),
        SizedBox(width: 12.w),
        SizedBox(
          width: 112.w,
          height: 52.h,
          child: TextFormField(
            controller: transferredPiiinksController,
            cursorColor: _sharePrimaryBlue,
            textAlign: TextAlign.right,
            keyboardType: TextInputType.number,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.allow(RegExp(r'(^\d*\.?\d{0,2})'))
            ],
            decoration: _shareInputDecoration(
              hintText: '0.00',
              alignHintRight: true,
            ),
          ),
        ),
      ],
    );
  }

  // select merchant piiink dropDown
  merchantPiiink(List<MerchantWallet> totalMerchantWallets) {
    return DropdownButtonWidget(
      label: 'Choose merchant credits',
      searchController: searchController,
      value: selectedMerchantPiiinks,
      lPadding: 15,
      fillColor: const Color(0xFFF7F9FC),
      borderColor: _shareBorder,
      borderRadius: 16,
      iconColor: _sharePrimaryBlue,
      hintStyle: TextStyle(
        color: _shareMuted,
        fontSize: 14.sp,
        fontWeight: FontWeight.w700,
        fontFamily: 'Sans',
      ),
      height: 52.h,
      buttonHeight: 52.h,
      items: totalMerchantWallets.map((e) {
        return DropdownMenuItem(
          value:
              "${e.merchant!.merchantName} (${toFixed2DecimalPlaces(e.balance!)})",
          child: Tooltip(
            message:
                "${e.merchant!.merchantName} (${toFixed2DecimalPlaces(e.balance!)} ${S.of(context).touristSavers})",
            child: Padding(
              padding: const EdgeInsets.only(left: 25.0),
              child: AutoSizeText(
                "${e.merchant!.merchantName} (${toFixed2DecimalPlaces(e.balance!)} ${S.of(context).touristSavers})",
                overflow: TextOverflow.ellipsis,
                style: _dropdownTextStyle(),
              ),
            ),
          ),
        );
      }).toList(),
      onChanged: (newValue) {
        setState(() {
          selectedMerchantPiiinks = newValue as String;
          searchController.clear();
        });
        final merchantID = totalMerchantWallets.firstWhere((element) =>
            "${element.merchant!.merchantName} (${toFixed2DecimalPlaces(element.balance!)})" ==
            selectedMerchantPiiinks);
        selectedMerchantID = merchantID.id;
        selectedMerchantBalance = merchantID.balance;
      },
    );
  }

  // receiver number with prefix
  preNumSection() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FutureBuilder<LocationGetAllResModel?>(
            future: phonePrefix,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Container(
                  height: 52.h,
                  width: 82.w,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF7F9FC),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: _shareBorder),
                  ),
                );
              } else {
                return Container(
                  height: 52.h,
                  width: 82.w,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF7F9FC),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: _shareBorder),
                  ),
                  child: Center(
                    child: AutoSizeText(
                      phPrefix!,
                      style: TextStyle(
                        color: _shareNavy,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w800,
                        fontFamily: 'Sans',
                      ),
                    ),
                  ),
                );
              }
            }),
        SizedBox(width: 10.w),
        Expanded(
          child: TextFormField(
            controller: receiverNumberController,
            cursorColor: _sharePrimaryBlue,
            decoration: _shareInputDecoration(hintText: 'Enter mobile number'),
            keyboardType: TextInputType.number,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.allow(RegExp(r'(^\d{0,15})'))
            ],
          ),
        ),
      ],
    );
  }

  TextStyle _headingStyle() {
    return TextStyle(
      color: _shareNavy,
      fontSize: 17.sp,
      fontWeight: FontWeight.w900,
      fontFamily: 'Sans',
      height: 1.25,
    );
  }

  TextStyle _labelStyle() {
    return TextStyle(
      color: _shareNavy,
      fontSize: 14.sp,
      fontWeight: FontWeight.w900,
      fontFamily: 'Sans',
    );
  }

  TextStyle _helperStyle() {
    return TextStyle(
      color: _shareMuted,
      fontSize: 13.sp,
      fontWeight: FontWeight.w600,
      fontFamily: 'Sans',
      height: 1.35,
    );
  }

  TextStyle _dropdownTextStyle() {
    return TextStyle(
      color: _shareNavy,
      fontSize: 14.sp,
      fontWeight: FontWeight.w800,
      fontFamily: 'Sans',
    );
  }

  InputDecoration _shareInputDecoration({
    required String hintText,
    bool alignHintRight = false,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintTextDirection: alignHintRight ? TextDirection.rtl : null,
      hintStyle: TextStyle(
        color: _shareMuted,
        fontSize: 14.sp,
        fontWeight: FontWeight.w700,
        fontFamily: 'Sans',
      ),
      filled: true,
      fillColor: const Color(0xFFF7F9FC),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: _shareBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: _sharePrimaryBlue, width: 1.3),
      ),
    );
  }
}

class _ShareCard extends StatelessWidget {
  const _ShareCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22.r),
        border: Border.all(color: _shareBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _SharePrimaryButton extends StatelessWidget {
  const _SharePrimaryButton({
    required this.text,
    required this.onPressed,
    this.isLoading = false,
  });

  final String text;
  final VoidCallback onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: isLoading ? null : onPressed,
          child: Ink(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [_sharePrimaryBlue, _shareCtaCyan],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: _sharePrimaryBlue.withValues(alpha: 0.18),
                  blurRadius: 18,
                  offset: const Offset(0, 9),
                ),
              ],
            ),
            child: Center(
              child: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.2,
                      ),
                    )
                  : AutoSizeText(
                      text,
                      maxLines: 1,
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
      ),
    );
  }
}

class _ShareSecondaryButton extends StatelessWidget {
  const _ShareSecondaryButton({
    required this.text,
    required this.onPressed,
  });

  final String text;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: _sharePrimaryBlue,
          side: const BorderSide(color: _shareBorder),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          backgroundColor: Colors.white,
        ),
        child: AutoSizeText(
          text,
          maxLines: 1,
          style: TextStyle(
            color: _sharePrimaryBlue,
            fontSize: 15.sp,
            fontWeight: FontWeight.w900,
            fontFamily: 'Sans',
          ),
        ),
      ),
    );
  }
}
