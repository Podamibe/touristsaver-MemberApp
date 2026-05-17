import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:go_router/go_router.dart';

class LocalNotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static void initialize(BuildContext context) async {
    void onDidReceiveNotificationResponse(
        {required NotificationResponse notificationResponse, onData}) async {
      if (notificationResponse.payload != null) {
        context.pushNamed('notification');
      }
    }

    InitializationSettings initializationSettings = InitializationSettings(
        android: const AndroidInitializationSettings("@mipmap/ic_notification"),
        iOS: DarwinInitializationSettings(
            // onDidReceiveLocalNotification: onDidReceiveLocalNotification,
            ));

    _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (notificationResponse) {
        onDidReceiveNotificationResponse(
            notificationResponse: notificationResponse,
            onData: () {
              context.pushNamed('notification');
            });
      },
    );
  }

  static void display(RemoteMessage message) async {
    try {
      final id = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      final String? notificationTitle = message.notification?.title;
      final String? notificationBody = message.notification?.body;
      final String? safeTitle = _safeNotificationTitle(notificationTitle);
      final String? safeBody = _safeNotificationBody(
        title: notificationTitle,
        body: notificationBody,
      );
      String? longdata = safeBody;
      BigTextStyleInformation bigTextStyleInformation =
          BigTextStyleInformation(longdata ?? '');

      NotificationDetails notificationDetails = NotificationDetails(
        android: AndroidNotificationDetails(
          "piiink",
          "piiink",
          channelDescription: "This is Piiink Member App",
          importance: Importance.max,
          priority: Priority.high,
          styleInformation: bigTextStyleInformation,
          onlyAlertOnce: true,
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
          presentBanner: true,
        ),
      );

      await _notificationsPlugin.show(
        id,
        safeTitle,
        safeBody,
        notificationDetails,
        payload: message.data["route"],
      );
    } on Exception {
      // print(e);
    }
  }

  static bool _looksLikeOldPaymentSuccessCopy(String? text) {
    final String normalized = text?.toLowerCase() ?? '';
    return normalized.contains('transaction successful') ||
        normalized.contains('transaction completed') ||
        normalized.contains('payment successful');
  }

  static String? _safeNotificationTitle(String? title) {
    return _looksLikeOldPaymentSuccessCopy(title) ? 'Discount approved' : title;
  }

  static String? _safeNotificationBody({
    required String? title,
    required String? body,
  }) {
    if (!_looksLikeOldPaymentSuccessCopy(title) &&
        !_looksLikeOldPaymentSuccessCopy(body)) {
      return body;
    }

    final RegExp amountPattern =
        RegExp(r'(?:AUD|\$)\s*([0-9]+(?:\.[0-9]+)?)', caseSensitive: false);
    final RegExpMatch? amountMatch = amountPattern.firstMatch(body ?? '');
    if (amountMatch == null) {
      return 'Show this screen to the merchant. Customer pays the merchant directly.';
    }

    final double? amount = double.tryParse(amountMatch.group(1) ?? '');
    if (amount == null) {
      return 'Show this screen to the merchant. Customer pays the merchant directly.';
    }

    return 'Merchant can accept \$${amount.toStringAsFixed(2)} from the member.';
  }
}
