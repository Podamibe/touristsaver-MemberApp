// import 'dart:developer';
// ignore_for_file: prefer_typing_uninitialized_variables

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:touristsaver/common/widgets/custom_app_bar.dart';
import 'package:touristsaver/common/widgets/custom_loader.dart';
import 'package:touristsaver/common/widgets/error.dart';
import 'package:touristsaver/constants/global_colors.dart';
import 'package:touristsaver/constants/style.dart';
import 'package:touristsaver/features/connectivity/cubit/internet_cubit.dart';
import 'package:touristsaver/features/details/services/dio_detail.dart';
import 'package:touristsaver/features/transaction/services/dio_transaction.dart';
import 'package:touristsaver/features/wallet/services/dio_wallet.dart';
import 'package:touristsaver/models/response/detail_res.dart' as detail;
import 'package:touristsaver/models/response/transaction_res.dart'
    as transaction;
import 'package:touristsaver/models/response/universal_get_my_wallet.dart';
import '../../../common/widgets/custom_button.dart';
import '../../../common/widgets/custom_snackbar.dart';
import '../../../constants/pref.dart';
import '../../../constants/pref_key.dart';
import '../../../models/error_res.dart';
import '../../../models/request/rate_merchant_req.dart';
import '../../../models/response/get_all_reviews_suggestion.dart';
import '../../../models/response/get_free_piiinks_res_model.dart';
import '../../../models/response/is_pay_enable_res.dart';
import '../../connectivity/screens/connectivity.dart';
import '../../merchant/services/dio_reviews.dart';
import '../../payment/services/dio_payment.dart';
import 'package:touristsaver/generated/l10n.dart';

import 'package:dartz/dartz.dart' as dartz;

class LogWalletScreen extends StatefulWidget {
  static const String routeName = '/wallet-screen';
  const LogWalletScreen({super.key});

  @override
  State<LogWalletScreen> createState() => _LogWalletScreenState();
}

class _LogWalletScreenState extends State<LogWalletScreen> {
  static const Color _primaryBlue = Color(0xFF0009FE);
  static const Color _screenBackground = Color(0xFFF8FAFE);
  static const Color _headingColor = Color(0xFF111C44);
  static const Color _bodyColor = Color(0xFF61708A);
  static const Color _borderColor = Color(0xFFE2E8F3);

  bool? isTopUpEnabled;
  bool? canClaimFreePiiinks;
  bool? isFreePiiinksProvided;
  bool? isTopUpOnRegister;
  double? universalFreePiiinks;
  //For Sending the universal piiink as an argument
  double? sendUniPiiink;
  bool isLoading = false;

  Future<void> getFreePiiinksInfo() async {
    GetFreePiinksResModel? getFreePiinksResModel = await DioWallet().getFree();
    universalFreePiiinks =
        getFreePiinksResModel?.data?.universalPiiinks!.toDouble();
    // log({getFreePiinksResModel?.data?.universalPiiinks}.toString());
  }

  Future<void> getPaymentInfo() async {
    IsPayEnableResModel? isPayEnabledResModel = await DioPay().payEnabled();
    if (!mounted) return;
    setState(() {
      isTopUpEnabled = isPayEnabledResModel?.data?.transactionIsEnabled;
    });
  }

  // Calling the user wallet
  Future<UniversalGetMyWallet?>? walletLoad;
  Future<transaction.TransactionResModel?>? recentSavingsLoad;
  Future<UniversalGetMyWallet?> loadWallet() async {
    setState(() {
      isLoading = false;
    });
    UniversalGetMyWallet? getWallet = await DioWallet().getUniverslUserWallet();
    setState(() {
      isTopUpOnRegister = getWallet!.data!.isTopUpOnRegister;
      canClaimFreePiiinks = getWallet.data!.canClaimFreePiiinks;
      isFreePiiinksProvided = getWallet.data!.isFreePiiinksProvided;
      isLoading = true;
    });
    return getWallet;
  }

  Future<transaction.TransactionResModel?> loadRecentSavings() async {
    final DateFormat apiDateFormat = DateFormat('yyyy-MM-dd');
    final DateTime now = DateTime.now();
    final String latestDate = apiDateFormat.format(now);
    const String previousDate = '2000-01-01';

    return DioTransaction().transac(previousDate, latestDate);
  }

