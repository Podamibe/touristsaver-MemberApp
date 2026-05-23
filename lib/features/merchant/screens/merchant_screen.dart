import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:new_piiink/common/app_variables.dart';
import 'package:new_piiink/common/models/merchant_summary.dart';
import 'package:new_piiink/common/services/dio_common.dart';
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
import '../../merchant/discovery/merchant_discovery_controller.dart';
import '../../merchant/discovery/merchant_discovery_intent.dart';
import '../../merchant/discovery/merchant_discovery_state.dart';
import 'package:new_piiink/generated/l10n.dart';

import '../../../models/response/piiink_info_res.dart';
import '../../../models/response/sub_category_list_res.dart' as sub;

class MerchantScreen extends StatefulWidget {
  static const String routeName = '/merchant-screen';
  const MerchantScreen({super.key});

  @override
  State<MerchantScreen> createState() => _MerchantScreenState();
}

class _MerchantScreenState extends State<MerchantScreen> {
  static const Color _primaryBlue = Color(0xFF0009FE);
  static const Color _headingColor = Color(0xFF111C44);
  static const Color _bodyColor = Color(0xFF63708A);
  static const Color _borderColor = Color(0xFFE2E8F3);
  static const Color _surfaceColor = Color(0xFFF7F9FC);

  late final MerchantDiscoveryController _discovery;
  final TextEditingController searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  int? _scheduledLaunchIntentToken;
  // For reading the country ID and countryName
  String? counName;
  Future<PiiinkInfoResModel?>? showRecommend;

  Future<PiiinkInfoResModel?> getShowRecommend() async {
    return DioCommon().piiinkInfo();
  }

  gettingLocation() async {
    counName = await Pref().readData(key: userChosenCountryStateName);
    // counName = await Pref().readData(key: userChosenLocationName);
  }

