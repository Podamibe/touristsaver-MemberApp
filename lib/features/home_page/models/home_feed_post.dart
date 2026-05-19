import 'dart:convert';

class HomeFeedPost {
  const HomeFeedPost({
    required this.id,
    this.title,
    this.caption,
    this.mediaType,
    this.mediaUrl,
    this.thumbnailUrl,
    this.merchant,
    this.externalUrl,
    this.externalUrlLabel,
    this.category,
    this.subcategory,
    this.isSponsored = false,
    this.sponsorLabel,
    this.likesCount,
    this.commentsCount,
    this.createdAt,
  });

  final String id;
  final String? title;
  final String? caption;
  final String? mediaType;
  final String? mediaUrl;
  final String? thumbnailUrl;
  final HomeFeedMerchant? merchant;
  final String? externalUrl;
  final String? externalUrlLabel;
  final String? category;
  final String? subcategory;
  final bool isSponsored;
  final String? sponsorLabel;
  final int? likesCount;
  final int? commentsCount;
  final DateTime? createdAt;

  bool get isVideo => mediaType?.toLowerCase().trim() == 'video';

  bool get isImage => mediaType?.toLowerCase().trim() == 'image';

  String? get previewUrl {
    if (isVideo) return _firstNotEmpty([thumbnailUrl, mediaUrl]);
    return _firstNotEmpty([mediaUrl, thumbnailUrl]);
  }

  String? get merchantName => merchant?.name;

  String? get label {
    return _joinLabels([
      merchantName,
      subcategory,
      category,
    ]);
  }

  factory HomeFeedPost.fromJson(Map<String, dynamic> json) {
    return HomeFeedPost(
      id: _string(json['id']) ?? '',
      title: _string(json['title']),
      caption: _string(json['caption']),
      mediaType: _string(json['mediaType']),
      mediaUrl: _string(json['mediaUrl']),
      thumbnailUrl: _string(json['thumbnailUrl']),
      merchant: HomeFeedMerchant.fromValue(json['merchant']),
      externalUrl: _string(json['externalUrl']),
      externalUrlLabel: _string(json['externalUrlLabel']),
      category: _labelFromValue(json['category']),
      subcategory: _labelFromValue(json['subcategory']),
      isSponsored: _bool(json['isSponsored']),
      sponsorLabel: _string(json['sponsorLabel']),
      likesCount: _int(json['likesCount']),
      commentsCount: _int(json['commentsCount']),
      createdAt: _dateTime(json['createdAt']),
    );
  }

  static List<HomeFeedPost> listFromResponse(dynamic responseBody) {
    if (responseBody == null) return const [];
    final dynamic decoded =
        responseBody is String ? json.decode(responseBody) : responseBody;
    final dynamic postsJson = _extractPostsList(decoded);
    if (postsJson is! List) return const [];

    return postsJson
        .whereType<Map>()
        .map((json) => HomeFeedPost.fromJson(Map<String, dynamic>.from(json)))
        .where((post) => post.id.trim().isNotEmpty)
        .toList(growable: false);
  }

  static dynamic _extractPostsList(dynamic decoded) {
    if (decoded is List) return decoded;
    if (decoded is! Map) return null;

    final dynamic data = decoded['data'];
    if (data is List) return data;
    if (data is Map) {
      return data['data'] ?? data['posts'] ?? data['results'];
    }
    return decoded['posts'] ?? decoded['results'];
  }

  static String? _labelFromValue(dynamic value) {
    if (value is String) return _string(value);
    if (value is Map) {
      return _string(value['name']) ??
          _string(value['title']) ??
          _string(value['label']) ??
          _string(value['slug']);
    }
    return null;
  }
}

class HomeFeedMerchant {
  const HomeFeedMerchant({
    this.id,
    this.name,
  });

  final int? id;
  final String? name;

  static HomeFeedMerchant? fromValue(dynamic value) {
    if (value == null) return null;
    if (value is num || value is String) {
      return HomeFeedMerchant(id: _int(value), name: _string(value));
    }
    if (value is! Map) return null;

    return HomeFeedMerchant(
      id: _int(value['id'] ?? value['merchantId'] ?? value['xId']),
      name: _string(
        value['merchantName'] ??
            value['name'] ??
            value['businessName'] ??
            value['title'],
      ),
    );
  }
}

String? _string(dynamic value) {
  if (value == null) return null;
  final String stringValue = value.toString().trim();
  return stringValue.isEmpty || stringValue == 'null' ? null : stringValue;
}

int? _int(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString());
}

bool _bool(dynamic value) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  if (value is String) return value.toLowerCase().trim() == 'true';
  return false;
}

DateTime? _dateTime(dynamic value) {
  final String? dateValue = _string(value);
  return dateValue == null ? null : DateTime.tryParse(dateValue);
}

String? _firstNotEmpty(List<String?> values) {
  for (final String? value in values) {
    final String? cleaned = _string(value);
    if (cleaned != null) return cleaned;
  }
  return null;
}

String? _joinLabels(List<String?> values) {
  final labels =
      values.map(_string).whereType<String>().toSet().toList(growable: false);
  return labels.isEmpty ? null : labels.join(' · ');
}
