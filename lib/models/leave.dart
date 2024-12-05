// To parse this JSON data, do
//
//     final leaveListingData = leaveListingDataFromJson(jsonString);

// ignore_for_file: non_constant_identifier_names

import 'dart:convert';

LeaveListingData leaveListingDataFromJson(String str) => LeaveListingData.fromJson(json.decode(str));

String leaveListingDataToJson(LeaveListingData data) => json.encode(data.toJson());

class LeaveListingData {
  String category;
  List<Leave> data;
  bool hasNext;
  bool hasPrev;
  String message;
  dynamic nextPage;
  int page;
  int pages;
  dynamic prevPage;
  int totalCount;

  LeaveListingData({
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

  factory LeaveListingData.fromJson(Map<String, dynamic> json) => LeaveListingData(
        category: json["category"],
        data: List<Leave>.from(json["data"].map((x) => Leave.fromJson(x))),
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

class Leave {
  int RECORD_ID;
  int EMPLOYEE_ID;
  String EMPLOYEE_NAME;
  DateTime APPLY_DATE;
  String LEAVE_NO;
  DateTime FROM_DATE;
  bool? FROM_HALF;
  DateTime TO_DATE;
  bool? TO_HALF;
  String PURPOSE;
  String? NOTES;
  String? APPROVE_BY;
  DateTime? APPROVE_DATE;
  String? STATUS;
  int? SEQUENCE;
  double? DAYS;

  Leave({
    required this.RECORD_ID,
    required this.EMPLOYEE_ID,
    required this.EMPLOYEE_NAME,
    required this.APPLY_DATE,
    required this.LEAVE_NO,
    required this.FROM_DATE,
    this.FROM_HALF,
    required this.TO_DATE,
    this.TO_HALF,
    required this.PURPOSE,
    this.NOTES,
    this.APPROVE_BY,
    this.APPROVE_DATE,
    this.STATUS,
    this.SEQUENCE,
    required this.DAYS,
  });

  factory Leave.fromJson(Map<String, dynamic> json) => Leave(
        RECORD_ID: json["RECORD_ID"],
        EMPLOYEE_ID: json["EMPLOYEE_ID"],
        EMPLOYEE_NAME: json["EMPLOYEE_NAME"],
        APPLY_DATE: DateTime.parse(json["APPLY_DATE"]),
        LEAVE_NO: json["LEAVE_NO"],
        FROM_DATE: DateTime.parse(json["FROM_DATE"]),
        FROM_HALF: json["FROM_HALF"],
        TO_DATE: DateTime.parse(json["TO_DATE"]),
        TO_HALF: json["TO_HALF"],
        PURPOSE: json["PURPOSE"],
        NOTES: json["NOTES"],
        APPROVE_BY: json["APPROVE_BY"],
        APPROVE_DATE: json["APPROVE_DATE"] == null ? null : DateTime.parse(json["APPROVE_DATE"]),
        STATUS: json["STATUS"],
        SEQUENCE: json["SEQUENCE"],
        DAYS: json["DAYS"].toDouble(),
      );

  Map<String, dynamic> toJson() => {
        "RECORD_ID": RECORD_ID,
        "EMPLOYEE_ID": EMPLOYEE_ID,
        "EMPLOYEE_NAME": EMPLOYEE_NAME,
        "APPLY_DATE": APPLY_DATE,
        "LEAVE_NO": LEAVE_NO,
        "FROM_DATE": FROM_DATE,
        "FROM_HALF": FROM_HALF,
        "TO_DATE": TO_DATE,
        "TO_HALF": TO_HALF,
        "PURPOSE": PURPOSE,
        "NOTES": NOTES,
        "APPROVE_BY": APPROVE_BY,
        "APPROVE_DATE": APPROVE_DATE,
        "STATUS": STATUS,
        "SEQUENCE": SEQUENCE,
        "DAYS": DAYS,
      };
}
