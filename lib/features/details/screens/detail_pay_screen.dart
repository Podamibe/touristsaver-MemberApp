import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:touristsaver/common/app_variables.dart';
import 'package:touristsaver/common/widgets/custom_app_bar.dart';
import 'package:touristsaver/common/widgets/custom_button.dart';
import 'package:touristsaver/common/widgets/custom_loader.dart';
import 'package:touristsaver/common/widgets/custom_snackbar.dart';
import 'package:touristsaver/common/widgets/error.dart';
import 'package:touristsaver/constants/fixed_decimal.dart';
import 'package:touristsaver/constants/global_colors.dart';
import 'package:touristsaver/constants/style.dart';
import 'package:touristsaver/features/payment/services/dio_payment.dart';
import 'package:touristsaver/features/payment/widgets/num_pad.dart';
import 'package:touristsaver/models/error_res.dart';
import 'package:touristsaver/models/request/confirm_piiink_req.dart';
import 'package:touristsaver/models/response/confirm_piiink_res.dart';
import 'package:touristsaver/models/response/is_pay_enable_res.dart';
import 'package:touristsaver/generated/l10n.dart';

class DetailPayScreen extends StatefulWidget {
  static const String routeName = '/detail-pay';
  final String merchantName;
  final String transactionCode;
  const DetailPayScreen(
      {super.key, required this.merchantName, required this.transactionCode});

  @override
  State<DetailPayScreen> createState() => _DetailPayScreenState();
}

class _DetailPayScreenState extends State<DetailPayScreen> {
  final payKey = GlobalKey<FormState>();
  TextEditingController amountController = TextEditingController();

  // For Loader
  bool isLoading = false;

  //Checking whether the pay is enabled or not
  Future<IsPayEnableResModel?>? payE;
  Future<IsPayEnableResModel?>? payEnabled() async {
    IsPayEnableResModel? isPayEnabledResModel = await DioPay().payEnabled();
    return isPayEnabledResModel;
  }

