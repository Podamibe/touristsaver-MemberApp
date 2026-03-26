import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'l10n_en.dart';
import 'l10n_ms.dart';
import 'l10n_ne.dart';
import 'l10n_th.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of S
/// returned by `S.of(context)`.
///
/// Applications need to include `S.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/l10n.dart';
///
/// return MaterialApp(
///   localizationsDelegates: S.localizationsDelegates,
///   supportedLocales: S.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the S.supportedLocales
/// property.
abstract class S {
  S(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static S of(BuildContext context) {
    return Localizations.of<S>(context, S)!;
  }

  static const LocalizationsDelegate<S> delegate = _SDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ms'),
    Locale('ne'),
    Locale('th')
  ];

  /// No description provided for @scanIssuerCode.
  ///
  /// In en, this message translates to:
  /// **'Scan Issuer Code'**
  String get scanIssuerCode;

  /// No description provided for @scanReferralCode.
  ///
  /// In en, this message translates to:
  /// **'Scan Referral Code'**
  String get scanReferralCode;

  /// No description provided for @rewardRerceivedDate.
  ///
  /// In en, this message translates to:
  /// **'Reward Rerceived Date'**
  String get rewardRerceivedDate;

  /// No description provided for @reward.
  ///
  /// In en, this message translates to:
  /// **'Reward'**
  String get reward;

  /// No description provided for @rewardScahemaType.
  ///
  /// In en, this message translates to:
  /// **'Reward/Scahema Type'**
  String get rewardScahemaType;

  /// No description provided for @schemaName.
  ///
  /// In en, this message translates to:
  /// **'Schema Name'**
  String get schemaName;

  /// No description provided for @sn.
  ///
  /// In en, this message translates to:
  /// **'S.N'**
  String get sn;

  /// No description provided for @noDataFound.
  ///
  /// In en, this message translates to:
  /// **'No Data Found'**
  String get noDataFound;

  /// No description provided for @rewards.
  ///
  /// In en, this message translates to:
  /// **'Rewards'**
  String get rewards;

  /// No description provided for @youDoNotHavePremiumCodeUsedHistoryToViewBetweenXTOY.
  ///
  /// In en, this message translates to:
  /// **'You do not have any Premium code use history to view between @X to @Y'**
  String get youDoNotHavePremiumCodeUsedHistoryToViewBetweenXTOY;

  /// No description provided for @noPremiumCodeHasBeenUsedYet.
  ///
  /// In en, this message translates to:
  /// **'No Premium code has been used yet'**
  String get noPremiumCodeHasBeenUsedYet;

  /// No description provided for @congratulationXTouristSaversHasBeenAddedToYourWallet.
  ///
  /// In en, this message translates to:
  /// **'Congratulations! &X TouristSavers has been added to your wallet'**
  String get congratulationXTouristSaversHasBeenAddedToYourWallet;

  /// No description provided for @premiumCodeUseHistory.
  ///
  /// In en, this message translates to:
  /// **'Premium Code Use History'**
  String get premiumCodeUseHistory;

  /// No description provided for @premiumCode.
  ///
  /// In en, this message translates to:
  /// **'Premium Code'**
  String get premiumCode;

  /// No description provided for @package.
  ///
  /// In en, this message translates to:
  /// **'Package'**
  String get package;

  /// No description provided for @receivedTouristSavers.
  ///
  /// In en, this message translates to:
  /// **'Received TouristSavers'**
  String get receivedTouristSavers;

  /// No description provided for @v3.
  ///
  /// In en, this message translates to:
  /// **'V3'**
  String get v3;

  /// No description provided for @noCharityFoundForPleaseTryAgain.
  ///
  /// In en, this message translates to:
  /// **'No charity found for &V. Please try again'**
  String get noCharityFoundForPleaseTryAgain;

  /// No description provided for @pleaseSelectCountryPrefix.
  ///
  /// In en, this message translates to:
  /// **'Please select country prefix'**
  String get pleaseSelectCountryPrefix;

  /// No description provided for @emailA.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailA;

  /// No description provided for @instagram.
  ///
  /// In en, this message translates to:
  /// **'Instagram'**
  String get instagram;

  /// No description provided for @facebook.
  ///
  /// In en, this message translates to:
  /// **'Facebook'**
  String get facebook;

  /// No description provided for @website.
  ///
  /// In en, this message translates to:
  /// **'Website'**
  String get website;

  /// No description provided for @areYouSureYouWantToChooseThisCharity.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to choose this charity?'**
  String get areYouSureYouWantToChooseThisCharity;

  /// No description provided for @chooseCharity.
  ///
  /// In en, this message translates to:
  /// **'Choose Charity'**
  String get chooseCharity;

  /// No description provided for @yourCharity.
  ///
  /// In en, this message translates to:
  /// **'Your Charity'**
  String get yourCharity;

  /// No description provided for @version2.
  ///
  /// In en, this message translates to:
  /// **'V2'**
  String get version2;

  /// No description provided for @from.
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get from;

  /// No description provided for @fromEveryTransactionCashGoesToYourNominatedCharity.
  ///
  /// In en, this message translates to:
  /// **'From every transaction, cash goes to your nominated charity'**
  String get fromEveryTransactionCashGoesToYourNominatedCharity;

  /// No description provided for @donateToCharity.
  ///
  /// In en, this message translates to:
  /// **'Donate to charity'**
  String get donateToCharity;

  /// No description provided for @shopAtTouristSaverMerchantsAndGetGreatOffers.
  ///
  /// In en, this message translates to:
  /// **'Shop at TouristSaver merchants and get great offers'**
  String get shopAtTouristSaverMerchantsAndGetGreatOffers;

  /// No description provided for @goShopping.
  ///
  /// In en, this message translates to:
  /// **'Go shopping'**
  String get goShopping;

  /// No description provided for @theMostInnovativeCommunityLifestyleProgramForYourEverydayShopping.
  ///
  /// In en, this message translates to:
  /// **'The most innovative Community Lifestyle Program for your everyday shopping'**
  String get theMostInnovativeCommunityLifestyleProgramForYourEverydayShopping;

  /// No description provided for @welcomeToTouristSaver.
  ///
  /// In en, this message translates to:
  /// **'Welcome to TouristSaver'**
  String get welcomeToTouristSaver;

  /// No description provided for @claimNow.
  ///
  /// In en, this message translates to:
  /// **'Claim Now'**
  String get claimNow;

  /// No description provided for @youHavenotClaimedYourUPFreeUniversalPiinksYet.
  ///
  /// In en, this message translates to:
  /// **'You haven\'t claimed your *UP free Universal Piinks yet'**
  String get youHavenotClaimedYourUPFreeUniversalPiinksYet;

  /// No description provided for @toShopAtTouristSaverMerchantsGetGreatDiscountsAndDonatToYourFavouriteCharityRegisterMembershipOrLogin.
  ///
  /// In en, this message translates to:
  /// **'To shop at TouristSaver merchants, get great discounts and donate to your favourite charity, register membership or login'**
  String
      get toShopAtTouristSaverMerchantsGetGreatDiscountsAndDonatToYourFavouriteCharityRegisterMembershipOrLogin;

  /// No description provided for @youreCurrentlyOfflineCheckYourConnectionAndTryAgain.
  ///
  /// In en, this message translates to:
  /// **'You\'re currently offline.\nCheck your connection and try again'**
  String get youreCurrentlyOfflineCheckYourConnectionAndTryAgain;

  /// No description provided for @pleaseSelectSMSvalidationType.
  ///
  /// In en, this message translates to:
  /// **'Please select service for SMS validation'**
  String get pleaseSelectSMSvalidationType;

  /// No description provided for @pleaseSelectPhonePrefix.
  ///
  /// In en, this message translates to:
  /// **'Please select phone prefix'**
  String get pleaseSelectPhonePrefix;

  /// No description provided for @pleaseFillConfirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Please fill confirm password'**
  String get pleaseFillConfirmPassword;

  /// No description provided for @pleaseSelectCountryFirstToSelectCharity.
  ///
  /// In en, this message translates to:
  /// **'Please select country first to select charity'**
  String get pleaseSelectCountryFirstToSelectCharity;

  /// No description provided for @selectCharity.
  ///
  /// In en, this message translates to:
  /// **'Select Charity'**
  String get selectCharity;

  /// No description provided for @refCode.
  ///
  /// In en, this message translates to:
  /// **'Referral Code from Your Family/Friends (optional)'**
  String get refCode;

  /// No description provided for @selectServiceForSMSValidation.
  ///
  /// In en, this message translates to:
  /// **'Select Service for SMS Validation*'**
  String get selectServiceForSMSValidation;

  /// No description provided for @noSmsTypeAvailable.
  ///
  /// In en, this message translates to:
  /// **'No Sms Type Available'**
  String get noSmsTypeAvailable;

  /// No description provided for @mobileNumberPrefixIsDifferentThanTheCountryYouHaveChosenPleaseChooseOneOfTheFollowingOptionForMobileNumberVerification.
  ///
  /// In en, this message translates to:
  /// **'Mobile Number prefix is different than the country you have chosen. Please choose one of the following option for Mobile Number Verification'**
  String
      get mobileNumberPrefixIsDifferentThanTheCountryYouHaveChosenPleaseChooseOneOfTheFollowingOptionForMobileNumberVerification;

