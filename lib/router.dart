import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:new_piiink/common/widgets/bottom_navigation_bar.dart';
import 'package:new_piiink/common/widgets/congrats.dart';
import 'package:new_piiink/common/widgets/paid_free.dart';
import 'package:new_piiink/features/app_intro/screens/first_choose_country.dart';
import 'package:new_piiink/features/app_intro/screens/intro_screen.dart';
import 'package:new_piiink/features/app_intro/screens/video_intro_screen.dart';
import 'package:new_piiink/features/charity/screens/charity_list.dart';
import 'package:new_piiink/features/charity/screens/view_all_charities.dart';
import 'package:new_piiink/features/details/screens/detail_pay_screen.dart';
import 'package:new_piiink/features/details/screens/details_screen.dart';
import 'package:new_piiink/features/home_page/screens/all_merchant_screen.dart';
import 'package:new_piiink/features/home_page/screens/category_screen.dart';
import 'package:new_piiink/features/home_page/screens/home_screen.dart';
import 'package:new_piiink/features/home_page/screens/search_merchant.dart';
import 'package:new_piiink/features/home_page/screens/view_all_screen.dart';
import 'package:new_piiink/features/home_page/widget/map_view_from_new_merchants.dart';

import 'package:new_piiink/features/location/screens/location_screen.dart';
import 'package:new_piiink/features/login/screens/bio_login.dart';
import 'package:new_piiink/features/login/screens/login_screen.dart';
import 'package:new_piiink/features/merchant/screens/add_review.dart';
import 'package:new_piiink/features/merchant/screens/merchant_rating.dart';
import 'package:new_piiink/features/merchant/screens/merchant_screen.dart';
import 'package:new_piiink/features/more_offers/screens/more_offers_screen.dart';
import 'package:new_piiink/features/notification/notification_screen.dart';
import 'package:new_piiink/features/payment/screens/accept_screen.dart';
import 'package:new_piiink/features/payment/screens/confirm_pay_screen.dart';
import 'package:new_piiink/features/payment/screens/manual_code.dart';
import 'package:new_piiink/features/payment/screens/pay_complete.dart';
import 'package:new_piiink/features/payment/screens/pay_screen.dart';
import 'package:new_piiink/common/widgets/qr_scan.dart';
import 'package:new_piiink/features/profile/screens/change_country.dart';
import 'package:new_piiink/features/profile/screens/country_num_change_veri.dart';
import 'package:new_piiink/features/profile/screens/edit_num_change_veri.dart';
import 'package:new_piiink/features/profile/screens/edit_profile.dart';
import 'package:new_piiink/features/profile/screens/log_profile_screen.dart';
import 'package:new_piiink/features/profile/screens/member_referral.dart';
import 'package:new_piiink/features/wallet/widget/merchant_wallet.dart';
import 'package:new_piiink/features/profile/screens/profile_screen.dart';
import 'package:new_piiink/features/recommend/screens/recommend_screen.dart';
import 'package:new_piiink/features/register/screens/num_otp_screen.dart';
import 'package:new_piiink/features/register/screens/register_screen.dart';
import 'package:new_piiink/features/terms_conditions/screens/terms_first.dart';
import 'package:new_piiink/features/transaction/screens/transaction.dart';
import 'package:new_piiink/features/terms_conditions/screens/terms_condition_screens.dart';
import 'package:new_piiink/features/top_up/screens/top_up_screen.dart';
import 'package:new_piiink/features/transfer_piiinks/screens/transfer_piiinks.dart';
import 'package:new_piiink/features/wallet/screens/wallet_screen.dart';
import 'package:new_piiink/splash_screen.dart';
import 'features/about/screens/about_screen.dart';
import 'features/home_page/screens/location_searched.dart';
import 'features/home_page/widget/choose_on_map.dart';
import 'features/home_page/widget/view_all_nearby_merchants.dart';
import 'features/top_up/screens/top_up_history.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

