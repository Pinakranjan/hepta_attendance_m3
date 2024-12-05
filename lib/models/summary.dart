// To parse this JSON data, do
//
//     final summaryListingData = summaryListingDataFromJson(jsonString);

// ignore_for_file: non_constant_identifier_names

import 'dart:convert';

SummaryListingData summaryListingDataFromJson(String str) => SummaryListingData.fromJson(json.decode(str));

String summaryListingDataToJson(SummaryListingData data) => json.encode(data.toJson());

class SummaryListingData {
  String category;
  List<Summary> data;
  String message;
  bool half;
  String? halfsince;

  SummaryListingData({
    required this.category,
    required this.data,
    required this.message,
    required this.half,
    this.halfsince,
  });

  factory SummaryListingData.fromJson(Map<String, dynamic> json) => SummaryListingData(
        category: json["category"],
        data: List<Summary>.from(json["data"].map((x) => Summary.fromJson(x))),
        message: json["message"],
        half: json["half"],
        halfsince: json["halfsince"],
      );

  Map<String, dynamic> toJson() => {
        "category": category,
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
        "message": message,
        "half": half,
        "halfsince": halfsince,
      };
}

class Summary {
  String FIN_YEAR;
  String YEAR_MTH;
  String MONTH_NM;
  int DAYS;
  int SUNDAYS;
  int HOLIDAYS;
  int PRESENT;
  int ABSENT;
  int LEAVE;
  int WEEKOFF_EXCLUDED;
  int HOLIDAY_EXCLUDED;

  Summary({
    required this.FIN_YEAR,
    required this.YEAR_MTH,
    required this.MONTH_NM,
    required this.DAYS,
    required this.SUNDAYS,
    required this.HOLIDAYS,
    required this.PRESENT,
    required this.ABSENT,
    required this.LEAVE,
    required this.WEEKOFF_EXCLUDED,
    required this.HOLIDAY_EXCLUDED,
  });

  factory Summary.fromJson(Map<String, dynamic> json) => Summary(
        FIN_YEAR: json["FIN_YEAR"],
        YEAR_MTH: json["YEAR_MTH"],
        MONTH_NM: json["MONTH_NM"],
        DAYS: json["DAYS"],
        SUNDAYS: json["SUNDAYS"],
        HOLIDAYS: json["HOLIDAYS"],
        PRESENT: json["PRESENT"],
        ABSENT: json["ABSENT"],
        LEAVE: json["LEAVE"],
        WEEKOFF_EXCLUDED: json["WEEKOFF_EXCLUDED"],
        HOLIDAY_EXCLUDED: json["HOLIDAY_EXCLUDED"],
      );

  Map<String, dynamic> toJson() => {
        "FIN_YEAR": FIN_YEAR,
        "YEAR_MTH": YEAR_MTH,
        "MONTH_NM": MONTH_NM,
        "DAYS": DAYS,
        "SUNDAYS": SUNDAYS,
        "HOLIDAYS": HOLIDAYS,
        "PRESENT": PRESENT,
        "ABSENT": ABSENT,
        "LEAVE": LEAVE,
        "WEEKOFF_EXCLUDED": WEEKOFF_EXCLUDED,
        "HOLIDAY_EXCLUDED": HOLIDAY_EXCLUDED,
      };
}