  @override
  void initState() {
    _discovery = MerchantDiscoveryController();
    _discovery.addListener(_handleDiscoveryChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      context
          .read<CategoryBloc>()
          .add(LoadCategoryEvent(AppVariables.selectedLanguageNow));
      if (AppVariables.accessToken != null) {
        showRecommend = getShowRecommend();
      }
      await gettingLocation();
      if (!mounted) return;
      setState(() {});
    });
    super.initState();
  }

  @override
  void dispose() {
    _discovery.removeListener(_handleDiscoveryChanged);
    _discovery.dispose();
    searchController.dispose();
    _searchFocusNode.dispose();
    ConnectivityCubit().close();
    super.dispose();
  }

  void _handleDiscoveryChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _loadSearch(String value) {
    return _discovery.loadSearch(value);
  }

  Future<void> _loadCategory(int categoryId, String categoryName) {
    FocusManager.instance.primaryFocus?.unfocus();
    searchController.clear();
    return _discovery.loadCategory(categoryId, categoryName);
  }

  Future<void> _showCategorySelector(Datum category) async {
    final int? categoryId = category.id;
    final String categoryName = category.name?.trim() ?? '';
    if (categoryId == null || categoryName.isEmpty) return;
    FocusManager.instance.primaryFocus?.unfocus();

    final Future<List<_CategorySelection>> subcategoriesFuture =
        _subcategoryOptionsFor(category);

    final _CategorySelection? selection = await showDialog<_CategorySelection>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.36),
      builder: (context) {
        return _SubcategoryDialog(
          categoryId: categoryId,
          categoryName: categoryName,
          selectedCategoryId: _discovery.state.selectedCategoryId,
          subcategoriesFuture: subcategoriesFuture,
        );
      },
    );

    if (!mounted || selection == null) return;
    await _loadCategory(selection.id, selection.name);
  }

  void _handleLaunchIntent(List<Datum> categories) {
    final MerchantDiscoveryLaunchIntent? intent =
        MerchantDiscoveryIntentStore.pendingIntent;
    if (intent == null || _scheduledLaunchIntentToken == intent.token) return;

    if (intent.focusSearch) {
      _scheduledLaunchIntentToken = intent.token;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final MerchantDiscoveryLaunchIntent? activeIntent =
            MerchantDiscoveryIntentStore.consume(intent.token);
        if (activeIntent == null) return;
        _searchFocusNode.requestFocus();
      });
      return;
    }

    if (intent.showBestOffers) {
      _scheduledLaunchIntentToken = intent.token;
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!mounted) return;
        final MerchantDiscoveryLaunchIntent? activeIntent =
            MerchantDiscoveryIntentStore.consume(intent.token);
        if (activeIntent == null) return;
        FocusManager.instance.primaryFocus?.unfocus();
        searchController.clear();
        await _discovery.loadBestOffers();
      });
      return;
    }

    final int? categoryId = intent.categoryId;
    final String categoryName = intent.categoryName?.trim() ?? '';
    if (categoryId == null || categoryName.isEmpty) return;

    Datum? category;
    for (final Datum item in categories) {
      if (item.id == categoryId) {
        category = item;
        break;
      }
    }
    category ??= Datum(
      id: categoryId,
      name: categoryName,
      children: const [],
    );

    _scheduledLaunchIntentToken = intent.token;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      final MerchantDiscoveryLaunchIntent? activeIntent =
          MerchantDiscoveryIntentStore.consume(intent.token);
      if (activeIntent == null) return;
      if (kDebugMode) {
        debugPrint(
          '[MerchantDiscovery] Consumed launch intent: '
          'categoryId=${activeIntent.categoryId}, '
          'categoryName=${activeIntent.categoryName}, '
          'openSubcategorySelector=${activeIntent.openSubcategorySelector}',
        );
      }
      if (activeIntent.openSubcategorySelector) {
        await _showCategorySelector(category!);
      } else {
        final int? activeCategoryId = activeIntent.categoryId;
        final String activeCategoryName =
            activeIntent.categoryName?.trim() ?? '';
        if (activeCategoryId == null || activeCategoryName.isEmpty) return;
        await _loadCategory(activeCategoryId, activeCategoryName);
      }
    });
  }

  Future<List<_CategorySelection>> _subcategoryOptionsFor(
      Datum category) async {
    final int parentId = category.id!;
    final String parentName = category.name?.trim() ?? '';
    if (kDebugMode) {
      debugPrint(
        '[MerchantDiscovery] Category tapped: id=$parentId, '
        'name=$parentName, children=${category.children?.length ?? 0}',
      );
    }

    final List<_CategorySelection> childOptions =
        _categoryChildrenOptions(category, parentId, parentName);
    if (childOptions.isNotEmpty) {
      if (kDebugMode) {
        debugPrint(
          '[MerchantDiscovery] Using parsed category children for '
          '$parentName: ${childOptions.length}',
        );
      }
      return childOptions;
    }

    final sub.SubCategoryListResModel? response =
        await DioHome().getSubCategory(parentId);
    final List<_CategorySelection> fallbackOptions = (response?.data ?? [])
        .where(
          (item) => _isRealSubcategory(
            id: item.id,
            name: item.name,
            parentId: parentId,
            parentName: parentName,
          ),
        )
        .map(
          (item) => _CategorySelection(
            id: item.id!,
            name: item.name!.trim(),
          ),
        )
        .toList();
    if (kDebugMode) {
      debugPrint(
        '[MerchantDiscovery] Subcategory fallback for $parentName: '
        'status=${response?.status}, raw=${response?.data?.length ?? 0}, '
        'usable=${fallbackOptions.length}',
      );
    }
    return fallbackOptions;
  }

  List<_CategorySelection> _categoryChildrenOptions(
    Datum category,
    int parentId,
    String parentName,
  ) {
    return (category.children ?? [])
        .where(
          (item) => _isRealSubcategory(
            id: item.id,
            name: item.name,
            parentId: parentId,
            parentName: parentName,
          ),
        )
        .map(
          (item) => _CategorySelection(
            id: item.id!,
            name: item.name!.trim(),
          ),
        )
        .toList();
  }

  bool _isRealSubcategory({
    required int? id,
    required String? name,
    required int parentId,
    required String parentName,
  }) {
    final String cleanName = name?.trim() ?? '';
    final String normalizedName = cleanName.toLowerCase();
    final String normalizedParentName = parentName.toLowerCase();
    final String parentLikeAllName = 'all $normalizedParentName';
    return id != null &&
        id != parentId &&
        cleanName.isNotEmpty &&
        normalizedName != normalizedParentName &&
        normalizedName != parentLikeAllName;
  }

  Future<void> _toggleFavourite(MerchantSummary merchant) async {
    final bool success = await _discovery.toggleFavourite(merchant);
    if (!mounted) return;
    if (!success) {
      GlobalSnackBar.showError(
        context,
        'Could not update favourite. Please try again.',
      );
    }
  }

  void _setSort(String sort) {
    _discovery.setSort(sort);
  }

  void _setRadius(double? radius) {
    _discovery.setRadius(radius);
  }

  void _setBestOfferFirst(bool value) {
    _discovery.setBestOfferFirst(value);
  }

  void _openResultsMap(List<MerchantSummary> merchants, String title) {
    final List<MerchantSummary> mappableMerchants =
        merchants.where((merchant) => merchant.hasLocation).toList();
    if (mappableMerchants.isEmpty) return;

    FocusManager.instance.primaryFocus?.unfocus();
    context.pushNamed(
      'map-view-merchant',
      extra: {
        'title': title,
        'merchants': mappableMerchants,
      },
    ).then((value) {
      if (value == true && mounted) {
        setState(() {});
      }
    });
  }

  void _clearDiscovery() {
    FocusManager.instance.primaryFocus?.unfocus();
    searchController.clear();
    _discovery.clear();
  }

  @override
  Widget build(BuildContext context) {
    final MerchantDiscoveryState discoveryState = _discovery.state;
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
                        padding: const EdgeInsets.fromLTRB(18, 6, 18, 0),
                        child: _SearchEntryCard(
                          controller: searchController,
                          focusNode: _searchFocusNode,
                          onChanged: _loadSearch,
                          onSubmitted: _loadSearch,
                          onClear: _clearDiscovery,
                        ),
                      ),
                      const SizedBox(height: 8),
                      BlocBuilder<CategoryBloc, CategoryState>(
                        builder: (context, state) {
                          if (state is CategoryLoadingState) {
                            return SizedBox(
                              height: 96,
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
                            final List<Datum> categories =
                                categoryList.data?.data ?? [];
                            _handleLaunchIntent(categories);
                            return SizedBox(
                              height: categories.isEmpty ? 50 : 96,
                              child: categories.isEmpty
                                  ? EmptyData(
                                      text: S.of(context).noCategoryFound)
                                  : ListView.separated(
                                      scrollDirection: Axis.horizontal,
                                      padding: const EdgeInsets.only(
                                          left: 10.0, right: 10.0),
                                      separatorBuilder: (context, index) {
                                        return const SizedBox(width: 20);
                                      },
                                      itemCount: categories.length,
                                      itemBuilder: (context, index) {
                                        return InkWell(
                                          onTap: () {
                                            final category = categories[index];
                                            final int? categoryId = category.id;
                                            if (categoryId == null) return;
                                            _showCategorySelector(category);
                                          },
                                          child: TabContainer(
                                            icon: categories[index].imageName!,
                                            text: categories[index].name!,
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
                      const SizedBox(height: 10),
                      if (discoveryState.hasResultsPanel) ...[
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 18),
                          child: _FilterSortBar(
                            selectedSort: discoveryState.selectedSort,
                            selectedRadiusKm: discoveryState.selectedRadiusKm,
                            bestOfferFirst: discoveryState.bestOfferFirst,
                            onSortSelected: _setSort,
                            onRadiusSelected: _setRadius,
                            onBestOfferChanged: _setBestOfferFirst,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 18),
                          child: _MerchantResultsSection(
                            title: discoveryState.title,
                            isLoading: discoveryState.isLoading,
                            error: discoveryState.error,
                            merchants: discoveryState.results,
                            pendingFavouriteMerchantIds:
                                discoveryState.pendingFavouriteMerchantIds,
                            onClear: _clearDiscovery,
                            onMapView: () => _openResultsMap(
                              discoveryState.results,
                              discoveryState.title,
                            ),
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
                        const SizedBox(height: 18),
                      ],
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 18),
                        child: _HelperCard(
                          title: 'Find savings faster',
                          body:
                              'Search by merchant name, browse a category, then use distance filters to refine nearby offers.',
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

class _CategorySelection {
  const _CategorySelection({
    required this.id,
    required this.name,
  });

  final int id;
  final String name;
}

class _SubcategoryDialog extends StatelessWidget {
  const _SubcategoryDialog({
    required this.categoryId,
    required this.categoryName,
    required this.selectedCategoryId,
    required this.subcategoriesFuture,
  });

  final int categoryId;
  final String categoryName;
  final int? selectedCategoryId;
  final Future<List<_CategorySelection>> subcategoriesFuture;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
      backgroundColor: Colors.transparent,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.72,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: _MerchantScreenState._surfaceColor,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.16),
                blurRadius: 24,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Choose $categoryName type',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: topicStyle.copyWith(
                        color: _MerchantScreenState._headingColor,
                        fontSize: 20,
                      ),
                    ),
                  ),
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(
                      Icons.close_rounded,
                      color: _MerchantScreenState._primaryBlue,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Refine merchant results without leaving discovery.',
                style: searchStyle.copyWith(
                  color: _MerchantScreenState._bodyColor,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 14),
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  padding: EdgeInsets.zero,
                  children: [
                    _SubcategoryOptionTile(
                      label: 'All $categoryName',
                      selected: selectedCategoryId == categoryId,
                      onTap: () {
                        Navigator.of(context).pop(
                          _CategorySelection(
                            id: categoryId,
                            name: categoryName,
                          ),
                        );
                      },
                    ),
                    FutureBuilder<List<_CategorySelection>>(
                      future: subcategoriesFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 18),
                            child: Center(
                              child: SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: GlobalColors.loaderColor,
                                ),
                              ),
                            ),
                          );
                        }

                        final subcategories =
                            snapshot.data ?? const <_CategorySelection>[];

                        if (subcategories.isEmpty) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: Text(
                              'No subcategories available.',
                              style: searchStyle.copyWith(
                                color: _MerchantScreenState._bodyColor,
                              ),
                            ),
                          );
                        }

                        return Column(
                          children: subcategories.map((item) {
                            return _SubcategoryOptionTile(
                              label: item.name,
                              selected: selectedCategoryId == item.id,
                              onTap: () {
                                Navigator.of(context).pop(
                                  item,
                                );
                              },
                            );
                          }).toList(),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SubcategoryOptionTile extends StatelessWidget {
  const _SubcategoryOptionTile({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: selected
                ? _MerchantScreenState._primaryBlue.withValues(alpha: 0.08)
                : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected
                  ? _MerchantScreenState._primaryBlue
                  : _MerchantScreenState._borderColor,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: textStyle15.copyWith(
                    color: _MerchantScreenState._headingColor,
                    fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                  ),
                ),
              ),
              if (selected)
                const Icon(
                  Icons.check_circle_rounded,
                  color: _MerchantScreenState._primaryBlue,
                  size: 20,
                )
              else
                const Icon(
                  Icons.chevron_right_rounded,
                  color: _MerchantScreenState._bodyColor,
                  size: 20,
                ),
            ],
          ),
        ),
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
    required this.focusNode,
    required this.onChanged,
    required this.onSubmitted,
    required this.onClear,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
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
              focusNode: focusNode,
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
    required this.bestOfferFirst,
    required this.onSortSelected,
    required this.onRadiusSelected,
    required this.onBestOfferChanged,
  });

  final String selectedSort;
  final double? selectedRadiusKm;
  final bool bestOfferFirst;
  final ValueChanged<String> onSortSelected;
  final ValueChanged<double?> onRadiusSelected;
  final ValueChanged<bool> onBestOfferChanged;

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
              label: 'Best Offer',
              selected: bestOfferFirst,
              onTap: () => onBestOfferChanged(!bestOfferFirst),
            ),
            _DiscoveryChip(
              label: 'Favourites',
              selected: selectedSort == 'Favourites',
              onTap: () => onSortSelected('Favourites'),
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
        const SizedBox(height: 6),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _DiscoveryChip(
              label: 'Any distance',
              selected: selectedRadiusKm == null,
              onTap: () => onRadiusSelected(null),
            ),
            for (final radius in const [5.0, 15.0, 50.0])
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
    required this.pendingFavouriteMerchantIds,
    required this.onClear,
    required this.onMapView,
    required this.onMerchantTap,
    required this.onFavouriteTap,
  });

  final String title;
  final bool isLoading;
  final String? error;
  final List<MerchantSummary> merchants;
  final Set<int> pendingFavouriteMerchantIds;
  final VoidCallback onClear;
  final VoidCallback onMapView;
  final ValueChanged<MerchantSummary> onMerchantTap;
  final ValueChanged<MerchantSummary> onFavouriteTap;

  @override
  Widget build(BuildContext context) {
    final bool canShowMap = !isLoading &&
        error == null &&
        merchants.any((merchant) => merchant.hasLocation);

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
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: topicStyle.copyWith(
                    color: _MerchantScreenState._headingColor,
                    fontSize: 19,
                  ),
                ),
              ),
              if (canShowMap)
                TextButton.icon(
                  onPressed: onMapView,
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    minimumSize: const Size(0, 40),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  icon: const Icon(
                    Icons.map_outlined,
                    size: 18,
                    color: _MerchantScreenState._primaryBlue,
                  ),
                  label: const Text(
                    'Map View',
                    style: TextStyle(color: _MerchantScreenState._primaryBlue),
                  ),
                ),
              TextButton(
                onPressed: onClear,
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  minimumSize: const Size(0, 40),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
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
                  isFavouritePending:
                      pendingFavouriteMerchantIds.contains(merchant.merchantId),
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
