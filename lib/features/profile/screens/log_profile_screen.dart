import 'dart:developer';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:local_auth/local_auth.dart';
import 'package:touristsaver/common/services/dio_common.dart';
import 'package:touristsaver/common/utils.dart';
import 'package:touristsaver/common/widgets/custom_app_bar.dart';
import 'package:touristsaver/common/widgets/custom_button.dart';
import 'package:touristsaver/common/widgets/custom_loader.dart';
import 'package:touristsaver/common/widgets/custom_snackbar.dart';
import 'package:touristsaver/constants/global_colors.dart';
import 'package:touristsaver/constants/pref.dart';
import 'package:touristsaver/constants/pref_key.dart';
import 'package:touristsaver/constants/style.dart';
import 'package:touristsaver/features/connectivity/cubit/internet_cubit.dart';
import 'package:touristsaver/features/profile/bloc/user_profile_blocs.dart';
import 'package:touristsaver/features/profile/bloc/user_profile_events.dart';
import 'package:touristsaver/features/profile/bloc/user_profile_states.dart';
import 'package:touristsaver/features/profile/services/dio_membership.dart';
import 'package:touristsaver/models/request/change_password_req.dart';
import 'package:touristsaver/models/response/change_password_res.dart';
import 'package:touristsaver/models/response/piiink_info_res.dart';
import 'package:touristsaver/models/response/user_delete_res.dart';
import 'package:touristsaver/models/response/user_detail_res.dart';
import 'package:touristsaver/splash_screen.dart';

import '../../../common/app_variables.dart';
import '../../../common/services/device_info.dart';
import '../../../common/show_verify_email_bottom_sheet.dart';
import '../../../constants/helper.dart';
import '../../../constants/url_end_point.dart';
import '../../connectivity/screens/connectivity.dart';

import 'package:touristsaver/generated/l10n.dart';

const Color _profileNavy = Color(0xFF111C44);
const Color _profileMuted = Color(0xFF63708A);
const Color _profileBorder = Color(0xFFE5EAF4);
const bool _showLaunchDeferredProfileSections = false;

class _ProfileActionItem {
  const _ProfileActionItem({
    required this.title,
    required this.icon,
    this.subtitle,
    this.onTap,
  });

  final String title;
  final String? subtitle;
  final IconData icon;
  final VoidCallback? onTap;
}

class _TravelPreferenceItem {
  const _TravelPreferenceItem({
    required this.title,
    required this.value,
    required this.icon,
  });

  final String title;
  final String value;
  final IconData icon;
}

class LogProfileScreen extends StatefulWidget {
  static const String routeName = '/log-profile';
  const LogProfileScreen({super.key});

  @override
  State<LogProfileScreen> createState() => _LogProfileScreenState();
}

class _LogProfileScreenState extends State<LogProfileScreen> {
  //For Login using FingerPrint (BioMetric)
  var localAuth = LocalAuthentication();

  final changeKey = GlobalKey<FormState>();
  final profileRefreshKey = GlobalKey<RefreshIndicatorState>();
  final TextEditingController currentPasswordController =
      TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmNewPasswordController =
      TextEditingController();
  dynamic showCharity = false;

  bool? hideRecommendOption;
  bool? hideRemoveAccountButton;
  bool _isBiometricsSupported = true;
  String? _selectedStayLocation;
  String? _selectedCountryStateLocation;

  bool isHidden = true;
  bool isHidden1 = true;
  bool isHidden2 = true;

  Future<void> getPiiinkInfo() async {
    PiiinkInfoResModel? piiinkInfoResModel = await DioCommon().piiinkInfo();
    if (!mounted) return;
    setState(() {
      hideRecommendOption = piiinkInfoResModel?.data?.hideReferredMerchantInApp;
      hideRemoveAccountButton = piiinkInfoResModel?.data?.hideRemoveAccount;
    });
  }

