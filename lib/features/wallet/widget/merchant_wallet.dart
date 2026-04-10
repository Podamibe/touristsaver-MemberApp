import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:new_piiink/common/widgets/custom_app_bar.dart';
import 'package:new_piiink/common/widgets/custom_loader.dart';
import 'package:new_piiink/common/widgets/error.dart';
import 'package:new_piiink/common/widgets/not_available.dart';
import 'package:new_piiink/constants/fixed_decimal.dart';
import 'package:new_piiink/constants/global_colors.dart';
import 'package:new_piiink/constants/number_formatter.dart';
import 'package:new_piiink/constants/style.dart';
import 'package:new_piiink/features/wallet/services/dio_wallet.dart';
import 'package:new_piiink/models/response/merchant_get_my_wallet.dart';
import 'package:outline_gradient_button/outline_gradient_button.dart';
import 'package:new_piiink/generated/l10n.dart';

import '../../../constants/app_image_string.dart';

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
  List<String> sort = ['Sort by Alphabetical', 'Sort by Piiink Credits'];
  List<String> walletTypeDropdownItems = ['Merchant', 'Group Merchant'];
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
      appBar: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight),
          child: CustomAppBar(
            text: S.of(context).merchantWallet,
            icon: Icons.arrow_back_ios,
            onPressed: () {
              context.pop();
            },
          )),
      body: isFirstLoading
          ? const MerchantWalletLoader()
          : err == 'Something went wrong'
              ? const Error1()
              : RefreshIndicator(
                  key: refreshIndicatorMerchantWallet,
                  color: GlobalColors.appColor,
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
                            cursorColor: GlobalColors.appColor,
                            decoration: InputDecoration(
                                hintText: S.of(context).searchMerchantWallet,
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 7),
                                suffixIcon: InkWell(
                                  onTap: () {
                                    searchController.clear();
                                    setState(() {});
                                  },
                                  child: Icon(
                                    searchController.text.isEmpty
                                        ? Icons.search
                                        : Icons.clear,
                                    color: GlobalColors.appColor,
                                  ),
                                ),
                                enabledBorder: const OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: GlobalColors.appColor)),
                                focusedBorder: const OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: GlobalColors.appColor)),
                                border: const OutlineInputBorder()),
                          ),
                        ),
                      ),

                      // --------------------------------------------------
                      // ✅ FIXED RESPONSIVE DROPDOWNS START HERE
                      // --------------------------------------------------
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10.0, vertical: 10.0),
                        child: Row(
                          children: [
                            // LEFT DROPDOWN (Wallet Type)
                            Expanded(
                              child: OutlineGradientButton(
                                padding: EdgeInsets.zero,
                                strokeWidth: 1,
                                radius: const Radius.circular(5.0),
                                backgroundColor:
                                    GlobalColors.appWhiteBackgroundColor,
                                elevation: 2,
                                gradient: const LinearGradient(
                                  colors: [
                                    GlobalColors.appColor,
                                    GlobalColors.appColor1
                                  ],
                                  begin: Alignment.topRight,
                                  end: Alignment.bottomLeft,
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton2(
                                    isExpanded: true,
                                    iconStyleData: IconStyleData(
                                      icon: const Icon(
                                        Icons.expand_more,
                                        size: 20,
                                        color: GlobalColors.appColor,
                                      ),
                                      openMenuIcon: const Icon(
                                        Icons.expand_less,
                                        size: 20,
                                        color: GlobalColors.appColor,
                                      ),
                                    ),
                                    items: walletTypeDropdownItems.map((e) {
                                      return DropdownMenuItem(
                                        value: e,
                                        child: AutoSizeText(
                                          e == 'Merchant'
                                              ? S.of(context).merchant
                                              : S.of(context).groupMerchant,
                                          style: dopdownTextStyle,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      );
                                    }).toList(),
                                    onChanged: (newValue) {
                                      setState(() {
                                        selectedWalletType = newValue!;
                                      });
                                    },
                                    value: selectedWalletType,
                                    buttonStyleData: const ButtonStyleData(
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 10),
                                      height: 50,
                                    ),
                                    dropdownStyleData: const DropdownStyleData(
                                      maxHeight: 400,
                                    ),
                                    menuItemStyleData: const MenuItemStyleData(
                                      height: 40,
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            SizedBox(width: 10.w),

                            // RIGHT DROPDOWN (Sort By)
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5.0),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton2(
                                    isExpanded: true,
                                    iconStyleData: IconStyleData(
                                      icon: const Icon(
                                        Icons.expand_more,
                                        size: 20,
                                        color: GlobalColors.appColor,
                                      ),
                                      openMenuIcon: const Icon(
                                        Icons.expand_less,
                                        size: 20,
                                        color: GlobalColors.appColor,
                                      ),
                                    ),
                                    items: sort.map((e) {
                                      return DropdownMenuItem(
                                        value: e,
                                        child: AutoSizeText(
                                          e == 'Sort by Alphabetical'
                                              ? S.of(context).sortByAlphabetical
                                              : S
                                                  .of(context)
                                                  .sortByTouristSaverCredits,
                                          style: dopdownTextStyle,
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
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 10),
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
                          ],
                        ),
                      ),
                      // --------------------------------------------------
                      // ✅ FIXED RESPONSIVE DROPDOWNS END HERE
                      // --------------------------------------------------

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
                  return OutlineGradientButton(
                    padding: const EdgeInsets.all(5.0),
                    strokeWidth: 1,
                    radius: const Radius.circular(5.0),
                    backgroundColor: GlobalColors.appWhiteBackgroundColor,
                    elevation: 2,
                    gradient: const LinearGradient(
                      colors: [GlobalColors.appColor, GlobalColors.appColor1],
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                    ),
                    child: Column(
                      children: [
                        Expanded(
                          flex: 5,
                          child: ClipRRect(
                            borderRadius: const BorderRadius.only(
                                topRight: Radius.circular(5.0),
                                topLeft: Radius.circular(5.0)),
                            child: CachedNetworkImage(
                              imageUrl: selectedWalletType == 'Merchant'
                                  ? merchantWallet.merchantImageInfo == null
                                      ? AppImageString.appNoImageURL
                                      : merchantWallet
                                              .merchantImageInfo?.logoUrl ??
                                          merchantWallet
                                              .merchantImageInfo?.slider1 ??
                                          merchantWallet
                                              .merchantImageInfo?.slider2 ??
                                          merchantWallet
                                              .merchantImageInfo?.slider3 ??
                                          merchantWallet
                                              .merchantImageInfo?.slider4 ??
                                          merchantWallet
                                              .merchantImageInfo?.slider5 ??
                                          AppImageString.appNoImageURL
                                  : merchantWallet.merchant?.logoUrl ?? '',
                              fit: BoxFit.cover,
                              width: MediaQuery.of(context).size.width / 1.3,
                              placeholder: (context, url) {
                                return const Center(
                                    child:
                                        FittedBox(child: CustomAllLoader1()));
                              },
                              errorWidget: (context, url, error) => Center(
                                  child: Image.asset(
                                      'assets/images/no_image.jpg')),
                            ),
                          ),
                        ),

                        // Merchant Name
                        Expanded(
                          flex: 2,
                          child: Tooltip(
                            message:
                                merchantWallet.merchant?.merchantName ?? '',
                            child: Padding(
                              padding: const EdgeInsets.all(5),
                              child: Align(
                                alignment: Alignment.center,
                                child: AutoSizeText(
                                  merchantWallet.merchant?.merchantName ?? '',
                                  style: merchantNameStyle.copyWith(
                                      fontSize: 16.sp),
                                ),
                              ),
                            ),
                          ),
                        ),

                        // Piiink Points in terms of Merchant
                        SizedBox(
                          height: 30,
                          child: Center(
                            child: AutoSizeText(
                              '${numFormatter.format(merchantWallet.balance!)} ${S.of(context).touristSavers}',
                              style: topicStyle.copyWith(
                                  color: GlobalColors.appColor),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ),
              // checking and loading more
              if (isLoadingMore == true)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 10.0),
                  child: CircularProgressIndicator(
                    color: GlobalColors.appColor,
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
                  return OutlineGradientButton(
                    padding: const EdgeInsets.all(5.0),
                    strokeWidth: 1,
                    radius: const Radius.circular(5.0),
                    backgroundColor: GlobalColors.appWhiteBackgroundColor,
                    elevation: 2,
                    gradient: const LinearGradient(
                      colors: [GlobalColors.appColor, GlobalColors.appColor1],
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                    ),
                    child: Column(
                      children: [
                        Expanded(
                          flex: 5,
                          child: ClipRRect(
                            borderRadius: const BorderRadius.only(
                                topRight: Radius.circular(5.0),
                                topLeft: Radius.circular(5.0)),
                            child: CachedNetworkImage(
                              imageUrl: selectedWalletType == 'Merchant'
                                  ? merchantWallet.merchantImageInfo == null
                                      ? AppImageString.appNoImageURL
                                      : merchantWallet
                                              .merchantImageInfo?.logoUrl ??
                                          merchantWallet
                                              .merchantImageInfo?.slider1 ??
                                          merchantWallet
                                              .merchantImageInfo?.slider2 ??
                                          merchantWallet
                                              .merchantImageInfo?.slider3 ??
                                          merchantWallet
                                              .merchantImageInfo?.slider4 ??
                                          merchantWallet
                                              .merchantImageInfo?.slider5 ??
                                          AppImageString.appNoImageURL
                                  : merchantWallet.merchant?.logoUrl ?? '',
                              fit: BoxFit.cover,
                              width: MediaQuery.of(context).size.width / 1.3,
                              placeholder: (context, url) {
                                return const Center(
                                    child:
                                        FittedBox(child: CustomAllLoader1()));
                              },
                              errorWidget: (context, url, error) => Center(
                                  child: Image.asset(
                                      'assets/images/no_image.jpg')),
                            ),
                          ),
                        ),

                        // Merchant Name
                        Expanded(
                          flex: 2,
                          child: Tooltip(
                            message:
                                merchantWallet.merchant?.merchantName ?? '',
                            child: Padding(
                              padding: const EdgeInsets.all(5),
                              child: Align(
                                alignment: Alignment.center,
                                child: AutoSizeText(
                                  merchantWallet.merchant?.merchantName ?? '',
                                  style: merchantNameStyle.copyWith(
                                      fontSize: 16.sp),
                                ),
                              ),
                            ),
                          ),
                        ),

                        // Piiink Points in terms of Merchant
                        SizedBox(
                          height: 30,
                          child: Center(
                            child: AutoSizeText(
                              '${toFixed2DecimalPlaces(merchantWallet.balance!)} ${S.of(context).touristSavers}',
                              style: topicStyle.copyWith(
                                  color: GlobalColors.appColor),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ),
              // checking and loading more
              if (isLoadingMore == true)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 10.0),
                  child: CircularProgressIndicator(
                    color: GlobalColors.appColor,
                    strokeWidth: 2.0,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  //nO Merchant wallet available
  noMerchantWallet() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
      child: NotAvailable(
        titleText:
            '${selectedWalletType == 'Merchant' ? S.of(context).merchant : S.of(context).groupMerchant} ${S.of(context).wallet} ${S.of(context).notAvailable}',
        bodyText: S
            .of(context)
            .firstTryShoppingWithSomeMerchantsToGainAndTransferMerchantTouristSavers,
        image: "assets/images/shopping-bag.png",
      ),
    );
  }
}
