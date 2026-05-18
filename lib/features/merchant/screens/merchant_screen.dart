import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:new_piiink/common/app_variables.dart';
import 'package:new_piiink/common/models/merchant_summary.dart';
import 'package:new_piiink/common/services/dio_common.dart';
import 'package:new_piiink/common/services/location_service.dart';
import 'package:new_piiink/common/widgets/custom_snackbar.dart';
import 'package:new_piiink/common/widgets/error.dart';
import 'package:new_piiink/common/widgets/merchant_result_tile.dart';
import 'package:new_piiink/constants/global_colors.dart';
import 'package:new_piiink/constants/pref.dart';
import 'package:new_piiink/constants/pref_key.dart';
import 'package:new_piiink/constants/style.dart';
import 'package:new_piiink/features/connectivity/cubit/internet_cubit.dart';
import '../../../common/widgets/empty_data.dart';
import '../../../models/response/category_list_res.dart';
import '../../connectivity/screens/connectivity.dart';
import '../../connectivity/screens/connectivity_screen.dart';
import '../../home_page/bloc/category_blocs.dart';
import '../../home_page/bloc/category_events.dart';
import '../../home_page/bloc/category_states.dart';
import '../../home_page/services/home_dio.dart';
import '../../home_page/widget/tab_container.dart';
import '../../merchant/services/dio_merchant.dart';
import 'package:new_piiink/generated/l10n.dart';

import '../../../models/request/mark_fav_req.dart';
import '../../../models/response/common_res.dart';
import '../../../models/response/piiink_info_res.dart';

class MerchantScreen extends StatefulWidget {
  static const String routeName = '/merchant-screen';
  const MerchantScreen({super.key});

  @override
  State<MerchantScreen> createState() => _MerchantScreenState();
}

class _MerchantScreenState extends State<MerchantScreen> {
  static const Color _primaryBlue = Color(0xFF0009FE);
  static const Color _cyan = Color(0xFF18C6FF);
  static const Color _headingColor = Color(0xFF111C44);
  static const Color _bodyColor = Color(0xFF63708A);
  static const Color _borderColor = Color(0xFFE2E8F3);
  static const Color _surfaceColor = Color(0xFFF7F9FC);

  final TextEditingController searchController = TextEditingController();
  // For reading the country ID and countryName
  String? counName;
  Future<PiiinkInfoResModel?>? showRecommend;
  Timer? _searchDebounce;
  int _searchRequestId = 0;
  List<MerchantSummary> _rawResults = [];
  List<MerchantSummary> _visibleResults = [];
  bool _isLoadingResults = false;
  String? _resultsTitle;
  String? _resultsError;
  String _selectedSort = 'Relevance';
  double? _selectedRadiusKm;
  String _activeSource = 'none';

  Future<PiiinkInfoResModel?> getShowRecommend() async {
    return DioCommon().piiinkInfo();
  }

