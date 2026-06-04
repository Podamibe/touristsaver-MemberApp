import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:touristsaver/common/utils.dart';
import 'package:touristsaver/constants/global_colors.dart';
import 'package:touristsaver/features/home_page/models/home_feed_post.dart';
import 'package:touristsaver/features/home_page/services/home_feed_dio.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeFeedSection extends StatefulWidget {
  const HomeFeedSection({super.key});

  @override
  State<HomeFeedSection> createState() => _HomeFeedSectionState();
}

class _HomeFeedSectionState extends State<HomeFeedSection> {
  late final Future<List<HomeFeedPost>> _postsFuture;

  @override
  void initState() {
    super.initState();
    _postsFuture = DioHomeFeed().getPosts();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<HomeFeedPost>>(
      future: _postsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const _HomeFeedLoading();
        }

        if (snapshot.hasError) {
          return const _HomeFeedMessage(
            icon: Icons.explore_off_rounded,
            title: 'Feed unavailable',
            message: 'Check back soon for more local inspiration.',
          );
        }

        final List<HomeFeedPost> posts = snapshot.data ?? const [];
        if (posts.isEmpty) {
          return const _HomeFeedMessage(
            icon: Icons.travel_explore_rounded,
            title: 'No stories yet',
            message: 'Fresh travel ideas will appear here soon.',
          );
        }

        return Padding(
          padding: EdgeInsets.fromLTRB(12.w, 0, 12.w, 4.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(left: 2.w, bottom: 10.h),
                child: Text(
                  'Explore what is on',
                  style: TextStyle(
                    color: const Color(0xFF111C44),
                    fontSize: 19.sp,
                    fontWeight: FontWeight.w800,
                    fontFamily: 'Montserrat',
                    letterSpacing: 0,
                  ),
                ),
              ),
              ListView.separated(
                itemCount: posts.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: EdgeInsets.zero,
                separatorBuilder: (context, index) => SizedBox(height: 18.h),
                itemBuilder: (context, index) {
                  return _HomeFeedCard(post: posts[index]);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class _HomeFeedCard extends StatelessWidget {
  const _HomeFeedCard({required this.post});

  final HomeFeedPost post;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8.r),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _handleTap(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _FeedMedia(post: post),
            Padding(
              padding: EdgeInsets.fromLTRB(14.w, 12.h, 14.w, 14.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _FeedMetaRow(post: post),
                  if (post.title != null) ...[
                    SizedBox(height: 8.h),
                    Text(
                      post.title!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: const Color(0xFF111C44),
                        fontSize: 18.sp,
                        height: 1.18,
                        fontWeight: FontWeight.w800,
                        fontFamily: 'Montserrat',
                        letterSpacing: 0,
                      ),
                    ),
                  ],
                  if (post.caption != null) ...[
                    SizedBox(height: 7.h),
                    Text(
                      post.caption!,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: const Color(0xFF596780),
                        fontSize: 13.sp,
                        height: 1.35,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Sans',
                        letterSpacing: 0,
                      ),
                    ),
                  ],
                  if (_hasStats) ...[
                    SizedBox(height: 12.h),
                    _FeedStatsRow(post: post),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool get _hasStats => post.likesCount != null || post.commentsCount != null;

  Future<void> _handleTap(BuildContext context) async {
    final int? merchantId = post.merchant?.id;
    if (merchantId != null) {
      context.pushNamed('details-screen', extra: {
        'merchantID': merchantId.toString(),
      });
      return;
    }

    final String? externalUrl = post.externalUrl;
    if (externalUrl == null || externalUrl.trim().isEmpty) return;

    final Uri uri = Uri.parse(prefixHttp(externalUrl));
    try {
      final bool launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched) {
        debugPrint('Could not launch home feed URL: $uri');
      }
    } catch (e) {
      debugPrint('Could not launch home feed URL: $uri, $e');
    }
  }
}

class _FeedMedia extends StatelessWidget {
  const _FeedMedia({required this.post});

  final HomeFeedPost post;

  @override
  Widget build(BuildContext context) {
    final String? previewUrl = post.previewUrl;
    return AspectRatio(
      aspectRatio: 16 / 10,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            color: const Color(0xFFEAF0F8),
            child: previewUrl == null
                ? _fallback()
                : CachedNetworkImage(
                    imageUrl: previewUrl,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => const Center(
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.2,
                          color: Color(0xFF0009FE),
                        ),
                      ),
                    ),
                    errorWidget: (context, url, error) => _fallback(),
                  ),
          ),
          if (post.isVideo)
            Center(
              child: Container(
                width: 58.w,
                height: 58.w,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.42),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                ),
                child: Icon(
                  Icons.play_arrow_rounded,
                  color: Colors.white,
                  size: 36.sp,
                ),
              ),
            ),
          if (post.isSponsored)
            Positioned(
              top: 12.h,
              left: 12.w,
              child: _SponsoredPill(
                label: post.sponsorLabel ?? 'Sponsored',
              ),
            ),
        ],
      ),
    );
  }

  Widget _fallback() {
    return Image.asset('assets/images/no_image.jpg', fit: BoxFit.cover);
  }
}