  /// No description provided for @enterTheOtpThatHasBeenSentInYourMobileNumberOrWhatsApp.
  ///
  /// In en, this message translates to:
  /// **'Enter the OTP that has been sent to your *A number or email'**
  String get enterTheOtpThatHasBeenSentInYourMobileNumberOrWhatsApp;

  /// No description provided for @noTopupPacakgeAvailableForNow.
  ///
  /// In en, this message translates to:
  /// **'No top-up pacakge available for now'**
  String get noTopupPacakgeAvailableForNow;

  /// No description provided for @claimFreeTouristSavers.
  ///
  /// In en, this message translates to:
  /// **'Claim Free TouristSavers'**
  String get claimFreeTouristSavers;

  /// No description provided for @linkCopiedToClipboard.
  ///
  /// In en, this message translates to:
  /// **'Link copied to clipboard'**
  String get linkCopiedToClipboard;

  /// No description provided for @copyLink.
  ///
  /// In en, this message translates to:
  /// **'Copy Link'**
  String get copyLink;

  /// No description provided for @shareLink.
  ///
  /// In en, this message translates to:
  /// **'Share Link'**
  String get shareLink;

  /// No description provided for @shareThisQRToYourFriend.
  ///
  /// In en, this message translates to:
  /// **'Share this QR to your friends'**
  String get shareThisQRToYourFriend;

  /// No description provided for @referTouristSaverAppToYourFriendsAndEarnAUniversalTouristSaversAsTheyPerformTransactionEqualsToB.
  ///
  /// In en, this message translates to:
  /// **'Refer TouristSaver App to your friends and earn *A Universal TouristSavers as they perform transaction equals to *B'**
  String
      get referTouristSaverAppToYourFriendsAndEarnAUniversalTouristSaversAsTheyPerformTransactionEqualsToB;

  /// No description provided for @referTouristSaverAppToYourFriendsAndEarnPUniversalTouristSavers.
  ///
  /// In en, this message translates to:
  /// **'Refer TouristSaver App to your friends and earn *P Universal TouristSavers'**
  String get referTouristSaverAppToYourFriendsAndEarnPUniversalTouristSavers;

  /// No description provided for @referAFriend.
  ///
  /// In en, this message translates to:
  /// **'Refer a Friend'**
  String get referAFriend;

  /// No description provided for @selectThePhonePrefix.
  ///
  /// In en, this message translates to:
  /// **'Select the phone prefix'**
  String get selectThePhonePrefix;

  /// No description provided for @prefix.
  ///
  /// In en, this message translates to:
  /// **'Prefix*'**
  String get prefix;

  /// No description provided for @viewNearby.
  ///
  /// In en, this message translates to:
  /// **'View Nearby'**
  String get viewNearby;

  /// No description provided for @weWantToSetYourActualLocationToShowYouNearbyCharities.
  ///
  /// In en, this message translates to:
  /// **'We want to set your actual location to show you nearby charities'**
  String get weWantToSetYourActualLocationToShowYouNearbyCharities;

  /// No description provided for @nearbyCharities.
  ///
  /// In en, this message translates to:
  /// **'Nearby Charities'**
  String get nearbyCharities;

  /// No description provided for @searchNearByCharity.
  ///
  /// In en, this message translates to:
  /// **'Search nearby charity'**
  String get searchNearByCharity;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @freeTouristSaversClaimedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Free touristSavers claimed successfully'**
  String get freeTouristSaversClaimedSuccessfully;

  /// No description provided for @pleaseSearchByLocationOrSelectCategory.
  ///
  /// In en, this message translates to:
  /// **'Please search by location or select category'**
  String get pleaseSearchByLocationOrSelectCategory;

  /// No description provided for @searchByLocation.
  ///
  /// In en, this message translates to:
  /// **'Search By Location'**
  String get searchByLocation;

  /// No description provided for @chooseOnMap.
  ///
  /// In en, this message translates to:
  /// **'Choose On Map'**
  String get chooseOnMap;

  /// No description provided for @nearMe.
  ///
  /// In en, this message translates to:
  /// **'Near Me'**
  String get nearMe;

  /// No description provided for @selectCategory.
  ///
  /// In en, this message translates to:
  /// **'Select category'**
  String get selectCategory;

  /// No description provided for @searchByLocationCategory.
  ///
  /// In en, this message translates to:
  /// **'Search By Location/Category'**
  String get searchByLocationCategory;

  /// No description provided for @youAreNotLoggedIn.
  ///
  /// In en, this message translates to:
  /// **'You are not logged in'**
  String get youAreNotLoggedIn;

  /// No description provided for @usernameMustBeAtleastSixCharacters.
  ///
  /// In en, this message translates to:
  /// **'Username must be atleast 6 characters'**
  String get usernameMustBeAtleastSixCharacters;

  /// No description provided for @notificationsFromAtoB.
  ///
  /// In en, this message translates to:
  /// **'Notifications from\n &A to &B'**
  String get notificationsFromAtoB;

  /// No description provided for @withInVKm.
  ///
  /// In en, this message translates to:
  /// **'With in &V KM'**
  String get withInVKm;

  /// No description provided for @loadXTouristSavers.
  ///
  /// In en, this message translates to:
  /// **'Load &L TouristSavers'**
  String get loadXTouristSavers;

  /// No description provided for @touristSaversCreditAdded.
  ///
  /// In en, this message translates to:
  /// **'TouristSaver Credits Added'**
  String get touristSaversCreditAdded;

  /// No description provided for @congratulationNowYouHaveXTouristSavers.
  ///
  /// In en, this message translates to:
  /// **'Congratulations! You now have &X TouristSavers'**
  String get congratulationNowYouHaveXTouristSavers;

  /// No description provided for @topUpAndPayXY.
  ///
  /// In en, this message translates to:
  /// **'Top-up and Pay &XY'**
  String get topUpAndPayXY;

  /// No description provided for @iAgreeWithTheTermsAndCondition.
  ///
  /// In en, this message translates to:
  /// **'I agree with the &C'**
  String get iAgreeWithTheTermsAndCondition;

  /// No description provided for @weWillDeductCPiinksFromYourCredit.
  ///
  /// In en, this message translates to:
  /// **'We will deduct &C&X &CTouristSavers from Your Credit'**
  String get weWillDeductCPiinksFromYourCredit;

  /// No description provided for @noNotificationFrom.
  ///
  /// In en, this message translates to:
  /// **'No notifications from &S to &E'**
  String get noNotificationFrom;

  /// No description provided for @youDoNotHaveAnyTransactionHistoryToViewBetweenXTOY.
  ///
  /// In en, this message translates to:
  /// **'You do not have any Transaction history to view between &X to &Y'**
  String get youDoNotHaveAnyTransactionHistoryToViewBetweenXTOY;

  /// No description provided for @youDoNotHaveAnyTopUpHistoryToViewBetweenXTOY.
  ///
  /// In en, this message translates to:
  /// **'You do not have any TopUp history to view between @X to @Y'**
  String get youDoNotHaveAnyTopUpHistoryToViewBetweenXTOY;

  /// No description provided for @upToXdiscount.
  ///
  /// In en, this message translates to:
  /// **'upto &x% discount'**
  String get upToXdiscount;

  /// No description provided for @accept.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get accept;

  /// No description provided for @acceptToUseTouristSavers.
  ///
  /// In en, this message translates to:
  /// **'Accept to use TouristSavers'**
  String get acceptToUseTouristSavers;

  /// No description provided for @addReview.
  ///
  /// In en, this message translates to:
  /// **'Add Review'**
  String get addReview;

  /// No description provided for @additional.
  ///
  /// In en, this message translates to:
  /// **'Additional'**
  String get additional;

  /// No description provided for @additionalInformation.
  ///
  /// In en, this message translates to:
  /// **'Additional Information'**
  String get additionalInformation;

  /// No description provided for @agreeAndContinue.
  ///
  /// In en, this message translates to:
  /// **'Agree and Continue'**
  String get agreeAndContinue;

  /// No description provided for @allDay.
  ///
  /// In en, this message translates to:
  /// **'All Day'**
  String get allDay;

  /// No description provided for @anEmailVerificationWillBeSentAfterTheVerificationOfMobileOtpPleaseCheckYourEmail.
  ///
  /// In en, this message translates to:
  /// **'An email verification will be sent after the verification of Mobile OTP. Please check your email'**
  String
      get anEmailVerificationWillBeSentAfterTheVerificationOfMobileOtpPleaseCheckYourEmail;

  /// No description provided for @apply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get apply;

  /// No description provided for @applyPremiumCode.
  ///
  /// In en, this message translates to:
  /// **'Apply Premium Code'**
  String get applyPremiumCode;

  /// No description provided for @areYouSureYouWantToDeleteAllNotifications.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete all notifications?'**
  String get areYouSureYouWantToDeleteAllNotifications;

  /// No description provided for @areYouSureYouWantToLogOut.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to log out?'**
  String get areYouSureYouWantToLogOut;

