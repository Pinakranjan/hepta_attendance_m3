// ignore_for_file: use_build_context_synchronously

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:dio/dio.dart';
import 'package:dio/dio.dart' as dio;
import 'package:expansion_tile_card/expansion_tile_card.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_progress_hud/flutter_progress_hud.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:stack_trace/stack_trace.dart';

import '../config.dart';
import '../models/leave.dart';
import '../providers/custom_theme_provider.dart';
import '../services/dio_service.dart';
import '../utils/color_constraints.dart';
import '../utils/common_functions.dart';
import '../widgets/header_widget.dart';
import '../widgets/input_text_widget.dart';
import '../widgets/page_name_widget.dart';
import 'package:hepta_attendance/providers/loginpage_provider.dart';
import 'package:provider/provider.dart';

class LeaveApprovalPage extends StatefulWidget {
  const LeaveApprovalPage({Key? key}) : super(key: key);
  static const route = '/leaveregister-screen';

  @override
  State<LeaveApprovalPage> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<LeaveApprovalPage>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  GlobalKey<FormState> globalFormKey = GlobalKey<FormState>();

  List<Leave> leavedata = [];
  List<Leave> _foundLeave = [];
  bool leavelistResult = false;

  int currentPage = 1;
  int totalPages = 1;
  final RefreshController refreshController =
      RefreshController(initialRefresh: true);
  bool initialRefresh = true;
  bool actionOnLeaveClicked = false;

  List<GlobalKey<ExpansionTileCardState>> cardKeyList = [];

  String? deviceId;
  String? uuid;
  String? adminName;

  late TextEditingController remarksController;
  late FocusNode purposeFocus;

  late LoginProvider loginProv;

  @override
  void initState() {
    super.initState();

    remarksController = TextEditingController();
    purposeFocus = FocusNode();

    // This is called after build complete
    WidgetsBinding.instance.endOfFrame.then((_) async {
      if (mounted) {
        await Hive.initFlutter();
        Box box1 = await Hive.openBox('heptalogindata');

        if (box1.get('uuid') != null) {
          uuid = box1.get('uuid');
          if (kDebugMode) {
            print('UUID: $uuid');
          }
        }

        loginProv = Provider.of<LoginProvider>(context, listen: false);
        loginProv.isLeaveRegisterLoaded = true;
      }
    });
  }

  @override
  void deactivate() {
    loginProv.isLeaveRegisterLoaded = false;
    super.deactivate();
  }

  @override
  void dispose() {
    //don't forget to dispose of it when not needed anymore

    remarksController.dispose();
    purposeFocus.dispose();

    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext sfctx) {
    return SafeArea(
      top: true,
      child: Scaffold(
        body: ProgressHUD(
          indicatorColor: ColorConfig.lightMain,
          textStyle: TextStyle(color: ColorConfig.lightMain),
          barrierColor: ColorConfig.darkMain.withOpacity(0.6),
          child: Builder(builder: (BuildContext pHUDcontext) {
            return Form(
              key: globalFormKey,
              child: _leaveApprovalUI(context, sfctx, pHUDcontext),
            );
          }),
        ),
      ),
    );
  }

