// Api End point to concatenate after base url
const stripeKey = '/country/app/stripeKey';
const appSlugMessageURL = '/appSlugMessage/getOneBySlug';
// const getAllCharitiess = '/charity/getAll';
const charityByMember = '/charity/getCharityByMember';
const getAllCharitiesForApp = '/charity/getAllCharityForMobileApp';
const charityList = '/charity/getAll';
const getAllCharity = '/charity/getAllCharity';
const updateCharity = '/member/general/selectCharity';
const getNearCharity = '/charity/getCharityWithInRadius';
const countryList = '/country/getAllForApp';
const allState = '/state/getAllForApp';
const allregion = '/region/getAllForApp';
const allPostalCode = '/postalCode/getAll';
const loginMember = '/auth/memberLogin';
const oneMember = '/member/general/getOne';
const confirmApplyPiiinkURL = '/member/transaction/startApplyPiiink';
const terminalConfirmApplyPiiinkURL =
    '/member/transaction/terminalStartApplyPiiink';
const surApplyPiiink = '/member/transaction/applyPiiink';

const memberPremiumGetOne = '/memberPremiumCode/getOne';
const showCharityGetOne = '/showCharity/getOne';
const registrationImageGetOne = 'registrationImage/getOne/';

const universalGetMyWallet = '/wallet/universal/getMyWallet';
const merchantGetMyWallet = '/wallet/merchant/getMyWallet';
const profileEdit = '/member/general/edit';
const premium = '/memberPremiumCode/checkCodeValidity';
const regTopUp = '/member/general/topUpWithPaidPremiumCode';
// const createEmailMemOTP = '/member/general/createEmailOTP';
const createPhoneOtpUrl = '/member/general/createPhoneOTP';
const resendRegEmailMemOTP = '/member/general/reSendEmailOTP';
const verifyRegEmailOTP = '/member/general/verifyEmailOTP';
const resendRegNumberOTP = '/member/general/reSendOTP';
const regMem = '/member/general/create';
const piiinkTransfer = '/wallet/transfer/piiinks';
const piinksTransferQR = '/wallet/transfer/app/piiinks';
const topUpIntent = '/member/topup/topup_paymentIntent';
const premiumTopupCodeValidity = '/memberPremiumCode/checkCodeValidityOnTopUp';
const topUpCheckPremiumCode = '/member/topup/checkPremiumCode';
// const memPackage = '/membershipPackage/getAll';
const memPackageFree = '/membershipPackage/getOneForFreeBymember';
const memPackageForMember = '/membershipPackage/getAllBymember';
const singleMemPackageForMember = '/membershipPackage/getOneForTouristBymember';
const stripePayConfirm = '/member/topup/stripe/confirmation';
const verifyEmailUrl = '/member/general/sendEmailVerificationToken';
const topUpHistory = '/transaction/membership/getByMember';
const premiumTopUpHistory = '/memberPremiumCode/getByMember';
const claimPiinksUrl = '/member/general/claimFreePiiinks';
const membershipGetFreeUrl = '/membershipPackage/getFree';
const verifyOTPMediumUrl = '/member/verifyOTPMedium/getAll';
const locationMerchantUrl = '/merchant/merchantForApp/getMerchantByLocation';
const getAllMemberCategoriesUrl =
    '/merchant/merchantCategory/getAllParentCategoryForApp';
const appVersionLogUrl = '/globalSetting/appVersionLog/getLatestOne';
//---------------------------....working api============//
const patchChoosenLanguage = '/member/general/changeAppLang';
const getActiveLang = '/country/getActivelang';
const getAllPhonePrefix = '/globalSetting/countryWisePrefix/getAll';
const nearByLocation = '/merchant/general/getMerchantWithinRadius';

const bannerList = 'banner/getOne/';
const locationRange = '/globalSetting/appLocationRange/getAll';
const changePasswordUrl = '/member/general/changePassword';
const changeCountryURL = '/member/general/changeCountry';
const forgotPass = '/member/general/forgotPassword';
const resetPass = '/member/general/resetPassword';
const verifyChangedNum = '/member/general/verifyUpdatePhone';
// const categorylistByParentID = '/merchant/merchantCategory/getOne';
const categoryList = '/merchant/merchantCategory/getParentCategories';
const subCategoryList = '/merchant/merchantCategory/getSubCategories';
const allMerchant = '/merchant/general/getAll';
const merchantFavOrNot = '/member/favoriteMerchant/getByMerchantId';
const merchantDetail = '/merchant/general/getOneByApp/';
const agreement = '/page/getForApp/';
const discountInfo = '/merchant/general/discountSummaryApp/';
const appSlide = '/globalSetting/appSlider/getAll';
const homeFeedPosts = '/home-feed/posts';
const searchMerchant = '/merchant/merchantForApp/getAllbyName/';
const otherMerchant = '/merchant/merchantForApp/otherMerchant/';
const isPay = '/country/getOne/';
const checkIssuer = '/issuerCode/getIssuer';
const userTransac = '/transaction/friendship/getByMemberApp';
const deleteUser = '/member/general/deleteAccount';
const piiinkInfoURL = '/globalSetting/piiinkInformation/getOneByCountry';
const recommendMerURL = '/merchant/referred/create';
const addFavouriteURL = '/member/favoriteMerchant/add_to_favorite';
const removeFavouriteURL = '/member/favoriteMerchant/delete';
const getAllFavouriteURL = '/member/favoriteMerchant/getAll';
const checkEmailAndPhoneNoUrl = '/member/general/checkEmailOrPhone';
const addFcmToken = '/notification/fcmToken/addFcmToken';

// Notifications
const getAllMemberNotifications = '/notification/member/getAll';
const deleteMemberSingleNotification = '/notification/member/delete/{0}';
const deleteMemberAllNotifications = '/notification/member/deleteAll';
const deleteDeviceIdOnLogOut = '/notification/fcmToken/delete/{0}';

//Merchant Reviews
const getAllMerchantReviewsURL = '/merchant/merchantReview/getAll';
const getAllReviewsURL = '/globalSetting/reviewText/getAll';
const createMerchantReviewsURL = '/merchant/merchantReview/create';

const memberDelete = '/member/general/deleteAccount';
