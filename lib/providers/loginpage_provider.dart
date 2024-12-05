import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class LoginProvider extends ChangeNotifier {
  String _deviceId = '';
  get deviceId => _deviceId;

  set deviceId(value) => {_deviceId = value};

  String? _fcmToken;
  get fcmToken => _fcmToken;

  set fcmToken(value) => {_fcmToken = value};

  String? _adminName;
  get adminName => _adminName;

  set adminName(value) => {_adminName = value};

  bool _isLeaveRegisterLoaded = false;
  bool get isLeaveRegisterLoaded => _isLeaveRegisterLoaded;

  set isLeaveRegisterLoaded(bool value) => {_isLeaveRegisterLoaded = value};

  bool _isLocationEnabled = false;
  bool get isLocationEnabled => _isLocationEnabled;

  set isLocationEnabled(bool value) => {_isLocationEnabled = value, notifyListeners()};

  bool? _noInternet;

  get noInternet => _noInternet;

  set noInternet(value) => {_noInternet = value, notifyListeners()};

  bool _isApiCallProcess = false;

  get isApiCallProcess => _isApiCallProcess;

  set isApiCallProcess(value) => {_isApiCallProcess = value, notifyListeners()};

  String _errorText = '';
  get errorText => _errorText;

  set errorText(value) => {_errorText = value, notifyListeners()}; //Not To Reset

  late Box box1;
  void createBox() async {
    box1 = await Hive.openBox('heptalogindata');
  }

  Future<String> getHiveDataValue(String key) async {
    box1 = await Hive.openBox('heptalogindata');

    if (box1.get(key) != null) {
      return box1.get(key).toString();
    }

    return '0';
  }

  void setHiveData(String key, String value) {
    box1.put(key, value);
  }

  void removeHiveData(String key) {
    box1.delete(key);
  }

  void reset() {
    isApiCallProcess = false;
    errorText = '';

    createBox();
    // notifyListeners();
  }
}
