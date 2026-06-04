import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:touristsaver/common/services/dio_common.dart';
import 'package:touristsaver/common/services/image_service.dart';
import 'package:touristsaver/common/widgets/custom_app_bar.dart';
import 'package:touristsaver/common/widgets/custom_loader.dart';
import 'package:touristsaver/common/widgets/custom_snackbar.dart';
import 'package:touristsaver/common/widgets/error.dart' as error_widget;
import 'package:touristsaver/common/widgets/not_available.dart';
import 'package:touristsaver/features/connectivity/cubit/internet_cubit.dart';
import 'package:touristsaver/features/recommend/services/dio_recommend.dart';
import 'package:touristsaver/generated/l10n.dart';
import 'package:touristsaver/models/error_res.dart';
import 'package:touristsaver/models/response/common_res.dart';
import 'package:touristsaver/models/response/piiink_info_res.dart';

import '../../connectivity/screens/connectivity.dart';
import '../../connectivity/screens/connectivity_screen.dart';

const Color _recommendNavy = Color(0xFF111C44);
const Color _recommendMuted = Color(0xFF65708A);
const Color _recommendBorder = Color(0xFFE4EAF5);
const Color _recommendSurface = Color(0xFFF7F9FC);
const Color _recommendBlue = Color(0xFF0009FE);
const Color _recommendCyan = Color(0xFF18C6FF);

class RecommendScreen extends StatefulWidget {
  static const String routeName = "/recommend";
  const RecommendScreen({super.key});

  @override
  State<RecommendScreen> createState() => _RecommendScreenState();
}

class _RecommendScreenState extends State<RecommendScreen> {
  final recommendKey = GlobalKey<FormState>();
  final merchantNameController = TextEditingController();
  final reasonController = TextEditingController();
  final addressController = TextEditingController();
  final ImageService _imageService = ImageService();

  Future<PiiinkInfoResModel?>? displayOrNot;
  bool isSending = false;
  XFile? selectedImage;

  Future<PiiinkInfoResModel?> getDisplayOrNot() async {
    return DioCommon().piiinkInfo();
  }

  @override
  void initState() {
    displayOrNot = getDisplayOrNot();
    super.initState();
  }