/// The route configuration.
final GoRouter goRouter = GoRouter(
  navigatorKey: navigatorKey,
  routes: <RouteBase>[
    //Splash Screen
    // GoRoute(
    //     path: '/',
    //     name: 'splash-screen',
    //     builder: (context, state) {
    //       return UpgradeAlert(
    //           navigatorKey: navigatorKey,
    //           upgrader: Upgrader(
    //             // shouldPopScope: () => true,
    //             durationUntilAlertAgain: const Duration(seconds: 1),
    //             // dialogStyle: Platform.isAndroid
    //             //     ? UpgradeDialogStyle.material
    //             //     : UpgradeDialogStyle.cupertino,
    //           ),
    //           child: const MySplashScreen());
    //     }),
    GoRoute(
        path: '/',
        name: 'splash-screen',
        builder: (context, state) {
          return const MySplashScreen();
        }),

    //Introduction Screen
    GoRoute(
      path: '/intro-screen',
      name: 'intro-screen',
      builder: (context, state) => const IntroScreen(),
    ),
    GoRoute(
      path: '/video-screen',
      name: 'video-screen',
      builder: (context, state) => VideoIntroScreen(
        returnRouteName: state.uri.queryParameters['returnTo'],
      ),
    ),
    //First Choose Country Screen
    GoRoute(
      path: '/first-choose-country',
      name: 'first-choose-country',
      builder: (context, state) => const FirstChooseCountry(),
    ),
    //Terms First
    GoRoute(
      path: '/terms-first',
      name: 'terms-first',
      builder: (context, state) => const TermsFirst(),
    ),
    //Terms and Condition Screen
    GoRoute(
      path: '/terms-condition',
      name: 'terms-condition',
      builder: (context, state) => const TermsConditionScreen(),
    ),
    //Home Screen
    GoRoute(
      path: '/home',
      name: 'home',
      builder: (context, state) => const HomeScreen(),
    ),
    // Notification Screen
    GoRoute(
      path: '/notification',
      name: 'notification',
      builder: (context, state) => const NotificationScreen(),
    ),
    //View All Screen
    GoRoute(
      path: '/home-view-all/:appBarName',
      name: 'home-view-all',
      builder: (context, state) =>
          ViewAllScreen(appBarName: state.pathParameters['appBarName']!),
    ),
    //View All Nearby Merchants Screen
    GoRoute(
      path: '/view-all-nearby-merchants',
      name: 'view-all-nearby-merchants',
      builder: (context, state) => const ViewAllNearbyMerchantsScreen(
          // appBarName: state.pathParameters['appBarName']!
          ),
    ),
    //All Merchant Screen
    GoRoute(
      path: '/all-merchant',
      name: 'all-merchant',
      builder: (context, state) => const AllMerchantScreen(),
    ),
    //Map View Merchant Screen
    GoRoute(
      path: '/map-view-merchant',
      name: 'map-view-merchant',
      builder: (context, state) => const MapViewMerchants(),
    ),
    //Merchant Reviews Screen
    GoRoute(
        path: '/merchant-rating',
        name: 'merchant-rating',
        builder: (context, state) {
          Map<String, dynamic> args = state.extra as Map<String, dynamic>;
          return MerchantRating(
            merchantId: args['merchantId'],
          );
        }),
    //Merchant Reviews Screen
    GoRoute(
        path: '/feedback-screen',
        name: 'feedback-screen',
        builder: (context, state) {
          Map<String, dynamic> args = state.extra as Map<String, dynamic>;
          return FeedbackScreen(
            merchantId: args['merchantId'],
          );
        }),
    //Search Merchant Screen
    GoRoute(
      path: '/search-merchant',
      name: 'search-merchant',
      builder: (context, state) => const SearchMerchant(),
    ),

    //Location Search Merchant Screen
    GoRoute(
      path: '/location-search-merchant',
      name: 'location-search-merchant',
      builder: (context, state) => const LocationSearchMerchant(),
    ),
    //Location Search Merchant Screen
    // GoRoute(
    //   path: '/near-me-merchant/:appBarName',
    //   name: 'near-me-merchant',
    //   builder: (context, state) =>
    //       NearMeMerchants(appBarName: state.pathParameters['appBarName']!),
    // ),
    GoRoute(
      path: '/choose-on-map/:appBarName',
      name: 'choose-on-map',
      builder: (context, state) =>
          ChooseOnMap(appBarName: state.pathParameters['appBarName']!),
    ),
    //Location Screen
    GoRoute(
      path: '/location',
      name: 'location',
      builder: (context, state) => const LocationScreen(),
    ),
    //Profile Screen
    GoRoute(
      path: '/profile',
      name: 'profile',
      builder: (context, state) => const ProfileScreen(),
    ),
    //Category Screen
    GoRoute(
      path: '/category-screen/:parentId',
      name: 'category-screen',
      builder: (context, state) => CategoryScreen(
        //  categoryName: state.pathParameters['categoryName']!,
        parentId: state.pathParameters['parentId']!,
      ),
    ),
    //Details Screen
    GoRoute(
        path: '/details-screen',
        name: 'details-screen',
        builder: (context, state) {
          Map<String, dynamic> args = state.extra as Map<String, dynamic>;
          return DetailsScreen(
            merchantID: args['merchantID']!,
            // isFavorite: args['isFavorite'] ?? false,
          );
        }),
    //Detail Pay Screen
    GoRoute(
      path: '/detail-pay/:merchantName/:transactionCode',
      name: 'detail-pay',
      builder: (context, state) => DetailPayScreen(
        merchantName: state.pathParameters['merchantName']!,
        transactionCode: state.pathParameters['transactionCode']!,
      ),
    ),
    //More Offer Screen
    GoRoute(
        path: '/more-offers',
        name: 'more-offers',
        builder: (context, state) {
          Map<String, dynamic> args = state.extra as Map<String, dynamic>;
          return MoreOffersScreen(
            argImageList: args['argImageList'],
            merchantID: args['merchantID'],
          );
        }),
    //Login Screen
    GoRoute(
      path: '/login',
      name: 'login',
      builder: (context, state) => const LoginScreen(),
    ),
    //Email OTP Screen
    // GoRoute(
    //     path: '/email-otp',
    //     name: 'email-otp',
    //     builder: (context, state) {
    //       Map<String, dynamic> args = state.extra as Map<String, dynamic>;
    //       return EmailOTPScreen(
    //         countryID: args['countryID'],
    //         stateID: args['stateID'],
    //         issuerCode: args['issuerCode'],
    //         firstName: args['firstName'],
    //         lastName: args['lastName'],
    //         email: args['email'],
    //         password: args['password'],
    //         confirmPassword: args['confirmPassword'],
    //         phonePrefix: args['phonePrefix'],
    //         phNum: args['phNum'],
    //         postalCode: args['postalCode'],
    //         premium: args['premium'],
    //         referralCode: args['referralCode'],
    //         otpMedium: args['otpMedium'],
    //       );
    //     }),
    //Number OTP Screen
    GoRoute(
        path: '/number-reg-otp',
        name: 'number-reg-otp',
        builder: (context, state) {
          Map<String, dynamic> args = state.extra as Map<String, dynamic>;
          return NumberOTPScreen(
            charityID: args['charityID'],
            countryID: args['countryID'],
            stateID: args['stateID'],
            issuerCode: args['issuerCode'],
            firstName: args['firstName'],
            lastName: args['lastName'],
            email: args['email'],
            password: args['password'],
            confirmPassword: args['confirmPassword'],
            phonePrefix: args['phonePrefix'],
            phNum: args['phNum'],
            postalCode: args['postalCode'],
            premium: args['premium'],
            referralCode: args['referralCode'],
            phoneVerifiedBy: args['phoneVerifiedBy'],
          );
        }),
    //Register Screen
    GoRoute(
      path: '/register',
      name: 'register',
      builder: (context, state) {
        final issuercode = state.uri.queryParameters['issuercode'] ?? '';
        final memberReferralCode =
            state.uri.queryParameters['memberReferralCode'] ?? '';
        return RegisterScreen(
            issuercode: issuercode, memberReferralCode: memberReferralCode);
      },
    ),
    //Log Profile Screen
    GoRoute(
      path: '/log-profile',
      name: 'log-profile',
      builder: (context, state) => const LogProfileScreen(),
    ),
    //Merchant Wallet Screen
    GoRoute(
      path: '/merchant-wallet',
      name: 'merchant-wallet',
      builder: (context, state) => const MerchantWalletScreen(),
    ),
    //Manual Code Screen
    GoRoute(
      path: '/manual-code/:totalAmount',
      name: 'manual-code',
      builder: (context, state) => ManualCode(
        totalAmount: state.pathParameters['totalAmount']!,
      ),
    ),
    //Recommend Screen
    GoRoute(
      path: '/recommend',
      name: 'recommend',
      builder: (context, state) => const RecommendScreen(),
    ),
    //Recommend Screen
    GoRoute(
      path: '/memberReferral',
      name: 'memberReferral',
      builder: (context, state) => const MemberReferralScreen(),
    ),
    //Pay Screen
    GoRoute(
      path: '/pay',
      name: 'pay',
      builder: (context, state) => PayScreen(
        merchantName: state.extra as String?,
      ),
    ),
    //Top Up Screen
    GoRoute(
      path: '/top-up',
      name: 'top-up',
      builder: (context, state) => const TopUpScreen(),
    ),
    //Paid Free Screen
    GoRoute(
      path: '/paid-free',
      name: 'paid-free',
      builder: (context, state) => PaidFreeScreen(),
    ),
    //Transfer Piiinks
    GoRoute(
      path: '/transfer-piiinks',
      name: 'transfer-piiinks',
      builder: (context, state) => const TransferPiiinks(),
    ),
    //Edit Profile
    GoRoute(
      path: '/edit-profile',
      name: 'edit-profile',
      builder: (context, state) => const EditProfile(),
    ),
    //Edit Number Screen
    GoRoute(
        path: '/edit-number',
        name: 'edit-number',
        builder: (context, state) {
          Map<String, dynamic> args = state.extra as Map<String, dynamic>;
          return EditNumberChangedVerification(
            phoneNumberPrefix: args['phoneNumberPrefix'],
            mobileNumber: args['mobileNumber'],
            email: args['email'],
            countryId: args['countryId'],
            // otpMedium: args['otpMedium'],
          );
        }),
    //Change Country
    GoRoute(
      path: '/change-country',
      name: 'change-country',
      builder: (context, state) => const ChangeCountry(),
    ),
    //Change Country Edit Number Screen
    GoRoute(
        path: '/country-number-edit',
        name: 'country-number-edit',
        builder: (context, state) {
          Map<String, dynamic> args = state.extra as Map<String, dynamic>;
          return CountryNumberChangedVerification(
            phonePrefix: args['phonePrefix'],
            mobileNumber: args['mobileNumber'],
            email: args['email'],
            countryId: args['countryId'],
            // otpMedium: args['otpMedium'],
          );
        }),
    //Charity List Screen
    GoRoute(
      path: '/charity-list',
      name: 'charity-list',
      builder: (context, state) => const CharityList(),
    ),
    //View All Charity List Screen
    GoRoute(
      path: '/view-all-charity-list',
      name: 'view-all-charity-list',
      builder: (context, state) => const ViewAllCharityList(),
    ),

    //Confirm Payment Screen
    GoRoute(
        path: '/confirm-pay',
        name: 'confirm-pay',
        builder: (context, state) {
          Map<String, dynamic> args = state.extra as Map<String, dynamic>;
          return ConfimrPaymentScreen(
            merchantId: args['merchantId'],
            totalAmount: args['totalAmount'],
            qrCode: args['qrCode'],
            hasMerchantPiiinks: args['hasMerchantPiiinks'],
            hasUniversalPiiinks: args['hasUniversalPiiinks'],
            merchantName: args['merchantName'],
            universalPiiinkBalance: args['universalPiiinkBalance'],
            merchantPiiinkBalance: args['merchantPiiinkBalance'],
            merchantRebateToMember: args['merchantRebateToMember'],
            merchantDiscountPercentage: args['merchantDiscountPercentage'],
            discountedTransactionAmount: args['discountedTransactionAmount'],
            totalPiiinkDiscount: args['totalPiiinkDiscount'],
            logo: args['logo'],
            universalPiiinkOnHold: args['universalPiiinkOnHold'],
            merchantPiiinkOnHold: args['merchantPiiinkOnHold'],
            terminalUserId: args['terminalUserId'],
            terminalId: args['terminalId'],
          );
        }),
    //Accept Screen
    GoRoute(
        path: '/accept-screen',
        name: 'accept-screen',
        builder: (context, state) {
          Map<String, dynamic> args = state.extra as Map<String, dynamic>;
          return AcceptScreen(
            merchantId: args['merchantId'],
            totalAmount: args['totalAmount'],
            qrCode: args['qrCode'],
            discountedTransactionAmount: args['discountedTransactionAmount'],
            totalPiiinkDiscount: args['totalPiiinkDiscount'],
            merchantRebateToMember: args['merchantRebateToMember'],
            merchantDiscountPercentage: args['merchantDiscountPercentage'],
            merchantName: args['merchantName'],
            logo: args['logo'],
            tsdcsRemaining: args['tsdcsRemaining'],
            walletType: args['walletType'],
            terminalUserId: args['terminalUserId'],
            terminalId: args['terminalId'],
          );
        }),
    //Payment Completed
    GoRoute(
        path: '/payment-complete',
        name: 'payment-complete',
        builder: (context, state) {
          Map<String, dynamic> args = state.extra as Map<String, dynamic>;
          return PaymentCompleted(
            merchantId: args['merchantId'],
            merchantName: args['merchantName'],
            totalAmount: args['totalAmount'],
            totalPiiinkDiscount: args['totalPiiinkDiscount'],
            discountedTransactionAmount: args['discountedTransactionAmount'],
            merchantRebateToMember: args['merchantRebateToMember'],
            merchantDiscountPercentage: args['merchantDiscountPercentage'],
            walletType: args['walletType'],
          );
        }),
    //Bottom Navigation Bar
    GoRoute(
      path: '/bottom-bar/:page',
      name: 'bottom-bar',
      builder: (context, state) {
        final page = state.pathParameters['page'];
        return BottomBar(page: int.parse(page ?? '4'));
      },
    ),
    //Transaction Screen
    GoRoute(
      path: '/statement/:uniBalance',
      name: 'statement',
      builder: (context, state) => TransactionScreen(
        uniBalance: double.parse(state.pathParameters['uniBalance']!),
      ),
    ),
    //TopUpHistory Screen
    GoRoute(
      path: '/top_up_history',
      name: 'top_up_history',
      builder: (context, state) => const TopUpHistoryScreen(),
    ),
    //Premium Top Up Screen
    // GoRoute(
    //   path: '/premium_top_up_history',
    //   name: 'premium_top_up_history',
    //   builder: (context, state) => const PremiumTopUpHistory(),
    // ),
    //BoiMetric Login Screen
    GoRoute(
      path: '/settings-screen',
      name: 'settings-screen',
      builder: (context, state) => const SettingScreen(),
    ),
    //About Us Screen
    GoRoute(
      path: '/about-screen',
      name: 'about-screen',
      builder: (context, state) => const AboutScreen(),
    ),
    //Rewards Screen
    // GoRoute(
    //   path: '/rewards-screen',
    //   name: 'rewards-screen',
    //   builder: (context, state) => const RewardsScreen(),
    // ),
    //Merchant Screen
    GoRoute(
      path: '/merchant-screen',
      name: 'merchant-screen',
      builder: (context, state) => const MerchantScreen(),
    ),
    //Wallet Screen
    GoRoute(
      path: '/wallet-screen',
      name: 'wallet-screen',
      builder: (context, state) => const WalletScreen(),
    ),

    //Congrats Screen
    GoRoute(
      path: '/congrats-screen/:piiinkCredit',
      name: 'congrats-screen',
      builder: (context, state) =>
          CongratsScreen(piiinkCredit: state.pathParameters['piiinkCredit']!),
    ),

    //Qr Scan Screen
    GoRoute(
      path: '/qr_screen',
      name: 'qr_screen',
      builder: (context, state) {
        Map<String, dynamic> args = state.extra as Map<String, dynamic>;
        return QRScannerScreen(
          title: args['title'],
        );
      },
    ),
  ],
);
