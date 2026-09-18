import 'dart:convert';

import 'package:touristsaver/constants/pref.dart';
import 'package:touristsaver/constants/pref_key.dart';

class DiscoveryMembershipContext {
  const DiscoveryMembershipContext({
    this.isActive = true,
    this.entitlementId,
    this.campaignId,
    this.campaignName,
    this.invitationName,
    this.communityGroupName,
    this.sourceType,
    this.sourceName,
    this.communityName,
    this.invitationSource,
    this.entitlementStartDate,
    this.entitlementExpiryDate,
    this.periodDays,
    this.savingsCapAmount,
    this.savingsCapAmountMinor,
    this.currencyCode,
    this.currencySymbol,
    this.savingsDiscoveredAmount,
    this.savingsConsumedAmountMinor,
    this.inheritanceEnabled = false,
    this.maximumInvitationGeneration,
    this.generation = 0,
    this.status,
    this.endReason,
    this.endedAt,
    this.continuation,
  });

  final bool isActive;
  final int? entitlementId;
  final int? campaignId;
  final String? campaignName;
  final String? invitationName;
  final String? communityGroupName;
  final String? sourceType;
  final String? sourceName;
  final String? communityName;
  final String? invitationSource;
  final DateTime? entitlementStartDate;
  final DateTime? entitlementExpiryDate;
  final int? periodDays;
  final double? savingsCapAmount;
  final int? savingsCapAmountMinor;
  final String? currencyCode;
  final String? currencySymbol;
  final double? savingsDiscoveredAmount;
  final int? savingsConsumedAmountMinor;
  final bool inheritanceEnabled;
  final int? maximumInvitationGeneration;
  final int generation;
  final String? status;
  final String? endReason;
  final DateTime? endedAt;
  final DiscoveryPremiumContinuation? continuation;

  String get displayCommunityName =>
      invitationName ??
      communityGroupName ??
      sourceName ??
      communityName ??
      campaignName ??
      'the TouristSaver Community';

  String get displayCurrency {
    if (currencySymbol != null) return currencySymbol!;
    switch (currencyCode) {
      case 'AUD':
        return r'A$';
      case 'NZD':
        return r'NZ$';
      case 'USD':
        return r'$';
      default:
        return currencyCode ?? '';
    }
  }

  double? get effectiveSavingsCapAmount => savingsCapAmountMinor != null
      ? savingsCapAmountMinor! / 100
      : savingsCapAmount;

  double? get effectiveSavingsConsumedAmount =>
      savingsConsumedAmountMinor != null
          ? savingsConsumedAmountMinor! / 100
          : savingsDiscoveredAmount;

  int? daysRemaining({DateTime? now}) {
    final DateTime? expiry = entitlementExpiryDate ??
        (entitlementStartDate != null && periodDays != null
            ? entitlementStartDate!.add(Duration(days: periodDays!))
            : null);
    if (expiry == null) return null;
    final DateTime today = _dateOnly(now ?? DateTime.now());
    final DateTime expiryDay = _dateOnly(expiry);
    final int remaining = expiryDay.difference(today).inDays;
    return remaining < 0 ? 0 : remaining;
  }

  Map<String, dynamic> toRouteExtra() => toJson();

  DiscoveryMembershipContext withAcceptedPremiumContinuation() {
    final DiscoveryPremiumContinuation? current = continuation;
    if (current == null || current.accepted) return this;
    return DiscoveryMembershipContext.fromJson({
      ...toJson(),
      'continuation': {
        ...current.toJson(),
        'eligible': false,
        'status': 'accepted',
      },
    });
  }

  Map<String, dynamic> toJson() => {
        'isActive': isActive,
        'entitlementId': entitlementId,
        'campaignId': campaignId,
        'campaignName': campaignName,
        'invitationName': invitationName,
        'communityGroupName': communityGroupName,
        'sourceType': sourceType,
        'sourceName': sourceName,
        'communityName': communityName,
        'invitationSource': invitationSource,
        'entitlementStartDate': entitlementStartDate?.toIso8601String(),
        'entitlementExpiryDate': entitlementExpiryDate?.toIso8601String(),
        'periodDays': periodDays,
        'savingsCapAmount': savingsCapAmount,
        'savingsCapAmountMinor': savingsCapAmountMinor,
        'currencyCode': currencyCode,
        'currencySymbol': currencySymbol,
        'savingsDiscoveredAmount': savingsDiscoveredAmount,
        'savingsConsumedAmountMinor': savingsConsumedAmountMinor,
        'allowsMemberInvites': inheritanceEnabled,
        'maximumInvitationGeneration': maximumInvitationGeneration,
        'generation': generation,
        'status': status,
        'endReason': endReason,
        'endedAt': endedAt?.toIso8601String(),
        'continuation': continuation?.toJson(),
      };

