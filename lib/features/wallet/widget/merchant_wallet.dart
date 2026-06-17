import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:touristsaver/common/widgets/custom_loader.dart';
import 'package:touristsaver/common/widgets/error.dart';
import 'package:touristsaver/features/wallet/services/dio_wallet.dart';
import 'package:touristsaver/models/response/merchant_get_my_wallet.dart';
import 'package:touristsaver/generated/l10n.dart';

import '../../../constants/app_image_string.dart';

const Color _walletPrimaryBlue = Color(0xFF0009FE);
const Color _walletCtaCyan = Color(0xFF18C6FF);
const Color _walletNavy = Color(0xFF111C44);
const Color _walletMuted = Color(0xFF61708A);
const Color _walletBorder = Color(0xFFE2E8F3);
const Color _walletBackground = Color(0xFFF8FAFE);

class MerchantWalletScreen extends StatefulWidget {
  static const String routeName = '/merchant-wallet';
  const MerchantWalletScreen({super.key});

  @override
  State<MerchantWalletScreen> createState() => _MerchantWalletScreenState();
}

class _MerchantWalletScreenState extends State<MerchantWalletScreen> {
  final GlobalKey<RefreshIndicatorState> refreshIndicatorMerchantWallet =
      GlobalKey<RefreshIndicatorState>();
  TextEditingController searchController = TextEditingController();
  bool isSearching = false;
  //For Sorting
  List<String> sort = ['Sort by Alphabetical', 'Sort by Premium Savings'];
  String selectedWalletType = 'Merchant';
  String sortBy = 'Sort by Alphabetical';

  // For pagination
  int page = 1;
  bool isFirstLoading = false;
  bool hasNextPage = true;
  bool isLoadingMore = false;
  late ScrollController controllerWallet;
  List<MerchantWallet> merWallet = [];
  List<MerchantWallet> merFranchiseWallet = [];

  //For Error First Load
  String? err;

  // First Load
  void firstLoad() async {
    if (!mounted) return;
    setState(() {
      isFirstLoading = true;
    });

    try {
      final res = await DioWallet().getMerchantUserWallet(pageNumber: page);
      if (!mounted) return;
      setState(() {
        merWallet = res!.data!.merchantWallet ?? [];
        merFranchiseWallet = res.data!.merchantFranchiseWallet ?? [];
      });
    } catch (e) {
      if (kDebugMode) {
        err = 'Something went wrong';
      }
    }
    setState(() {
      if (!mounted) return;
      isFirstLoading = false;
    });
  }

  //Load More
  void loadMore() async {
    if (hasNextPage == true &&
        isFirstLoading == false &&
        isLoadingMore == false &&
        controllerWallet.position.extentAfter < 300) {
      if (!mounted) return;
      setState(() {
        isLoadingMore = true;
      });
      page += 1;
      try {
        final res = await DioWallet().getMerchantUserWallet(pageNumber: page);
        final List<MerchantWallet> fetchMerWallet =
            res!.data!.merchantWallet ?? [];
        if (fetchMerWallet.isNotEmpty) {
          setState(() {
            merWallet.addAll(fetchMerWallet);
          });
        } else {
          setState(() {
            hasNextPage = false;
          });
        }
      } catch (e) {
        if (kDebugMode) {
          print('Something went wrong!');
        }
      }
      if (!mounted) return;
      setState(() {
        isLoadingMore = false;
      });
    }
  }

  List<MerchantWallet> filteredMerWallet = [];
  List<MerchantWallet> filteredMerFranchiseWallet = [];

  // Filter the merchant wallets based on the search query
  filterMerchantWallet(String query) {
    setState(() {
      if (selectedWalletType == 'Merchant') {
        filteredMerWallet = merWallet
            .where((wallet) =>
                wallet.merchant?.merchantName
                    ?.toLowerCase()
                    .contains(query.toLowerCase()) ==
                true)
            .toList();
        filteredMerFranchiseWallet.clear();
      } else {
        filteredMerFranchiseWallet = merFranchiseWallet
            .where((wallet) =>
                wallet.merchant?.merchantName
                    ?.toLowerCase()
                    .contains(query.toLowerCase()) ==
                true)
            .toList();
        filteredMerWallet.clear();
      }
    });
  }

