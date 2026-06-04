import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:go_router/go_router.dart';
import 'package:touristsaver/common/widgets/custom_app_bar.dart';
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

class TopUpScreen extends StatefulWidget {
  static const String routeName = '/top-up';
  const TopUpScreen({super.key});

  @override
  State<TopUpScreen> createState() => _TopUpScreenState();
}

class _TopUpScreenState extends State<TopUpScreen> {
  static const Color _screenBackground = Color(0xFFF8FAFE);
  static const Color _headingColor = Color(0xFF111C44);
  static const Color _bodyColor = Color(0xFF61708A);

  TextEditingController premiumController = TextEditingController();

  // To get saved Country ID
  String? countryId;
  String? currencyPref;

  // For Loading part
  bool isLoading = false;
  bool isAppliedLoading = false;
  double? piiinkCre;

  @override
  void initState() {
    super.initState();
    _loadCountryId();
  }

  Future<void> _loadCountryId() async {
    final String? savedCountryId = await Pref().readData(key: saveCountryID);
    if (!mounted) return;
    setState(() {
      countryId = savedCountryId;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _screenBackground,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: CustomAppBar(
          text: 'Add Discount Credits',
          icon: Icons.arrow_back_ios,
          onPressed: () => context.pop(),
        ),
      ),
      body: ScrollConfiguration(
        behavior: const ScrollBehavior(),
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: BlocProvider(
            lazy: false,
            create: (context) =>
                MemPackAllBloc(RepositoryProvider.of<DioTopUpStripe>(context))
                  ..add(LoadMemPackAllEvent()),
            child: BlocBuilder<MemPackAllBloc, MemPackAllState>(
                builder: (context, state) {
              //loaded state
              if (state is MemPackAllLoadingState) {
                return const CustomAllLoader();
              }
              //loading state
              else if (state is MemPackAllLoadedState) {
                MemberShipPackageResModel memPackAll = state.memPackAll;
                return memPackAll.data!.isEmpty
                    ? Padding(
                        padding: EdgeInsets.symmetric(
                            vertical: 18.h, horizontal: 16.w),
                        child: NoDataFound(
                          titleText: 'No Discount Credit packages available',
                          bodyText:
                              'Please check again soon for available Add Credits packages.',
                          image: "assets/images/oops.png",
                        ),
                      )
                    : Padding(
                        padding: EdgeInsets.fromLTRB(16.w, 18.h, 16.w, 28.h),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'Add Discount Credits',
                              style: TextStyle(
                                color: _headingColor,
                                fontSize: 28.sp,
                                fontWeight: FontWeight.w900,
                                height: 1.12,
                                fontFamily: 'Sans',
                              ),
                            ),
                            SizedBox(height: 8.h),
                            Text(
                              'Add TouristSaver Discount Credits to unlock more member savings at participating merchants.',
                              style: TextStyle(
                                color: _bodyColor,
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w600,
                                height: 1.42,
                                fontFamily: 'Sans',
                              ),
                            ),
                            SizedBox(height: 20.h),
                            piiinkLoaded(memPackAll, countryId),
                          ],
                        ),
                      );
              } else if (state is MemPackAllErrorState) {
                return const Error1();
              } else {
                return const SizedBox();
              }
            }),
          ),
        ),
      ),
    );
  }

  //Piiink loaded quantity
  piiinkLoaded(MemberShipPackageResModel memPackAll, String? countryId) {
    return ListView.separated(
      separatorBuilder: (context, index) {
        return SizedBox(height: 14.h);
      },
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: memPackAll.data!.length,
      itemBuilder: (context, index) {
        return TopUpWidget(
          memPackAll: memPackAll,
          index: index,
          countryID: countryId,
        );
      },
    );
  }

  //Apply Premium Button
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
      //Start of Checking whether the premium code is valid or not
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
            // print('Error eeta');
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

  //giveaway popup
  giveAwayPopUp() {
    return showGeneralDialog(
      barrierLabel: 'Label',
      barrierDismissible: false, //to dismiss the container once opened
      barrierColor: Colors.black.withValues(
          alpha:
              0.5), //to change the background color once the container is opened
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
              context.pop(); //To close the pop up
              context.pop(); //To close the top up screen
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

  //invalid code popup
  invalidCode() {
    return showGeneralDialog(
      barrierLabel: 'Label',
      barrierDismissible: false, //to dismiss the container once opened
      barrierColor: Colors.black.withValues(
          alpha:
              0.5), //to change the background color once the container is opened
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

  //Apply Button
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
}

// For desiging the banner that shows the top up amount
class SkyDesign extends CustomClipper<Path> {
  @override
  getClip(Size size) {
    Path path = Path();
    path.moveTo(0.0, 0.0);
    path.lineTo(0.0, size.height - 28);
    path.lineTo((size.width / 5) - 5, size.height - 20);
    path.lineTo(size.width / 2, size.height);
    path.lineTo((size.width / 2) + 20, size.height - 15);
    path.lineTo(size.width, size.height - 25);
    path.lineTo(size.width, 0.0);
    return path;
  }

  @override
  bool shouldReclip(CustomClipper oldClipper) {
    return true;
  }
}

class TopUpWidget extends StatefulWidget {
  const TopUpWidget(
      {super.key,
      this.index,
      this.memPackAll,
      this.countryID,
      this.premiumData});
  final String? countryID;
  final int? index;
  final MemberShipPackageResModel? memPackAll;
  final dynamic premiumData;

  @override
  State<TopUpWidget> createState() => _TopUpWidgetState();
}

class _TopUpWidgetState extends State<TopUpWidget> {
  static const Color _primaryBlue = Color(0xFF0009FE);
  static const Color _ctaCyan = Color(0xFF18C6FF);
  static const Color _headingColor = Color(0xFF111C44);
  static const Color _bodyColor = Color(0xFF61708A);
  static const Color _borderColor = Color(0xFFE2E8F3);

  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    final Datum? package = _package;
    if (package == null) {
      return const SizedBox.shrink();
    }

    return Container(
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 46.w,
                height: 46.w,
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF7FF),
                  borderRadius: BorderRadius.circular(14.r),
                ),
                child: Icon(
                  Icons.savings_outlined,
                  color: _primaryBlue,
                  size: 25.sp,
                ),
              ),
              SizedBox(width: 13.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _packageName(package),
                      style: TextStyle(
                        color: _headingColor,
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w900,
                        fontFamily: 'Sans',
                      ),
                    ),
                    SizedBox(height: 5.h),
                    Text(
                      '${_creditsText(package)} Discount Credits',
                      style: TextStyle(
                        color: _bodyColor,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Sans',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 18.h),
          Text(
            _packagePriceWithGst(package),
            style: TextStyle(
              color: _headingColor,
              fontSize: 26.sp,
              fontWeight: FontWeight.w900,
              fontFamily: 'Sans',
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            'Add credits to your TouristSaver wallet and keep saving with participating merchants.',
            style: TextStyle(
              color: _bodyColor,
              fontSize: 13.5.sp,
              fontWeight: FontWeight.w600,
              height: 1.38,
              fontFamily: 'Sans',
            ),
          ),
          SizedBox(height: 18.h),
          isLoading
              ? const Center(child: CustomAllLoader())
              : _GradientButton(
                  label: 'Pay now',
                  onTap: () => _startTopUp(package),
                ),
        ],
      ),
    );
  }

  Datum? get _package {
    final data = widget.memPackAll?.data;
    final index = widget.index;
    if (data == null || index == null || index < 0 || index >= data.length) {
      return null;
    }
    return data[index];
  }

  String _packageName(Datum package) {
    final String? name = package.packageName?.trim();
    if (name == null || name.isEmpty) {
      return 'Premium Package';
    }
    return name.replaceAll(RegExp('top-up', caseSensitive: false), 'Credits');
  }

  String _creditsText(Datum package) {
    return removeTrailingZero(
        numFormatter.format(package.universalPiiinks ?? 0));
  }

  Future<void> _startTopUp(Datum package) async {
    if (isLoading) return;

    final int? packageId = package.id;
    final String? countryId = widget.countryID ?? package.countryId?.toString();
    if (packageId == null || countryId == null || countryId.isEmpty) {
      GlobalSnackBar.showError(
          context, 'This Add Credits package is not available right now.');
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final double originalFee = package.packageFee ?? 0;
      final Map? premiumData =
          widget.premiumData is Map ? widget.premiumData as Map : null;
      final discountStr = premiumData == null ? null : premiumData['discount'];
      final isDiscountedPackage = discountStr != null &&
          discountStr.toString() != "0" &&
          originalFee > 0;
      final String? codeToSend = isDiscountedPackage
          ? premiumData!['memberPremiumCode']?.toString()
          : null;

      final res = await DioTopUpStripe().topUpStripe(
        topUpStripeReqModel: TopUpStripeReqModel(
          paymentGateway: 'stripe',
          memberPremiumCode: codeToSend,
          membershipPackageId: packageId.toString(),
          countryId: countryId,
        ),
      );

      if (!mounted) return;

      if (res is! TopUpStripeResModel) {
        GlobalSnackBar.showError(context, S.of(context).serverError);
        return;
      }

      if (res.clientSecret == null || res.clientSecret!.isEmpty) {
        final bool hasBalance = await checkWalletBalance();
        if (!context.mounted) return;
        if (hasBalance) {
          GlobalSnackBar.showSuccess(context, S.of(context).paymentSuccessful);
          if (context.canPop()) {
            context.pop();
          } else {
            context.pushReplacementNamed('bottom-bar',
                pathParameters: {'page': '0'});
          }
        }
        return;
      }

      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: res.clientSecret,
          merchantDisplayName: 'TouristSaver',
          style: ThemeMode.light,
        ),
      );

      if (!mounted) return;
      setState(() {
        isLoading = false;
      });

      await displayPaymentSheet(res.clientSecret);
    } catch (e) {
      if (!mounted) return;
      GlobalSnackBar.showError(context, S.of(context).somethingWentWrong);
    } finally {
      if (mounted && isLoading) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> displayPaymentSheet(String? clientSecret) async {
    try {
      //this shows the stripe pay form
      await Stripe.instance.presentPaymentSheet().then((value) async {
        //Retreiving the response after stripe sheet pay button is clicked
        var res = await Stripe.instance.retrievePaymentIntent(clientSecret!);
        if (res.status == PaymentIntentsStatus.Succeeded) {
          // Confirming the stripe payment in backend
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
        // Confirming the stripe payment in backend
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

  String _packagePriceWithGst(Datum package) {
    final priceText =
        '${package.packageCurrencySymbol ?? ''}${removeTrailingZero(numFormatter.format(package.packageFee ?? 0))}';
    return priceText.toLowerCase().contains('gst')
        ? priceText
        : '$priceText inc GST';
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
                _TopUpWidgetState._primaryBlue,
                _TopUpWidgetState._ctaCyan,
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(18.r),
            boxShadow: [
              BoxShadow(
                color: _TopUpWidgetState._primaryBlue.withValues(alpha: 0.20),
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
