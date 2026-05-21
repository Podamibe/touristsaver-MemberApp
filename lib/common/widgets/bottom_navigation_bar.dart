// ignore_for_file: deprecated_member_use
import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_branch_sdk/flutter_branch_sdk.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:flutter_svg/flutter_svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:new_piiink/common/app_variables.dart';
import 'package:new_piiink/common/services/firebase_api.dart';
import 'package:new_piiink/common/widgets/reg_log_slider.dart';
import 'package:new_piiink/constants/global_colors.dart';
import 'package:new_piiink/constants/initialize_stripe.dart';
import 'package:new_piiink/constants/pref.dart';
import 'package:new_piiink/constants/pref_key.dart';
import 'package:new_piiink/features/home_page/screens/home_screen.dart';
import 'package:new_piiink/features/merchant/discovery/merchant_discovery_intent.dart';
import 'package:new_piiink/features/merchant/screens/merchant_screen.dart';
import 'package:new_piiink/features/payment/screens/pay_screen.dart';
import 'package:new_piiink/features/profile/screens/log_profile_screen.dart';
import 'package:new_piiink/features/profile/screens/profile_screen.dart';
import 'package:new_piiink/features/wallet/screens/wallet_screen.dart';
import 'package:new_piiink/features/wallet/screens/log_wallet_screen.dart';
import 'package:new_piiink/splash_screen.dart';
import 'package:upgrader/upgrader.dart';
import '../services/location_service.dart';
import 'package:new_piiink/generated/l10n.dart';

class BottomBar extends StatefulWidget {
  final int? page;
  static const String routeName = '/bottom-bar';
  const BottomBar({super.key, this.page});

  @override
  State<BottomBar> createState() => _BottomBarState();
}

class _BottomBarState extends State<BottomBar> {
  GlobalKey navBarGlobalKey = GlobalKey();
  DateTime backpress = DateTime.now();
  int _page = 4;
  late bool serviceEnabled;
  late LocationPermission permission;

  // For checking the token and For reading the country currency that user is registered with
  checkToken() async {
    AppVariables.originCountryId =
        await Pref().readData(key: saveCountryOriginID);
    AppVariables.accessToken = await Pref().readData(key: saveToken);
    AppVariables.selectedLanguageNow = await Pref().readData(key: 'locale');
    if (AppVariables.accessToken != null) {
      AppVariables.initNotifications = true;
    }
    AppVariables.currency = await Pref().readData(key: saveCurrency);
    acc = await Pref().readData(key: accept);
  }

  //Using Branch.io for referral issuer code
  StreamSubscription<Map>? streamSubscription;
  // StreamController<String> controllerData = StreamController<String>();
  void listenDynamicLinks() async {
    // FlutterBranchSdk.init();
    streamSubscription = FlutterBranchSdk.listSession().listen((data) {
      if (AppVariables.accessToken != null) return;
      if (data.containsKey('+clicked_branch_link') &&
          data['+clicked_branch_link'] == true) {
        if (data.containsKey('issuercode')) {
          Pref().setBool(key: 'isShownRegLog', value: true);
          context.pushNamed('register', queryParameters: {
            'issuercode': '${data['issuercode']}',
            'memberReferralCode': ''
          });
        } else if (data.containsKey('memberReferralCode')) {
          Pref().setBool(key: 'isShownRegLog', value: true);
          context.pushNamed('register', queryParameters: {
            'issuercode': '',
            'memberReferralCode': '${data['memberReferralCode']}'
          });
        } else {
          return;
        }
      } else {
        return;
      }
    }, onError: (error) {
      debugPrint('InitSesseion error: ${error.toString()}');
    });
  }

  initializeNotifications() async {
    if (AppVariables.initNotifications) {
      await FirebaseApi().initNotifications(context);
    }
  }

