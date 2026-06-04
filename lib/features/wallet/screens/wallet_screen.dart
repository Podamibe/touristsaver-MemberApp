import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:touristsaver/common/widgets/custom_app_bar.dart';
import 'package:touristsaver/common/widgets/custom_button.dart';
import 'package:touristsaver/common/widgets/reg_log_slider.dart';
import 'package:touristsaver/constants/global_colors.dart';
import 'package:touristsaver/constants/style.dart';
import 'package:touristsaver/features/connectivity/cubit/internet_cubit.dart';
import 'package:touristsaver/features/connectivity/screens/connectivity.dart';
import 'package:touristsaver/features/profile/widget/info_popup.dart';

import '../../../models/wallet_additional_section.dart';
import 'package:touristsaver/generated/l10n.dart';

class WalletScreen extends StatefulWidget {
  static const String routeName = '/wallet-screen';
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  // List<WalletAdditionalSection> additionalList = [
  //   WalletAdditionalSection(title: topUp, description: popTopUp),
  //   WalletAdditionalSection(
  //       title: changeCountry, description: popChangeCountry),
  //   WalletAdditionalSection(title: transfer, description: popTransferPiiink),
  //   WalletAdditionalSection(title: transaction, description: popTransaction),
  // ];

  bool? isTopUpEnabled;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    ConnectivityCubit().close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<WalletAdditionalSection> additionalList = [
      WalletAdditionalSection(
          title: S.of(context).topUpUniversalTouristSaverCredits,
          description:
              S.of(context).toUseTopUpFunctionRegisterMembershipOrLogIn),
      WalletAdditionalSection(
          title: S.of(context).changeCountry,
          description: S.of(context).toChangeCountryRegisterMembershipOrLogIn),
      WalletAdditionalSection(
          title: S.of(context).transferTouristSavers,
          description:
              S.of(context).toTransferTouristSaversRegisterMembershipOrLogIn),
      WalletAdditionalSection(
          title: S.of(context).transactionHistory,
          description: S
              .of(context)
              .toViewTheTransactionHistoryRegisterMembershipOrLogIn),
    ];
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: CustomAppBar(text: S.of(context).myWallet),
      ),
      body: BlocBuilder<ConnectivityCubit, ConnectivityState>(
        builder: (context, state) {
          return SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Padding(
              padding: const EdgeInsets.only(top: 10.0, bottom: 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  (state == ConnectivityState.loading)
                      ? const NoInternetLoader()
                      : (state == ConnectivityState.disconnected)
                          ? const NoInternetWidget()
                          : (state == ConnectivityState.connected)
                              ? Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    //  "Your Piiinks Universal Credits",
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10.0),
                                      child: AutoSizeText(
                                        S
                                            .of(context)
                                            .yourUniversalTouristSaverCredits,
                                        style: topicStyle,
                                      ),
                                    ),

                                    const SizedBox(height: 10),

                                    // Full Container
                                    uniCredit(),

                                    const SizedBox(height: 20),
                                  ],
                                )
                              : const SizedBox(),
                  // Additionals
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: AutoSizeText(
                      S.of(context).additional,
                      style: topicStyle,
                    ),
                  ),

                  const SizedBox(height: 10),

                  // addtionalList(),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    separatorBuilder: (context, index) {
                      return const SizedBox(height: 10);
                    },
                    itemCount: additionalList.length,
                    itemBuilder: (context, index) {
                      return InkWell(
                        borderRadius: BorderRadius.circular(5.0),
                        onTap: () {
                          showModalBottomSheet(
                              context: context,
                              elevation: 0,
                              backgroundColor: Colors.transparent,
                              constraints: BoxConstraints(
                                maxWidth:
                                    MediaQuery.of(context).size.width / 1.1,
                              ),
                              builder: (context) {
                                return RegLogSlider(
                                    title: additionalList[index].title,
                                    body: additionalList[index].description,
                                    onregister: () {
                                      context.pop();
                                      context.pushNamed('register',
                                          queryParameters: {
                                            'issuercode': '',
                                            'memberReferralCode': ''
                                          });
                                    },
                                    onLogin: () {
                                      context.pop();
                                      context.pushNamed('login');
                                    },
                                    image: 'assets/images/member-card.png');
                              });
                        },
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width,
                          height: 60,
                          child: ListTile(
                            tileColor: GlobalColors.appWhiteBackgroundColor,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5.0)),
                            title: Padding(
                              padding: const EdgeInsets.only(top: 3),
                              child: AutoSizeText(
                                additionalList[index].title,
                                style: profileListStyle,
                              ),
                            ),
                            trailing: Padding(
                              padding: const EdgeInsets.only(top: 3),
                              child: Icon(
                                Icons.arrow_forward_ios,
                                size: 25,
                                color: GlobalColors.gray.withValues(alpha: 0.5),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // Full Container
  uniCredit() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          constraints: const BoxConstraints(maxHeight: double.infinity),
          margin: const EdgeInsets.symmetric(horizontal: 10.0),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(5.0),
              boxShadow: [
                BoxShadow(
                    color: Colors.grey.withValues(alpha: 0.2),
                    blurRadius: 4,
                    spreadRadius: 1,
                    offset: const Offset(2, 2))
              ]),
          child: Column(
            // crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              // Image
              SizedBox(
                child: Image.asset(
                  "assets/images/member-card.png",
                  height: 140,
                  width: MediaQuery.of(context).size.width / 2.4,
                  fit: BoxFit.contain,
                  // color: GlobalColors.appColor,
                ),
              ),

              const SizedBox(height: 20),

              // Body Text
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: AutoSizeText(
                  S
                      .of(context)
                      .youDonTHaveAnyTouristSaverUniversalCreditRegisterYourMembershipOrLogInToAccessTheTouristSaverBenefits,
                  textAlign: TextAlign.center,
                  style: locationStyle.copyWith(fontSize: 18.sp),
                ),
              ),

              const SizedBox(height: 20),

              // Register Button
              CustomButton(
                text: S.of(context).registerNow,
                onPressed: () {
                  context.pushNamed('register', queryParameters: {
                    'issuercode': '',
                    'memberReferralCode': ''
                  });
                },
              ),
              const SizedBox(height: 15),

              // Login Button
              CustomButton1(
                text: S.of(context).logIn,
                onPressed: () {
                  context.pushNamed('login');
                },
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),

        //  info Button
        Positioned(
          right: -5.0,
          top: -7.0,
          child: GestureDetector(
            onTap: () {
              showGeneralDialog(
                barrierLabel: 'Label',
                barrierDismissible:
                    false, //to dismiss the container once opened
                barrierColor: Colors.black.withValues(
                    alpha:
                        0.5), //to change the background color once the container is opened
                transitionDuration: const Duration(milliseconds: 300),
                context: context,
                pageBuilder: (context, anim1, anim2) {
                  return Align(
                    alignment: Alignment.center,
                    child: InfoPopUp(
                      title: S.of(context).touristSaverCreditsInfo,
                      body: S.of(context).touristSaverCreditsInfoD,
                      onOk: () {
                        context.pop();
                      },
                    ),
                  );
                },
                transitionBuilder: (context, anim1, anim2, child) {
                  return SlideTransition(
                    position: Tween(
                            begin: const Offset(0, 1), end: const Offset(0, 0))
                        .animate(anim1),
                    child: child,
                  );
                },
              );
            },
            child: Container(
              width: 25,
              height: 25,
              margin: const EdgeInsets.symmetric(horizontal: 10.0),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  color: GlobalColors.appColor),
              child: Image.asset(
                "assets/images/info.png",
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Additional List
  // addtionalList() {
  // return ListView.separated(
  //   shrinkWrap: true,
  //   physics: const NeverScrollableScrollPhysics(),
  //   padding: const EdgeInsets.symmetric(horizontal: 10.0),
  //   separatorBuilder: (context, index) {
  //     return const SizedBox(height: 10);
  //   },
  //   itemCount: additionalList.length,
  //   itemBuilder: (context, index) {
  //     return InkWell(
  //       borderRadius: BorderRadius.circular(5.0),
  //       onTap: () {
  //         showModalBottomSheet(
  //             context: context,
  //             elevation: 0,
  //             backgroundColor: Colors.transparent,
  //             constraints: BoxConstraints(
  //               maxWidth: MediaQuery.of(context).size.width / 1.1,
  //             ),
  //             builder: (context) {
  //               return RegLogSlider(
  //                   title: additionalList[index].title,
  //                   body: additionalList[index].description,
  //                   onregister: () {
  //                     context.pop();
  //                     context.pushNamed('register', queryParameters: {
  //                       'issuercode': '',
  //                       'memberReferralCode': ''
  //                     });
  //                   },
  //                   onLogin: () {
  //                     context.pop();
  //                     context.pushNamed('login');
  //                   },
  //                   image: 'assets/images/member-card.png');
  //             });
  //       },
  //       child: SizedBox(
  //         width: MediaQuery.of(context).size.width,
  //         height: 60,
  //         child: ListTile(
  //           tileColor: GlobalColors.appWhiteBackgroundColor,
  //           shape: RoundedRectangleBorder(
  //               borderRadius: BorderRadius.circular(5.0)),
  //           title: Padding(
  //             padding: const EdgeInsets.only(top: 3),
  //             child: AutoSizeText(
  //               additionalList[index].title,
  //               style: profileListStyle,
  //             ),
  //           ),
  //           trailing: Padding(
  //             padding: const EdgeInsets.only(top: 3),
  //             child: Icon(
  //               Icons.arrow_forward_ios,
  //               size: 25,
  //               color: GlobalColors.gray.withValues(alpha: 0.5),
  //             ),
  //           ),
  //         ),
  //       ),
  //     );
  //   },
  // );
  // }
}