  int? merchantId;
  bool showReviewPopUp = false;

  late double _rating;
  final int _ratingBarMode = 0;
  final double _initialRating = 0;
  IconData? _selectedIcon;
  var _defaultChoiceIndex;
  String? selectedString;
  bool reviewLoading = false;
  bool isSelected = false;
  final Map<int, Future<String?>> _merchantImageLoads = {};

// For filling the edit form
  Future<dartz.Either<ErrorResModel, GetAllReviewSuggestionResModel>?>?
      getReviews;
  Future<dartz.Either<ErrorResModel, GetAllReviewSuggestionResModel>?>?
      getSuggestionReview() async {
    dartz.Either<ErrorResModel, GetAllReviewSuggestionResModel>?
        getSuggestionReviewRes = await DioReviews().getAllReviews();

    return getSuggestionReviewRes!
        .fold((l) => getSuggestionReviewRes, (r) => getSuggestionReviewRes);
  }

  @override
  void initState() {
    getPaymentInfo();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      showReviewPopUp = await Pref().readBool(key: showReview) ?? false;
      merchantId = await Pref().readInt(key: addReviewMerchantID);
      getReviews = getSuggestionReview();
      _rating = _initialRating;
      if (showReviewPopUp == true) {
        _showAddReviewDialog();
      }
    });

    getFreePiiinksInfo();
    walletLoad = loadWallet();
    recentSavingsLoad = loadRecentSavings();
    super.initState();
  }

  @override
  void dispose() {
    ConnectivityCubit().close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _screenBackground,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: CustomAppBar(text: 'My Savings'),
      ),
      body: BlocBuilder<ConnectivityCubit, ConnectivityState>(
        builder: (context, state) {
          return ScrollConfiguration(
            behavior: const ScrollBehavior(),
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 28.h),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height -
                      kToolbarHeight -
                      MediaQuery.of(context).padding.top -
                      40.h,
                ),
                child: state == ConnectivityState.loading
                    ? const NoInternetLoader()
                    : state == ConnectivityState.disconnected
                        ? const NoInternetWidget()
                        : _connectedSavingsDashboard(),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _connectedSavingsDashboard() {
    return FutureBuilder<UniversalGetMyWallet?>(
      future: walletLoad,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const ProfileError();
        } else if (!snapshot.hasData || isLoading == false) {
          return const ProfileLoader();
        }

        final UniversalGetMyWallet wallet = snapshot.data!;
        sendUniPiiink = wallet.data?.balance ?? 0;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _mainBalanceCard(wallet),
            SizedBox(height: 16.h),
            _recentSavingsSection(),
            SizedBox(height: 16.h),
            _howDiscountCreditsWorkCard(),
            SizedBox(height: 16.h),
            _merchantDiscountCreditsSection(),
            SizedBox(height: 16.h),
            _moreOptionsSection(),
          ],
        );
      },
    );
  }

  Widget _mainBalanceCard(UniversalGetMyWallet universalWallet) {
    final String balance = _formatCurrency(universalWallet.data?.balance ?? 0);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.white, Color(0xFFEFF7FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: _borderColor),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0A236B).withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Align(
            alignment: Alignment.center,
            child: Container(
              width: 44.w,
              height: 44.w,
              decoration: BoxDecoration(
                color: const Color(0xFFE6F3FF),
                borderRadius: BorderRadius.circular(14.r),
              ),
              child: Icon(
                Icons.savings_outlined,
                color: _primaryBlue,
                size: 25.sp,
              ),
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            'Available Discount Credits',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _headingColor,
              fontSize: 17.sp,
              fontWeight: FontWeight.w900,
              fontFamily: 'Sans',
            ),
          ),
          SizedBox(height: 14.h),
          Text(
            balance,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _primaryBlue,
              fontSize: 34.sp,
              fontWeight: FontWeight.w900,
              height: 1.12,
              fontFamily: 'Sans',
            ),
          ),
          SizedBox(height: 10.h),
          Text(
            'Use your Discount Credits to access participating merchant offers.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _bodyColor,
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              height: 1.4,
              fontFamily: 'Sans',
            ),
          ),
        ],
      ),
    );
  }

  Widget _howDiscountCreditsWorkCard() {
    return _SavingsCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader(
            icon: Icons.info_outline,
            title: 'How Discount Credits work',
          ),
          SizedBox(height: 12.h),
          Text(
            'TouristSaver Discount Credits are used to access eligible merchant discounts. When a participating merchant applies a discount, only the discount amount is deducted from your available Discount Credits.',
            style: _bodyTextStyle(),
          ),
          SizedBox(height: 14.h),
          Divider(color: _borderColor, height: 1),
          SizedBox(height: 14.h),
          _exampleRow('Bill total', '\$100'),
          _exampleRow('Member discount', '10%'),
          _exampleRow('You pay merchant', '\$90'),
          _exampleRow('Discount Credits used', '\$10.00'),
          SizedBox(height: 10.h),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: _showDiscountCreditsExplainer,
              style: TextButton.styleFrom(
                foregroundColor: _primaryBlue,
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                'Learn more',
                style: TextStyle(
                  color: _primaryBlue,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w900,
                  fontFamily: 'Sans',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _recentSavingsSection() {
    return _SavingsCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _sectionHeader(
                  icon: Icons.history_outlined,
                  title: 'Recent savings',
                ),
              ),
              TextButton(
                onPressed: _openTransactionHistory,
                style: TextButton.styleFrom(
                  foregroundColor: _primaryBlue,
                  padding: EdgeInsets.symmetric(horizontal: 8.w),
                ),
                child: Text(
                  'Transaction History',
                  style: TextStyle(
                    color: _primaryBlue,
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w800,
                    fontFamily: 'Sans',
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          FutureBuilder<transaction.TransactionResModel?>(
            future: recentSavingsLoad,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  child: const Center(
                    child: CircularProgressIndicator(
                      color: _primaryBlue,
                      strokeWidth: 2,
                    ),
                  ),
                );
              }

              final List<transaction.Datum> allSavings =
                  _latestSavings(snapshot.data!);
              final List<transaction.Datum> transactions =
                  allSavings.take(5).toList();
              final double totalSavings = _totalMemberSavings(allSavings);

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _totalMemberSavingsBlock(totalSavings),
                  SizedBox(height: 16.h),
                  if (transactions.isEmpty)
                    Text(
                      'Your recent savings will appear here after you use TouristSaver with participating merchants.',
                      style: _bodyTextStyle(),
                    )
                  else
                    Column(
                      children: [
                        for (int index = 0;
                            index < transactions.length;
                            index++) ...[
                          _recentSavingTile(transactions[index]),
                          if (index != transactions.length - 1)
                            SizedBox(height: 10.h),
                        ],
                      ],
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _recentSavingTile(transaction.Datum transaction) {
    final String merchantName =
        transaction.merchant?.merchantName ?? 'Participating merchant';
    final String date = transaction.transactionDate == null
        ? ''
        : DateFormat('d MMM yyyy')
            .format(transaction.transactionDate!.toLocal());
    final String discount = _formatCurrency(transaction.discountAmount ?? 0);
    final String? merchantImageUrl = _merchantImageUrl(transaction);

    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: _borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          _recentSavingMerchantImage(
            merchantImageUrl,
            merchantId: transaction.merchantId,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  merchantName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: _headingColor,
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w800,
                    fontFamily: 'Sans',
                  ),
                ),
                if (date.isNotEmpty) ...[
                  SizedBox(height: 5.h),
                  Text(
                    date,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: _captionTextStyle(),
                  ),
                ],
              ],
            ),
          ),
          SizedBox(width: 8.w),
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 104.w),
            child: Text(
              'Saved $discount',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.right,
              style: TextStyle(
                color: _primaryBlue,
                fontSize: 13.sp,
                fontWeight: FontWeight.w900,
                fontFamily: 'Sans',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _recentSavingMerchantImage(String? imageUrl, {int? merchantId}) {
    final String? url =
        imageUrl == null || imageUrl.trim().isEmpty ? null : imageUrl.trim();
    if (url == null && merchantId != null) {
      return FutureBuilder<String?>(
        future: _merchantImageFuture(merchantId),
        builder: (context, snapshot) {
          return _recentSavingMerchantImageFrame(
            snapshot.data,
            isLoading: snapshot.connectionState != ConnectionState.done,
          );
        },
      );
    }

    return _recentSavingMerchantImageFrame(url);
  }

  Widget _recentSavingMerchantImageFrame(
    String? imageUrl, {
    bool isLoading = false,
  }) {
    final String? url =
        imageUrl == null || imageUrl.trim().isEmpty ? null : imageUrl.trim();
    return ClipRRect(
      borderRadius: BorderRadius.circular(14.r),
      child: Container(
        width: 66.w,
        height: 66.w,
        color: const Color(0xFFF2F6FC),
        child: isLoading
            ? _recentSavingImageLoader()
            : url == null
                ? _recentSavingFallbackImage()
                : CachedNetworkImage(
                    imageUrl: url,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => _recentSavingImageLoader(),
                    errorWidget: (context, url, error) =>
                        _recentSavingFallbackImage(),
                  ),
      ),
    );
  }

  Widget _recentSavingImageLoader() {
    return Center(
      child: SizedBox(
        width: 18.w,
        height: 18.w,
        child: const CircularProgressIndicator(
          strokeWidth: 2,
          color: Color(0xFF009FE3),
        ),
      ),
    );
  }

  Future<String?> _merchantImageFuture(int merchantId) {
    return _merchantImageLoads.putIfAbsent(
      merchantId,
      () => _loadMerchantImage(merchantId),
    );
  }

  Future<String?> _loadMerchantImage(int merchantId) async {
    final DateTime now = DateTime.now();
    final detail.MerchantDetailResModel? merchantDetail =
        await DioDetail().getMerchantDetail(
      id: merchantId,
      day: DateFormat('EEEE').format(now),
      hour: now.hour,
    );
    final detail.MerchantImageInfo? imageInfo =
        merchantDetail?.data?.merchantImageInfo;
    return _firstNotEmpty([
      imageInfo?.logoUrl,
      imageInfo?.slider1,
      imageInfo?.slider2,
      imageInfo?.slider3,
      imageInfo?.slider4,
      imageInfo?.slider5,
      imageInfo?.slider6,
    ]);
  }

  Widget _recentSavingFallbackImage() {
    return Image.asset('assets/images/no_image.jpg', fit: BoxFit.cover);
  }

  String? _merchantImageUrl(transaction.Datum transactionData) {
    final transaction.Merchant? merchant = transactionData.merchant;
    return _firstNotEmpty([
      transactionData.merchantImageInfo?.logoUrl,
      merchant?.merchantImageInfo?.logoUrl,
      merchant?.logoUrl,
      transactionData.merchantImageInfo?.slider1,
      merchant?.merchantImageInfo?.slider1,
      transactionData.merchantImageInfo?.slider2,
      merchant?.merchantImageInfo?.slider2,
      transactionData.merchantImageInfo?.slider3,
      merchant?.merchantImageInfo?.slider3,
      transactionData.merchantImageInfo?.slider4,
      merchant?.merchantImageInfo?.slider4,
      transactionData.merchantImageInfo?.slider5,
      merchant?.merchantImageInfo?.slider5,
    ]);
  }

  String? _firstNotEmpty(List<String?> values) {
    for (final String? value in values) {
      if (value != null && value.trim().isNotEmpty) {
        return value.trim();
      }
    }
    return null;
  }

  Widget _merchantDiscountCreditsSection() {
    return _SavingsCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader(
            icon: Icons.storefront_outlined,
            title: 'Merchant Discount Credits',
          ),
          SizedBox(height: 10.h),
          Text(
            'Merchant Discount Credits are merchant-specific credits that can be used toward eligible future purchases with that merchant.',
            style: _bodyTextStyle(),
          ),
          SizedBox(height: 14.h),
          _outlineLinkButton(
            label: 'View merchant Discount Credits',
            icon: Icons.arrow_forward_rounded,
            onTap: () => context.pushNamed('merchant-wallet'),
          ),
        ],
      ),
    );
  }

  Widget _moreOptionsSection() {
    return _SavingsCard(
      padding: EdgeInsets.zero,
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 2.h),
          childrenPadding: EdgeInsets.fromLTRB(18.w, 0, 18.w, 16.h),
          iconColor: _primaryBlue,
          collapsedIconColor: _primaryBlue,
          title: Text(
            'More options',
            style: TextStyle(
              color: _headingColor,
              fontSize: 16.sp,
              fontWeight: FontWeight.w900,
              fontFamily: 'Sans',
            ),
          ),
          children: [
            _moreOptionTile(
              icon: Icons.add_card_outlined,
              label: 'Add Discount Credits',
              onTap: isTopUpEnabled == false
                  ? null
                  : () {
                      context.pushNamed('top-up').then((value) {
                        _refreshSavings();
                      });
                    },
            ),
            _moreOptionTile(
              icon: Icons.public_outlined,
              label: 'Change Country',
              onTap: () {
                context.pushNamed('change-country').then((value) {
                  _refreshSavings();
                });
              },
            ),
            _moreOptionTile(
              icon: Icons.swap_horiz_rounded,
              label: 'Transfer Merchant Credits',
              onTap: () {
                context.pushNamed('transfer-piiinks').then((value) {
                  _refreshSavings();
                });
              },
            ),
            _moreOptionTile(
              icon: Icons.payments_outlined,
              label: 'Discount Credit purchase history',
              onTap: () => context.pushNamed('top_up_history'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _moreOptionTile({
    required IconData icon,
    required String label,
    required VoidCallback? onTap,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      enabled: onTap != null,
      leading: Icon(
        icon,
        color:
            onTap == null ? _bodyColor.withValues(alpha: 0.45) : _primaryBlue,
        size: 22.sp,
      ),
      title: Text(
        label,
        style: TextStyle(
          color: onTap == null
              ? _bodyColor.withValues(alpha: 0.55)
              : _headingColor,
          fontSize: 14.sp,
          fontWeight: FontWeight.w700,
          fontFamily: 'Sans',
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios_rounded,
        color: _bodyColor,
        size: 16.sp,
      ),
      onTap: onTap,
    );
  }

  Widget _totalMemberSavingsBlock(double totalSavings) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: const Color(0xFFF7FAFF),
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: _borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Total Member Savings',
            style: TextStyle(
              color: _headingColor,
              fontSize: 14.sp,
              fontWeight: FontWeight.w900,
              fontFamily: 'Sans',
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            _formatCurrency(totalSavings),
            style: TextStyle(
              color: _primaryBlue,
              fontSize: 28.sp,
              fontWeight: FontWeight.w900,
              height: 1,
              fontFamily: 'Sans',
            ),
          ),
        ],
      ),
    );
  }

  Widget _outlineLinkButton({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16.r),
        onTap: onTap,
        child: Ink(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 13.h),
          decoration: BoxDecoration(
            color: const Color(0xFFF7FAFF),
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: _borderColor),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: _primaryBlue,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w900,
                  fontFamily: 'Sans',
                ),
              ),
              SizedBox(width: 8.w),
              Icon(icon, color: _primaryBlue, size: 18.sp),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionHeader({required IconData icon, required String title}) {
    return Row(
      children: [
        Icon(icon, color: _primaryBlue, size: 22.sp),
        SizedBox(width: 8.w),
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              color: _headingColor,
              fontSize: 17.sp,
              fontWeight: FontWeight.w900,
              fontFamily: 'Sans',
            ),
          ),
        ),
      ],
    );
  }

  Widget _exampleRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: _bodyTextStyle()),
          ),
          Text(
            value,
            style: TextStyle(
              color: _headingColor,
              fontSize: 14.sp,
              fontWeight: FontWeight.w900,
              fontFamily: 'Sans',
            ),
          ),
        ],
      ),
    );
  }

  TextStyle _bodyTextStyle() {
    return TextStyle(
      color: _bodyColor,
      fontSize: 14.sp,
      fontWeight: FontWeight.w600,
      height: 1.42,
      fontFamily: 'Sans',
    );
  }

  TextStyle _captionTextStyle() {
    return TextStyle(
      color: _bodyColor,
      fontSize: 12.5.sp,
      fontWeight: FontWeight.w600,
      fontFamily: 'Sans',
    );
  }

  List<transaction.Datum> _latestSavings(
      transaction.TransactionResModel model) {
    final List<transaction.Datum> transactions = model.data?.values
            .expand(
                (List<transaction.Datum> dayTransactions) => dayTransactions)
            .where((transaction.Datum item) => (item.discountAmount ?? 0) > 0)
            .toList() ??
        [];

    transactions.sort((transaction.Datum a, transaction.Datum b) {
      final DateTime aDate =
          a.transactionDate ?? DateTime.fromMillisecondsSinceEpoch(0);
      final DateTime bDate =
          b.transactionDate ?? DateTime.fromMillisecondsSinceEpoch(0);
      return bDate.compareTo(aDate);
    });

    return transactions;
  }

  double _totalMemberSavings(List<transaction.Datum> transactions) {
    return transactions.fold<double>(
      0,
      (double total, transaction.Datum item) =>
          total + (item.discountAmount ?? 0),
    );
  }

  String _formatCurrency(num value) {
    return NumberFormat.currency(symbol: '\$', decimalDigits: 2).format(value);
  }

  Future<void> _refreshSavings() async {
    final Future<UniversalGetMyWallet?> newWalletLoad = loadWallet();
    final Future<transaction.TransactionResModel?> newRecentSavingsLoad =
        loadRecentSavings();

    setState(() {
      walletLoad = newWalletLoad;
      recentSavingsLoad = newRecentSavingsLoad;
    });

    await Future.wait([
      newWalletLoad,
      newRecentSavingsLoad,
    ]);
  }

  void _openTransactionHistory() {
    context.pushNamed('statement', pathParameters: {
      'uniBalance':
          sendUniPiiink.toString() != 'null' ? sendUniPiiink.toString() : '0',
    });
  }

  void _showDiscountCreditsExplainer() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return SafeArea(
          child: Container(
            margin: EdgeInsets.all(16.r),
            padding: EdgeInsets.all(20.r),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24.r),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sectionHeader(
                  icon: Icons.info_outline,
                  title: 'TouristSaver Discount Credits',
                ),
                SizedBox(height: 14.h),
                Text(
                  'Discount Credits help access discounts with participating merchants. They are not cash, tokens or a currency balance.',
                  style: _bodyTextStyle(),
                ),
                SizedBox(height: 12.h),
                Text(
                  'When you use TouristSaver, the merchant discount amount is deducted from your available Discount Credits. You then pay the merchant the discounted total.',
                  style: _bodyTextStyle(),
                ),
                SizedBox(height: 12.h),
                Text(
                  'Merchant Discount Credits are merchant-specific credits that can be used toward eligible future purchases with that merchant.',
                  style: _bodyTextStyle(),
                ),
                SizedBox(height: 18.h),
                _outlineLinkButton(
                  label: 'Got it',
                  icon: Icons.check_rounded,
                  onTap: () => context.pop(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showAddReviewDialog() {
    Pref().setBool(key: showReview, value: false);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(S.of(context).addReview),
          content: StatefulBuilder(builder: (context, stateMode) {
            return SingleChildScrollView(
              child: SizedBox(
                height: 320,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      S.of(context).rateThisMerchant,
                      style: topicStyle.copyWith(fontSize: 20),
                    ),
                    const SizedBox(height: 15),
                    Center(child: _ratingBar(_ratingBarMode)),
                    const SizedBox(height: 15),
                    const Divider(
                      thickness: 2,
                    ),
                    const SizedBox(height: 15),
                    Text(S.of(context).yourFeedback,
                        style: topicStyle.copyWith(
                            fontSize: 15, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 15),
                    choiceChips(stateMode),
                  ],
                ),
              ),
            );
          }),
          actions: [
            reviewLoading == true
                ? Padding(
                    padding: const EdgeInsets.only(
                        right: 15.0, left: 15.0, bottom: 7.0),
                    child: const CustomButtonWithCircular(),
                  )
                : Padding(
                    padding: const EdgeInsets.only(
                        right: 15.0, left: 15.0, bottom: 7.0),
                    child: CustomButton(
                        onPressed: () {
                          onSendReview();
                        },
                        text: S.of(context).sendReview),
                  ),
          ],
        );
      },
    );
  }

  Widget choiceChips(stateMode) {
    return FutureBuilder<
            dartz.Either<ErrorResModel, GetAllReviewSuggestionResModel>?>(
        future: getReviews,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Error1();
          } else if (!snapshot.hasData) {
            return const Column(
              children: [
                CustomAllLoader(),
              ],
            );
          } else {
            return snapshot.data!.fold((l) {
              return ErrorData(text: l.message!);
            }, (r) {
              var realData = r.data?.where((x) => x.isActive == true).toList();
              return r.data!.isNotEmpty
                  ? Expanded(
                      child: SingleChildScrollView(
                        child: Wrap(
                          children: realData!.map((item) {
                            // log("Chip item: ${item.reviewText}");
                            return ChoiceChip(
                              padding: EdgeInsets.all(10.sp),
                              selectedColor: Colors.orange.shade300,
                              label: Text(
                                item.reviewText ?? '',
                                overflow: TextOverflow.ellipsis,
                              ),
                              selected:
                                  _defaultChoiceIndex == realData.indexOf(item),
                              shape: RoundedRectangleBorder(
                                  side: const BorderSide(
                                      color: GlobalColors.appColor1),
                                  borderRadius: BorderRadius.circular(15)),
                              backgroundColor:
                                  GlobalColors.appWhiteBackgroundColor,
                              labelStyle: _defaultChoiceIndex ==
                                          realData.indexOf(item) &&
                                      isSelected
                                  ? const TextStyle(
                                      color:
                                          GlobalColors.appWhiteBackgroundColor)
                                  : const TextStyle(
                                      color: GlobalColors.appColor1),
                              onSelected: (bool selected) {
                                stateMode(() {
                                  _defaultChoiceIndex =
                                      selected ? realData.indexOf(item) : 0;
                                  isSelected = true;
                                  selectedString = item.reviewText ?? '';
                                });
                              },
                            );
                          }).toList(),
                        ),
                      ),
                    )
                  : SizedBox();
            });
          }
        });
  }

  Widget _ratingBar(int mode) {
    return RatingBar.builder(
      initialRating: 0,
      minRating: 0,
      direction: Axis.horizontal,
      allowHalfRating: true,
      unratedColor: Colors.orange.withAlpha(50),
      itemCount: 5,
      itemSize: 30.0,
      itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
      itemBuilder: (context, _) => Icon(
        _selectedIcon ?? Icons.star,
        color: Colors.orange,
      ),
      onRatingUpdate: (rating) {
        setState(() {
          _rating = rating;
        });
      },
      updateOnDrag: true,
    );
  }

  onSendReview() async {
    setState(() {
      reviewLoading = true;
    });

    if (_rating == 0.0 && selectedString == null) {
      GlobalSnackBar.valid(
          context, S.of(context).pleaseRateThisMerchantOrProvideFeedback);
      setState(() {
        reviewLoading = false;
      });
    } else {
      var rez = await DioReviews().createMerchantReviews(
          rateMerchantReqModel: RateMerchantReqModel(
              rating: _rating, merchantId: merchantId, review: selectedString));
      rez?.fold((l) {
        GlobalSnackBar.showError(context, l.message!);
        setState(() {
          reviewLoading = false;
        });
        return;
      }, (r) {
        if (r.status == 'Success') {
          GlobalSnackBar.showSuccess(
              context, S.of(context).reviewAddedSuccessfully);
          setState(() {
            reviewLoading = false;
          });
          context.pop();
        }
      });
    }
  }
}

class _SavingsCard extends StatelessWidget {
  const _SavingsCard({
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
        borderRadius: BorderRadius.circular(22.r),
        border: Border.all(color: _LogWalletScreenState._borderColor),
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