  @override
  void initState() {
    super.initState();
    fetchShowCharity();
    getPiiinkInfo();
    _loadStayLocationPrefs();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      localAuth.isDeviceSupported().then((bool isSupported) {
        if (!mounted) return;
        setState(() {
          _isBiometricsSupported = isSupported;
        });
      });
    });
  }

  Future<void> _loadStayLocationPrefs() async {
    final String? stayLocation =
        await Pref().readData(key: userChosenLocationName);
    final String? countryStateLocation =
        await Pref().readData(key: userChosenCountryStateName);
    if (!mounted) return;
    setState(() {
      _selectedStayLocation = _cleanPrefValue(stayLocation);
      _selectedCountryStateLocation = _cleanPrefValue(countryStateLocation);
    });
  }

  String? _cleanPrefValue(String? value) {
    final String cleanValue = value?.trim() ?? '';
    if (cleanValue.isEmpty || cleanValue == 'null' || cleanValue == '0') {
      return null;
    }
    return cleanValue;
  }

  String? _firstNotEmpty(List<String?> values) {
    for (final String? value in values) {
      final String cleanValue = value?.trim() ?? '';
      if (cleanValue.isNotEmpty && cleanValue != 'null') {
        return cleanValue;
      }
    }
    return null;
  }

  String _displayValue(String? value) {
    return _firstNotEmpty([value]) ?? 'Not set';
  }

  List<_ProfileActionItem> _helpfulActions() {
    final List<_ProfileActionItem> actions = [
      _ProfileActionItem(
        title: S.of(context).changeCountry,
        subtitle: 'Update your country or stay location',
        icon: Icons.public_rounded,
        onTap: () => context.pushNamed('change-country'),
      ),
      _ProfileActionItem(
        title: S.of(context).editProfile,
        subtitle: 'Name, email and phone details',
        icon: Icons.edit_outlined,
        onTap: () => context.pushNamed('edit-profile'),
      ),
      _ProfileActionItem(
        title: S.of(context).changePassword,
        subtitle: 'Keep your account secure',
        icon: Icons.lock_outline_rounded,
        onTap: changePopUpPassword,
      ),
    ];

    if (hideRecommendOption != true) {
      actions.add(
        _ProfileActionItem(
          title: S.of(context).recommendNewMerchant,
          subtitle: 'Suggest a place for TouristSaver',
          icon: Icons.add_business_outlined,
          onTap: () => context.pushNamed('recommend'),
        ),
      );
    }

    actions.addAll([
      _ProfileActionItem(
        title: S.of(context).referAFriend,
        subtitle: 'Share TouristSaver with someone',
        icon: Icons.group_add_outlined,
        onTap: () => context.pushNamed('memberReferral'),
      ),
      if (_isBiometricsSupported)
        _ProfileActionItem(
          title: S.of(context).biometrics,
          subtitle: 'Manage biometric sign-in',
          icon: Icons.fingerprint_rounded,
          onTap: () => context.pushNamed('settings-screen'),
        ),
      _ProfileActionItem(
        title: S.of(context).termsConditions,
        subtitle: 'Membership terms and conditions',
        icon: Icons.description_outlined,
        onTap: () => context.pushNamed('terms-condition'),
      ),
      _ProfileActionItem(
        title: S.of(context).about,
        subtitle: 'About TouristSaver',
        icon: Icons.info_outline_rounded,
        onTap: () => context.pushNamed('about-screen'),
      ),
    ]);

    if (showCharity is Map && showCharity['show'] == true) {
      actions.insert(
        0,
        _ProfileActionItem(
          title: S.of(context).charity,
          subtitle: 'Choose or view supported charities',
          icon: Icons.volunteer_activism_outlined,
          onTap: () => context.pushNamed('charity-list'),
        ),
      );
    }
    return actions;
  }

  List<_ProfileActionItem> _savingsActions() {
    return const [
      _ProfileActionItem(
        title: 'Favourites',
        subtitle: 'Coming soon',
        icon: Icons.favorite_border_rounded,
      ),
      _ProfileActionItem(
        title: 'Saved offers',
        subtitle: 'Coming soon',
        icon: Icons.bookmark_border_rounded,
      ),
      _ProfileActionItem(
        title: 'Recently viewed',
        subtitle: 'Coming soon',
        icon: Icons.history_rounded,
      ),
      _ProfileActionItem(
        title: 'Claimed savings',
        subtitle: 'Coming soon',
        icon: Icons.savings_outlined,
      ),
    ];
  }

  List<_TravelPreferenceItem> _travelPreferences() {
    return const [
      _TravelPreferenceItem(
        title: 'Walking comfort',
        value: '1 km',
        icon: Icons.directions_walk_rounded,
      ),
      _TravelPreferenceItem(
        title: 'Breakfast/Cafe walk',
        value: '500 m',
        icon: Icons.local_cafe_outlined,
      ),
      _TravelPreferenceItem(
        title: 'Places radius',
        value: '10 km',
        icon: Icons.place_outlined,
      ),
      _TravelPreferenceItem(
        title: 'Great Deals radius',
        value: '5 km',
        icon: Icons.local_offer_outlined,
      ),
      _TravelPreferenceItem(
        title: 'Transport',
        value: 'Walk / Public transport / Uber-Taxi / Own car / Bike-Scooter',
        icon: Icons.route_outlined,
      ),
    ];
  }

  Future<void> fetchShowCharity() async {
    try {
      var res = await DioCommon().getShowCharity();

      if (res != null && res['status'] == "Success") {
        if (!mounted) return;
        setState(() {
          showCharity = res['data'];
        });
      }
    } catch (e) {
      debugPrint("Error processing banner: $e");
    }
  }

  @override
  void dispose() {
    // ConnectivityCubit().close();
    super.dispose();
  }

  final DioMemberShip _dioMembership = DioMemberShip();
  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      key: profileRefreshKey,
      color: GlobalColors.appColor,
      onRefresh: () async {
        await Future.delayed(const Duration(seconds: 2));
        getPiiinkInfo();
        _loadStayLocationPrefs();
      },
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight),
          child: FutureBuilder<bool>(
            future: checkWalletBalance(), // 👈 call the async function
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                // show placeholder or loader while fetching
                return const SizedBox.shrink();
              }

              final hasBalance = snapshot.data ?? false;

              return CustomAppBar(
                text: S.of(context).profile,
                icon: hasBalance ? null : Icons.arrow_back_ios,
                onPressed: () => context.pop(),
              );
            },
          ),
        ),
        body: SafeArea(
          child: BlocBuilder<ConnectivityCubit, ConnectivityState>(
            builder: (context, state) {
              return ScrollConfiguration(
                behavior: const ScrollBehavior(),
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        //MemberShip
                        (state == ConnectivityState.loading)
                            ? const NoInternetLoader()
                            : (state == ConnectivityState.disconnected)
                                ? const NoInternetWidget()
                                : (state == ConnectivityState.connected)
                                    ? memberShipBox()
                                    : const SizedBox(),

                        if (hideRemoveAccountButton == false)
                          Column(
                            children: [
                              const SizedBox(height: 20),
                              Center(
                                child: CustomButton1(
                                  text: S.of(context).removeAccount,
                                  onPressed: () {
                                    removeButton();
                                  },
                                ),
                              ),
                            ],
                          ),
                        const SizedBox(height: 10),
                        // Logout Button
                        logOut(),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  //Membership
  memberShipBox() {
    return BlocProvider(
      lazy: false,
      create: (context) =>
          UserProfileBloc(_dioMembership)..add(LoadUserProfileEvent()),
      child: BlocBuilder<UserProfileBloc, UserProfileState>(
        builder: (context, state) {
          if (state is UserProfileLoadingState) {
            return Padding(
              padding: EdgeInsets.symmetric(vertical: 42.h),
              child: const Center(child: CustomAllLoader1()),
            );
          } else if (state is UserProfileLoadedState) {
            return profileSection(state.userProfile);
          } else if (state is UserProfileErrorState) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: _ProfileCard(child: memError()),
            );
          } else {
            return const SizedBox();
          }
        },
      ),
    );
  }

  // Profile Section
  profileSection(UserProfileResModel userProfile) {
    final results = userProfile.data?.results;
    final String memberName = _firstNotEmpty([
          '${results?.firstname ?? ''} ${results?.lastname ?? ''}'.trim(),
          results?.email,
        ]) ??
        'TouristSaver Member';
    final String profileLocation = _firstNotEmpty([
          results?.state?.stateName,
          results?.country?.countryName,
        ]) ??
        'Not set';
    final String stayLocation = _firstNotEmpty([
          _selectedStayLocation,
          _selectedCountryStateLocation,
        ]) ??
        'Not selected';
    final bool isEmailVerified = results?.isEmailVerified == true;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 6),
          child: _memberIdentityCard(
            name: memberName,
            stayLocation: stayLocation,
            profileLocation: profileLocation,
            memberCode: _displayValue(results?.uniqueMemberCode),
            issuerCode: _displayValue(userProfile.data?.issuerCode),
            email: _displayValue(results?.email),
            isEmailVerified: isEmailVerified,
          ),
        ),
        if (_showLaunchDeferredProfileSections) ...[
          _ProfileSection(
            title: 'My Travel Preferences',
            subtitle: 'Phase 1 defaults for nearby discovery',
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              children:
                  _travelPreferences().map(_travelPreferenceTile).toList(),
            ),
          ),
          _ProfileSection(
            title: 'My Savings / Activity',
            subtitle: 'More personal history will appear here later',
            child: Column(
              children: _savingsActions()
                  .map((item) => _actionTile(item, isComingSoon: true))
                  .toList(),
            ),
          ),
        ],
        _ProfileSection(
          title: 'Helpful Actions',
          child: Column(
            children: _helpfulActions().map(_actionTile).toList(),
          ),
        ),
      ],
    );
  }

  Widget _memberIdentityCard({
    required String name,
    required String stayLocation,
    required String profileLocation,
    required String memberCode,
    required String issuerCode,
    required String email,
    required bool isEmailVerified,
  }) {
    return _ProfileCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFFF146EA),
                      Color(0xFF0009FE),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: const Icon(
                  Icons.card_membership_rounded,
                  color: Colors.white,
                  size: 26,
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: _profileNavy,
                        fontSize: 22.sp,
                        fontWeight: FontWeight.w900,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 6),
                    _statusPill(
                      isEmailVerified ? 'Email verified' : 'Email not verified',
                      isEmailVerified
                          ? Icons.verified_rounded
                          : Icons.mark_email_unread_outlined,
                      isEmailVerified
                          ? const Color(0xFF0F9F6E)
                          : const Color(0xFFF146EA),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _identityRow(
            icon: Icons.near_me_outlined,
            label: 'Stay location',
            value: stayLocation,
          ),
          _identityRow(
            icon: Icons.public_rounded,
            label: 'Profile country/state',
            value: profileLocation,
          ),
          _identityRow(
            icon: Icons.confirmation_number_outlined,
            label: 'Member code',
            value: memberCode,
          ),
          _identityRow(
            icon: Icons.badge_outlined,
            label: 'Issuer code',
            value: issuerCode,
          ),
          _identityRow(
            icon: Icons.email_outlined,
            label: 'Email',
            value: email,
          ),
          if (!isEmailVerified) ...[
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF0009FE),
                  padding: EdgeInsets.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                onPressed: () {
                  showVerifyEmailBottomSheet(context);
                },
                icon: const Icon(Icons.email_outlined, size: 18),
                label: Text(
                  S.of(context).verifyEmail,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _identityRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFF0009FE), size: 19),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: _profileMuted,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    color: _profileNavy,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    height: 1.25,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusPill(String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 15),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _travelPreferenceTile(_TravelPreferenceItem item) {
    final double width = (MediaQuery.of(context).size.width - 58) / 2;
    return SizedBox(
      width: item.title == 'Transport' ? double.infinity : width,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFF7F9FC),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE5EAF4)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(item.icon, color: const Color(0xFF0009FE), size: 20),
            const SizedBox(width: 9),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: const TextStyle(
                      color: _profileMuted,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    item.value,
                    style: const TextStyle(
                      color: _profileNavy,
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      height: 1.25,
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

  Widget _actionTile(
    _ProfileActionItem item, {
    bool isComingSoon = false,
  }) {
    final bool enabled = item.onTap != null && !isComingSoon;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: enabled ? item.onTap : null,
        child: Container(
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(
            color: enabled ? Colors.white : const Color(0xFFF7F9FC),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE5EAF4)),
          ),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: const Color(0xFF0009FE).withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  item.icon,
                  color: enabled ? const Color(0xFF0009FE) : _profileMuted,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: TextStyle(
                        color: enabled ? _profileNavy : _profileMuted,
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    if (item.subtitle != null) ...[
                      const SizedBox(height: 3),
                      Text(
                        item.subtitle!,
                        style: const TextStyle(
                          color: _profileMuted,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Icon(
                enabled ? Icons.chevron_right_rounded : Icons.lock_clock,
                color: _profileMuted,
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }

  //Error
  memError() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          child: SizedBox(
              height: 100.h,
              width: 120.w,
              child: Image.asset("assets/images/oops.png")),
        ),
        const SizedBox(height: 10),
        AutoSizeText(
          S.of(context).oops,
          style: topicStyle,
        ),
        const SizedBox(height: 10),
        AutoSizeText(
          S.of(context).somethingWentWrong,
          style: topicStyle,
        )
      ],
    );
  }

  // Change Password PopUp
  changePopUpPassword() {
    currentPasswordController.clear();
    newPasswordController.clear();
    confirmNewPasswordController.clear();
    setState(() {
      isHidden = true;
      isHidden1 = true;
      isHidden2 = true;
    });
    bool isLoading = false;
    //bool for tracking the pop up
    bool trackDialog = false;
    return showDialog(
        context: context,
        barrierColor: Colors.black.withValues(alpha: 0.36),
        barrierDismissible: false,
        builder: (BuildContext context) => Dialog(
              elevation: 0,
              insetPadding:
                  const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
              backgroundColor: Colors.transparent,
              child: SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                child: Container(
                  width: double.infinity,
                  constraints: const BoxConstraints(maxWidth: 430),
                  padding: const EdgeInsets.fromLTRB(20, 22, 20, 18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.14),
                        blurRadius: 28,
                        offset: const Offset(0, 14),
                      ),
                    ],
                  ),
                  child: StatefulBuilder(
                    builder: (context, stateMode) {
                      return Form(
                        key: changeKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              S.of(context).changePassword,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: _profileNavy,
                                fontSize: 22.sp,
                                fontWeight: FontWeight.w900,
                                height: 1.15,
                              ),
                            ),
                            const SizedBox(height: 18),

                            // Recent Password
                            TextFormField(
                              controller: currentPasswordController,
                              cursorColor: GlobalColors.appColor,
                              decoration: _passwordInputDecoration(
                                hintText: S.of(context).currentPassword,
                                isHidden: isHidden,
                                onVisibilityTap: () {
                                  stateMode(() {
                                    isHidden = !isHidden;
                                  });
                                },
                              ),
                              obscureText: isHidden,
                              validator: (currentPassword) {
                                if (currentPassword == null ||
                                    currentPassword.isEmpty) {
                                  stateMode(() {
                                    isLoading = false;
                                  });
                                  return S
                                      .of(context)
                                      .pleaseEnterCurrentPassword;
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 12),

                            // New Password
                            TextFormField(
                              controller: newPasswordController,
                              cursorColor: GlobalColors.appColor,
                              decoration: _passwordInputDecoration(
                                hintText: S.of(context).newPassword,
                                isHidden: isHidden1,
                                onVisibilityTap: () {
                                  stateMode(() {
                                    isHidden1 = !isHidden1;
                                  });
                                },
                              ),
                              obscureText: isHidden1,
                              validator: (newPassword) {
                                if (newPassword == null ||
                                    newPassword.isEmpty ||
                                    newPassword ==
                                        currentPasswordController.text.trim()) {
                                  stateMode(() {
                                    isLoading = false;
                                  });
                                  return newPassword ==
                                          currentPasswordController.text.trim()
                                      ? S.of(context).passwordsAreSame
                                      : S.of(context).enterNewPassword;
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 12),

                            // Confirm New Password
                            TextFormField(
                              controller: confirmNewPasswordController,
                              cursorColor: GlobalColors.appColor,
                              decoration: _passwordInputDecoration(
                                hintText: S.of(context).confirmPassword,
                                isHidden: isHidden2,
                                onVisibilityTap: () {
                                  stateMode(() {
                                    isHidden2 = !isHidden2;
                                  });
                                },
                              ),
                              obscureText: isHidden2,
                              validator: (confirmPassword) {
                                if (confirmPassword == null ||
                                    confirmPassword.isEmpty ||
                                    confirmPassword !=
                                        newPasswordController.text.trim() ||
                                    confirmPassword ==
                                        currentPasswordController.text.trim()) {
                                  stateMode(() {
                                    isLoading = false;
                                  });
                                  return confirmPassword ==
                                          currentPasswordController.text.trim()
                                      ? S.of(context).passwordsAreSame
                                      : S.of(context).passwordNoMatch;
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 18),

                            // Save Button
                            isLoading == true
                                ? const CustomButtonWithCircular()
                                : _profileDialogPrimaryButton(
                                    text: S.of(context).save,
                                    onPressed: () async {
                                      stateMode(() {
                                        isLoading = true;
                                      });
                                      if (changeKey.currentState!.validate()) {
                                        var res =
                                            await DioMemberShip().changePass(
                                          changePasswordReqModel:
                                              ChangePasswordReqModel(
                                            currentPassword:
                                                currentPasswordController.text
                                                    .trim(),
                                            newPassword: newPasswordController
                                                .text
                                                .trim(),
                                            newConfirmPassword:
                                                confirmNewPasswordController
                                                    .text
                                                    .trim(),
                                          ),
                                        );
                                        if (!mounted) return;
                                        if (res is ChangePasswordResModel) {
                                          if (res.status == 'Success') {
                                            stateMode(() {
                                              Pref().writeData(
                                                  key: 'savePassword',
                                                  value: newPasswordController
                                                      .text
                                                      .trim());
                                              isLoading = false;
                                              trackDialog = true;
                                            });
                                            context.pop();
                                          }
                                        } else {
                                          GlobalSnackBar.showError(
                                              context,
                                              S
                                                  .of(context)
                                                  .currentPasswordDoesNotMatch);
                                          stateMode(() {
                                            isLoading = false;
                                          });
                                        }
                                      }
                                    },
                                  ),
                            const SizedBox(height: 10),
                            _profileDialogSecondaryButton(
                              text: S.of(context).cancel,
                              onPressed: () {
                                context.pop();
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            )).then((value) => trackDialog == true
        ? GlobalSnackBar.showSuccess(
            context, S.of(context).passwordChangedSuccessfully)
        : null);
  }

  InputDecoration _passwordInputDecoration({
    required String hintText,
    required bool isHidden,
    required VoidCallback onVisibilityTap,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(
        color: _profileMuted,
        fontSize: 14,
        fontWeight: FontWeight.w700,
      ),
      filled: true,
      fillColor: const Color(0xFFF7F9FC),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: _profileBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: GlobalColors.appColor1, width: 1.4),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: GlobalColors.appColor),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: GlobalColors.appColor, width: 1.4),
      ),
      suffixIcon: IconButton(
        onPressed: onVisibilityTap,
        splashRadius: 20,
        icon: Icon(
          isHidden ? Icons.visibility_off_outlined : Icons.visibility_outlined,
          size: 20,
          color: _profileMuted,
        ),
      ),
    );
  }

  Widget _profileDialogPrimaryButton({
    required String text,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      height: 48,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: GlobalColors.appColor1,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: AutoSizeText(
          text,
          maxLines: 1,
          style: TextStyle(
            color: Colors.white,
            fontSize: 16.sp,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }

  Widget _profileDialogSecondaryButton({
    required String text,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      height: 46,
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          foregroundColor: _profileNavy,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: AutoSizeText(
          text,
          maxLines: 1,
          style: TextStyle(
            color: _profileMuted,
            fontSize: 15.sp,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }

// Logout Button
  logOut() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 18),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () async {
          return showDialog(
            context: context,
            builder: (BuildContext dialogContext) {
              // Use a distinct context for the dialog
              bool logOutConfirmed = false;
              return AlertDialog(
                content: StatefulBuilder(
                    builder: (BuildContext context, StateSetter setState) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        S.of(context).areYouSureYouWantToLogOut,
                        textAlign: TextAlign.center,
                        style: topicStyle,
                      ),
                      const SizedBox(height: 15),
                      // Yes Button
                      logOutConfirmed == true
                          ? const CustomButtonWithCircular()
                          : CustomButton(
                              onPressed: () async {
                                // 1. Show loading state immediately
                                setState(() {
                                  logOutConfirmed = true;
                                });

                                // 2. BACKGROUND TASKS: Do not put 'await' in front of this!
                                // This lets the app continue instantly while the server thinks.
                                Future.delayed(Duration.zero, () async {
                                  try {
                                    String deviceId;
                                    if (AppVariables.deviceId.isNotEmpty) {
                                      deviceId = AppVariables.deviceId;
                                    } else {
                                      deviceId = await getDeviceId();
                                    }

                                    if (deviceId.isNotEmpty) {
                                      await getClient().then(
                                        (dio) => dio.delete(
                                          deleteDeviceIdOnLogOut
                                              .format(params: [deviceId]),
                                        ),
                                      );
                                    }
                                  } catch (e) {
                                    debugPrint(
                                        'Error during device ID deletion: $e');
                                  }

                                  try {
                                    await FirebaseMessaging.instance
                                        .deleteToken();
                                  } catch (e) {
                                    debugPrint(
                                        'Firebase token deletion failed: $e');
                                  }
                                });

                                // 3. CLEAR LOCAL DATA IMMEDIATELY
                                await Pref().removeData(saveToken);
                                await Pref().removeData(issuerType);
                                await Pref().removeData('fcmToken');
                                await Pref().removeData('isTokenSent');
                                await Pref().removeData('notificationsCount');
                                await Pref().removeData(saveUserID);
                                await Pref().removeData(saveCurrency);
                                await Pref().removeData(savePublishableKey);
                                await Pref()
                                    .removeData(userChosenLocationStateID);
                                await Pref()
                                    .removeData(userChosenLocationRegionID);
                                AppVariables.accessToken = null;

                                AppVariables.notificationLabel.value = 0;
                                AppVariables.initNotifications = false;

                                if (!mounted) return;

                                // 4. INSTANT NAVIGATION
                                // Close the dialog
                                Navigator.of(dialogContext).pop();

                                context.pushReplacementNamed('login');
                              },
                              text: S.of(context).yes,
                            ),
                      const SizedBox(height: 10),
                      CustomButton1(
                        onPressed: () {
                          // Correctly pop the dialog
                          Navigator.of(context).pop();
                        },
                        text: S.of(context).cancel,
                      ),
                    ],
                  );
                }),
              );
            },
          );
        },
        child: Container(
          width: double.infinity,
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: 16),
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
                blurRadius: 18,
                offset: const Offset(0, 9),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.logout_rounded,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 9),
              Text(
                S.of(context).logOut,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Remove Button
  removeButton() async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        bool removeAccountConfirmed = false;
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
          return AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  S.of(context).areYouSureYouWantToRemoveYourAccount,
                  textAlign: TextAlign.center,
                  style: topicStyle,
                ),
                const SizedBox(height: 15),
                // Yes Button
                removeAccountConfirmed == true
                    ? const CustomButtonWithCircular()
                    : CustomButton(
                        onPressed: () async {
                          try {
                            setState(() {
                              removeAccountConfirmed = true;
                            });
                            var deleteRes = await DioCommon().userDeletion();
                            if (deleteRes is UserDeleteResModel) {
                              if (!mounted) return;
                              if (deleteRes.status == 'success') {
                                await Pref().removeData(saveToken);
                                await Pref().removeData(issuerType);
                                await Pref().removeData('fcmToken');
                                await Pref().removeData('isTokenSent');
                                await Pref().removeData('notificationsCount');
                                await Pref().removeData(saveUserID);
                                await Pref().removeData(saveCurrency);
                                await Pref().removeData(savePublishableKey);
                                await Pref()
                                    .removeData(userChosenLocationStateID);
                                await Pref()
                                    .removeData(userChosenLocationRegionID);
                                AppVariables.accessToken = null;

                                if (!mounted) return;
                                GlobalSnackBar.showSuccess(
                                    context, deleteRes.message!);
                              }
                            }
                            // else {
                            //   if (!mounted) return;
                            //   GlobalSnackBar.showError(
                            //       context, "Couldn't delete the account!");
                            // }
                          } catch (e) {
                            // GlobalSnackBar.showError(
                            //     context, "Couldn't delete the account!");
                          }
                          try {
                            await FirebaseMessaging.instance.deleteToken();
                          } catch (e) {
                            log(e.toString());
                          }
                          AppVariables.notificationLabel.value = 0;
                          AppVariables.initNotifications = false;
                          if (!mounted) return;
                          context.pushReplacementNamed('bottom-bar',
                              pathParameters: {'page': '4'});
                        },
                        text: S.of(context).yes,
                      ),

                const SizedBox(height: 10),

                // No Button
                CustomButton1(
                  onPressed: () {
                    context.pop();
                  },
                  text: S.of(context).cancel,
                ),
              ],
            ),
          );
        });
      },
    );
  }
}

class _ProfileSection extends StatelessWidget {
  const _ProfileSection({
    required this.title,
    required this.child,
    this.subtitle,
  });

  final String title;
  final String? subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: _profileNavy,
              fontSize: 18.sp,
              fontWeight: FontWeight.w900,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 3),
            Text(
              subtitle!,
              style: const TextStyle(
                color: _profileMuted,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
          const SizedBox(height: 10),
          _ProfileCard(child: child),
        ],
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({
    required this.child,
    this.padding = const EdgeInsets.all(14),
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
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _profileBorder),
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
