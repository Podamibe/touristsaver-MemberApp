import 'package:flutter/material.dart';
import 'package:touristsaver/constants/global_colors.dart';
import 'package:touristsaver/generated/l10n.dart';

class GlobalSnackBar {
  final String message;

  const GlobalSnackBar({
    required this.message,
  });

  // Success
  static showSuccess(
    BuildContext context,
    String message,
  ) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars
      ..showSnackBar(
        SnackBar(
          elevation: 0.0,
          behavior: SnackBarBehavior.fixed,
          content: Text(message),
          duration: const Duration(seconds: 3),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16.0),
                topRight: Radius.circular(16.0)),
          ),
          backgroundColor: GlobalColors.appColor1,
          action: SnackBarAction(
            textColor: Colors.white,
            label: S.of(context).ok,
            onPressed: () {},
          ),
        ),
      );
  }

  // Error
  static showError(
    BuildContext context,
    String message,
  ) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          elevation: 0.0,
          behavior: SnackBarBehavior.fixed,
          content: Text(message),
          duration: const Duration(seconds: 3),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16.0),
                topRight: Radius.circular(16.0)),
          ),
          backgroundColor: Colors.red,
          action: SnackBarAction(
            textColor: const Color(0xFFFAF2FB),
            label: S.of(context).ok,
            onPressed: () {},
          ),
        ),
      );
  }

  // TextFormFeild Validation
  static valid(
    BuildContext context,
    String message,
  ) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          duration: const Duration(seconds: 2),
          content: Text(message),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16.0),
                topRight: Radius.circular(16.0)),
          ),
        ),
      );
  }
}