  /// No description provided for @areYouSureYouWantToRemoveYourAccount.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to remove your account?'**
  String get areYouSureYouWantToRemoveYourAccount;

  /// No description provided for @availableUniversalTouristSavers.
  ///
  /// In en, this message translates to:
  /// **'Available Universal TouristSavers'**
  String get availableUniversalTouristSavers;

  /// No description provided for @away.
  ///
  /// In en, this message translates to:
  /// **' Away'**
  String get away;

  /// No description provided for @bestOffers.
  ///
  /// In en, this message translates to:
  /// **'Best Offers'**
  String get bestOffers;

  /// No description provided for @biometricAuthentication.
  ///
  /// In en, this message translates to:
  /// **'Biometric Authentication'**
  String get biometricAuthentication;

  /// No description provided for @biometricAuthenticationDisabledSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Biometric authentication disabled successfully'**
  String get biometricAuthenticationDisabledSuccessfully;

  /// No description provided for @biometricAuthenticationEnabledSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Biometric authentication enabled successfully'**
  String get biometricAuthenticationEnabledSuccessfully;

  /// No description provided for @biometrics.
  ///
  /// In en, this message translates to:
  /// **'Biometrics'**
  String get biometrics;

  /// No description provided for @buyXUniversalTouristSaverCredits.
  ///
  /// In en, this message translates to:
  /// **'Buy &X Universal TouristSaver Credits'**
  String get buyXUniversalTouristSaverCredits;

  /// No description provided for @byClicking.
  ///
  /// In en, this message translates to:
  /// **'By Clicking'**
  String get byClicking;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @cannotOpenFacebook.
  ///
  /// In en, this message translates to:
  /// **'Cannot open Facebook'**
  String get cannotOpenFacebook;

  /// No description provided for @cannotOpenInstagram.
  ///
  /// In en, this message translates to:
  /// **'Cannot open Instagram'**
  String get cannotOpenInstagram;

  /// No description provided for @cashFromEachTransaction.
  ///
  /// In en, this message translates to:
  /// **'Cash from each transaction will go to your selected charity'**
  String get cashFromEachTransaction;

  /// No description provided for @changeCountry.
  ///
  /// In en, this message translates to:
  /// **'Change Country'**
  String get changeCountry;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePassword;

  /// No description provided for @charity.
  ///
  /// In en, this message translates to:
  /// **'Charity'**
  String get charity;

  /// No description provided for @charityChanged.
  ///
  /// In en, this message translates to:
  /// **'Charity changed'**
  String get charityChanged;

  /// No description provided for @charityWithin.
  ///
  /// In en, this message translates to:
  /// **'Charity within'**
  String get charityWithin;

  /// No description provided for @chooseCountry.
  ///
  /// In en, this message translates to:
  /// **'Choose Country'**
  String get chooseCountry;

  /// No description provided for @chooseDate.
  ///
  /// In en, this message translates to:
  /// **'Choose Date'**
  String get chooseDate;

  /// No description provided for @chooseLanguage.
  ///
  /// In en, this message translates to:
  /// **'Choose Preferred Language'**
  String get chooseLanguage;

  /// No description provided for @chooseOne.
  ///
  /// In en, this message translates to:
  /// **'Choose One'**
  String get chooseOne;

  /// No description provided for @chooseWallet.
  ///
  /// In en, this message translates to:
  /// **'Choose Wallet'**
  String get chooseWallet;

  /// No description provided for @city.
  ///
  /// In en, this message translates to:
  /// **'City *'**
  String get city;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @comingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming Soon...'**
  String get comingSoon;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// No description provided for @confirmPasswordA.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password *'**
  String get confirmPasswordA;

  /// No description provided for @confirmPasswordDoesNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Confirm password does not match'**
  String get confirmPasswordDoesNotMatch;

  /// No description provided for @confirmWallet.
  ///
  /// In en, this message translates to:
  /// **'Confirm Wallet'**
  String get confirmWallet;

  /// No description provided for @congratulations.
  ///
  /// In en, this message translates to:
  /// **'Congratulations'**
  String get congratulations;

  /// No description provided for @congratulationsYouHaveSuccessfullyRegisteredUsingPremiumCodeNextYouCanEitherTopupOrAccountOrContinue.
  ///
  /// In en, this message translates to:
  /// **'Congratulations! You have successfully registered using premium code. Next, you can either topup or account or continue'**
  String
      get congratulationsYouHaveSuccessfullyRegisteredUsingPremiumCodeNextYouCanEitherTopupOrAccountOrContinue;

  /// No description provided for @contact.
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get contact;

  /// No description provided for @contactInfo.
  ///
  /// In en, this message translates to:
  /// **'Contact Info'**
  String get contactInfo;

  /// No description provided for @contactPersonFirstName.
  ///
  /// In en, this message translates to:
  /// **'Contact Person First Name *'**
  String get contactPersonFirstName;

  /// No description provided for @contactPersonLastName.
  ///
  /// In en, this message translates to:
  /// **'Contact Person Last Name *'**
  String get contactPersonLastName;

  /// No description provided for @continueL.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueL;

  /// No description provided for @continueWithDefaultTouristSaverCredits.
  ///
  /// In en, this message translates to:
  /// **'Continue with default TouristSaver credits'**
  String get continueWithDefaultTouristSaverCredits;

  /// No description provided for @continueWithoutTopUp.
  ///
  /// In en, this message translates to:
  /// **'Continue without Top-up'**
  String get continueWithoutTopUp;

  /// No description provided for @couldNotReceiveNotifications.
  ///
  /// In en, this message translates to:
  /// **'Could not receive notifications'**
  String get couldNotReceiveNotifications;

  /// No description provided for @couldnTDeleteTheAccount.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t delete the account'**
  String get couldnTDeleteTheAccount;

  /// No description provided for @couldnTFetchTheFavouriteData.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t fetch the favourite data'**
  String get couldnTFetchTheFavouriteData;

  /// No description provided for @couldnTRecommendMerchant.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t recommend merchant'**
  String get couldnTRecommendMerchant;

  /// No description provided for @couldnTResendOtp.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t resend OTP'**
  String get couldnTResendOtp;

  /// No description provided for @countryChangedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Country changed successfully'**
  String get countryChangedSuccessfully;

  /// No description provided for @creditRemaning.
  ///
  /// In en, this message translates to:
  /// **'Credit Remaning'**
  String get creditRemaning;

  /// No description provided for @currentPassword.
  ///
  /// In en, this message translates to:
  /// **'Current Password'**
  String get currentPassword;

  /// No description provided for @currentPasswordDoesNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Current password does not match'**
  String get currentPasswordDoesNotMatch;

  /// No description provided for @currentlyThereAreNoCharitiesAvailableForThisCountry.
  ///
  /// In en, this message translates to:
  /// **'Currently there are no charities available for this country'**
  String get currentlyThereAreNoCharitiesAvailableForThisCountry;

  /// No description provided for @currentlyThereAreNoCharitiesAvailableInYourLocation.
  ///
  /// In en, this message translates to:
  /// **'Currently there are no charities available in your location'**
  String get currentlyThereAreNoCharitiesAvailableInYourLocation;

  /// No description provided for @doYouWantToDisableBiometricLogin.
  ///
  /// In en, this message translates to:
  /// **'Do you want to disable biometric login?'**
  String get doYouWantToDisableBiometricLogin;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email *'**
  String get email;

  /// No description provided for @emailAnd.
  ///
  /// In en, this message translates to:
  /// **'email and'**
  String get emailAnd;

  /// No description provided for @emailNotVerified.
  ///
  /// In en, this message translates to:
  /// **'Email not verified  '**
  String get emailNotVerified;

  /// No description provided for @emailOrPhoneNumberAlreadyExists.
  ///
  /// In en, this message translates to:
  /// **'Email or phone number already exists'**
  String get emailOrPhoneNumberAlreadyExists;

  /// No description provided for @enableAccess.
  ///
  /// In en, this message translates to:
  /// **'Enable Access'**
  String get enableAccess;

  /// No description provided for @enterAmountOfTransaction.
  ///
  /// In en, this message translates to:
  /// **'Enter amount of transaction'**
  String get enterAmountOfTransaction;

  /// No description provided for @enterCodeManually.
  ///
  /// In en, this message translates to:
  /// **' enter code manually'**
  String get enterCodeManually;

  /// No description provided for @enterDetails.
  ///
  /// In en, this message translates to:
  /// **'Enter Details'**
  String get enterDetails;

  /// No description provided for @enterNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter new password'**
  String get enterNewPassword;

  /// No description provided for @enterOrScanIssuerCode.
  ///
  /// In en, this message translates to:
  /// **'Enter or scan Issuer Code'**
  String get enterOrScanIssuerCode;

  /// No description provided for @enterPremiumCode.
  ///
  /// In en, this message translates to:
  /// **'Enter Premium Code'**
  String get enterPremiumCode;

  /// No description provided for @enterTheMerchantTransactionCode.
  ///
  /// In en, this message translates to:
  /// **'Enter the Merchant Transaction Code'**
  String get enterTheMerchantTransactionCode;

  /// No description provided for @enterTheOtpThatHasBeenSentInYourEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter the OTP that has been sent in your email'**
  String get enterTheOtpThatHasBeenSentInYourEmail;

