import 'package:new_piiink/common/models/merchant_summary.dart';

enum MerchantDiscoverySource {
  none,
  search,
  category,
  nearMe,
}

class MerchantDiscoveryState {
  const MerchantDiscoveryState({
    this.source = MerchantDiscoverySource.none,
    this.searchText = '',
    this.selectedCategoryId,
    this.selectedCategoryName,
    this.selectedRadiusKm,
    this.selectedSort = 'Distance',
    this.bestOfferFirst = false,
    this.isLoading = false,
    this.error,
    this.results = const [],
    this.pendingFavouriteMerchantIds = const {},
  });

  static const Object _unset = Object();

  final MerchantDiscoverySource source;
  final String searchText;
  final int? selectedCategoryId;
  final String? selectedCategoryName;
  final double? selectedRadiusKm;
  final String selectedSort;
  final bool bestOfferFirst;
  final bool isLoading;
  final String? error;
  final List<MerchantSummary> results;
  final Set<int> pendingFavouriteMerchantIds;

  bool get hasResultsPanel =>
      source != MerchantDiscoverySource.none || isLoading || error != null;

  String get title {
    if (source == MerchantDiscoverySource.search) return 'Search results';
    if (source == MerchantDiscoverySource.category) {
      return selectedCategoryName ?? 'Results';
    }
    if (source == MerchantDiscoverySource.nearMe) return 'Near me';
    return 'Results';
  }

  MerchantDiscoveryState copyWith({
    MerchantDiscoverySource? source,
    String? searchText,
    Object? selectedCategoryId = _unset,
    Object? selectedCategoryName = _unset,
    Object? selectedRadiusKm = _unset,
    String? selectedSort,
    bool? bestOfferFirst,
    bool? isLoading,
    Object? error = _unset,
    List<MerchantSummary>? results,
    Set<int>? pendingFavouriteMerchantIds,
  }) {
    return MerchantDiscoveryState(
      source: source ?? this.source,
      searchText: searchText ?? this.searchText,
      selectedCategoryId: selectedCategoryId == _unset
          ? this.selectedCategoryId
          : selectedCategoryId as int?,
      selectedCategoryName: selectedCategoryName == _unset
          ? this.selectedCategoryName
          : selectedCategoryName as String?,
      selectedRadiusKm: selectedRadiusKm == _unset
          ? this.selectedRadiusKm
          : selectedRadiusKm as double?,
      selectedSort: selectedSort ?? this.selectedSort,
      bestOfferFirst: bestOfferFirst ?? this.bestOfferFirst,
      isLoading: isLoading ?? this.isLoading,
      error: error == _unset ? this.error : error as String?,
      results: results ?? this.results,
      pendingFavouriteMerchantIds:
          pendingFavouriteMerchantIds ?? this.pendingFavouriteMerchantIds,
    );
  }
}