  @override
  void initState() {
    checkToken();
    _page = widget.page ?? 4;
    MerchantDiscoveryIntentStore.bottomTabRequest
        .addListener(_handleDiscoveryTabRequest);
    _handleDiscoveryTabRequest();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await LocationService().enableLocationAndFetchCountry();
      await Pref().readData(key: savePublishableKey) == null
          ? byDefaultStripeKey()
          : initializeFlutterStripe();
      // Initializing Firebase notifications
      initializeNotifications();
      listenDynamicLinks();
    });
    //   WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  void _handleDiscoveryTabRequest() {
    final MerchantDiscoveryTabRequest? request =
        MerchantDiscoveryIntentStore.bottomTabRequest.value;
    if (request == null) return;
    if (_page != request.page) {
      if (mounted) {
        setState(() {
          _page = request.page;
        });
      } else {
        _page = request.page;
      }
    }
    MerchantDiscoveryIntentStore.clearBottomTabRequest(token: request.token);
  }

  @override
  void didUpdateWidget(covariant BottomBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    final int nextPage = widget.page ?? 4;
    if (oldWidget.page != widget.page && _page != nextPage) {
      setState(() {
        _page = nextPage;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: _page != 0,
      child: WillPopScope(
        onWillPop: () async {
          final timegap = DateTime.now().difference(backpress);
          final cantExit = timegap >= const Duration(seconds: 2);
          backpress = DateTime.now();
          if (cantExit) {
            // show snackbar
            SnackBar snack = SnackBar(
              content: Text(S.of(context).pressBackButtonAgainToExit),
              duration: const Duration(seconds: 2),
            );
            ScaffoldMessenger.of(context).showSnackBar(snack);
            return false;
          } else {
            return true;
          }
        },
        child: UpgradeAlert(
          dialogStyle: Platform.isAndroid
              ? UpgradeDialogStyle.material
              : UpgradeDialogStyle.cupertino,
          shouldPopScope: () => true,
          showIgnore: false,
          upgrader: Upgrader(
            durationUntilAlertAgain: const Duration(hours: 5),
          ),
          child: Scaffold(
            body: AppVariables.accessToken == null
                ? _page == 0
                    ? const HomeScreen()
                    : _page == 1
                        ? const MerchantScreen()
                        : _page == 3
                            ? const WalletScreen()
                            : const ProfileScreen()
                : _page == 0
                    ? const HomeScreen()
                    : _page == 1
                        ? const MerchantScreen()
                        : _page == 2
                            ? const PayScreen()
                            : _page == 3
                                ? const LogWalletScreen()
                                : const LogProfileScreen(),

            // Bottom Navigation Bar
            bottomNavigationBar: buildBottomNavigationMenu(context),

            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerDocked,
          ),
        ),
      ),
    );
  }

  buildBottomNavigationMenu(context) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: GlobalColors.appColor1.withValues(alpha: 0.2),
            spreadRadius: 1,
            blurRadius: 7,
            offset: const Offset(0.5, 0.5),
          ),
        ],
      ),
      child: BottomNavigationBar(
        key: navBarGlobalKey,
        landscapeLayout: BottomNavigationBarLandscapeLayout.centered,
        elevation: 0,
        currentIndex: _page,
        selectedItemColor: const Color(0xFFF146EA),
        selectedFontSize: 13.sp,
        unselectedFontSize: 13.sp,
        unselectedItemColor: Colors.grey,
        iconSize: 25.h,
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        onTap: (page) async {
          if (page == 0) {
            MerchantDiscoveryIntentStore.clear();
            MerchantDiscoveryIntentStore.clearBottomTabRequest();
          }
          if (AppVariables.accessToken == null) {
            if (page == 2) {
              await paySlider();
            } else {
              setState(() {
                _page = page;
              });
            }
          } else {
            setState(() {
              _page = page;
            });
          }
        },
        items: [
          // Home Screen
          BottomNavigationBarItem(
            icon: const Icon(Icons.house),
            label: S.of(context).home,
          ),

          // Merchant Screen
          BottomNavigationBarItem(
            icon: const Icon(Icons.saved_search_rounded),
            label: 'Search',
          ),

          // Pay Screen
          BottomNavigationBarItem(
            icon: Icon(
              Icons.account_balance_wallet,
              color: _page == 2 ? const Color(0xFFF146EA) : Colors.grey,
            ),
            // SvgPicture.asset(
            //   "assets/images/pay.svg",
            //   height: 25,
            //   color: _page == 2 ? GlobalColors.appColor : Colors.grey,
            // ),
            label: S.of(context).pay,
          ),

          // Savings Screen
          BottomNavigationBarItem(
            icon: const Icon(Icons.savings_outlined),
            label: 'My Savings',
          ),

          // Profile Screen
          BottomNavigationBarItem(
            icon: const Icon(Icons.person),
            label: S.of(context).profile,
          ),
        ],
      ),
    );
  }

  paySlider() {
    return showModalBottomSheet(
        context: context,
        elevation: 0,
        backgroundColor: Colors.transparent,
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width /
              1.1, // here increase or decrease in width
        ),
        builder: (context) {
          return RegLogSlider(
            title: S.of(context).membership,
            body:
                S.of(context).registerYourMembershipNowAndEnjoyOurAmazingOffers,
            onregister: () {
              context.pop();
              context.pushNamed('register', queryParameters: {
                'issuercode': '',
                'memberReferralCode': ''
              });
            },
            onLogin: () {
              context.pop();
              context.pushNamed('login');
            },
          );
        });
  }

  @override
  void dispose() {
    MerchantDiscoveryIntentStore.bottomTabRequest
        .removeListener(_handleDiscoveryTabRequest);
    streamSubscription?.cancel();
    // WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}
