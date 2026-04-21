import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:go_router/go_router.dart';
import 'package:new_piiink/common/app_variables.dart';
import 'package:new_piiink/common/services/dio_common.dart';
import 'package:new_piiink/common/widgets/custom_app_bar.dart';
import 'package:new_piiink/common/widgets/custom_button.dart';
import 'package:new_piiink/common/widgets/custom_loader.dart';
import 'package:new_piiink/common/widgets/custom_snackbar.dart';
import 'package:new_piiink/common/widgets/error.dart';
import 'package:new_piiink/common/widgets/not_available.dart';
import 'package:new_piiink/constants/decimal_remove.dart';
import 'package:new_piiink/constants/global_colors.dart';
import 'package:new_piiink/constants/number_formatter.dart';
import 'package:new_piiink/constants/pref.dart';
import 'package:new_piiink/constants/pref_key.dart';
import 'package:new_piiink/constants/style.dart';
import 'package:new_piiink/features/profile/widget/info_popup.dart';
import 'package:new_piiink/features/top_up/bloc/mem_pack_bloc.dart';
import 'package:new_piiink/features/top_up/bloc/mem_pack_event.dart';
import 'package:new_piiink/features/top_up/bloc/mem_pack_state.dart';
import 'package:new_piiink/features/top_up/services/top_up_dio.dart';
import 'package:new_piiink/features/wallet/services/dio_wallet.dart';
import 'package:new_piiink/models/request/confirm_topup_req.dart';
import 'package:new_piiink/models/request/premium_topup_req.dart';
import 'package:new_piiink/models/request/top_up_stripe_req.dart';
import 'package:new_piiink/models/response/confirm_topup_res.dart';
import 'package:new_piiink/models/response/member_package_res.dart';
import 'package:new_piiink/models/response/pre_topup_free_res.dart';
import 'package:new_piiink/models/response/pre_topup_paid_res.dart';
import 'package:new_piiink/models/response/premium_validity_res.dart';
import 'package:new_piiink/models/response/top_up_stripe_res.dart';

import 'package:new_piiink/generated/l10n.dart';
import 'package:new_piiink/splash_screen.dart';

class PaidFreeScreen extends StatefulWidget {
  static const String routeName = '/paid-free';
  const PaidFreeScreen({super.key});

  @override
  State<PaidFreeScreen> createState() => _PaidFreeScreenState();
}

class _PaidFreeScreenState extends State<PaidFreeScreen> {
  TextEditingController premiumController = TextEditingController();

  // To get saved Country ID
  String? countryId;
  String? currencyPref;

  // For Loading part
  bool isLoading = false;
  bool isAppliedLoading = false;
  double? piiinkCre;