  factory DiscoveryMembershipContext.fromRouteExtra(
    Map<String, dynamic> extra,
  ) =>
      DiscoveryMembershipContext.fromJson(extra);

  factory DiscoveryMembershipContext.fromJson(Map<String, dynamic> json) {
    return DiscoveryMembershipContext(
      isActive: _bool(json, const ['active', 'isActive']) ?? true,
      entitlementId: _int(json, const ['entitlementId']),
      campaignId: _int(json, const ['campaignId']),
      campaignName: _string(json, const ['campaignName', 'campaign_name']),
      invitationName:
          _string(json, const ['invitationName', 'invitation_name']),
      communityGroupName: _string(
        json,
        const ['communityGroupName', 'community_group_name'],
      ),
      sourceType: _string(json, const ['sourceType', 'source_type']),
      sourceName: _string(json, const ['sourceName', 'source_name']),
      communityName: _string(json, const [
        'communityName',
        'community_name',
        'groupName',
        'group_name',
        'organisationName',
        'organizationName',
      ]),
      invitationSource: _string(json, const [
        'invitationSource',
        'invitation_source',
        'source',
      ]),
      entitlementStartDate: _date(json, const [
        'entitlementStartDate',
        'entitlement_start_date',
        'startDate',
        'startsAt',
      ]),
      entitlementExpiryDate: _date(json, const [
        'entitlementExpiryDate',
        'entitlement_expiry_date',
        'expiryDate',
        'expiresAt',
        'endDate',
      ]),
      periodDays: _int(json, const [
        'membershipDays',
        'discoveryPeriodDays',
        'discovery_period_days',
        'periodDays',
        'days',
      ]),
      savingsCapAmount: _double(json, const [
        'savingsCapAmount',
        'savings_cap_amount',
        'savingsCap',
        'maximumSavings',
      ]),
      savingsCapAmountMinor: _int(json, const [
        'savingsCapMinor',
        'savingsCapAmountMinor',
        'discoverySavingsCapAmountMinor',
      ]),
      currencyCode: _string(json, const [
        'savingsCapCurrency',
        'currencyCode',
        'currency',
      ]),
      currencySymbol: _string(json, const ['currencySymbol']),
      savingsDiscoveredAmount: _double(json, const [
        'savingsDiscoveredAmount',
        'savings_discovered_amount',
        'savingsDiscovered',
        'verifiedSavings',
      ]),
      savingsConsumedAmountMinor: _int(
          json, const ['savingsConsumedMinor', 'savingsConsumedAmountMinor']),
      inheritanceEnabled: _bool(json, const [
            'allowMemberInvitations',
            'allowsMemberInvites',
            'campaignInheritanceEnabled',
            'inheritanceEnabled',
            'memberInvitationEligible',
            'canInviteMembers',
          ]) ??
          false,
      maximumInvitationGeneration:
          _int(json, const ['maximumInvitationGeneration']),
      generation: _int(json, const ['invitationGeneration', 'generation']) ?? 0,
      status: _string(json, const ['status']),
      endReason: _string(json, const ['endReason']),
      endedAt: _date(json, const ['endedAt']),
      continuation: json['continuation'] is Map
          ? DiscoveryPremiumContinuation.fromJson(
              Map<String, dynamic>.from(json['continuation'] as Map),
            )
          : null,
    );
  }

  static DiscoveryMembershipContext? fromRegistrationJson(
    Map<String, dynamic> json,
  ) {
    final String membershipType =
        (_value(json, const ['membershipType', 'memberType', 'tier']) ?? '')
            .toString()
            .trim()
            .toLowerCase();
    final bool explicitDiscovery = membershipType == 'discovery' ||
        membershipType == 'discovery_membership' ||
        _bool(json, const ['isDiscoveryMember', 'discoveryMember']) == true;

    const containerKeys = [
      'discoveryMembership',
      'discoveryEntitlement',
      'discovery',
      'campaignInvitation',
      'campaignEntitlement',
    ];
    Map<String, dynamic>? payload;
    for (final String key in containerKeys) {
      final dynamic value = json[key];
      if (value is Map) {
        payload = Map<String, dynamic>.from(value);
        break;
      }
    }
    if (!explicitDiscovery && payload == null) return null;
    return DiscoveryMembershipContext.fromJson({...json, ...?payload});
  }