  /// No description provided for @enterTheOtpThatHasBeenSentInYourMobileNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter the OTP that has been sent in your mobile number'**
  String get enterTheOtpThatHasBeenSentInYourMobileNumber;

  /// No description provided for @enterValidCredentials.
  ///
  /// In en, this message translates to:
  /// **'Enter valid credentials'**
  String get enterValidCredentials;

  /// No description provided for @enterValidMobileNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter valid mobile number'**
  String get enterValidMobileNumber;

  /// No description provided for @enterValidPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter valid password'**
  String get enterValidPassword;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @errorInEditingProfile.
  ///
  /// In en, this message translates to:
  /// **'Error in editing profile'**
  String get errorInEditingProfile;

  /// No description provided for @errorResendingOtp.
  ///
  /// In en, this message translates to:
  /// **'Error resending OTP'**
  String get errorResendingOtp;

  /// No description provided for @favorite.
  ///
  /// In en, this message translates to:
  /// **'Favorite'**
  String get favorite;

  /// No description provided for @favouriteMerchants.
  ///
  /// In en, this message translates to:
  /// **'Favourite Merchants'**
  String get favouriteMerchants;

  /// No description provided for @filter.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get filter;

  /// No description provided for @finish.
  ///
  /// In en, this message translates to:
  /// **'Finish'**
  String get finish;

  /// No description provided for @firstName.
  ///
  /// In en, this message translates to:
  /// **'First Name *'**
  String get firstName;

  /// No description provided for @firstTryShoppingWithSomeMerchantsToGainAndTransferMerchantTouristSavers.
  ///
  /// In en, this message translates to:
  /// **'First try shopping with some merchants to gain and transfer Merchant TouristSavers'**
  String
      get firstTryShoppingWithSomeMerchantsToGainAndTransferMerchantTouristSavers;

  /// No description provided for @forRecommendingTheNewMerchantRegisterMembershipOrLogIn.
  ///
  /// In en, this message translates to:
  /// **'For recommending the new merchant register membership or log in'**
  String get forRecommendingTheNewMerchantRegisterMembershipOrLogIn;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// No description provided for @free.
  ///
  /// In en, this message translates to:
  /// **'Free'**
  String get free;

  /// No description provided for @friday.
  ///
  /// In en, this message translates to:
  /// **'Friday '**
  String get friday;

  /// No description provided for @getFree20UniversalFreeCredits.
  ///
  /// In en, this message translates to:
  /// **'Get Free 20 Universal Free Credits'**
  String get getFree20UniversalFreeCredits;

  /// No description provided for @groupMerchant.
  ///
  /// In en, this message translates to:
  /// **'Group Merchant'**
  String get groupMerchant;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @ifYouClickOnCancelYourMobileNumberWonTBeVerifiedAndOnlyTheOtherChangesWillBeDone.
  ///
  /// In en, this message translates to:
  /// **'If you click on cancel, your mobile number won\'t be verified and only the other changes will be done'**
  String
      get ifYouClickOnCancelYourMobileNumberWonTBeVerifiedAndOnlyTheOtherChangesWillBeDone;

  /// No description provided for @ifYourCameraIsNotWorkingProperly.
  ///
  /// In en, this message translates to:
  /// **'If your camera is not working properly '**
  String get ifYourCameraIsNotWorkingProperly;

  /// No description provided for @insufficientTouristSaverCredits.
  ///
  /// In en, this message translates to:
  /// **'Insufficient TouristSaver Credits'**
  String get insufficientTouristSaverCredits;

  /// No description provided for @invalidQrCode.
  ///
  /// In en, this message translates to:
  /// **'Invalid QR code'**
  String get invalidQrCode;

  /// No description provided for @issueInDeletingNotifications.
  ///
  /// In en, this message translates to:
  /// **'Issue in deleting notifications'**
  String get issueInDeletingNotifications;

  /// No description provided for @issuerCodeIsNotValid.
  ///
  /// In en, this message translates to:
  /// **'Issuer code is not valid'**
  String get issuerCodeIsNotValid;

  /// No description provided for @km.
  ///
  /// In en, this message translates to:
  /// **'KM'**
  String get km;

  /// No description provided for @lastName.
  ///
  /// In en, this message translates to:
  /// **'Last Name *'**
  String get lastName;

  /// No description provided for @linkYourFingerprintFaceForFasterLogin.
  ///
  /// In en, this message translates to:
  /// **'Link your fingerprint/face for faster login'**
  String get linkYourFingerprintFaceForFasterLogin;

  /// No description provided for @location.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get location;

  /// No description provided for @logIn.
  ///
  /// In en, this message translates to:
  /// **'Log In'**
  String get logIn;

  /// No description provided for @logOut.
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get logOut;

  /// No description provided for @mapView.
  ///
  /// In en, this message translates to:
  /// **'Map View'**
  String get mapView;

  /// No description provided for @membership.
  ///
  /// In en, this message translates to:
  /// **'Membership'**
  String get membership;

  /// No description provided for @merchant.
  ///
  /// In en, this message translates to:
  /// **'Merchant'**
  String get merchant;

  /// No description provided for @merchantAddedToFavorites.
  ///
  /// In en, this message translates to:
  /// **'Merchant added to favorites'**
  String get merchantAddedToFavorites;

  /// No description provided for @merchantCategories.
  ///
  /// In en, this message translates to:
  /// **'Merchant Categories'**
  String get merchantCategories;

  /// No description provided for @merchantCode.
  ///
  /// In en, this message translates to:
  /// **'Merchant Code'**
  String get merchantCode;

  /// No description provided for @merchantEmail.
  ///
  /// In en, this message translates to:
  /// **'Merchant Email *'**
  String get merchantEmail;

  /// No description provided for @merchantInfo.
  ///
  /// In en, this message translates to:
  /// **'Merchant Info'**
  String get merchantInfo;

  /// No description provided for @merchantName.
  ///
  /// In en, this message translates to:
  /// **'Merchant Name *'**
  String get merchantName;

  /// No description provided for @merchantNameP.
  ///
  /// In en, this message translates to:
  /// **'Merchant Name'**
  String get merchantNameP;

  /// No description provided for @merchantOffers.
  ///
  /// In en, this message translates to:
  /// **'Merchant Offers'**
  String get merchantOffers;

  /// No description provided for @merchantPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Merchant Phone Number *'**
  String get merchantPhoneNumber;

  /// No description provided for @merchantRecommendedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Merchant recommended successfully'**
  String get merchantRecommendedSuccessfully;

  /// No description provided for @merchantRemovedFromFavorites.
  ///
  /// In en, this message translates to:
  /// **'Merchant removed from favorites'**
  String get merchantRemovedFromFavorites;

  /// No description provided for @merchantWallet.
  ///
  /// In en, this message translates to:
  /// **'Merchant Wallet'**
  String get merchantWallet;

  /// No description provided for @merchants.
  ///
  /// In en, this message translates to:
  /// **'Merchants'**
  String get merchants;

  /// No description provided for @notAvailable.
  ///
  /// In en, this message translates to:
  /// **' not available'**
  String get notAvailable;

  /// No description provided for @mobNumWop.
  ///
  /// In en, this message translates to:
  /// **'Mobile number (without prefix) *'**
  String get mobNumWop;

  /// No description provided for @mobileNumber.
  ///
  /// In en, this message translates to:
  /// **'Mobile Number'**
  String get mobileNumber;

  /// No description provided for @mobileNumberA.
  ///
  /// In en, this message translates to:
  /// **'Mobile Number *'**
  String get mobileNumberA;

  /// No description provided for @mobileNumberDoesNotMatchWithYourChosenCountry.
  ///
  /// In en, this message translates to:
  /// **'Mobile number does not match with your chosen country'**
  String get mobileNumberDoesNotMatchWithYourChosenCountry;

  /// No description provided for @mobileNumberMustBeAtLeast7Digits.
  ///
  /// In en, this message translates to:
  /// **'Mobile number must be at least 7 digits'**
  String get mobileNumberMustBeAtLeast7Digits;

  /// No description provided for @mobileNumberVerification.
  ///
  /// In en, this message translates to:
  /// **'Mobile Number Verification'**
  String get mobileNumberVerification;

  /// No description provided for @monday.
  ///
  /// In en, this message translates to:
  /// **'Monday '**
  String get monday;

  /// No description provided for @moreOffers.
  ///
  /// In en, this message translates to:
  /// **'More Offers'**
  String get moreOffers;

  /// No description provided for @myMembership.
  ///
  /// In en, this message translates to:
  /// **'My Membership'**
  String get myMembership;

  /// No description provided for @myWallet.
  ///
  /// In en, this message translates to:
  /// **'My Wallet'**
  String get myWallet;

  /// No description provided for @nearbyCharity.
  ///
  /// In en, this message translates to:
  /// **'Nearby Charity'**
  String get nearbyCharity;

  /// No description provided for @nearbyMerchants.
  ///
  /// In en, this message translates to:
  /// **'Nearby Merchants'**
  String get nearbyMerchants;

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get newPassword;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @noAnyCountryOrStateOrRegion.
  ///
  /// In en, this message translates to:
  /// **'No any country or state or region'**
  String get noAnyCountryOrStateOrRegion;

