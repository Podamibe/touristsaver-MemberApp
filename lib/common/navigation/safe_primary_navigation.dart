import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:touristsaver/features/merchant/discovery/merchant_discovery_intent.dart';

void navigateToSafePrimaryScreen(
  BuildContext context, {
  bool returnToSearch = false,
}) {
  FocusScope.of(context).unfocus();
  final String page = returnToSearch ? '1' : '0';
  MerchantDiscoveryIntentStore.requestBottomTab(int.parse(page));
  context.goNamed(
    'bottom-bar',
    pathParameters: {'page': page},
  );
}
