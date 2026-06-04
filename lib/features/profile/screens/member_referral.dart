import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:touristsaver/common/widgets/custom_loader.dart';
import 'package:touristsaver/common/widgets/custom_snackbar.dart';
import 'package:touristsaver/common/widgets/error.dart';
import 'package:touristsaver/features/profile/services/dio_membership.dart';

import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import '../../../common/services/dio_common.dart';
import '../../../common/widgets/custom_app_bar.dart';
import '../../../models/response/piiink_info_res.dart';
import '../../../models/response/user_detail_res.dart';
import '../bloc/user_profile_blocs.dart';
import '../bloc/user_profile_events.dart';
import '../bloc/user_profile_states.dart';
import 'package:touristsaver/generated/l10n.dart';

const Color _referralNavy = Color(0xFF111C44);
const Color _referralMuted = Color(0xFF63708A);
const Color _referralBorder = Color(0xFFE5EAF4);

class MemberReferralScreen extends StatefulWidget {
  static const String routeName = "/memberReferral";
  const MemberReferralScreen({super.key});

  @override
  State<MemberReferralScreen> createState() => _MemberReferralScreenState();
}

class _MemberReferralScreenState extends State<MemberReferralScreen> {
  bool shareLoad = false;
  bool copyLoad = false;
  int? memRefKPI;
  int? piiinkUponMemberReferral;

  Future<void> getPiiinkInfo() async {
    PiiinkInfoResModel? piiinkInfoResModel = await DioCommon().piiinkInfo();
    setState(() {
      memRefKPI = piiinkInfoResModel?.data?.memberReferTransactionKpi;
      piiinkUponMemberReferral =
          piiinkInfoResModel?.data?.piiinkUponMemberReferral;
    });
  }

  @override
  void initState() {
    getPiiinkInfo();
    super.initState();
  }

  final DioMemberShip _dioMembership = DioMemberShip();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: CustomAppBar(
          text: S.of(context).referAFriend,
          icon: Icons.arrow_back_ios,
          onPressed: () {
            context.pop();
          },
        ),
      ),
      body: BlocProvider(
        lazy: false,
        create: (context) =>
            UserProfileBloc(_dioMembership)..add(LoadUserProfileEvent()),
        child: BlocBuilder<UserProfileBloc, UserProfileState>(
          builder: (context, state) {
            //loading state
            if (state is UserProfileLoadingState) {
              return const Column(
                children: [
                  CustomAllLoader(),
                ],
              );
            } else if (state is UserProfileLoadedState) {
              UserProfileResModel userProfile = state.userProfile;
              return userProfile.data!.results!.uniqueMemberCode == null
                  ? const Error1()
                  : _referralContent(userProfile);
            } else if (state is UserProfileErrorState) {
              return const Error1();
            } else {
              return Text(S.of(context).somethingWentWrong,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      decoration: TextDecoration.none,
                      color: Colors.black.withValues(alpha: 0.5),
                      fontFamily: 'Sans'));
            }
          },
        ),
      ),
    );
  }

  Widget _referralContent(UserProfileResModel userProfile) {
    final String memberCode = userProfile.data!.results!.uniqueMemberCode ?? '';
    final String referralLink =
        'https://app.touristsaver.org/register?memberReferralCode=$memberCode';

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _ReferralCard(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          Color(0xFFF146EA),
                          Color(0xFF18C6FF),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: const Icon(
                      Icons.card_giftcard_rounded,
                      color: Colors.white,
                      size: 25,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Invite friends to discover more with TouristSaver',
                    style: TextStyle(
                      color: _referralNavy,
                      fontSize: 24.sp,
                      fontWeight: FontWeight.w900,
                      height: 1.12,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Share your QR code or referral link with friends. When they join, they can start discovering local savings, experiences and great deals nearby.',
                    style: TextStyle(
                      color: _referralMuted,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            _ReferralCard(
              child: Column(
                children: [
                  Text(
                    'Your referral QR code',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: _referralNavy,
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Friends can scan this code to join TouristSaver.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: _referralMuted,
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 18.h),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: _referralBorder),
                    ),
                    child: QrImageView(
                      data: referralLink,
                      size: 200,
                      version: QrVersions.auto,
                      backgroundColor: Colors.white,
                    ),
                  ),
                  SizedBox(height: 14.h),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 9,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7F9FC),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: _referralBorder),
                    ),
                    child: Text(
                      memberCode,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: _referralNavy,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0,
                      ),
                    ),
                  ),
                  SizedBox(height: 18.h),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final bool stackButtons = constraints.maxWidth < 330;
                      final buttons = [
                        Expanded(
                          child: _ReferralGradientButton(
                            text: S.of(context).copyLink,
                            icon: Icons.copy_rounded,
                            isLoading: copyLoad,
                            onPressed: () {
                              setState(() {
                                copyLoad = true;
                              });
                              copyToClipboard(referralLink);
                            },
                          ),
                        ),
                        SizedBox(
                          width: stackButtons ? 0 : 10,
                          height: stackButtons ? 10 : 0,
                        ),
                        Expanded(
                          child: _ReferralGradientButton(
                            text: S.of(context).shareLink,
                            icon: Icons.ios_share_rounded,
                            isLoading: shareLoad,
                            onPressed: () {
                              setState(() {
                                shareLoad = true;
                              });
                              _onShare(context, referralLink);
                            },
                          ),
                        ),
                      ];

                      if (stackButtons) {
                        return Column(
                          children: buttons
                              .map(
                                (child) => child is Expanded
                                    ? SizedBox(
                                        width: double.infinity,
                                        child: child.child,
                                      )
                                    : child,
                              )
                              .toList(),
                        );
                      }
                      return Row(children: buttons);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            _ReferralCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color:
                              const Color(0xFF0009FE).withValues(alpha: 0.08),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.emoji_events_outlined,
                          color: Color(0xFF0009FE),
                          size: 21,
                        ),
                      ),
                      const SizedBox(width: 11),
                      Expanded(
                        child: Text(
                          'Referral rewards',
                          style: TextStyle(
                            color: _referralNavy,
                            fontSize: 17.sp,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Eligible members may be included in monthly merchant giveaway promotions.',
                    style: TextStyle(
                      color: _referralMuted,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Special major prize promotions may be announced from time to time.',
                    style: TextStyle(
                      color: _referralMuted,
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void copyToClipboard(String link) {
    FlutterClipboard.copy(link).then((value) async {
      await Future.delayed(const Duration(seconds: 2));
      setState(() {
        copyLoad = false;
      });
      GlobalSnackBar.showSuccess(context, S.of(context).linkCopiedToClipboard);
    });
  }

  void _onShare(BuildContext context, String link) async {
    await Future.delayed(const Duration(seconds: 2));
    final box = context.findRenderObject() as RenderBox?;
    await Share.share(link,
        sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size);
    setState(() {
      shareLoad = false;
    });
  }
}

class _ReferralCard extends StatelessWidget {
  const _ReferralCard({
    required this.child,
    this.padding = const EdgeInsets.all(16),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _referralBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _ReferralGradientButton extends StatelessWidget {
  const _ReferralGradientButton({
    required this.text,
    required this.icon,
    required this.onPressed,
    this.isLoading = false,
  });

  final String text;
  final IconData icon;
  final VoidCallback onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: isLoading ? null : onPressed,
        child: Ink(
          height: 50,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xFF0009FE),
                Color(0xFF18C6FF),
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0009FE).withValues(alpha: 0.18),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Center(
            child: isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.2,
                      color: Colors.white,
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(icon, color: Colors.white, size: 19),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          text,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