  /// No description provided for @noBiometricFunction.
  ///
  /// In en, this message translates to:
  /// **'No biometric function'**
  String get noBiometricFunction;

  /// No description provided for @noCategoryFound.
  ///
  /// In en, this message translates to:
  /// **'No Category Found'**
  String get noCategoryFound;

  /// No description provided for @noCharityAvailable.
  ///
  /// In en, this message translates to:
  /// **'No Charity Available'**
  String get noCharityAvailable;

  /// No description provided for @noCharityFound.
  ///
  /// In en, this message translates to:
  /// **'No Charity Found'**
  String get noCharityFound;

  /// No description provided for @noDiscount.
  ///
  /// In en, this message translates to:
  /// **'No Discount'**
  String get noDiscount;

  /// No description provided for @noEmail.
  ///
  /// In en, this message translates to:
  /// **'No Email'**
  String get noEmail;

  /// No description provided for @noFacebookLink.
  ///
  /// In en, this message translates to:
  /// **'No Facebook link'**
  String get noFacebookLink;

  /// No description provided for @noInstagramLink.
  ///
  /// In en, this message translates to:
  /// **'No Instagram Link'**
  String get noInstagramLink;

  /// No description provided for @noMemberCode.
  ///
  /// In en, this message translates to:
  /// **'No Member Code'**
  String get noMemberCode;

  /// No description provided for @noMerchantAvailable.
  ///
  /// In en, this message translates to:
  /// **'No Merchant Available'**
  String get noMerchantAvailable;

  /// No description provided for @noMerchantCategory.
  ///
  /// In en, this message translates to:
  /// **'No Merchant Category'**
  String get noMerchantCategory;

  /// No description provided for @noMerchantDescription.
  ///
  /// In en, this message translates to:
  /// **'No Merchant Description'**
  String get noMerchantDescription;

  /// No description provided for @noMerchantFound.
  ///
  /// In en, this message translates to:
  /// **'No Merchant Found'**
  String get noMerchantFound;

  /// No description provided for @noMerchantIsAvailableRightNowWeWillKeepYouUpdated.
  ///
  /// In en, this message translates to:
  /// **'No merchant is available right now. We will keep you updated'**
  String get noMerchantIsAvailableRightNowWeWillKeepYouUpdated;

  /// No description provided for @noMerchantTouristSaverAvailable.
  ///
  /// In en, this message translates to:
  /// **'No Merchant TouristSaver Available'**
  String get noMerchantTouristSaverAvailable;

  /// No description provided for @noNumber.
  ///
  /// In en, this message translates to:
  /// **'No Number'**
  String get noNumber;

  /// No description provided for @noOpeningHours.
  ///
  /// In en, this message translates to:
  /// **'No Opening Hours'**
  String get noOpeningHours;

  /// No description provided for @noRegionAvailable.
  ///
  /// In en, this message translates to:
  /// **'No Region Available'**
  String get noRegionAvailable;

  /// No description provided for @noReviewsToShow.
  ///
  /// In en, this message translates to:
  /// **'No Reviews to Show'**
  String get noReviewsToShow;

  /// No description provided for @noSliderImageAdded.
  ///
  /// In en, this message translates to:
  /// **'No Slider Image Added'**
  String get noSliderImageAdded;

  /// No description provided for @noStateAvailable.
  ///
  /// In en, this message translates to:
  /// **'No State Available'**
  String get noStateAvailable;

  /// No description provided for @noThanks.
  ///
  /// In en, this message translates to:
  /// **'No thanks'**
  String get noThanks;

  /// No description provided for @noTopUpAvailable.
  ///
  /// In en, this message translates to:
  /// **'No Top-up available'**
  String get noTopUpAvailable;

  /// No description provided for @noTopUpHasBeenDoneYet.
  ///
  /// In en, this message translates to:
  /// **'No Top Up has been done yet'**
  String get noTopUpHasBeenDoneYet;

  /// No description provided for @noTransactionHasBeenCompletedYet.
  ///
  /// In en, this message translates to:
  /// **'No transaction data is available'**
  String get noTransactionHasBeenCompletedYet;

  /// No description provided for @noTransactionsBetween.
  ///
  /// In en, this message translates to:
  /// **'You do not have any transactions between'**
  String get noTransactionsBetween;

  /// No description provided for @noWebsiteLink.
  ///
  /// In en, this message translates to:
  /// **'No Website Link'**
  String get noWebsiteLink;

  /// No description provided for @notEnoughTouristSaverCredits.
  ///
  /// In en, this message translates to:
  /// **'Not enough TouristSaver credits'**
  String get notEnoughTouristSaverCredits;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @notificationsDeletedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Notifications deleted successfully'**
  String get notificationsDeletedSuccessfully;

  /// No description provided for @numberOfTouristSaversToBeTransferred.
  ///
  /// In en, this message translates to:
  /// **'Number of TouristSavers to be transferred'**
  String get numberOfTouristSaversToBeTransferred;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'Ok'**
  String get ok;

  /// No description provided for @oops.
  ///
  /// In en, this message translates to:
  /// **'Oops!!'**
  String get oops;

  /// No description provided for @openingHours.
  ///
  /// In en, this message translates to:
  /// **'Opening Hours'**
  String get openingHours;

  /// No description provided for @or.
  ///
  /// In en, this message translates to:
  /// **'OR'**
  String get or;

  /// No description provided for @otp.
  ///
  /// In en, this message translates to:
  /// **'OTP'**
  String get otp;

  /// No description provided for @otpHasBeenSentToYour.
  ///
  /// In en, this message translates to:
  /// **'OTP has been sent to your'**
  String get otpHasBeenSentToYour;

  /// No description provided for @otpIsNotValidOrServerError.
  ///
  /// In en, this message translates to:
  /// **'OTP is not valid or Server Error'**
  String get otpIsNotValidOrServerError;

  /// No description provided for @otpSentSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'OTP sent successfully'**
  String get otpSentSuccessfully;

  /// No description provided for @partOfOurMission.
  ///
  /// In en, this message translates to:
  /// **'Part of our mission is to \"perpetually contribute back to society and make a difference to the lives of others\"'**
  String get partOfOurMission;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @passwordA.
  ///
  /// In en, this message translates to:
  /// **'Password *'**
  String get passwordA;

  /// No description provided for @passwordChangedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Password changed successfully'**
  String get passwordChangedSuccessfully;

  /// No description provided for @passwordNoMatch.
  ///
  /// In en, this message translates to:
  /// **'Confirm password does not match'**
  String get passwordNoMatch;

  /// No description provided for @passwordsAreSame.
  ///
  /// In en, this message translates to:
  /// **'Current password and new password are same'**
  String get passwordsAreSame;

  /// No description provided for @pay.
  ///
  /// In en, this message translates to:
  /// **'Pay'**
  String get pay;

  /// No description provided for @paymentFailed.
  ///
  /// In en, this message translates to:
  /// **'Payment failed'**
  String get paymentFailed;

  /// No description provided for @paymentSuccessful.
  ///
  /// In en, this message translates to:
  /// **'Payment successful'**
  String get paymentSuccessful;

  /// No description provided for @phoneNum.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNum;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone Number *'**
  String get phoneNumber;

  /// No description provided for @phoneNumberShouldBeAtLeast7Digits.
  ///
  /// In en, this message translates to:
  /// **'Phone number should be at least 7 digits'**
  String get phoneNumberShouldBeAtLeast7Digits;

  /// No description provided for @touristSaverCredits.
  ///
  /// In en, this message translates to:
  /// **' TouristSaver Credits'**
  String get touristSaverCredits;

  /// No description provided for @touristSaverCreditsInfo.
  ///
  /// In en, this message translates to:
  /// **'TouristSaver Credits Info'**
  String get touristSaverCreditsInfo;

  /// No description provided for @touristSaverCreditsInfoD.
  ///
  /// In en, this message translates to:
  /// **'Universal TouristSaver Credits allow you to get a discount with any of our Merchants. Every time you use TouristSaver you will receive Merchant TouristSaver credits to spend back with the issuing Merchant'**
  String get touristSaverCreditsInfoD;

  /// No description provided for @touristSaverTransferredSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'TouristSavers transferred successfully'**
  String get touristSaverTransferredSuccessfully;

  /// No description provided for @touristSavers.
  ///
  /// In en, this message translates to:
  /// **'TouristSavers'**
  String get touristSavers;

  /// No description provided for @touristSaversLoaded.
  ///
  /// In en, this message translates to:
  /// **'TouristSavers Loaded'**
  String get touristSaversLoaded;

  /// No description provided for @touristSaversOnHold.
  ///
  /// In en, this message translates to:
  /// **'TouristSavers On Hold'**
  String get touristSaversOnHold;

  /// No description provided for @pleaseAcceptTermsConditions.
  ///
  /// In en, this message translates to:
  /// **'Please Accept Terms & Conditions'**
  String get pleaseAcceptTermsConditions;

  /// No description provided for @pleaseAuthenticateToSignIn.
  ///
  /// In en, this message translates to:
  /// **'Please authenticate to sign in'**
  String get pleaseAuthenticateToSignIn;