  gettingLocation() async {
    counName = await Pref().readData(key: userChosenCountryStateName);
    // counName = await Pref().readData(key: userChosenLocationName);
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      context
          .read<CategoryBloc>()
          .add(LoadCategoryEvent(AppVariables.selectedLanguageNow));
      if (AppVariables.accessToken != null) {
        showRecommend = getShowRecommend();
      }
      await gettingLocation();
      setState(() {});
    });
    super.initState();
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    searchController.dispose();
    ConnectivityCubit().close();
    super.dispose();
  }

  Future<void> _loadSearch(String value) async {
    final String query = value.trim();
    final int requestId = ++_searchRequestId;
    _searchDebounce?.cancel();
    if (query.length < 3) {
      setState(() {
        _activeSource = 'none';
        _resultsTitle = null;
        _resultsError = null;
        _rawResults = [];
        _visibleResults = [];
        _isLoadingResults = false;
      });
      return;
    }

    _searchDebounce = Timer(const Duration(milliseconds: 350), () async {
      if (!mounted) return;
      setState(() {
        _activeSource = 'search';
        _resultsTitle = 'Search results';
        _resultsError = null;
        _isLoadingResults = true;
      });

      final response = await DioHome().getSearched(name: query);
      if (!mounted ||
          requestId != _searchRequestId ||
          searchController.text.trim() != query ||
          _activeSource != 'search') {
        return;
      }
      final summaries = (response?.merchants ?? [])
          .map(
            (merchant) => MerchantSummaryAdapters.fromSearchMerchant(
              merchant,
              currentLatitude: AppVariables.latitude,
              currentLongitude: AppVariables.longitude,
            ),
          )
          .whereType<MerchantSummary>()
          .toList();

      setState(() {
        _rawResults = summaries;
        _isLoadingResults = false;
        _applyFiltersAndSort();
      });
    });
  }

  Future<void> _loadCategory(int categoryId, String categoryName) async {
    FocusManager.instance.primaryFocus?.unfocus();
    _searchDebounce?.cancel();
    _searchRequestId++;
    setState(() {
      _activeSource = 'category';
      _resultsTitle = categoryName;
      _resultsError = null;
      _isLoadingResults = true;
      searchController.clear();
    });

    final response = await DioHome().getAllMerchant(
      pageNumber: 1,
      categoryId: categoryId,
    );
    if (!mounted) return;
    final summaries = (response?.data ?? [])
        .map(
          (merchant) => MerchantSummaryAdapters.fromMerchantGetAll(
            merchant,
            currentLatitude: AppVariables.latitude,
            currentLongitude: AppVariables.longitude,
            categoryLabel: categoryName,
          ),
        )
        .whereType<MerchantSummary>()
        .toList();

    setState(() {
      _rawResults = summaries;
      _isLoadingResults = false;
      _applyFiltersAndSort();
    });
  }

  Future<void> _loadNearMe() async {
    FocusManager.instance.primaryFocus?.unfocus();
    _searchDebounce?.cancel();
    _searchRequestId++;
    double? latitude = AppVariables.latitude;
    double? longitude = AppVariables.longitude;
    if (latitude == null || longitude == null) {
      setState(() {
        _activeSource = 'nearMe';
        _resultsTitle = 'Near me';
        _resultsError = null;
        _isLoadingResults = true;
        _rawResults = [];
        _visibleResults = [];
        searchController.clear();
      });

      final bool locationReady =
          await LocationService().enableLocationAndFetchCountry();
      if (!mounted) return;
      latitude = AppVariables.latitude;
      longitude = AppVariables.longitude;
      if (!locationReady || latitude == null || longitude == null) {
        setState(() {
          _isLoadingResults = false;
          _resultsError =
              'Location is needed to show nearby merchants. Try Map View or update your location.';
          _rawResults = [];
          _visibleResults = [];
        });
        return;
      }
    }

    final double radius = _selectedRadiusKm ?? 25;
    setState(() {
      _activeSource = 'nearMe';
      _resultsTitle = 'Near me';
      _resultsError = null;
      _isLoadingResults = true;
      searchController.clear();
    });

    final response = await DioHome().getNearbyOffers(
      latitude: latitude,
      longitude: longitude,
      radius: radius,
    );
    if (!mounted) return;
    final summaries = (response?.data ?? [])
        .map(MerchantSummaryAdapters.fromNearbyViewAll)
        .whereType<MerchantSummary>()
        .toList();

    setState(() {
      _rawResults = summaries;
      _isLoadingResults = false;
      _applyFiltersAndSort();
    });
  }

  Future<void> _toggleFavourite(MerchantSummary merchant) async {
    if (AppVariables.accessToken == null) return;
    final bool shouldAdd = merchant.isFavourite != true;
    dynamic response;
    if (shouldAdd) {
      response = await DioMerchant().markFavouriteMerchants(
        markFavouriteReqModel: MarkFavouriteReqModel(
          merchantId: merchant.merchantId,
        ),
      );
    } else {
      response = await DioMerchant().removeFavouriteMerchants(
        merchantID: merchant.merchantId,
      );
    }
    if (!mounted) return;

    final bool success = response is CommonResModel
        ? response.status == 'Success'
        : response is SecondCommonResModel
            ? response.status == 'Success'
            : false;

    if (!success) {
      GlobalSnackBar.showError(context, S.of(context).somethingWentWrong);
      return;
    }

    setState(() {
      _rawResults = _rawResults
          .map(
            (item) => item.merchantId == merchant.merchantId
                ? item.copyWith(isFavourite: shouldAdd)
                : item,
          )
          .toList();
      _applyFiltersAndSort();
    });
  }

  void _setSort(String sort) {
    setState(() {
      _selectedSort = sort;
      _applyFiltersAndSort();
    });
  }

  void _setRadius(double? radius) {
    setState(() {
      _selectedRadiusKm = radius;
    });
    if (_activeSource == 'nearMe') {
      _loadNearMe();
    } else {
      setState(_applyFiltersAndSort);
    }
  }

  void _clearDiscovery() {
    _searchDebounce?.cancel();
    _searchRequestId++;
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() {
      searchController.clear();
      _activeSource = 'none';
      _resultsTitle = null;
      _resultsError = null;
      _rawResults = [];
      _visibleResults = [];
      _isLoadingResults = false;
    });
  }

  void _applyFiltersAndSort() {
    List<MerchantSummary> results = List<MerchantSummary>.from(_rawResults);
    final double? radius = _selectedRadiusKm;
    if (radius != null && _activeSource != 'nearMe') {
      results = results
          .where((merchant) =>
              merchant.distanceKm != null && merchant.distanceKm! <= radius)
          .toList();
    }

    if (_selectedSort == 'Name') {
      results.sort((left, right) => left.merchantName
          .toLowerCase()
          .compareTo(right.merchantName.toLowerCase()));
    } else if (_selectedSort == 'Distance') {
      results.sort((left, right) {
        final double leftDistance = left.distanceKm ?? double.infinity;
        final double rightDistance = right.distanceKm ?? double.infinity;
        return leftDistance.compareTo(rightDistance);
      });
    }

    _visibleResults = results;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _surfaceColor,
      appBar: PreferredSize(
        preferredSize: Size(MediaQuery.of(context).size.width, 86),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 10, 18, 12),
            child: Row(
              children: [
                Image.asset(
                  'assets/images/tourist.png',
                  width: 112,
                  height: 42,
                  fit: BoxFit.contain,
                ),
                const Spacer(),
                _LocationChip(
                  label: counName ?? '...',
                  onTap: () {
                    context.pushNamed('location').then((value) {
                      gettingLocation().then((_) {
                        if (mounted) setState(() {});
                      });
                    });
                  },
                ),
                if (AppVariables.accessToken != null) ...[
                  const SizedBox(width: 8),
                  _RecommendOverflow(
                    showRecommend: showRecommend,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
      body: BlocBuilder<ConnectivityCubit, ConnectivityState>(
        builder: (context, state) {
          if (state == ConnectivityState.loading) {
            return const NoInternetLoader();
          } else if (state == ConnectivityState.disconnected) {
            return const NoConnectivityScreen();
          } else if (state == ConnectivityState.connected) {
            return Stack(
              alignment: Alignment.center,
              children: [
                SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(18, 16, 18, 0),
                        child: _SearchEntryCard(
                          controller: searchController,
                          onChanged: _loadSearch,
                          onSubmitted: _loadSearch,
                          onClear: _clearDiscovery,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 18),
                        child: _DiscoveryActions(
                          onNearMe: _loadNearMe,
                          onMapView: () => context.pushNamed(
                            'map-view-merchant',
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 18),
                        child: Text(
                          'Browse categories',
                          style: topicStyle.copyWith(
                            color: _headingColor,
                            fontSize: 20,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      BlocBuilder<CategoryBloc, CategoryState>(
                        builder: (context, state) {
                          if (state is CategoryLoadingState) {
                            return SizedBox(
                              height: 125,
                              child: ListView.separated(
                                  scrollDirection: Axis.horizontal,
                                  padding: const EdgeInsets.only(
                                      left: 10.0, right: 10.0),
                                  separatorBuilder: (context, index) {
                                    return const SizedBox(width: 20);
                                  },
                                  itemCount: 10,
                                  itemBuilder: (context, index) {
                                    return const TabContainer(
                                        icon: '', text: '...');
                                  }),
                            );
                          } else if (state is CategoryLoadedState) {
                            CategoryListResModel categoryList =
                                state.categoryList;
                            return SizedBox(
                              height:
                                  categoryList.data!.data!.isEmpty ? 50 : 125,
                              child: categoryList.data!.data!.isEmpty
                                  ? EmptyData(
                                      text: S.of(context).noCategoryFound)
                                  : ListView.separated(
                                      scrollDirection: Axis.horizontal,
                                      padding: const EdgeInsets.only(
                                          left: 10.0, right: 10.0),
                                      separatorBuilder: (context, index) {
                                        return const SizedBox(width: 20);
                                      },
                                      itemCount:
                                          categoryList.data!.data!.length,
                                      itemBuilder: (context, index) {
                                        return InkWell(
                                          onTap: () {
                                            final category =
                                                categoryList.data!.data![index];
                                            final int? categoryId = category.id;
                                            final String categoryName =
                                                category.name ?? '';
                                            if (categoryId == null) return;
                                            _loadCategory(
                                              categoryId,
                                              categoryName,
                                            );
                                          },
                                          child: TabContainer(
                                            icon: categoryList
                                                .data!.data![index].imageName!,
                                            text: categoryList
                                                .data!.data![index].name!,
                                          ),
                                        );
                                      }),
                            );
                          } else if (state is CategoryErrorState) {
                            return const Padding(
                              padding: EdgeInsets.only(bottom: 10.0),
                              child: Error(),
                            );
                          } else {
                            return const SizedBox();
                          }
                        },
                      ),
                      const SizedBox(height: 28),
                      if (_activeSource != 'none' ||
                          _isLoadingResults ||
                          _resultsError != null) ...[
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 18),
                          child: _FilterSortBar(
                            selectedSort: _selectedSort,
                            selectedRadiusKm: _selectedRadiusKm,
                            onSortSelected: _setSort,
                            onRadiusSelected: _setRadius,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 18),
                          child: _MerchantResultsSection(
                            title: _resultsTitle ?? 'Results',
                            isLoading: _isLoadingResults,
                            error: _resultsError,
                            merchants: _visibleResults,
                            onClear: _clearDiscovery,
                            onMerchantTap: (merchant) {
                              context.pushNamed('details-screen', extra: {
                                'merchantID': merchant.merchantId.toString(),
                              }).then((value) {
                                if (value == true && mounted) {
                                  setState(() {});
                                }
                              });
                            },
                            onFavouriteTap: _toggleFavourite,
                          ),
                        ),
                        const SizedBox(height: 28),
                      ],
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 18),
                        child: _HelperCard(
                          title: 'Find savings faster',
                          body:
                              'Search by merchant name, browse a category, or open the map when you are nearby.',
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ],
            );
          } else {
            return const SizedBox();
          }
        },
      ),
    );
  }
}

class _RecommendOverflow extends StatelessWidget {
  const _RecommendOverflow({required this.showRecommend});

  final Future<PiiinkInfoResModel?>? showRecommend;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PiiinkInfoResModel?>(
      future: showRecommend,
      builder: (context, snapshot) {
        if (snapshot.hasError || !snapshot.hasData) {
          return const SizedBox();
        }
        if (snapshot.data?.data?.hideReferredMerchantInApp != false) {
          return const SizedBox();
        }
        return PopupMenuButton<String>(
          tooltip: S.of(context).recommendNewMerchant,
          icon: const Icon(
            Icons.more_horiz,
            color: _MerchantScreenState._primaryBlue,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          onSelected: (value) {
            if (value == 'recommend') {
              context.pushNamed('recommend');
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'recommend',
              child: Text(S.of(context).recommendNewMerchant),
            ),
          ],
        );
      },
    );
  }
}

class _LocationChip extends StatelessWidget {
  const _LocationChip({
    required this.label,
    required this.onTap,
  });

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 150),
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: _MerchantScreenState._borderColor),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.location_on_rounded,
              color: _MerchantScreenState._primaryBlue,
              size: 18,
            ),
            const SizedBox(width: 5),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: textStyle15.copyWith(
                  color: _MerchantScreenState._headingColor,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchEntryCard extends StatelessWidget {
  const _SearchEntryCard({
    required this.controller,
    required this.onChanged,
    required this.onSubmitted,
    required this.onClear,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onSubmitted;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _MerchantScreenState._borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: _MerchantScreenState._primaryBlue.withValues(
                alpha: 0.08,
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.search_rounded,
              color: _MerchantScreenState._primaryBlue,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: controller,
              textInputAction: TextInputAction.search,
              cursorColor: _MerchantScreenState._primaryBlue,
              onChanged: onChanged,
              onSubmitted: onSubmitted,
              decoration: InputDecoration(
                border: InputBorder.none,
                isDense: true,
                hintText: 'Search merchants',
                hintStyle: searchStyle.copyWith(
                  color: _MerchantScreenState._bodyColor,
                  fontSize: 15,
                ),
              ),
              style: textStyle15.copyWith(
                color: _MerchantScreenState._headingColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: controller,
            builder: (context, value, child) {
              if (value.text.isEmpty) {
                return const Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: _MerchantScreenState._primaryBlue,
                  size: 17,
                );
              }
              return IconButton(
                visualDensity: VisualDensity.compact,
                onPressed: onClear,
                icon: const Icon(
                  Icons.close_rounded,
                  color: _MerchantScreenState._bodyColor,
                  size: 20,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _FilterSortBar extends StatelessWidget {
  const _FilterSortBar({
    required this.selectedSort,
    required this.selectedRadiusKm,
    required this.onSortSelected,
    required this.onRadiusSelected,
  });

  final String selectedSort;
  final double? selectedRadiusKm;
  final ValueChanged<String> onSortSelected;
  final ValueChanged<double?> onRadiusSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _DiscoveryChip(
              label: 'Relevance',
              selected: selectedSort == 'Relevance',
              onTap: () => onSortSelected('Relevance'),
            ),
            _DiscoveryChip(
              label: 'Distance',
              selected: selectedSort == 'Distance',
              onTap: () => onSortSelected('Distance'),
            ),
            _DiscoveryChip(
              label: 'Name',
              selected: selectedSort == 'Name',
              onTap: () => onSortSelected('Name'),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _DiscoveryChip(
              label: 'Any distance',
              selected: selectedRadiusKm == null,
              onTap: () => onRadiusSelected(null),
            ),
            for (final radius in const [5.0, 10.0, 25.0, 50.0])
              _DiscoveryChip(
                label: '${radius.toInt()} km',
                selected: selectedRadiusKm == radius,
                onTap: () => onRadiusSelected(radius),
              ),
          ],
        ),
      ],
    );
  }
}

class _DiscoveryChip extends StatelessWidget {
  const _DiscoveryChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? _MerchantScreenState._primaryBlue : Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected
                ? _MerchantScreenState._primaryBlue
                : _MerchantScreenState._borderColor,
          ),
        ),
        child: Text(
          label,
          style: searchStyle.copyWith(
            color: selected ? Colors.white : _MerchantScreenState._bodyColor,
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

class _MerchantResultsSection extends StatelessWidget {
  const _MerchantResultsSection({
    required this.title,
    required this.isLoading,
    required this.error,
    required this.merchants,
    required this.onClear,
    required this.onMerchantTap,
    required this.onFavouriteTap,
  });

  final String title;
  final bool isLoading;
  final String? error;
  final List<MerchantSummary> merchants;
  final VoidCallback onClear;
  final ValueChanged<MerchantSummary> onMerchantTap;
  final ValueChanged<MerchantSummary> onFavouriteTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _MerchantScreenState._borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: topicStyle.copyWith(
                    color: _MerchantScreenState._headingColor,
                    fontSize: 19,
                  ),
                ),
              ),
              TextButton(
                onPressed: onClear,
                child: const Text(
                  'Clear',
                  style: TextStyle(color: _MerchantScreenState._primaryBlue),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 18),
                child: CircularProgressIndicator(
                  color: GlobalColors.loaderColor,
                  strokeWidth: 2,
                ),
              ),
            )
          else if (error != null)
            Text(
              error!,
              style: searchStyle.copyWith(
                color: _MerchantScreenState._bodyColor,
                height: 1.35,
              ),
            )
          else if (merchants.isEmpty)
            Text(
              'No matching merchants found. Try another search, category or distance.',
              style: searchStyle.copyWith(
                color: _MerchantScreenState._bodyColor,
                height: 1.35,
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: merchants.length,
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final merchant = merchants[index];
                return MerchantResultTile(
                  merchant: merchant,
                  onTap: () => onMerchantTap(merchant),
                  onFavouriteTap: AppVariables.accessToken == null ||
                          merchant.isFavourite == null
                      ? null
                      : () => onFavouriteTap(merchant),
                );
              },
            ),
        ],
      ),
    );
  }
}

