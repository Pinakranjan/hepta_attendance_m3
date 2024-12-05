// To parse this JSON data, do
//
//     final AttendanceConciseData = AttendanceConciseDataFromJson(jsonString);

// ignore_for_file: non_constant_identifier_names

import 'dart:convert';

AttendanceConciseData AttendanceConciseDataFromJson(String str) => AttendanceConciseData.fromJson(json.decode(str));

class AttendanceConciseData {
  String category;
  List<AttendanceConcise> available;
  List<AttendanceConcise> onleave;
  List<AttendanceConcise> absents;
  List<AttendanceConcise> yettocome;
  List<Summarise> summarise;
  String message;

  AttendanceConciseData({
    required this.category,
    required this.available,
    required this.onleave,
    required this.absents,
    required this.yettocome,
    required this.summarise,
    required this.message,
  });

  factory AttendanceConciseData.fromJson(Map<String, dynamic> json) => AttendanceConciseData(
        category: json["category"],
        available: List<AttendanceConcise>.from(json["available"].map((x) => AttendanceConcise.fromJson(x))),
        onleave: List<AttendanceConcise>.from(json["onleave"].map((x) => AttendanceConcise.fromJson(x))),
        absents: List<AttendanceConcise>.from(json["absents"].map((x) => AttendanceConcise.fromJson(x))),
        yettocome: List<AttendanceConcise>.from(json["yettocome"].map((x) => AttendanceConcise.fromJson(x))),
        summarise: List<Summarise>.from(json["summarise"].map((x) => Summarise.fromJson(x))),
        message: json["message"],
      );

  Map<String, dynamic> toJson() => {
        "category": category,
        "available": List<dynamic>.from(available.map((x) => x.toJson())),
        "onleave": List<dynamic>.from(onleave.map((x) => x.toJson())),
        "absents": List<dynamic>.from(absents.map((x) => x.toJson())),
        "yettocome": List<dynamic>.from(yettocome.map((x) => x.toJson())),
        "summarise": List<dynamic>.from(summarise.map((x) => x.toJson())),
        "message": message,
      };
}

class AttendanceConcise {
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

  AttendanceConcise({
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

  factory AttendanceConcise.fromJson(Map<String, dynamic> json) => AttendanceConcise(
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

class Summarise {
  int RECORD_ID;
  String DETAILS;
  int VALUE;
  int PERCENTAGE;
  String? HOLIDAY;

  Summarise({
    required this.RECORD_ID,
    required this.DETAILS,
    required this.VALUE,
    required this.PERCENTAGE,
    this.HOLIDAY,
  });

  factory Summarise.fromJson(Map<String, dynamic> json) => Summarise(
        RECORD_ID: json["RECORD_ID"],
        DETAILS: json["DETAILS"],
        VALUE: json["VALUE"],
        PERCENTAGE: json["PERCENTAGE"],
        HOLIDAY: json["HOLIDAY"],
      );

  Map<String, dynamic> toJson() => {
        "RECORD_ID": RECORD_ID,
        "DETAILS": DETAILS,
        "VALUE": VALUE,
        "PERCENTAGE": PERCENTAGE,
        "HOLIDAY": HOLIDAY,
      };
}
