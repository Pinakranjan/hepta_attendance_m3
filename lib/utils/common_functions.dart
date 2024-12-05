// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/services.dart';

import '../config.dart';
import '../services/navigation_service.dart';
import 'color_constraints.dart';
import 'package:flutter_exit_app/flutter_exit_app.dart';

AwesomeDialog awesomePopup(
    BuildContext context, String r, String? title, String dialogType) {
  DialogType dialogType2;

  if (dialogType == 'question') {
    dialogType2 = DialogType.question;
  } else if (dialogType == 'error') {
    dialogType2 = DialogType.error;
  } else if (dialogType == 'noHeader') {
    dialogType2 = DialogType.noHeader;
  } else if (dialogType == 'info') {
    dialogType2 = DialogType.info;
  } else if (dialogType == 'warning') {
    dialogType2 = DialogType.warning;
  } else {
    dialogType2 = DialogType.success;
  }

  if (dialogType2 == DialogType.question) {
    return AwesomeDialog(
      context: context,
      dialogType: dialogType2,
      animType: AnimType.scale,
      title: title != '' ? title : Config.appName,
      desc: r,
      btnCancelOnPress: () {},
      btnOkOnPress: () {
        if (r.contains('close the application?')) {
          // closeAppUsingSystemPop();
          // closeAppUsingExit();

          // call this to exit app
          if (Platform.isAndroid) {
            FlutterExitApp.exitApp();
          } else {
            FlutterExitApp.exitApp(iosForceExit: true);
          }
        }
      },
      btnCancelIcon: Icons.cancel,
      showCloseIcon: true,
      btnOkIcon: Icons.check,
      padding: const EdgeInsets.all(20),
      btnOkColor: Colors.green.shade700,
      barrierColor: ColorConfig.darkMain.withOpacity(0.6),
      titleTextStyle: const TextStyle(
          color: Colors.black, fontSize: 20, fontWeight: FontWeight.w700),
      descTextStyle: const TextStyle(
          color: Colors.black, fontSize: 14, fontWeight: FontWeight.normal),
      dialogBackgroundColor: Colors.white,
      // buttonsBorderRadius: const BorderRadius.all(
      //   Radius.circular(2),
      // ),
    );
  } else {
    return AwesomeDialog(
      context: context,
      dialogType: dialogType2,
      animType: AnimType.scale,
      title: title != '' ? title : Config.appName,
      desc: r,
      btnOkOnPress: () {},
      showCloseIcon: false,
      btnOkIcon:
          dialogType2 == DialogType.noHeader || dialogType2 == DialogType.error
              ? Icons.close_outlined
              : Icons.cancel,
      btnOkText:
          dialogType2 == DialogType.noHeader || dialogType2 == DialogType.error
              ? 'Close'
              : 'Ok',
      padding: const EdgeInsets.all(20),
      btnOkColor: (r.toLowerCase().contains('success') ||
              dialogType2 == DialogType.success ||
              dialogType2 == DialogType.info)
          ? Colors.green.shade700
          : Colors.red,
      barrierColor: ColorConfig.darkMain.withOpacity(0.6),
      titleTextStyle: const TextStyle(
          color: Colors.black, fontSize: 20, fontWeight: FontWeight.w700),
      descTextStyle: const TextStyle(
          color: Colors.black, fontSize: 14, fontWeight: FontWeight.normal),
      dialogBackgroundColor: Colors.white,
      // buttonsBorderRadius: const BorderRadius.all(
      //   Radius.circular(2),
      // ),
    );
  }
}

void closeAppUsingSystemPop() {
  // SystemNavigator.pop(animated: true);
  SystemChannels.platform.invokeMethod<void>('SystemNavigator.pop');
}

void closeAppUsingExit() {
  exit(0);
}

void dioMessage(DioException e, String type, String location,
    BuildContext context, bool show) async {
  if (kDebugMode) {
    // print('$type: $e (${e.type})');
    // print(location);
  }

  if (e.type == DioExceptionType.connectionTimeout ||
      e.type == DioExceptionType.receiveTimeout) {
    if (show == true) {
      await awesomePopup(
              context,
              "The request connection took very long, hence it was aborted!",
              type,
              'error')
          .show();
    }
  } else if (e.type == DioExceptionType.unknown &&
      e.toString().contains('SocketException')) {
    if (show == true) {
      await awesomePopup(
              context, "APIs didn't not respond in time!", type, 'error')
          .show();
    }
  } else if (e.type == DioExceptionType.unknown ||
      e.type == DioExceptionType.connectionError) {
    if (show == true) {
      await awesomePopup(
              context, "APIs didn't not respond in time!", type, 'error')
          .show();
    }
  } else if (e.response!.statusCode == 400 ||
      e.response!.statusCode == 404 ||
      e.response!.statusCode == 406) {
    if (show == true) {
      await awesomePopup(context, e.response!.data['message'], type, 'error')
          .show();
    }
  } else if (e.response!.statusCode == 500) {
    if (show == true) {
      await awesomePopup(context, e.message.toString(), type, 'error').show();
    }
  } else if (e.response!.statusCode == 401 &&
      e.response!.data['message'] != null) {
    if (show == true) {
      await awesomePopup(context, e.response!.data['message'], type, 'error')
          .show();
    }
  } else if (e.response!.statusCode == 403 && e.response!.data['msg'] != null) {
    if (show == true) {
      await awesomePopup(context, e.response!.data['msg'], type, 'error')
          .show();
    }
  }
}

void showSnackBarOld(String message, Color color) {
  final snackBar = SnackBar(content: Text(message), backgroundColor: color);
  ScaffoldMessenger.of(
          NavigationService.instance.navigationKey!.currentContext!)
      .showSnackBar(snackBar);
}