  InputDecoration _inputDecoration(String label, {String? hint}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      labelStyle: const TextStyle(
        color: _recommendMuted,
        fontWeight: FontWeight.w700,
      ),
      floatingLabelStyle: const TextStyle(
        color: _recommendBlue,
        fontWeight: FontWeight.w800,
      ),
      hintStyle: TextStyle(
        color: _recommendMuted.withValues(alpha: 0.72),
        fontWeight: FontWeight.w500,
      ),
      filled: true,
      fillColor: _recommendSurface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: _recommendBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: _recommendCyan, width: 1.4),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: Color(0xFFE86F7F)),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: Color(0xFFE86F7F), width: 1.4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: CustomAppBar(
          text: S.of(context).recommend,
          icon: Icons.arrow_back_ios,
          onPressed: () => context.pop(),
        ),
      ),
      body: BlocBuilder<ConnectivityCubit, ConnectivityState>(
        builder: (context, state) {
          if (state == ConnectivityState.loading) {
            return const NoInternetLoader();
          } else if (state == ConnectivityState.disconnected) {
            return const NoConnectivityScreen();
          } else if (state == ConnectivityState.connected) {
            return FutureBuilder<PiiinkInfoResModel?>(
              future: displayOrNot,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const error_widget.Error();
                } else if (!snapshot.hasData) {
                  return const CustomAllLoader();
                }

                if (snapshot.data?.data?.hideReferredMerchantInApp != false) {
                  return comingSoon();
                }

                return recommendFormScreen();
              },
            );
          }
          return const SizedBox();
        },
      ),
    );
  }

  Widget recommendFormScreen() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 28),
      child: Form(
        key: recommendKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _heroCard(),
            const SizedBox(height: 14),
            _formCard(),
          ],
        ),
      ),
    );
  }

  Widget _heroCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF111C44),
            Color(0xFF0009FE),
            Color(0xFF18C6FF),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: _recommendBlue.withValues(alpha: 0.18),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 42,
            width: 42,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(
              Icons.storefront_rounded,
              color: Colors.white,
              size: 23,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'Know a great local place?',
            style: TextStyle(
              color: Colors.white,
              fontSize: 25.sp,
              fontWeight: FontWeight.w900,
              height: 1.08,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Help TouristSaver discover great places nearby. Approved recommendations may be eligible for member giveaway promotions.',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _formCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _recommendBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: merchantNameController,
            cursorColor: _recommendBlue,
            textInputAction: TextInputAction.next,
            style: const TextStyle(
              color: _recommendNavy,
              fontWeight: FontWeight.w700,
            ),
            decoration: _inputDecoration('Merchant / business name *'),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return S.of(context).pleaseEnterMerchantName;
              }
              return null;
            },
          ),
          const SizedBox(height: 15),
          TextFormField(
            controller: reasonController,
            cursorColor: _recommendBlue,
            maxLines: 4,
            minLines: 3,
            textInputAction: TextInputAction.newline,
            style: const TextStyle(
              color: _recommendNavy,
              fontWeight: FontWeight.w700,
              height: 1.35,
            ),
            decoration: _inputDecoration(
              'Why do you recommend this place?',
              hint: 'Tell us what makes it worth discovering.',
            ),
          ),
          const SizedBox(height: 15),
          TextFormField(
            controller: addressController,
            cursorColor: _recommendBlue,
            textInputAction: TextInputAction.done,
            style: const TextStyle(
              color: _recommendNavy,
              fontWeight: FontWeight.w700,
            ),
            decoration: _inputDecoration(
              'Address or location',
              hint: 'Optional',
            ),
          ),
          const SizedBox(height: 18),
          _photoPicker(),
          const SizedBox(height: 22),
          _RecommendGradientButton(
            text: 'Submit recommendation',
            isLoading: isSending,
            onPressed: _submitRecommendation,
          ),
        ],
      ),
    );
  }

  Widget _photoPicker() {
    if (selectedImage != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: AspectRatio(
              aspectRatio: 16 / 10,
              child: Image.file(
                File(selectedImage!.path),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: const Color(0xFFF4F8FF),
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          height: 44,
                          width: 44,
                          decoration: BoxDecoration(
                            color: _recommendBlue.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: const Icon(
                            Icons.broken_image_rounded,
                            color: _recommendBlue,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'This photo could not be loaded.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: _recommendNavy,
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Choose another image or remove it.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: _recommendMuted,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _SecondaryActionButton(
                  icon: Icons.swap_horiz_rounded,
                  text: 'Change photo',
                  onPressed: isSending ? null : _showPhotoSourceSheet,
                ),
              ),
              const SizedBox(width: 10),
              _IconActionButton(
                icon: Icons.close_rounded,
                tooltip: 'Remove photo',
                onPressed: isSending
                    ? null
                    : () {
                        setState(() {
                          selectedImage = null;
                        });
                      },
              ),
            ],
          ),
        ],
      );
    }

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: isSending ? null : _showPhotoSourceSheet,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        decoration: BoxDecoration(
          color: const Color(0xFFF4F8FF),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _recommendBorder),
        ),
        child: Row(
          children: [
            Container(
              height: 42,
              width: 42,
              decoration: BoxDecoration(
                color: _recommendBlue.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Icon(
                Icons.add_a_photo_rounded,
                color: _recommendBlue,
                size: 21,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Add a photo',
                    style: TextStyle(
                      color: _recommendNavy,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Optional image of the establishment',
                    style: TextStyle(
                      color: _recommendMuted,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: _recommendMuted,
            ),
          ],
        ),
      ),
    );
  }

  void _showPhotoSourceSheet() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 4,
                  width: 42,
                  decoration: BoxDecoration(
                    color: _recommendBorder,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                const SizedBox(height: 16),
                _PhotoSourceTile(
                  icon: Icons.photo_camera_rounded,
                  title: 'Take photo',
                  onTap: () {
                    context.pop();
                    _pickImage(ImageSource.camera);
                  },
                ),
                _PhotoSourceTile(
                  icon: Icons.photo_library_rounded,
                  title: 'Choose from library',
                  onTap: () {
                    context.pop();
                    _pickImage(ImageSource.gallery);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedImage = await _imageService.pickImage(source);
    if (!mounted || pickedImage == null) return;

    if (!_isSupportedImage(pickedImage)) {
      GlobalSnackBar.showError(
        context,
        'Please choose a JPG, PNG or WEBP image.',
      );
      return;
    }

    setState(() {
      selectedImage = pickedImage;
    });
  }

  bool _isSupportedImage(XFile image) {
    final path = image.path.toLowerCase();
    final name = image.name.toLowerCase();
    return path.endsWith('.jpg') ||
        path.endsWith('.jpeg') ||
        path.endsWith('.png') ||
        path.endsWith('.webp') ||
        name.endsWith('.jpg') ||
        name.endsWith('.jpeg') ||
        name.endsWith('.png') ||
        name.endsWith('.webp');
  }

  Future<void> _submitRecommendation() async {
    if (isSending) return;
    if (!(recommendKey.currentState?.validate() ?? false)) return;

    setState(() {
      isSending = true;
    });

    final result = await DioRecommend().createMerchantReferral(
      merchantName: merchantNameController.text.trim(),
      reason: reasonController.text.trim(),
      addressText: addressController.text.trim(),
      uploadFile: selectedImage,
    );

    if (!mounted) return;

    setState(() {
      isSending = false;
    });

    if (result is CommonResModel) {
      merchantNameController.clear();
      reasonController.clear();
      addressController.clear();
      setState(() {
        selectedImage = null;
      });
      GlobalSnackBar.showSuccess(
        context,
        'Thanks! Your recommendation has been submitted for review.',
      );
    } else if (result is ErrorResModel) {
      GlobalSnackBar.showError(
        context,
        result.message ?? 'Could not submit your recommendation.',
      );
    } else {
      GlobalSnackBar.showError(
        context,
        'Could not submit your recommendation. Please try again.',
      );
    }
  }

  Widget comingSoon() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
      child: NotAvailable(
        titleText: S.of(context).comingSoon,
        bodyText: S.of(context).weAreCurrentlyWorkingOnThisWeWillKeepYouUpdated,
      ),
    );
  }

  @override
  void dispose() {
    merchantNameController.dispose();
    reasonController.dispose();
    addressController.dispose();
    super.dispose();
  }
}

