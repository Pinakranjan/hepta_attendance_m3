import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:provider/provider.dart';

import '../providers/loginpage_provider.dart';

class NetworkController extends GetxController {
  // final Connectivity _connectivity = Connectivity();

  //Connection Checker 31-07-23
  final InternetConnection connection = InternetConnection.createInstance(
    checkInterval: const Duration(seconds: 5),
    customCheckOptions: [
      InternetCheckOption(uri: Uri.parse('8.8.8.8')),
      InternetCheckOption(uri: Uri.parse('8.8.4.4')),
      // InternetCheckOption(uri: Uri.parse('65.1.86.48')),
      // InternetCheckOption(uri: Uri.parse('http://google.com')),
    ],
  );

  late StreamSubscription<InternetStatus> listener;

  @override
  void dispose() {
    listener.cancel();
    super.dispose();
  }

  @override
  void onInit() {
    super.onInit();

    listener = connection.onStatusChange.listen((InternetStatus status) {
      if (Get.isSnackbarOpen) {
        Get.closeCurrentSnackbar();
      }

      final provider = Provider.of<LoginProvider>(Get.context as BuildContext, listen: false);

      switch (status) {
        case InternetStatus.connected:
          // The internet is now connected
          provider.noInternet = false;
          break;
        case InternetStatus.disconnected:
          // The internet is now disconnected
          provider.noInternet = true;

          // if (provider.deviceId != '') {
          Get.rawSnackbar(
            messageText: const Text(
              'You are disconnected from the internet.',
              style: TextStyle(color: Colors.white, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            isDismissible: false,
            duration: const Duration(days: 1),
            backgroundColor: Colors.red[400]!,
            icon: const Icon(
              Icons.wifi_off,
              color: Colors.white,
              size: 35,
            ),
            margin: EdgeInsets.zero,
            snackStyle: SnackStyle.GROUNDED,
          );
          // }

          break;
      }
    });
  }
}