  Widget _leaveApprovalUI(
      BuildContext context, BuildContext sfctx, BuildContext pHUDcontext) {
    final themeState = Provider.of<CustomThemeProvider>(context);
    final loginProv = Provider.of<LoginProvider>(context, listen: true);

    bool isDarkMode = themeState.getDarkTheme;
    deviceId = loginProv.deviceId;
    adminName = loginProv.adminName;

    return Stack(
      alignment: Alignment.topLeft,
      children: [
        const HeaderWidget(),
        const PageNameWidget(
          admin: true,
          registered: true,
          leaveRegister: true,
          initialProcessed: true,
          adminmode: false,
          print: false,
          icon: Icons.calendar_month,
          name: 'Leave Register',
        ),
        // Text("Route Name: ${ModalRoute.of(context)?.settings.name}"),
        Padding(
          padding: EdgeInsets.only(
              top: MediaQuery.of(context).size.height / 9 + 45,
              left: 10,
              right: 10), //, bottom: (loginProv.noInternet == true) ? 110 : 70
          child: Stack(
            children: [
              SmartRefresher(
                controller: refreshController,
                enablePullUp: true,
                header: ClassicHeader(
                  height: initialRefresh == true ? 0 : 60,
                  idleText: "Pull to Refresh!",
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
                  failedText: currentPage > totalPages
                      ? "No more data to load"
                      : "Load failed!",
                ),
                onRefresh: () async {
                  final result = await getLeaveData(context, isRefresh: true);

                  // && currentPage <= totalPages
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
                  final result = await getLeaveData(context);

                  if (result && currentPage <= totalPages) {
                    refreshController.loadComplete();
                  } else {
                    refreshController.loadFailed();
                  }
                },
                child: _foundLeave.isEmpty
                    ? Center(
                        child: Text(
                            initialRefresh == true ? '' : 'No data found!'))
                    : SlidableAutoCloseBehavior(
                        child: ListView.separated(
                          key: const Key('Lst1'),
                          itemCount: _foundLeave.length,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          scrollDirection: Axis.vertical,
                          // padding: EdgeInsets.all(2),
                          separatorBuilder: (context, index) => const Divider(
                            height: 0,
                          ),
                          itemBuilder: (context, index) {
                            final data = _foundLeave[index];
                            cardKeyList.add(GlobalKey(
                                debugLabel: data.RECORD_ID.toString()));

                            return Slidable(
                              key: Key('Slide_${data.RECORD_ID}'),
                              groupTag: '1',
                              enabled: true,
                              closeOnScroll: true,
                              startActionPane: data.STATUS != null
                                  ? null
                                  : ActionPane(
                                      motion: const StretchMotion(),
                                      dragDismissible: false,
                                      extentRatio: 0.25,
                                      children: [
                                        SlidableAction(
                                          key: Key('Approve_${data.RECORD_ID}'),
                                          backgroundColor: Colors.green,
                                          icon: Icons.approval,
                                          label: 'Approve',
                                          autoClose: false,
                                          onPressed: (context) async {
                                            remarksController.text = '';

                                            await AwesomeDialog(
                                              context: sfctx,
                                              dialogType: DialogType.question,
                                              animType: AnimType.scale,
                                              showCloseIcon: true,
                                              keyboardAware: true,
                                              title: 'Leave Approval',
                                              desc:
                                                  'Are you sure you want to approve this leave application?',
                                              btnCancelOnPress: () {
                                                Slidable.of(context)?.close();

                                                setState(() {
                                                  actionOnLeaveClicked = false;
                                                });
                                              },
                                              onDismissCallback: (type) {
                                                Slidable.of(context)?.close();

                                                setState(() {
                                                  actionOnLeaveClicked = false;
                                                });
                                              },
                                              btnOkOnPress: () {
                                                setState(() {
                                                  actionOnLeaveClicked = true;
                                                });
                                              },
                                              btnOkIcon: Icons.check,
                                              padding: const EdgeInsets.all(20),
                                              barrierColor: ColorConfig.darkMain
                                                  .withOpacity(0.6),
                                              titleTextStyle: const TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.w700),
                                              descTextStyle: const TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 14,
                                                  fontWeight:
                                                      FontWeight.normal),
                                              dialogBackgroundColor:
                                                  Colors.white,
                                              body: Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Column(
                                                  children: <Widget>[
                                                    const Text(
                                                      'Leave Approval',
                                                      style: TextStyle(
                                                          color: Colors.black,
                                                          fontSize: 20,
                                                          fontWeight:
                                                              FontWeight.w700),
                                                    ),
                                                    const SizedBox(
                                                      height: 20,
                                                    ),
                                                    const Text(
                                                      'Are you sure you want to approve this leave application?',
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                          color: Colors.black,
                                                          fontSize: 14,
                                                          fontWeight: FontWeight
                                                              .normal),
                                                    ),
                                                    const SizedBox(
                                                      height: 20,
                                                    ),
                                                    InputTextFieldV1(
                                                      controller:
                                                          remarksController,
                                                      labelText: "Remarks",
                                                      hintText: "Remarks",
                                                      autovalidateMode:
                                                          AutovalidateMode
                                                              .onUserInteraction,
                                                      prefixIcon: const Padding(
                                                        padding:
                                                            EdgeInsets.only(
                                                                left: 10,
                                                                top: 5),
                                                        child: FaIcon(
                                                          FontAwesomeIcons
                                                              .clipboard,
                                                          size: 24,
                                                        ),
                                                      ),
                                                      textFocus: purposeFocus,
                                                      autofocus: false,
                                                      sufixIcon: false,
                                                      displaylines: 2,
                                                      isDark: false,
                                                      maxLength: 250,
                                                      textType:
                                                          TextCapitalization
                                                              .words,
                                                      inputType: TextInputType
                                                          .multiline,
                                                      textValueSetter:
                                                          (value) {},
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ).show();

                                            if (actionOnLeaveClicked == true) {
                                              final progress =
                                                  ProgressHUD.of(pHUDcontext);

                                              progress?.show();
                                              var action = await actionOnLeave(
                                                  sfctx, data, 'APPROVED');

                                              setState(() {
                                                actionOnLeaveClicked = false;
                                              });

                                              progress?.dismiss();

                                              if (action == true) {
                                                ScaffoldMessenger.of(sfctx)
                                                  ..hideCurrentSnackBar()
                                                  ..showSnackBar(
                                                    SnackBar(
                                                      key: Key(
                                                          'LA_${DateTime.now().toString()}'),
                                                      elevation: 0,
                                                      behavior: SnackBarBehavior
                                                          .floating,
                                                      backgroundColor:
                                                          Colors.transparent,
                                                      content:
                                                          AwesomeSnackbarContent(
                                                        title: Config.appName,
                                                        message:
                                                            'Leave Approved Successfully.',
                                                        contentType:
                                                            ContentType.success,
                                                      ),
                                                    ),
                                                  );

                                                setState(() {
                                                  leavelistResult = false;
                                                  leavedata = [];
                                                });

                                                // await Future.delayed(const Duration(seconds: 2), () {});
                                                await getLeaveData(context);

                                                setState(() {
                                                  initialRefresh = true;
                                                });

                                                refreshController
                                                    .requestRefresh();
                                              }
                                            }
                                          },
                                        ),
                                      ],
                                    ),
                              endActionPane: data.STATUS == 'CANCELLED'
                                  ? null
                                  : ActionPane(
                                      motion: const BehindMotion(),
                                      dragDismissible: false,
                                      extentRatio: 0.25,
                                      children: [
                                        SlidableAction(
                                          key: Key('Delete_${data.RECORD_ID}'),
                                          backgroundColor: Colors.red,
                                          icon: Icons.cancel,
                                          autoClose: false,
                                          label: 'Cancel',
                                          onPressed: (context) async {
                                            if (data.STATUS != 'CANCELLED') {
                                              remarksController.text = '';

                                              await AwesomeDialog(
                                                context: sfctx,
                                                dialogType: DialogType.question,
                                                animType: AnimType.scale,
                                                showCloseIcon: true,
                                                keyboardAware: true,
                                                title: 'Leave Cancellation',
                                                desc:
                                                    'Are you sure you want to cancel this leave application?',
                                                btnCancelOnPress: () {
                                                  Slidable.of(context)?.close();
                                                  setState(() {
                                                    actionOnLeaveClicked =
                                                        false;
                                                  });
                                                },
                                                onDismissCallback: (type) {
                                                  Slidable.of(context)?.close();
                                                  setState(() {
                                                    actionOnLeaveClicked =
                                                        false;
                                                  });
                                                },
                                                btnOkOnPress: () async {
                                                  setState(() {
                                                    actionOnLeaveClicked = true;
                                                  });
                                                },
                                                btnOkIcon: Icons.check,
                                                padding:
                                                    const EdgeInsets.all(20),
                                                barrierColor: ColorConfig
                                                    .darkMain
                                                    .withOpacity(0.6),
                                                titleTextStyle: const TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 20,
                                                    fontWeight:
                                                        FontWeight.w700),
                                                descTextStyle: const TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 14,
                                                    fontWeight:
                                                        FontWeight.normal),
                                                dialogBackgroundColor:
                                                    Colors.white,
                                                body: Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Column(
                                                    children: <Widget>[
                                                      const Text(
                                                        'Leave Cancellation',
                                                        style: TextStyle(
                                                            color: Colors.black,
                                                            fontSize: 20,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w700),
                                                      ),
                                                      const SizedBox(
                                                        height: 20,
                                                      ),
                                                      const Text(
                                                        'Are you sure you want to cancel this leave application?',
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: TextStyle(
                                                            color: Colors.black,
                                                            fontSize: 14,
                                                            fontWeight:
                                                                FontWeight
                                                                    .normal),
                                                      ),
                                                      const SizedBox(
                                                        height: 20,
                                                      ),
                                                      InputTextFieldV1(
                                                        controller:
                                                            remarksController,
                                                        labelText: "Remarks",
                                                        hintText: "Remarks",
                                                        autovalidateMode:
                                                            AutovalidateMode
                                                                .onUserInteraction,
                                                        prefixIcon:
                                                            const Padding(
                                                          padding:
                                                              EdgeInsets.only(
                                                                  left: 10,
                                                                  top: 5),
                                                          child: FaIcon(
                                                            FontAwesomeIcons
                                                                .clipboard,
                                                            size: 24,
                                                          ),
                                                        ),
                                                        textFocus: purposeFocus,
                                                        autofocus: false,
                                                        sufixIcon: false,
                                                        displaylines: 2,
                                                        isDark: false,
                                                        maxLength: 250,
                                                        textType:
                                                            TextCapitalization
                                                                .words,
                                                        inputType: TextInputType
                                                            .multiline,
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
                                                    ProgressHUD.of(pHUDcontext);

                                                progress?.show();
                                                var action =
                                                    await actionOnLeave(sfctx,
                                                        data, 'CANCELLED');

                                                setState(() {
                                                  actionOnLeaveClicked = false;
                                                });

                                                progress?.dismiss();

                                                if (action == true) {
                                                  ScaffoldMessenger.of(sfctx)
                                                    ..hideCurrentSnackBar()
                                                    ..showSnackBar(
                                                      SnackBar(
                                                        key: Key(
                                                            'LC_${DateTime.now().toString()}'),
                                                        elevation: 0,
                                                        behavior:
                                                            SnackBarBehavior
                                                                .floating,
                                                        backgroundColor:
                                                            Colors.transparent,
                                                        content:
                                                            AwesomeSnackbarContent(
                                                          title: Config.appName,
                                                          message:
                                                              'Leave Cancelled Successfully.',
                                                          contentType:
                                                              ContentType
                                                                  .success,
                                                        ),
                                                      ),
                                                    );

                                                  setState(() {
                                                    leavelistResult = false;
                                                    leavedata = [];
                                                  });

                                                  // await Future.delayed(const Duration(seconds: 2), () {});
                                                  await getLeaveData(sfctx);

                                                  setState(() {
                                                    initialRefresh = true;
                                                  });

                                                  refreshController
                                                      .requestRefresh();
                                                }
                                              }
                                            } else {
                                              await awesomePopup(
                                                      sfctx,
                                                      "Leave application is already cancelled!",
                                                      'Action Denied!',
                                                      'error')
                                                  .show();
                                              Slidable.of(context)?.close();
                                              setState(() {
                                                actionOnLeaveClicked = false;
                                              });
                                            }
                                          },
                                        ),
                                      ],
                                    ),
                              child: Card(
                                key: Key(data.RECORD_ID.toString()),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(7),
                                ),
                                color: Colors.white,
                                elevation: 4,
                                child: Stack(
                                  children: [
                                    ListTile(
                                      key:
                                          Key('LT${data.RECORD_ID.toString()}'),
                                      // contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: -25),
                                      // contentPadding: const EdgeInsets.fromLTRB(5, -10, 0, 0),
                                      contentPadding: const EdgeInsets.only(
                                        left: 5,
                                        // right: 5,
                                      ),
                                      isThreeLine: false,
                                      horizontalTitleGap: 0,
                                      minVerticalPadding: -4.5,
                                      // dense: true,
                                      // leading: CircleAvatar(
                                      //   radius: 11,
                                      //   backgroundColor: data.SEQUENCE != null ? ColorConfig.dark.withOpacity(0.8) : Colors.white,
                                      //   child: Text(data.SEQUENCE.toString(), style: const TextStyle(fontSize: 12, color: Colors.white)),
                                      // ),
                                      minLeadingWidth: 18,
                                      // tileColor: Colors.blueAccent,
                                      title: SizedBox(
                                        height: 68,
                                        width: double.maxFinite,
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                              left: 10,
                                              right: 10,
                                              top: 4,
                                              bottom: 4),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            children: [
                                              SizedBox(
                                                height: 15,
                                                child: FilterChip(
                                                  elevation: 1,
                                                  labelPadding:
                                                      const EdgeInsets.only(
                                                          top: -6),
                                                  shape:
                                                      const RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.all(
                                                            Radius.circular(2)),
                                                  ),
                                                  visualDensity:
                                                      VisualDensity.compact,
                                                  label: Text(
                                                    data.EMPLOYEE_NAME,
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.normal,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                  backgroundColor:
                                                      data.STATUS == 'CANCELLED'
                                                          ? Colors.red
                                                          : ColorConfig.dark
                                                              .withOpacity(0.8),
                                                  materialTapTargetSize:
                                                      MaterialTapTargetSize
                                                          .shrinkWrap,
                                                  onSelected: (value) {
                                                    awesomePopup(
                                                            context,
                                                            '${data.PURPOSE}\n\nApplied On: ${DateFormat("dd-MMM-yy HH:mm:ss").format(data.APPLY_DATE)}',
                                                            'Leave Purpose',
                                                            'info')
                                                        .show();
                                                  },
                                                ),
                                              ),
                                              const SizedBox(
                                                height: 1,
                                              ),
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
                                                  children: <Widget>[
                                                    Expanded(
                                                        child: Divider(
                                                            thickness: 1,
                                                            height: 0.5,
                                                            color: data.STATUS ==
                                                                    'CANCELLED'
                                                                ? Colors.red
                                                                : Colors.grey)),
                                                    Text(
                                                      '${DateFormat("dd-MMM-yy").format(data.FROM_DATE)} [${data.FROM_HALF == null ? "F" : data.FROM_HALF == false ? "FH" : "SH"}]',
                                                      style: TextStyle(
                                                          color: data.STATUS ==
                                                                  'CANCELLED'
                                                              ? Colors.red
                                                              : Colors.black,
                                                          fontSize: 12),
                                                    ),
                                                    Expanded(
                                                        child: Divider(
                                                            thickness: 1,
                                                            height: 0.5,
                                                            color: data.STATUS ==
                                                                    'CANCELLED'
                                                                ? Colors.red
                                                                : Colors.grey)),
                                                    SizedBox(
                                                      height: 15,
                                                      child: FilterChip(
                                                        elevation: 1,
                                                        labelPadding:
                                                            const EdgeInsets
                                                                .only(top: -6),
                                                        shape:
                                                            const RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius.all(
                                                                  Radius
                                                                      .circular(
                                                                          2)),
                                                        ),
                                                        visualDensity:
                                                            VisualDensity
                                                                .compact,
                                                        label: Text(
                                                          '${data.DAYS} day(s)',
                                                          textAlign:
                                                              TextAlign.start,
                                                          maxLines: 1,
                                                          style:
                                                              const TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 12,
                                                            fontWeight:
                                                                FontWeight
                                                                    .normal,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                          ),
                                                        ),
                                                        backgroundColor: data
                                                                    .STATUS ==
                                                                'CANCELLED'
                                                            ? Colors.red
                                                            : ColorConfig.dark
                                                                .withOpacity(
                                                                    0.8),
                                                        materialTapTargetSize:
                                                            MaterialTapTargetSize
                                                                .shrinkWrap,
                                                        onSelected: (value) {
                                                          awesomePopup(
                                                                  context,
                                                                  '${data.PURPOSE}\n\nApplied On: ${DateFormat("dd-MMM-yy HH:mm:ss").format(data.APPLY_DATE)}',
                                                                  'Leave Purpose',
                                                                  'info')
                                                              .show();
                                                        },
                                                      ),
                                                    ),
                                                    Expanded(
                                                        child: Divider(
                                                            thickness: 1,
                                                            height: 0.5,
                                                            color: data.STATUS ==
                                                                    'CANCELLED'
                                                                ? Colors.red
                                                                : Colors.grey)),
                                                    Text(
                                                      '${DateFormat("dd-MMM-yy").format(data.TO_DATE)} [${data.TO_HALF == null ? "F" : data.TO_HALF == false ? "FH" : "SH"}]',
                                                      style: TextStyle(
                                                          color: data.STATUS ==
                                                                  'CANCELLED'
                                                              ? Colors.red
                                                              : Colors.black,
                                                          fontSize: 12),
                                                    ),
                                                    Expanded(
                                                        child: Divider(
                                                            thickness: 1,
                                                            height: 0.5,
                                                            color: data.STATUS ==
                                                                    'CANCELLED'
                                                                ? Colors.red
                                                                : Colors.grey)),
                                                  ],
                                                ),
                                              ),
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
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    FaIcon(
                                                      FontAwesomeIcons
                                                          .penToSquare,
                                                      color: data.STATUS ==
                                                              'CANCELLED'
                                                          ? Colors.red
                                                          : Colors.black,
                                                      size: 12,
                                                    ),
                                                    const SizedBox(
                                                      width: 2,
                                                    ),
                                                    Text(
                                                      data.PURPOSE
                                                          .split('\n')[0],
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: TextStyle(
                                                          color: data.STATUS ==
                                                                  'CANCELLED'
                                                              ? Colors.red
                                                              : Colors.black,
                                                          fontSize: 12),
                                                    ),
                                                    Visibility(
                                                      visible: data.PURPOSE
                                                          .contains('\n'),
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(left: 5),
                                                        child: FaIcon(
                                                          FontAwesomeIcons
                                                              .arrowTurnDown,
                                                          size: 10,
                                                          color: data.STATUS ==
                                                                  'CANCELLED'
                                                              ? Colors.red
                                                              : Colors.black,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Visibility(
                                                visible: data.NOTES != null,
                                                child: GestureDetector(
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
                                                        color: data.STATUS ==
                                                                'CANCELLED'
                                                            ? Colors.red
                                                            : Colors
                                                                .green.shade700,
                                                        size: 12,
                                                      ),
                                                      const SizedBox(
                                                        width: 2,
                                                      ),
                                                      Flexible(
                                                        child: Text(
                                                          data.NOTES == null
                                                              ? ''
                                                              : data.NOTES!
                                                                  .split(
                                                                      '\n')[0],
                                                          maxLines: 1,
                                                          style: TextStyle(
                                                            color: data.STATUS ==
                                                                    'CANCELLED'
                                                                ? Colors.red
                                                                : Colors.green
                                                                    .shade700,
                                                            fontSize: 12,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                          ),
                                                        ),
                                                      ),
                                                      Visibility(
                                                        visible:
                                                            (data.NOTES ?? '')
                                                                .contains('\n'),
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  left: 5),
                                                          child: FaIcon(
                                                            FontAwesomeIcons
                                                                .arrowTurnDown,
                                                            size: 10,
                                                            color: data.STATUS ==
                                                                    'CANCELLED'
                                                                ? Colors.red
                                                                : Colors.green
                                                                    .shade700,
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
                                        highlightColor: Colors.orange
                                            .withOpacity(0.3), // static color
                                        splashColor:
                                            Colors.lightBlue, // animating color
                                        onTap: () async {
                                          await Future.delayed(
                                              const Duration(milliseconds: 500),
                                              () {});

                                          if (data.STATUS == null) {
                                            awesomePopup(context, '',
                                                    'Approval Due!', 'warning')
                                                .show();
                                          } else if (data.STATUS ==
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
                                          decoration: BoxDecoration(
                                            color: data.STATUS == null
                                                ? Colors.yellow.shade900
                                                : data.STATUS == 'CANCELLED'
                                                    ? Colors.red.shade600
                                                    : Colors.green.shade600,
                                            borderRadius:
                                                const BorderRadius.only(
                                              topRight: Radius.circular(7),
                                              bottomRight: Radius.circular(7),
                                            ),
                                          ),
                                          height: double.infinity,
                                          width: 22,
                                          child: SingleChildScrollView(
                                            scrollDirection: Axis.vertical,
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceAround,
                                              children: [
                                                const SizedBox(
                                                  height: 2,
                                                ),
                                                CircleAvatar(
                                                  maxRadius: 8,
                                                  backgroundColor: Colors.white,
                                                  child: FaIcon(
                                                    data.STATUS == null
                                                        ? FontAwesomeIcons
                                                            .triangleExclamation
                                                        : data.STATUS ==
                                                                'CANCELLED'
                                                            ? FontAwesomeIcons
                                                                .xmark
                                                            : FontAwesomeIcons
                                                                .check,
                                                    size: 12,
                                                    color: data.STATUS == null
                                                        ? Colors.yellow.shade900
                                                        : data.STATUS ==
                                                                'CANCELLED'
                                                            ? Colors
                                                                .red.shade600
                                                            : Colors
                                                                .green.shade600,
                                                  ),
                                                ),
                                                const SizedBox(
                                                  height: 1,
                                                ),
                                                RotatedBox(
                                                  quarterTurns: 5,
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            top: 3),
                                                    child: Text(
                                                      data.STATUS == null
                                                          ? 'Pending'
                                                          : data.STATUS ==
                                                                  'CANCELLED'
                                                              ? 'Cancelled'
                                                              : 'Approved',
                                                      maxLines: 1,
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                        fontSize:
                                                            data.STATUS == null
                                                                ? 9.5
                                                                : 8,
                                                        fontWeight:
                                                            FontWeight.normal,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        color: Colors.white,
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
        Positioned(
          bottom: (loginProv.noInternet == true) ? 50 : 10,
          left: 20,
          child: FloatingActionButton(
            key: const Key('Back'),
            backgroundColor:
                isDarkMode == true ? Colors.grey : Colors.grey.shade700,
            heroTag: const Key('Back'),
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Icon(Icons.arrow_back, color: Colors.white),
          ),
        ),
        Positioned(
          bottom: (loginProv.noInternet == true) ? 50 : 10,
          // left: 0,
          right: 20,
          child: FloatingActionButton(
            key: const Key('Close'),
            heroTag: const Key('Close'),
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

  Future<bool> getLeaveData(BuildContext context,
      {bool isRefresh = false}) async {
    try {
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
        'emp_id': 886677,
        'system_name': deviceId,
        'page': currentPage,
        'limit': 10,
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
          if (isRefresh) {
            cardKeyList = [];
            leavedata = result.data;
          } else {
            leavedata.addAll(result.data);
          }
          currentPage++;

          totalPages = result.pages; //Last 10 Entries

          _foundLeave = leavedata;

          leavelistResult = true;

          // if (kDebugMode) {
          //   print(response.data);
          // }
        });

        return true;
      } else {
        setState(() {
          cardKeyList = [];
          leavedata = [];
          currentPage = 1;

          totalPages = 0;

          _foundLeave = leavedata;

          leavelistResult = true;
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
    });

    return false;
  }

  Future<bool> actionOnLeave(
      BuildContext context, Leave data, String status) async {
    try {
      var dioObj = DioHelper();

      final params = <String, dynamic>{
        'system_name': deviceId,
        'leave_id': data.RECORD_ID,
        'emp_id': data.EMPLOYEE_ID,
        'emp_name': data.EMPLOYEE_NAME,
        'approver': (data.EMPLOYEE_NAME == adminName) ? 'Self' : adminName,
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
}