class _DiscoveryActions extends StatelessWidget {
  const _DiscoveryActions({
    required this.onNearMe,
    required this.onMapView,
  });

  final VoidCallback onNearMe;
  final VoidCallback onMapView;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _DiscoveryActionCard(
            icon: Icons.near_me_rounded,
            title: 'Near me',
            subtitle: 'Use current location',
            onTap: onNearMe,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _DiscoveryActionCard(
            icon: Icons.map_rounded,
            title: S.of(context).mapView,
            subtitle: 'Explore by area',
            onTap: onMapView,
          ),
        ),
      ],
    );
  }
}

class _DiscoveryActionCard extends StatelessWidget {
  const _DiscoveryActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: _MerchantScreenState._borderColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    _MerchantScreenState._primaryBlue,
                    _MerchantScreenState._cyan,
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.white, size: 20),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: textStyle15.copyWith(
                color: _MerchantScreenState._headingColor,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: searchStyle.copyWith(
                color: _MerchantScreenState._bodyColor,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HelperCard extends StatelessWidget {
  const _HelperCard({
    required this.title,
    required this.body,
  });

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _MerchantScreenState._primaryBlue.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: _MerchantScreenState._primaryBlue.withValues(alpha: 0.08),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.tips_and_updates_outlined,
            color: _MerchantScreenState._primaryBlue,
            size: 22,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: textStyle15.copyWith(
                    color: _MerchantScreenState._headingColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  body,
                  style: searchStyle.copyWith(
                    color: _MerchantScreenState._bodyColor,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
