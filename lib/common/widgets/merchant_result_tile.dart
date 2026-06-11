import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:touristsaver/common/models/merchant_summary.dart';
import 'package:touristsaver/common/widgets/merchant_distance.dart';

class MerchantResultTile extends StatelessWidget {
  const MerchantResultTile({
    super.key,
    required this.merchant,
    required this.onTap,
    this.onFavouriteTap,
    this.showFavourite = true,
    this.isFavouritePending = false,
  });

  static const Color _primaryBlue = Color(0xFF0009FE);
  static const Color _headingColor = Color(0xFF111C44);
  static const Color _bodyColor = Color(0xFF63708A);
  static const Color _borderColor = Color(0xFFE2E8F3);

  final MerchantSummary merchant;
  final VoidCallback onTap;
  final VoidCallback? onFavouriteTap;
  final bool showFavourite;
  final bool isFavouritePending;

  @override
  Widget build(BuildContext context) {
    final String distanceLabel = formatMerchantDistance(merchant.distanceKm);
    final String? secondaryLabel = _secondaryLabel(distanceLabel);

    return InkWell(
      borderRadius: BorderRadius.circular(16.r),
      onTap: onTap,
      child: Container(
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
            _MerchantAvatar(imageUrl: merchant.imageUrl ?? merchant.logoUrl),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    merchant.merchantName,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: _headingColor,
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w800,
                      fontFamily: 'Sans',
                    ),
                  ),
                  if (secondaryLabel != null) ...[
                    SizedBox(height: 5.h),
                    Text(
                      secondaryLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: _bodyColor,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Sans',
                      ),
                    ),
                  ],
                  if (merchant.openStatusLabel != null &&
                      merchant.openStatusLabel!.trim().isNotEmpty) ...[
                    SizedBox(height: 4.h),
                    Text(
                      merchant.openStatusLabel!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: _openStatusColor(merchant.openStatus),
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Sans',
                      ),
                    ),
                  ],
                ],
              ),
            ),
            SizedBox(width: 8.w),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (showFavourite)
                  if (isFavouritePending)
                    SizedBox(
                      width: 22.sp,
                      height: 22.sp,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2,
                        color: _primaryBlue,
                      ),
                    )
                  else if (onFavouriteTap != null)
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      constraints: const BoxConstraints(),
                      padding: EdgeInsets.zero,
                      onPressed: onFavouriteTap,
                      icon: Icon(
                        merchant.isFavourite == true
                            ? Icons.favorite
                            : Icons.favorite_border,
                        color: _primaryBlue,
                        size: 22.sp,
                      ),
                    ),
                SizedBox(height: 8.h),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: _primaryBlue,
                  size: 16.sp,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String? _secondaryLabel(String distanceLabel) {
    final labels = <String>[
      if (distanceLabel.isNotEmpty) distanceLabel,
      if (merchant.areaLabel != null && merchant.areaLabel!.trim().isNotEmpty)
        merchant.areaLabel!.trim(),
      if (merchant.categoryLabel != null &&
          merchant.categoryLabel!.trim().isNotEmpty)
        merchant.categoryLabel!.trim(),
    ];
    return labels.isEmpty ? null : labels.join(' · ');
  }

  Color _openStatusColor(String? status) {
    if (status?.toLowerCase() == 'open') return const Color(0xFF2E8B57);
    return _bodyColor;
  }
}

class _MerchantAvatar extends StatelessWidget {
  const _MerchantAvatar({required this.imageUrl});

  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final String? url =
        imageUrl == null || imageUrl!.trim().isEmpty ? null : imageUrl!.trim();
    return ClipRRect(
      borderRadius: BorderRadius.circular(14.r),
      child: Container(
        width: 66.w,
        height: 66.w,
        color: const Color(0xFFF2F6FC),
        child: url == null
            ? _fallbackImage()
            : CachedNetworkImage(
                imageUrl: url,
                fit: BoxFit.cover,
                placeholder: (context, url) => const Center(
                  child: SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Color(0xFF009FE3),
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => _fallbackImage(),
              ),
      ),
    );
  }

  Widget _fallbackImage() {
    return Image.asset('assets/images/no_image.jpg', fit: BoxFit.cover);
  }
}
