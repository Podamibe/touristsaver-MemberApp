import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:touristsaver/common/widgets/custom_app_bar.dart';
import 'package:touristsaver/common/widgets/custom_button.dart';
import 'package:touristsaver/common/widgets/custom_loader.dart';
import 'package:touristsaver/common/widgets/custom_snackbar.dart';
import 'package:touristsaver/common/widgets/dropdown_button_widget.dart';
import 'package:touristsaver/common/widgets/error.dart';
import 'package:touristsaver/common/widgets/not_available.dart';
import 'package:touristsaver/constants/global_colors.dart';
import 'package:touristsaver/constants/style.dart';
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
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: CustomAppBar(
          text: S.of(context).transferTouristSavers,
          icon: Icons.arrow_back_ios,
          onPressed: () {
            context.pop();
          },
        ),
      ),
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
                  child: Container(
                    width: MediaQuery.of(context).size.width / 1.05,
                    padding: const EdgeInsets.symmetric(
                        vertical: 20.0, horizontal: 10.0),
                    margin: const EdgeInsets.symmetric(
                        vertical: 10.0, horizontal: 10.0),
                    decoration: BoxDecoration(
                        color: GlobalColors.appWhiteBackgroundColor,
                        borderRadius: BorderRadius.circular(5.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withValues(alpha: 0.2),
                            blurRadius: 4,
                            spreadRadius: 1,
                            offset: const Offset(2, 2),
                          )
                        ]),
                    child: Column(
                      children: [
                        merchantPiiink(totalMerchantWallets),
                        const SizedBox(height: 15),
                        SizedBox(
                          height: 50.h,
                          width: MediaQuery.of(context).size.width / 1.2,
                          child: TextFormField(
                            controller: transferredPiiinksController,
                            cursorColor: GlobalColors.appColor,
                            keyboardType: TextInputType.number,
                            inputFormatters: <TextInputFormatter>[
                              FilteringTextInputFormatter.allow(
                                  RegExp(r'(^\d*\.?\d{0,2})'))
                            ],
                            decoration: textInputDecoration1.copyWith(
                                hintText: S
                                    .of(context)
                                    .numberOfTouristSaversToBeTransferred),
                          ),
                        ),
                        const SizedBox(height: 15),
                        qrScanLoading
                            ? const CustomButtonWithCircular()
                            : CustomButton(
                                onPressed: isLoading ? () {} : _scanMemberQr,
                                text: S.of(context).scanReceiverMemberQr),
                        const SizedBox(height: 15),
                        Text(
                          S.of(context).or,
                          style: merchantNameStyle,
                        ),
                        const SizedBox(height: 15),
                        //  Select Receiver Number
                        preNumSection(),

                        const SizedBox(height: 15),

                        // Send Button
                        isLoading == true
                            ? const CustomButtonWithCircular()
                            : CustomButton(
                                text: S.of(context).send,
                                onPressed:
                                    qrScanLoading ? () {} : manualTransfer,
                              ),

                        const SizedBox(height: 15),

                        // Cancel Button
                        CustomButton1(
                          text: S.of(context).cancel,
                          onPressed: () {
                            context.pop();
                          },
                        ),
                      ],
                    ),
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

  // select merchant piiink dropDown
  merchantPiiink(List<MerchantWallet> totalMerchantWallets) {
    return DropdownButtonWidget(
      label: S.of(context).selectMerchantTouristSavers,
      searchController: searchController,
      value: selectedMerchantPiiinks,
      lPadding: 15,
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
                style: dopdownTextStyle,
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
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        FutureBuilder<LocationGetAllResModel?>(
            future: phonePrefix,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Container(
                  height: 50,
                  width: 80,
                  decoration: BoxDecoration(
                    color: GlobalColors.paleGray,
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                );
              } else {
                return Container(
                  height: 50,
                  width: 80,
                  decoration: BoxDecoration(
                    color: GlobalColors.paleGray,
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                  child: Center(
                    child: AutoSizeText(
                      phPrefix!,
                      style:
                          locationStyle.copyWith(fontWeight: FontWeight.w500),
                    ),
                  ),
                );
              }
            }),
        const SizedBox(width: 5),
        SizedBox(
          width: MediaQuery.of(context).size.width / 1.7,
          child: TextFormField(
            controller: receiverNumberController,
            cursorColor: GlobalColors.appColor,
            decoration: textInputDecoration1.copyWith(
                hintText: S.of(context).mobileNumber),
            keyboardType: TextInputType.number,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.allow(RegExp(r'(^\d{0,15})'))
            ],
          ),
        ),
      ],
    );
  }
}