  /// No description provided for @pleaseEnterCity.
  ///
  /// In en, this message translates to:
  /// **'Please enter city'**
  String get pleaseEnterCity;

  /// No description provided for @pleaseEnterContactPersonFirstName.
  ///
  /// In en, this message translates to:
  /// **'Please enter contact person first name'**
  String get pleaseEnterContactPersonFirstName;

  /// No description provided for @pleaseEnterContactPersonLastName.
  ///
  /// In en, this message translates to:
  /// **'Please enter contact person last name'**
  String get pleaseEnterContactPersonLastName;

  /// No description provided for @pleaseEnterCorrectMobileNumber.
  ///
  /// In en, this message translates to:
  /// **'Please enter correct mobile number'**
  String get pleaseEnterCorrectMobileNumber;

  /// No description provided for @pleaseEnterCurrentPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter current password'**
  String get pleaseEnterCurrentPassword;

  /// No description provided for @pleaseEnterIssuerCodeToUsePremiumCode.
  ///
  /// In en, this message translates to:
  /// **'Please enter issuer code to use premium code'**
  String get pleaseEnterIssuerCodeToUsePremiumCode;

  /// No description provided for @pleaseEnterMerchantName.
  ///
  /// In en, this message translates to:
  /// **'Please enter merchant name'**
  String get pleaseEnterMerchantName;

  /// No description provided for @pleaseEnterMerchantNumber.
  ///
  /// In en, this message translates to:
  /// **'Please enter merchant number'**
  String get pleaseEnterMerchantNumber;

  /// No description provided for @pleaseEnterMobileNumber.
  ///
  /// In en, this message translates to:
  /// **'Please enter mobile number'**
  String get pleaseEnterMobileNumber;

  /// No description provided for @pleaseEnterNumberOfTouristSaversToBeTransferred.
  ///
  /// In en, this message translates to:
  /// **'Please enter number of TouristSavers to be transferred'**
  String get pleaseEnterNumberOfTouristSaversToBeTransferred;

  /// No description provided for @pleaseEnterPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter password'**
  String get pleaseEnterPassword;

  /// No description provided for @pleaseEnterPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Please enter phone number'**
  String get pleaseEnterPhoneNumber;

  /// No description provided for @pleaseEnterTheCode.
  ///
  /// In en, this message translates to:
  /// **'Please enter the code'**
  String get pleaseEnterTheCode;

  /// No description provided for @pleaseEnterThePremiumCode.
  ///
  /// In en, this message translates to:
  /// **'Please enter the premium code'**
  String get pleaseEnterThePremiumCode;

  /// No description provided for @pleaseEnterTheRightAmount.
  ///
  /// In en, this message translates to:
  /// **'Please enter the right amount'**
  String get pleaseEnterTheRightAmount;

  /// No description provided for @pleaseEnterUsername.
  ///
  /// In en, this message translates to:
  /// **'Please enter username'**
  String get pleaseEnterUsername;

  /// No description provided for @pleaseEnterValidEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter valid email'**
  String get pleaseEnterValidEmail;

  /// No description provided for @pleaseEnterValidMerchantEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter valid merchant email'**
  String get pleaseEnterValidMerchantEmail;

  /// No description provided for @pleaseEnterValidNumberOfTouristSaversToBeTransferred.
  ///
  /// In en, this message translates to:
  /// **'Please enter valid number of TouristSavers to be transferred'**
  String get pleaseEnterValidNumberOfTouristSaversToBeTransferred;

  /// No description provided for @pleaseFillCorrectMobileNumber.
  ///
  /// In en, this message translates to:
  /// **'Please fill correct mobile number'**
  String get pleaseFillCorrectMobileNumber;

  /// No description provided for @pleaseFillFirstName.
  ///
  /// In en, this message translates to:
  /// **'Please fill first name'**
  String get pleaseFillFirstName;

  /// No description provided for @pleaseFillLastName.
  ///
  /// In en, this message translates to:
  /// **'Please fill last name'**
  String get pleaseFillLastName;

  /// No description provided for @pleaseFillPostalCodeWith4Digits.
  ///
  /// In en, this message translates to:
  /// **'Please fill postal code with 4 digits'**
  String get pleaseFillPostalCodeWith4Digits;

  /// No description provided for @pleaseFillTheCorrectEmail.
  ///
  /// In en, this message translates to:
  /// **'Please fill the correct email'**
  String get pleaseFillTheCorrectEmail;

  /// No description provided for @pleaseFillTheOTPField.
  ///
  /// In en, this message translates to:
  /// **'Please fill the OTP field'**
  String get pleaseFillTheOTPField;

  /// No description provided for @pleaseFillThePassword.
  ///
  /// In en, this message translates to:
  /// **'Please fill the password'**
  String get pleaseFillThePassword;

  /// No description provided for @pleaseFillThePhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Please fill the phone number'**
  String get pleaseFillThePhoneNumber;

  /// No description provided for @pleasePayMerchant.
  ///
  /// In en, this message translates to:
  /// **'Please Pay Merchant'**
  String get pleasePayMerchant;

  /// No description provided for @pleaseRateThisMerchantOrProvideFeedback.
  ///
  /// In en, this message translates to:
  /// **'Please rate this merchant or provide feedback'**
  String get pleaseRateThisMerchantOrProvideFeedback;

  /// No description provided for @pleaseSelectMerchant.
  ///
  /// In en, this message translates to:
  /// **'Please select merchant'**
  String get pleaseSelectMerchant;

  /// No description provided for @pleaseSelectCountry.
  ///
  /// In en, this message translates to:
  /// **'Please select country'**
  String get pleaseSelectCountry;

  /// No description provided for @pleaseSelectTheState.
  ///
  /// In en, this message translates to:
  /// **'Please select state'**
  String get pleaseSelectTheState;

  /// No description provided for @pleaseTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Please try again'**
  String get pleaseTryAgain;

  /// No description provided for @pleaseWait.
  ///
  /// In en, this message translates to:
  /// **'Please Wait'**
  String get pleaseWait;

  /// No description provided for @pleaseWaitD.
  ///
  /// In en, this message translates to:
  /// **'Please Wait...'**
  String get pleaseWaitD;

  /// No description provided for @popularMerchants.
  ///
  /// In en, this message translates to:
  /// **'Popular Merchants'**
  String get popularMerchants;

  /// No description provided for @postalCodeShouldBeGreaterThan4Digits.
  ///
  /// In en, this message translates to:
  /// **'Postal code should be greater than 4 digits'**
  String get postalCodeShouldBeGreaterThan4Digits;

  /// No description provided for @postalZipCode.
  ///
  /// In en, this message translates to:
  /// **'Postal/Zip Code'**
  String get postalZipCode;

  /// No description provided for @preCode.
  ///
  /// In en, this message translates to:
  /// **'Premium Code (optional)'**
  String get preCode;

  /// No description provided for @premiumCodeIsNotValid.
  ///
  /// In en, this message translates to:
  /// **'Premium code is not valid'**
  String get premiumCodeIsNotValid;

  /// No description provided for @pressBackButtonAgainToExit.
  ///
  /// In en, this message translates to:
  /// **'Press back button again to exit'**
  String get pressBackButtonAgainToExit;

  /// No description provided for @proceed.
  ///
  /// In en, this message translates to:
  /// **'Proceed'**
  String get proceed;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @profileUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Profile updated successfully'**
  String get profileUpdatedSuccessfully;

  /// No description provided for @accountDeletedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Account deleted successfully'**
  String get accountDeletedSuccessfully;

  /// No description provided for @rateThisMerchant.
  ///
  /// In en, this message translates to:
  /// **'Rate this Merchant'**
  String get rateThisMerchant;

  /// No description provided for @rebate.
  ///
  /// In en, this message translates to:
  /// **'Rebate: '**
  String get rebate;

  /// No description provided for @recommend.
  ///
  /// In en, this message translates to:
  /// **'Recommend'**
  String get recommend;

  /// No description provided for @recommendNewMerchant.
  ///
  /// In en, this message translates to:
  /// **'Recommend New Merchant'**
  String get recommendNewMerchant;

  /// No description provided for @registerNow.
  ///
  /// In en, this message translates to:
  /// **'Register Now'**
  String get registerNow;

  /// No description provided for @registerYourMembershipNowAndEnjoyOurAmazingOffers.
  ///
  /// In en, this message translates to:
  /// **'Register your membership now and enjoy our amazing offers'**
  String get registerYourMembershipNowAndEnjoyOurAmazingOffers;

  /// No description provided for @registerYourMembershipOrLogInToAccessTheTouristSaverBenefitsAndViewYourProfileDetails.
  ///
  /// In en, this message translates to:
  /// **'Register your membership or log in to access the TouristSaver benefits and view your profile details'**
  String
      get registerYourMembershipOrLogInToAccessTheTouristSaverBenefitsAndViewYourProfileDetails;

  /// No description provided for @registration.
  ///
  /// In en, this message translates to:
  /// **'Registration'**
  String get registration;

  /// No description provided for @registrationCompleted.
  ///
  /// In en, this message translates to:
  /// **'Registration Completed'**
  String get registrationCompleted;

