class Config {
  static const String appName = "Hepta Attendance App";
  static const String googleAPIKey = 'AIzaSyBICK_7fVGqxnKen26jpu13dZtS1fEqBMw';
  static const String apiURL =
      'ec2-65-1-86-48.ap-south-1.compute.amazonaws.com:5002';
  // static const String apiURL = '127.0.0.1:5002';
  static const checkIp = "/checkip2";
  static const vecationListAPI = "/vecationlist";
  static const punchAPI = "/attendance/scan";
  static const printAPI = "/attendance/qrcodepdf";
  static const attendanceListingAPI = "/attendance/attendancedata";
  static const leaveListingAPI = "/attendance/leavedata";
  static const leaveAddAPI = "/attendance/leave";
  static const leaveActionAPI = "/attendance/leaveapprove";
  static const attendancePunchAPI = "/attendance/punches";
  static const attendanceSummaryAPI = "/attendance/attendancesummary";
  static const attendanceEmpWiseAPI = "/attendance/attendanceempwise";
  static const attendanceConciseAPI = "/attendance/attendanceconcise";
  static const attendanceLeaveSummaryAPI = "/attendance/worksummary";
}
