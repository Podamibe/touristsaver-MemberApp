import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_branch_sdk/flutter_branch_sdk.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:new_piiink/constants/global_colors.dart';
import 'package:new_piiink/features/charity/services/dio_charity.dart';
import 'package:new_piiink/features/connectivity/cubit/internet_cubit.dart';
import 'package:new_piiink/features/details/services/dio_detail.dart';
import 'package:new_piiink/features/home_page/bloc/category_blocs.dart';
import 'package:new_piiink/features/home_page/bloc/slider_blocs.dart';
import 'package:new_piiink/features/home_page/services/home_dio.dart';
import 'package:new_piiink/features/location/services/dio_location.dart';
import 'package:new_piiink/features/profile/bloc/user_profile_blocs.dart';
import 'package:new_piiink/features/profile/services/dio_membership.dart';
import 'package:new_piiink/features/more_offers/services/dio_more_offer.dart';
import 'package:new_piiink/features/profile/services/dio_profile.dart';
import 'package:new_piiink/features/terms_conditions/services/dio_agreement.dart';
import 'package:new_piiink/features/top_up/services/top_up_dio.dart';
import 'package:new_piiink/features/transaction/services/dio_transaction.dart';
import 'package:new_piiink/features/wallet/services/dio_wallet.dart';
import 'package:new_piiink/router.dart';
import 'firebase_options.dart';
import 'l10n/locale_bloc.dart';
import 'package:new_piiink/generated/l10n.dart';
import 'package:new_piiink/constants/initialize_stripe.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Firebase Initialization
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await FlutterBranchSdk.init();
  // FlutterBranchSdk
  //     .validateSDKIntegration(); //For Branch.io Remove it from the production
  await SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

  await initializeFlutterStripe();
  // Stripe.publishableKey = await Pref().readData(key: savePublishableKey);
  // stripePublishableKey; // set the publishable key for Stripe - this is mandatory
  // Stripe.merchantIdentifier = 'merchant.flutter.stripe.test';
  // await Stripe.instance.applySettings();
  // await Upgrader.clearSavedSettings(); //For app update notification as a testing purpose
  await ScreenUtil.ensureScreenSize();
  if (kReleaseMode) {
    debugPrint = (String? message, {int? wrapWidth}) {};
  }
  DioHome dioHome = DioHome();
  DioMemberShip dioMemberShip = DioMemberShip();
  runApp(
    MultiRepositoryProvider(
      providers: [
        BlocProvider(create: (context) => ConnectivityCubit()),
        // RepositoryProvider(create: (context) => DioHome()), //For category list
        // RepositoryProvider(create: (context) => DioMemberShip()), //For User Profile
        BlocProvider(
          create: (context) => CategoryBloc(dioHome),
        ),
        BlocProvider(
          create: (context) => SliderBloc(dioHome),
        ),
        BlocProvider(
          create: (context) => UserProfileBloc(dioMemberShip),
        ),
        RepositoryProvider(
            create: (context) =>
                DioLocation()), //For Country, State, PostalCode/ZipCode
        RepositoryProvider(
            create: (context) => DioProfile()), //For Profile Wallet
        RepositoryProvider(
            create: (context) => DioCharity()), //For Charity List
        RepositoryProvider(
            create: (context) =>
                DioTopUpStripe()), //For Top Up or Member Package
        RepositoryProvider(
            create: (context) => DioDetail()), //For merchant detail
        RepositoryProvider(
            create: (context) => DioAgreement()), //For Terms and Condition
        RepositoryProvider(
            create: (context) => DioMoreOffer()), //For More Offer for Discount
        RepositoryProvider(
            create: (context) => DioTransaction()), //For Transaction
        RepositoryProvider(create: (context) => DioWallet()), //For Wallet
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(393, 786),
      minTextAdapt: true,
      splitScreenMode: true,
      useInheritedMediaQuery: true,
      builder: (context, child) {
        return BlocProvider(
          create: (context) => LocaleCubit(),
          child: BlocBuilder<LocaleCubit, LocaleState>(
            builder: (context, state) {
              return MaterialApp.router(
                title: "TouristSaver",
                debugShowCheckedModeBanner: false,
                scrollBehavior: const ScrollBehavior(),
                localizationsDelegates: S.localizationsDelegates,
                supportedLocales: S.supportedLocales,
                locale: state.localeModel.locale,
                theme: ThemeData(
                  useMaterial3: false,
                  scaffoldBackgroundColor: GlobalColors.appGreyBackgroundColor,
                  appBarTheme: AppBarTheme(
                    elevation: 0,
                    iconTheme: const IconThemeData(
                      color: Colors.black,
                    ),
                    // For changing the mobile top bar color and top bar text color
                    systemOverlayStyle: SystemUiOverlayStyle.dark.copyWith(
                        statusBarColor: GlobalColors.appGreyBackgroundColor),
                  ),
                  // fontFamily: 'Lato',
                  fontFamily: 'Sans',
                  scrollbarTheme: const ScrollbarThemeData().copyWith(
                    thumbColor: WidgetStateProperty.all(GlobalColors.appColor1),
                  ),
                ),
                routerConfig: goRouter,
              );
            },
          ),
        );
      },
    );
  }
}
