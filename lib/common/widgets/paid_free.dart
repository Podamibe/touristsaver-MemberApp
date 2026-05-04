import 'dart:convert';

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
import 'package:google_fonts/google_fonts.dart';

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
  String? registrationImageUrl;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      countryId = await Pref().readData(key: saveCountryID);
    });
    super.initState();
    fetchMemberPremiumGetOne();

    fetchRegistrationImage();
  }

  Future<void> fetchRegistrationImage() async {
    try {
      // Assuming your method is inside a class called DioCommon
      var res = await DioCommon().getRegistrationImage();

      if (res != null && res['status'] == "Success") {
        if (!mounted) return;
        setState(() {
          // Extract the URL from the nested "data" object
          registrationImageUrl = res['data']['url'];
        });
      }
    } catch (e) {
      debugPrint("Error fetching registration image: $e");
    }
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
  //the memPackAll comes from   Future<MemberShipPackageResModel?> memPack() async which is in top_up_dio folder

  piiinkLoaded(MemberShipPackageResModel memPackAll, String? countryId) {
    // 👉 1. Find the exact indices of all "premium" packages in the list
    List<int> premiumIndices = [];
    if (memPackAll.data != null) {
      for (int i = 0; i < memPackAll.data!.length; i++) {
        if (memPackAll.data![i].subscriptionType == 'premium') {
          premiumIndices.add(i);
        }
      }
    }
    return ListView.separated(
      separatorBuilder: (context, index) {
        return const SizedBox(height: 20);
      },
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      // 👉 2. Only build items for the premium packages we found
      itemCount: premiumIndices.length,
      itemBuilder: (context, index) {
        // 👉 3. Grab the original index so TopUpWidget still reads the correct data
        int realIndex = premiumIndices[index];
        return TopUpWidget(
          memPackAll: memPackAll,
          index: realIndex,
          countryID: countryId,
          premiumData: premiumData,
          registrationImageUrl: registrationImageUrl, // Pass it here!
        );
      },
    );
  }

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
    const Color primaryBlue = Color(0xFF5871FF);
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
                    text: appBarTitle,
                    textColor: primaryBlue,
                    fontSize: 24.sp,
                    fontWeight: FontWeight.w900,
                  )
                : CustomAppBar(
                    text: appBarTitle,
                    textColor: primaryBlue,
                    fontSize: 24.sp,
                    fontWeight: FontWeight.w900,
                    icon: Icons.person_outlined,
                    onPressed: () => context.push('/log-profile'));
          },
        ),
      ),
      body: BlocProvider(
        lazy: false,
        create: (context) =>
            MemPackAllBloc(RepositoryProvider.of<DioTopUpStripe>(context))
              ..add(LoadMemPackAllEvent()),
        child: Builder(
          builder: (context) {
            return RefreshIndicator(
              color: GlobalColors.appColor,
              onRefresh: () async {
                await fetchRegistrationImage();
                await fetchMemberPremiumGetOne();
                context.read<MemPackAllBloc>().add(LoadMemPackAllEvent());
              },
              child: ScrollConfiguration(
                behavior: const ScrollBehavior(),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  scrollDirection: Axis.vertical,
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
                              : Column(
                                  children: [
                                    piiinkLoaded(memPackAll, countryId),
                                  ],
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

class TopUpWidget extends StatefulWidget {
  const TopUpWidget({
    super.key,
    this.index,
    this.memPackAll,
    this.countryID,
    this.premiumData,
    this.registrationImageUrl,
  });
  final String? countryID;
  final int? index;
  final MemberShipPackageResModel? memPackAll;
  final dynamic premiumData;
  final String? registrationImageUrl;

  @override
  State<TopUpWidget> createState() => _TopUpWidgetState();
}

class _TopUpWidgetState extends State<TopUpWidget> {
  bool isLoading = false;

  Future<void> _handleFreeMemberShip() async {
    bool isLoggedIn = AppVariables.accessToken != null &&
        AppVariables.accessToken!.isNotEmpty;

    if (!isLoggedIn) {
      context.pushNamed('login');
      return;
    }

    setState(() {
      isLoading = true;
    });

    Pref pref = Pref();
    await pref.writeData(key: 'claimedFreeMembership', value: 'true');

    String creditAmount = "0";
    if (widget.premiumData != null &&
        widget.premiumData['piiinksProvided'] != null) {
      creditAmount = widget.premiumData['piiinksProvided'].toString();
    }

    setState(() {
      isLoading = false;
    });

    context.pushNamed(
      'congrats-screen',
      pathParameters: {
        'piiinkCredit': creditAmount,
      },
    );
  }

  Future<void> _handleTopUp() async {
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

      await displayPaymentSheet(res.clientSecret);

      if (!context.mounted) return;

      bool canGoHome = await checkWalletBalance();
      if (!context.mounted) return;

      if (canGoHome) {
        GlobalSnackBar.showSuccess(context, S.of(context).paymentSuccessful);
        context
            .pushReplacementNamed('bottom-bar', pathParameters: {'page': '0'});
      } else {
        context.pushReplacementNamed('paid-free');
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

  @override
  Widget build(BuildContext context) {
    final originalFee = widget.memPackAll!.data![widget.index!].packageFee!;
    String currency = "\$";

    final discountStr = widget.premiumData?['discount'];
    debugPrint("====== CURRENT DISCOUNT PERCENT: $discountStr% ======");

    String displayAmount = "1000";
    if (widget.premiumData != null &&
        widget.premiumData['piiinksProvided'] != null) {
      displayAmount = removeTrailingZero(
          numFormatter.format(widget.premiumData['piiinksProvided']));
    }
    double discountPercent =
        double.tryParse(discountStr?.toString() ?? "0") ?? 0;
    debugPrint("====== CURRENT DISCOUNT PERCENT: $discountPercent% ======");
    double finalFee = originalFee * (1 - (discountPercent / 100));

    String discountedPriceText = "$currency${finalFee.toStringAsFixed(2)}";

    String originalPriceText =
        "$currency${removeTrailingZero(numFormatter.format(originalFee))}";

    // Colors extracted from your mock image
    const Color primaryBlue = Color(0xFF5775FF);
    const Color accentYellow = Color(0xFFF7E015);

    return Column(
      children: [
        // 👉 1. The Collage Image at the top (Only shows on the first package)
        if (widget.index == 0)
          Padding(
            padding: EdgeInsets.only(bottom: 10.h),
            child: widget.registrationImageUrl != null &&
                    widget.registrationImageUrl!.isNotEmpty
                ? Image.network(
                    widget.registrationImageUrl!, // Use the dynamic URL!
                    width: double.infinity,
                    fit: BoxFit.cover,
                    // Show a loading spinner while the image downloads
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return SizedBox(
                        height: 200.h,
                        child: const Center(child: CircularProgressIndicator()),
                      );
                    },
                    // If the URL is broken, show your local asset as a fallback
                    errorBuilder: (context, error, stackTrace) {
                      return Image.asset(
                        "assets/images/newimage.png",
                        width: double.infinity,
                        fit: BoxFit.cover,
                      );
                    },
                  )
                : Image.asset(
                    "assets/images/newimage.png", // Fallback while API is loading
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
          ),

        // 👉 2. The Text and Buttons
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Column(
            children: [
              SizedBox(height: 20.h),
              // Top Blue Text
              Text(
                "Save \$$displayAmount's of dollars\nAustralia wide",
                textAlign: TextAlign.center,
                style: GoogleFonts.nunito(
                  color: primaryBlue,
                  fontSize: 22.sp,
                  fontWeight: FontWeight.w800, // Black/Boldest weight
                  height: 1.3,
                ),
              ),
              SizedBox(height: 15.h),

              // Subtitle Blue Text
              Text(
                discountPercent == 100
                    ? "Free 12 month membership"
                    : (discountPercent > 0 && discountPercent < 100)
                        ? "Premium 12 month's membership"
                        : "12 month's membership only $originalPriceText",
                textAlign: TextAlign.center,
                style: GoogleFonts.nunito(
                  color: primaryBlue,
                  fontSize: 22.sp,
                  fontWeight: FontWeight.w800,
                ),
              ),

              // 👉 FIX 1: Only add this gap AND the Row if there is a partial discount.
              if (discountPercent > 0 && discountPercent < 100) ...[
                SizedBox(height: 20.h),
                // 👉 Pricing Row (Yellow Badges and Strikethrough)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Yellow Discount Box
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 20.w, vertical: 15.h),
                      decoration: BoxDecoration(
                        color: accentYellow,
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      child: Text(
                        "${removeTrailingZero(numFormatter.format(discountPercent))}% OFF",
                        style: GoogleFonts.nunito(
                          color: Colors.black,
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),

                    // Grey Strikethrough Price
                    Text(
                      originalPriceText,
                      style: TextStyle(
                        fontSize: 23.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade500,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                    SizedBox(width: 12.w),

                    // Final Price Yellow Box
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 25.w, vertical: 15.h),
                      decoration: BoxDecoration(
                        color: accentYellow,
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      child: Text(
                        discountedPriceText,
                        style: GoogleFonts.nunito(
                          color: Colors.black,
                          fontSize: 23.sp,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ],

              // 👉 Master gap between text/pricing and the button
              SizedBox(height: 28.h),

              // 👉 PAY Button
              SizedBox(
                width: 320.w,
                // 👉 FIX 2: Removed hardcoded heights. Let the internal padding define the button height dynamically.
                child: ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : (discountPercent == 100
                          ? _handleFreeMemberShip
                          : _handleTopUp),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentYellow,
                    disabledBackgroundColor: accentYellow,
                    // 👉 FIX 3: Added symmetric padding. This guarantees a perfect
                    // professional gap around the text, even if it wraps to two lines!
                    padding:
                        EdgeInsets.symmetric(vertical: 16.h, horizontal: 20.w),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(50.r), // Perfect pill shape
                    ),
                    elevation: 0,
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(color: primaryBlue)
                      // 👉 FIX 4: Used AutoSizeText so the text shrinks slightly instead of breaking awkwardly.
                      : AutoSizeText(
                          discountPercent == 100
                              ? "Continue with FREE membership"
                              : (discountPercent > 0 && discountPercent < 100)
                                  ? "PAY now $discountedPriceText"
                                  : "PAY now $originalPriceText",
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          style: GoogleFonts.nunito(
                            color: Colors.black,
                            fontSize: 22.sp,
                            fontWeight: FontWeight.w800,
                            height:
                                1.2, // Gives breathing room between lines if it wraps
                          ),
                        ),
                ),
              ),
              SizedBox(height: 20.h),
            ],
          ),
        ),
      ],
    );
  }
}
