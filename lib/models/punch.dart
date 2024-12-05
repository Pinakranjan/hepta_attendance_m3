// To parse this JSON data, do
//
//     final punchListingData = punchListingDataFromJson(jsonString);

// ignore_for_file: non_constant_identifier_names

import 'dart:convert';

PunchListingData punchListingDataFromJson(String str) => PunchListingData.fromJson(json.decode(str));

String punchListingDataToJson(PunchListingData data) => json.encode(data.toJson());

class PunchListingData {
  String category;
  List<Punch> data;
  bool hasNext;
  bool hasPrev;
  String message;
  dynamic nextPage;
  int page;
  int pages;
  dynamic prevPage;
  int totalCount;

  PunchListingData({
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

  factory PunchListingData.fromJson(Map<String, dynamic> json) => PunchListingData(
        category: json["category"],
        data: List<Punch>.from(json["data"].map((x) => Punch.fromJson(x))),
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

class Punch {
  DateTime DT_DATE;
  String? PUNCH_TYPE;

  Punch({
    required this.DT_DATE,
    required this.PUNCH_TYPE,
  });

  factory Punch.fromJson(Map<String, dynamic> json) => Punch(
        DT_DATE: DateTime.parse(json["DT_DATE"]),
        PUNCH_TYPE: json["PUNCH_TYPE"],
      );

  Map<String, dynamic> toJson() => {
        "DT_DATE": DT_DATE,
        "PUNCH_TYPE": PUNCH_TYPE,
      };
}
