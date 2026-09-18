import 'package:flutter/material.dart';
import 'package:touristsaver/generated/l10n.dart';
import 'package:touristsaver/common/models/member_error_presentation.dart';

class GlobalSnackBar {
  final String message;

  const GlobalSnackBar({
    required this.message,
  });

  static void showMemberError(
    BuildContext context,
    MemberErrorPresentation presentation,
  ) =>
      showError(context, presentation.displayText);

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
          padding: EdgeInsets.zero,
          content: Container(
            padding: const EdgeInsets.only(left: 16.0, right: 8.0),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0009FE), Color(0xFF18C6FF)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    message,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                TextButton(
                  onPressed: () =>
                      ScaffoldMessenger.of(context).hideCurrentSnackBar(),
                  child: Text(
                    S.of(context).ok,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          duration: const Duration(seconds: 3),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16.0),
                topRight: Radius.circular(16.0)),
          ),
          clipBehavior: Clip.antiAlias,
          backgroundColor: Colors.transparent,
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
