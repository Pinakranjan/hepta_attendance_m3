import 'dart:io';

import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import 'api/firebase_api.dart';
import 'firebase_options.dart';
import 'pages/attendance_page.dart';
import 'pages/leave_approval_page.dart';
import 'pages/notification_screen.dart';
import 'pages/splash_screen.dart';
import 'providers/custom_theme_provider.dart';
import 'providers/loginpage_provider.dart';
import 'themes/dark_theme.dart';
import 'themes/light_theme.dart';

final navigatorKey = GlobalKey<NavigatorState>();

// ignore: prefer_typing_uninitialized_variables
late final isNotificationAvailable;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterNativeSplash.remove();

  await Firebase.initializeApp(
    name: "attendance-40605",
    options: DefaultFirebaseOptions.currentPlatform,
  );

  isNotificationAvailable = await FirebaseApi().initNotificationsMain();
  // isNotificationAvailable = '1:false';

  HttpOverrides.global = MyHttpOverrides();

  runApp(const MyApp());
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  CustomThemeProvider themeChangeProvider = CustomThemeProvider();

  void getCurrentAppTheme() async {
    themeChangeProvider.setDarkTheme =
        await themeChangeProvider.darkThemePrefs.getTheme();
  }

  @override
  void initState() {
    getCurrentAppTheme();
    super.initState();
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context) => LoginProvider()),
          ChangeNotifierProvider(create: (_) {
            return themeChangeProvider;
          }),
        ],
        child: Consumer<CustomThemeProvider>(
            builder: (context, themeProvider, child) {
          return ThemeProvider(
            initTheme:
                themeChangeProvider.getDarkTheme ? darkTheme : lightTheme,
            builder: (_, myTheme) {
              return GetMaterialApp(
                debugShowCheckedModeBanner: false,
                title: 'Hits Attendance',
                theme: themeChangeProvider.getDarkTheme == true
                    ? darkTheme
                    : lightTheme,
                // darkTheme: darkTheme,
                home: SplashScreen({'notify': isNotificationAvailable}),
                routes: {
                  // '/': (context) => const TestPage(),
                  // '/': (BuildContext context) => SplashScreen(),
                  '/attendance': (BuildContext context) => AttendancePage(
                      ModalRoute.of(context)!.settings.arguments
                          as Map<String, dynamic>),
                  NotificationScreen.route: (BuildContext context) =>
                      const NotificationScreen(),
                  LeaveApprovalPage.route: (BuildContext context) =>
                      const LeaveApprovalPage(),
                  // '/login': (context) => LoginPage(ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>),
                  // '/otp': (context) => OTPVerificationPage(ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>),
                  // '/register': (context) => const RegisterPage(),
                  // '/project': (context) => const ProjectSelectionPage(),
                },
                // navigatorKey: NavigationService.instance.navigationKey,
                navigatorKey: navigatorKey,
                scaffoldMessengerKey: SnackBarService.scaffoldKey,
              );
            },
          );
        }));
  }
}

class SnackBarService {
  static final scaffoldKey = GlobalKey<ScaffoldMessengerState>();
  static void showSnackBar({required String content}) {
    scaffoldKey.currentState?.showSnackBar(SnackBar(content: Text(content)));
  }
}
