import 'dart:io';

import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import '../providers/custom_theme_provider.dart';
import '../providers/loginpage_provider.dart';
import '../utils/color_constraints.dart';
import '../themes/dark_theme.dart';
import '../themes/light_theme.dart';

class PageNameWidget extends StatefulWidget {
  const PageNameWidget({
    super.key,
    required this.name,
    required this.icon,
    required this.admin,
    required this.adminmode,
    required this.registered,
    required this.print,
    this.fontsize = 18,
    this.onClickedLocation,
    this.onClick,
    this.onReload,
    this.onPrint,
    this.onLeave,
    this.onVacation,
    this.onLeaveSummary,
    this.onSummary,
    this.initialProcessed,
    this.leaveRegister = false,
    this.leaveSummaryType = 0, // New parameter added
  });

  final VoidCallback? onClick;
  final VoidCallback? onClickedLocation;
  final VoidCallback? onReload;
  final VoidCallback? onPrint;
  final VoidCallback? onLeave;
  final VoidCallback? onVacation;
  final Function(int)? onLeaveSummary;
  final VoidCallback? onSummary;

  final String name;
  final IconData icon;
  final double fontsize;
  final bool leaveRegister;
  final bool print;
  final bool admin;
  final bool registered;
  final bool? initialProcessed;
  final bool adminmode;
  final int leaveSummaryType;

  @override
  State<PageNameWidget> createState() => _PageNameWidgetState();
}