class _FeedMetaRow extends StatelessWidget {
  const _FeedMetaRow({required this.post});

  final HomeFeedPost post;

  @override
  Widget build(BuildContext context) {
    final String? label = post.label;
    final String? actionLabel =
        post.merchant?.id == null ? post.externalUrlLabel : null;
    return Row(
      children: [
        if (label != null)
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: const Color(0xFF0009FE),
                fontSize: 12.sp,
                fontWeight: FontWeight.w800,
                fontFamily: 'Sans',
                letterSpacing: 0,
              ),
            ),
          )
        else
          const Spacer(),
        if (actionLabel != null) ...[
          SizedBox(width: 8.w),
          Flexible(
            child: Text(
              actionLabel,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: const Color(0xFF596780),
                fontSize: 12.sp,
                fontWeight: FontWeight.w700,
                fontFamily: 'Sans',
                letterSpacing: 0,
              ),
            ),
          ),
          SizedBox(width: 5.w),
        ],
        if (post.externalUrl != null && post.merchant?.id == null)
          Icon(
            Icons.open_in_new_rounded,
            color: const Color(0xFF596780),
            size: 16.sp,
          )
        else
          Icon(
            Icons.chevron_right_rounded,
            color: const Color(0xFF596780),
            size: 20.sp,
          ),
      ],
    );
  }
}

class _FeedStatsRow extends StatelessWidget {
  const _FeedStatsRow({required this.post});

  final HomeFeedPost post;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (post.likesCount != null)
          _Stat(icon: Icons.favorite_border_rounded, value: post.likesCount!),
        if (post.likesCount != null && post.commentsCount != null)
          SizedBox(width: 14.w),
        if (post.commentsCount != null)
          _Stat(
            icon: Icons.chat_bubble_outline_rounded,
            value: post.commentsCount!,
          ),
      ],
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.icon, required this.value});

  final IconData icon;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16.sp, color: const Color(0xFF7B8798)),
        SizedBox(width: 5.w),
        Text(
          value.toString(),
          style: TextStyle(
            color: const Color(0xFF596780),
            fontSize: 12.sp,
            fontWeight: FontWeight.w700,
            fontFamily: 'Sans',
          ),
        ),
      ],
    );
  }
}

class _SponsoredPill extends StatelessWidget {
  const _SponsoredPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: Colors.white,
          fontSize: 11.sp,
          fontWeight: FontWeight.w700,
          fontFamily: 'Sans',
        ),
      ),
    );
  }
}

class _HomeFeedLoading extends StatelessWidget {
  const _HomeFeedLoading();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(12.w, 0, 12.w, 4.h),
      child: Column(
        children: List.generate(
          2,
          (index) => Padding(
            padding: EdgeInsets.only(bottom: 18.h),
            child: Container(
              height: 260.h,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2.2,
                  color: GlobalColors.appColor,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _HomeFeedMessage extends StatelessWidget {
  const _HomeFeedMessage({
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(12.w, 0, 12.w, 4.h),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 22.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Column(
          children: [
            Icon(icon, color: const Color(0xFF7B8798), size: 28.sp),
            SizedBox(height: 8.h),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: const Color(0xFF111C44),
                fontSize: 15.sp,
                fontWeight: FontWeight.w800,
                fontFamily: 'Montserrat',
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: const Color(0xFF596780),
                fontSize: 12.sp,
                height: 1.35,
                fontWeight: FontWeight.w500,
                fontFamily: 'Sans',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
