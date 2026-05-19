// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'dart:math' as math;

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:new_piiink/common/models/merchant_summary.dart';
import 'package:new_piiink/common/widgets/custom_loader.dart';
import 'package:new_piiink/common/widgets/merchant_result_tile.dart';
import 'package:new_piiink/constants/global_colors.dart';
import 'package:new_piiink/constants/style.dart';
import 'package:new_piiink/features/home_page/services/home_dio.dart';
import 'package:new_piiink/models/response/search_merchant_res.dart';
import '../../../common/app_variables.dart';
import 'package:new_piiink/generated/l10n.dart';

import '../../../common/widgets/error.dart';

class SearchMerchant extends StatefulWidget {
  static const String routeName = '/search-merchant';
  const SearchMerchant({super.key});

  @override
  State<SearchMerchant> createState() => _SearchMerchantState();
}

class _SearchMerchantState extends State<SearchMerchant> {
  static const Color _primaryBlue = Color(0xFF0009FE);
  static const Color _headingColor = Color(0xFF111C44);
  static const Color _bodyColor = Color(0xFF63708A);
  static const Color _borderColor = Color(0xFFE2E8F3);

  final searchKey = GlobalKey<FormState>();
  final TextEditingController _searchController = TextEditingController();
  final Map<String, Future<List<MerchantCategory>>> _categoryFilterCache = {};
  // bool isSearching = false;
  String searchText = '';
  //For page Loading part
  bool isSearchedChanged = false;
  String? err;
  bool recallMerchantApi = false;
  bool locationPinClicked = false;
  String _selectedSort = 'Relevance';
  double? _selectedRadiusKm;

  Future<SearchMerchantResModel?>? listOfMerchantAndCategory;
  Future<SearchMerchantResModel?> getSearchMerchantAndCategory() async {
    SearchMerchantResModel? searchMerchantResModel =
        await DioHome().getSearched(name: searchText);

    return searchMerchantResModel;
  }

