// ignore_for_file: prefer_const_constructors, use_build_context_synchronously, prefer_final_fields

import 'dart:async';
import 'dart:io';

import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:dio/dio.dart' as dio;
import 'package:expansion_tile_card/expansion_tile_card.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_progress_hud/flutter_progress_hud.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:hepta_attendance/models/attendanceempwise.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:latlong2/latlong.dart';
import 'package:lottie/lottie.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:stack_trace/stack_trace.dart';
import 'package:intl/intl.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hepta_attendance/providers/loginpage_provider.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import '../api/firebase_api.dart';
import '../config.dart';
import '../dependency_injection.dart';
import '../models/attendance.dart';
import '../models/attendanceconcise.dart';
import '../models/employee.dart';
import '../models/leave.dart';
import '../models/punch.dart';
import '../models/summary.dart';
import '../models/vecation.dart';
import '../providers/custom_theme_provider.dart';
import '../services/dio_service.dart';
import '../services/navigation_service.dart';
import '../utils/color_constraints.dart';
import '../utils/common_functions.dart';
import '../widgets/header_widget.dart';
import '../widgets/input_text_widget.dart';
import '../widgets/page_name_widget.dart';
import '../widgets/popup_widget.dart';
import '../widgets/popup_widget_v2.dart';
import 'leave_approval_page.dart';

enum Actions { share, delete, archive }

class AttendancePage extends StatefulWidget {
  final Map<String, dynamic>? args;
  const AttendancePage(this.args, {Key? key}) : super(key: key);

  @override
  State<AttendancePage> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<AttendancePage>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  GlobalKey<FormState> globalFormKey = GlobalKey<FormState>();
  GlobalKey<FormState> globalFormKeyLeave = GlobalKey<FormState>();
  GlobalKey<FormState> globalFormKeyLeaveAdd = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _leaveScaffoldKey = GlobalKey<ScaffoldState>();

  late final AnimationController _controller;

  late LocationPermission permission;
  late StreamSubscription<Position> locationSubscription;
  late DeviceInfoPlugin deviceInfo;
  String? deviceId;
  String? fcmToken;
  bool servicestatus = false;
  bool registered = false;
  bool blacklisted = false;
  bool initialProcess = false;
  bool admin = false;
  bool ceo = false;
  bool half = false;
  bool nottoscan = false;
  String? adminName;
  String? regmsg;

  double? lat0;
  double? long0;

  String? lat;
  String? long;
  double? distance;
  int? allowedDistance;

  String filePathQR = '';

  List<Employee> userdata = [];

  int currentPage = 1;
  int totalPages = 1;
  final RefreshController refreshController =
      RefreshController(initialRefresh: true);
  bool initialRefresh = true;
  bool userEntryRefresh = false;

  bool dragUpDown = false;
  late DraggableScrollableController dragController;
  late DraggableScrollableController dragControllerLeave;
  StateSetter? setStateVecation;
  List<Vacation> vecationdata = [];
  bool vecationlistResult = false;

  List<Attendance> attendancedata = [];
  // This list holds the data for the list view
  List<Attendance> _foundAttendance = [];

  List<GlobalKey<ExpansionTileCardState>> cardKeyList = [];

  DateRangePickerController dtRangeController = DateRangePickerController();
  StateSetter? setStateLeave;
  List<Leave> leavedata = [];
  bool leavelistResult = false;
  late TextEditingController purposeController;
  late TextEditingController remarksController;
  late FocusNode purposeFocus;
  late FocusNode fromHalfFocus;
  late FocusNode toHalfFocus;
  String? fromDate;
  String? toDate;
  String? fromHalf;
  String? toHalf;

  StateSetter? setStateAddLeave;
  bool saveLeaveClicked = false;
  bool actionOnLeaveClicked = false;

  bool submitPressed = false;
  bool punchlistResult = false;
  bool summarylistResult = false;

  bool showDelay = false;
  bool showLunch = false;
  bool adminmode = false;
  String version = 'V1.4';
  String? uuid;
  DateTime selectedDate = DateTime.now();
  String section = 'Section';
  String category = 'Category';
  bool concise = true;

  int currentPageEmpWise = 1;
  int totalPagesEmpWise = 1;
  List<AttendanceEmpWise> attendanceEmpWisedata = [];
  // This list holds the data for the list view
  List<AttendanceEmpWise> _foundAttendanceEmpWise = [];
  List<GlobalKey<ExpansionTileCardState>> cardKeyListEmpWise = [];

  List<Summarise> attendanceConcisedata = [];
  // This list holds the data for the list view
  List<Summarise> _foundAttendanceConcise = [];
  List<AttendanceConcise> conciseAvailabledata = [];
  List<AttendanceConcise> conciseAbsentdata = [];
  List<AttendanceConcise> conciseOnLeavedata = [];
  List<AttendanceConcise> conciseYetToComedata = [];

  List<GlobalKey<ExpansionTileCardState>> cardKeyListConcise = [];

  static const channel = MethodChannel('heptaattendance/serialno');

