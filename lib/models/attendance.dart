// To parse this JSON data, do
//
//     final attendanceListingData = attendanceListingDataFromJson(jsonString);

// ignore_for_file: non_constant_identifier_names

import 'dart:convert';

AttendanceListingData attendanceListingDataFromJson(String str) => AttendanceListingData.fromJson(json.decode(str));

String stockListingDataToJson(AttendanceListingData data) => json.encode(data.toJson());

class AttendanceListingData {
  String category;
  List<Attendance> data;
  bool hasNext;
  bool hasPrev;
  String message;
  dynamic nextPage;
  int page;
  int pages;
  dynamic prevPage;
  int totalCount;

  AttendanceListingData({
    required this.category,
    required this.data,
    required this.hasNext,
    required this.hasPrev,
    required this.message,
    this.nextPage,
    required this.page,
    required this.pages,
    this.prevPage,
    required this.totalCount,
  });

  factory AttendanceListingData.fromJson(Map<String, dynamic> json) => AttendanceListingData(
        category: json["category"],
        data: List<Attendance>.from(json["data"].map((x) => Attendance.fromJson(x))),
        hasNext: json["has_next"],
        hasPrev: json["has_prev"],
        message: json["message"],
        nextPage: json["next_page"],
        page: json["page"],
        pages: json["pages"],
        prevPage: json["prev_page"],
        totalCount: json["total_count"],
      );

  Map<String, dynamic> toJson() => {
        "category": category,
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
        "has_next": hasNext,
        "has_prev": hasPrev,
        "message": message,
        "next_page": nextPage,
        "page": page,
        "pages": pages,
        "prev_page": prevPage,
        "total_count": totalCount,
      };
}

class Attendance {
  int RECORD_ID;
  DateTime DT_DATE;
  String DAY_NAME;
  String? HOLIDAY;
  bool? NATIONAL_HOLIDAY;
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

  Attendance({
    required this.RECORD_ID,
    required this.DT_DATE,
    required this.DAY_NAME,
    this.HOLIDAY,
    this.NATIONAL_HOLIDAY,
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
  });

  factory Attendance.fromJson(Map<String, dynamic> json) => Attendance(
        RECORD_ID: json["RECORD_ID"],
        DT_DATE: DateTime.parse(json["DT_DATE"]),
        HOLIDAY: json["HOLIDAY"],
        DAY_NAME: json["DAY_NAME"],
        NATIONAL_HOLIDAY: json["NATIONAL_HOLIDAY"],
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
      );

  Map<String, dynamic> toJson() => {
        "RECORD_ID": RECORD_ID,
        "DT_DATE": DT_DATE,
        "DAY_NAME": DAY_NAME,
        "HOLIDAY": HOLIDAY,
        "NATIONAL_HOLIDAY": NATIONAL_HOLIDAY,
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
      };
}
