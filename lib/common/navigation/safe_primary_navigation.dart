import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:touristsaver/features/merchant/discovery/merchant_discovery_intent.dart';

void navigateToSafePrimaryScreen(
  BuildContext context, {
  bool returnToSearch = false,
}) {
  final String page = returnToSearch ? '1' : '0';
  navigateToBottomTab(context, int.parse(page));
}

void navigateToBottomTab(BuildContext context, int page) {
  FocusManager.instance.primaryFocus?.unfocus();
  MerchantDiscoveryIntentStore.requestBottomTab(page);
  context.goNamed(
    'bottom-bar',
    pathParameters: {'page': page.toString()},
  );
}