  loadSearchedList() async {
    if (!mounted) return;
    setState(() {
      isSearchedChanged = true;
    });
    try {
      listOfMerchantAndCategory = getSearchMerchantAndCategory();
    } catch (e) {
      if (kDebugMode) {
        err = S.of(context).somethingWentWrong;
      }
    }
    setState(() {
      if (!mounted) return;
      isSearchedChanged = false;
    });
  }

// Declare the Timer
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        context.pop(recallMerchantApi);
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          flexibleSpace: Container(
            decoration: BoxDecoration(
                color: GlobalColors.appGreyBackgroundColor,
                boxShadow: [
                  BoxShadow(
                      color: Colors.grey.withValues(alpha: 0.2),
                      spreadRadius: 1,
                      blurRadius: 4,
                      offset: const Offset(2, 2))
                ]),
          ),
          elevation: 0.0,
          leadingWidth: 42,
          titleSpacing: 0,
          leading: InkWell(
              onTap: () {
                context.pop(recallMerchantApi);
              },
              child: const Icon(Icons.arrow_back_ios)),
          // automaticallyImplyLeading: false, //To remove the leading icon
          title: appBarSearch(),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (searchText.isNotEmpty) ...[
                  _searchControls(),
                  SizedBox(height: 16.h),
                ],
                searchCategoryAndMerchant(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  //AppBar Serach Section
  appBarSearch() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 42.h,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(color: _borderColor),
            ),
            child: Row(
              children: [
                SizedBox(width: 10.w),
                const Icon(
                  Icons.search,
                  size: 21,
                  color: _primaryBlue,
                ),
                Expanded(
                  child: Form(
                    key: searchKey,
                    child: TextFormField(
                      controller: _searchController,
                      autofocus: true,
                      textAlignVertical: TextAlignVertical.center,
                      cursorColor: _primaryBlue,
                      decoration: InputDecoration(
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 11.w,
                          vertical: 11.h,
                        ),
                        border: InputBorder.none,
                        hintText: 'Search',
                        hintStyle: searchStyle.copyWith(color: _bodyColor),
                        suffixIcon: InkWell(
                          borderRadius: BorderRadius.circular(999),
                          onTap: () {
                            // isSearching = false;
                            _debounce?.cancel();
                            _searchController.clear();
                            err = null;
                            FocusManager.instance.primaryFocus?.unfocus();
                            setState(() {
                              searchText = '';
                              listOfMerchantAndCategory = null;
                              isSearchedChanged = false;
                            });
                          },
                          child: const Icon(
                            Icons.clear,
                            size: 20,
                          ),
                        ),
                        suffixIconColor: _bodyColor,
                      ),
                      onChanged: (value) async {
                        setState(() {
                          searchText = value.trim();
                        });
                        if (_debounce?.isActive ?? false) _debounce!.cancel();
                        _debounce =
                            Timer(const Duration(milliseconds: 500), () {
                          err = null;
                          if (value.trim().length >= 3) {
                            loadSearchedList();
                          } else {
                            setState(() {
                              // isSearching = false;
                              searchText = '';
                            });
                          }
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(width: 8.w),
        GestureDetector(
          onTap: () {
            // locationPinClicked = true;
            context.pushNamed('location-search-merchant').then((value) {
              if (AppVariables.locationEnabledStatus.value > 1 &&
                  value == true) {
                AppVariables.locationEnabledStatus.value += 1;
              }
            });
          },
          child: Container(
            height: 42.h,
            padding: EdgeInsets.symmetric(horizontal: 10.w),
            decoration: BoxDecoration(
              color: const Color(0xFFF4F8FF),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: _borderColor),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.near_me_outlined,
                  color: _primaryBlue,
                  size: 17,
                ),
                SizedBox(width: 4.w),
                Text(
                  'Near me',
                  style: TextStyle(
                    color: _headingColor,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w800,
                    fontFamily: 'Sans',
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  searchCategoryAndMerchant() {
    return searchText.isEmpty
        ? const SizedBox()
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FutureBuilder<SearchMerchantResModel?>(
                future: listOfMerchantAndCategory,
                builder: (context, state) {
                  if (state.hasError) {
                    return const Error1();
                  } else if (!state.hasData) {
                    return const Center(child: CustomAllLoader());
                  } else {
                    final merchantCategories =
                        state.data!.merchantCategories ?? [];
                    final merchants = state.data!.merchants ?? [];
                    final visibleMerchants = _visibleMerchants(merchants);
                    final visibleMerchantSummaries = visibleMerchants
                        .map(
                          (merchant) =>
                              MerchantSummaryAdapters.fromSearchMerchant(
                            merchant,
                            currentLatitude: AppVariables.latitude,
                            currentLongitude: AppVariables.longitude,
                          ),
                        )
                        .whereType<MerchantSummary>()
                        .toList();
                    final hasUnfilteredMerchantMatches = merchants.isNotEmpty;
                    final hasMerchantMatches =
                        visibleMerchantSummaries.isNotEmpty;

                    return FutureBuilder<List<MerchantCategory>>(
                      future: _categoriesWithMerchants(merchantCategories),
                      builder: (context, categoryState) {
                        final visibleCategories =
                            categoryState.data ?? const <MerchantCategory>[];
                        final bool isCheckingCategories =
                            categoryState.connectionState ==
                                    ConnectionState.waiting &&
                                merchantCategories.isNotEmpty;
                        final bool hasCategoryMatches =
                            visibleCategories.isNotEmpty;

                        if (!hasCategoryMatches &&
                            !hasMerchantMatches &&
                            !isCheckingCategories) {
                          return _searchEmptyState(
                            title: hasUnfilteredMerchantMatches &&
                                    _selectedRadiusKm != null
                                ? 'No nearby merchants found'
                                : null,
                            message: hasUnfilteredMerchantMatches &&
                                    _selectedRadiusKm != null
                                ? 'Try increasing the search radius.'
                                : null,
                          );
                        }
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (hasMerchantMatches) ...[
                              _sectionTitle(S.of(context).merchant),
                              SizedBox(height: 10.h),
                              ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                separatorBuilder: (context, index) {
                                  return SizedBox(height: 10.h);
                                },
                                itemCount: visibleMerchantSummaries.length,
                                itemBuilder: (context, index) {
                                  final merchant =
                                      visibleMerchantSummaries[index];
                                  return MerchantResultTile(
                                    merchant: merchant,
                                    showFavourite: false,
                                    onTap: () {
                                      context
                                          .pushNamed('details-screen', extra: {
                                        'merchantID':
                                            merchant.merchantId.toString(),
                                      }).then((value) {
                                        if (value == true) {
                                          if (recallMerchantApi == false) {
                                            recallMerchantApi = true;
                                          }
                                          loadSearchedList();
                                        }
                                      });
                                    },
                                  );
                                },
                              ),
                              SizedBox(height: 18.h),
                            ] else if (hasCategoryMatches) ...[
                              _sectionTitle(S.of(context).merchant),
                              SizedBox(height: 10.h),
                              _searchEmptyState(
                                title: hasUnfilteredMerchantMatches &&
                                        _selectedRadiusKm != null
                                    ? 'No nearby merchants found'
                                    : 'No direct merchant matches. Try the matching category below.',
                                message: hasUnfilteredMerchantMatches &&
                                        _selectedRadiusKm != null
                                    ? 'Try increasing the search radius.'
                                    : null,
                              ),
                              SizedBox(height: 18.h),
                            ],
                            if (hasCategoryMatches) ...[
                              _sectionTitle(S.of(context).merchantCategories),
                              SizedBox(height: 10.h),
                              ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                separatorBuilder: (context, index) {
                                  return SizedBox(height: 10.h);
                                },
                                itemCount: visibleCategories.length,
                                itemBuilder: (context, index) {
                                  return _searchResultTile(
                                    title: visibleCategories[index].name!,
                                    onTap: () {
                                      context.pushNamed('category-screen',
                                          pathParameters: {
                                            'parentId': visibleCategories[index]
                                                .id
                                                .toString(),
                                          }).then((value) {
                                        if (value == true) {
                                          if (recallMerchantApi == false) {
                                            recallMerchantApi = true;
                                          }
                                          loadSearchedList();
                                        }
                                      });
                                    },
                                  );
                                },
                              ),
                              SizedBox(height: 18.h),
                            ] else if (isCheckingCategories) ...[
                              SizedBox(height: 8.h),
                              const Center(child: CustomAllLoader()),
                              SizedBox(height: 18.h),
                            ],
                          ],
                        );
                      },
                    );
                  }
                },
              ),
            ],
          );
  }

  Widget _searchControls() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _chipRow(
          children: [
            _controlChip(
              label: 'Relevance',
              selected: _selectedSort == 'Relevance',
              onTap: () => setState(() => _selectedSort = 'Relevance'),
            ),
            _controlChip(
              label: 'Distance',
              selected: _selectedSort == 'Distance',
              onTap: () => setState(() => _selectedSort = 'Distance'),
            ),
            _controlChip(
              label: 'Name',
              selected: _selectedSort == 'Name',
              onTap: () => setState(() => _selectedSort = 'Name'),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        _chipRow(
          children: [
            _controlChip(
              label: 'Any distance',
              selected: _selectedRadiusKm == null,
              onTap: () => setState(() => _selectedRadiusKm = null),
            ),
            _controlChip(
              label: '5 km',
              selected: _selectedRadiusKm == 5,
              onTap: () => setState(() => _selectedRadiusKm = 5),
            ),
            _controlChip(
              label: '10 km',
              selected: _selectedRadiusKm == 10,
              onTap: () => setState(() => _selectedRadiusKm = 10),
            ),
            _controlChip(
              label: '25 km',
              selected: _selectedRadiusKm == 25,
              onTap: () => setState(() => _selectedRadiusKm = 25),
            ),
            _controlChip(
              label: '50 km',
              selected: _selectedRadiusKm == 50,
              onTap: () => setState(() => _selectedRadiusKm = 50),
            ),
          ],
        ),
      ],
    );
  }

  Widget _chipRow({required List<Widget> children}) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (int index = 0; index < children.length; index++) ...[
            if (index > 0) SizedBox(width: 8.w),
            children[index],
          ],
        ],
      ),
    );
  }

