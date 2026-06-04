import 'dart:io';

import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:touristsaver/common/services/device_info.dart';
import 'package:touristsaver/constants/pref.dart';
import 'package:touristsaver/constants/url_end_point.dart';

import '../../constants/helper.dart';
import '../app_variables.dart';
import 'local_notification_service.dart';

// Receives message when app is in the background and terminated
@pragma('vm:entry-point')
Future<void> backgroundMsgHandler(RemoteMessage message) async {
  if (message.notification != null) {
    AppVariables.notificationLabel.value += 1;
    await Pref().writeInt(
        key: 'notificationsCount', value: AppVariables.notificationLabel.value);
  }
  debugPrint('backgroundMsgHandler called');
}

class FirebaseApi {
  final _firebaseMessaging = FirebaseMessaging.instance;
  Pref pref = Pref();
  static final FirebaseApi _firebaseApi = FirebaseApi._();

  factory FirebaseApi() {
    return _firebaseApi;
  }

  FirebaseApi._();

  Future<void> initNotifications(BuildContext context) async {
    try {
      NotificationSettings settings =
          await _firebaseMessaging.requestPermission();
      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        final String? fcmToken = await _firebaseMessaging.getToken();
        if (fcmToken != null) {
          saveAndSendToken(fcmToken);
        }
        AppVariables.initNotifications = false;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          onMessagingListener(context);
        });
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  increaseNotificationCount() async {
    AppVariables.notificationLabel.value += 1;
    await pref.writeInt(
        key: 'notificationsCount', value: AppVariables.notificationLabel.value);
  }

  void handleMessage(BuildContext context) {
    context.pushNamed('notification');
  }

  Future<void> onMessagingListener(BuildContext context) async {
    LocalNotificationService.initialize(context);

    // Required to display a heads up notification in iOS platform
    if (Platform.isIOS) {
      await _firebaseMessaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
    }

    // Receives the message when the app is in terminated state
    // and the app is opened when the user taps on it
    _firebaseMessaging.getInitialMessage().then((message) {
      if (message != null && message.notification != null) {
        increaseNotificationCount();
        handleMessage(context);
        debugPrint('getInitialMessage called');
      }
    });

    // When the app is opened on the foreground
    FirebaseMessaging.onMessage.listen((message) {
      if (message.notification != null) {
        if (Platform.isAndroid) {
          LocalNotificationService.display(message);
        }
        increaseNotificationCount();
        handleMessage;
      }
      debugPrint('onMessage called');
    });

    // When the app is in the background but not terminated and user taps
    // on the notification
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      if (message.notification != null) {
        increaseNotificationCount();
        handleMessage(context);
      }
      debugPrint('onMessageOpened called');
      // context.pushNamed('notification');
    });

    FirebaseMessaging.onBackgroundMessage(backgroundMsgHandler);
  }

  saveAndSendToken(String fcmToken) async {
    bool? isTokenSent = await pref.readBool(key: 'isTokenSent');
    if (isTokenSent == null || isTokenSent == false) {
      await pref.writeData(key: 'fcmToken', value: fcmToken);
      String deviceId = await getDeviceId();
      try {
        Dio dio = await getClient();
        await dio.post(
          addFcmToken,
          data: {
            "fcmToken": fcmToken,
            "deviceId": deviceId,
          },
        );
        pref.setBool(key: 'isTokenSent', value: true);
      } catch (e) {
        // debugPrint(e.toString());
      }
    }
  }
}
