// To parse this JSON data, do
//
//     final vacationListingData = vacationListingDataFromJson(jsonString);

// ignore_for_file: non_constant_identifier_names

import 'dart:convert';

VacationListingData vecationListingDataFromJson(String str) => VacationListingData.fromJson(json.decode(str));

String vacationListingDataToJson(VacationListingData data) => json.encode(data.toJson());

class VacationListingData {
  String category;
  List<Vacation> data;
  bool hasNext;
  bool hasPrev;
  String message;
  dynamic nextPage;
  int page;
  int pages;
  dynamic prevPage;
  int totalCount;

  VacationListingData({
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

  factory VacationListingData.fromJson(Map<String, dynamic> json) => VacationListingData(
        category: json["category"],
        data: List<Vacation>.from(json["data"].map((x) => Vacation.fromJson(x))),
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

class Vacation {
  int RECORD_ID;
  DateTime DT_DATE;
  String? HOLIDAY;
  bool? NATIONAL_HOLIDAY;

  Vacation({
    required this.RECORD_ID,
    required this.DT_DATE,
    this.HOLIDAY,
    this.NATIONAL_HOLIDAY,
  });

  factory Vacation.fromJson(Map<String, dynamic> json) => Vacation(
        RECORD_ID: json["RECORD_ID"],
        DT_DATE: DateTime.parse(json["DT_DATE"]),
        HOLIDAY: json["HOLIDAY"],
        NATIONAL_HOLIDAY: json["NATIONAL_HOLIDAY"],
      );

  Map<String, dynamic> toJson() => {
        "RECORD_ID": RECORD_ID,
        "DT_DATE": DT_DATE,
        "HOLIDAY": HOLIDAY,
        "NATIONAL_HOLIDAY": NATIONAL_HOLIDAY,
      };
}