  @override
  void initState() {
    payE = payEnabled();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: CustomAppBar(
            text: widget.merchantName,
            icon: Icons.arrow_back_ios,
            onPressed: () {
              context.pop();
            }),
      ),
      body: ScrollConfiguration(
        behavior: const ScrollBehavior(),
        child: SingleChildScrollView(
          child: FutureBuilder<IsPayEnableResModel?>(
            future: payE,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const Error1();
              } else if (!snapshot.hasData) {
                return const CustomAllLoader();
              } else {
                return snapshot.data!.data!.transactionIsEnabled == true
                    ? Form(
                        key: payKey,
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 10.0, vertical: 10.0),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 15, vertical: 20),
                          width: MediaQuery.of(context).size.width / 1,
                          constraints: const BoxConstraints(
                            //To make height expandable according to the text
                            maxHeight: double.infinity,
                          ),
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
                              AutoSizeText(
                                S.of(context).enterAmountOfTransaction,
                                style: topicStyle,
                              ),
                              const SizedBox(height: 20),

                              // Amount Enter
                              SizedBox(
                                width: MediaQuery.of(context).size.width / 1.2,
                                child: IgnorePointer(
                                  child: TextFormField(
                                    controller: amountController,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(fontSize: 20.sp),
                                    decoration: textInputDecoration1.copyWith(
                                      hintText: AppVariables.currency,
                                      hintStyle: TextStyle(
                                          color: GlobalColors.gray
                                              .withValues(alpha: 0.8),
                                          fontSize: 20.sp,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ),
                                ),
                              ),

                              // implement the custom NumPad
                              NumPad(
                                buttonSize: 70,
                                buttonColor: Colors.white,
                                iconColor: GlobalColors.appColor,
                                controller: amountController,
                                delete: () {
                                  amountController.text.isEmpty
                                      ? null
                                      : amountController.text =
                                          amountController.text.substring(0,
                                              amountController.text.length - 1);
                                },
                              ),

                              const SizedBox(height: 20),

                              isLoading == true
                                  ? const CustomButtonWithCircular()
                                  : CustomButton(
                                      text: S.of(context).proceed,
                                      onPressed: () async {
                                        setState(() {
                                          isLoading = true;
                                        });
                                        if (payKey.currentState!.validate()) {
                                          if (amountController.text.isEmpty ||
                                              double.parse(
                                                      amountController.text) <=
                                                  0) {
                                            GlobalSnackBar.valid(
                                                context,
                                                S
                                                    .of(context)
                                                    .pleaseEnterTheRightAmount);
                                            setState(() {
                                              isLoading = false;
                                            });
                                            return;
                                          }

                                          var res =
                                              await DioPay().confirmApplyPiiink(
                                            confirmApplyPiiinkReqModel:
                                                ConfirmApplyPiiinkReqModel(
                                              totalAmount: double.parse(
                                                  amountController.text),
                                              transactionQRCode:
                                                  widget.transactionCode,
                                              hour: int.parse(DateFormat('HH ')
                                                  .format(DateTime.now())),
                                              week: DateTime.now().weekday % 7,
                                            ),
                                          );

                                          if (!mounted) return;
                                          if (res
                                              is ConfirmApplyPiiinkResModel) {
                                            if (res.status == "Success") {
                                              setState(() {
                                                isLoading = false;
                                              });
                                              context.pushNamed('confirm-pay',
                                                  extra: {
                                                    'totalAmount':
                                                        amountController.text
                                                            .trim(),
                                                    'qrCode':
                                                        widget.transactionCode,
                                                    'hasMerchantPiiinks': res
                                                        .data!
                                                        .hasMerchantPiiinks
                                                        .toString(),
                                                    'hasUniversalPiiinks': res
                                                        .data!
                                                        .hasUniversalPiiinks
                                                        .toString(),
                                                    'merchantName': res
                                                        .data!
                                                        .merchantInfo!
                                                        .merchantName,
                                                    'universalPiiinkBalance':
                                                        toFixed2DecimalPlaces(res
                                                                .data!
                                                                .universalPiiinkBalance!)
                                                            .toString(),
                                                    'merchantPiiinkBalance':
                                                        toFixed2DecimalPlaces(res
                                                                .data!
                                                                .merchantPiiinkBalance!)
                                                            .toString(),
                                                    'merchantRebateToMember': res
                                                        .data!
                                                        .merchantRebateToMember
                                                        .toString(),
                                                    'discountedTransactionAmount': res
                                                        .data!
                                                        .discountedTransactionAmount
                                                        .toString(),
                                                    'totalPiiinkDiscount': res
                                                        .data!
                                                        .totalPiiinkDiscount
                                                        .toString(),
                                                    'logo': res
                                                                .data!
                                                                .merchantInfo
                                                                ?.merchantImageInfo ==
                                                            null
                                                        ? 'null'
                                                        : res
                                                                .data!
                                                                .merchantInfo
                                                                ?.merchantImageInfo
                                                                ?.logoUrl ??
                                                            res
                                                                .data!
                                                                .merchantInfo
                                                                ?.merchantImageInfo
                                                                ?.slider1 ??
                                                            'null',
                                                    'universalPiiinkOnHold': res
                                                        .data!
                                                        .universalPiiinkBalanceOnHold
                                                        .toString(),
                                                    'merchantPiiinkOnHold': res
                                                        .data!
                                                        .merchantPiiinkBalanceOnHold
                                                        .toString(),
                                                  });
                                            } else {
                                              GlobalSnackBar.showError(
                                                  context,
                                                  S
                                                      .of(context)
                                                      .notEnoughTouristSaverCredits);
                                              setState(() {
                                                isLoading = false;
                                              });
                                              return;
                                            }
                                          } else if (res is ErrorResModel) {
                                            GlobalSnackBar.showError(
                                                context, res.message!);
                                            setState(() {
                                              isLoading = false;
                                            });
                                            return;
                                          } else {
                                            GlobalSnackBar.showError(
                                                context,
                                                S
                                                    .of(context)
                                                    .somethingWentWrong);
                                            setState(() {
                                              isLoading = false;
                                            });
                                            return;
                                          }
                                        }
                                      },
                                    ),
                            ],
                          ),
                        ),
                      )
                    : daysMoreToGo(snapshot.data!);
              }
            },
          ),
        ),
      ),
    );
  }

  //Showing how many more days to go for a pay section
  daysMoreToGo(IsPayEnableResModel? getData) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
      width: MediaQuery.of(context).size.width / 1,
      constraints: const BoxConstraints(
        //To make height expandable according to the text
        maxHeight: double.infinity,
      ),
      child: Column(
        children: [
          const SizedBox(height: 30),
          SizedBox(
            child: Image.asset(
              "assets/images/coming-soon-icon.png",
              height: 200,
              width: MediaQuery.of(context).size.width / 2,
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
    );
  }
}
