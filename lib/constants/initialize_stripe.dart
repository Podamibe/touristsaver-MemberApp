//Initializing the flutter stripe
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:new_piiink/constants/env.dart';
import 'package:new_piiink/constants/pref.dart';
import 'package:new_piiink/constants/pref_key.dart';

initializeFlutterStripe() async {
  try {
    // Read the key from preferences
    String? key = await Pref().readData(key: savePublishableKey);
    // ✅ Fix: Check if key exists before assigning to Stripe
    if (key != null && key.isNotEmpty && key != "null") {
      Stripe.publishableKey = key;
      Stripe.merchantIdentifier = 'merchant.flutter.stripe.test';
      await Stripe.instance.applySettings();
    } else {
      // If no key is found, we log it but DON'T crash
      print("STRIPE: No publishable key found in storage.");
    }
  } catch (e) {
    // Catch any unexpected Stripe initialization errors
    print("STRIPE INIT ERROR: $e");
  }
}

byDefaultStripeKey() async {
  Pref().writeData(key: savePublishableKey, value: stripePublishableKey);

  Stripe.publishableKey = await Pref().readData(key: savePublishableKey);
  // stripePublishableKey; // set the publishable key for Stripe - this is mandatory
  Stripe.merchantIdentifier = 'merchant.flutter.stripe.test';
  await Stripe.instance.applySettings();
}