  static DateTime _dateOnly(DateTime value) =>
      DateTime(value.year, value.month, value.day);

  static dynamic _value(Map<String, dynamic> json, List<String> keys) {
    for (final String key in keys) {
      final dynamic value = json[key];
      if (value != null && value.toString().trim().isNotEmpty) return value;
    }
    return null;
  }

  static String? _string(Map<String, dynamic> json, List<String> keys) {
    final String value = _value(json, keys)?.toString().trim() ?? '';
    return value.isEmpty || value.toLowerCase() == 'null' ? null : value;
  }

  static int? _int(Map<String, dynamic> json, List<String> keys) {
    final dynamic value = _value(json, keys);
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '');
  }

  static double? _double(Map<String, dynamic> json, List<String> keys) {
    final dynamic value = _value(json, keys);
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '');
  }

  static DateTime? _date(Map<String, dynamic> json, List<String> keys) {
    final dynamic value = _value(json, keys);
    if (value is DateTime) return value;
    return DateTime.tryParse(value?.toString() ?? '');
  }

  static bool? _bool(Map<String, dynamic> json, List<String> keys) {
    final dynamic value = _value(json, keys);
    if (value is bool) return value;
    if (value is num) return value != 0;
    final String normalized = value?.toString().trim().toLowerCase() ?? '';
    if (normalized == 'true' || normalized == 'yes' || normalized == '1') {
      return true;
    }
    if (normalized == 'false' || normalized == 'no' || normalized == '0') {
      return false;
    }
    return null;
  }
}

bool usesDiscoverySavingsWording({
  required DiscoveryMembershipContext? discoveryMembership,
  required DateTime? premiumExpiryDate,
  DateTime? now,
}) {
  final bool hasActivePremium =
      premiumExpiryDate?.isAfter(now ?? DateTime.now()) ?? false;
  return discoveryMembership != null &&
      discoveryMembership.continuation?.accepted != true &&
      !hasActivePremium;
}

class DiscoveryPremiumContinuation {
  const DiscoveryPremiumContinuation({
    required this.eligible,
    required this.status,
    required this.complimentary,
    required this.membershipPackageId,
    required this.priceAmountMinor,
    required this.currency,
  });

  final bool eligible;
  final String status;
  final bool complimentary;
  final int? membershipPackageId;
  final int? priceAmountMinor;
  final String? currency;

  bool get accepted => status == 'accepted';

  String get displayCurrency {
    switch (currency) {
      case 'AUD':
        return r'A$';
      case 'NZD':
        return r'NZ$';
      case 'USD':
        return r'$';
      default:
        return currency ?? '';
    }
  }

  String get displayPrice => complimentary
      ? 'Complimentary'
      : '$displayCurrency${((priceAmountMinor ?? 0) / 100).toStringAsFixed(2)}';

  factory DiscoveryPremiumContinuation.fromJson(Map<String, dynamic> json) =>
      DiscoveryPremiumContinuation(
        eligible:
            DiscoveryMembershipContext._bool(json, const ['eligible']) ?? false,
        status: DiscoveryMembershipContext._string(json, const ['status']) ??
            'not_offered',
        complimentary:
            DiscoveryMembershipContext._bool(json, const ['complimentary']) ??
                false,
        membershipPackageId: DiscoveryMembershipContext._int(
            json, const ['membershipPackageId']),
        priceAmountMinor:
            DiscoveryMembershipContext._int(json, const ['priceAmountMinor']),
        currency: DiscoveryMembershipContext._string(json, const ['currency']),
      );

  Map<String, dynamic> toJson() => {
        'eligible': eligible,
        'status': status,
        'complimentary': complimentary,
        'membershipPackageId': membershipPackageId,
        'priceAmountMinor': priceAmountMinor,
        'currency': currency,
      };
}

class DiscoveryMembershipStore {
  const DiscoveryMembershipStore();

  Future<void> save(DiscoveryMembershipContext context) => Pref().writeData(
        key: discoveryMembershipPreferenceKey,
        value: jsonEncode(context.toJson()),
      );

  Future<DiscoveryMembershipContext?> read() async {
    final String? encoded =
        await Pref().readData(key: discoveryMembershipPreferenceKey);
    if (encoded == null || encoded.trim().isEmpty) return null;
    try {
      final dynamic decoded = jsonDecode(encoded);
      return decoded is Map
          ? DiscoveryMembershipContext.fromJson(
              Map<String, dynamic>.from(decoded),
            )
          : null;
    } catch (_) {
      return null;
    }
  }

  Future<void> clear() => Pref().removeData(discoveryMembershipPreferenceKey);
}