class _PageNameWidgetState extends State<PageNameWidget> {
  @override
  Widget build(BuildContext context) {
    final provLogin = Provider.of<LoginProvider>(context);
    final themeState = Provider.of<CustomThemeProvider>(context, listen: true);

    bool isAttendancePage = widget.name == 'Attendance';
    bool isLeavePage = widget.name == 'Leave Register';
    bool isDarkMode = themeState.getDarkTheme;

    return Positioned(
      top: MediaQuery.of(context).size.height / 9.5,
      child: Padding(
        padding: const EdgeInsets.only(
          left: 10,
          top: 5,
          // right: 10,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(
              // color: Colors.greenAccent,
              width: MediaQuery.of(context).size.width - 10,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: GestureDetector(
                      onTap: widget.onClick,
                      child: Chip(
                        label: Text(widget.name),
                        avatar: CircleAvatar(
                          backgroundColor: Colors.transparent,
                          child: FaIcon(
                            isLeavePage
                                ? FontAwesomeIcons.personWalkingLuggage
                                : widget.icon,
                            size: widget.fontsize,
                            color: themeState.getDarkTheme
                                ? ColorConfig.darkMain
                                : ColorConfig.lightMain,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 7,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          Visibility(
                            visible: widget.initialProcessed == true &&
                                provLogin.isLocationEnabled == false &&
                                widget.leaveRegister == false,
                            child: Center(
                              child: IconButton(
                                onPressed: widget.onClickedLocation,
                                icon: Icon(
                                  Icons.location_off,
                                  color: themeState.getDarkTheme == true
                                      ? ColorConfig.lightChip
                                      : ColorConfig.darkChip,
                                ),
                                iconSize: 22,
                              ),
                            ),
                          ),
                          Visibility(
                            visible: widget.initialProcessed == true &&
                                isAttendancePage,
                            child: Center(
                              child: IconButton(
                                onPressed: widget.onReload,
                                icon: Icon(Icons.refresh,
                                    color: themeState.getDarkTheme == true
                                        ? ColorConfig.lightChip
                                        : ColorConfig.darkChip),
                                iconSize: 22,
                              ),
                            ),
                          ),
                          Visibility(
                            visible: widget.registered &&
                                widget.admin &&
                                provLogin.isLocationEnabled == true &&
                                widget.leaveRegister == false &&
                                widget.print &&
                                Platform.isAndroid,
                            child: Center(
                              child: IconButton(
                                onPressed: widget.onPrint,
                                icon: Icon(Icons.print,
                                    color: themeState.getDarkTheme == true
                                        ? ColorConfig.lightChip
                                        : ColorConfig.darkChip),
                                iconSize: 22,
                              ),
                            ),
                          ),
                          Visibility(
                            visible: widget.registered &&
                                widget.admin &&
                                provLogin.isLocationEnabled == true &&
                                widget.leaveRegister == false,
                            child: Center(
                              child: IconButton(
                                onPressed: widget.onLeave,
                                icon: FaIcon(
                                    FontAwesomeIcons.personWalkingLuggage,
                                    color: themeState.getDarkTheme == true
                                        ? ColorConfig.lightChip
                                        : ColorConfig.darkChip),
                                iconSize: 22,
                              ),
                            ),
                          ),
                          Visibility(
                            visible: widget.registered &&
                                provLogin.isLocationEnabled == true &&
                                widget.leaveRegister == false,
                            child: Center(
                              child: IconButton(
                                onPressed: widget.onVacation,
                                icon: FaIcon(FontAwesomeIcons.umbrellaBeach,
                                    size: 20,
                                    color: themeState.getDarkTheme == true
                                        ? ColorConfig.lightChip
                                        : ColorConfig.darkChip),
                                iconSize: 22,
                              ),
                            ),
                          ),
                          Visibility(
                            visible: widget.registered &&
                                widget.leaveRegister == false,
                            child: Center(
                              child: Builder(
                                builder: (context) {
                                  return IconButton(
                                    onPressed: () async {
                                      final RenderBox button = context
                                          .findRenderObject() as RenderBox;
                                      final Offset offset =
                                          button.localToGlobal(Offset.zero);
                                      final Size size = button.size;
                                      final selected = await showMenu<int>(
                                        context: context,
                                        position: RelativeRect.fromLTRB(
                                          offset.dx,
                                          offset.dy + size.height,
                                          offset.dx + size.width,
                                          offset.dy,
                                        ),
                                        items: const [
                                          PopupMenuItem<int>(
                                              value: 1,
                                              child: Text("Leave Days")),
                                          PopupMenuItem<int>(
                                              value: 2,
                                              child: Text("Absent Days")),
                                          PopupMenuItem<int>(
                                              value: 3,
                                              child: Text("Work Hours")),
                                          PopupMenuItem<int>(
                                              value: 4,
                                              child: Text("Lunch Time")),
                                          PopupMenuItem<int>(
                                              value: 5,
                                              child: Text("Missed Punch")),
                                        ],
                                      );
                                      if (selected != null &&
                                          widget.onLeaveSummary != null) {
                                        widget.onLeaveSummary!(selected);
                                      }
                                    },
                                    icon: FaIcon(FontAwesomeIcons.calendarDays,
                                        size: 20,
                                        color: themeState.getDarkTheme == true
                                            ? ColorConfig.lightChip
                                            : ColorConfig.darkChip),
                                    iconSize: 22,
                                  );
                                },
                              ),
                            ),
                          ),
                          Visibility(
                            visible: widget.registered &&
                                provLogin.isLocationEnabled == true &&
                                widget.leaveRegister == false &&
                                !widget.adminmode,
                            child: Center(
                              child: IconButton(
                                onPressed: widget.onSummary,
                                icon: FaIcon(FontAwesomeIcons.circleInfo,
                                    size: 24,
                                    color: themeState.getDarkTheme == true
                                        ? ColorConfig.lightChip
                                        : ColorConfig.darkChip),
                                iconSize: 24,
                              ),
                            ),
                          ),
                          Visibility(
                            visible: isAttendancePage &&
                                widget.leaveRegister == false,
                            child: ThemeSwitcher(
                              builder: (context) => IconButton(
                                icon: isDarkMode == true
                                    ? Icon(Icons.dark_mode_outlined,
                                        color: ColorConfig.light)
                                    : Icon(Icons.light_mode,
                                        color: ColorConfig.dark),
                                iconSize: 22,
                                onPressed: () {
                                  isDarkMode = !isDarkMode;
                                  final switcher = ThemeSwitcher.of(context);
                                  switcher.changeTheme(
                                      theme:
                                          isDarkMode ? darkTheme : lightTheme,
                                      isReversed: isDarkMode);

                                  Future.delayed(
                                          const Duration(milliseconds: 200))
                                      .then((_) => {
                                            themeState.setDarkTheme =
                                                isDarkMode,
                                          });
                                },
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
          ],
        ),
      ),
    );
  }
}
