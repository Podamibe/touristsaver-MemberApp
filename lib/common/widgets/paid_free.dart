import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:go_router/go_router.dart';
import 'package:touristsaver/common/app_variables.dart';
import 'package:touristsaver/common/services/dio_common.dart';
import 'package:touristsaver/common/widgets/custom_loader.dart';
import 'package:touristsaver/common/widgets/custom_snackbar.dart';
import 'package:touristsaver/common/widgets/error.dart';
import 'package:touristsaver/common/widgets/not_available.dart';
import 'package:touristsaver/constants/decimal_remove.dart';
import 'package:touristsaver/constants/number_formatter.dart';
import 'package:touristsaver/constants/pref.dart';
import 'package:touristsaver/constants/pref_key.dart';
import 'package:touristsaver/constants/style.dart';
import 'package:touristsaver/features/profile/widget/info_popup.dart';
import 'package:touristsaver/features/top_up/bloc/mem_pack_bloc.dart';
import 'package:touristsaver/features/top_up/bloc/mem_pack_event.dart';
import 'package:touristsaver/features/top_up/bloc/mem_pack_state.dart';
import 'package:touristsaver/features/top_up/services/top_up_dio.dart';
import 'package:touristsaver/models/request/confirm_topup_req.dart';
import 'package:touristsaver/models/request/premium_topup_req.dart';
import 'package:touristsaver/models/request/top_up_stripe_req.dart';
import 'package:touristsaver/models/response/confirm_topup_res.dart';
import 'package:touristsaver/models/response/member_package_res.dart';
import 'package:touristsaver/models/response/pre_topup_free_res.dart';
import 'package:touristsaver/models/response/pre_topup_paid_res.dart';
import 'package:touristsaver/models/response/premium_validity_res.dart';
import 'package:touristsaver/models/response/top_up_stripe_res.dart';
import 'package:touristsaver/generated/l10n.dart';
import 'package:touristsaver/splash_screen.dart';
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

  // For Loading part
  bool isAppliedLoading = false;
  double? piiinkCre;

  // Premium data mapping
  dynamic premiumData;
  String? registrationImageUrl;
  bool isGlobalLoading = false; // Add this at the top with your other variables
  late MemPackAllBloc _memPackAllBloc;
  bool _memPackBlocReady = false;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      countryId = await Pref().readData(key: saveCountryID);
    });
    super.initState();
    fetchMemberPremiumGetOne();

    fetchRegistrationImage();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_memPackBlocReady) return;
    _memPackAllBloc =
        MemPackAllBloc(RepositoryProvider.of<DioTopUpStripe>(context))
          ..add(LoadMemPackAllEvent());
    _memPackBlocReady = true;
  }

  @override
  void dispose() {
    _memPackAllBloc.close();
    premiumController.dispose();
    super.dispose();
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
          showHeader: index == 0,
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
    String appBarTitle = "Premium Membership";
    const Color primaryBlue = Color(0xFF0009FE);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: const Color(0xFFF8FAFE),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8FAFE),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.person_outline,
            color: primaryBlue,
            size: 22.sp,
          ),
          onPressed: () => context.push('/log-profile'),
        ),
        title: Text(
          appBarTitle,
          style: GoogleFonts.nunito(
            color: const Color(0xFF111C44),
            fontSize: 22.sp,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: Stack(children: [
        BlocProvider.value(
          value: _memPackAllBloc,
          child: Builder(
            builder: (context) {
              return ScrollConfiguration(
                behavior: const ScrollBehavior(),
                child: SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  scrollDirection: Axis.vertical,
                  child: Container(
                    padding: EdgeInsets.only(bottom: 28.h),
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
              );
            },
          ),
        ),
        if (isGlobalLoading)
          Positioned.fill(
            child: GestureDetector(
              onTap:
                  () {}, // This empty callback blocks taps from reaching the buttons below
              child: Container(
                color: Colors.black.withValues(alpha: 0.5),
                child: const Center(
                  child: CircularProgressIndicator(
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
      ]),
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
    this.showHeader = false,
  });
  final String? countryID;
  final int? index;
  final MemberShipPackageResModel? memPackAll;
  final dynamic premiumData;
  final String? registrationImageUrl;
  final bool showHeader;

  @override
  State<TopUpWidget> createState() => _TopUpWidgetState();
}

class _TopUpWidgetState extends State<TopUpWidget> {
  static const Color _primaryBlue = Color(0xFF0009FE);
  static const Color _ctaCyan = Color(0xFF18C6FF);
  static const Color _screenBackground = Color(0xFFF8FAFE);
  static const Color _headingColor = Color(0xFF111C44);
  static const Color _bodyColor = Color(0xFF61708A);
  static const Color _borderColor = Color(0xFFE2E8F3);

  bool isLoading = false;

  Future<void> _showPaymentConfirmation(String paymentPriceText) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => _PaymentConfirmationScreen(
          amountText: paymentPriceText,
          onContinue: (paymentContext) => _handleTopUp(
            paymentContext: paymentContext,
          ),
        ),
      ),
    );
  }

  void _dismissPaymentConfirmation(BuildContext? paymentContext) {
    if (paymentContext == null || !paymentContext.mounted) return;
    final navigator = Navigator.of(paymentContext);
    if (navigator.canPop()) {
      navigator.pop();
    }
  }

  void _navigateToActivationSuccess({String creditAmount = '0'}) {
    context.pushReplacementNamed(
      'congrats-screen',
      pathParameters: {
        'piiinkCredit': creditAmount,
      },
    );
  }

  String _selectedPackageCreditAmount() {
    final credits =
        widget.memPackAll?.data?[widget.index ?? 0].universalPiiinks;
    return credits?.toString() ?? '0';
  }

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

    _navigateToActivationSuccess(creditAmount: creditAmount);
  }

  Future<void> _handleTopUp({BuildContext? paymentContext}) async {
    FocusManager.instance.primaryFocus?.unfocus();
    await Future.delayed(const Duration(milliseconds: 300));

    bool isLoggedIn = AppVariables.accessToken != null &&
        AppVariables.accessToken!.isNotEmpty;

    if (!isLoggedIn) {
      _dismissPaymentConfirmation(paymentContext);
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
          _dismissPaymentConfirmation(paymentContext);
          _navigateToActivationSuccess(
            creditAmount: _selectedPackageCreditAmount(),
          );
        } else {
          _dismissPaymentConfirmation(paymentContext);
          _navigateToActivationSuccess(
            creditAmount: _selectedPackageCreditAmount(),
          );
        }
        return;
      }

      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: res.clientSecret,
          merchantDisplayName: 'Prospects',
          style: ThemeMode.light,
          appearance: const PaymentSheetAppearance(
            colors: PaymentSheetAppearanceColors(
              primary: Colors.blue,
            ),
          ),
        ),
      );

      // Turn off loading spinner before showing the sheet
      setState(() {
        isLoading = false;
      });

      // WAIT for the payment to completely finish
      bool paymentSuccess = await displayPaymentSheet(res.clientSecret);

      if (!mounted) return;

      if (paymentSuccess) {
        // 👉 1. Show the global circular loader immediately
        final parentState =
            context.findAncestorStateOfType<_PaidFreeScreenState>();
        parentState?.setState(() {
          parentState.isGlobalLoading = true;
        });

        // 👉 2. CHANGE: Use 'await' so the loader stays until balance is updated
        await checkWalletBalance();

        if (!mounted) return;

        // 👉 3. Navigate Home - the loader will disappear as the screen is destroyed
        _dismissPaymentConfirmation(paymentContext);
        _navigateToActivationSuccess(
          creditAmount: _selectedPackageCreditAmount(),
        );
      } else {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<bool> displayPaymentSheet(String? clientSecret) async {
    try {
      await Stripe.instance.presentPaymentSheet();

      // Retrieve status from Stripe Native SDK
      var res = await Stripe.instance.retrievePaymentIntent(clientSecret!);

      if (res.status == PaymentIntentsStatus.Succeeded) {
        try {
          var confirm = await DioTopUpStripe().confirmTopUp(
              confirmTopUpReqModel: ConfirmTopUpReqModel(
                  paymentIntent: res.id,
                  paymentIntentClientSecret: res.clientSecret));

          if (confirm is ConfirmTopUpResModel && confirm.status == 'success') {
            return true;
          }
        } catch (e) {
          // 👉 FIX: Catch ANY error (208 Already Reported, 500, etc.)
          // Because Stripe's native UI said it succeeded, we ignore the backend
          // conflict and check if the wallet got the money from the webhook!
          debugPrint(
              "⚠️ Backend confirm conflict, checking wallet directly...");
          return await checkWalletBalance();
        }
        return await checkWalletBalance();
      }
      return false;
    } on StripeException {
      if (!mounted) return false;
      GlobalSnackBar.showError(
          context, S.of(context).thePaymentHasBeenCanceled);
      return false;
    } catch (e) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final package = widget.memPackAll!.data![widget.index!];
    final originalFee = package.packageFee ?? 0;
    final currency = (package.packageCurrencySymbol?.trim().isNotEmpty ?? false)
        ? package.packageCurrencySymbol!.trim()
        : AppVariables.currency ?? "\$";
    final currencyName = package.packageCurrencyName?.trim() ?? '';

    final discountStr = widget.premiumData?['discount'];
    debugPrint("====== CURRENT DISCOUNT PERCENT: $discountStr% ======");

    double discountPercent =
        double.tryParse(discountStr?.toString() ?? "0") ?? 0;
    discountPercent = discountPercent.clamp(0, 100);
    debugPrint("====== CURRENT DISCOUNT PERCENT: $discountPercent% ======");
    final double discountAmount = originalFee * (discountPercent / 100);
    final double finalFee =
        (originalFee - discountAmount).clamp(0, double.infinity);

    final originalPriceText =
        _formatMembershipAmount(originalFee, currency, currencyName);
    final discountAmountText =
        "-${_formatMembershipAmount(discountAmount, currency, currencyName)}";
    final amountPayableText =
        _formatMembershipAmount(finalFee, currency, currencyName);

    final bool isFreeMembership = discountPercent == 100;
    final bool hasPartialDiscount =
        discountPercent > 0 && discountPercent < 100;
    final String buttonLabel = "Continue";
    final bool showValueSections = widget.showHeader || isFreeMembership;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (showValueSections) ...[
            SizedBox(height: 10.h),
            _heroImage(),
            SizedBox(height: 14.h),
            _watchIntroLink(),
            SizedBox(height: 18.h),
            _valueIntroCard(),
            SizedBox(height: 18.h),
            _exampleSavingsSection(),
            SizedBox(height: 18.h),
            _nearbySavingsCard(),
            SizedBox(height: 18.h),
          ] else
            SizedBox(height: 18.h),
          _membershipCard(
            originalPriceText: originalPriceText,
            discountAmountText: discountAmountText,
            amountPayableText: amountPayableText,
            discountPercent: discountPercent,
            isFreeMembership: isFreeMembership,
            hasPartialDiscount: hasPartialDiscount,
            buttonLabel: buttonLabel,
            onPressed: isFreeMembership
                ? _handleFreeMemberShip
                : () => _showPaymentConfirmation(amountPayableText),
          ),
        ],
      ),
    );
  }

  String _formatMembershipAmount(
    double amount,
    String currency,
    String currencyName,
  ) {
    final amountText = "$currency${amount.toStringAsFixed(2)}";
    return currencyName.isEmpty ? amountText : "$amountText $currencyName";
  }

  Widget _heroImage() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24.r),
      clipBehavior: Clip.antiAlias,
      child: AspectRatio(
        aspectRatio: 4 / 3,
        child: Container(
          color: Colors.white,
          child: widget.registrationImageUrl != null &&
                  widget.registrationImageUrl!.isNotEmpty
              ? Image.network(
                  widget.registrationImageUrl!,
                  width: double.infinity,
                  fit: BoxFit.contain,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return const Center(
                      child: CircularProgressIndicator(color: _primaryBlue),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return _fallbackHeroImage();
                  },
                )
              : _fallbackHeroImage(),
        ),
      ),
    );
  }

  Widget _fallbackHeroImage() {
    return Image.asset(
      "assets/images/newimage.png",
      width: double.infinity,
      fit: BoxFit.contain,
    );
  }

  Widget _watchIntroLink() {
    return Align(
      alignment: Alignment.center,
      child: TextButton.icon(
        onPressed: () => context.pushNamed(
          'video-screen',
          queryParameters: {'returnTo': 'paid-free'},
        ),
        style: TextButton.styleFrom(
          foregroundColor: _primaryBlue,
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
        ),
        icon: Icon(Icons.play_circle_outline, size: 20.sp),
        label: Text(
          "Watch 1-minute intro",
          style: GoogleFonts.nunito(
            color: _primaryBlue,
            fontSize: 14.sp,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }

  Widget _valueIntroCard() {
    return _SoftCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Save on thousands of experiences across Australia",
            style: GoogleFonts.nunito(
              color: _headingColor,
              fontSize: 23.sp,
              fontWeight: FontWeight.w900,
              height: 1.18,
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            "Access over 4,500 member offers across theme parks, dining, attractions, travel, shopping and everyday lifestyle experiences.",
            style: GoogleFonts.nunito(
              color: _bodyColor,
              fontSize: 14.5.sp,
              fontWeight: FontWeight.w600,
              height: 1.45,
            ),
          ),
          SizedBox(height: 12.h),
          Container(
            padding: EdgeInsets.all(14.r),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF7FF),
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Text(
              "Many families and couples can recover the cost of membership from just one holiday, weekend getaway or local day out.",
              style: GoogleFonts.nunito(
                color: _headingColor,
                fontSize: 13.5.sp,
                fontWeight: FontWeight.w700,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _exampleSavingsSection() {
    return _SoftCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Example member savings",
            style: GoogleFonts.nunito(
              color: _headingColor,
              fontSize: 18.sp,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 14.h),
          _savingExample(
            icon: Icons.confirmation_number_outlined,
            title: "Theme park pass",
            body: "Save around \$28 per person",
          ),
          SizedBox(height: 10.h),
          _savingExample(
            icon: Icons.restaurant_outlined,
            title: "Dinner or cruise experience",
            body: "Save around \$20 or more",
          ),
          SizedBox(height: 10.h),
          _savingExample(
            icon: Icons.explore_outlined,
            title: "Local dining & attractions",
            body: "Everyday savings during your trip and throughout the year",
          ),
        ],
      ),
    );
  }

  Widget _savingExample({
    required IconData icon,
    required String title,
    required String body,
  }) {
    return Container(
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: _screenBackground,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: _borderColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38.w,
            height: 38.w,
            decoration: BoxDecoration(
              color: const Color(0xFFEFF7FF),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(icon, color: _primaryBlue, size: 21.sp),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.nunito(
                    color: _headingColor,
                    fontSize: 14.5.sp,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 3.h),
                Text(
                  body,
                  style: GoogleFonts.nunito(
                    color: _bodyColor,
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _nearbySavingsCard() {
    return _SoftCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42.w,
            height: 42.w,
            decoration: BoxDecoration(
              color: const Color(0xFFEFF7FF),
              borderRadius: BorderRadius.circular(14.r),
            ),
            child: Icon(
              Icons.location_on_outlined,
              color: _primaryBlue,
              size: 24.sp,
            ),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Find nearby savings as you travel",
                  style: GoogleFonts.nunito(
                    color: _headingColor,
                    fontSize: 17.sp,
                    fontWeight: FontWeight.w900,
                    height: 1.2,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  "TouristSaver helps connect you with participating merchants and local offers near you using location-based discovery.",
                  style: GoogleFonts.nunito(
                    color: _bodyColor,
                    fontSize: 13.5.sp,
                    fontWeight: FontWeight.w600,
                    height: 1.4,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  "No more relying on printed vouchers or outdated leaflets. Offers can be viewed in the app as you explore.",
                  style: GoogleFonts.nunito(
                    color: _bodyColor,
                    fontSize: 13.5.sp,
                    fontWeight: FontWeight.w600,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _membershipCard({
    required String originalPriceText,
    required String discountAmountText,
    required String amountPayableText,
    required double discountPercent,
    required bool isFreeMembership,
    required bool hasPartialDiscount,
    required String buttonLabel,
    required VoidCallback onPressed,
  }) {
    return _SoftCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Premium Membership",
            style: GoogleFonts.nunito(
              color: _headingColor,
              fontSize: 20.sp,
              fontWeight: FontWeight.w900,
              height: 1.2,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            "Enjoy member savings for 12 months across Australia.",
            style: GoogleFonts.nunito(
              color: _bodyColor,
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              height: 1.4,
            ),
          ),
          SizedBox(height: 18.h),
          _membershipPriceSummary(
            originalPriceText: originalPriceText,
            discountAmountText: discountAmountText,
            amountPayableText: amountPayableText,
            discountPercent: discountPercent,
            showDiscount: hasPartialDiscount || isFreeMembership,
          ),
          SizedBox(height: 16.h),
          _benefitSummary(),
          SizedBox(height: 16.h),
          _valueGuaranteePanel(),
          SizedBox(height: 18.h),
          _GradientCheckoutButton(
            label: buttonLabel,
            isLoading: isLoading,
            onPressed: onPressed,
          ),
        ],
      ),
    );
  }

  Widget _membershipPriceSummary({
    required String originalPriceText,
    required String discountAmountText,
    required String amountPayableText,
    required double discountPercent,
    required bool showDiscount,
  }) {
    return Container(
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: _screenBackground,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: _borderColor),
      ),
      child: Column(
        children: [
          _priceRow(
            label: "Membership Price",
            value: originalPriceText,
          ),
          if (showDiscount) ...[
            SizedBox(height: 8.h),
            _priceRow(
              label:
                  "Premium Code Discount (${removeTrailingZero(numFormatter.format(discountPercent))}% off)",
              value: discountAmountText,
              valueColor: _primaryBlue,
            ),
          ],
          SizedBox(height: 12.h),
          Divider(height: 1, color: _borderColor),
          SizedBox(height: 12.h),
          _priceRow(
            label: "Amount Payable",
            value: amountPayableText,
            valueColor: _headingColor,
            isLarge: true,
          ),
        ],
      ),
    );
  }

  Widget _benefitSummary() {
    return Column(
      children: [
        _benefitLine(
          Icons.savings_outlined,
          "Over \$10,000 in potential savings",
        ),
        SizedBox(height: 10.h),
        _benefitLine(
          Icons.verified_outlined,
          "Money Back Guarantee",
        ),
        SizedBox(height: 10.h),
        _benefitLine(
          Icons.public_outlined,
          "Access to participating merchants across Australia",
        ),
      ],
    );
  }

  Widget _benefitLine(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: _primaryBlue, size: 20.sp),
        SizedBox(width: 10.w),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.nunito(
              color: _headingColor,
              fontSize: 13.5.sp,
              fontWeight: FontWeight.w800,
              height: 1.3,
            ),
          ),
        ),
      ],
    );
  }

  Widget _priceRow({
    required String label,
    required String value,
    Color? valueColor,
    bool strikeThrough = false,
    bool isLarge = false,
  }) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.nunito(
              color: _bodyColor,
              fontSize: 13.5.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        SizedBox(width: 12.w),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: GoogleFonts.nunito(
              color: valueColor ?? _bodyColor,
              fontSize: isLarge ? 22.sp : 14.sp,
              fontWeight: isLarge ? FontWeight.w900 : FontWeight.w800,
              decoration: strikeThrough
                  ? TextDecoration.lineThrough
                  : TextDecoration.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _valueGuaranteePanel() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F8FF),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFD6EAFB)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32.w,
            height: 32.w,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.72),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(
              Icons.verified_outlined,
              color: _primaryBlue,
              size: 19.sp,
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "TouristSaver Value Guarantee",
                  style: GoogleFonts.nunito(
                    color: _headingColor,
                    fontSize: 14.5.sp,
                    fontWeight: FontWeight.w900,
                    height: 1.2,
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  "We are so confident that your TouristSaver membership will deliver real value throughout your membership journey.",
                  style: GoogleFonts.nunito(
                    color: _bodyColor,
                    fontSize: 12.5.sp,
                    fontWeight: FontWeight.w600,
                    height: 1.35,
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  "Your membership should pay for itself. If your eligible verified savings over 12 months don’t exceed your membership fee, we’ll refund the difference.*",
                  style: GoogleFonts.nunito(
                    color: _bodyColor,
                    fontSize: 12.5.sp,
                    fontWeight: FontWeight.w600,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SoftCard extends StatelessWidget {
  const _SoftCard({
    required this.child,
    this.padding,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding ?? EdgeInsets.all(18.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: _TopUpWidgetState._borderColor),
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

class _GradientCheckoutButton extends StatelessWidget {
  const _GradientCheckoutButton({
    required this.label,
    required this.isLoading,
    required this.onPressed,
  });

  final String label;
  final bool isLoading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 54.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18.r),
        gradient: const LinearGradient(
          colors: [
            _TopUpWidgetState._primaryBlue,
            _TopUpWidgetState._ctaCyan,
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        boxShadow: [
          BoxShadow(
            color: _TopUpWidgetState._primaryBlue.withValues(alpha: 0.22),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18.r),
          onTap: isLoading ? null : onPressed,
          child: Center(
            child: isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 3,
                    ),
                  )
                : Text(
                    label,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.nunito(
                      color: Colors.white,
                      fontSize: 17.sp,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

class _PaymentConfirmationScreen extends StatefulWidget {
  const _PaymentConfirmationScreen({
    required this.amountText,
    required this.onContinue,
  });

  final String amountText;
  final Future<void> Function(BuildContext context) onContinue;

  @override
  State<_PaymentConfirmationScreen> createState() =>
      _PaymentConfirmationScreenState();
}

class _PaymentConfirmationScreenState
    extends State<_PaymentConfirmationScreen> {
  bool _isProcessing = false;

  Future<void> _handleContinue() async {
    if (_isProcessing) return;
    setState(() {
      _isProcessing = true;
    });

    try {
      await widget.onContinue(context);
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_isProcessing,
      child: Scaffold(
        backgroundColor: _TopUpWidgetState._screenBackground,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 24.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: _ConfirmationIconButton(
                    icon: Icons.arrow_back_ios_new_rounded,
                    onTap: _isProcessing
                        ? () {}
                        : () => Navigator.of(context).pop(false),
                  ),
                ),
                SizedBox(height: 10.h),
                Text(
                  "Activate your membership",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.nunito(
                    color: _TopUpWidgetState._headingColor,
                    fontSize: 26.sp,
                    fontWeight: FontWeight.w900,
                    height: 1.15,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  "Premium 12-month TouristSaver membership",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.nunito(
                    color: _TopUpWidgetState._bodyColor,
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                    height: 1.35,
                  ),
                ),
                SizedBox(height: 16.h),
                _SoftCard(
                  padding: EdgeInsets.all(14.r),
                  child: Column(
                    children: [
                      _ConfirmationBenefit(
                        icon: Icons.local_offer_outlined,
                        text: "Access 4,500+ member offers",
                      ),
                      _ConfirmationBenefit(
                        icon: Icons.public_outlined,
                        text: "Savings across Australia",
                      ),
                      _ConfirmationBenefit(
                        icon: Icons.restaurant_outlined,
                        text:
                            "Dining, attractions, travel & lifestyle experiences",
                      ),
                      _ConfirmationBenefit(
                        icon: Icons.location_on_outlined,
                        text: "Nearby offers using location-based discovery",
                      ),
                      _ConfirmationBenefit(
                        icon: Icons.calendar_month_outlined,
                        text: "Valid for 12 months",
                        showDivider: false,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 12.h),
                _SoftCard(
                  padding: EdgeInsets.all(15.r),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Payment summary",
                        style: GoogleFonts.nunito(
                          color: _TopUpWidgetState._headingColor,
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      SizedBox(height: 10.h),
                      _SummaryRow(
                        label: "Membership",
                        value: "Premium 12-month",
                      ),
                      SizedBox(height: 8.h),
                      Divider(
                        color: _TopUpWidgetState._borderColor,
                        height: 1,
                      ),
                      SizedBox(height: 8.h),
                      _SummaryRow(
                        label: "Today",
                        value: widget.amountText,
                        isTotal: true,
                      ),
                      SizedBox(height: 12.h),
                      Container(
                        padding: EdgeInsets.all(10.r),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF7FF),
                          borderRadius: BorderRadius.circular(14.r),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.lock_outline,
                              color: _TopUpWidgetState._primaryBlue,
                              size: 20.sp,
                            ),
                            SizedBox(width: 10.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Secure payment protected by Stripe",
                                    style: GoogleFonts.nunito(
                                      color: _TopUpWidgetState._headingColor,
                                      fontSize: 13.5.sp,
                                      fontWeight: FontWeight.w800,
                                      height: 1.25,
                                    ),
                                  ),
                                  SizedBox(height: 3.h),
                                  Text(
                                    "Your membership is backed by the TouristSaver Value Guarantee*",
                                    style: GoogleFonts.nunito(
                                      color: _TopUpWidgetState._bodyColor,
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w600,
                                      height: 1.3,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16.h),
                _GradientCheckoutButton(
                  label: "Continue to secure payment",
                  isLoading: _isProcessing,
                  onPressed: _handleContinue,
                ),
                SizedBox(height: 12.h),
                TextButton(
                  onPressed:
                      _isProcessing ? null : () => Navigator.of(context).pop(),
                  style: TextButton.styleFrom(
                    foregroundColor: _TopUpWidgetState._primaryBlue,
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                  ),
                  child: Text(
                    "Back to membership summary",
                    style: GoogleFonts.nunito(
                      color: _TopUpWidgetState._primaryBlue,
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ConfirmationIconButton extends StatelessWidget {
  const _ConfirmationIconButton({
    required this.icon,
    required this.onTap,
  });

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16.r),
      child: InkWell(
        borderRadius: BorderRadius.circular(16.r),
        onTap: onTap,
        child: Container(
          width: 44.w,
          height: 44.w,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: _TopUpWidgetState._borderColor),
          ),
          child: Icon(
            icon,
            color: _TopUpWidgetState._primaryBlue,
            size: 18.sp,
          ),
        ),
      ),
    );
  }
}

class _ConfirmationBenefit extends StatelessWidget {
  const _ConfirmationBenefit({
    required this.icon,
    required this.text,
    this.showDivider = true,
  });

  final IconData icon;
  final String text;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Container(
              width: 38.w,
              height: 38.w,
              decoration: BoxDecoration(
                color: const Color(0xFFEFF7FF),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(
                icon,
                color: _TopUpWidgetState._primaryBlue,
                size: 21.sp,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                text,
                style: GoogleFonts.nunito(
                  color: _TopUpWidgetState._headingColor,
                  fontSize: 14.5.sp,
                  fontWeight: FontWeight.w800,
                  height: 1.3,
                ),
              ),
            ),
          ],
        ),
        if (showDivider) ...[
          SizedBox(height: 8.h),
          Divider(
            color: _TopUpWidgetState._borderColor,
            height: 1,
          ),
          SizedBox(height: 8.h),
        ],
      ],
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.isTotal = false,
  });

  final String label;
  final String value;
  final bool isTotal;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.nunito(
              color: _TopUpWidgetState._bodyColor,
              fontSize: 14.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Text(
          value,
          style: GoogleFonts.nunito(
            color: isTotal
                ? _TopUpWidgetState._headingColor
                : _TopUpWidgetState._bodyColor,
            fontSize: isTotal ? 22.sp : 14.sp,
            fontWeight: isTotal ? FontWeight.w900 : FontWeight.w800,
          ),
        ),
      ],
    );
  }
}
