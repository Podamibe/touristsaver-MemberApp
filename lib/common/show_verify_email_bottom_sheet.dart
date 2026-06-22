// ignore_for_file: use_build_context_synchronously

// import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:touristsaver/common/widgets/custom_snackbar.dart';
import 'package:touristsaver/models/error_res.dart';

import '../features/profile/services/dio_profile.dart';
import '../models/response/common_res.dart';
import 'package:touristsaver/generated/l10n.dart';

Future<dynamic> showVerifyEmailBottomSheet(BuildContext context,
    {String? email}) {
  const navy = Color(0xFF111C44);
  const muted = Color(0xFF63708A);
  const blue = Color(0xFF0009FE);
  const cyan = Color(0xFF18C6FF);
  final displayEmail = email?.trim();

  return showDialog<void>(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.48),
    builder: (dialogContext) {
      bool apiCalled = false;
      return StatefulBuilder(builder: (dialogContext, setModalState) {
        return Dialog(
          elevation: 0,
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 28),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 390),
            padding: EdgeInsets.fromLTRB(24.w, 24.h, 24.w, 20.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24.r),
              boxShadow: [
                BoxShadow(
                  color: navy.withValues(alpha: 0.18),
                  blurRadius: 30,
                  offset: const Offset(0, 14),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 54.w,
                  height: 54.w,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [blue, cyan],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: const Icon(
                    Icons.mark_email_unread_outlined,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                SizedBox(height: 17.h),
                Text(
                  'Verify Email',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: navy,
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w900,
                    height: 1.15,
                    fontFamily: 'Sans',
                  ),
                ),
                SizedBox(height: 11.h),
                Text(
                  "Your email address isn't verified yet.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: muted,
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                    height: 1.4,
                    fontFamily: 'Sans',
                  ),
                ),
                SizedBox(height: 14.h),
                Text(
                  "We'll send a verification link to:",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: muted,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Sans',
                  ),
                ),
                if (displayEmail != null && displayEmail.isNotEmpty) ...[
                  SizedBox(height: 7.h),
                  Container(
                    width: double.infinity,
                    padding:
                        EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F7FF),
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: const Color(0xFFDDE8FF)),
                    ),
                    child: Text(
                      displayEmail,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: navy,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w800,
                        fontFamily: 'Sans',
                      ),
                    ),
                  ),
                ],
                SizedBox(height: 22.h),
                Container(
                  width: double.infinity,
                  height: 50.h,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16.r),
                    gradient: const LinearGradient(
                      colors: [blue, cyan],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: blue.withValues(alpha: 0.22),
                        blurRadius: 16,
                        offset: const Offset(0, 7),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16.r),
                      onTap: apiCalled
                          ? null
                          : () async {
                              setModalState(() {
                                apiCalled = true;
                              });
                              var result = await DioProfile().verifyEmail();
                              if (result is CommonResModel &&
                                  result.status == 'Success') {
                                if (dialogContext.mounted) {
                                  Navigator.of(dialogContext).pop();
                                }
                                if (context.mounted) {
                                  await showVerificationEmailSentDialog(
                                      context);
                                }
                                return;
                              }

                              if (dialogContext.mounted) {
                                setModalState(() {
                                  apiCalled = false;
                                });
                                final errorMessage = result is ErrorResModel
                                    ? result.message
                                    : result is CommonResModel
                                        ? result.message
                                        : null;
                                GlobalSnackBar.showError(
                                  dialogContext,
                                  errorMessage ??
                                      S.of(dialogContext).someErrorOccurred,
                                );
                              }
                            },
                      child: Center(
                        child: apiCalled
                            ? const SizedBox(
                                width: 23,
                                height: 23,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 3,
                                ),
                              )
                            : Text(
                                'Send Verification Email',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15.5.sp,
                                  fontWeight: FontWeight.w900,
                                  fontFamily: 'Sans',
                                ),
                              ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10.h),
                TextButton(
                  onPressed: apiCalled
                      ? null
                      : () => Navigator.of(dialogContext).pop(),
                  style: TextButton.styleFrom(
                    foregroundColor: muted,
                    padding:
                        EdgeInsets.symmetric(horizontal: 18.w, vertical: 8.h),
                  ),
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      fontSize: 14.5.sp,
                      fontWeight: FontWeight.w800,
                      fontFamily: 'Sans',
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      });
    },
  );
}

Future<void> showVerificationEmailSentDialog(BuildContext context) {
  const navy = Color(0xFF111C44);
  const muted = Color(0xFF63708A);
  const blue = Color(0xFF0009FE);
  const cyan = Color(0xFF18C6FF);

  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.black.withValues(alpha: 0.48),
    builder: (dialogContext) {
      return Dialog(
        elevation: 0,
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 28),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 390),
          padding: EdgeInsets.fromLTRB(24.w, 24.h, 24.w, 22.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24.r),
            boxShadow: [
              BoxShadow(
                color: navy.withValues(alpha: 0.18),
                blurRadius: 30,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 58.w,
                height: 58.w,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Color(0xFFF146EA), cyan],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: Colors.white,
                  size: 34,
                ),
              ),
              SizedBox(height: 18.h),
              Text(
                'Verification Email Sent',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: navy,
                  fontSize: 22.sp,
                  fontWeight: FontWeight.w900,
                  height: 1.15,
                  fontFamily: 'Sans',
                ),
              ),
              SizedBox(height: 12.h),
              Text(
                'Check your inbox and click the verification link.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: muted,
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                  height: 1.4,
                  fontFamily: 'Sans',
                ),
              ),
              SizedBox(height: 18.h),
              Text(
                "Didn't receive it?",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: navy,
                  fontSize: 14.5.sp,
                  fontWeight: FontWeight.w800,
                  fontFamily: 'Sans',
                ),
              ),
              SizedBox(height: 5.h),
              Text(
                'Check your spam folder or request another email.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: muted,
                  fontSize: 13.5.sp,
                  fontWeight: FontWeight.w600,
                  height: 1.35,
                  fontFamily: 'Sans',
                ),
              ),
              SizedBox(height: 22.h),
              Container(
                width: double.infinity,
                height: 50.h,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16.r),
                  gradient: const LinearGradient(
                    colors: [blue, cyan],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: blue.withValues(alpha: 0.22),
                      blurRadius: 16,
                      offset: const Offset(0, 7),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16.r),
                    onTap: () => Navigator.of(dialogContext).pop(),
                    child: Center(
                      child: Text(
                        'Done',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w900,
                          fontFamily: 'Sans',
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