  @override
  void initState() {
    super.initState();
    firstLoad();
    controllerWallet = ScrollController()..addListener(loadMore);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: _walletBackground,
      appBar: _merchantCreditsAppBar(),
      body: isFirstLoading
          ? const _MerchantCreditsLoadingState()
          : err == 'Something went wrong'
              ? const Error1()
              : RefreshIndicator(
                  key: refreshIndicatorMerchantWallet,
                  color: _walletPrimaryBlue,
                  onRefresh: () async {
                    firstLoad();
                  },
                  child: Column(
                    children: [
                      SizedBox(height: 5.h),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10.w),
                        child: SizedBox(
                          height: 50.h,
                          child: TextFormField(
                            controller: searchController,
                            onChanged: (value) {
                              filterMerchantWallet(
                                  searchController.text.trim());
                            },
                            showCursor: true,
                            cursorColor: _walletPrimaryBlue,
                            decoration: InputDecoration(
                              hintText: 'Search merchants',
                              hintStyle: TextStyle(
                                color: _walletMuted,
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w700,
                                fontFamily: 'Sans',
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 14),
                              suffixIcon: InkWell(
                                borderRadius: BorderRadius.circular(18),
                                onTap: () {
                                  searchController.clear();
                                  setState(() {});
                                },
                                child: Icon(
                                  searchController.text.isEmpty
                                      ? Icons.search_rounded
                                      : Icons.clear_rounded,
                                  color: _walletPrimaryBlue,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(18),
                                borderSide:
                                    const BorderSide(color: _walletBorder),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(18),
                                borderSide: const BorderSide(
                                    color: _walletPrimaryBlue, width: 1.3),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(18),
                                borderSide:
                                    const BorderSide(color: _walletBorder),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.fromLTRB(16.w, 6.h, 16.w, 2.h),
                        child: AutoSizeText(
                          'Premium Savings by merchant helps you track the value unlocked through your membership.',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: _walletMuted,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Sans',
                            height: 1.35,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10.0, vertical: 10.0),
                        child: _filterShell(
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton2(
                              isExpanded: true,
                              iconStyleData: const IconStyleData(
                                icon: Icon(
                                  Icons.expand_more,
                                  size: 20,
                                  color: _walletPrimaryBlue,
                                ),
                                openMenuIcon: Icon(
                                  Icons.expand_less,
                                  size: 20,
                                  color: _walletPrimaryBlue,
                                ),
                              ),
                              items: sort.map((e) {
                                return DropdownMenuItem(
                                  value: e,
                                  child: AutoSizeText(
                                    e == 'Sort by Alphabetical'
                                        ? S.of(context).sortByAlphabetical
                                        : 'Sort by Premium Savings',
                                    style: _dropdownTextStyle(),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                );
                              }).toList(),
                              onChanged: (newValue) {
                                setState(() {
                                  sortBy = newValue.toString();
                                });
                              },
                              value: sortBy,
                              buttonStyleData: const ButtonStyleData(
                                padding: EdgeInsets.symmetric(horizontal: 10),
                                height: 50,
                              ),
                              dropdownStyleData: const DropdownStyleData(
                                maxHeight: 250,
                              ),
                              menuItemStyleData: const MenuItemStyleData(
                                height: 40,
                              ),
                            ),
                          ),
                        ),
                      ),
                      searchController.text.isNotEmpty
                          ? searchedMerchantWalletList()
                          : merWallet.isEmpty &&
                                  selectedWalletType == 'Merchant'
                              ? noMerchantWallet()
                              : merFranchiseWallet.isEmpty &&
                                      selectedWalletType == 'Group Merchant'
                                  ? noMerchantWallet()
                                  : merchantWalletList(),
                      const SizedBox(
                        height: 10,
                      ),
                    ],
                  ),
                ),
    );
  }

  PreferredSizeWidget _merchantCreditsAppBar() {
    return AppBar(
      flexibleSpace: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF6F6F6),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.2),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(2, 2),
            ),
          ],
        ),
      ),
      elevation: 0,
      centerTitle: true,
      leadingWidth: 40,
      titleSpacing: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios),
        color: Colors.black.withValues(alpha: 0.8),
        iconSize: 20,
        onPressed: () {
          context.pop();
        },
      ),
      title: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 4),
        child: AutoSizeText(
          'Merchant Premium Savings',
          maxLines: 1,
          minFontSize: 14,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: _walletNavy,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      actions: const [
        SizedBox(width: 40),
      ],
    );
  }

  // Merchant Wallet Available
  merchantWalletList() {
    return Expanded(
      child: ScrollConfiguration(
        behavior: const ScrollBehavior(),
        child: SingleChildScrollView(
          controller: controllerWallet,
          child: Column(
            children: [
              GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                padding: const EdgeInsets.only(
                  left: 10.0,
                  right: 10.0,
                  top: 0.0,
                  bottom: 20.0,
                ),
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 300,
                    childAspectRatio: 4 / 5,
                    crossAxisSpacing: 25,
                    mainAxisSpacing: 25),
                itemCount: selectedWalletType == 'Merchant'
                    ? merWallet.length
                    : merFranchiseWallet.length,
                itemBuilder: ((context, index) {
                  //For sorting alphabetically
                  if (sortBy == 'Sort by Alphabetical') {
                    if (selectedWalletType == 'Merchant') {
                      merWallet.sort((a, b) {
                        return a.merchant!.merchantName!
                            .compareTo(b.merchant!.merchantName!);
                      });
                    } else {
                      merFranchiseWallet.sort((a, b) {
                        return a.merchant!.merchantName!
                            .compareTo(b.merchant!.merchantName!);
                      });
                    }
                  } else {
                    if (selectedWalletType == 'Merchant') {
                      merWallet.sort((a, b) {
                        return b.balance!.compareTo(a.balance!);
                      });
                    } else {
                      merFranchiseWallet.sort((a, b) {
                        return b.balance!.compareTo(a.balance!);
                      });
                    }
                  }
                  MerchantWallet merchantWallet =
                      selectedWalletType == 'Merchant'
                          ? merWallet[index]
                          : merFranchiseWallet[index];
                  return _merchantCreditCard(merchantWallet);
                }),
              ),
              // checking and loading more
              if (isLoadingMore == true)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 10.0),
                  child: CircularProgressIndicator(
                    color: _walletPrimaryBlue,
                    strokeWidth: 2.0,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // Merchant Wallet Available
  searchedMerchantWalletList() {
    return Expanded(
      child: ScrollConfiguration(
        behavior: const ScrollBehavior(),
        child: SingleChildScrollView(
          controller: controllerWallet,
          child: Column(
            children: [
              GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                padding: const EdgeInsets.only(
                  left: 10.0,
                  right: 10.0,
                  top: 0.0,
                  bottom: 20.0,
                ),
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 300,
                    childAspectRatio: 4 / 5,
                    crossAxisSpacing: 25,
                    mainAxisSpacing: 25),
                itemCount: selectedWalletType == 'Merchant'
                    ? filteredMerWallet.length
                    : filteredMerFranchiseWallet.length,
                itemBuilder: ((context, index) {
                  MerchantWallet merchantWallet =
                      selectedWalletType == 'Merchant'
                          ? filteredMerWallet[index]
                          : filteredMerFranchiseWallet[index];
                  return _merchantCreditCard(merchantWallet);
                }),
              ),
              // checking and loading more
              if (isLoadingMore == true)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 10.0),
                  child: CircularProgressIndicator(
                    color: _walletPrimaryBlue,
                    strokeWidth: 2.0,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _filterShell({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _walletBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }

  TextStyle _dropdownTextStyle() {
    return TextStyle(
      color: _walletNavy,
      fontSize: 14.sp,
      fontWeight: FontWeight.w800,
      fontFamily: 'Sans',
    );
  }

  Widget _merchantCreditCard(MerchantWallet merchantWallet) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _walletBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Expanded(
            flex: 5,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: CachedNetworkImage(
                imageUrl: _merchantImageUrl(merchantWallet),
                fit: BoxFit.cover,
                width: double.infinity,
                placeholder: (context, url) {
                  return const Center(
                      child: FittedBox(child: CustomAllLoader1()));
                },
                errorWidget: (context, url, error) =>
                    Center(child: Image.asset('assets/images/no_image.jpg')),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Tooltip(
              message: merchantWallet.merchant?.merchantName ?? '',
              child: Padding(
                padding: const EdgeInsets.fromLTRB(4, 9, 4, 4),
                child: Align(
                  alignment: Alignment.center,
                  child: AutoSizeText(
                    merchantWallet.merchant?.merchantName ?? '',
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: _walletNavy,
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w900,
                      fontFamily: 'Sans',
                      height: 1.15,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _walletPrimaryBlue.withValues(alpha: 0.08),
                  _walletCtaCyan.withValues(alpha: 0.08),
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              children: [
                AutoSizeText(
                  'Your Savings ${_formatSavings(merchantWallet.balance)}',
                  maxLines: 1,
                  minFontSize: 11,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _walletPrimaryBlue,
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w900,
                    fontFamily: 'Sans',
                  ),
                ),
                const SizedBox(height: 2),
                AutoSizeText(
                  'Premium Savings',
                  maxLines: 1,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _walletMuted,
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Sans',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _merchantImageUrl(MerchantWallet merchantWallet) {
    if (selectedWalletType != 'Merchant') {
      return merchantWallet.merchant?.logoUrl ?? '';
    }

    if (merchantWallet.merchantImageInfo == null) {
      return AppImageString.appNoImageURL;
    }

    return merchantWallet.merchantImageInfo?.logoUrl ??
        merchantWallet.merchantImageInfo?.slider1 ??
        merchantWallet.merchantImageInfo?.slider2 ??
        merchantWallet.merchantImageInfo?.slider3 ??
        merchantWallet.merchantImageInfo?.slider4 ??
        merchantWallet.merchantImageInfo?.slider5 ??
        AppImageString.appNoImageURL;
  }

  String _formatSavings(num? balance) {
    return '\$${(balance ?? 0).toDouble().toStringAsFixed(2)}';
  }

  //nO Merchant wallet available
  noMerchantWallet() {
    return Expanded(
      child: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 24.h),
          child: _MerchantCreditsEmptyState(
            onPressed: () {
              context.pop();
            },
          ),
        ),
      ),
    );
  }
}

class _MerchantCreditsLoadingState extends StatelessWidget {
  const _MerchantCreditsLoadingState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 34.w,
            height: 34.w,
            child: const CircularProgressIndicator(
              color: _walletPrimaryBlue,
              strokeWidth: 3,
            ),
          ),
          SizedBox(height: 14.h),
          Text(
            'Loading merchant savings...',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _walletMuted,
              fontSize: 14.sp,
              fontWeight: FontWeight.w700,
              fontFamily: 'Sans',
            ),
          ),
        ],
      ),
    );
  }
}

class _MerchantCreditsEmptyState extends StatelessWidget {
  const _MerchantCreditsEmptyState({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(22.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22.r),
        border: Border.all(color: _walletBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 54.w,
            height: 54.w,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _walletPrimaryBlue.withValues(alpha: 0.10),
                  _walletCtaCyan.withValues(alpha: 0.10),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18.r),
            ),
            child: Icon(
              Icons.savings_outlined,
              color: _walletPrimaryBlue,
              size: 28.sp,
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            'Merchant Premium Savings not available',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _walletNavy,
              fontSize: 18.sp,
              fontWeight: FontWeight.w900,
              fontFamily: 'Sans',
              height: 1.2,
            ),
          ),
          SizedBox(height: 10.h),
          Text(
            'Shop with participating merchants to start building merchant-specific Premium Savings.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _walletMuted,
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              fontFamily: 'Sans',
              height: 1.4,
            ),
          ),
          SizedBox(height: 20.h),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(18),
                onTap: onPressed,
                child: Ink(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [_walletPrimaryBlue, _walletCtaCyan],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: _walletPrimaryBlue.withValues(alpha: 0.18),
                        blurRadius: 18,
                        offset: const Offset(0, 9),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      'Ok',
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
            ),
          ),
        ],
      ),
    );
  }
}
