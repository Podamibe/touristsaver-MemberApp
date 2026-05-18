String formatMerchantDistance(num? distanceKm) {
  if (distanceKm == null) return '';

  final double distance = distanceKm.toDouble();
  if (distance.isNaN || distance.isInfinite) return '';

  if (distance < 1) {
    return '${(distance * 1000).round()} m';
  }

  if (distance < 100) {
    return '${distance.toStringAsFixed(1)} km';
  }

  return '${distance.round()} km';
}