  /// No description provided for @regular.
  ///
  /// In en, this message translates to:
  /// **'Regular'**
  String get regular;

  /// No description provided for @removeAccount.
  ///
  /// In en, this message translates to:
  /// **'Remove Account'**
  String get removeAccount;

  /// No description provided for @resendOtp.
  ///
  /// In en, this message translates to:
  /// **'Resend OTP'**
  String get resendOtp;

  /// No description provided for @resetPassword.
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get resetPassword;

  /// No description provided for @reviewAddedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Review added successfully'**
  String get reviewAddedSuccessfully;

  /// No description provided for @reviews.
  ///
  /// In en, this message translates to:
  /// **'Reviews'**
  String get reviews;

  /// No description provided for @saturday.
  ///
  /// In en, this message translates to:
  /// **'Saturday '**
  String get saturday;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @savingApproved.
  ///
  /// In en, this message translates to:
  /// **'Saving Approved'**
  String get savingApproved;

  /// No description provided for @scan.
  ///
  /// In en, this message translates to:
  /// **'Scan'**
  String get scan;

  /// No description provided for @scanMerchantPaymentCode.
  ///
  /// In en, this message translates to:
  /// **'Scan Merchant Payment Code'**
  String get scanMerchantPaymentCode;

  /// No description provided for @scanReceiverMemberQr.
  ///
  /// In en, this message translates to:
  /// **'Scan Receiver Member QR'**
  String get scanReceiverMemberQr;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @searchForMerchantsCategoryLocation.
  ///
  /// In en, this message translates to:
  /// **'Search for merchants/category/location'**
  String get searchForMerchantsCategoryLocation;

  /// No description provided for @searchMerchantWallet.
  ///
  /// In en, this message translates to:
  /// **'Search merchant Wallet'**
  String get searchMerchantWallet;

  /// No description provided for @searchOrChooseCountryStateRegionFromTheListBelowToFilterOffersAndMerchants.
  ///
  /// In en, this message translates to:
  /// **'Search or choose country/state/region from the list below to filter offers and Merchants'**
  String
      get searchOrChooseCountryStateRegionFromTheListBelowToFilterOffersAndMerchants;

  /// No description provided for @searchWithinCountry.
  ///
  /// In en, this message translates to:
  /// **'Search within country'**
  String get searchWithinCountry;

  /// No description provided for @seeLess.
  ///
  /// In en, this message translates to:
  /// **'See Less'**
  String get seeLess;

  /// No description provided for @seeMore.
  ///
  /// In en, this message translates to:
  /// **'See More'**
  String get seeMore;

  /// No description provided for @selectCountryA.
  ///
  /// In en, this message translates to:
  /// **'Select Country Prefix*'**
  String get selectCountryA;

  /// No description provided for @selectDateFrom.
  ///
  /// In en, this message translates to:
  /// **'Select Date From'**
  String get selectDateFrom;

  /// No description provided for @selectDateTo.
  ///
  /// In en, this message translates to:
  /// **'Select Date To'**
  String get selectDateTo;

  /// No description provided for @selectMerchantTouristSavers.
  ///
  /// In en, this message translates to:
  /// **'Select Merchant TouristSavers'**
  String get selectMerchantTouristSavers;

  /// No description provided for @selectStateProvince.
  ///
  /// In en, this message translates to:
  /// **'Select State/Province *'**
  String get selectStateProvince;

  /// No description provided for @selectTheCountry.
  ///
  /// In en, this message translates to:
  /// **'Please select the country'**
  String get selectTheCountry;

  /// No description provided for @selectTheState.
  ///
  /// In en, this message translates to:
  /// **'Select the state'**
  String get selectTheState;

  /// No description provided for @send.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get send;

  /// No description provided for @sendOtp.
  ///
  /// In en, this message translates to:
  /// **'Send OTP'**
  String get sendOtp;

  /// No description provided for @sendReview.
  ///
  /// In en, this message translates to:
  /// **'Send Review'**
  String get sendReview;

  /// No description provided for @serverError.
  ///
  /// In en, this message translates to:
  /// **'Server Error'**
  String get serverError;

  /// No description provided for @sessionExpired.
  ///
  /// In en, this message translates to:
  /// **'Session expired'**
  String get sessionExpired;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @someErrorOccurred.
  ///
  /// In en, this message translates to:
  /// **'Some error occurred'**
  String get someErrorOccurred;

  /// No description provided for @somethingWentWrong.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get somethingWentWrong;

  /// No description provided for @somethingWentWrongCouldnTFetchCountryCurrencyWhenLoggingIn.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Couldn\'t fetch country currency when logging in'**
  String get somethingWentWrongCouldnTFetchCountryCurrencyWhenLoggingIn;

  /// No description provided for @somethingWentWrongCouldnTFetchMemberOriginCountryIdAndMemberIdWhenLoggingIn.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Couldn\'t fetch member origin country id and member id when logging in'**
  String
      get somethingWentWrongCouldnTFetchMemberOriginCountryIdAndMemberIdWhenLoggingIn;

  /// No description provided for @somethingWentWrongCouldnTFetchTheStripeKeyToCompleteTheRegistrationProcess.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Couldn\'t fetch the stripe key to complete the registration process'**
  String
      get somethingWentWrongCouldnTFetchTheStripeKeyToCompleteTheRegistrationProcess;

  /// No description provided for @somethingWentWrongCouldnTFetchTheStripeKeyWhenChangingCountry.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Couldn\'t fetch the stripe key when changing country'**
  String get somethingWentWrongCouldnTFetchTheStripeKeyWhenChangingCountry;

  /// No description provided for @somethingWentWrongCouldnTFetchTheStripeKeyWhenLoggingIn.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Couldn\'t fetch the stripe key when logging in'**
  String get somethingWentWrongCouldnTFetchTheStripeKeyWhenLoggingIn;

  /// No description provided for @somethingWentWrongPleaseTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again'**
  String get somethingWentWrongPleaseTryAgain;

  /// No description provided for @somethingWentWrongWhenValidatingPremiumCodePleaseTryAgainLater.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong when validating premium code. Please Try Again Later'**
  String get somethingWentWrongWhenValidatingPremiumCodePleaseTryAgainLater;

  /// No description provided for @sortByAlphabetical.
  ///
  /// In en, this message translates to:
  /// **'Sort by Alphabetical'**
  String get sortByAlphabetical;

  /// No description provided for @sortByTouristSaverCredits.
  ///
  /// In en, this message translates to:
  /// **'Sort by TouristSaver Credits'**
  String get sortByTouristSaverCredits;

  /// No description provided for @stripePaymentFail.
  ///
  /// In en, this message translates to:
  /// **'Stripe Payment Fail'**
  String get stripePaymentFail;

  /// No description provided for @submit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submit;

  /// No description provided for @sunday.
  ///
  /// In en, this message translates to:
  /// **'Sunday '**
  String get sunday;

  /// No description provided for @sureVerifyYourEmail.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to verify your email?'**
  String get sureVerifyYourEmail;

  /// No description provided for @termsAndConditions.
  ///
  /// In en, this message translates to:
  /// **'Terms and Conditions'**
  String get termsAndConditions;

  /// No description provided for @termsConditions.
  ///
  /// In en, this message translates to:
  /// **'Terms & Conditions'**
  String get termsConditions;

  /// No description provided for @theChangeOfLocationInThisScreenOnlyChangesTheDisplayOfMerchantDataForChangingYourRegisteredLocationYouNeedToNavigateToTheChangeCountryAndChangeItRespectively.
  ///
  /// In en, this message translates to:
  /// **'The change of location in this screen only changes the display of merchant data. For changing your registered location you need to navigate to the \'Change Country\' and change it respectively'**
  String
      get theChangeOfLocationInThisScreenOnlyChangesTheDisplayOfMerchantDataForChangingYourRegisteredLocationYouNeedToNavigateToTheChangeCountryAndChangeItRespectively;

  /// No description provided for @thePaymentHasBeenCanceled.
  ///
  /// In en, this message translates to:
  /// **'The payment has been canceled'**
  String get thePaymentHasBeenCanceled;

  /// No description provided for @thursday.
  ///
  /// In en, this message translates to:
  /// **'Thursday '**
  String get thursday;

  /// No description provided for @toChangeCountryRegisterMembershipOrLogIn.
  ///
  /// In en, this message translates to:
  /// **'To change country register membership or log in'**
  String get toChangeCountryRegisterMembershipOrLogIn;

  /// No description provided for @toChooseCharityRegisterMembershipOrLogIn.
  ///
  /// In en, this message translates to:
  /// **'To choose charity register membership or log in'**
  String get toChooseCharityRegisterMembershipOrLogIn;

  /// No description provided for @to.
  ///
  /// In en, this message translates to:
  /// **' To '**
  String get to;

  /// No description provided for @toTransferTouristSaversRegisterMembershipOrLogIn.
  ///
  /// In en, this message translates to:
  /// **'To transfer TouristSavers register membership or log in'**
  String get toTransferTouristSaversRegisterMembershipOrLogIn;