  Widget _controlChip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 7.h),
        decoration: BoxDecoration(
          color: selected ? _primaryBlue : Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected ? _primaryBlue : _borderColor,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : _bodyColor,
            fontSize: 12.sp,
            fontWeight: FontWeight.w800,
            fontFamily: 'Sans',
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return AutoSizeText(
      title,
      style: TextStyle(
        color: _headingColor,
        fontSize: 17.sp,
        fontWeight: FontWeight.w900,
        fontFamily: 'Sans',
      ),
    );
  }

  Widget _searchEmptyState({String? title, String? message}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: GlobalColors.appWhiteBackgroundColor,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: _borderColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _nearbyEmptyIcon(),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title ?? S.of(context).noMerchantAvailable,
                  softWrap: true,
                  style: TextStyle(
                    color: _headingColor,
                    fontSize: 14.sp,
                    height: 1.25,
                    fontWeight: FontWeight.w800,
                    fontFamily: 'Sans',
                  ),
                ),
                if (message != null && message.isNotEmpty) ...[
                  SizedBox(height: 3.h),
                  Text(
                    message,
                    softWrap: true,
                    style: TextStyle(
                      color: _bodyColor,
                      fontSize: 13.sp,
                      height: 1.3,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Sans',
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _nearbyEmptyIcon() {
    return SizedBox(
      width: 52.w,
      height: 52.w,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 48.w,
            height: 48.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _primaryBlue.withValues(alpha: 0.08),
              border: Border.all(
                color: _primaryBlue.withValues(alpha: 0.16),
              ),
            ),
          ),
          Container(
            width: 33.w,
            height: 33.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  _primaryBlue.withValues(alpha: 0.95),
                  const Color(0xFF18C6FF).withValues(alpha: 0.85),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Icon(
              Icons.location_on_outlined,
              color: Colors.white,
              size: 20.sp,
            ),
          ),
        ],
      ),
    );
  }

  Widget _searchResultTile({
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(12.r),
      onTap: onTap,
      child: Container(
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          color: GlobalColors.appWhiteBackgroundColor,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: _borderColor),
        ),
        child: ListTile(
          title: Padding(
            padding: const EdgeInsets.only(top: 3.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AutoSizeText(
                  title,
                  style: profileListStyle.copyWith(
                    color: _headingColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (subtitle != null && subtitle.isNotEmpty) ...[
                  SizedBox(height: 3.h),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: _bodyColor,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Sans',
                    ),
                  ),
                ],
              ],
            ),
          ),
          trailing: const Padding(
            padding: EdgeInsets.only(top: 3.0),
            child: Icon(
              Icons.arrow_forward_ios,
              size: 18,
              color: _primaryBlue,
            ),
          ),
        ),
      ),
    );
  }

  List<Merchant> _visibleMerchants(List<Merchant> merchants) {
    final List<Merchant> visible = merchants.where((merchant) {
      final double? radius = _selectedRadiusKm;
      if (radius == null) return true;

      final double? distance = _distanceKmFromCurrentLocation(merchant.latlon);
      return distance != null && distance <= radius;
    }).toList();

    if (_selectedSort == 'Name') {
      visible.sort((left, right) {
        return (left.merchantName ?? '')
            .toLowerCase()
            .compareTo((right.merchantName ?? '').toLowerCase());
      });
    } else if (_selectedSort == 'Distance') {
      visible.sort((left, right) {
        final double? leftDistance =
            _distanceKmFromCurrentLocation(left.latlon);
        final double? rightDistance =
            _distanceKmFromCurrentLocation(right.latlon);

        if (leftDistance == null && rightDistance == null) return 0;
        if (leftDistance == null) return 1;
        if (rightDistance == null) return -1;
        return leftDistance.compareTo(rightDistance);
      });
    }

    return visible;
  }

  double? _distanceKmFromCurrentLocation(List<double>? merchantLatLon) {
    if (merchantLatLon == null || merchantLatLon.length < 2) return null;

    final double? userLat = AppVariables.latitude;
    final double? userLon = AppVariables.longitude;
    if (userLat == null || userLon == null) return null;

    final double merchantLat = merchantLatLon[0];
    final double merchantLon = merchantLatLon[1];
    const double earthRadiusKm = 6371;
    final double dLat = _degreesToRadians(merchantLat - userLat);
    final double dLon = _degreesToRadians(merchantLon - userLon);
    final double lat1 = _degreesToRadians(userLat);
    final double lat2 = _degreesToRadians(merchantLat);

    final double a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(lat1) *
            math.cos(lat2) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    final double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadiusKm * c;
  }

  double _degreesToRadians(double degrees) {
    return degrees * math.pi / 180;
  }

  Future<List<MerchantCategory>> _categoriesWithMerchants(
    List<MerchantCategory> categories,
  ) {
    if (categories.isEmpty) {
      return Future.value(const <MerchantCategory>[]);
    }

    final String cacheKey =
        '$searchText:${_selectedRadiusKm ?? 'any'}:${categories.map((category) => category.id).join(',')}';
    return _categoryFilterCache.putIfAbsent(cacheKey, () async {
      final List<MerchantCategory> visibleCategories = [];

      for (final MerchantCategory category in categories) {
        final int? categoryId = category.id;
        if (categoryId == null) continue;

        final result = await DioHome().getAllMerchant(
          pageNumber: 1,
          categoryId: categoryId,
        );
        final categoryMerchants = result?.data ?? [];
        final hasMerchantInActiveFilters = categoryMerchants.any((merchant) {
          final double? radius = _selectedRadiusKm;
          if (radius == null) return true;

          final double? distance =
              _distanceKmFromCurrentLocation(merchant.latlon);
          return distance != null && distance <= radius;
        });

        if (hasMerchantInActiveFilters) {
          visibleCategories.add(category);
        }
      }

      return visibleCategories;
    });
  }
}
