import 'dart:convert';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import '../main.dart';
import '../pages/leave_approval_page.dart';
import '../providers/loginpage_provider.dart';

Future<void> handleBackgroundMessage(RemoteMessage message) async {
  // This is executed when application is in background and a message received (Not tapped a notification)
  if (kDebugMode) {
    print('Title: ${message.notification?.title}');
    print('Body: ${message.notification?.body}');
    print('Payload: ${message.data}');
  }
}

class FirebaseApi {
  final VoidCallback? onLeaveApprovalPN;

  FirebaseApi({this.onLeaveApprovalPN});

  final _firebaseMessaging = FirebaseMessaging.instance;
  bool isAdmin = false;

  final _androidChannel = const AndroidNotificationChannel(
    'high_importance_channel',
    'High Importance Notifications',
    description: 'This channel is used for important notifications.',
    importance: Importance.high,
  );
  final _localNotifications = FlutterLocalNotificationsPlugin();

  void handleMessage(RemoteMessage? message) async {
    // await awesomePopup(navigatorKey.currentContext!, jsonEncode(message), 'Push Notification!', 'info').show();
    if (message == null) return;

    // Also if Leave Request comes then check admin and open Leave Approval Page
    // If Leave is Approved/Cancelled (by admin) then directly open Leave Buttonsheet

    bool user = false;
    final data = message.data.entries.map((e) => e.value).toList();

    if (data.contains('user')) {
      user = true;
    }

    // if (kDebugMode) {
    //   print('Tapped a Notification (Administrator)');
    //   print('Title: ${message.notification?.title}');
    //   print('Body: ${message.notification?.body}');

    //   print("Payload: $data");
    // }

    if (isAdmin == true && user == false) {
      // navigatorKey.currentState?.pushNamed(
      //   NotificationScreen.route,
      //   arguments: message,
      // );

      // if (kDebugMode) {
      //   final routeName = Navigator.of(navigatorKey.currentContext!).widget.pages.last.name;
      //   print('Route Name1 ${routeName ?? ''}');
      //   print('Route Name ${ModalRoute.of(navigatorKey.currentContext!)!.settings.name ?? 'May be null'}');
      // }

      final loginProv = Provider.of<LoginProvider>(navigatorKey.currentContext!,
          listen: false);
      if (loginProv.isLeaveRegisterLoaded) {
        // await awesomePopup(navigatorKey.currentContext!, "Leave Register", 'Push Notification!', 'info').show();
        // navigatorKey.currentState?.pushReplacementNamed('/leaveregister', arguments: message);
        navigatorKey.currentState?.pushReplacementNamed(
          LeaveApprovalPage.route,
          arguments: message,
        );
      } else {
        // await awesomePopup(navigatorKey.currentContext!, "Attendance Register", 'Push Notification!', 'info').show();
        // navigatorKey.currentState?.pushNamed('/leaveregister', arguments: message);
        navigatorKey.currentState?.pushNamed(
          LeaveApprovalPage.route,
          arguments: message,
        );
      }
    } else {
      if (kDebugMode) {
        print('Tapped a Notification (Regular User)');
      }

      //Open Attendance Page with Replacement and extra parameter to open bottom sheet
      if (onLeaveApprovalPN != null) {
        onLeaveApprovalPN!();
      }
    }
  }

  Future<void> initNotifications(bool isadmin) async {
    await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
    // final fCMToken = await _firebaseMessaging.getToken();

    // if (kDebugMode) {
    //   print('Device FCM Token: $fCMToken');
    // }

    isAdmin = isadmin;

    initPushNotifications();
    initLocalNotifications();
  }

  Future<String?> getFCMToken() async {
    if (await _isRunningOnSimulator()) {
      if (kDebugMode) {
        print('Running on iOS Simulator. Returning dummy token.');
      }
      return 'dummy_ios_simulator_token';
    }

    final fCMToken = await _firebaseMessaging.getToken();

    return fCMToken;
  }

  Future<bool> _isRunningOnSimulator() async {
    if (Platform.isIOS) {
      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;

      if (kDebugMode) {
        print('Platform.environment: ${iosInfo.toString()}');
      }
      // Check if the device is a simulator
      return iosInfo.isPhysicalDevice == false;
    }
    return false; // Not iOS, so not a simulator
  }

  Future initLocalNotifications() async {
    const iOS = IOSInitializationSettings();
    const android = AndroidInitializationSettings('@drawable/ic_launcher');
    const settings = InitializationSettings(android: android, iOS: iOS);

    await _localNotifications.initialize(
      settings,
      onSelectNotification: (payload) {
        final message = RemoteMessage.fromMap(jsonDecode(payload!));
        handleMessage(message);
      },
    );

    final platform = _localNotifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await platform?.createNotificationChannel(_androidChannel);
  }

  Future initPushNotifications() async {
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    // FirebaseMessaging.instance.getInitialMessage().then(handleMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(handleMessage);
    FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);

    FirebaseMessaging.onMessage.listen((message) {
      final notification = message.notification;
      if (notification == null) return;

      _localNotifications.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            _androidChannel.id,
            _androidChannel.name,
            channelDescription: _androidChannel.description,
            icon: '@drawable/ic_launcher',
          ),
        ),
        payload: jsonEncode(message.toMap()),
      );
    });
  }

  Future<String> initNotificationsMain() async {
    await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    RemoteMessage? message =
        await FirebaseMessaging.instance.getInitialMessage();

    // if (kDebugMode) {
    //   print("Initially: $initialMessage ");
    // }

    if (message != null) {
      bool user = false;
      final data = message.data.entries.map((e) => e.value).toList();

      if (data.contains('user')) {
        user = true;
      }

      return '1:$user';
      // handleMessage(message0);
    } else {
      return '0:0';
    }
  }
}