  @override
  void initState() {
    super.initState();

    DependencyInjection.init();

    _controller = AnimationController(vsync: this);
    dragController = DraggableScrollableController();
    dragControllerLeave = DraggableScrollableController();
    purposeController = TextEditingController();
    remarksController = TextEditingController();
    purposeFocus = FocusNode();
    fromHalfFocus = FocusNode();
    toHalfFocus = FocusNode();

    //add an observer to monitor the widget lyfecycle changes
    WidgetsBinding.instance.addObserver(this);

    // This is called after build complete
    WidgetsBinding.instance.endOfFrame.then((_) async {
      if (mounted) {
        // if (kDebugMode) {
        //   print('Notify: ${widget.args!["notify"]}');
        // }
        await Hive.initFlutter();
        Box box1 = await Hive.openBox('heptalogindata');

        if (box1.get('uuid') != null) {
          uuid = box1.get('uuid');
          if (kDebugMode) {
            print('UUID: $uuid');
          }
        }

        await checkGps(context, false);
        if (deviceId != 'NA') {
          await checkip(context, deviceId, fcmToken);
          getVecationData(context);

          if (initialProcess == true &&
              registered == true &&
              blacklisted == false &&
              fcmToken != null) {
            FirebaseApi(onLeaveApprovalPN: _showLeaveButtonSheet)
                .initNotifications(admin);

            if (widget.args!["notify"].toString().contains('1:')) {
              if (admin &&
                  widget.args!["notify"].toString().contains('false')) {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => LeaveApprovalPage()));
              } else {
                await _leaveBottomSheet(context);

                setStateLeave = null;
              }
            }
          }

          locationSub();
        }
      }
    });
    // final themeState = Provider.of<CustomThemeProvider>;

    // var theme = CustomThemes.themeData(true, context);
    // ThemeSwitcher.of(context).changeTheme(theme: theme);
  }

  void _showLeaveButtonSheet() {
    _leaveBottomSheet(context);
  }

  void locationSub() {
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return;
    }

    try {
      const settings = LocationSettings(
        accuracy: LocationAccuracy.best,
        distanceFilter: 0,
      );

      locationSubscription =
          Geolocator.getPositionStream(locationSettings: settings)
              .listen((position) {
        setState(() {
          lat = position.latitude.toStringAsFixed(8);
          long = position.longitude.toStringAsFixed(8);

          var dist = Distance();
          if (lat0 != null && long0 != null) {
            setState(() {
              distance = dist(LatLng(lat0!, long0!),
                  LatLng(position.latitude, position.longitude));
            });
          }
        });
      });

      // locationSubscription.pause();
    } on Exception catch (e) {
      if (kDebugMode) {
        print('Failed to create location subscription: $e');
      }

      // awesomePopup(context, e.toString(), 'Vacation List Failed!', 'error').show();
    }
  }

  late AppLifecycleState _lastState;
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.resumed &&
        _lastState == AppLifecycleState.paused) {
      //now you know that your app went to the background and is back to the foreground
      // if (kDebugMode) {
      //   print('App in foreground');
      // }

      checkGps(
          NavigationService.instance.navigationKey!.currentContext!, false);
    }

    _lastState =
        state; //register the last state. When you get "paused" it means the app went to the background.
  }

  @override
  void dispose() {
    //don't forget to dispose of it when not needed anymore
    locationSubscription.cancel();
    dragController.dispose();
    dragControllerLeave.dispose();
    setStateVecation = null;
    setStateLeave = null;
    purposeController.dispose();
    remarksController.dispose();
    purposeFocus.dispose();
    fromHalfFocus.dispose();
    toHalfFocus.dispose();
    setStateAddLeave = null;

    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: true,
      child: Scaffold(
        body: ProgressHUD(
          indicatorColor: ColorConfig.lightMain,
          textStyle: TextStyle(color: ColorConfig.lightMain),
          barrierColor: ColorConfig.darkMain.withOpacity(0.6),
          // extendBodyBehindAppBar: false,
          // appBar: AppBar(
          //   backgroundColor: Colors.blue,
          //   elevation: 0,
          //   title: const Text('Messages Page'),
          // ),
          child: Builder(builder: (context) {
            return Form(
              key: globalFormKey,
              child: _attendanceUI(context),
            );
          }),
        ),
      ),
    );
  }

  Widget _attendanceUI(BuildContext context) {
    final themeState = Provider.of<CustomThemeProvider>(context);
    final loginProv = Provider.of<LoginProvider>(context, listen: true);

    return Stack(
      alignment: Alignment.topLeft,
      children: [
        HeaderWidget(),
        PageNameWidget(
          icon: Icons.calendar_month,
          name: 'Attendance',
          fontsize: 22,
          admin: admin,
          adminmode: adminmode,
          print: adminName == 'PINAK RANJAN SAHOO' ||
              adminName == 'PINAK SAHOO' ||
              adminName == 'DEBASHIS BISWAL',
          registered: registered,
          initialProcessed: initialProcess,
          onClickedLocation: () async {
            final provLogin =
                Provider.of<LoginProvider>(context, listen: false);
            //await Geolocator.openLocationSettings();
            permission = await Geolocator.requestPermission();

            if (permission == LocationPermission.denied) {
              provLogin.isLocationEnabled = false;
              if (kDebugMode) {
                print('Location permissions are denied');
              }
              awesomePopup(
                      context,
                      "Enable location service for ${Config.appName}.",
                      'Location Service Denied!',
                      'error')
                  .show();
            } else if (permission == LocationPermission.deniedForever) {
              provLogin.isLocationEnabled = false;
              if (kDebugMode) {
                print('Location permissions are permanently denied');
              }
              awesomePopup(
                      context,
                      "Enable location service for ${Config.appName}.",
                      'Location Service Denied!',
                      'error')
                  .show();
            } else {
              locationSub();
              provLogin.isLocationEnabled = true;
            }

            final snackBar = SnackBar(content: Text('Location: $permission'));
            ScaffoldMessenger.of(context)
              ..removeCurrentSnackBar()
              ..showSnackBar(snackBar);
          },
          onReload: () async {
            if (!ceo && admin) {
              setState(() {
                adminmode = false;
              });
            }
            final progress = ProgressHUD.of(context);

            progress?.show();
            String value = await checkip(context, deviceId, fcmToken);

            if (value == 'Unregistered') {
              //
            } else if (regmsg != null && regmsg != '') {
              awesomePopup(context, regmsg!, Config.appName,
                      regmsg!.contains('approval') ? 'info' : 'error')
                  .show();
            } else if (registered == true && value != 'Error') {
              initialRefresh = true;
              nottoscan = false;

              refreshController.requestRefresh();
            }

            progress?.dismiss();
          },
          onClick: () async {
            if (initialProcess == true && admin) {
              setState(() {
                adminmode = true;
              });

              initialRefresh = true;
              refreshController.requestRefresh();
            }
          },
          onPrint: () async {
            await Future.delayed(const Duration(milliseconds: 100), () {});
            final progress = ProgressHUD.of(context);

            progress?.show();

            bool status = await getQRCodePdf(context);

            progress?.dismiss();

            if (status == true) {
              await OpenFile.open(filePathQR);

              // Navigator.push(context, MaterialPageRoute(builder: (context) => QRCodePrintPage(filePathQR)));
            }
          },
          onLeave: () async {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => LeaveApprovalPage()));
          },
          onVacation: () async {
            await Future.delayed(const Duration(milliseconds: 100), () {});
            await _vecationBottomSheet(context);
            setStateVecation = null;
          },
          onSummary: () async {
            await Future.delayed(const Duration(milliseconds: 100), () {});
            await getAttendanceSummaryData(context);
          },
        ),
        Visibility(
          visible: registered && ceo,
          child: Positioned(
            left: 5,
            top: 5,
            child: Row(
              children: [
                Icon(
                  Icons.admin_panel_settings,
                  size: 16,
                  color: Colors.green.shade800,
                ),
                Text(
                  userdata.isEmpty || userdata[0].ADMINNAME == null
                      ? ''
                      : userdata[0].ADMINNAME ?? '',
                  textAlign: TextAlign.end,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    overflow: TextOverflow.ellipsis,
                    color: Colors.green.shade800,
                  ),
                ),
              ],
            ),
          ),
        ),
        Visibility(
          visible: registered,
          child: Positioned(
            right: 10,
            top: 5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.phone_android,
                      size: 14,
                      color: Colors.black,
                    ),
                    Text(
                      userdata.isEmpty
                          ? ''
                          : DateFormat('dd-MM-yyyy')
                              .format(userdata[0].DT_APPLICABLE),
                      textAlign: TextAlign.end,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        overflow: TextOverflow.ellipsis,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                Text(
                  version,
                  textAlign: TextAlign.end,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    overflow: TextOverflow.ellipsis,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ),
        Visibility(
          visible: registered && userdata.isNotEmpty,
          child: Padding(
            padding: EdgeInsets.only(
                top: MediaQuery.of(context).size.height / 9 + 40,
                left: 10,
                right: 10),
            child: SizedBox(
              // color: Colors.lightGreen,
              // height: 40,
              // width: MediaQuery.of(context).size.width,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Stack(
                      children: [
                        Visibility(
                          visible: !adminmode,
                          child: Transform(
                            alignment: Alignment.centerLeft,
                            transform: Matrix4.identity()..scale(0.7),
                            child: FilterChip(
                              elevation: 5,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              avatar: Icon(
                                userdata.isEmpty
                                    ? Icons.man
                                    : userdata[0].SEX
                                        ? Icons.woman
                                        : Icons.man,
                                color: Colors.white,
                              ),
                              label: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    userdata.isEmpty
                                        ? ''
                                        : '${userdata[0].EMP_NAME} [${userdata[0].EMP_CODE}]',
                                    textAlign: TextAlign.end,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Visibility(
                                      visible: half, child: SizedBox(width: 5)),
                                  Visibility(
                                    visible: half,
                                    child: CircleAvatar(
                                      radius: 12,
                                      backgroundColor:
                                          ColorConfig.dark.withOpacity(0.8),
                                      child: Text('0.5',
                                          style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.white)),
                                    ),
                                  ),
                                ],
                              ),
                              backgroundColor: Colors.green,
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                              onSelected: (value) {
                                // Navigator.pushNamedAndRemoveUntil(
                                //   context,
                                //   '/project',
                                //   (route) => false,
                                // );
                              },
                            ),
                          ),
                        ),
                        Visibility(
                          visible: adminmode,
                          child: SizedBox(
                            // color: Colors.greenAccent,
                            width: MediaQuery.of(context).size.width - 20,
                            height: 42,
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                SizedBox(
                                  width: 4,
                                ),
                                Expanded(
                                  flex: 2,
                                  child: GestureDetector(
                                    onTap: () async {
                                      DateTime? pickeddate =
                                          await showDatePicker(
                                        context: context,
                                        initialDate:
                                            selectedDate, // Refer step 1
                                        firstDate: DateTime(1900),
                                        lastDate: DateTime(2100),
                                        currentDate: DateTime.now(),
                                        // initialEntryMode: DatePickerEntryMode.input,
                                        builder: (BuildContext context,
                                            Widget? child) {
                                          return Theme(
                                            data: ThemeData.light().copyWith(
                                              colorScheme:
                                                  ColorScheme.fromSwatch(
                                                primarySwatch: Colors.teal,
                                                // primaryColorDark: Colors.teal,
                                                accentColor: Colors.teal,
                                              ),
                                              dialogBackgroundColor:
                                                  themeState.getDarkTheme
                                                      ? ColorConfig.light
                                                      : Colors.white,
                                            ),
                                            child: child!,
                                          );
                                        },
                                      );

                                      if (pickeddate != null) {
                                        if (pickeddate != selectedDate) {
                                          setState(() {
                                            selectedDate = pickeddate;
                                            initialRefresh = true;
                                            refreshController.requestRefresh();
                                          });
                                        }
                                      }
                                    },
                                    child: Stack(
                                      alignment: Alignment.topLeft,
                                      children: [
                                        SizedBox(
                                          // color: Colors.red,
                                          height: 35,
                                        ),
                                        Positioned(
                                          top: 5,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            mainAxisSize: MainAxisSize.max,
                                            children: [
                                              Icon(
                                                Icons.calendar_month,
                                                color: DateUtils.isSameDay(
                                                        DateTime.now(),
                                                        selectedDate)
                                                    ? themeState.getDarkTheme
                                                        ? ColorConfig.lightMain
                                                        : ColorConfig.darkMain
                                                    : Colors.blue,
                                              ),
                                              Text(
                                                DateUtils.isSameDay(
                                                        DateTime.now(),
                                                        selectedDate)
                                                    ? 'Today'
                                                    : DateFormat("dd-MMM-yyyy")
                                                        .format(selectedDate),
                                                textAlign: TextAlign.end,
                                                style: TextStyle(
                                                  color: DateUtils.isSameDay(
                                                          DateTime.now(),
                                                          selectedDate)
                                                      ? themeState.getDarkTheme
                                                          ? Colors.white
                                                          : Colors.black
                                                      : Colors.blue,
                                                  fontSize: DateUtils.isSameDay(
                                                          DateTime.now(),
                                                          selectedDate)
                                                      ? 15
                                                      : 12,
                                                  fontWeight: FontWeight.w500,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Positioned(
                                          top: 22,
                                          left: 22,
                                          // right: 15,
                                          child: Text(
                                            "(${DateFormat('EEEE').format(selectedDate)})",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              color: DateUtils.isSameDay(
                                                      DateTime.now(),
                                                      selectedDate)
                                                  ? themeState.getDarkTheme
                                                      ? Colors.white
                                                      : Colors.black
                                                  : Colors.blue,
                                              fontSize: 10,
                                              fontWeight: FontWeight.w500,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(width: 5),
                                Expanded(
                                  flex: 2,
                                  child: SelectionPopupV2(
                                    isDark: themeState.getDarkTheme,
                                    data: userdata.isEmpty
                                        ? const ['Category']
                                        : userdata[0].CATEGORIES.split(','),
                                    initValue: category,
                                    icon: Icons.group,
                                    initial: category == 'Category',
                                    textValueSetter: (value) => {
                                      setState(() {
                                        category = value;
                                        initialRefresh = true;
                                        refreshController.requestRefresh();
                                      })
                                    },
                                  ),
                                ),
                                SizedBox(width: 5),
                                Expanded(
                                  flex: 2,
                                  child: SelectionPopupV2(
                                    isDark: themeState.getDarkTheme,
                                    data: userdata.isEmpty
                                        ? const ['Section']
                                        : userdata[0].DEPARTMENTS.split(','),
                                    initValue: section,
                                    icon: Icons.computer_rounded,
                                    initial: section == 'Section',
                                    textValueSetter: (value) => {
                                      setState(() {
                                        section = value;
                                        initialRefresh = true;
                                        refreshController.requestRefresh();
                                      })
                                    },
                                  ),
                                ),
                                SizedBox(width: 10),
                                Expanded(
                                  flex: 1,
                                  child: Switch(
                                    key: UniqueKey(),
                                    autofocus: false,
                                    value: concise,
                                    // thumbColor: MaterialStateProperty.all(Color(0xFFC79822)),
                                    // trackColor: MaterialStateProperty.all(Color(0x667B5A07)),
                                    onChanged: (value) {
                                      Future.delayed(
                                        const Duration(milliseconds: 500),
                                        () async {
                                          setState(() {
                                            concise = value;
                                            initialRefresh = true;
                                            refreshController.requestRefresh();
                                          });
                                        },
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Visibility(
                          visible: lat != null && !adminmode,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: SizedBox(
                              width: MediaQuery.of(context).size.width - 20,
                              height: 25,
                              child: Align(
                                alignment: AlignmentDirectional.topEnd,
                                child: FilterChip(
                                  elevation: 5,
                                  labelPadding:
                                      EdgeInsets.only(top: -1, bottom: 0),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(6.0),
                                  ),
                                  avatar: Icon(
                                    Icons.location_pin,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                  padding: EdgeInsets.only(
                                      top: -4, left: -4, right: 4),
                                  label: Text(
                                    userdata.isEmpty ? '' : '$lat\n$long',
                                    textAlign: TextAlign.start,
                                    maxLines: 2,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 8,
                                      fontWeight: FontWeight.bold,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  backgroundColor:
                                      (distance ?? 0) <= (allowedDistance ?? 2)
                                          ? Colors.green
                                          : Colors.red,
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  onSelected: (value) {
                                    // Navigator.pushNamedAndRemoveUntil(
                                    //   context,
                                    //   '/project',
                                    //   (route) => false,
                                    // );
                                  },
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    // Flexible(fit: FlexFit.tight, child: SizedBox()),
                  ],
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(
              top: MediaQuery.of(context).size.height / 9 +
                  40 +
                  (adminmode ? 40 : 35),
              left: 10,
              right: 10), //, bottom: (loginProv.noInternet == true) ? 110 : 70
          child: Stack(
            children: [
              SmartRefresher(
                controller: refreshController,
                enablePullUp: true,
                header: ClassicHeader(
                  height: initialRefresh == true ? 0 : 60,
                  idleText: userEntryRefresh == true ? "" : "Pull to Refresh!",
                  refreshingIcon: const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      backgroundColor: Colors.white,
                      valueColor: AlwaysStoppedAnimation(Colors.blue),
                      strokeWidth: 2,
                    ),
                  ),
                ),
                footer: ClassicFooter(
                  loadStyle: LoadStyle.ShowWhenLoading,
                  // canLoadingText: "Can Load More",
                  // noDataText: "No more data to load",
                  // loadingText: "Loading Pinak...",
                  loadingIcon: const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      backgroundColor: Colors.white,
                      valueColor: AlwaysStoppedAnimation(Colors.blue),
                      strokeWidth: 2,
                    ),
                  ),
                  failedText: adminmode == false
                      ? currentPage > totalPages
                          ? "No more data to load"
                          : "Load failed!"
                      : currentPageEmpWise > totalPagesEmpWise
                          ? "No more data to load"
                          : "Load failed!",
                ),
                onRefresh: () async {
                  bool result = false;

                  if (adminmode == false) {
                    result = await getAttendanceData(context, isRefresh: true);
                  } else {
                    if (concise) {
                      result = await getAttendanceConciseData(context);
                    } else {
                      result = await getAttendanceEmpWiseData(context,
                          isRefresh: true);
                    }
                  }

                  if (result) {
                    refreshController.refreshCompleted();
                  } else {
                    refreshController.refreshFailed();
                  }

                  setState(() {
                    initialRefresh = false;
                  });
                },
                onLoading: () async {
                  bool result = false;

                  if (adminmode == false) {
                    result = await getAttendanceData(context);
                  } else {
                    if (concise) {
                      result = await getAttendanceConciseData(context);
                    } else {
                      result = await getAttendanceEmpWiseData(context);
                    }
                  }

                  if (result &&
                      ((adminmode == false && currentPage <= totalPages) ||
                          (adminmode == true &&
                              currentPageEmpWise <= totalPagesEmpWise))) {
                    refreshController.loadComplete();
                  } else {
                    refreshController.loadFailed();
                  }
                },
                child: adminmode == true
                    ? concise == true
                        ? _foundAttendanceConcise.isEmpty
                            ? Center(child: Text('No data found!'))
                            : attendanceConcise(themeState)
                        : _foundAttendanceEmpWise.isEmpty
                            ? Center(
                                child: Text(initialRefresh == true
                                    ? ''
                                    : 'No data found!'))
                            : attendanceDetailed(themeState)
                    : _foundAttendance.isEmpty
                        ? Center(
                            child: Text(
                                initialRefresh == true ? '' : 'No data found!'))
                        : attendanceEmployee(),
              ),
              Visibility(
                visible: initialRefresh,
                child: const Center(
                  child: CircularProgressIndicator(
                    backgroundColor: Colors.white,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                    strokeWidth: 4,
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.only(top: MediaQuery.of(context).size.height / 9),
          child: Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                Visibility(
                  visible: !registered,
                  child: SizedBox(
                    height: 275,
                    width: 400,
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Text(
                        regmsg ?? '',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 15,
                            overflow: TextOverflow.ellipsis,
                            color: blacklisted == true
                                ? Colors.red.shade800
                                : themeState.getDarkTheme
                                    ? ColorConfig.light
                                    : ColorConfig.dark),
                      ),
                    ),
                  ),
                ),
                Visibility(
                  visible: !registered,
                  child: Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      color: themeState.getDarkTheme
                          ? Colors.grey.shade500
                          : Colors.white,
                      borderRadius: const BorderRadius.all(
                        Radius.circular(100.0),
                      ),
                    ),
                    child: Center(
                      child: SizedBox(
                        width: 150,
                        height: 150,
                        child: Lottie.asset(
                          blacklisted == true
                              ? 'assets/jsons/error2.json'
                              : 'assets/jsons/pending.json',
                          repeat: false,
                          animate: true,
                          controller: _controller,
                          onLoaded: (compos) {
                            _controller.duration = compos.duration;
                            //Open another page after animation is done
                            // _controller.forward().then((value) {
                            //   _controller.reset();
                            //   _controller.forward().then((value) {
                            //     Navigator.push(context, MaterialPageRoute(builder: (context) => _defaultHome));
                            //   });
                            // });
                            _controller.forward();
                            _controller.repeat();
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Visibility(
          visible: loginProv.isLocationEnabled && registered && !adminmode,
          child: Positioned(
            bottom: (loginProv.noInternet == true) ? 50 : 10,
            left: 0,
            right: 0,
            child: FloatingActionButton(
              key: const Key('Leave'),
              backgroundColor: Colors.amber.shade900,
              heroTag: Key('Leave'),
              onPressed: () async {
                await Future.delayed(const Duration(milliseconds: 100), () {});
                await _leaveBottomSheet(context);

                setStateLeave = null;
              },
              child: const FaIcon(FontAwesomeIcons.personWalkingLuggage,
                  color: Colors.white),
            ),
          ),
        ),
        Visibility(
          visible: loginProv.isLocationEnabled &&
              registered &&
              distance != null &&
              !ceo &&
              !adminmode,
          child: Positioned(
            bottom: (loginProv.noInternet == true) ? 50 : 10,
            left: 20,
            // right: 0,
            child: FloatingActionButton(
              key: const Key('Scan'),
              backgroundColor: Colors.green.shade700,
              heroTag: Key('Scan'),
              onPressed: () {
                if (nottoscan == true) {
                  awesomePopup(context, 'Invalid User Selected!',
                          Config.appName, 'error')
                      .show();
                } else {
                  scanQR();
                }
              },
              child: const Icon(Icons.qr_code, color: Colors.white),
            ),
          ),
        ),
        Positioned(
          bottom: (loginProv.noInternet == true) ? 50 : 10,
          // left: 0,
          right: 20,
          child: FloatingActionButton(
            key: const Key('Close'),
            heroTag: Key('Close'),
            onPressed: () {
              awesomePopup(
                      context,
                      'Are you sure you want to close the application?',
                      Config.appName,
                      'question')
                  .show();
            },
            child: const Icon(Icons.close, color: Colors.white),
          ),
        ),
      ],
    );
  }

  SlidableAutoCloseBehavior attendanceEmployee() {
    return SlidableAutoCloseBehavior(
      child: ListView.separated(
        key: const Key('Lst1'),
        itemCount: _foundAttendance.length,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        scrollDirection: Axis.vertical,
        // physics: const NeverScrollableScrollPhysics(),
        // padding: EdgeInsets.all(2),
        itemBuilder: (context, index) {
          final attn = _foundAttendance[index];
          cardKeyList.add(GlobalKey(debugLabel: attn.RECORD_ID.toString()));

          return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(7),
            ),
            color: Colors.white,
            elevation: 5,
            child: Stack(
              children: [
                Visibility(
                  visible: attn.HOLIDAY != null,
                  child: Padding(
                    padding: const EdgeInsets.only(
                      left: 20,
                      right: 16,
                    ),
                    child: ClipRRect(
                      // borderRadius: BorderRadius.circular(7.0),
                      child: Image.asset(
                        "assets/images/holidays/${attn.HOLIDAY == 'GANDHI JAYANTI' ? 'Gandhi_Jayanti.png' : attn.HOLIDAY == 'ASHTAMI' || attn.HOLIDAY == 'NAVAMI' || attn.HOLIDAY == 'VIJAYA DASHAMI' ? 'Durga_Puja.png' : attn.HOLIDAY == 'VISHWAKARMA PUJA' ? 'Viswakarma_Puja.png' : attn.HOLIDAY == 'DIWALI' ? 'Diwali.png' : attn.HOLIDAY == 'REPUBLIC DAY' ? 'Republic_Day.png' : attn.HOLIDAY == 'INDEPENDENCE DAY' ? 'Independence_Day.png' : attn.HOLIDAY == 'RATH YATRA' ? 'Ratha_Yatra.png' : attn.HOLIDAY == 'HOLI' ? 'Holi.png' : 'Holiday.png'}",
                        height: 56,
                        fit: BoxFit.fill,
                      ),
                    ),
                  ),
                ),
                ListTile(
                  key: cardKeyList[index], //attention
                  contentPadding: const EdgeInsets.only(
                    left: 0,
                    right: 0,
                  ),
                  isThreeLine: false,
                  horizontalTitleGap: 0,
                  minLeadingWidth: 0,
                  // dense: true,
                  leading: Container(
                    decoration: BoxDecoration(
                      color: attn.DT_DATE.weekday == 7
                          ? Colors.amber.shade800
                          : Colors.blue,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(7),
                        bottomLeft: Radius.circular(7),
                      ),
                    ),
                    height: double.infinity,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        CircleAvatar(
                          maxRadius: 8,
                          backgroundColor: Colors.white,
                          child: Text(
                            DateFormat("dd").format(attn.DT_DATE),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        RotatedBox(
                          quarterTurns: 3,
                          child: Text(
                            DateFormat("EEE").format(attn.DT_DATE),
                            maxLines: 1,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              overflow: TextOverflow.ellipsis,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  title: Container(
                    // color: Colors.lightGreen,
                    height: 50,
                    width: double.maxFinite,
                    padding: EdgeInsets.only(
                      left: 13,
                    ),
                    child: attn.HOLIDAY == null
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.max,
                                children: <Widget>[
                                  attn.DETAILS2.split(',')[0] == '-'
                                      ? attn.LEAVE == 'FIRST HALF'
                                          ? Expanded(
                                              flex: 3,
                                              child: Divider(
                                                  thickness: 1,
                                                  height: 0.5,
                                                  color: Colors.grey))
                                          : ScanTime(
                                              dayName: attn.DAY_NAME,
                                              label: 'Start',
                                              value: ' Missing!',
                                              leave: attn.LEAVE,
                                              leavestatus: attn.LEAVE_STATUS,
                                              showDelay: showDelay,
                                              onClick: () {
                                                getPunchData(
                                                    context,
                                                    attn.DT_DATE,
                                                    attn.SCANS,
                                                    userdata[0].EMP_ID,
                                                    userdata[0].EMP_NAME);
                                              },
                                            )
                                      : ScanTime(
                                          dayName: attn.DAY_NAME,
                                          label: 'Start',
                                          value: attn.DETAILS2
                                              .split(',')[0]
                                              .split('~')[0],
                                          deviation: attn.DETAILS2
                                              .split(',')[0]
                                              .split('~')[2],
                                          late: attn.DETAILS2
                                                  .split(',')[0]
                                                  .split('~')[3] ==
                                              'True',
                                          lunchdelay: attn.LUNCHDELAY,
                                          leave: attn.LEAVE,
                                          leavestatus: attn.LEAVE_STATUS,
                                          time: true,
                                          showDelay: showDelay,
                                          onClick: () {
                                            getPunchData(
                                                context,
                                                attn.DT_DATE,
                                                attn.SCANS,
                                                userdata[0].EMP_ID,
                                                userdata[0].EMP_NAME);
                                          },
                                        ),
                                  Expanded(
                                      flex: 1,
                                      child: Divider(
                                          thickness: 1,
                                          height: 0.5,
                                          color: Colors.grey)),
                                  attn.DETAILS2.split(',')[1] == '-'
                                      ? attn.LEAVE == 'FIRST HALF'
                                          ? Expanded(
                                              flex: 3,
                                              child: Divider(
                                                  thickness: 1,
                                                  height: 0.5,
                                                  color: Colors.grey))
                                          : ScanTime(
                                              dayName: attn.DAY_NAME,
                                              label: 'Lunch Out',
                                              value: ' Missing!',
                                              leave: attn.LEAVE,
                                              leavestatus: attn.LEAVE_STATUS,
                                              showDelay: showDelay,
                                              onClick: () {
                                                getPunchData(
                                                    context,
                                                    attn.DT_DATE,
                                                    attn.SCANS,
                                                    userdata[0].EMP_ID,
                                                    userdata[0].EMP_NAME);
                                              },
                                            )
                                      : ScanTime(
                                          dayName: attn.DAY_NAME,
                                          label: 'Lunch Out',
                                          value: attn.DETAILS2
                                              .split(',')[1]
                                              .split('~')[0],
                                          deviation: attn.DETAILS2
                                              .split(',')[1]
                                              .split('~')[2],
                                          late: attn.DETAILS2
                                                  .split(',')[1]
                                                  .split('~')[3] ==
                                              'True',
                                          lunchdelay: attn.LUNCHDELAY,
                                          leave: attn.LEAVE,
                                          leavestatus: attn.LEAVE_STATUS,
                                          time: true,
                                          showDelay: showDelay,
                                          onClick: () {
                                            getPunchData(
                                                context,
                                                attn.DT_DATE,
                                                attn.SCANS,
                                                userdata[0].EMP_ID,
                                                userdata[0].EMP_NAME);
                                          },
                                        ),
                                  Expanded(
                                      flex: 1,
                                      child: Divider(
                                          thickness: 1,
                                          height: 0.5,
                                          color: Colors.grey)),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                        width: 35,
                                        height: 12,
                                        child: FilterChip(
                                          elevation: 0,
                                          // padding: EdgeInsets.all(2),
                                          labelPadding:
                                              EdgeInsets.only(top: -11.5),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(4)),
                                            side: BorderSide(
                                              color: (attn.DAY_NAME == 'Sunday' ||
                                                      attn.WORKTIME == null ||
                                                      showLunch == false)
                                                  ? Colors.white
                                                  : attn.DAY_NAME ==
                                                              'Saturday' &&
                                                          attn.WORKTIME == null
                                                      ? Colors.white
                                                      : attn.DAY_NAME !=
                                                                  'Saturday' &&
                                                              attn.DETAILS2.split(',')[1].split(
                                                                      '~')[0] ==
                                                                  '-'
                                                          ? Colors.white
                                                          : (attn.LEAVE != null &&
                                                                      int.parse(attn.WORKTIME!.split(':')[0]) >=
                                                                          4) ||
                                                                  int.parse(attn
                                                                          .WORKTIME!
                                                                          .split(':')[0]) >=
                                                                      8
                                                              ? Colors.green
                                                              : Colors.red,
                                            ),
                                          ),
                                          // visualDensity: VisualDensity.compact,
                                          label: Text(
                                            attn.WORKTIME ?? '88:88',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 8,
                                              fontWeight: FontWeight.normal,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          backgroundColor: (attn.DAY_NAME ==
                                                      'Sunday' ||
                                                  attn.WORKTIME == null ||
                                                  showLunch == false)
                                              ? Colors.white
                                              : attn.DAY_NAME == 'Saturday' &&
                                                      attn.WORKTIME == null
                                                  ? Colors.white
                                                  : attn.DAY_NAME !=
                                                              'Saturday' &&
                                                          attn.DETAILS2
                                                                  .split(',')[1]
                                                                  .split(
                                                                      '~')[0] ==
                                                              '-'
                                                      ? Colors.white
                                                      : (attn.LEAVE != null &&
                                                                  int.parse(attn.WORKTIME!.split(':')[0]) >=
                                                                      4) ||
                                                              int.parse(attn
                                                                      .WORKTIME!
                                                                      .split(':')[0]) >=
                                                                  8
                                                          ? Colors.green
                                                          : Colors.red,
                                          materialTapTargetSize:
                                              MaterialTapTargetSize.shrinkWrap,
                                          onSelected: (value) {
                                            getPunchData(
                                                context,
                                                attn.DT_DATE,
                                                attn.SCANS,
                                                userdata[0].EMP_ID,
                                                userdata[0].EMP_NAME);
                                          },
                                        ),
                                      ),
                                      SizedBox(
                                        height: 1,
                                      ),
                                      CircleAvatar(
                                        maxRadius: 10,
                                        backgroundColor: attn.STATUS == 'A'
                                            ? Colors.red
                                            : ColorConfig.dark.withOpacity(0.8),
                                        child: CircleAvatar(
                                          maxRadius: 9,
                                          backgroundColor: attn.STATUS == 'A'
                                              ? Colors.red
                                              : attn.LEAVE_PURPOSE != null
                                                  ? attn.LEAVE_STATUS ==
                                                          'APPROVED'
                                                      ? Colors.green
                                                      : Colors.amber.shade900
                                                  : attn.STATUS == null
                                                      ? Colors.white
                                                      : ColorConfig.dark
                                                          .withOpacity(0.8),
                                          child: attn.LEAVE_PURPOSE != null
                                              ? FaIcon(
                                                  FontAwesomeIcons
                                                      .personWalkingLuggage,
                                                  color: Colors.white,
                                                  size: 12,
                                                )
                                              : Text(
                                                  attn.STATUS ?? '',
                                                  style: TextStyle(
                                                    fontSize: 8,
                                                    fontWeight: FontWeight.w700,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 1,
                                      ),
                                      SizedBox(
                                        width: 35,
                                        height: 12,
                                        child: FilterChip(
                                          elevation: 0,
                                          // padding: EdgeInsets.all(2),
                                          labelPadding:
                                              EdgeInsets.only(top: -11.5),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(4)),
                                            side: BorderSide(
                                              color: (attn.DAY_NAME ==
                                                          'Saturday' ||
                                                      attn.DAY_NAME ==
                                                          'Sunday' ||
                                                      attn.LUNCHTIME == null ||
                                                      showLunch == false)
                                                  ? Colors.white
                                                  : attn.LUNCHTIME != null
                                                      ? attn.LUNCHDELAY == true
                                                          ? Colors.red
                                                          : Colors.green
                                                      : ColorConfig.dark
                                                          .withOpacity(0.2),
                                            ),
                                          ),
                                          // visualDensity: VisualDensity.compact,
                                          label: (attn.DAY_NAME == 'Sunday' ||
                                                      attn.LEAVE ==
                                                          'FULL DAY' ||
                                                      attn.HOLIDAY != null) &&
                                                  (attn.SCANS ?? 0) > 0
                                              ? Icon(
                                                  Icons.qr_code,
                                                  size: 12,
                                                  color: Colors.black,
                                                )
                                              : Text(
                                                  attn.LUNCHTIME ?? '88:88',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 8,
                                                    fontWeight:
                                                        FontWeight.normal,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                          backgroundColor: (attn.DAY_NAME ==
                                                      'Saturday' ||
                                                  attn.DAY_NAME == 'Sunday' ||
                                                  attn.LUNCHTIME == null ||
                                                  showLunch == false)
                                              ? Colors.white
                                              : attn.LUNCHTIME != null
                                                  ? attn.LUNCHDELAY == true
                                                      ? Colors.red
                                                      : Colors.green
                                                  : ColorConfig.dark
                                                      .withOpacity(0.8),
                                          materialTapTargetSize:
                                              MaterialTapTargetSize.shrinkWrap,
                                          onSelected: (value) {
                                            getPunchData(
                                                context,
                                                attn.DT_DATE,
                                                attn.SCANS,
                                                userdata[0].EMP_ID,
                                                userdata[0].EMP_NAME);
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                  Expanded(
                                      flex: 1,
                                      child: Divider(
                                          thickness: 1,
                                          height: 0.5,
                                          color: Colors.grey)),
                                  attn.DETAILS2.split(',')[2] == '-'
                                      ? attn.LEAVE == 'SECOND HALF'
                                          ? Expanded(
                                              flex: 3,
                                              child: Divider(
                                                  thickness: 1,
                                                  height: 0.5,
                                                  color: Colors.grey))
                                          : ScanTime(
                                              dayName: attn.DAY_NAME,
                                              label: 'Lunch In',
                                              value: ' Missing!',
                                              leave: attn.LEAVE,
                                              leavestatus: attn.LEAVE_STATUS,
                                              showDelay: showDelay,
                                              onClick: () {
                                                getPunchData(
                                                    context,
                                                    attn.DT_DATE,
                                                    attn.SCANS,
                                                    userdata[0].EMP_ID,
                                                    userdata[0].EMP_NAME);
                                              },
                                            )
                                      : ScanTime(
                                          dayName: attn.DAY_NAME,
                                          label: 'Lunch In',
                                          value: attn.DETAILS2
                                              .split(',')[2]
                                              .split('~')[0],
                                          deviation: attn.DETAILS2
                                              .split(',')[2]
                                              .split('~')[2],
                                          late: attn.DETAILS2
                                                  .split(',')[2]
                                                  .split('~')[3] ==
                                              'True',
                                          lunchdelay: attn.LUNCHDELAY,
                                          leave: attn.LEAVE,
                                          leavestatus: attn.LEAVE_STATUS,
                                          time: true,
                                          showDelay: showDelay,
                                          onClick: () {
                                            getPunchData(
                                                context,
                                                attn.DT_DATE,
                                                attn.SCANS,
                                                userdata[0].EMP_ID,
                                                userdata[0].EMP_NAME);
                                          },
                                        ),
                                  Expanded(
                                      flex: 1,
                                      child: Divider(
                                          thickness: 1,
                                          height: 0.5,
                                          color: Colors.grey)),
                                  attn.DETAILS2.split(',')[3] == '-'
                                      ? attn.LEAVE == 'SECOND HALF'
                                          ? Expanded(
                                              flex: 3,
                                              child: Divider(
                                                  thickness: 1,
                                                  height: 0.5,
                                                  color: Colors.grey))
                                          : ScanTime(
                                              dayName: attn.DAY_NAME,
                                              label: 'End',
                                              value: ' Missing!',
                                              leave: attn.LEAVE,
                                              leavestatus: attn.LEAVE_STATUS,
                                              showDelay: showDelay,
                                              onClick: () {
                                                getPunchData(
                                                    context,
                                                    attn.DT_DATE,
                                                    attn.SCANS,
                                                    userdata[0].EMP_ID,
                                                    userdata[0].EMP_NAME);
                                              },
                                            )
                                      : ScanTime(
                                          dayName: attn.DAY_NAME,
                                          label: 'End',
                                          value: attn.DETAILS2
                                              .split(',')[3]
                                              .split('~')[0],
                                          deviation: attn.DETAILS2
                                              .split(',')[3]
                                              .split('~')[2],
                                          late: attn.DETAILS2
                                                  .split(',')[3]
                                                  .split('~')[3] ==
                                              'True',
                                          lunchdelay: attn.LUNCHDELAY,
                                          leave: attn.LEAVE,
                                          leavestatus: attn.LEAVE_STATUS,
                                          time: true,
                                          showDelay: showDelay,
                                          onClick: () {
                                            getPunchData(
                                                context,
                                                attn.DT_DATE,
                                                attn.SCANS,
                                                userdata[0].EMP_ID,
                                                userdata[0].EMP_NAME);
                                          },
                                        ),
                                ],
                              ),
                              // Text(
                              //   attn.DETAILS ?? 'Absent',
                              //   maxLines: 1,
                              //   overflow: TextOverflow.ellipsis,
                              //   style: TextStyle(color: ColorConfig.dark),
                              // ),
                            ],
                          )
                        : (attn.SCANS ?? 0) > 0
                            ? Icon(
                                Icons.qr_code,
                                size: 18,
                                color: Colors.black,
                              )
                            : null,
                  ),
                  trailing: Container(
                    decoration: BoxDecoration(
                        color: Colors.grey,
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(7),
                          bottomRight: Radius.circular(7),
                        )),
                    height: double.infinity,
                    width: 18,
                    child: RotatedBox(
                      quarterTurns: 3,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Text(
                            DateFormat("MMM").format(attn.DT_DATE),
                            maxLines: 1,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.normal,
                              overflow: TextOverflow.ellipsis,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            DateFormat("yyyy").format(attn.DT_DATE),
                            maxLines: 1,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 8,
                              fontWeight: FontWeight.normal,
                              overflow: TextOverflow.ellipsis,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  onTap: () {
                    getPunchData(context, attn.DT_DATE, attn.SCANS,
                        userdata[0].EMP_ID, userdata[0].EMP_NAME);
                  },
                ),
                Visibility(
                  visible: attn.HOLIDAY != null,
                  child: Padding(
                    padding: const EdgeInsets.only(
                      right: 17,
                      top: 1,
                    ),
                    child: Align(
                      alignment: Alignment.topRight,
                      child: SizedBox(
                        height: 20,
                        child: FilterChip(
                          elevation: 1,
                          // labelPadding: EdgeInsets.all(0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(7),
                            ),
                          ),
                          // avatar: Icon(
                          //   Icons.holiday_village,
                          //   color: Colors.white,
                          //   size: 18,
                          // ),
                          padding: EdgeInsets.only(
                            top: -8,
                          ),
                          visualDensity: VisualDensity.compact,
                          label: Text(
                            attn.HOLIDAY ?? '',
                            textAlign: TextAlign.start,
                            maxLines: 1,
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          // backgroundColor: Colors.transparent,
                          backgroundColor: attn.NATIONAL_HOLIDAY == true
                              ? Colors.amber.shade800
                              : Colors.cyan.shade400,
                          // materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          onSelected: (value) {},
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
        separatorBuilder: (context, index) => const Divider(
          height: 0,
        ),
      ),
    );
  }

  SlidableAutoCloseBehavior attendanceDetailed(CustomThemeProvider themeState) {
    return SlidableAutoCloseBehavior(
      child: ListView.separated(
        key: const Key('Lst2'),
        itemCount: _foundAttendanceEmpWise.length,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        scrollDirection: Axis.vertical,
        // physics: const NeverScrollableScrollPhysics(),
        // padding: EdgeInsets.all(2),
        itemBuilder: (context, index) {
          final attn = _foundAttendanceEmpWise[index];
          cardKeyListEmpWise
              .add(GlobalKey(debugLabel: attn.RECORD_ID.toString()));

          return Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.topLeft,
            children: <Widget>[
              // Container(
              //   color: Colors.greenAccent,
              //   // height: 80,
              // ),
              SizedBox(
                height: 25,
                child: Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: FilterChip(
                    elevation: 1,
                    labelPadding: const EdgeInsets.only(top: -6),
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(4)),
                    ),
                    visualDensity: VisualDensity.compact,
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          attn.SEX == null
                              ? Icons.man
                              : attn.SEX == true
                                  ? Icons.woman
                                  : Icons.man,
                          color: themeState.getDarkTheme
                              ? Colors.black
                              : Colors.white,
                          size: 16,
                        ),
                        Text(
                          attn.EMP_NAME ?? '',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: themeState.getDarkTheme
                                ? Colors.black
                                : Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.normal,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    backgroundColor: themeState.getDarkTheme
                        ? Colors.white
                        : ColorConfig.dark.withOpacity(0.7),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    onSelected: (value) {
                      setState(() {
                        adminmode = false;
                        userdata[0].EMP_NAME = attn.EMP_NAME;
                        userdata[0].EMP_CODE = attn.EMP_CODE;
                        userdata[0].EMP_ID = attn.RECORD_ID;
                        half = attn.HALF;
                        nottoscan = true;

                        refreshController.requestRefresh();
                      });
                    },
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 15),
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(7),
                  ),
                  color: Colors.white,
                  elevation: 5,
                  child: Stack(
                    children: [
                      ListTile(
                        key: cardKeyListEmpWise[index], //attention
                        contentPadding: const EdgeInsets.only(
                          left: 0,
                          right: 0,
                        ),
                        // isThreeLine: true,
                        horizontalTitleGap: 0,
                        // minVerticalPadding: 5,
                        minLeadingWidth: 0,
                        // dense: true,
                        leading: GestureDetector(
                          child: Container(
                            decoration: BoxDecoration(
                              color: attn.DEPARTMENT == 'Desktop'
                                  ? Colors.blue
                                  : attn.DEPARTMENT == 'Web'
                                      ? Colors.green
                                      : attn.DEPARTMENT == 'Designer'
                                          ? Colors.pink
                                          : attn.DEPARTMENT == 'Office'
                                              ? Colors.indigoAccent
                                              : Colors.cyan,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(7),
                                bottomLeft: Radius.circular(7),
                              ),
                            ),
                            height: double.infinity,
                            width: 19,
                            padding: EdgeInsets.only(left: 2),
                            child: SizedBox(
                              height: 55,
                              child: RotatedBox(
                                quarterTurns: 3,
                                child: AutoSizeText(
                                  attn.DEPARTMENT ?? '',
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  textAlign: TextAlign.center,
                                  minFontSize: 10,
                                  maxFontSize: 12,
                                  stepGranularity: 1,
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          onTap: () {
                            //
                          },
                        ),
                        title: Container(
                          // color: Colors.lightGreen,
                          height: 50,
                          width: double.maxFinite,
                          padding: EdgeInsets.only(
                            left: 13,
                          ),
                          child: attn.HOLIDAY == null
                              ? Row(
                                  mainAxisSize: MainAxisSize.max,
                                  children: <Widget>[
                                    attn.DETAILS2.split(',')[0] == '-'
                                        ? attn.LEAVE == 'FIRST HALF'
                                            ? Expanded(
                                                flex: 3,
                                                child: Divider(
                                                    thickness: 1,
                                                    height: 0.5,
                                                    color: Colors.grey))
                                            : ScanTime(
                                                dayName: attn.DAY_NAME,
                                                label: 'Start',
                                                value: ' Missing!',
                                                leave: attn.LEAVE,
                                                leavestatus: attn.LEAVE_STATUS,
                                                showDelay: showDelay,
                                                adminmode: adminmode,
                                                onClick: () {
                                                  getPunchData(
                                                      context,
                                                      attn.DT_DATE,
                                                      attn.SCANS,
                                                      attn.RECORD_ID,
                                                      attn.EMP_NAME);
                                                },
                                              )
                                        : ScanTime(
                                            dayName: attn.DAY_NAME,
                                            label: 'Start',
                                            value: attn.DETAILS2
                                                .split(',')[0]
                                                .split('~')[0],
                                            deviation: attn.DETAILS2
                                                .split(',')[0]
                                                .split('~')[2],
                                            late: attn.DETAILS2
                                                    .split(',')[0]
                                                    .split('~')[3] ==
                                                'True',
                                            lunchdelay: attn.LUNCHDELAY,
                                            leave: attn.LEAVE,
                                            leavestatus: attn.LEAVE_STATUS,
                                            time: true,
                                            showDelay: showDelay,
                                            adminmode: adminmode,
                                            onClick: () {
                                              getPunchData(
                                                  context,
                                                  attn.DT_DATE,
                                                  attn.SCANS,
                                                  attn.RECORD_ID,
                                                  attn.EMP_NAME);
                                            },
                                          ),
                                    Expanded(
                                        flex: 1,
                                        child: Divider(
                                            thickness: 1,
                                            height: 0.5,
                                            color: Colors.grey)),
                                    attn.DETAILS2.split(',')[1] == '-'
                                        ? attn.LEAVE == 'FIRST HALF'
                                            ? Expanded(
                                                flex: 3,
                                                child: Divider(
                                                    thickness: 1,
                                                    height: 0.5,
                                                    color: Colors.grey))
                                            : ScanTime(
                                                dayName: attn.DAY_NAME,
                                                label: 'Lunch Out',
                                                value: ' Missing!',
                                                leave: attn.LEAVE,
                                                leavestatus: attn.LEAVE_STATUS,
                                                showDelay: showDelay,
                                                adminmode: adminmode,
                                                onClick: () {
                                                  getPunchData(
                                                      context,
                                                      attn.DT_DATE,
                                                      attn.SCANS,
                                                      attn.RECORD_ID,
                                                      attn.EMP_NAME);
                                                },
                                              )
                                        : ScanTime(
                                            dayName: attn.DAY_NAME,
                                            label: 'Lunch Out',
                                            value: attn.DETAILS2
                                                .split(',')[1]
                                                .split('~')[0],
                                            deviation: attn.DETAILS2
                                                .split(',')[1]
                                                .split('~')[2],
                                            late: attn.DETAILS2
                                                    .split(',')[1]
                                                    .split('~')[3] ==
                                                'True',
                                            lunchdelay: attn.LUNCHDELAY,
                                            leave: attn.LEAVE,
                                            leavestatus: attn.LEAVE_STATUS,
                                            time: true,
                                            showDelay: showDelay,
                                            adminmode: adminmode,
                                            onClick: () {
                                              getPunchData(
                                                  context,
                                                  attn.DT_DATE,
                                                  attn.SCANS,
                                                  attn.RECORD_ID,
                                                  attn.EMP_NAME);
                                            },
                                          ),
                                    Expanded(
                                        flex: 1,
                                        child: Divider(
                                            thickness: 1,
                                            height: 0.5,
                                            color: Colors.grey)),
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        SizedBox(
                                          width: 35,
                                          height: 12,
                                          child: FilterChip(
                                            elevation: 0,
                                            // padding: EdgeInsets.all(2),
                                            labelPadding:
                                                EdgeInsets.only(top: -11.5),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(4)),
                                              side: BorderSide(
                                                color: (attn.DAY_NAME ==
                                                            'Sunday' ||
                                                        attn.WORKTIME == null ||
                                                        showLunch == false)
                                                    ? Colors.white
                                                    : attn.DAY_NAME ==
                                                                'Saturday' &&
                                                            attn.WORKTIME ==
                                                                null
                                                        ? Colors.white
                                                        : attn.DAY_NAME !=
                                                                    'Saturday' &&
                                                                attn.DETAILS2.split(',')[1].split(
                                                                            '~')[
                                                                        0] ==
                                                                    '-'
                                                            ? Colors.white
                                                            : (attn.LEAVE != null &&
                                                                        int.parse(attn.WORKTIME!.split(':')[0]) >=
                                                                            4) ||
                                                                    int.parse(attn.WORKTIME!.split(':')[0]) >=
                                                                        8
                                                                ? Colors.green
                                                                : Colors.red,
                                              ),
                                            ),
                                            // visualDensity: VisualDensity.compact,
                                            label: Text(
                                              attn.WORKTIME ?? '88:88',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 8,
                                                fontWeight: FontWeight.normal,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            backgroundColor: (attn.DAY_NAME ==
                                                        'Sunday' ||
                                                    attn.WORKTIME == null ||
                                                    showLunch == false)
                                                ? Colors.white
                                                : attn.DAY_NAME == 'Saturday' &&
                                                        attn.WORKTIME == null
                                                    ? Colors.white
                                                    : attn.DAY_NAME !=
                                                                'Saturday' &&
                                                            attn.DETAILS2.split(',')[1].split(
                                                                    '~')[0] ==
                                                                '-'
                                                        ? Colors.white
                                                        : (attn.LEAVE != null &&
                                                                    int.parse(attn.WORKTIME!.split(':')[0]) >=
                                                                        4) ||
                                                                int.parse(attn
                                                                        .WORKTIME!
                                                                        .split(':')[0]) >=
                                                                    8
                                                            ? Colors.green
                                                            : Colors.red,
                                            materialTapTargetSize:
                                                MaterialTapTargetSize
                                                    .shrinkWrap,
                                            onSelected: (value) {
                                              getPunchData(
                                                  context,
                                                  attn.DT_DATE,
                                                  attn.SCANS,
                                                  attn.RECORD_ID,
                                                  attn.EMP_NAME);
                                            },
                                          ),
                                        ),
                                        SizedBox(
                                          height: 1,
                                        ),
                                        CircleAvatar(
                                          maxRadius: 10,
                                          backgroundColor: attn.STATUS == 'A'
                                              ? Colors.red
                                              : ColorConfig.dark
                                                  .withOpacity(0.8),
                                          child: CircleAvatar(
                                            maxRadius: 9,
                                            backgroundColor: attn.STATUS == 'A'
                                                ? Colors.red
                                                : attn.LEAVE_PURPOSE != null
                                                    ? attn.LEAVE_STATUS ==
                                                            'APPROVED'
                                                        ? Colors.green
                                                        : Colors.amber.shade900
                                                    : attn.STATUS == null
                                                        ? Colors.white
                                                        : ColorConfig.dark
                                                            .withOpacity(0.8),
                                            child: attn.LEAVE_PURPOSE != null
                                                ? FaIcon(
                                                    FontAwesomeIcons
                                                        .personWalkingLuggage,
                                                    color: Colors.white,
                                                    size: 12,
                                                  )
                                                : Text(
                                                    attn.STATUS ?? '',
                                                    style: TextStyle(
                                                      fontSize: 8,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                          ),
                                        ),
                                        SizedBox(
                                          height: 1,
                                        ),
                                        SizedBox(
                                          width: 35,
                                          height: 12,
                                          child: FilterChip(
                                            elevation: 0,
                                            // padding: EdgeInsets.all(2),
                                            labelPadding:
                                                EdgeInsets.only(top: -11.5),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(4)),
                                              side: BorderSide(
                                                color: (attn.DAY_NAME ==
                                                            'Saturday' ||
                                                        attn.DAY_NAME ==
                                                            'Sunday' ||
                                                        attn.LUNCHTIME ==
                                                            null ||
                                                        showLunch == false)
                                                    ? Colors.white
                                                    : attn.LUNCHTIME != null
                                                        ? attn.LUNCHDELAY ==
                                                                true
                                                            ? Colors.red
                                                            : Colors.green
                                                        : ColorConfig.dark
                                                            .withOpacity(0.2),
                                              ),
                                            ),
                                            // visualDensity: VisualDensity.compact,
                                            label: (attn.DAY_NAME == 'Sunday' ||
                                                        attn.LEAVE ==
                                                            'FULL DAY' ||
                                                        attn.HOLIDAY != null) &&
                                                    (attn.SCANS ?? 0) > 0
                                                ? Icon(
                                                    Icons.qr_code,
                                                    size: 12,
                                                    color: Colors.black,
                                                  )
                                                : Text(
                                                    attn.LUNCHTIME ?? '88:88',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 8,
                                                      fontWeight:
                                                          FontWeight.normal,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                            backgroundColor: (attn.DAY_NAME ==
                                                        'Saturday' ||
                                                    attn.DAY_NAME == 'Sunday' ||
                                                    attn.LUNCHTIME == null ||
                                                    showLunch == false)
                                                ? Colors.white
                                                : attn.LUNCHTIME != null
                                                    ? attn.LUNCHDELAY == true
                                                        ? Colors.red
                                                        : Colors.green
                                                    : ColorConfig.dark
                                                        .withOpacity(0.8),
                                            materialTapTargetSize:
                                                MaterialTapTargetSize
                                                    .shrinkWrap,
                                            onSelected: (value) {
                                              getPunchData(
                                                  context,
                                                  attn.DT_DATE,
                                                  attn.SCANS,
                                                  attn.RECORD_ID,
                                                  attn.EMP_NAME);
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                    Expanded(
                                        flex: 1,
                                        child: Divider(
                                            thickness: 1,
                                            height: 0.5,
                                            color: Colors.grey)),
                                    attn.DETAILS2.split(',')[2] == '-'
                                        ? attn.LEAVE == 'SECOND HALF'
                                            ? Expanded(
                                                flex: 3,
                                                child: Divider(
                                                    thickness: 1,
                                                    height: 0.5,
                                                    color: Colors.grey))
                                            : ScanTime(
                                                dayName: attn.DAY_NAME,
                                                label: 'Lunch In',
                                                value: ' Missing!',
                                                leave: attn.LEAVE,
                                                leavestatus: attn.LEAVE_STATUS,
                                                showDelay: showDelay,
                                                adminmode: adminmode,
                                                onClick: () {
                                                  getPunchData(
                                                      context,
                                                      attn.DT_DATE,
                                                      attn.SCANS,
                                                      attn.RECORD_ID,
                                                      attn.EMP_NAME);
                                                },
                                              )
                                        : ScanTime(
                                            dayName: attn.DAY_NAME,
                                            label: 'Lunch In',
                                            value: attn.DETAILS2
                                                .split(',')[2]
                                                .split('~')[0],
                                            deviation: attn.DETAILS2
                                                .split(',')[2]
                                                .split('~')[2],
                                            late: attn.DETAILS2
                                                    .split(',')[2]
                                                    .split('~')[3] ==
                                                'True',
                                            lunchdelay: attn.LUNCHDELAY,
                                            leave: attn.LEAVE,
                                            leavestatus: attn.LEAVE_STATUS,
                                            time: true,
                                            showDelay: showDelay,
                                            adminmode: adminmode,
                                            onClick: () {
                                              getPunchData(
                                                  context,
                                                  attn.DT_DATE,
                                                  attn.SCANS,
                                                  attn.RECORD_ID,
                                                  attn.EMP_NAME);
                                            },
                                          ),
                                    Expanded(
                                        flex: 1,
                                        child: Divider(
                                            thickness: 1,
                                            height: 0.5,
                                            color: Colors.grey)),
                                    attn.DETAILS2.split(',')[3] == '-'
                                        ? attn.LEAVE == 'SECOND HALF'
                                            ? Expanded(
                                                flex: 3,
                                                child: Divider(
                                                    thickness: 1,
                                                    height: 0.5,
                                                    color: Colors.grey))
                                            : ScanTime(
                                                dayName: attn.DAY_NAME,
                                                label: 'End',
                                                value: ' Missing!',
                                                leave: attn.LEAVE,
                                                leavestatus: attn.LEAVE_STATUS,
                                                showDelay: showDelay,
                                                adminmode: adminmode,
                                                onClick: () {
                                                  getPunchData(
                                                      context,
                                                      attn.DT_DATE,
                                                      attn.SCANS,
                                                      attn.RECORD_ID,
                                                      attn.EMP_NAME);
                                                },
                                              )
                                        : ScanTime(
                                            dayName: attn.DAY_NAME,
                                            label: 'End',
                                            value: attn.DETAILS2
                                                .split(',')[3]
                                                .split('~')[0],
                                            deviation: attn.DETAILS2
                                                .split(',')[3]
                                                .split('~')[2],
                                            late: attn.DETAILS2
                                                    .split(',')[3]
                                                    .split('~')[3] ==
                                                'True',
                                            lunchdelay: attn.LUNCHDELAY,
                                            leave: attn.LEAVE,
                                            leavestatus: attn.LEAVE_STATUS,
                                            time: true,
                                            showDelay: showDelay,
                                            adminmode: adminmode,
                                            onClick: () {
                                              getPunchData(
                                                  context,
                                                  attn.DT_DATE,
                                                  attn.SCANS,
                                                  attn.RECORD_ID,
                                                  attn.EMP_NAME);
                                            },
                                          ),
                                  ],
                                )
                              : (attn.SCANS ?? 0) > 0
                                  ? Icon(
                                      Icons.qr_code,
                                      size: 18,
                                      color: Colors.black,
                                    )
                                  : null,
                        ),
                        trailing: Container(
                          decoration: BoxDecoration(
                              color: ColorConfig.dark.withOpacity(0.6),
                              borderRadius: BorderRadius.only(
                                topRight: Radius.circular(7),
                                bottomRight: Radius.circular(7),
                              )),
                          height: double.infinity,
                          width: 18,
                          child: RotatedBox(
                            quarterTurns: 1,
                            child: Text(
                              attn.CATEGORY ?? 'NA',
                              maxLines: 1,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.normal,
                                overflow: TextOverflow.ellipsis,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        onTap: () {
                          getPunchData(context, attn.DT_DATE, attn.SCANS,
                              attn.RECORD_ID, attn.EMP_NAME);
                        },
                      ),
                      Visibility(
                        visible: attn.HOLIDAY != null,
                        child: Padding(
                          padding: const EdgeInsets.only(
                            right: 17,
                            top: 1,
                          ),
                          child: Align(
                            alignment: Alignment.topRight,
                            child: SizedBox(
                              height: 20,
                              child: FilterChip(
                                elevation: 1,
                                // labelPadding: EdgeInsets.all(0),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(7),
                                  ),
                                ),
                                // avatar: Icon(
                                //   Icons.holiday_village,
                                //   color: Colors.white,
                                //   size: 18,
                                // ),
                                padding: EdgeInsets.only(
                                  top: -8,
                                ),
                                visualDensity: VisualDensity.compact,
                                label: Text(
                                  attn.HOLIDAY ?? '',
                                  textAlign: TextAlign.start,
                                  maxLines: 1,
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                // backgroundColor: Colors.transparent,
                                backgroundColor: attn.NATIONAL_HOLIDAY == true
                                    ? Colors.amber.shade800
                                    : Colors.cyan.shade400,
                                // materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                onSelected: (value) {},
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
        separatorBuilder: (context, index) => const Divider(
          height: 10,
        ),
      ),
    );
  }

  SlidableAutoCloseBehavior attendanceConcise(CustomThemeProvider themeState) {
    return SlidableAutoCloseBehavior(
      child: ListView.separated(
        key: const Key('Lst3'),
        itemCount: _foundAttendanceConcise.length,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        scrollDirection: Axis.vertical,
        itemBuilder: (context, index) {
          final attn = _foundAttendanceConcise[index];
          cardKeyListConcise
              .add(GlobalKey(debugLabel: attn.RECORD_ID.toString()));

          return Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.topLeft,
            children: <Widget>[
              SizedBox(
                height: 25,
                child: Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: FilterChip(
                    elevation: 1,
                    labelPadding: const EdgeInsets.only(top: -6),
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(4)),
                    ),
                    visualDensity: VisualDensity.compact,
                    label: Text(
                      (attn.RECORD_ID == 1 && attn.HOLIDAY != null)
                          ? "Holiday (${attn.HOLIDAY})"
                          : attn.DETAILS,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.normal,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    backgroundColor: attn.RECORD_ID == 2
                        ? Colors.amber.shade900
                        : attn.RECORD_ID == 3
                            ? Colors.red
                            : attn.RECORD_ID == 4
                                ? Colors.cyan
                                : Colors.green,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    onSelected: (value) {},
                  ),
                ),
              ),
              Positioned(
                right: 4,
                child: SizedBox(
                  height: 25,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 4),
                    child: FilterChip(
                      elevation: 1,
                      labelPadding: const EdgeInsets.only(top: -6),
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(4)),
                      ),
                      visualDensity: VisualDensity.compact,
                      label: Text(
                        attn.VALUE == 0
                            ? 'None'
                            : attn.VALUE <= 9
                                ? '0${attn.VALUE.toString()}'
                                : attn.VALUE.toString(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.normal,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      backgroundColor: attn.RECORD_ID == 2
                          ? Colors.amber.shade900
                          : attn.RECORD_ID == 3
                              ? Colors.red
                              : attn.RECORD_ID == 4
                                  ? Colors.cyan
                                  : Colors.green,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      onSelected: (value) {},
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 15),
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(7),
                  ),
                  color: Colors.white,
                  elevation: 5,
                  child: ListTile(
                    key: cardKeyListConcise[index],
                    contentPadding: const EdgeInsets.only(
                      left: 0,
                      right: 0,
                    ),
                    // isThreeLine: true,
                    horizontalTitleGap: 0,
                    // minVerticalPadding: 5,
                    minLeadingWidth: 0,
                    // dense: true,
                    leading: null,
                    title: conciseInnerList(
                        themeState,
                        attn,
                        attn.RECORD_ID == 1
                            ? conciseAvailabledata
                            : attn.RECORD_ID == 2
                                ? conciseOnLeavedata
                                : attn.RECORD_ID == 3
                                    ? conciseAbsentdata
                                    : conciseYetToComedata),
                    trailing: null,
                    onTap: () {},
                  ),
                ),
              ),
            ],
          );
        },
        separatorBuilder: (context, index) => const Divider(
          height: 10,
        ),
      ),
    );
  }

  SizedBox conciseInnerList(CustomThemeProvider themeState, Summarise attn,
      List<AttendanceConcise> concisedata) {
    return SizedBox(
      height: attn.PERCENTAGE == 0
          ? 50
          : attn.PERCENTAGE <= 10
              ? attn.RECORD_ID == 1
                  ? 150
                  : 100
              : attn.PERCENTAGE <= 20
                  ? 150
                  : attn.PERCENTAGE <= 60
                      ? 200
                      : 250,
      // color: Colors.lightGreenAccent,
      child: ListView.separated(
        key: Key('Lst3${attn.RECORD_ID}'),
        itemCount: concisedata.length,
        shrinkWrap: true,
        physics: AlwaysScrollableScrollPhysics(),
        scrollDirection: Axis.vertical,
        itemBuilder: (context, index) {
          final data = concisedata[index];

          return GestureDetector(
            onTap: () {
              setState(() {
                adminmode = false;
                userdata[0].EMP_NAME = data.EMP_NAME;
                userdata[0].EMP_CODE = data.EMP_CODE;
                userdata[0].EMP_ID = data.RECORD_ID;
                half = data.HALF;
                nottoscan = true;
                refreshController.requestRefresh();
              });
            },
            child: SizedBox(
              height: attn.RECORD_ID == 1 ? 25 : 20,
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.centerLeft,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      SizedBox(
                        width: 2,
                      ),
                      Material(
                        elevation: 2,
                        child: Container(
                          height: attn.RECORD_ID == 1 ? 25 : 20,
                          width: 40,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            shape: BoxShape.rectangle,
                            color: data.DEPARTMENT == 'Desktop'
                                ? Colors.blue
                                : data.DEPARTMENT == 'Web'
                                    ? Colors.green
                                    : data.DEPARTMENT == 'Designer'
                                        ? Colors.pink
                                        : data.DEPARTMENT == 'Office'
                                            ? Colors.indigoAccent
                                            : Colors.cyan,
                            borderRadius: BorderRadius.all(Radius.circular(2)),
                          ),
                          margin: EdgeInsets.only(bottom: 0),
                          child: Padding(
                            padding: const EdgeInsets.only(left: 2, right: 2),
                            child: AutoSizeText(
                              data.DEPARTMENT ?? '',
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              minFontSize: 10,
                              // stepGranularity: 2,
                              // wrapWords: true,
                              // maxLines: 2,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 2,
                      ),
                      Icon(
                        data.SEX == null
                            ? Icons.man
                            : data.SEX == true
                                ? Icons.woman
                                : Icons.man,
                        color: Colors.black,
                        size: 16,
                      ),
                      SizedBox(
                        // color: Colors.lightGreen,
                        width: attn.RECORD_ID == 3 || attn.RECORD_ID == 4
                            ? MediaQuery.of(context).size.width - 90
                            : attn.RECORD_ID == 2
                                ? MediaQuery.of(context).size.width - 220
                                : MediaQuery.of(context).size.width -
                                    150 -
                                    (data.WORKTIME != null ? 38 : 0),
                        child: AutoSizeText(
                          data.EMP_NAME ?? '',
                          key: GlobalKey(
                              debugLabel: "Inner_${data.RECORD_ID.toString()}"),
                          maxLines: 1,
                          minFontSize: 12,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.normal,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Positioned(
                    right: 2,
                    child: Row(
                      children: [
                        Visibility(
                          visible: attn.RECORD_ID == 1,
                          child: Row(
                            children: [
                              Visibility(
                                visible: data.WORKTIME == null &&
                                    data.LEAVE == null &&
                                    data.DETAILS2.split(',')[1] != '-' &&
                                    data.DETAILS2.split(',')[2] == '-',
                                child: Icon(
                                  FontAwesomeIcons.utensils,
                                  color: Colors.grey.shade800,
                                  size: 14,
                                ),
                              ),
                              Visibility(
                                visible: data.WORKTIME == null &&
                                    data.LEAVE == null &&
                                    data.DETAILS2.split(',')[1] != '-' &&
                                    data.DETAILS2.split(',')[2] == '-',
                                child: SizedBox(width: 4),
                              ),
                              Visibility(
                                visible: data.DETAILS2.split(',')[0] != '-',
                                child: Material(
                                  elevation: 2,
                                  child: Container(
                                    height: 25,
                                    width: 35,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.rectangle,
                                      color: attn.RECORD_ID == 1 &&
                                              data.DETAILS2.split(',')[0] !=
                                                  '-' &&
                                              data.DETAILS2
                                                      .split(',')[0]
                                                      .split('~')[3] ==
                                                  'True'
                                          ? Colors.red
                                          : Colors.green,
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(2)),
                                    ),
                                    margin: EdgeInsets.only(bottom: 0),
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          left: 2, right: 2),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        mainAxisSize: MainAxisSize.max,
                                        children: [
                                          Text(
                                            attn.RECORD_ID == 1 &&
                                                    data.DETAILS2
                                                            .split(',')[0] !=
                                                        '-' &&
                                                    data.DETAILS2
                                                            .split(',')[0]
                                                            .split('~')[3] ==
                                                        'True'
                                                ? 'Late'
                                                : 'Early',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 8,
                                              fontWeight: FontWeight.w500,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          Text(
                                            attn.RECORD_ID == 1 &&
                                                    data.DETAILS2
                                                            .split(',')[0] !=
                                                        '-'
                                                ? data.DETAILS2
                                                    .split(',')[0]
                                                    .split('~')[2]
                                                : '-',
                                            overflow: TextOverflow.ellipsis,
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 10,
                                              fontWeight: FontWeight.w500,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Visibility(
                                visible: data.WORKTIME != null,
                                child: Row(
                                  children: [
                                    SizedBox(width: 5),
                                    Material(
                                      elevation: 2,
                                      child: Container(
                                        height: attn.RECORD_ID == 1 ? 25 : 20,
                                        width: 35,
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.rectangle,
                                          color: data.WORKTIME != null &&
                                                  attn.RECORD_ID == 1 &&
                                                  data.DETAILS2.split(',')[0] !=
                                                      '-' &&
                                                  ((data.LEAVE != null &&
                                                          int.parse(data
                                                                      .WORKTIME!
                                                                      .split(
                                                                          ':')[
                                                                  0]) >=
                                                              4) ||
                                                      int.parse(data.WORKTIME!
                                                              .split(':')[0]) >=
                                                          8)
                                              ? Colors.green
                                              : Colors.red,
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(2)),
                                        ),
                                        margin: EdgeInsets.only(bottom: 0),
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                              left: 2, right: 2),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            mainAxisSize: MainAxisSize.max,
                                            children: [
                                              Text(
                                                'Work',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 8,
                                                  fontWeight: FontWeight.w500,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                              Text(
                                                data.WORKTIME ?? '-',
                                                overflow: TextOverflow.ellipsis,
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w500,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(width: 2),
                              Icon(
                                FontAwesomeIcons.solidCircleCheck,
                                color: data.WORKTIME == null &&
                                        data.STATUS == null &&
                                        data.DETAILS2.split(',')[0] != '-'
                                    ? Colors.green.shade500
                                    : Colors.grey.shade400,
                                size: 18,
                              ),
                            ],
                          ),
                        ),
                        Visibility(
                          visible: attn.RECORD_ID == 2,
                          child: Row(
                            children: [
                              Material(
                                elevation: 2,
                                child: Container(
                                  height: 20,
                                  width: 70,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.rectangle,
                                    color: ColorConfig.darkMain,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(2)),
                                  ),
                                  margin: EdgeInsets.only(bottom: 0),
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        left: 2, right: 2),
                                    child: AutoSizeText(
                                      data.LEAVE ?? '',
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.center,
                                      minFontSize: 8,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w500,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 5),
                              Material(
                                elevation: 2,
                                child: Container(
                                  height: 20,
                                  width: 55,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.rectangle,
                                    color: data.LEAVE_STATUS == null
                                        ? Colors.amber.shade900
                                        : data.LEAVE_STATUS == 'CANCELLED'
                                            ? Colors.red
                                            : Colors.green,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(2)),
                                  ),
                                  margin: EdgeInsets.only(bottom: 0),
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        left: 2, right: 2),
                                    child: Text(
                                      data.LEAVE_STATUS == null
                                          ? 'Pending'
                                          : data.LEAVE_STATUS == 'CANCELLED'
                                              ? 'Cancelled'
                                              : 'Approved',
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w500,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        separatorBuilder: (context, index) => const Divider(
          height: 4,
        ),
      ),
    );
  }

  Future<bool> checkGps(BuildContext context, bool request) async {
    deviceInfo = DeviceInfoPlugin();
    final loginProv = Provider.of<LoginProvider>(context, listen: false);

    if (Platform.isIOS) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;

      setState(() {
        deviceId = iosInfo.identifierForVendor;
        loginProv.deviceId = deviceId;
      });
    } else {
      // const androidIdPlugin = AndroidId();

      // final String? androidId = await androidIdPlugin.getId();

      // if (kDebugMode) {
      //   print(androidId);
      // }

      final arguments = {'message': 'Pinaks Flutter'};
      final String serialNo =
          await channel.invokeMethod('getSerialNo', arguments);

      if (kDebugMode) {
        print("Device_ID: $serialNo");
      }

      final androidInfo = await deviceInfo.androidInfo;

      setState(() {
        deviceId =
            "${serialNo.toUpperCase().removeAllWhitespace}-${androidInfo.brand.toUpperCase().removeAllWhitespace}-${androidInfo.model.toUpperCase().removeAllWhitespace}";
        loginProv.deviceId = deviceId;
      });
      // if (serialNo != "NA") {
      //   setState(() {
      //     deviceId = serialNo.toUpperCase();
      //     loginProv.deviceId = deviceId;
      //   });
      // } else {
      //   final androidInfo = await deviceInfo.androidInfo;
      //   deviceId = "${androidInfo.brand.toUpperCase().removeAllWhitespace}-${androidInfo.model.toUpperCase().removeAllWhitespace}-";
      //   setState(() {
      //     deviceId = "$deviceId${androidInfo.host.toUpperCase().removeAllWhitespace}-${androidInfo.hardware.toUpperCase().removeAllWhitespace}";
      //     loginProv.deviceId = deviceId;
      //   });
      // }
    }

    loginProv.fcmToken = await FirebaseApi().getFCMToken();

    if (kDebugMode) {
      print("FCM_Token: ${loginProv.fcmToken}");
    }

    fcmToken = loginProv.fcmToken;

    servicestatus = await Geolocator.isLocationServiceEnabled();
    if (servicestatus) {
      permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        if (request == true) {
          permission = await Geolocator.requestPermission();
        }

        if (permission == LocationPermission.denied) {
          loginProv.isLocationEnabled = false;
          if (kDebugMode) {
            print('Location permissions are denied');
          }
        } else if (permission == LocationPermission.deniedForever) {
          loginProv.isLocationEnabled = false;
          if (kDebugMode) {
            print('Location permissions are permanently denied');
          }
        } else {
          loginProv.isLocationEnabled = true;
        }
      } else {
        loginProv.isLocationEnabled = true;
      }
    } else {
      loginProv.isLocationEnabled = false;
      if (kDebugMode) {
        print("GPS Service is not enabled, turn on GPS location");
      }
    }

    return loginProv.isLocationEnabled;
  }

  Future<String> checkip(
      BuildContext context, String? sysId, String? fcmToken) async {
    try {
      setState(() {
        regmsg = '';
      });

      var dioObj = DioHelper();

      final params = <String, dynamic>{
        'sys_id': sysId,
        'fcm_token': fcmToken,
        'version': version,
      };

      if (uuid != null) {
        params.addAll({'uuid_no': uuid});
      }

      final response = await dioObj.api.get(
        Config.checkIp,
        options: dio.Options(
          headers: {"requires-token": false},
        ),
        queryParameters: params,
      );

      if (response.statusCode == 200) {
        // if (kDebugMode) {
        //   print(response.data);
        // }

        Box box1 = await Hive.openBox('heptalogindata');

        setState(() {
          registered = false;
          initialProcess = true;
          // registered = (response.data!['type'].toString().contains('Received') == false &&
          //     response.data!['type'].toString().contains('Pending') == false &&
          //     response.data!['type'].toString().contains('Unauthorised') == false);
          regmsg =
              '${response.data!['message'].toString()}\n${response.data!['type'].toString()}';
          // regmsg = response.data!['message'].toString();
          blacklisted =
              (response.data!['type'].toString().contains('Unauthorised') ==
                  true);

          if (response.data!['uuid'].toString() != '') {
            box1.put('uuid', response.data!['uuid'].toString());
          }
        });

        return 'Unregistered';
      } else if (response.statusCode == 201) {
        // if (kDebugMode) {
        //   print(response.data);
        // }
        Box box1 = await Hive.openBox('heptalogindata');

        final result = EmployeeData.fromJson(response.data);

        setState(() {
          userdata = result.data;
          lat0 = double.parse(userdata[0].LATITUDE);
          long0 = double.parse(userdata[0].LONGITUDE);
          allowedDistance = userdata[0].ALLOWED_DISTANCE;
          admin = userdata[0].ADMIN;
          adminName = userdata[0].ADMINNAME;
          ceo = (admin && userdata[0].EMP_NAME == null);
          adminmode = ceo;
          half = result.half;

          final loginProv = Provider.of<LoginProvider>(context, listen: false);
          loginProv.adminName = adminName;

          showDelay = userdata[0].SHOW_DELAY;
          showLunch = userdata[0].SHOW_LUNCH;

          if (userdata[0].ADMIN_CATEGORY_DEFAULT != null) {
            category = userdata[0].ADMIN_CATEGORY_DEFAULT ?? 'Category';
          }

          if (userdata[0].ADMIN_DEPARTMENT_DEFAULT != null) {
            section = userdata[0].ADMIN_DEPARTMENT_DEFAULT ?? 'Section';
          }

          box1.put('uuid', userdata[0].UUID);

          registered = true;
          initialProcess = true;

          initialRefresh = true;
          refreshController.requestRefresh();
        });

        return 'Registered';
      }
    } on DioException catch (e) {
      setState(() {
        initialProcess = true;
      });

      dioMessage(
          e,
          'Failed to Initialize!',
          '${Trace.from(StackTrace.current).frames[0].member} Line: ${Trace.from(StackTrace.current).frames[0].line}',
          context,
          true);
    } on Exception catch (e) {
      if (kDebugMode) {
        print('Failed to initialize: $e');
      }

      setState(() {
        initialProcess = true;
      });

      awesomePopup(context, e.toString(), 'Failed to initialize!', 'error')
          .show();
    }

    return 'Error';
  }

  Future<void> scanQR() async {
    String barcodeScanRes;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
        '#ff6666',
        'Cancel',
        true,
        ScanMode.QR,
      );

      // final snackBar = SnackBar(content: Text('Selected [$barcodeScanRes]'));
      // ScaffoldMessenger.of(context)
      //   ..removeCurrentSnackBar()
      //   ..showSnackBar(snackBar);

      // If the widget was removed from the tree while the asynchronous platform
      // message was in flight, we want to discard the reply rather than calling
      // setState to update our non-existent appearance.
      if (!mounted) return;

      if (barcodeScanRes == '-1') {
        AssetsAudioPlayer.newPlayer().open(
          Audio("assets/audios/cancel2.mp3"),
          autoStart: true,
          showNotification: true,
        );
        var snackBar = const SnackBar(content: Text('No QRCode Scanned!'));
        ScaffoldMessenger.of(context)
          ..removeCurrentSnackBar()
          ..showSnackBar(snackBar);
      } else if (barcodeScanRes != userdata[0].ALLOWED_QRCODE) {
        awesomePopup(context, 'Invalid QRCode Scanned!',
                'Attendance Scanning Failed!', 'error')
            .show();
      } else if (distance == null || (distance ?? 0) > allowedDistance!) {
        awesomePopup(context, 'Device is outside allowed range!',
                'Attendance Scanning Failed!', 'error')
            .show();
      } else {
        var dioObj = DioHelper();

        try {
          final params = <String, dynamic>{
            'sys_id': deviceId,
            'emp_id': userdata[0].EMP_ID,
            'emp_name': userdata[0].EMP_NAME,
          };

          if (uuid != null) {
            params.addAll({'uuid_no': uuid});
          }

          final response = await dioObj.api.post(
            Config.punchAPI,
            options: dio.Options(headers: {"requires-token": false}),
            queryParameters: params,
          );

          if (response.statusCode == 200) {
            // if (kDebugMode) {
            //   print(response);
            // }

            AssetsAudioPlayer.newPlayer().open(
              Audio("assets/audios/railway.mp3"),
              autoStart: true,
              showNotification: true,
            );

            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(SnackBar(
                elevation: 0,
                behavior: SnackBarBehavior.floating,
                backgroundColor: Colors.transparent,
                content: AwesomeSnackbarContent(
                  title: Config.appName,
                  message: 'Scanned successfully!',
                  contentType: ContentType.success,
                ),
              ));

            initialRefresh = true;
            refreshController.requestRefresh();
          }
        } on DioException catch (e) {
          dioMessage(
              e,
              'Attendance Scanning Failed!',
              '${Trace.from(StackTrace.current).frames[0].member} Line: ${Trace.from(StackTrace.current).frames[0].line}',
              context,
              true);
        } on PlatformException catch (e) {
          if (kDebugMode) {
            print('Failed to scan: $e');
          }

          awesomePopup(
                  context, e.toString(), 'Attendance Scanning Failed!', 'error')
              .show();
        }
      }
    } on PlatformException catch (e) {
      awesomePopup(context, e.toString(), 'Error Scanning Stock!', 'error')
          .show();
    } on Exception catch (e) {
      awesomePopup(context, e.toString(), 'Error Scanning Stock!', 'error')
          .show();
    }
  }

  Future<bool> getQRCodePdf(BuildContext context) async {
    try {
      var dioObj = DioHelper();

      final params = <String, dynamic>{
        'system_name': deviceId,
      };

      final response = await dioObj.api.get(
        Config.printAPI,
        options: dio.Options(
          headers: {"requires-token": true},
          responseType: dio.ResponseType.bytes,
          // followRedirects: false,
          // receiveTimeout: const Duration(seconds: 10),
        ),
        queryParameters: params,
      );

      if (response.statusCode == 200) {
        final appStorage = await getExternalStorageDirectory();
        // if (kDebugMode) {
        //   print(appStorage);
        // }

        final savedDir = Directory(appStorage!.path);
        bool hasExisted = await savedDir.exists();
        if (!hasExisted) {
          savedDir.create();
        }
        var filename = response.headers['content-disposition'];
        final name = filename![0].split('=').last;
        final file = File('${appStorage.path}/$name');

        final raf = file.openSync(mode: FileMode.write);
        raf.writeFromSync(response.data);
        await raf.close();

        // if (file == null) {
        //   return false;
        // }

        // if (kDebugMode) {
        //   print('Path: ${file.path}');
        //   print('Length: ${file.lengthSync()}');
        // }

        setState(() {
          filePathQR = file.path;
        });
        // if (kDebugMode) {
        //   print(ret);
        // }

        return true;
      } else {
        if (kDebugMode) {
          print(response.data);
        }

        return false;
      }

      // await Future.delayed(const Duration(seconds: 15), () {
      //   progress?.dismiss();
      // });

      // Navigator.of(context).pop(suppController.text);
    } on DioException catch (e) {
      dioMessage(
          e,
          'QR Code Generation Failed!',
          '${Trace.from(StackTrace.current).frames[0].member} Line: ${Trace.from(StackTrace.current).frames[0].line}',
          context,
          true);
    } on PlatformException catch (e) {
      if (kDebugMode) {
        print('Failed to print QR code: $e');
      }

      awesomePopup(context, e.toString(), 'QR Code Generation Failed!', 'error')
          .show();
    } on Exception catch (e) {
      if (kDebugMode) {
        print('Failed to print QR code: $e');
      }

      // awesomePopup(context, e.toString(), 'QR Code Generation Failed!', 'error').show();
      awesomePopup(
              context,
              "The request connection took very long, hence it was aborted!",
              'QR Code Generation Failed!',
              'error')
          .show();
    }
    // Navigator.of(context).pop(suppController.text);

    // suppController.clear();

    return false;
  }

  Future<bool> getAttendanceData(BuildContext context,
      {bool isRefresh = false}) async {
    try {
      if (userdata.isEmpty) {
        cardKeyList = [];
        attendancedata = [];
        currentPage = 1;

        totalPages = 0;

        _foundAttendance = attendancedata;
        return false;
      }

      if (isRefresh == true) {
        setState(() {
          currentPage = 1;
        });
      } else {
        if (currentPage > totalPages) {
          setState(() {
            refreshController.loadNoData();
          });
          return false;
        }
      }

      var dioObj = DioHelper();

      final params = <String, dynamic>{
        'system_name': deviceId,
        'emp_id': userdata[0].EMP_ID ?? 0,
        'page': currentPage,
        'limit': 10,
        'keywords': '*',
      };

      final response = await dioObj.api.get(
        Config.attendanceListingAPI,
        options: dio.Options(
          headers: {"requires-token": false},
          // validateStatus: (status) => true,
          // followRedirects: false,
        ),
        queryParameters: params,
      );

      if (response.statusCode == 200) {
        final result = AttendanceListingData.fromJson(response.data);

        setState(() {
          if (isRefresh) {
            cardKeyList = [];
            attendancedata = result.data;
          } else {
            attendancedata.addAll(result.data);
          }
          currentPage++;

          totalPages = result.pages; //Last 10 Entries

          _foundAttendance = attendancedata;

          // if (kDebugMode) {
          //   print(response.data);
          // }
        });

        return true;
      } else {
        setState(() {
          cardKeyList = [];
          attendancedata = [];
          currentPage = 1;

          totalPages = 0;

          _foundAttendance = attendancedata;

          // if (kDebugMode) {
          //   print(response.data);
          // }
        });

        return false;
      }

      // await awesomePopup(context, response.data['message'].toString(), 'Success', 'success').show();
    } on DioException catch (e) {
      dioMessage(
          e,
          'Attendance Listing Failed!',
          '${Trace.from(StackTrace.current).frames[0].member} Line: ${Trace.from(StackTrace.current).frames[0].line}',
          context,
          true);
    } on PlatformException catch (e) {
      if (kDebugMode) {
        print('Failed to retrive attendance data: $e');
      }

      await awesomePopup(
              context, e.toString(), 'Attendance Listing Failed!', 'error')
          .show();

      return false;
    }

    return false;
  }

  Future<bool?> _vecationBottomSheet(BuildContext context) async {
    setState(() {
      setStateVecation = null;
      dragUpDown = true;
      vecationdata = [];
      vecationlistResult = false;
    });

    getVecationData(context);

    return await showModalBottomSheet(
      isScrollControlled: true, // required for min/max child size
      elevation: 10,
      barrierColor: ColorConfig.darkMain.withOpacity(0.6),
      backgroundColor: Colors.white, //Colors.cyan.shade50
      isDismissible: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(15.0),
        ),
      ),
      // constraints: BoxConstraints(
      //   maxWidth: MediaQuery.of(context).size.width - 40, // here increase or decrease in width
      // ),
      context: context,
      builder: (context) => buildScrollableSheet(),
    );
  }

  Widget makeDismissible({required Widget child}) => GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => Navigator.of(context).pop(false),
        child: GestureDetector(onTap: () {}, child: child),
      );

  Widget buildScrollableSheet() =>
      NotificationListener<DraggableScrollableNotification>(
        onNotification: (notification) {
          setState(() {
            if (notification.extent >= 0.7) {
              dragUpDown = false;
            } else {
              dragUpDown = true;
            }
          });

          setStateVecation!(() {});
          return true;
        },
        child: Builder(
          builder: (BuildContext bcontext) {
            return StatefulBuilder(builder: (context, innerSetState) {
              setStateVecation = innerSetState;

              return DraggableScrollableSheet(
                initialChildSize: 0.5,
                minChildSize: 0.3,
                maxChildSize: 0.7,
                expand: false,
                controller: dragController,
                builder: (_, scrollController) => Padding(
                  padding: EdgeInsets.only(
                    left: 10,
                  ), //, bottom: (loginProv.noInternet == true) ? 110 : 70
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white, //Colors.cyan.shade50
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                    margin: EdgeInsets.only(left: 0, right: 10),
                    width: MediaQuery.of(context).size.width,
                    child: ProgressHUD(
                      indicatorColor: ColorConfig.lightMain,
                      textStyle: TextStyle(color: ColorConfig.lightMain),
                      barrierColor: ColorConfig.darkMain.withOpacity(0.6),
                      barrierEnabled: true,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Expanded(
                                flex: 5,
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: FilterChip(
                                    elevation: 1,
                                    // labelPadding: EdgeInsets.all(0),
                                    shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(7)),
                                    ),
                                    avatar: FaIcon(
                                      FontAwesomeIcons.umbrellaBeach,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                    visualDensity: VisualDensity.compact,
                                    label: Text(
                                      'Holiday List',
                                      textAlign: TextAlign.start,
                                      maxLines: 1,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    backgroundColor: Colors.cyan.shade400,
                                    materialTapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                    onSelected: (value) {},
                                  ),
                                ),
                              ),
                              Align(
                                alignment: Alignment.center,
                                child: SizedBox(
                                  height: 30,
                                  width: 30,
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 2),
                                    child: FloatingActionButton(
                                      backgroundColor:
                                          ColorConfig.dark.withOpacity(0.8),
                                      elevation: 2,
                                      onPressed: () {
                                        double val =
                                            dragUpDown == true ? 0.7 : 0.3;
                                        dragController.jumpTo(val);
                                        dragController.animateTo(
                                          val,
                                          duration:
                                              const Duration(milliseconds: 100),
                                          curve: Curves.easeInBack,
                                        );
                                      },
                                      child: Icon(
                                        dragUpDown == true
                                            ? Icons.arrow_upward
                                            : Icons.arrow_downward,
                                        size: 16,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 5,
                                child: Align(
                                  alignment: Alignment.centerRight,
                                  child: FilterChip(
                                    elevation: 1,
                                    shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(7)),
                                    ),
                                    visualDensity: VisualDensity.compact,
                                    label: Text(
                                      vecationdata.isEmpty
                                          ? 'Wait'
                                          : DateFormat("yyyy")
                                              .format(vecationdata[0].DT_DATE),
                                      textAlign: TextAlign.start,
                                      maxLines: 1,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    backgroundColor:
                                        ColorConfig.dark.withOpacity(0.8),
                                    materialTapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                    onSelected: (value) {},
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Visibility(
                            visible: vecationlistResult == false,
                            child: const Expanded(
                              flex: 12,
                              child: Center(
                                child: CircularProgressIndicator(
                                  backgroundColor: Colors.white,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.blue),
                                  strokeWidth: 4,
                                ),
                              ),
                            ),
                          ),
                          Visibility(
                            visible: vecationlistResult == true &&
                                vecationdata.isEmpty,
                            child: const Expanded(
                              flex: 12,
                              child: Center(
                                child: Text(
                                  'Vacation List Missing!',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.normal,
                                      color: Colors.black),
                                ),
                              ),
                            ),
                          ),
                          Visibility(
                            visible: vecationlistResult == true &&
                                vecationdata.isNotEmpty,
                            child: Expanded(
                              flex: 12,
                              child: SingleChildScrollView(
                                controller: scrollController,
                                // physics: const AlwaysScrollableScrollPhysics(),
                                // padding: EdgeInsets.only(right: 10),
                                child: ListView.builder(
                                  itemCount: vecationdata.length,
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  scrollDirection: Axis.vertical,
                                  // padding: const EdgeInsets.only(right: 20),
                                  itemBuilder: (context, index) {
                                    final data = vecationdata[index];

                                    return Card(
                                      key: Key(data.RECORD_ID.toString()),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(7),
                                      ),
                                      color: Colors.white,
                                      elevation: 4,
                                      child: Stack(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(
                                              left: 20,
                                              right: 16,
                                            ),
                                            child: ClipRRect(
                                              // borderRadius: BorderRadius.circular(7.0),
                                              child: Image.asset(
                                                "assets/images/holidays/${data.HOLIDAY == 'GANDHI JAYANTI' ? 'Gandhi_Jayanti.png' : data.HOLIDAY == 'ASHTAMI' || data.HOLIDAY == 'NAVAMI' || data.HOLIDAY == 'VIJAYA DASHAMI' ? 'Durga_Puja.png' : data.HOLIDAY == 'VISHWAKARMA PUJA' ? 'Viswakarma_Puja.png' : data.HOLIDAY == 'DIWALI' ? 'Diwali.png' : data.HOLIDAY == 'REPUBLIC DAY' ? 'Republic_Day.png' : data.HOLIDAY == 'INDEPENDENCE DAY' ? 'Independence_Day.png' : data.HOLIDAY == 'RATH YATRA' ? 'Ratha_Yatra.png' : data.HOLIDAY == 'HOLI' ? 'Holi.png' : 'Holiday.png'}",
                                                height: 56,
                                                fit: BoxFit.fill,
                                              ),
                                            ),
                                          ),
                                          ListTile(
                                            key: Key(
                                                'LT${data.RECORD_ID.toString()}'),
                                            contentPadding:
                                                const EdgeInsets.only(
                                              left: 0,
                                              right: 0,
                                            ),
                                            isThreeLine: false,
                                            horizontalTitleGap: 0,
                                            // dense: true,
                                            leading: Container(
                                              decoration: BoxDecoration(
                                                color: data.DT_DATE.weekday == 7
                                                    ? Colors.amber.shade800
                                                    : Colors.blue,
                                                borderRadius: BorderRadius.only(
                                                  topLeft: Radius.circular(7),
                                                  bottomLeft:
                                                      Radius.circular(7),
                                                ),
                                              ),
                                              height: double.infinity,
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceAround,
                                                children: [
                                                  CircleAvatar(
                                                    maxRadius: 7,
                                                    backgroundColor:
                                                        Colors.white,
                                                    child: Text(
                                                      DateFormat("dd")
                                                          .format(data.DT_DATE),
                                                      style: TextStyle(
                                                        fontSize: 10,
                                                        fontWeight:
                                                            FontWeight.w700,
                                                        color: Colors.black,
                                                      ),
                                                    ),
                                                  ),
                                                  RotatedBox(
                                                    quarterTurns: 3,
                                                    child: Text(
                                                      DateFormat("EEE")
                                                          .format(data.DT_DATE),
                                                      maxLines: 1,
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            minLeadingWidth: 18,
                                            title: SizedBox(
                                              height: 50,
                                              width: double.maxFinite,
                                              // color: Colors.greenAccent,
                                              // decoration: BoxDecoration(
                                              //   borderRadius: BorderRadius.all(Radius.circular(7)),
                                              //   // color: Colors.greenAccent,
                                              //   image: attn.HOLIDAY != null
                                              //       ? DecorationImage(
                                              //           fit: BoxFit.fill, //i assumed you want to occupy the entire space of the card
                                              //           image: AssetImage(
                                              //             'assets/images/Gandhi_Jayanti.png',
                                              //           ),
                                              //         )
                                              //       : null,
                                              // ),
                                              child: null,
                                            ),
                                            trailing: Container(
                                              decoration: BoxDecoration(
                                                  color: Colors.grey,
                                                  borderRadius:
                                                      BorderRadius.only(
                                                    topRight:
                                                        Radius.circular(7),
                                                    bottomRight:
                                                        Radius.circular(7),
                                                  )),
                                              height: double.infinity,
                                              // width: 18,
                                              child: RotatedBox(
                                                quarterTurns: 3,
                                                child: Text(
                                                  DateFormat("MMM")
                                                      .format(data.DT_DATE),
                                                  maxLines: 1,
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight:
                                                        FontWeight.normal,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          Visibility(
                                            visible: data.HOLIDAY != null,
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                right: 17,
                                                top: 1,
                                              ),
                                              child: Align(
                                                alignment: Alignment.topRight,
                                                child: SizedBox(
                                                  height: 20,
                                                  child: FilterChip(
                                                    elevation: 1,
                                                    // labelPadding: EdgeInsets.all(0),
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.only(
                                                        topLeft:
                                                            Radius.circular(7),
                                                      ),
                                                    ),
                                                    // avatar: Icon(
                                                    //   Icons.holiday_village,
                                                    //   color: Colors.white,
                                                    //   size: 18,
                                                    // ),
                                                    padding: EdgeInsets.only(
                                                      top: -8,
                                                    ),
                                                    visualDensity:
                                                        VisualDensity.compact,
                                                    label: Text(
                                                      data.HOLIDAY ?? '',
                                                      textAlign:
                                                          TextAlign.start,
                                                      maxLines: 1,
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 10,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ),
                                                    // backgroundColor: Colors.transparent,
                                                    backgroundColor:
                                                        data.NATIONAL_HOLIDAY ==
                                                                true
                                                            ? Colors
                                                                .amber.shade800
                                                            : Colors
                                                                .cyan.shade400,
                                                    // materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                                    onSelected: (value) {},
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            });
          },
        ),
      );

  Future<bool> getVecationData(BuildContext context) async {
    try {
      var dioObj = DioHelper();

      final params = <String, dynamic>{
        'system_name': deviceId,
      };

      final response = await dioObj.api.get(
        Config.vecationListAPI,
        options: dio.Options(
          headers: {"requires-token": false},
          // validateStatus: (status) => true,
          // followRedirects: false,
        ),
        queryParameters: params,
      );

      if (response.statusCode == 200) {
        final result = VacationListingData.fromJson(response.data);

        setState(() {
          vecationdata = result.data;
          vecationlistResult = true;

          if (setStateVecation != null) {
            setStateVecation!(() {});
          }

          // if (kDebugMode) {
          //   print(response.data);
          // }
        });

        return true;
      } else {
        setState(() {
          vecationlistResult = true;
          vecationdata = [];

          if (setStateVecation != null) {
            setStateVecation!(() {});
          }
        });

        return false;
      }

      // await awesomePopup(context, response.data['message'].toString(), 'Success', 'success').show();
    } on DioException catch (e) {
      dioMessage(
          e,
          'Vacation List Failed!',
          '${Trace.from(StackTrace.current).frames[0].member} Line: ${Trace.from(StackTrace.current).frames[0].line}',
          context,
          false);
    } on Exception catch (e) {
      if (kDebugMode) {
        print('Failed to fetch vecation list: $e');
      }

      // awesomePopup(context, e.toString(), 'Vacation List Failed!', 'error').show();
    }

    setState(() {
      vecationlistResult = true;

      if (setStateVecation != null) {
        setStateVecation!(() {});
      }
    });

    return false;
  }

  Future<bool> getLeaveData(BuildContext context) async {
    if (userdata.isEmpty) {
      leavedata = [];
      return false;
    }

    try {
      var dioObj = DioHelper();

      final params = <String, dynamic>{
        'emp_id': userdata[0].EMP_ID,
        'system_name': deviceId,
      };

      if (uuid != null) {
        params.addAll({'uuid_no': uuid});
      }

      final response = await dioObj.api.get(
        Config.leaveListingAPI,
        options: dio.Options(
          headers: {"requires-token": false},
          // validateStatus: (status) => true,
          // followRedirects: false,
        ),
        queryParameters: params,
      );

      if (response.statusCode == 200) {
        final result = LeaveListingData.fromJson(response.data);

        setState(() {
          leavedata = result.data;
          leavelistResult = true;

          if (setStateLeave != null) {
            setStateLeave!(() {});
          }

          // if (kDebugMode) {
          //   print(response.data);
          // }
        });

        return true;
      } else {
        setState(() {
          leavelistResult = true;
          leavedata = [];

          if (setStateLeave != null) {
            setStateLeave!(() {});
          }
        });

        return false;
      }

      // await awesomePopup(context, response.data['message'].toString(), 'Success', 'success').show();
    } on DioException catch (e) {
      dioMessage(
          e,
          'Leave List Failed!',
          '${Trace.from(StackTrace.current).frames[0].member} Line: ${Trace.from(StackTrace.current).frames[0].line}',
          context,
          true);
    } on Exception catch (e) {
      if (kDebugMode) {
        print('Failed to fetch leave list: $e');
      }

      // awesomePopup(context, e.toString(), 'Leave List Failed!', 'error').show();
    }

    setState(() {
      leavelistResult = true;

      if (setStateLeave != null) {
        setStateLeave!(() {});
      }
    });

    return false;
  }

  Future<bool?> _leaveBottomSheet(BuildContext context) async {
    setState(() {
      leavelistResult = false;
      dragUpDown = true;
      leavedata = [];
    });

    getLeaveData(context);

    return await showModalBottomSheet(
      isScrollControlled: true, // required for min/max child size
      elevation: 10,
      barrierColor: ColorConfig.darkMain.withOpacity(0.6),
      backgroundColor: ColorConfig.light, //Colors.cyan.shade50
      isDismissible: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(15.0),
        ),
      ),
      // constraints: BoxConstraints(
      //   maxWidth: MediaQuery.of(context).size.width - 40, // here increase or decrease in width
      // ),
      context: context,
      builder: (context) => buildScrollableSheetLeave(),
    );
  }

  Widget
      buildScrollableSheetLeave() =>
          NotificationListener<DraggableScrollableNotification>(
            onNotification: (notification) {
              setState(() {
                if (notification.extent >= 0.7) {
                  dragUpDown = false;
                } else {
                  dragUpDown = true;
                }
              });

              setStateLeave!(() {});
              return true;
            },
            child: Builder(
              builder: (BuildContext bcontext) {
                return StatefulBuilder(
                    builder: (BuildContext sfctx, innerSetState) {
                  setStateLeave = innerSetState;

                  return DraggableScrollableSheet(
                    initialChildSize: 0.5,
                    minChildSize: 0.3,
                    maxChildSize: 0.7,
                    expand: false,
                    controller: dragControllerLeave,
                    builder: (_, scrollController) => Scaffold(
                      extendBody: false,
                      key: _leaveScaffoldKey,
                      resizeToAvoidBottomInset: true,
                      backgroundColor: Colors.transparent,
                      body: ProgressHUD(
                        indicatorColor: ColorConfig.lightMain,
                        textStyle: TextStyle(color: ColorConfig.lightMain),
                        barrierColor: ColorConfig.darkMain.withOpacity(0.6),
                        barrierEnabled: true,
                        child: Builder(builder: (BuildContext pHUDcontext) {
                          return Padding(
                            padding: EdgeInsets.only(
                              left: 10,
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                color: ColorConfig.light, //Colors.cyan.shade50
                                borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(20)),
                              ),
                              margin: EdgeInsets.only(left: 0, right: 10),
                              width: MediaQuery.of(sfctx).size.width,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        top: 5, left: 5, right: 5, bottom: 5),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      mainAxisSize: MainAxisSize.max,
                                      children: [
                                        Expanded(
                                          flex: 5,
                                          child: Align(
                                            alignment: Alignment.centerLeft,
                                            child: SizedBox(
                                              height: 40,
                                              child: FilterChip(
                                                elevation: 1,
                                                // labelPadding: EdgeInsets.all(0),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(7)),
                                                ),
                                                avatar: FaIcon(
                                                  FontAwesomeIcons
                                                      .personWalkingLuggage,
                                                  color: Colors.white,
                                                ),
                                                // visualDensity: VisualDensity.compact,
                                                label: Text(
                                                  'Leave Register',
                                                  textAlign: TextAlign.start,
                                                  maxLines: 1,
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.bold,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                                backgroundColor:
                                                    Colors.amber.shade900,
                                                materialTapTargetSize:
                                                    MaterialTapTargetSize
                                                        .shrinkWrap,
                                                onSelected: (value) {},
                                              ),
                                            ),
                                          ),
                                        ),
                                        Align(
                                          alignment: Alignment.center,
                                          child: SizedBox(
                                            height: 30,
                                            width: 30,
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.only(top: 2),
                                              child: FloatingActionButton(
                                                backgroundColor: ColorConfig
                                                    .dark
                                                    .withOpacity(0.8),
                                                elevation: 2,
                                                onPressed: () {
                                                  double val =
                                                      dragUpDown == true
                                                          ? 0.7
                                                          : 0.3;
                                                  dragControllerLeave
                                                      .jumpTo(val);
                                                  dragControllerLeave.animateTo(
                                                    val,
                                                    duration: const Duration(
                                                        milliseconds: 100),
                                                    curve: Curves.easeInBack,
                                                  );
                                                },
                                                child: Icon(
                                                  dragUpDown == true
                                                      ? Icons.arrow_upward
                                                      : Icons.arrow_downward,
                                                  size: 16,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 5,
                                          child: Align(
                                            alignment: Alignment.centerRight,
                                            child: Visibility(
                                              visible: !ceo,
                                              child: FilterChip(
                                                elevation: 1,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(7)),
                                                ),
                                                // visualDensity: VisualDensity.compact,
                                                avatar: Icon(
                                                  Icons.add,
                                                  color: Colors.white,
                                                ),
                                                label: Text(
                                                  'Add',
                                                  textAlign: TextAlign.start,
                                                  maxLines: 1,
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.bold,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                                backgroundColor: ColorConfig
                                                    .dark
                                                    .withOpacity(0.8),
                                                materialTapTargetSize:
                                                    MaterialTapTargetSize
                                                        .shrinkWrap,
                                                onSelected: (value) async {
                                                  dtRangeController
                                                      .selectedRange = null;
                                                  final add =
                                                      await _showAddLeaveBottomSheet(
                                                          sfctx);

                                                  setStateAddLeave = null;

                                                  if (add == null ||
                                                      add.isEmpty) {
                                                    return;
                                                  } else {
                                                    ScaffoldMessenger.of(
                                                        _leaveScaffoldKey
                                                            .currentState!
                                                            .context)
                                                      ..hideCurrentSnackBar()
                                                      ..showSnackBar(
                                                        SnackBar(
                                                          key: Key(
                                                              'LA_${DateTime.now().toString()}'),
                                                          elevation: 0,
                                                          behavior:
                                                              SnackBarBehavior
                                                                  .floating,
                                                          backgroundColor:
                                                              Colors
                                                                  .transparent,
                                                          content:
                                                              AwesomeSnackbarContent(
                                                            title:
                                                                Config.appName,
                                                            message:
                                                                'Leave Applied Successfully.',
                                                            contentType:
                                                                ContentType
                                                                    .success,
                                                          ),
                                                        ),
                                                      );

                                                    setState(() {
                                                      submitPressed = false;
                                                      leavelistResult = false;
                                                      dragUpDown = true;
                                                      leavedata = [];
                                                    });

                                                    setStateLeave!(() {});
                                                    // await Future.delayed(const Duration(seconds: 2), () {});
                                                    await getLeaveData(sfctx);

                                                    setState(() {
                                                      initialRefresh = true;
                                                    });

                                                    refreshController
                                                        .requestRefresh();
                                                  }
                                                },
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Visibility(
                                    visible: leavelistResult == false,
                                    child: const Expanded(
                                      flex: 12,
                                      child: Center(
                                        child: CircularProgressIndicator(
                                          backgroundColor: Colors.white,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                  Colors.blue),
                                          strokeWidth: 4,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Visibility(
                                    visible: leavelistResult == true &&
                                        leavedata.isEmpty,
                                    child: const Expanded(
                                      flex: 12,
                                      child: Center(
                                        child: Text(
                                          'Leave not taken yet!',
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.normal,
                                              color: Colors.black),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Visibility(
                                    visible: leavelistResult == true &&
                                        leavedata.isNotEmpty,
                                    child: Expanded(
                                      flex: 12,
                                      child: SingleChildScrollView(
                                        controller: scrollController,
                                        // physics: const AlwaysScrollableScrollPhysics(),
                                        // padding: EdgeInsets.only(right: 10),
                                        child: SlidableAutoCloseBehavior(
                                          child: ListView.separated(
                                            itemCount: leavedata.length,
                                            shrinkWrap: true,
                                            physics:
                                                const NeverScrollableScrollPhysics(),
                                            scrollDirection: Axis.vertical,
                                            // padding: const EdgeInsets.only(right: 10),
                                            separatorBuilder:
                                                (context, index) =>
                                                    const Divider(
                                              height: 0,
                                            ),
                                            itemBuilder: (context, index) {
                                              final data = leavedata[index];

                                              return Slidable(
                                                key: Key(
                                                    'Slide_${data.RECORD_ID}'),
                                                groupTag: '1',
                                                enabled: true,
                                                closeOnScroll: true,
                                                startActionPane:
                                                    data.STATUS != null ||
                                                            !admin
                                                        ? null
                                                        : ActionPane(
                                                            motion:
                                                                const StretchMotion(),
                                                            dragDismissible:
                                                                false,
                                                            extentRatio: 0.25,
                                                            children: [
                                                              SlidableAction(
                                                                key: Key(
                                                                    'Approve_${data.RECORD_ID}'),
                                                                backgroundColor:
                                                                    Colors
                                                                        .green,
                                                                icon: Icons
                                                                    .approval,
                                                                label:
                                                                    'Approve',
                                                                autoClose:
                                                                    false,
                                                                onPressed:
                                                                    (context) async {
                                                                  remarksController
                                                                      .text = '';

                                                                  await AwesomeDialog(
                                                                    context:
                                                                        sfctx,
                                                                    dialogType:
                                                                        DialogType
                                                                            .question,
                                                                    animType:
                                                                        AnimType
                                                                            .scale,
                                                                    showCloseIcon:
                                                                        true,
                                                                    keyboardAware:
                                                                        true,
                                                                    title:
                                                                        'Leave Approval',
                                                                    desc:
                                                                        'Are you sure you want to approve this leave application?',
                                                                    btnCancelOnPress:
                                                                        () {
                                                                      Slidable.of(
                                                                              context)
                                                                          ?.close();
                                                                      setStateLeave!(
                                                                          () {
                                                                        actionOnLeaveClicked =
                                                                            false;
                                                                      });
                                                                    },
                                                                    onDismissCallback:
                                                                        (type) {
                                                                      Slidable.of(
                                                                              context)
                                                                          ?.close();
                                                                      setStateLeave!(
                                                                          () {
                                                                        actionOnLeaveClicked =
                                                                            false;
                                                                      });
                                                                    },
                                                                    btnOkOnPress:
                                                                        () {
                                                                      setStateLeave!(
                                                                          () {
                                                                        actionOnLeaveClicked =
                                                                            true;
                                                                      });
                                                                    },
                                                                    btnOkIcon:
                                                                        Icons
                                                                            .check,
                                                                    padding:
                                                                        const EdgeInsets
                                                                            .all(
                                                                            20),
                                                                    barrierColor: ColorConfig
                                                                        .darkMain
                                                                        .withOpacity(
                                                                            0.6),
                                                                    titleTextStyle: const TextStyle(
                                                                        color: Colors
                                                                            .black,
                                                                        fontSize:
                                                                            20,
                                                                        fontWeight:
                                                                            FontWeight.w700),
                                                                    descTextStyle: const TextStyle(
                                                                        color: Colors
                                                                            .black,
                                                                        fontSize:
                                                                            14,
                                                                        fontWeight:
                                                                            FontWeight.normal),
                                                                    dialogBackgroundColor:
                                                                        Colors
                                                                            .white,
                                                                    body:
                                                                        Padding(
                                                                      padding: const EdgeInsets
                                                                          .all(
                                                                          8.0),
                                                                      child:
                                                                          Column(
                                                                        children: <Widget>[
                                                                          Text(
                                                                            'Leave Approval',
                                                                            style: const TextStyle(
                                                                                color: Colors.black,
                                                                                fontSize: 20,
                                                                                fontWeight: FontWeight.w700),
                                                                          ),
                                                                          const SizedBox(
                                                                            height:
                                                                                20,
                                                                          ),
                                                                          Text(
                                                                            'Are you sure you want to approve this leave application?',
                                                                            textAlign:
                                                                                TextAlign.center,
                                                                            style: const TextStyle(
                                                                                color: Colors.black,
                                                                                fontSize: 14,
                                                                                fontWeight: FontWeight.normal),
                                                                          ),
                                                                          const SizedBox(
                                                                            height:
                                                                                20,
                                                                          ),
                                                                          InputTextFieldV1(
                                                                            controller:
                                                                                remarksController,
                                                                            labelText:
                                                                                "Remarks",
                                                                            hintText:
                                                                                "Remarks",
                                                                            autovalidateMode:
                                                                                AutovalidateMode.onUserInteraction,
                                                                            prefixIcon:
                                                                                const Padding(
                                                                              padding: EdgeInsets.only(left: 10, top: 5),
                                                                              child: FaIcon(
                                                                                FontAwesomeIcons.clipboard,
                                                                                size: 24,
                                                                              ),
                                                                            ),
                                                                            textFocus:
                                                                                purposeFocus,
                                                                            autofocus:
                                                                                false,
                                                                            sufixIcon:
                                                                                false,
                                                                            displaylines:
                                                                                2,
                                                                            isDark:
                                                                                false,
                                                                            maxLength:
                                                                                250,
                                                                            textType:
                                                                                TextCapitalization.words,
                                                                            inputType:
                                                                                TextInputType.multiline,
                                                                            textValueSetter:
                                                                                (value) {},
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  ).show();

                                                                  if (actionOnLeaveClicked ==
                                                                      true) {
                                                                    final progress =
                                                                        ProgressHUD.of(
                                                                            pHUDcontext);

                                                                    progress
                                                                        ?.show();
                                                                    var action =
                                                                        await actionOnLeave(
                                                                            sfctx,
                                                                            data,
                                                                            'APPROVED');

                                                                    setStateLeave!(
                                                                        () {
                                                                      actionOnLeaveClicked =
                                                                          false;
                                                                    });

                                                                    progress
                                                                        ?.dismiss();

                                                                    if (action ==
                                                                        true) {
                                                                      ScaffoldMessenger.of(
                                                                          sfctx)
                                                                        ..hideCurrentSnackBar()
                                                                        ..showSnackBar(
                                                                          SnackBar(
                                                                            key:
                                                                                Key('LA_${DateTime.now().toString()}'),
                                                                            elevation:
                                                                                0,
                                                                            behavior:
                                                                                SnackBarBehavior.floating,
                                                                            backgroundColor:
                                                                                Colors.transparent,
                                                                            content:
                                                                                AwesomeSnackbarContent(
                                                                              title: Config.appName,
                                                                              message: 'Leave Approved Successfully.',
                                                                              contentType: ContentType.success,
                                                                            ),
                                                                          ),
                                                                        );

                                                                      setState(
                                                                          () {
                                                                        leavelistResult =
                                                                            false;
                                                                        dragUpDown =
                                                                            true;
                                                                        leavedata =
                                                                            [];
                                                                      });

                                                                      setStateLeave!(
                                                                          () {});
                                                                      // await Future.delayed(const Duration(seconds: 2), () {});
                                                                      await getLeaveData(
                                                                          sfctx);

                                                                      setState(
                                                                          () {
                                                                        initialRefresh =
                                                                            true;
                                                                      });

                                                                      refreshController
                                                                          .requestRefresh();
                                                                    }
                                                                  }
                                                                },
                                                              ),
                                                            ],
                                                          ),
                                                endActionPane:
                                                    data.STATUS == 'CANCELLED'
                                                        ? null
                                                        : ActionPane(
                                                            motion:
                                                                const BehindMotion(),
                                                            dragDismissible:
                                                                false,
                                                            extentRatio: 0.25,
                                                            children: [
                                                              SlidableAction(
                                                                key: Key(
                                                                    'Delete_${data.RECORD_ID}'),
                                                                backgroundColor:
                                                                    Colors.red,
                                                                icon: Icons
                                                                    .cancel,
                                                                autoClose:
                                                                    false,
                                                                label: 'Cancel',
                                                                onPressed:
                                                                    (context) async {
                                                                  if (data.STATUS !=
                                                                      'CANCELLED') {
                                                                    remarksController
                                                                        .text = '';

                                                                    await AwesomeDialog(
                                                                      context:
                                                                          context,
                                                                      dialogType:
                                                                          DialogType
                                                                              .question,
                                                                      animType:
                                                                          AnimType
                                                                              .scale,
                                                                      showCloseIcon:
                                                                          true,
                                                                      keyboardAware:
                                                                          true,
                                                                      title:
                                                                          'Leave Cancellation',
                                                                      desc:
                                                                          'Are you sure you want to cancel this leave application?',
                                                                      btnCancelOnPress:
                                                                          () {
                                                                        Slidable.of(context)
                                                                            ?.close();
                                                                        setStateLeave!(
                                                                            () {
                                                                          actionOnLeaveClicked =
                                                                              false;
                                                                        });
                                                                      },
                                                                      onDismissCallback:
                                                                          (type) {
                                                                        Slidable.of(context)
                                                                            ?.close();
                                                                        setStateLeave!(
                                                                            () {
                                                                          actionOnLeaveClicked =
                                                                              false;
                                                                        });
                                                                      },
                                                                      btnOkOnPress:
                                                                          () async {
                                                                        setStateLeave!(
                                                                            () {
                                                                          actionOnLeaveClicked =
                                                                              true;
                                                                        });
                                                                      },
                                                                      btnOkIcon:
                                                                          Icons
                                                                              .check,
                                                                      padding: const EdgeInsets
                                                                          .all(
                                                                          20),
                                                                      barrierColor: ColorConfig
                                                                          .darkMain
                                                                          .withOpacity(
                                                                              0.6),
                                                                      titleTextStyle: const TextStyle(
                                                                          color: Colors
                                                                              .black,
                                                                          fontSize:
                                                                              20,
                                                                          fontWeight:
                                                                              FontWeight.w700),
                                                                      descTextStyle: const TextStyle(
                                                                          color: Colors
                                                                              .black,
                                                                          fontSize:
                                                                              14,
                                                                          fontWeight:
                                                                              FontWeight.normal),
                                                                      dialogBackgroundColor:
                                                                          Colors
                                                                              .white,
                                                                      body:
                                                                          Padding(
                                                                        padding: const EdgeInsets
                                                                            .all(
                                                                            8.0),
                                                                        child:
                                                                            Column(
                                                                          children: <Widget>[
                                                                            Text(
                                                                              'Leave Cancellation',
                                                                              style: const TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.w700),
                                                                            ),
                                                                            const SizedBox(
                                                                              height: 20,
                                                                            ),
                                                                            Text(
                                                                              'Are you sure you want to cancel this leave application?',
                                                                              textAlign: TextAlign.center,
                                                                              style: const TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.normal),
                                                                            ),
                                                                            const SizedBox(
                                                                              height: 20,
                                                                            ),
                                                                            InputTextFieldV1(
                                                                              controller: remarksController,
                                                                              labelText: "Remarks",
                                                                              hintText: "Remarks",
                                                                              autovalidateMode: AutovalidateMode.onUserInteraction,
                                                                              prefixIcon: const Padding(
                                                                                padding: EdgeInsets.only(left: 10, top: 5),
                                                                                child: FaIcon(
                                                                                  FontAwesomeIcons.clipboard,
                                                                                  size: 24,
                                                                                ),
                                                                              ),
                                                                              textFocus: purposeFocus,
                                                                              autofocus: false,
                                                                              sufixIcon: false,
                                                                              displaylines: 2,
                                                                              isDark: false,
                                                                              maxLength: 250,
                                                                              textType: TextCapitalization.words,
                                                                              inputType: TextInputType.multiline,
                                                                              textValueSetter: (value) {},
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                    ).show();

                                                                    if (actionOnLeaveClicked ==
                                                                        true) {
                                                                      final progress =
                                                                          ProgressHUD.of(
                                                                              pHUDcontext);

                                                                      progress
                                                                          ?.show();
                                                                      var action = await actionOnLeave(
                                                                          sfctx,
                                                                          data,
                                                                          'CANCELLED');

                                                                      setStateLeave!(
                                                                          () {
                                                                        actionOnLeaveClicked =
                                                                            false;
                                                                      });

                                                                      progress
                                                                          ?.dismiss();

                                                                      if (action ==
                                                                          true) {
                                                                        ScaffoldMessenger.of(
                                                                            sfctx)
                                                                          ..hideCurrentSnackBar()
                                                                          ..showSnackBar(
                                                                            SnackBar(
                                                                              key: Key('LC_${DateTime.now().toString()}'),
                                                                              elevation: 0,
                                                                              behavior: SnackBarBehavior.floating,
                                                                              backgroundColor: Colors.transparent,
                                                                              content: AwesomeSnackbarContent(
                                                                                title: Config.appName,
                                                                                message: 'Leave Cancelled Successfully.',
                                                                                contentType: ContentType.success,
                                                                              ),
                                                                            ),
                                                                          );

                                                                        setState(
                                                                            () {
                                                                          leavelistResult =
                                                                              false;
                                                                          dragUpDown =
                                                                              true;
                                                                          leavedata =
                                                                              [];
                                                                        });

                                                                        setStateLeave!(
                                                                            () {});
                                                                        // await Future.delayed(const Duration(seconds: 2), () {});
                                                                        await getLeaveData(
                                                                            sfctx);

                                                                        setState(
                                                                            () {
                                                                          initialRefresh =
                                                                              true;
                                                                        });

                                                                        refreshController
                                                                            .requestRefresh();
                                                                      }
                                                                    }
                                                                  } else {
                                                                    await awesomePopup(
                                                                            context,
                                                                            "Leave application is already cancelled!",
                                                                            'Action Denied!',
                                                                            'error')
                                                                        .show();
                                                                    Slidable.of(
                                                                            context)
                                                                        ?.close();
                                                                    setStateLeave!(
                                                                        () {
                                                                      actionOnLeaveClicked =
                                                                          false;
                                                                    });
                                                                  }
                                                                },
                                                              ),
                                                            ],
                                                          ),
                                                child: Card(
                                                  key: Key(data.RECORD_ID
                                                      .toString()),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            7),
                                                  ),
                                                  color: Colors.white,
                                                  elevation: 4,
                                                  child: Stack(
                                                    children: [
                                                      ListTile(
                                                        key: Key(
                                                            'LT${data.RECORD_ID.toString()}'),
                                                        // contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: -25),
                                                        // contentPadding: const EdgeInsets.fromLTRB(5, -10, 0, 0),
                                                        contentPadding:
                                                            const EdgeInsets
                                                                .only(
                                                          left: 5,
                                                          // right: 5,
                                                        ),
                                                        isThreeLine: false,
                                                        horizontalTitleGap: 0,
                                                        minVerticalPadding:
                                                            -1.5,
                                                        // dense: true,
                                                        leading: CircleAvatar(
                                                          radius: 11,
                                                          backgroundColor: data
                                                                      .SEQUENCE !=
                                                                  null
                                                              ? ColorConfig.dark
                                                                  .withOpacity(
                                                                      0.8)
                                                              : Colors.white,
                                                          child: Text(
                                                              data.SEQUENCE
                                                                  .toString(),
                                                              style: const TextStyle(
                                                                  fontSize: 12,
                                                                  color: Colors
                                                                      .white)),
                                                        ),
                                                        minLeadingWidth: 18,
                                                        // tileColor: Colors.blueAccent,
                                                        title: SizedBox(
                                                          height: 60,
                                                          width:
                                                              double.maxFinite,
                                                          child: Padding(
                                                            padding:
                                                                EdgeInsets.only(
                                                                    left: 10,
                                                                    right: 10,
                                                                    top: 0),
                                                            child: Column(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceEvenly,
                                                              children: [
                                                                Row(
                                                                  children: <Widget>[
                                                                    Expanded(
                                                                        child: Divider(
                                                                            thickness:
                                                                                1,
                                                                            height:
                                                                                0.5,
                                                                            color: data.STATUS == 'CANCELLED'
                                                                                ? Colors.red
                                                                                : Colors.grey)),
                                                                    Text(
                                                                      '${DateFormat("dd-MMM-yy").format(data.FROM_DATE)} [${data.FROM_HALF == null ? "F" : data.FROM_HALF == false ? "FH" : "SH"}]',
                                                                      style: TextStyle(
                                                                          color: data.STATUS == 'CANCELLED'
                                                                              ? Colors.red
                                                                              : Colors.black,
                                                                          fontSize: 12),
                                                                    ),
                                                                    Expanded(
                                                                        child: Divider(
                                                                            thickness:
                                                                                1,
                                                                            height:
                                                                                0.5,
                                                                            color: data.STATUS == 'CANCELLED'
                                                                                ? Colors.red
                                                                                : Colors.grey)),
                                                                    SizedBox(
                                                                      height:
                                                                          15,
                                                                      child:
                                                                          FilterChip(
                                                                        elevation:
                                                                            1,
                                                                        labelPadding:
                                                                            EdgeInsets.only(top: -6),
                                                                        shape:
                                                                            RoundedRectangleBorder(
                                                                          borderRadius:
                                                                              BorderRadius.all(Radius.circular(4)),
                                                                        ),
                                                                        visualDensity:
                                                                            VisualDensity.compact,
                                                                        label:
                                                                            Text(
                                                                          '${data.DAYS} day(s)',
                                                                          textAlign:
                                                                              TextAlign.start,
                                                                          maxLines:
                                                                              1,
                                                                          style:
                                                                              const TextStyle(
                                                                            color:
                                                                                Colors.white,
                                                                            fontSize:
                                                                                12,
                                                                            fontWeight:
                                                                                FontWeight.normal,
                                                                            overflow:
                                                                                TextOverflow.ellipsis,
                                                                          ),
                                                                        ),
                                                                        backgroundColor: data.STATUS ==
                                                                                'CANCELLED'
                                                                            ? Colors.red
                                                                            : ColorConfig.dark.withOpacity(0.8),
                                                                        materialTapTargetSize:
                                                                            MaterialTapTargetSize.shrinkWrap,
                                                                        onSelected:
                                                                            (value) {},
                                                                      ),
                                                                    ),
                                                                    Expanded(
                                                                        child: Divider(
                                                                            thickness:
                                                                                1,
                                                                            height:
                                                                                0.5,
                                                                            color: data.STATUS == 'CANCELLED'
                                                                                ? Colors.red
                                                                                : Colors.grey)),
                                                                    Text(
                                                                      '${DateFormat("dd-MMM-yy").format(data.TO_DATE)} [${data.TO_HALF == null ? "F" : data.TO_HALF == false ? "FH" : "SH"}]',
                                                                      style: TextStyle(
                                                                          color: data.STATUS == 'CANCELLED'
                                                                              ? Colors.red
                                                                              : Colors.black,
                                                                          fontSize: 12),
                                                                    ),
                                                                    Expanded(
                                                                        child: Divider(
                                                                            thickness:
                                                                                1,
                                                                            height:
                                                                                0.5,
                                                                            color: data.STATUS == 'CANCELLED'
                                                                                ? Colors.red
                                                                                : Colors.grey)),
                                                                  ],
                                                                ),
                                                                // SizedBox(
                                                                //   height: 2,
                                                                // ),
                                                                GestureDetector(
                                                                  onTap: () {
                                                                    awesomePopup(
                                                                            context,
                                                                            '${data.PURPOSE}\n\nApplied On: ${DateFormat("dd-MMM-yy HH:mm:ss").format(data.APPLY_DATE)}',
                                                                            'Leave Purpose',
                                                                            'info')
                                                                        .show();
                                                                  },
                                                                  child: Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .center,
                                                                    children: [
                                                                      FaIcon(
                                                                        FontAwesomeIcons
                                                                            .penToSquare,
                                                                        color: data.STATUS ==
                                                                                'CANCELLED'
                                                                            ? Colors.red
                                                                            : Colors.black,
                                                                        size:
                                                                            14,
                                                                      ),
                                                                      SizedBox(
                                                                        width:
                                                                            2,
                                                                      ),
                                                                      Text(
                                                                        data.PURPOSE
                                                                            .split('\n')[0],
                                                                        maxLines:
                                                                            1,
                                                                        overflow:
                                                                            TextOverflow.ellipsis,
                                                                        style: TextStyle(
                                                                            color: data.STATUS == 'CANCELLED'
                                                                                ? Colors.red
                                                                                : Colors.black,
                                                                            fontSize: 12),
                                                                      ),
                                                                      Visibility(
                                                                        visible: data
                                                                            .PURPOSE
                                                                            .contains('\n'),
                                                                        child:
                                                                            Padding(
                                                                          padding: const EdgeInsets
                                                                              .only(
                                                                              left: 5),
                                                                          child:
                                                                              FaIcon(
                                                                            FontAwesomeIcons.arrowTurnDown,
                                                                            size:
                                                                                10,
                                                                            color: data.STATUS == 'CANCELLED'
                                                                                ? Colors.red
                                                                                : Colors.black,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                                Visibility(
                                                                  visible:
                                                                      data.NOTES !=
                                                                          null,
                                                                  child:
                                                                      GestureDetector(
                                                                    onTap: () {
                                                                      if (data.STATUS ==
                                                                          'APPROVED') {
                                                                        awesomePopup(
                                                                                context,
                                                                                '${data.NOTES ?? ''}\n\nApproved By\n${data.APPROVE_BY}\n${DateFormat("dd-MMM-yy HH:mm:ss").format(data.APPROVE_DATE!)}',
                                                                                'Leave Approval Note!',
                                                                                'success')
                                                                            .show();
                                                                      } else {
                                                                        awesomePopup(
                                                                                context,
                                                                                '${data.NOTES ?? ''}\n\nCancelled By\n${data.APPROVE_BY}\n${DateFormat("dd-MMM-yy HH:mm:ss").format(data.APPROVE_DATE!)}',
                                                                                'Leave Cancellation Note!',
                                                                                'error')
                                                                            .show();
                                                                      }
                                                                    },
                                                                    child: Row(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .center,
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .center,
                                                                      children: [
                                                                        FaIcon(
                                                                          FontAwesomeIcons
                                                                              .commentDots,
                                                                          color: data.STATUS == 'CANCELLED'
                                                                              ? Colors.red
                                                                              : Colors.green.shade700,
                                                                          size:
                                                                              14,
                                                                        ),
                                                                        SizedBox(
                                                                          width:
                                                                              2,
                                                                        ),
                                                                        Flexible(
                                                                          child:
                                                                              Text(
                                                                            data.NOTES == null
                                                                                ? ''
                                                                                : data.NOTES!.split('\n')[0],
                                                                            maxLines:
                                                                                1,
                                                                            style:
                                                                                TextStyle(
                                                                              color: data.STATUS == 'CANCELLED' ? Colors.red : Colors.green.shade700,
                                                                              fontSize: 12,
                                                                              overflow: TextOverflow.ellipsis,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        Visibility(
                                                                          visible:
                                                                              (data.NOTES ?? '').contains('\n'),
                                                                          child:
                                                                              Padding(
                                                                            padding:
                                                                                const EdgeInsets.only(left: 5),
                                                                            child:
                                                                                FaIcon(
                                                                              FontAwesomeIcons.arrowTurnDown,
                                                                              size: 10,
                                                                              color: data.STATUS == 'CANCELLED' ? Colors.red : Colors.green.shade700,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                        trailing: InkWell(
                                                          highlightColor: Colors
                                                              .orange
                                                              .withOpacity(
                                                                  0.3), // static color
                                                          splashColor: Colors
                                                              .lightBlue, // animating color
                                                          onTap: () async {
                                                            await Future.delayed(
                                                                const Duration(
                                                                    milliseconds:
                                                                        500),
                                                                () {});

                                                            if (data.STATUS ==
                                                                null) {
                                                              awesomePopup(
                                                                      context,
                                                                      '',
                                                                      'Approval Due!',
                                                                      'warning')
                                                                  .show();
                                                            } else if (data
                                                                    .STATUS ==
                                                                'APPROVED') {
                                                              awesomePopup(
                                                                      context,
                                                                      '${data.NOTES ?? ''}\n\nApproved By\n${data.APPROVE_BY}\n${DateFormat("dd-MMM-yy HH:mm:ss").format(data.APPROVE_DATE!)}',
                                                                      'Leave Approval Note!',
                                                                      'success')
                                                                  .show();
                                                            } else {
                                                              awesomePopup(
                                                                      context,
                                                                      '${data.NOTES ?? ''}\n\nCancelled By\n${data.APPROVE_BY}\n${DateFormat("dd-MMM-yy HH:mm:ss").format(data.APPROVE_DATE!)}',
                                                                      'Leave Cancellation Note!',
                                                                      'error')
                                                                  .show();
                                                            }
                                                          },
                                                          child: Container(
                                                            decoration:
                                                                BoxDecoration(
                                                                    color: data.STATUS ==
                                                                            null
                                                                        ? Colors
                                                                            .yellow
                                                                            .shade900
                                                                        : data.STATUS ==
                                                                                'CANCELLED'
                                                                            ? Colors
                                                                                .red.shade600
                                                                            : Colors
                                                                                .green.shade600,
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .only(
                                                                      topRight:
                                                                          Radius.circular(
                                                                              7),
                                                                      bottomRight:
                                                                          Radius.circular(
                                                                              7),
                                                                    )),
                                                            height:
                                                                double.infinity,
                                                            width: 22,
                                                            child:
                                                                SingleChildScrollView(
                                                              scrollDirection:
                                                                  Axis.vertical,
                                                              child: Column(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .spaceAround,
                                                                children: [
                                                                  SizedBox(
                                                                    height: 2,
                                                                  ),
                                                                  CircleAvatar(
                                                                    maxRadius:
                                                                        8,
                                                                    backgroundColor:
                                                                        Colors
                                                                            .white,
                                                                    child:
                                                                        FaIcon(
                                                                      data.STATUS ==
                                                                              null
                                                                          ? FontAwesomeIcons
                                                                              .triangleExclamation
                                                                          : data.STATUS == 'CANCELLED'
                                                                              ? FontAwesomeIcons.xmark
                                                                              : FontAwesomeIcons.check,
                                                                      size: 12,
                                                                      color: data.STATUS ==
                                                                              null
                                                                          ? Colors
                                                                              .yellow
                                                                              .shade900
                                                                          : data.STATUS == 'CANCELLED'
                                                                              ? Colors.red.shade600
                                                                              : Colors.green.shade600,
                                                                    ),
                                                                  ),
                                                                  SizedBox(
                                                                    height: 1,
                                                                  ),
                                                                  RotatedBox(
                                                                    quarterTurns:
                                                                        5,
                                                                    child:
                                                                        Padding(
                                                                      padding: const EdgeInsets
                                                                          .only(
                                                                          top:
                                                                              3),
                                                                      child:
                                                                          Text(
                                                                        data.STATUS ==
                                                                                null
                                                                            ? 'Pending'
                                                                            : data.STATUS == 'CANCELLED'
                                                                                ? 'Cancelled'
                                                                                : 'Approved',
                                                                        maxLines:
                                                                            1,
                                                                        textAlign:
                                                                            TextAlign.center,
                                                                        style:
                                                                            TextStyle(
                                                                          fontSize: data.STATUS == null
                                                                              ? 9.5
                                                                              : 8,
                                                                          fontWeight:
                                                                              FontWeight.normal,
                                                                          overflow:
                                                                              TextOverflow.ellipsis,
                                                                          color:
                                                                              Colors.white,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                  );
                });
              },
            ),
          );

  Future<String?> _showAddLeaveBottomSheet(BuildContext context) async {
    PickerDateRange? pr;
    final List<DateTime>? specialDates;

    setState(() {
      purposeController.text = '';
      fromDate = null;
      toDate = null;
      fromHalf = null;
      toHalf = null;
      submitPressed = false;
      saveLeaveClicked = false;
    });

    specialDates = vecationdata.map((e) => e.DT_DATE).toList();

    return await showModalBottomSheet(
      isScrollControlled: true, // required for min/max child size
      elevation: 10,
      barrierColor: ColorConfig.darkMain.withOpacity(0.6),
      backgroundColor: Colors.white,
      isDismissible: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(15.0),
        ),
      ),
      context: context,
      builder: (ctx) {
        return Form(
          key: globalFormKeyLeaveAdd,
          child: StatefulBuilder(
              builder: (BuildContext context, StateSetter setStateLA) {
            setStateAddLeave = setStateLA;

            return Padding(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom),
              child: SizedBox(
                height: MediaQuery.of(context).size.height - 300,
                // width: MediaQuery.of(context).size.width,
                width: double.maxFinite,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Visibility(
                      visible: saveLeaveClicked,
                      child: Center(
                        child: CircularProgressIndicator(
                          backgroundColor: Colors.grey.shade400,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.blue),
                          strokeWidth: 4,
                        ),
                      ),
                    ),
                    Column(
                      children: [
                        Expanded(
                          flex: fromDate == null ? 2 : 3,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 10, right: 10),
                            child: SingleChildScrollView(
                              scrollDirection: Axis.vertical,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  InputTextFieldV1(
                                    controller: purposeController,
                                    labelText: "Purpose",
                                    hintText: "Purpose",
                                    errorText: (submitPressed == true)
                                        ? "Purpose can't be empty."
                                        : "",
                                    autovalidateMode: (submitPressed == true)
                                        ? AutovalidateMode.always
                                        : AutovalidateMode.onUserInteraction,
                                    prefixIcon: const Padding(
                                      padding:
                                          EdgeInsets.only(left: 10, top: 5),
                                      child: FaIcon(
                                        FontAwesomeIcons.clipboard,
                                        size: 24,
                                      ),
                                    ),
                                    textFocus: purposeFocus,
                                    autofocus: false,
                                    sufixIcon: false,
                                    displaylines: 1,
                                    // isDark: themeState.getDarkTheme,
                                    isDark: false,
                                    maxLength: 250,
                                    textType: TextCapitalization.words,
                                    inputType: TextInputType.multiline,
                                    textValueSetter: (value) {
                                      // supplieraddress = value;
                                    },
                                  ),
                                  Visibility(
                                    visible: fromDate != null,
                                    child: SizedBox(
                                      height: 10,
                                    ),
                                  ),
                                  Visibility(
                                    visible: fromDate != null,
                                    child: Row(
                                      // mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: <Widget>[
                                        Expanded(
                                          child: SelectionPopup(
                                            focus: fromHalfFocus,
                                            isDark: false,
                                            label: fromDate ?? 'From Type',
                                            data: const [
                                              'Full Day',
                                              'First Half',
                                              'Second Half'
                                            ],
                                            initValue: 'Full Day',
                                            // errorText: (submitPressed == true) ? "Gender can't be empty." : "",
                                            errorText:
                                                "From half can't be empty.",
                                            textValueSetter: (value) => {
                                              setState(() {
                                                fromHalf = value;
                                              })
                                            },
                                          ),
                                        ),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        Expanded(
                                          child: SelectionPopup(
                                            focus: toHalfFocus,
                                            isDark: false,
                                            label: toDate ?? 'To Type',
                                            data: const [
                                              'Full Day',
                                              'First Half',
                                              'Second Half'
                                            ],
                                            initValue: 'Full Day',
                                            // errorText: (submitPressed == true) ? "Gender can't be empty." : "",
                                            errorText:
                                                "To half can't be empty.",
                                            textValueSetter: (value) => {
                                              setState(() {
                                                toHalf = value;
                                              })
                                            },
                                          ),
                                        ),
                                        SizedBox(
                                          width: 30,
                                          child: IconButton(
                                            padding: EdgeInsets.only(top: 10),
                                            icon: const Icon(
                                              Icons.cancel,
                                              color: Colors.black,
                                            ),
                                            onPressed: () async {
                                              setState(() {
                                                dtRangeController
                                                    .selectedRange = pr;

                                                fromDate = null;
                                                toDate = null;
                                                fromHalf = null;
                                                toHalf = null;
                                              });

                                              setStateAddLeave!(() {});
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 10, right: 10, top: 5),
                          child: Row(children: <Widget>[
                            Expanded(
                                child: Divider(
                                    thickness: 1,
                                    height: 0.5,
                                    color: submitPressed == true &&
                                            fromDate == null
                                        ? Colors.red
                                        : Colors.grey)),
                            Text(" Select Range ",
                                style: TextStyle(
                                    color: submitPressed == true &&
                                            fromDate == null
                                        ? Colors.red
                                        : Colors.black,
                                    fontSize: 12)),
                            Expanded(
                                child: Divider(
                                    thickness: 1,
                                    height: 0.5,
                                    color: submitPressed == true &&
                                            fromDate == null
                                        ? Colors.red
                                        : Colors.grey)),
                          ]),
                        ),
                        Expanded(
                          flex: fromDate == null ? 11 : 9,
                          // height: 350,
                          child: SfDateRangePicker(
                            controller: dtRangeController,
                            onSelectionChanged:
                                (DateRangePickerSelectionChangedArgs args) {
                              if (args.value is PickerDateRange) {
                                final DateTime? startDate =
                                    args.value.startDate;
                                final DateTime? endDate =
                                    args.value.endDate ?? args.value.startDate;

                                setState(() {
                                  if (startDate != null && endDate != null) {
                                    fromDate = DateFormat("dd-MMM-yy")
                                        .format(startDate);
                                    toDate =
                                        DateFormat("dd-MMM-yy").format(endDate);

                                    fromHalf = 'Full Day';
                                    toHalf = 'Full Day';
                                  } else {
                                    fromDate = null;
                                    toDate = null;
                                    fromHalf = null;
                                    toHalf = null;
                                  }

                                  setStateAddLeave!(() {});
                                });
                              }
                            },
                            onSubmit: (Object? val) async {
                              setState(() {
                                FocusManager.instance.primaryFocus?.unfocus();
                                submitPressed = true;
                              });

                              var value = await submitLeave(context);

                              setStateAddLeave!(() {
                                saveLeaveClicked = false;
                              });

                              if (value == true) {
                                Navigator.of(context).pop('Success');
                              }
                            },
                            onCancel: () {
                              FocusManager.instance.primaryFocus?.unfocus();
                              dtRangeController.selectedRange = pr;
                              Navigator.pop(context);
                            },
                            showActionButtons: !saveLeaveClicked,
                            showTodayButton: !saveLeaveClicked,
                            toggleDaySelection: true,
                            view: DateRangePickerView.month,
                            selectionShape:
                                DateRangePickerSelectionShape.rectangle,
                            // selectionColor: Colors.blue,
                            todayHighlightColor: Colors.blue,
                            showNavigationArrow: true,
                            monthViewSettings: DateRangePickerMonthViewSettings(
                              firstDayOfWeek: 1,
                              showWeekNumber: true,
                              showTrailingAndLeadingDates: false,
                              weekNumberStyle: DateRangePickerWeekNumberStyle(
                                textStyle: const TextStyle(color: Colors.black),
                                backgroundColor: Colors.grey.shade300,
                              ),
                              viewHeaderStyle:
                                  const DateRangePickerViewHeaderStyle(
                                      // backgroundColor: Colors.red,
                                      textStyle:
                                          TextStyle(color: Colors.black)),
                              specialDates: specialDates,
                            ),
                            selectionMode:
                                DateRangePickerSelectionMode.extendableRange,
                            initialSelectedRange: pr,
                            headerStyle: const DateRangePickerHeaderStyle(
                              textStyle: TextStyle(color: Colors.black),
                            ),
                            selectionTextStyle: const TextStyle(
                                fontStyle: FontStyle.normal,
                                fontWeight: FontWeight.w500,
                                fontSize: 12,
                                color: Colors.white),
                            rangeTextStyle: const TextStyle(
                                fontStyle: FontStyle.italic,
                                fontWeight: FontWeight.w500,
                                fontSize: 12,
                                color: Colors.black),
                            rangeSelectionColor:
                                Colors.purpleAccent.withOpacity(0.4),
                            endRangeSelectionColor: Colors.purple,
                            startRangeSelectionColor: Colors.purple,
                            yearCellStyle: const DateRangePickerYearCellStyle(
                              textStyle: TextStyle(
                                  fontWeight: FontWeight.w400,
                                  fontSize: 15,
                                  color: Colors.black),
                              todayTextStyle: TextStyle(
                                  fontStyle: FontStyle.italic,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.red),
                            ),
                            monthCellStyle: DateRangePickerMonthCellStyle(
                                textStyle: const TextStyle(
                                    fontWeight: FontWeight.w400,
                                    fontSize: 15,
                                    color: Colors.black),
                                todayTextStyle: const TextStyle(
                                    fontStyle: FontStyle.italic,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.red),
                                // weekendTextStyle: TextStyle(fontStyle: FontStyle.italic, fontWeight: FontWeight.w500, fontSize: 12, color: Colors.green),

                                leadingDatesDecoration: BoxDecoration(
                                    color: const Color(0xFFDFDFDF),
                                    border: Border.all(
                                        color: const Color(0xFFB6B6B6),
                                        width: 1),
                                    shape: BoxShape.circle),
                                disabledDatesDecoration: BoxDecoration(
                                    color: const Color(0xFFDFDFDF)
                                        .withOpacity(0.2),
                                    border: Border.all(
                                        color: const Color(0xFFB6B6B6),
                                        width: 1),
                                    shape: BoxShape.circle),
                                // specialDatesTextStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.green),
                                specialDatesDecoration: BoxDecoration(
                                  color:
                                      const Color(0xFFDFDFDF).withOpacity(0.2),
                                  border:
                                      Border.all(color: Colors.green, width: 2),
                                  shape: BoxShape.circle,
                                )),
                            // backgroundColor: Colors.cyanAccent,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),
        );
      },
    );
  }

  Future<bool> validateAndSaveLeave() async {
    final form = globalFormKeyLeaveAdd.currentState;

    if (form!.validate() &&
        fromDate != null &&
        toDate != null &&
        fromHalf != null &&
        toHalf != null) {
      form.save();
      return true;
    }

    return false;
  }

  Future<bool> submitLeave(BuildContext context) async {
    if (await validateAndSaveLeave()) {
      setStateAddLeave!(() {
        saveLeaveClicked = true;
      });

      try {
        var dioObj = DioHelper();

        final params = <String, dynamic>{
          'system_name': deviceId,
          'emp_id': userdata[0].EMP_ID,
          'emp_name': userdata[0].EMP_NAME,
          'purpose': purposeController.text.replaceAll("'", "''"),
          'dt_from': DateFormat("yyyy-MM-dd")
              .format(dtRangeController.selectedRange!.startDate!),
          'dt_to': DateFormat("yyyy-MM-dd").format(
              dtRangeController.selectedRange!.endDate ??
                  dtRangeController.selectedRange!.startDate!),
        };

        if (fromHalf != 'Full Day') {
          params.addAll({'from_half': fromHalf});
        }

        if (toHalf != 'Full Day') {
          params.addAll({'to_half': toHalf});
        }

        final response = await dioObj.api.post(
          Config.leaveAddAPI,
          options: dio.Options(headers: {"requires-token": false}),
          queryParameters: params,
        );

        if (response.statusCode == 200) {
          // await awesomePopup(context, response.data['message'].toString(), 'Success', 'success').show();
          // if (kDebugMode) {
          //   print(response);
          // }
          // await Future.delayed(const Duration(seconds: 2), () {});

          return true;
        }
      } on DioException catch (e) {
        dioMessage(
            e,
            'Leave Application Failed!',
            '${Trace.from(StackTrace.current).frames[0].member} Line: ${Trace.from(StackTrace.current).frames[0].line}',
            context,
            true);
      } on Exception catch (e) {
        if (kDebugMode) {
          print('Leave Application Failed!: $e');
        }

        awesomePopup(
                context, e.toString(), 'Leave Application Failed!', 'error')
            .show();
      }
    } else {
      if (purposeController.text == '') {
        FocusScope.of(context).requestFocus(purposeFocus);
        return false;
      }
    }

    return false;
  }

  Future<bool> actionOnLeave(
      BuildContext context, Leave data, String status) async {
    try {
      var dioObj = DioHelper();

      final params = <String, dynamic>{
        'system_name': deviceId,
        'leave_id': data.RECORD_ID,
        'emp_id': userdata[0].EMP_ID,
        'emp_name': userdata[0].EMP_NAME,
        'approver': admin == false || (userdata[0].EMP_NAME == adminName)
            ? 'Self'
            : adminName,
        'status': status,
      };

      if (remarksController.text != '') {
        params.addAll({'notes': remarksController.text.replaceAll("'", "''")});
      }

      final response = await dioObj.api.post(
        Config.leaveActionAPI,
        options: dio.Options(headers: {"requires-token": false}),
        queryParameters: params,
      );

      if (response.statusCode == 200) {
        // await awesomePopup(context, response.data['message'].toString(), 'Success', 'success').show();
        // if (kDebugMode) {
        //   print(response);
        // }
        // await Future.delayed(const Duration(seconds: 2), () {});

        return true;
      }
    } on DioException catch (e) {
      dioMessage(
          e,
          'Leave ${status == "CANCELLED" ? "Cancellation" : "Approval"} Failed!',
          '${Trace.from(StackTrace.current).frames[0].member} Line: ${Trace.from(StackTrace.current).frames[0].line}',
          context,
          true);
    } on Exception catch (e) {
      if (kDebugMode) {
        print(
            'Leave ${status == "CANCELLED" ? "Cancellation" : "Approval"} Failed!: $e');
      }

      awesomePopup(
              context,
              e.toString(),
              'Leave ${status == "CANCELLED" ? "Cancellation" : "Approval"} Failed!',
              'error')
          .show();
    }

    return false;
  }

  Future<bool> getPunchData(BuildContext context, DateTime dtdate, int? punches,
      int? empid, String? empname) async {
    if (punches == null || punches == 0 || empid == null || empname == null) {
      return false;
    } else {
      setState(() {
        punchlistResult = false;
      });
    }

    final progress = ProgressHUD.of(context);

    progress?.show();

    try {
      var dioObj = DioHelper();

      final params = <String, dynamic>{
        'emp_id': empid,
        'emp_name': empname,
        'dt_date': DateFormat("yyyy-MM-dd").format(dtdate),
        'system_name': deviceId,
      };

      final response = await dioObj.api.get(
        Config.attendancePunchAPI,
        options: dio.Options(
          headers: {"requires-token": false},
          // validateStatus: (status) => true,
          // followRedirects: false,
        ),
        queryParameters: params,
      );

      setState(() {
        punchlistResult = true;
      });

      progress?.dismiss();

      if (response.data == null) {
        return false;
      }

      final result = PunchListingData.fromJson(response.data);

      if (result.data.isNotEmpty) {
        // var data = result.data.map((e) => "${DateFormat("hh:mm:ss a").format(e.DT_DATE)} ${e.PUNCH_TYPE ?? ''}").toList().join('\n');

        await AwesomeDialog(
          context: context,
          dialogType: DialogType.info,
          animType: AnimType.scale,
          showCloseIcon: true,
          keyboardAware: true,
          title: 'Punch Details',
          // desc: data,
          btnOkIcon: Icons.check,
          padding: const EdgeInsets.all(20),
          barrierColor: ColorConfig.darkMain.withOpacity(0.6),
          titleTextStyle: const TextStyle(
              color: Colors.black, fontSize: 20, fontWeight: FontWeight.w700),
          descTextStyle: const TextStyle(
              color: Colors.black, fontSize: 14, fontWeight: FontWeight.normal),
          dialogBackgroundColor: Colors.white,
          btnOkOnPress: () {},
          body: Column(
            children: <Widget>[
              Text(
                'Punch Details',
                style: const TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.w700),
              ),
              const SizedBox(
                height: 10,
              ),
              Text(
                empname,
                style: const TextStyle(
                    color: Colors.black,
                    fontSize: 12,
                    fontWeight: FontWeight.w700),
              ),
              const SizedBox(
                height: 10,
              ),
              Text(
                'On ${DateFormat("dd-MMM-yyyy").format(dtdate)}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                    fontWeight: FontWeight.normal),
              ),
              const SizedBox(
                height: 10,
              ),
              Padding(
                padding: const EdgeInsets.only(
                  left: 45,
                ),
                child: SingleChildScrollView(
                  // scrollDirection: Axis.vertical,
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height / 4,
                    child: ListView.builder(
                      itemCount: result.data.length,
                      shrinkWrap: true,
                      scrollDirection: Axis.vertical,
                      // padding: const EdgeInsets.only(right: 20),
                      itemBuilder: (context, index) {
                        final data = result.data[index];

                        return Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              DateFormat("hh:mm:ss a").format(data.DT_DATE),
                              style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 14,
                                  fontWeight: FontWeight.normal),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Icon(
                              data.PUNCH_TYPE != null
                                  ? Icons.check_circle
                                  : Icons.cancel,
                              size: 18,
                              color: data.PUNCH_TYPE == null
                                  ? Colors.red
                                  : Colors.green,
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Text(
                              data.PUNCH_TYPE ?? '',
                              style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 14,
                                  fontWeight: FontWeight.normal),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ).show();
      }

      return true;
    } on DioException catch (e) {
      progress?.dismiss();
      dioMessage(
          e,
          'Punch List Failed!',
          '${Trace.from(StackTrace.current).frames[0].member} Line: ${Trace.from(StackTrace.current).frames[0].line}',
          context,
          true);
    } on Exception catch (e) {
      progress?.dismiss();
      if (kDebugMode) {
        print('Failed to fetch punch list: $e');
      }

      // awesomePopup(context, e.toString(), 'Leave List Failed!', 'error').show();
    }

    setState(() {
      punchlistResult = true;
    });

    return false;
  }

  Future<bool> getAttendanceSummaryData(BuildContext context) async {
    setState(() {
      summarylistResult = false;
    });

    final progress = ProgressHUD.of(context);

    progress?.show();

    try {
      var dioObj = DioHelper();

      final params = <String, dynamic>{
        'emp_id': userdata[0].EMP_ID,
        'system_name': deviceId,
      };

      final response = await dioObj.api.get(
        Config.attendanceSummaryAPI,
        options: dio.Options(
          headers: {"requires-token": false},
          // validateStatus: (status) => true,
          // followRedirects: false,
        ),
        queryParameters: params,
      );

      setState(() {
        summarylistResult = true;
      });

      progress?.dismiss();

      if (response.data == null) {
        return false;
      }

      final result = SummaryListingData.fromJson(response.data);

      if (result.data.isNotEmpty) {
        // awesomePopup(context, 'Data Found', 'Data Found!', 'success').show();
        // var data = result.data.map((e) => "${DateFormat("hh:mm:ss a").format(e.DT_DATE)} ${e.PUNCH_TYPE ?? ''}").toList().join('\n');

        await AwesomeDialog(
          context: context,
          dialogType: DialogType.info,
          animType: AnimType.scale,
          showCloseIcon: true,
          keyboardAware: true,
          title: 'Attendance Summary',
          // desc: data,
          btnOkIcon: Icons.check,
          padding: const EdgeInsets.all(20),
          barrierColor: ColorConfig.darkMain.withOpacity(0.6),
          titleTextStyle: const TextStyle(
              color: Colors.black, fontSize: 20, fontWeight: FontWeight.w700),
          descTextStyle: const TextStyle(
              color: Colors.black, fontSize: 14, fontWeight: FontWeight.normal),
          dialogBackgroundColor: Colors.white,
          btnOkOnPress: () {},
          body: Column(
            // mainAxisAlignment: MainAxisAlignment.start,
            // mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Text('Attendance Summary',
                  style: const TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.w700)),
              const SizedBox(
                height: 20,
              ),
              Text(
                userdata[0].EMP_NAME ?? '',
                style: const TextStyle(
                    color: Colors.black,
                    fontSize: 12,
                    fontWeight: FontWeight.w700),
              ),
              const SizedBox(
                height: 10,
              ),
              Text(
                'As On ${DateFormat("dd-MMM-yyyy").format(DateTime.now())}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                    fontWeight: FontWeight.normal),
              ),
              Visibility(
                visible: half && result.halfsince != null,
                child: const SizedBox(
                  height: 5,
                ),
              ),
              Visibility(
                visible: half && result.halfsince != null,
                child: Container(
                  // alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(3.0)),
                    color: ColorConfig.dark.withOpacity(0.8),
                  ),
                  child: Text(' Half Day Available since ${result.halfsince} ',
                      style: TextStyle(fontSize: 14, color: Colors.white)),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: SizedBox(
                      height: 20,
                      width: double.infinity,
                      child: FilterChip(
                        elevation: 0,
                        labelPadding: EdgeInsets.only(top: -4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(4)),
                        ),
                        visualDensity: VisualDensity.compact,
                        label: Text(
                          'Year',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w500),
                        ),
                        backgroundColor: ColorConfig.dark.withOpacity(0.8),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        onSelected: (value) {},
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: SizedBox(
                      height: 20,
                      width: double.infinity,
                      child: FilterChip(
                        elevation: 0,
                        labelPadding: EdgeInsets.only(top: -4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(4)),
                        ),
                        visualDensity: VisualDensity.compact,
                        label: Text(
                          'Month',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w500),
                        ),
                        backgroundColor: ColorConfig.dark.withOpacity(0.8),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        onSelected: (value) {},
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: SizedBox(
                      height: 20,
                      width: double.infinity,
                      child: FilterChip(
                        elevation: 0,
                        labelPadding: EdgeInsets.only(top: -4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(4)),
                        ),
                        visualDensity: VisualDensity.compact,
                        label: Text(
                          'P',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w500),
                        ),
                        backgroundColor: ColorConfig.dark.withOpacity(0.8),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        onSelected: (value) {},
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: SizedBox(
                      height: 20,
                      width: double.infinity,
                      child: FilterChip(
                        elevation: 0,
                        labelPadding: EdgeInsets.only(top: -4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(4)),
                        ),
                        visualDensity: VisualDensity.compact,
                        label: Text(
                          'A',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w500),
                        ),
                        backgroundColor: ColorConfig.dark.withOpacity(0.8),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        onSelected: (value) {},
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: SizedBox(
                      height: 20,
                      width: double.infinity,
                      child: FilterChip(
                        elevation: 0,
                        labelPadding: EdgeInsets.only(top: -4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(4)),
                        ),
                        visualDensity: VisualDensity.compact,
                        label: Text(
                          'L',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w500),
                        ),
                        backgroundColor: ColorConfig.dark.withOpacity(0.8),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        onSelected: (value) {},
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: SizedBox(
                      height: 20,
                      width: double.infinity,
                      child: FilterChip(
                        elevation: 0,
                        labelPadding: EdgeInsets.only(top: -4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(4)),
                        ),
                        visualDensity: VisualDensity.compact,
                        label: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Text(
                              'WO',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 8,
                                  fontWeight: FontWeight.w500),
                            ),
                            Text(
                              'Ex',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 8,
                                  fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                        backgroundColor: Colors.red,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        onSelected: (value) {},
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: SizedBox(
                      height: 20,
                      width: double.infinity,
                      child: FilterChip(
                        elevation: 0,
                        labelPadding: EdgeInsets.only(top: -4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(4)),
                        ),
                        visualDensity: VisualDensity.compact,
                        label: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Text(
                              'HO',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 8,
                                  fontWeight: FontWeight.w500),
                            ),
                            Text(
                              'Ex',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 8,
                                  fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                        backgroundColor: Colors.red,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        onSelected: (value) {},
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(
                  left: 0,
                ),
                child: SingleChildScrollView(
                  // scrollDirection: Axis.vertical,
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height / 4,
                    child: ListView.builder(
                      itemCount: result.data.length,
                      shrinkWrap: true,
                      scrollDirection: Axis.vertical,
                      // padding: const EdgeInsets.only(right: 20),
                      itemBuilder: (context, index) {
                        final data = result.data[index];

                        return Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 2,
                              child: Text(
                                data.FIN_YEAR,
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                style: TextStyle(
                                    color: data.MONTH_NM == 'Total'
                                        ? Colors.black
                                        : Colors.white,
                                    fontSize: 11,
                                    fontWeight: data.MONTH_NM == 'Total'
                                        ? FontWeight.w900
                                        : FontWeight.w400),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                data.MONTH_NM,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 12,
                                    fontWeight: data.MONTH_NM == 'Total'
                                        ? FontWeight.w900
                                        : FontWeight.w400),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Text(
                                data.PRESENT.toString(),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 12,
                                    fontWeight: data.MONTH_NM == 'Total'
                                        ? FontWeight.w900
                                        : FontWeight.w400),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Text(
                                data.ABSENT.toString(),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 12,
                                    fontWeight: data.MONTH_NM == 'Total'
                                        ? FontWeight.w900
                                        : FontWeight.w400),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Text(
                                data.LEAVE.toString(),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 12,
                                    fontWeight: data.MONTH_NM == 'Total'
                                        ? FontWeight.w900
                                        : FontWeight.w400),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Text(
                                data.WEEKOFF_EXCLUDED > 0
                                    ? data.WEEKOFF_EXCLUDED.toString()
                                    : '',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 12,
                                    fontWeight: data.MONTH_NM == 'Total'
                                        ? FontWeight.w900
                                        : FontWeight.w400),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Text(
                                data.HOLIDAY_EXCLUDED > 0
                                    ? data.HOLIDAY_EXCLUDED.toString()
                                    : '',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 12,
                                    fontWeight: data.MONTH_NM == 'Total'
                                        ? FontWeight.w900
                                        : FontWeight.w400),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ).show();
      }

      return true;
    } on DioException catch (e) {
      progress?.dismiss();
      dioMessage(
          e,
          'Summary List Failed!',
          '${Trace.from(StackTrace.current).frames[0].member} Line: ${Trace.from(StackTrace.current).frames[0].line}',
          context,
          true);
    } on Exception catch (e) {
      progress?.dismiss();
      if (kDebugMode) {
        print('Failed to fetch attendance summary list: $e');
      }

      // awesomePopup(context, e.toString(), 'Leave List Failed!', 'error').show();
    }

    setState(() {
      summarylistResult = true;
    });

    return false;
  }

  Future<bool> getAttendanceEmpWiseData(BuildContext context,
      {bool isRefresh = false}) async {
    try {
      if (userdata.isEmpty) {
        cardKeyListEmpWise = [];
        attendanceEmpWisedata = [];
        currentPageEmpWise = 1;

        totalPagesEmpWise = 0;

        _foundAttendanceEmpWise = attendanceEmpWisedata;
        return false;
      }

      if (isRefresh == true) {
        setState(() {
          currentPageEmpWise = 1;
        });
      } else {
        if (currentPageEmpWise > totalPagesEmpWise) {
          setState(() {
            refreshController.loadNoData();
          });
          return false;
        }
      }

      var dioObj = DioHelper();

      final params = <String, dynamic>{
        'system_name': deviceId,
        'dt_date': DateFormat("yyyy-MM-dd").format(selectedDate),
        'page': currentPageEmpWise,
        'limit': 10,
        'department': section,
        'category': category,
        'keywords': '*',
      };

      if (userdata[0].ADMIN_DEPARTMENT != null) {
        params.addAll({'admin_department': userdata[0].ADMIN_DEPARTMENT});
      }

      if (userdata[0].ADMIN_CATEGORY != null) {
        params.addAll({'admin_category': userdata[0].ADMIN_CATEGORY});
      }

      final response = await dioObj.api.get(
        Config.attendanceEmpWiseAPI,
        options: dio.Options(
          headers: {"requires-token": false},
          // validateStatus: (status) => true,
          // followRedirects: false,
        ),
        queryParameters: params,
      );

      if (response.statusCode == 200) {
        final result = AttendanceEmpWiseListingData.fromJson(response.data);

        setState(() {
          if (isRefresh) {
            cardKeyListEmpWise = [];
            attendanceEmpWisedata = result.data;
          } else {
            attendanceEmpWisedata.addAll(result.data);
          }
          currentPageEmpWise++;

          totalPagesEmpWise = result.pages; //Last 10 Entries

          _foundAttendanceEmpWise = attendanceEmpWisedata;

          // if (kDebugMode) {
          //   print(response.data);
          // }
        });

        return true;
      } else {
        setState(() {
          cardKeyListEmpWise = [];
          attendanceEmpWisedata = [];

          currentPageEmpWise = 1;

          totalPagesEmpWise = 0;
          _foundAttendanceEmpWise = attendanceEmpWisedata;

          // if (kDebugMode) {
          //   print(response.data);
          // }
        });

        return false;
      }

      // await awesomePopup(context, response.data['message'].toString(), 'Success', 'success').show();
    } on DioException catch (e) {
      dioMessage(
          e,
          'Attendance Listing Failed!',
          '${Trace.from(StackTrace.current).frames[0].member} Line: ${Trace.from(StackTrace.current).frames[0].line}',
          context,
          true);
    } on PlatformException catch (e) {
      if (kDebugMode) {
        print('Failed to retrive attendance data: $e');
      }

      await awesomePopup(
              context, e.toString(), 'Attendance Listing Failed!', 'error')
          .show();

      return false;
    }

    return false;
  }

  Future<bool> getAttendanceConciseData(BuildContext context) async {
    try {
      if (userdata.isEmpty) {
        cardKeyListConcise = [];
        conciseAvailabledata = [];
        conciseAbsentdata = [];
        conciseOnLeavedata = [];
        conciseYetToComedata = [];

        attendanceConcisedata = [];
        _foundAttendanceConcise = attendanceConcisedata;
        return false;
      }

      var dioObj = DioHelper();

      final params = <String, dynamic>{
        'system_name': deviceId,
        'dt_date': DateFormat("yyyy-MM-dd").format(selectedDate),
        'department': section,
        'category': category,
        'keywords': '*',
      };

      if (userdata[0].ADMIN_DEPARTMENT != null) {
        params.addAll({'admin_department': userdata[0].ADMIN_DEPARTMENT});
      }

      if (userdata[0].ADMIN_CATEGORY != null) {
        params.addAll({'admin_category': userdata[0].ADMIN_CATEGORY});
      }

      final response = await dioObj.api.get(
        Config.attendanceConciseAPI,
        options: dio.Options(
          headers: {"requires-token": false},
          // validateStatus: (status) => true,
          // followRedirects: false,
        ),
        queryParameters: params,
      );

      if (response.statusCode == 200) {
        final result = AttendanceConciseData.fromJson(response.data);

        setState(() {
          cardKeyListConcise = [];
          conciseAvailabledata = result.available;
          conciseAbsentdata = result.absents;
          conciseOnLeavedata = result.onleave;
          conciseYetToComedata = result.yettocome;

          attendanceConcisedata = result.summarise;

          _foundAttendanceConcise = attendanceConcisedata;

          // if (kDebugMode) {
          //   print(response.data);
          // }
        });

        return true;
      } else {
        setState(() {
          cardKeyListConcise = [];
          conciseAvailabledata = [];
          conciseAbsentdata = [];
          conciseOnLeavedata = [];
          conciseYetToComedata = [];

          attendanceConcisedata = [];

          _foundAttendanceConcise = attendanceConcisedata;

          // if (kDebugMode) {
          //   print(response.data);
          // }
        });

        return false;
      }

      // await awesomePopup(context, response.data['message'].toString(), 'Success', 'success').show();
    } on DioException catch (e) {
      dioMessage(
          e,
          'Concise Attendance Failed!',
          '${Trace.from(StackTrace.current).frames[0].member} Line: ${Trace.from(StackTrace.current).frames[0].line}',
          context,
          true);
    } on PlatformException catch (e) {
      if (kDebugMode) {
        print('Failed to retrive concise attendance data: $e');
      }

      await awesomePopup(
              context, e.toString(), 'Concise Attendance Failed!', 'error')
          .show();

      return false;
    }

    return false;
  }
}

class ScanTime extends StatefulWidget {
  const ScanTime({
    super.key,
    required this.label,
    required this.value,
    required this.dayName,
    this.deviation,
    this.time,
    this.late = false,
    this.lunchdelay,
    this.leave,
    this.leavestatus,
    required this.onClick,
    required this.showDelay,
    this.adminmode = false,
  });

  final String label;
  final String value;
  final String dayName;
  final String? deviation;
  final bool? late;
  final bool? time;
  final bool? lunchdelay;
  final String? leave;
  final String? leavestatus;

  final bool showDelay;
  final bool adminmode;

  final VoidCallback onClick;

  @override
  State<ScanTime> createState() => _ScanTimeState();
}

class _ScanTimeState extends State<ScanTime> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height:
          widget.time == true && widget.dayName != 'Sunday' && widget.showDelay
              ? 46
              : 32,
      decoration: (widget.dayName == 'Saturday' &&
                  ((widget.label == 'Lunch Out' && widget.leave == null) ||
                      (widget.label == 'Lunch In' && widget.leave == null))) ||
              widget.dayName == 'Sunday'
          ? null
          : BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(4.0)),
              color: widget.late == false ? Colors.green : Colors.red,
              // color: (widget.label == 'Lunch Out' || widget.label == 'Lunch In') && widget.lunchdelay == false
              //     ? Colors.green
              //     : (widget.label == 'Lunch Out' || widget.label == 'Lunch In') && widget.lunchdelay == true
              //         ? Colors.red
              //         : widget.late == false
              //             ? Colors.green
              //             : Colors.red,
            ),
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: Visibility(
              visible: !(widget.dayName == 'Sunday' ||
                  (widget.dayName == 'Saturday' &&
                      ((widget.label == 'Lunch Out' && widget.leave == null) ||
                          (widget.label == 'Lunch In' &&
                              widget.leave == null))) ||
                  widget.leave == 'FULL DAY'),
              child: FilterChip(
                elevation: widget.time == true ? 1 : 0,
                labelPadding: EdgeInsets.only(top: 0, bottom: -1),
                // padding: EdgeInsets.only(left: 0, top: 0, right: 0, bottom: 0),

                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(4)),
                  side: BorderSide(
                    color: widget.time == true
                        ? ColorConfig.dark.withOpacity(0.2)
                        : Colors.grey,
                  ),
                ),
                // visualDensity: VisualDensity.compact,
                label: SizedBox(
                  width: 40,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    // crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.leave == 'FIRST HALF' &&
                                widget.label == 'Lunch In'
                            ? 'Start'
                            : widget.leave == 'SECOND HALF' &&
                                    widget.label == 'Lunch Out'
                                ? 'End'
                                : widget.label,
                        style: TextStyle(
                          color:
                              widget.time == true ? Colors.white : Colors.black,
                          fontSize: 8,
                          fontWeight: FontWeight.normal,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(
                        height: 1,
                      ),
                      Text(
                        widget.value,
                        textAlign: TextAlign.start,
                        maxLines: 1,
                        style: TextStyle(
                          color: Colors
                              .white, //Not to show in case of Missing hence white
                          fontSize: 11,
                          fontWeight: FontWeight.normal,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                backgroundColor: widget.time == true
                    ? ColorConfig.dark.withOpacity(0.8)
                    : Colors.white,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                onSelected: (value) => widget.onClick(),
              ),
            ),
          ),
          Visibility(
            visible: widget.dayName != 'Sunday' && widget.showDelay,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Visibility(
                  visible: widget.time == true,
                  child: Text(
                    widget.deviation.toString(),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 8,
                      fontWeight: FontWeight.normal,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
