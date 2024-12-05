// To parse this JSON data, do
//
//     final EmployeeData = EmployeeDataFromJson(jsonString);

// ignore_for_file: non_constant_identifier_names

import 'dart:convert';

EmployeeData EmployeeDataFromJson(String str) => EmployeeData.fromJson(json.decode(str));

String EmployeeDataToJson(EmployeeData data) => json.encode(data.toJson());

class EmployeeData {
  String category;
  List<Employee> data;
  String message;
  int totalCount;
  bool half;

  EmployeeData({
    required this.category,
    required this.data,
    required this.message,
    required this.totalCount,
    required this.half,
  });

  factory EmployeeData.fromJson(Map<String, dynamic> json) => EmployeeData(
        category: json["category"],
        data: List<Employee>.from(json["data"].map((x) => Employee.fromJson(x))),
        message: json["message"],
        totalCount: json["total_count"],
        half: json["half"],
      );

  Map<String, dynamic> toJson() => {
        "category": category,
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
        "message": message,
        "total_count": totalCount,
        "half": half,
      };
}

class Employee {
  int RECORD_ID;
  int? EMP_ID;
  DateTime DT_APPLICABLE;
  String? EMP_CODE;
  String? EMP_NAME;
  bool SEX;
  bool? STATUS;
  bool ADMIN;
  String? ADMINNAME;
  String LATITUDE;
  String LONGITUDE;
  int ALLOWED_DISTANCE;
  String ALLOWED_QRCODE;
  bool SHOW_DELAY;
  bool SHOW_LUNCH;
  String CATEGORIES;
  String DEPARTMENTS;
  String? ADMIN_CATEGORY;
  String? ADMIN_CATEGORY_DEFAULT;
  String? ADMIN_DEPARTMENT;
  String? ADMIN_DEPARTMENT_DEFAULT;
  String? UUID;

  Employee({
    required this.RECORD_ID,
    required this.EMP_ID,
    required this.DT_APPLICABLE,
    required this.EMP_CODE,
    required this.EMP_NAME,
    required this.SEX,
    required this.STATUS,
    required this.ADMIN,
    this.ADMINNAME,
    required this.LATITUDE,
    required this.LONGITUDE,
    required this.ALLOWED_DISTANCE,
    required this.ALLOWED_QRCODE,
    required this.SHOW_DELAY,
    required this.SHOW_LUNCH,
    required this.CATEGORIES,
    required this.DEPARTMENTS,
    this.ADMIN_CATEGORY,
    this.ADMIN_CATEGORY_DEFAULT,
    this.ADMIN_DEPARTMENT,
    this.ADMIN_DEPARTMENT_DEFAULT,
    this.UUID,
  });

  factory Employee.fromJson(Map<String, dynamic> json) => Employee(
        RECORD_ID: json["RECORD_ID"],
        EMP_ID: json["EMP_ID"],
        DT_APPLICABLE: DateTime.parse(json["DT_APPLICABLE"]),
        EMP_CODE: json["EMP_CODE"],
        EMP_NAME: json["EMP_NAME"],
        SEX: json["SEX"],
        STATUS: json["STATUS"],
        ADMIN: json["ADMIN"],
        ADMINNAME: json["ADMINNAME"],
        LATITUDE: json["LATITUDE"],
        LONGITUDE: json["LONGITUDE"],
        ALLOWED_DISTANCE: json["ALLOWED_DISTANCE"],
        ALLOWED_QRCODE: json["ALLOWED_QRCODE"],
        SHOW_DELAY: json["SHOW_DELAY"],
        SHOW_LUNCH: json["SHOW_LUNCH"],
        CATEGORIES: json["CATEGORIES"],
        DEPARTMENTS: json["DEPARTMENTS"],
        ADMIN_CATEGORY: json["ADMIN_CATEGORY"],
        ADMIN_CATEGORY_DEFAULT: json["ADMIN_CATEGORY_DEFAULT"],
        ADMIN_DEPARTMENT: json["ADMIN_DEPARTMENT"],
        ADMIN_DEPARTMENT_DEFAULT: json["ADMIN_DEPARTMENT_DEFAULT"],
        UUID: json["UUID"],
      );

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};

    data['RECORD_ID'] = RECORD_ID;
    data['EMP_ID'] = EMP_ID;
    data['DT_APPLICABLE'] = DT_APPLICABLE;

    data['EMP_CODE'] = EMP_CODE;
    data['EMP_NAME'] = EMP_NAME;
    data['SEX'] = SEX;
    data['STATUS'] = STATUS;
    data['ADMIN'] = ADMIN;
    data['ADMINNAME'] = ADMINNAME;

    data['LATITUDE'] = LATITUDE;
    data['LONGITUDE'] = LONGITUDE;
    data['ALLOWED_DISTANCE'] = ALLOWED_DISTANCE;
    data['ALLOWED_QRCODE'] = ALLOWED_QRCODE;

    data['SHOW_DELAY'] = SHOW_DELAY;
    data['SHOW_LUNCH'] = SHOW_LUNCH;

    data['CATEGORIES'] = CATEGORIES;
    data['DEPARTMENTS'] = DEPARTMENTS;

    data['ADMIN_CATEGORY'] = ADMIN_CATEGORY;
    data['ADMIN_CATEGORY_DEFAULT'] = ADMIN_CATEGORY_DEFAULT;
    data['ADMIN_DEPARTMENT'] = ADMIN_DEPARTMENT;
    data['ADMIN_DEPARTMENT_DEFAULT'] = ADMIN_DEPARTMENT_DEFAULT;

    data['UUID'] = UUID;

    return data;
  }
}
