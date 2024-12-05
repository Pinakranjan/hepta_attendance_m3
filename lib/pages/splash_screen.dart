import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import '../providers/custom_theme_provider.dart';
import '../utils/color_constraints.dart';
import '../widgets/header_widget.dart';
// import 'attendance_page.dart';

class SplashScreen extends StatefulWidget {
  final Map<String, dynamic>? args;
  const SplashScreen(this.args, {Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late final AnimationController _controller;
  // Widget _defaultHome = const AttendancePage();

  @override
  void initState() {
    super.initState();

    String? notify = widget.args!["notify"];

    FocusManager.instance.primaryFocus?.unfocus();

    // if (FocusManager.instance.primaryFocus != null) {
    //   FocusManager.instance.primaryFocus?.unfocus();
    // }

    _controller = AnimationController(vsync: this);

    // setDefaultPage();

    Future.delayed(const Duration(seconds: 2)).then((_) {
      // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => _defaultHome));

      Navigator.pushNamedAndRemoveUntil(
        context,
        '/attendance',
        arguments: {'notify': notify},
        (route) => false,
      );
    });
  }

  // void setDefaultPage() async {
  //   await Hive.initFlutter();

  //   Box box1 = await Hive.openBox('hitslogindata');

  //   // Here Auto Login means autologin=1 and last login details present and not expired.
  //   // If Last loggedout then it will redirect to login screen.
  //   // We are not storing password in hive and autologin by using that password for security issue.
  //   bool? result = await SharedService.isLoggedIn();
  //   LoginResponseModel? cachedinfo = await SharedService.loginDetails();

  //   // ignore: use_build_context_synchronously
  //   final login = Provider.of<LoginProvider>(context, listen: false);

  //   if (box1.get('autologinenabled') == '1' &&
  //       result &&
  //       cachedinfo != null &&
  //       JwtDecoder.isExpired(cachedinfo.data.refreshToken) == false &&
  //       login.noInternet == false) {
  //     int projects = 0;
  //     int permission = cachedinfo.data.permissionDetails;

  //     if (mounted) {
  //       // ignore: use_build_context_synchronously
  //       final provInner = Provider.of<InnerProvider>(context, listen: false);
  //       provInner.resetProfile();

  //       // if (kDebugMode) {
  //       //   print(provInner.profileExists ?? 'Not Set');
  //       // }

  //       Map<String, dynamic> decodedRefreshToken = JwtDecoder.decode(cachedinfo.data.refreshToken);

  //       provInner.autoLoginValidity = DateFormat('dd-MM-yyyy HH:mm:ss').format(DateTime.fromMillisecondsSinceEpoch(decodedRefreshToken['exp'] * 1000));

  //       provInner.setHiveData('logintype', 'autologin', false);

  //       if (cachedinfo.data.projects != null) {
  //         projects = cachedinfo.data.projects2!.split(',').length;
  //       }

  //       if (projects == 1) {
  //         provInner.projectId = int.tryParse(cachedinfo.data.projects2!.split('~')[1]);
  //         provInner.projectName = cachedinfo.data.projects2!.split('~')[0];
  //       } else {
  //         provInner.projectId = null;
  //         provInner.projectName = null;
  //       }
  //     }

  //     if (projects == 1) {
  //       Map<String, dynamic> mapp = {"permission": permission.toString()};

  //       _defaultHome = HomePage(mapp);
  //     } else {
  //       _defaultHome = const ProjectSelectionPage();
  //     }
  //   } else {
  //     bool isFingerValid = false;

  //     if (box1.get('fingerprintenabled') == '1' && box1.get('fingerprintenabled_validity') != '') {
  //       if (DateFormat('dd-MM-yyyy HH:mm:ss').parse(box1.get('fingerprintenabled_validity')).isAfter(DateTime.now()) == true) {
  //         isFingerValid = true;
  //       }
  //     }

  //     final isAvailable = await LocalAuthApi.hasBiometrics();

  //     if (isFingerValid == true && isAvailable == true) {
  //       _defaultHome = FingerprintPage(
  //         isFingerValid: isFingerValid,
  //       );
  //     }
  //   }
  // }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChannels.textInput.invokeMethod('TextInput.hide'); //Keep this as it is other sollutions not working
    final themeState = Provider.of<CustomThemeProvider>(context, listen: true);

    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: themeState.getDarkTheme ? ColorConfig.dark : ColorConfig.light,
        body: Stack(
          children: [
            const HeaderWidget(),
            Padding(
              padding: EdgeInsets.only(top: MediaQuery.of(context).size.height / 9),
              child: Center(
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    color: themeState.getDarkTheme ? Colors.grey.shade300 : Colors.white,
                    borderRadius: const BorderRadius.all(
                      Radius.circular(100.0),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: MediaQuery.of(context).size.height / 9),
              child: Center(
                child: SizedBox(
                  width: 150,
                  height: 150,
                  child: Lottie.asset(
                    'assets/jsons/qrcode.json',
                    repeat: false,
                    animate: true,
                    fit: BoxFit.scaleDown,
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
          ],
        ),
      ),
    );
  }
}