  /// No description provided for @toUseTopUpFunctionRegisterMembershipOrLogIn.
  ///
  /// In en, this message translates to:
  /// **'To use top-up function register membership or log in'**
  String get toUseTopUpFunctionRegisterMembershipOrLogIn;

  /// No description provided for @toViewTheTransactionHistoryRegisterMembershipOrLogIn.
  ///
  /// In en, this message translates to:
  /// **'To view the transaction history register membership or log in'**
  String get toViewTheTransactionHistoryRegisterMembershipOrLogIn;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @topUp.
  ///
  /// In en, this message translates to:
  /// **'Top-up'**
  String get topUp;

  /// No description provided for @topUpAmount.
  ///
  /// In en, this message translates to:
  /// **'Top Up Amount'**
  String get topUpAmount;

  /// No description provided for @topUpHistory.
  ///
  /// In en, this message translates to:
  /// **'Top Up History'**
  String get topUpHistory;

  /// No description provided for @topUpUniversalTouristSaverCredits.
  ///
  /// In en, this message translates to:
  /// **'Top-up Universal TouristSaver Credits'**
  String get topUpUniversalTouristSaverCredits;

  /// No description provided for @topUpUniversalTouristSaverCreditsToGetDiscountWithAnyOfOurMerchant.
  ///
  /// In en, this message translates to:
  /// **'Top-up Universal TouristSaver Credits to get discount with any of our merchant'**
  String get topUpUniversalTouristSaverCreditsToGetDiscountWithAnyOfOurMerchant;

  /// No description provided for @topUpYourUniversalTouristSaversToGainExtraCreditAndEnjoyMoreOffersFromYourFavouriteMerchants.
  ///
  /// In en, this message translates to:
  /// **'Top-up your Universal TouristSavers to gain extra credit and enjoy more offers from your favourite merchants'**
  String
      get topUpYourUniversalTouristSaversToGainExtraCreditAndEnjoyMoreOffersFromYourFavouriteMerchants;

  /// No description provided for @transactionCode.
  ///
  /// In en, this message translates to:
  /// **'Transaction Code*'**
  String get transactionCode;

  /// No description provided for @transactionCompleted.
  ///
  /// In en, this message translates to:
  /// **'Transaction Completed'**
  String get transactionCompleted;

  /// No description provided for @transactionHistory.
  ///
  /// In en, this message translates to:
  /// **'Transaction History'**
  String get transactionHistory;

  /// No description provided for @transactionId.
  ///
  /// In en, this message translates to:
  /// **'Transaction ID '**
  String get transactionId;

  /// No description provided for @transferTouristSavers.
  ///
  /// In en, this message translates to:
  /// **'Transfer TouristSavers'**
  String get transferTouristSavers;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get tryAgain;

  /// No description provided for @tuesday.
  ///
  /// In en, this message translates to:
  /// **'Tuesday '**
  String get tuesday;

  /// No description provided for @universal.
  ///
  /// In en, this message translates to:
  /// **'Universal'**
  String get universal;

  /// No description provided for @universalWallet.
  ///
  /// In en, this message translates to:
  /// **'Universal Wallet'**
  String get universalWallet;

  /// No description provided for @update.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get update;

  /// No description provided for @updatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Updated successfully'**
  String get updatedSuccessfully;

  /// No description provided for @useBiometrics.
  ///
  /// In en, this message translates to:
  /// **'Use Biometrics'**
  String get useBiometrics;

  /// No description provided for @userReviews.
  ///
  /// In en, this message translates to:
  /// **'User Reviews'**
  String get userReviews;

  /// No description provided for @username.
  ///
  /// In en, this message translates to:
  /// **'Username *'**
  String get username;

  /// No description provided for @verficationFailedTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Verfication failed! Try again'**
  String get verficationFailedTryAgain;

  /// No description provided for @verificationLinkSentSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Verification link sent successfully'**
  String get verificationLinkSentSuccessfully;

  /// No description provided for @verify.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get verify;

  /// No description provided for @verifyEmail.
  ///
  /// In en, this message translates to:
  /// **'Verify Email'**
  String get verifyEmail;

  /// No description provided for @verifyMobileNumber.
  ///
  /// In en, this message translates to:
  /// **'Verify Mobile Number'**
  String get verifyMobileNumber;

  /// No description provided for @verifyNow.
  ///
  /// In en, this message translates to:
  /// **'Verify Now'**
  String get verifyNow;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get viewAll;

  /// No description provided for @viewOpeningHours.
  ///
  /// In en, this message translates to:
  /// **'View Opening Hours'**
  String get viewOpeningHours;

  /// No description provided for @wallet.
  ///
  /// In en, this message translates to:
  /// **'Wallet'**
  String get wallet;

  /// No description provided for @weAreCurrentlyWorkingOnThisWeWillKeepYouUpdated.
  ///
  /// In en, this message translates to:
  /// **'We are currently working on this. We will keep you updated'**
  String get weAreCurrentlyWorkingOnThisWeWillKeepYouUpdated;

  /// No description provided for @weWantToSetYourActualLocationToShowYouTheBestOffersNearby.
  ///
  /// In en, this message translates to:
  /// **'We want to set your actual location to show you the best offers nearby'**
  String get weWantToSetYourActualLocationToShowYouTheBestOffersNearby;

  /// No description provided for @weWantToSetYourActualLocationToShowYouTheMerchantsNearby.
  ///
  /// In en, this message translates to:
  /// **'We want to set your actual location to show you the merchants nearby'**
  String get weWantToSetYourActualLocationToShowYouTheMerchantsNearby;

  /// No description provided for @weWantToSetYourActualLocationToShowYouThePopularMerchantsNearby.
  ///
  /// In en, this message translates to:
  /// **'We want to set your actual location to show you the popular merchants nearby'**
  String get weWantToSetYourActualLocationToShowYouThePopularMerchantsNearby;

  /// No description provided for @wednesday.
  ///
  /// In en, this message translates to:
  /// **'Wednesday '**
  String get wednesday;

  /// No description provided for @whatAreYouLookingFor.
  ///
  /// In en, this message translates to:
  /// **'What are you looking for?'**
  String get whatAreYouLookingFor;

  /// No description provided for @withThisMerchant.
  ///
  /// In en, this message translates to:
  /// **'with this merchant'**
  String get withThisMerchant;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// No description provided for @youDonTHaveAnyTouristSaverUniversalCreditRegisterYourMembershipOrLogInToAccessTheTouristSaverBenefits.
  ///
  /// In en, this message translates to:
  /// **'You don\'t have any TouristSaver Universal credit. Register your membership or log in to access the TouristSaver benefits'**
  String
      get youDonTHaveAnyTouristSaverUniversalCreditRegisterYourMembershipOrLogInToAccessTheTouristSaverBenefits;

  /// No description provided for @yourActiveMerchantWallets.
  ///
  /// In en, this message translates to:
  /// **'Your Active Merchant Wallets'**
  String get yourActiveMerchantWallets;

  /// No description provided for @yourEmailIsNotActivatedYet.
  ///
  /// In en, this message translates to:
  /// **'Your email is not activated yet.\nYou need to activate your email to change country and recommend merchant as well as to receive important emails from TouristSaver'**
  String get yourEmailIsNotActivatedYet;

  /// No description provided for @yourEmailIsNotActivatedYetNPleaseVerifyYourEmailBeforeChangingCountry.
  ///
  /// In en, this message translates to:
  /// **'Your email is not activated yet.\nPlease verify your email before changing country'**
  String
      get yourEmailIsNotActivatedYetNPleaseVerifyYourEmailBeforeChangingCountry;

  /// No description provided for @yourEmailIsNotActivatedYetNPleaseVerifyYourEmailBeforeRecommendingMerchants.
  ///
  /// In en, this message translates to:
  /// **'Your email is not activated yet.\nPlease verify your email before recommending merchants'**
  String
      get yourEmailIsNotActivatedYetNPleaseVerifyYourEmailBeforeRecommendingMerchants;

  /// No description provided for @yourFeedback.
  ///
  /// In en, this message translates to:
  /// **'Your Feedback'**
  String get yourFeedback;

  /// No description provided for @yourQrCode.
  ///
  /// In en, this message translates to:
  /// **'Your QR Code'**
  String get yourQrCode;

  /// No description provided for @yourUniversalTouristSaverCredits.
  ///
  /// In en, this message translates to:
  /// **'Your Universal TouristSaver Credits'**
  String get yourUniversalTouristSaverCredits;

  /// No description provided for @direction.
  ///
  /// In en, this message translates to:
  /// **'Directions'**
  String get direction;

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get deleteAccount;

  /// No description provided for @areYouSureDeleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete your account? This action cannot be undone.'**
  String get areYouSureDeleteAccount;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;
}

class _SDelegate extends LocalizationsDelegate<S> {
  const _SDelegate();

  @override
  Future<S> load(Locale locale) {
    return SynchronousFuture<S>(lookupS(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ms', 'ne', 'th'].contains(locale.languageCode);

  @override
  bool shouldReload(_SDelegate old) => false;
}

S lookupS(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return SEn();
    case 'ms':
      return SMs();
    case 'ne':
      return SNe();
    case 'th':
      return STh();
  }

  throw FlutterError(
      'S.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
