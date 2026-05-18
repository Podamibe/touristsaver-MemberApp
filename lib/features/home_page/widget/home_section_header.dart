import 'package:flutter/material.dart';

class HomeSectionHeader extends StatelessWidget {
  const HomeSectionHeader({
    super.key,
    required this.title,
    this.onViewAllTap,
    this.viewAllLabel = 'View All',
  });

  final String title;
  final VoidCallback? onViewAllTap;
  final String viewAllLabel;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 4,
            height: 18,
            decoration: BoxDecoration(
              color: const Color(0xFF0009FE),
              borderRadius: BorderRadius.circular(99),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF111C44),
              fontSize: 18,
              fontWeight: FontWeight.w900,
              fontFamily: 'Sans',
            ),
          ),
          if (onViewAllTap != null) ...[
            const SizedBox(width: 12),
            InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: onViewAllTap,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 2,
                  vertical: 4,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      viewAllLabel,
                      style: const TextStyle(
                        color: Color(0xFF0009FE),
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        fontFamily: 'Sans',
                      ),
                    ),
                    const SizedBox(width: 3),
                    const Icon(
                      Icons.arrow_forward_ios,
                      size: 12,
                      color: Color(0xFF0009FE),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