  // Premium data mapping
  dynamic premiumData;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      countryId = await Pref().readData(key: saveCountryID);
    });
    super.initState();
    fetchMemberPremiumGetOne();
  }

  Future<void> fetchMemberPremiumGetOne() async {
    try {
      var res = await DioCommon().getdiscountInmemberPremiumCode();
      if (res != null && res['status'] == "Success") {
        if (!mounted) return;
        setState(() {
          premiumData = res['data'];
        });
      }
    } catch (e) {
      debugPrint("Error processing banner: $e");
    }
  }

  // Piiink loaded quantity method updated to pass premiumData
  piiinkLoaded(MemberShipPackageResModel memPackAll, String? countryId) {
    return ListView.separated(
      separatorBuilder: (context, index) {
        return const SizedBox(height: 20);
      },
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: memPackAll.data!.length,
      itemBuilder: (context, index) {
        return TopUpWidget(
          memPackAll: memPackAll,
          index: index,
          countryID: countryId,
          premiumData: premiumData, // Pass the data to the child
        );
      },
    );
  }

  // ... [Keep your existing applyPremium, giveAwayPopUp, invalidCode, applyButton, etc.]
  applyPremium() async {
    setState(() {
      isAppliedLoading = true;
    });
    if (premiumController.text.isEmpty) {
      setState(() {
        isAppliedLoading = false;
      });
      GlobalSnackBar.valid(context, S.of(context).pleaseEnterThePremiumCode);
      return;
    } else {
      var firstCheckPremium = await DioTopUpStripe().premiumTopupValidity(
        premiumTopUpReqModel: PremiumTopUpReqModel(
          memberPremiumCode: premiumController.text.trim(),
        ),
      );
      if (firstCheckPremium is PremiumValidityResModel) {
        if (firstCheckPremium.status == 'success') {
          var applyRes = await DioTopUpStripe().checkPremiumCodeTopUp(
            premiumTopUpReqModel: PremiumTopUpReqModel(
              memberPremiumCode: premiumController.text.trim(),
            ),
          );
          if (!mounted) return;
          if (applyRes is PremiumTopUpFreeResModel) {
            if (applyRes.status == 'success') {
              setState(() {
                piiinkCre =
                    double.parse(applyRes.data!.piiinksAmount.toString());
                isAppliedLoading = false;
                premiumController.clear();
              });
              giveAwayPopUp();
            } else {
              setState(() {
                isAppliedLoading = false;
              });
              invalidCode();
              return;
            }
          } else if (applyRes is PremiumTopUpPaidResModel) {
            setState(() {
              piiinkCre = applyRes.data?.piiinksAmount;
              isAppliedLoading = false;
              premiumController.clear();
            });
            giveAwayPopUp();
            return;
          } else {
            setState(() {
              isAppliedLoading = false;
            });
            invalidCode();
            return;
          }
        } else {
          setState(() {
            isAppliedLoading = false;
          });
          invalidCode();
        }
      } else {
        setState(() {
          isAppliedLoading = false;
        });
        invalidCode();
      }
    }
  }

  giveAwayPopUp() {
    return showGeneralDialog(
      barrierLabel: 'Label',
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      transitionDuration: const Duration(milliseconds: 300),
      context: context,
      pageBuilder: (context, anim1, anim2) {
        return Align(
          alignment: Alignment.center,
          child: InfoPopUp(
            textAlign: TextAlign.center,
            title: S
                .of(context)
                .congratulationXTouristSaversHasBeenAddedToYourWallet
                .replaceAll(
                    '&X', removeTrailingZero(numFormatter.format(piiinkCre))),
            onOk: () {
              context.pop();
              context.pop();
            },
          ),
        );
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return SlideTransition(
          position: Tween(begin: const Offset(0, 1), end: const Offset(0, 0))
              .animate(anim1),
          child: child,
        );
      },
    );
  }

  invalidCode() {
    return showGeneralDialog(
      barrierLabel: 'Label',
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      transitionDuration: const Duration(milliseconds: 300),
      context: context,
      pageBuilder: (context, anim1, anim2) {
        return Align(
          alignment: Alignment.center,
          child: InfoPopUp(
            title: S.of(context).premiumCodeIsNotValid,
            image: 'assets/images/oops.png',
            onOk: () {
              context.pop();
            },
          ),
        );
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return SlideTransition(
          position: Tween(begin: const Offset(0, 1), end: const Offset(0, 0))
              .animate(anim1),
          child: child,
        );
      },
    );
  }

  applyButton({required Widget widget, required VoidCallback onPressed}) {
    return Container(
      decoration:
          BoxDecoration(borderRadius: BorderRadius.circular(10), boxShadow: [
        BoxShadow(
            color: Colors.grey.withValues(alpha: 0.2),
            blurRadius: 4,
            spreadRadius: 1,
            offset: const Offset(2, 2))
      ]),
      width: MediaQuery.of(context).size.width / 4.6,
      height: 45.h,
      child: ElevatedButton(
        onPressed: onPressed,
        style: styleMainButton,
        child: widget,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final discountStr = premiumData?['discount'];
    double discountPercent =
        double.tryParse(discountStr?.toString() ?? "0") ?? 0;
    String appBarTitle =
        discountPercent == 100 ? "Free Membership" : "Join now";
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: FutureBuilder<bool>(
          future: checkWalletBalance(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const SizedBox.shrink();
            final hasBalance = snapshot.data ?? false;
            return hasBalance
                ? CustomAppBar(
                    text: appBarTitle, // 👉 3. Apply the dynamic title here!
                    // icon: Icons.arrow_back_ios,
                    // onPressed: () => context.pop()
                  )
                : CustomAppBar(
                    text: appBarTitle, // 👉 Apply it here too!
                    icon: Icons.person_outlined,
                    onPressed: () => context.push('/log-profile'));
          },
        ),
      ),
      // 1. Move BlocProvider to the top of the body
      body: BlocProvider(
        lazy: false,
        create: (context) =>
            MemPackAllBloc(RepositoryProvider.of<DioTopUpStripe>(context))
              ..add(LoadMemPackAllEvent()),
        // 2. Use a Builder to get the correct context for the Bloc
        child: Builder(
          builder: (context) {
            // 3. Wrap with RefreshIndicator
            return RefreshIndicator(
              color: GlobalColors.appColor,
              onRefresh: () async {
                // Re-fetch the premium discount code data
                await fetchMemberPremiumGetOne();
                // Re-fetch the membership packages from the API
                context.read<MemPackAllBloc>().add(LoadMemPackAllEvent());
              },
              child: ScrollConfiguration(
                behavior: const ScrollBehavior(),
                child: SingleChildScrollView(
                  // 👉 CRITICAL: AlwaysScrollableScrollPhysics is required for
                  // RefreshIndicator to work even if the screen isn't full!
                  physics: const AlwaysScrollableScrollPhysics(),
                  scrollDirection: Axis.vertical,
                  // We add a minimum height so the refresh indicator always has space to pull
                  child: Container(
                    constraints: BoxConstraints(
                      minHeight: MediaQuery.of(context).size.height,
                    ),
                    alignment: Alignment.topCenter,
                    child: BlocBuilder<MemPackAllBloc, MemPackAllState>(
                      builder: (context, state) {
                        if (state is MemPackAllLoadingState) {
                          return const CustomAllLoader();
                        } else if (state is MemPackAllLoadedState) {
                          MemberShipPackageResModel memPackAll =
                              state.memPackAll;
                          return memPackAll.data!.isEmpty
                              ? Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 10.0, horizontal: 10.0),
                                  child: NoDataFound(
                                    titleText: S.of(context).noTopUpAvailable,
                                    bodyText: S
                                        .of(context)
                                        .noTopupPacakgeAvailableForNow,
                                    image: "assets/images/oops.png",
                                  ),
                                )
                              : Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Column(
                                    children: [
                                      // Center(
                                      //     child: AutoSizeText(
                                      //         S
                                      //             .of(context)
                                      //             .topUpYourUniversalTouristSaversToGainExtraCreditAndEnjoyMoreOffersFromYourFavouriteMerchants,
                                      //         textAlign: TextAlign.center,
                                      //         style: textStyle15)),
                                      // const SizedBox(height: 30),
                                      piiinkLoaded(memPackAll, countryId),
                                      Center(
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                              10), // Optional rounded corners
                                          child: Image.asset(
                                            "assets/images/dreamworld.png",
                                            fit: BoxFit.contain,
                                          ),
                                        ),
                                      )

                                      // 👉 Check if Premium Data exists. If yes, show Image. If no, show the input field.
                                      // (premiumData != null &&
                                      //         premiumData.toString() != "[]" &&
                                      //         premiumData.toString() != "{}")
                                      //     ? Center(
                                      //         child: ClipRRect(
                                      //           borderRadius: BorderRadius.circular(
                                      //               10), // Optional rounded corners
                                      //           child: Image.asset(
                                      //             "assets/images/dreamworld.png",
                                      //             fit: BoxFit.contain,
                                      //           ),
                                      //         ),
                                      //       )
                                      //     : Column(
                                      //         children: [
                                      //           Center(
                                      //               child: Text(
                                      //                   S.of(context).or,
                                      //                   textAlign:
                                      //                       TextAlign.center,
                                      //                   style: topicStyle)),
                                      //           const SizedBox(height: 30),
                                      //           Center(
                                      //               child: Text(
                                      //                   S
                                      //                       .of(context)
                                      //                       .applyPremiumCode,
                                      //                   textAlign:
                                      //                       TextAlign.center,
                                      //                   style: textStyle15)),
                                      //           const SizedBox(height: 20),
                                      //           Row(
                                      //             mainAxisAlignment:
                                      //                 MainAxisAlignment
                                      //                     .spaceBetween,
                                      //             children: [
                                      //               SizedBox(
                                      //                 width:
                                      //                     MediaQuery.of(context)
                                      //                             .size
                                      //                             .width /
                                      //                         1.4,
                                      //                 height: 45.h,
                                      //                 child: TextFormField(
                                      //                   controller:
                                      //                       premiumController,
                                      //                   cursorColor:
                                      //                       GlobalColors
                                      //                           .appColor,
                                      //                   decoration:
                                      //                       textInputDecoration1
                                      //                           .copyWith(
                                      //                     hintText: S
                                      //                         .of(context)
                                      //                         .enterPremiumCode,
                                      //                     fillColor: GlobalColors
                                      //                         .appWhiteBackgroundColor,
                                      //                     border:
                                      //                         OutlineInputBorder(
                                      //                       borderRadius:
                                      //                           BorderRadius
                                      //                               .circular(
                                      //                                   5.0),
                                      //                       borderSide:
                                      //                           const BorderSide(
                                      //                               width: 1,
                                      //                               style: BorderStyle
                                      //                                   .solid),
                                      //                     ),
                                      //                     focusedBorder:
                                      //                         OutlineInputBorder(
                                      //                       borderSide:
                                      //                           const BorderSide(
                                      //                               color: GlobalColors
                                      //                                   .appColor),
                                      //                       borderRadius:
                                      //                           BorderRadius
                                      //                               .circular(
                                      //                                   5.0),
                                      //                     ),
                                      //                   ),
                                      //                 ),
                                      //               ),
                                      //               SizedBox(width: 5.w),
                                      //               isAppliedLoading == true
                                      //                   ? applyButton(
                                      //                       onPressed: () {},
                                      //                       widget: Container(
                                      //                         width: 24.w,
                                      //                         height: 24.h,
                                      //                         padding:
                                      //                             const EdgeInsets
                                      //                                 .all(2.0),
                                      //                         child:
                                      //                             const CircularProgressIndicator(
                                      //                           color: Colors
                                      //                               .white,
                                      //                           strokeWidth: 3,
                                      //                         ),
                                      //                       ),
                                      //                     )
                                      //                   : applyButton(
                                      //                       onPressed: () {
                                      //                         applyPremium();
                                      //                       },
                                      //                       widget: FittedBox(
                                      //                         child: Text(
                                      //                           S
                                      //                               .of(context)
                                      //                               .apply,
                                      //                           style:
                                      //                               buttonText,
                                      //                         ),
                                      //                       ),
                                      //                     ),
                                      //             ],
                                      //           ),
                                      //         ],
                                      //       ),
                                      // const SizedBox(height: 20),
                                    ],
                                  ),
                                );
                        } else if (state is MemPackAllErrorState) {
                          return const Error1();
                        } else {
                          return const SizedBox();
                        }
                      },
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// --- CHILD WIDGET ---
// --- CHILD WIDGET ---

class TopUpWidget extends StatefulWidget {
  const TopUpWidget({
    super.key,
    this.index,
    this.memPackAll,
    this.countryID,
    this.premiumData,
  });
  final String? countryID;
  final int? index;
  final MemberShipPackageResModel? memPackAll;
  final dynamic premiumData;

  @override
  State<TopUpWidget> createState() => _TopUpWidgetState();
}

class _TopUpWidgetState extends State<TopUpWidget> {
  bool isLoading = false;
  Future<void> _handleFreeMemberShip() async {
    // 1. Check if logged in FIRST!
    bool isLoggedIn = AppVariables.accessToken != null &&
        AppVariables.accessToken!.isNotEmpty;

    if (!isLoggedIn) {
      context.pushNamed('login');
      return;
    }

    setState(() {
      isLoading = true;
    });

    // Save this action to local storage so it survives app restarts!
    Pref pref = Pref();
    await pref.writeData(key: 'claimedFreeMembership', value: 'true');

    // 👉 NEW: Print the entire premium data object to your debug console!
    // debugPrint("========== PREMIUM DATA DUMP ==========");
    // debugPrint(widget.premiumData?.toString() ?? "Premium Data is NULL");
    // debugPrint("=======================================");

    // 👉 2. Extract the Piiink amount ONLY from the Premium Code!
    String creditAmount = "0";
    if (widget.premiumData != null &&
        widget.premiumData['piiinksProvided'] != null) {
      creditAmount = widget.premiumData['piiinksProvided'].toString();
    }

    setState(() {
      isLoading = false;
    });

    // 👉 3. Pass the extracted Premium Code amount to the Congrats screen
    context.pushNamed(
      'congrats-screen',
      pathParameters: {
        'piiinkCredit': creditAmount,
      },
    );
  }

  // 👉 We extracted the huge payment logic into this helper function to keep the UI clean!
  Future<void> _handleTopUp() async {
    // 1. Check if logged in FIRST!
    bool isLoggedIn = AppVariables.accessToken != null &&
        AppVariables.accessToken!.isNotEmpty;

    if (!isLoggedIn) {
      context.pushNamed('login');
      return;
    }

    setState(() {
      isLoading = true;
    });

    final originalFee = widget.memPackAll!.data![widget.index!].packageFee!;
    final discountStr = widget.premiumData?['discount'];
    final isDiscountedPackage =
        discountStr != null && discountStr.toString() != "0" && originalFee > 0;

    // 3. Extract the code string
    final String? codeToSend =
        isDiscountedPackage ? widget.premiumData['memberPremiumCode'] : null;

    var res = await DioTopUpStripe().topUpStripe(
      topUpStripeReqModel: TopUpStripeReqModel(
        paymentGateway: 'stripe',
        memberPremiumCode: codeToSend,
        membershipPackageId:
            widget.memPackAll!.data![widget.index!].id.toString(),
        countryId: widget.countryID,
      ),
    );

    if (!mounted) return;

    if (res is TopUpStripeResModel) {
      // --- SCENARIO A: 100% FREE OR DISCOUNTED (No Stripe Required) ---
      if (res.clientSecret == null || res.clientSecret!.isEmpty) {
        setState(() {
          isLoading = false;
        });

        bool canGoHome = await checkWalletBalance();
        if (!context.mounted) return;

        if (canGoHome) {
          GlobalSnackBar.showSuccess(context, S.of(context).paymentSuccessful);
          context.pushReplacementNamed('bottom-bar',
              pathParameters: {'page': '0'});
        } else {
          context.pushReplacementNamed('top-up');
        }
        return;
      }

      // --- SCENARIO B: STRIPE PAYMENT REQUIRED ---
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: res.clientSecret,
          merchantDisplayName: 'Prospects',
          style: ThemeMode.dark,
        ),
      );

      setState(() {
        isLoading = false;
      });

      // Wait for user to complete the Stripe popup
      await displayPaymentSheet(res.clientSecret);

      if (!context.mounted) return;

      // Check balance after successful Stripe payment
      bool canGoHome = await checkWalletBalance();
      if (!context.mounted) return;

      if (canGoHome) {
        GlobalSnackBar.showSuccess(context, S.of(context).paymentSuccessful);
        context
            .pushReplacementNamed('bottom-bar', pathParameters: {'page': '0'});
      } else {
        context.pushReplacementNamed(
            'paid-free'); // Refresh the paid/free screen to show updated balance
      }
    } else {
      setState(() {
        isLoading = false;
      });

      if (!context.mounted) return;
      GlobalSnackBar.showError(
          context, "You are not eligible for this free package.");
    }
  }

  Widget _buildPriceDisplay() {
    final originalFee = widget.memPackAll!.data![widget.index!].packageFee!;
    final currency = widget
        .memPackAll!.data![widget.index!].packageCurrencySymbol
        .toString();
    final textColor = Color(
        int.parse(widget.memPackAll!.data![widget.index!].amountTextColor!));

    final discountStr = widget.premiumData?['discount'];

    if (discountStr != null &&
        discountStr.toString() != "0" &&
        originalFee > 0) {
      double discountPercent = double.tryParse(discountStr.toString()) ?? 0;
      double finalFee = originalFee * (1 - (discountPercent / 100));

      return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
            decoration: BoxDecoration(
                color: Colors.red, borderRadius: BorderRadius.circular(4)),
            child: Text("$discountStr% OFF",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 10.sp,
                    fontWeight: FontWeight.bold)),
          ),
          SizedBox(width: 8.w),
          Text(
            "$currency ${removeTrailingZero(numFormatter.format(originalFee))}",
            style: TextStyle(
                color: textColor.withOpacity(0.6),
                decoration: TextDecoration.lineThrough,
                fontSize: 12.sp),
          ),
          SizedBox(width: 8.w),
          AutoSizeText(
            "$currency ${removeTrailingZero(numFormatter.format(finalFee))}",
            style: topicStyle.copyWith(
                color: textColor, fontWeight: FontWeight.bold),
          ),
        ],
      );
    }
    if (originalFee == 0 || originalFee == 0.0) {
      return const SizedBox.shrink();
    }

    return AutoSizeText(
      "$currency ${removeTrailingZero(numFormatter.format(originalFee))}",
      style: topicStyle.copyWith(color: textColor),
    );
  }

  @override
  Widget build(BuildContext context) {
    final discountStr = widget.premiumData?['discount'];
    String displayAmount = "1,000";
    if (widget.premiumData != null &&
        widget.premiumData['piiinksProvided'] != null) {
      displayAmount = removeTrailingZero(
          numFormatter.format(widget.premiumData['piiinksProvided']));
    }
    double discountPercent =
        double.tryParse(discountStr?.toString() ?? "0") ?? 0;

    // 👉 100% DISCOUNT UI (Free Membership Mode)
    if (discountPercent == 100) {
      if (widget.index != 0) {
        return const SizedBox.shrink();
      }
      return Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Column(
          children: [
            // Top Grey Box
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 12.w),
              decoration: BoxDecoration(
                color: const Color(0xFFF4F4F4),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Text(
                "Receive credits for \$$displayAmount's of dollars in savings\nAustralia wide.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700,
                  height: 1.4,
                ),
              ),
            ),
            SizedBox(height: 12.h),
            // Bottom Grey Box
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 12.w),
              decoration: BoxDecoration(
                color: const Color(0xFFF4F4F4),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Text(
                "FREE 12 month membership",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade700,
                ),
              ),
            ),
            SizedBox(height: 20.h),
            // Teal Button
            SizedBox(
              width: double.infinity,
              height: 48.h,
              child: isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                          color: GlobalColors.appColor))
                  : ElevatedButton(
                      onPressed: _handleFreeMemberShip,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF5ABCBF),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5.r)),
                        elevation: 0,
                      ),
                      child: Text(
                        "Continue with FREE membership",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
            )
          ],
        ),
      );
    }

    // 👉 DEFAULT UI (Paid Packages / Low Discount)
    return Column(
      children: [
        if (widget.index == 0) ...[
          // Header Info Box (White card with grey internal boxes)
          Container(
            width: double.infinity,
            margin: EdgeInsets.only(bottom: 20.h),
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding:
                      EdgeInsets.symmetric(vertical: 16.h, horizontal: 12.w),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF4F4F4),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    "Receive credits for \$$displayAmount's of dollars in savings\nAustralia wide.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade700,
                        height: 1.4),
                  ),
                ),
                SizedBox(height: 12.h),
                Container(
                  width: double.infinity,
                  padding:
                      EdgeInsets.symmetric(vertical: 14.h, horizontal: 12.w),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF4F4F4),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    "FREE 12 month membership",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade700),
                  ),
                ),
              ],
            ),
          ),
        ],

        // Package Card
        Container(
          margin: EdgeInsets.only(bottom: 8.h), // Reduced gap between cards
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
                width: 2,
                color: Color(int.parse(
                    '${widget.memPackAll!.data![widget.index!].boxBorderColor}'))),
            color: Color(int.parse(
                '${widget.memPackAll!.data![widget.index!].boxBackgroundColor}')),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  offset: const Offset(0, 4),
                  blurRadius: 12.0)
            ],
            image: widget.memPackAll!.data![widget.index!].boxBackgroundImageUrl
                            ?.isNotEmpty ==
                        true &&
                    widget.memPackAll!.data![widget.index!]
                            .boxBackgroundImageUrl !=
                        "null"
                ? DecorationImage(
                    image: NetworkImage(
                        '${widget.memPackAll!.data![widget.index!].boxBackgroundImageUrl}'),
                    fit: BoxFit.cover)
                : null,
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AutoSizeText(
                  widget.memPackAll!.data![widget.index!].packageName
                      .toString(),
                  overflow: TextOverflow.ellipsis,
                  style: topicStyle.copyWith(
                      fontSize: 18.sp,
                      color: Color(int.parse(widget
                          .memPackAll!.data![widget.index!].boxTextColor!))),
                ),
                const SizedBox(height: 12.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Expanded(
                      flex: 8,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AutoSizeText(
                            S.of(context).loadXTouristSavers.replaceAll(
                                '&L',
                                removeTrailingZero(numFormatter.format(widget
                                    .memPackAll!
                                    .data![widget.index!]
                                    .universalPiiinks))),
                            style: topicStyle.copyWith(
                                color: Color(int.parse(widget.memPackAll!
                                    .data![widget.index!].amountTextColor!)),
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 6.0),
                          _buildPriceDisplay(),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 4,
                      child: isLoading == true
                          ? TopUpWithCircular(
                              buttonBackGroundColor: Color(int.parse(widget
                                  .memPackAll!
                                  .data![widget.index!]
                                  .buttonColor!)),
                              buttonSideColor: Color(int.parse(
                                  '${widget.memPackAll!.data![widget.index!].boxBorderColor}')),
                              circleColor: Color(int.parse(widget.memPackAll!
                                  .data![widget.index!].buttonTextColor!)),
                            )
                          : TopUpButton(
                              buttonBackGroundColor: Color(int.parse(widget
                                  .memPackAll!
                                  .data![widget.index!]
                                  .buttonColor!)),
                              buttonSideColor: Color(int.parse(
                                  '${widget.memPackAll!.data![widget.index!].boxBorderColor}')),
                              buttonTextColor: Color(int.parse(widget
                                  .memPackAll!
                                  .data![widget.index!]
                                  .buttonTextColor!)),
                              text: (widget.memPackAll!.data![widget.index!]
                                          .packageFee! <=
                                      0)
                                  ? S.of(context).continueL
                                  : S.of(context).pay,
                              onPressed: _handleTopUp,
                            ),
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // --- Display Payment Sheet remains the same ---
  Future<void> displayPaymentSheet(String? clientSecret) async {
    try {
      await Stripe.instance.presentPaymentSheet().then((value) async {
        var res = await Stripe.instance.retrievePaymentIntent(clientSecret!);
        if (res.status == PaymentIntentsStatus.Succeeded) {
          var confirm = await DioTopUpStripe().confirmTopUp(
              confirmTopUpReqModel: ConfirmTopUpReqModel(
                  paymentIntent: res.id,
                  paymentIntentClientSecret: res.clientSecret));
          if (!mounted) return;
          if (confirm is ConfirmTopUpResModel) {
            if (confirm.status == 'success') {
              context.pop();
              GlobalSnackBar.showSuccess(
                  context, S.of(context).paymentSuccessful);
            } else {
              GlobalSnackBar.showError(context, S.of(context).paymentFailed);
            }
          } else {
            GlobalSnackBar.showError(context, S.of(context).serverError);
          }
        } else {
          if (!mounted) return;
          GlobalSnackBar.showError(context, S.of(context).stripePaymentFail);
        }
      });
    } on Exception catch (e) {
      if (e is StripeException) {
        var res = await Stripe.instance.retrievePaymentIntent(clientSecret!);
        var confirm = await DioTopUpStripe().confirmTopUp(
            confirmTopUpReqModel: ConfirmTopUpReqModel(
                paymentIntent: res.id,
                paymentIntentClientSecret: res.clientSecret));
        if (!mounted) return;
        if (confirm is ConfirmTopUpResModel) {
          return;
        } else {
          GlobalSnackBar.showError(
              context, S.of(context).thePaymentHasBeenCanceled);
        }
      } else {
        return;
      }
    } catch (e) {
      return;
    }
  }
}
