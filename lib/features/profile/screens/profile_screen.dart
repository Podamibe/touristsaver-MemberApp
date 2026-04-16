import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:new_piiink/common/services/dio_common.dart';
import 'package:new_piiink/common/widgets/custom_app_bar.dart';
import 'package:new_piiink/common/widgets/custom_button.dart';
import 'package:new_piiink/common/widgets/reg_log_slider.dart';
import 'package:new_piiink/constants/global_colors.dart';
import 'package:new_piiink/constants/style.dart';
import 'package:new_piiink/features/connectivity/cubit/internet_cubit.dart';
import 'package:new_piiink/generated/l10n.dart';

import '../../connectivity/screens/connectivity.dart';

class ProfileScreen extends StatefulWidget {
  static const String routeName = "/profile";

  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  dynamic showCharity = false;
  @override
  void initState() {
    super.initState();
    fetchShowCharity(); // ✅ Fetch when screen opens
  }

  @override
  void dispose() {
    // ConnectivityCubit().close();
    super.dispose();
    // fetchShowCharity();
  }

  Future<void> fetchShowCharity() async {
    try {
      var res = await DioCommon().getShowCharity();

      if (res != null && res['status'] == "Success") {
        if (!mounted) return;
        setState(() {
          showCharity = res['data'];
        });
      }
    } catch (e) {
      debugPrint("Error processing banner: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    List<String> additional = [];

    if (showCharity is Map && showCharity['show'] == true) {
      additional.add(S.of(context).charity);
    }
    additional.addAll([
      S.of(context).recommendNewMerchant,
      S.of(context).about,
      S.of(context).termsConditions,
    ]);
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: CustomAppBar(text: S.of(context).profile),
      ),
      body: BlocBuilder<ConnectivityCubit, ConnectivityState>(
        builder: (context, state) {
          return ScrollConfiguration(
            behavior: const ScrollBehavior(),
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Padding(
                padding: const EdgeInsets.only(top: 10.0, bottom: 10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Full Container
                    (state == ConnectivityState.loading)
                        ? const NoInternetLoader()
                        : (state == ConnectivityState.disconnected)
                            ? const NoInternetWidget()
                            : (state == ConnectivityState.connected)
                                ? Column(
                                    children: [
                                      memberShipBoxProfile(),
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
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      separatorBuilder: (context, index) {
                        return const SizedBox(height: 10);
                      },
                      itemCount: additional.length,
                      itemBuilder: (context, index) {
                        return InkWell(
                          borderRadius: BorderRadius.circular(5.0),
                          onTap: () {
                            additional[index] == additional[2]
                                ? context.pushNamed('about-screen')
                                : additional[index] == additional[3]
                                    ? context.pushNamed('terms-condition')
                                    : showModalBottomSheet(
                                        context: context,
                                        elevation: 0,
                                        backgroundColor: Colors.transparent,
                                        constraints: BoxConstraints(
                                          maxWidth: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              1.1, // here increase or decrease in width
                                        ),
                                        builder: (context) {
                                          return RegLogSlider(
                                            title: additional[index] ==
                                                    additional[0]
                                                ? S.of(context).charity
                                                : S
                                                    .of(context)
                                                    .recommendNewMerchant,
                                            body: additional[index] ==
                                                    additional[0]
                                                ? S
                                                    .of(context)
                                                    .toChooseCharityRegisterMembershipOrLogIn
                                                : S
                                                    .of(context)
                                                    .forRecommendingTheNewMerchantRegisterMembershipOrLogIn,
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
                                            image: additional[index] ==
                                                    additional[1]
                                                ? 'assets/images/member-card.png'
                                                : 'assets/images/charity.png',
                                          );
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
                                  additional[index],
                                  style: profileListStyle,
                                ),
                              ),
                              trailing: Padding(
                                padding: const EdgeInsets.only(top: 3),
                                child: Icon(
                                  Icons.arrow_forward_ios,
                                  size: 25,
                                  color:
                                      GlobalColors.gray.withValues(alpha: 0.5),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    )
                    // addtionalList(),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // Full Container
  memberShipBoxProfile() {
    return Stack(
      // alignment: Alignment.topRight,
      clipBehavior: Clip.none,
      children: [
        Container(
          constraints: const BoxConstraints(
            //To make height expandable according to the text
            maxHeight: double.infinity,
          ),
          // width: MediaQuery.of(context).size.width / 1,
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
                      .registerYourMembershipOrLogInToAccessTheTouristSaverBenefitsAndViewYourProfileDetails,
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
      ],
    );
  }
}