class _RecommendGradientButton extends StatelessWidget {
  const _RecommendGradientButton({
    required this.text,
    required this.onPressed,
    this.isLoading = false,
  });

  final String text;
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
          height: 52,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [_recommendBlue, _recommendCyan],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: _recommendBlue.withValues(alpha: 0.18),
                blurRadius: 18,
                offset: const Offset(0, 9),
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
                : Text(
                    text,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

class _SecondaryActionButton extends StatelessWidget {
  const _SecondaryActionButton({
    required this.icon,
    required this.text,
    required this.onPressed,
  });

  final IconData icon;
  final String text;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: _recommendNavy,
        side: const BorderSide(color: _recommendBorder),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
      icon: Icon(icon, size: 18, color: _recommendBlue),
      label: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.w800),
      ),
    );
  }
}

class _IconActionButton extends StatelessWidget {
  const _IconActionButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onPressed,
        child: Container(
          height: 48,
          width: 48,
          decoration: BoxDecoration(
            color: _recommendSurface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _recommendBorder),
          ),
          child: Icon(
            icon,
            color: _recommendMuted,
          ),
        ),
      ),
    );
  }
}

class _PhotoSourceTile extends StatelessWidget {
  const _PhotoSourceTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        height: 42,
        width: 42,
        decoration: BoxDecoration(
          color: _recommendBlue.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(icon, color: _recommendBlue),
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: _recommendNavy,
          fontWeight: FontWeight.w800,
        ),
      ),
      trailing: const Icon(
        Icons.chevron_right_rounded,
        color: _recommendMuted,
      ),
    );
  }
}
