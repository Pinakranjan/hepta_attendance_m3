// To parse this JSON data, do
//
//     final AttendanceEmpWiseListingData = AttendanceEmpWiseListingDataFromJson(jsonString);

// ignore_for_file: non_constant_identifier_names

import 'dart:convert';

AttendanceEmpWiseListingData AttendanceEmpWiseListingDataFromJson(String str) => AttendanceEmpWiseListingData.fromJson(json.decode(str));

String AttendanceEmpWiseDataToJson(AttendanceEmpWiseListingData data) => json.encode(data.toJson());

class AttendanceEmpWiseListingData {
  String category;
  List<AttendanceEmpWise> data;
  String message;
  int page;
  int pages;
  int totalCount;

  AttendanceEmpWiseListingData({
    required this.category,
    required this.data,
    required this.message,
    required this.page,
    required this.pages,
    required this.totalCount,
  });

  factory AttendanceEmpWiseListingData.fromJson(Map<String, dynamic> json) => AttendanceEmpWiseListingData(
        category: json["category"],
        data: List<AttendanceEmpWise>.from(json["data"].map((x) => AttendanceEmpWise.fromJson(x))),
        message: json["message"],
        page: json["page"],
        pages: json["pages"],
        totalCount: json["total_count"],
      );

  Map<String, dynamic> toJson() => {
        "category": category,
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
        "message": message,
        "page": page,
        "pages": pages,
        "total_count": totalCount,
      };
}

class AttendanceEmpWise {
  int RECORD_ID;
  DateTime DT_DATE;
  String DAY_NAME;
  String? HOLIDAY;
  bool? NATIONAL_HOLIDAY;
  String? EMP_NAME;
  String? EMP_CODE;
  bool? SEX;
  String? CATEGORY;
  String? DEPARTMENT;
  String? STATUS;
  String? REMARKS;
  int? SCANS;
  String? DETAILS;
  String DETAILS2;
  bool? LUNCHDELAY;
  String? LUNCHTIME;
  String? LEAVE;
  String? LEAVE_PURPOSE;
  String? LEAVE_STATUS;
  DateTime? FROM_DATE;
  String? FROM_HALF;
  DateTime? TO_DATE;
  String? TO_HALF;
  String? WORKTIME;
  bool HALF;

  AttendanceEmpWise({
    required this.RECORD_ID,
    required this.DT_DATE,
    required this.DAY_NAME,
    this.HOLIDAY,
    this.NATIONAL_HOLIDAY,
    this.EMP_NAME,
    this.EMP_CODE,
    this.SEX,
    this.CATEGORY,
    this.DEPARTMENT,
    this.STATUS,
    this.REMARKS,
    this.SCANS,
    this.DETAILS,
    required this.DETAILS2,
    this.LUNCHDELAY,
    this.LUNCHTIME,
    this.LEAVE,
    this.LEAVE_PURPOSE,
    this.LEAVE_STATUS,
    this.FROM_DATE,
    this.FROM_HALF,
    this.TO_DATE,
    this.TO_HALF,
    this.WORKTIME,
    required this.HALF,
  });

  factory AttendanceEmpWise.fromJson(Map<String, dynamic> json) => AttendanceEmpWise(
        RECORD_ID: json["RECORD_ID"],
        DT_DATE: DateTime.parse(json["DT_DATE"]),
        HOLIDAY: json["HOLIDAY"],
        DAY_NAME: json["DAY_NAME"],
        NATIONAL_HOLIDAY: json["NATIONAL_HOLIDAY"],
        EMP_NAME: json["EMP_NAME"],
        EMP_CODE: json["EMP_CODE"],
        SEX: json["SEX"],
        CATEGORY: json["CATEGORY"],
        DEPARTMENT: json["DEPARTMENT"],
        STATUS: json["STATUS"],
        REMARKS: json["REMARKS"],
        SCANS: json["SCANS"],
        DETAILS: json["DETAILS"],
        DETAILS2: json["DETAILS2"],
        LUNCHDELAY: json["LUNCHDELAY"],
        LUNCHTIME: json["LUNCHTIME"],
        LEAVE: json["LEAVE"],
        LEAVE_PURPOSE: json["LEAVE_PURPOSE"],
        LEAVE_STATUS: json["LEAVE_STATUS"],
        FROM_DATE: json["FROM_DATE"] == null ? null : DateTime.parse(json["FROM_DATE"]),
        FROM_HALF: json["FROM_HALF"],
        TO_DATE: json["TO_DATE"] == null ? null : DateTime.parse(json["TO_DATE"]),
        TO_HALF: json["TO_HALF"],
        WORKTIME: json["WORKTIME"],
        HALF: json["HALF"],
      );

  Map<String, dynamic> toJson() => {
        "RECORD_ID": RECORD_ID,
        "DT_DATE": DT_DATE,
        "DAY_NAME": DAY_NAME,
        "HOLIDAY": HOLIDAY,
        "NATIONAL_HOLIDAY": NATIONAL_HOLIDAY,
        "EMP_NAME": EMP_NAME,
        "EMP_CODE": EMP_CODE,
        "SEX": SEX,
        "CATEGORY": CATEGORY,
        "DEPARTMENT": DEPARTMENT,
        "STATUS": STATUS,
        "REMARKS": REMARKS,
        "SCANS": SCANS,
        "DETAILS": DETAILS,
        "DETAILS2": DETAILS2,
        "LUNCHDELAY": LUNCHDELAY,
        "LUNCHTIME": LUNCHTIME,
        "LEAVE": LEAVE,
        "LEAVE_PURPOSE": LEAVE_PURPOSE,
        "LEAVE_STATUS": LEAVE_STATUS,
        "FROM_DATE": FROM_DATE,
        "FROM_HALF": FROM_HALF,
        "TO_DATE": TO_DATE,
        "TO_HALF": TO_HALF,
        "WORKTIME": WORKTIME,
        "HALF": HALF,
      };
}
