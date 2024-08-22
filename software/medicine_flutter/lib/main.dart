import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:medicine/app/app.bottomsheets.dart';
import 'package:medicine/app/app.dialogs.dart';
import 'package:medicine/app/app.locator.dart';
import 'package:medicine/app/app.router.dart';
import 'package:medicine/ui/common/app_colors.dart';
import 'package:flutter/services.dart';
import 'package:stacked_services/stacked_services.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  setupLocator();
  setupDialogUi();
  setupBottomSheetUi();

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Doctor robo',
      debugShowCheckedModeBanner: false,
      theme: Theme.of(context).copyWith(
        primaryColor: kcBackgroundColor,
        focusColor: kcPrimaryColor,
        colorScheme: const ColorScheme(
          brightness: Brightness.light,
          primary: kcPrimaryColor,
          onPrimary: kcDarkGreyColor,
          secondary: kcPrimaryColorDark,
          onSecondary: kcLightGrey,
          error: Colors.red,
          onError: Colors.white,
          background: kcVeryLightGrey,
          onBackground: kcPrimaryColor,
          surface: Colors.white,
          onSurface: kcDarkGreyColor,
        ),
        textTheme: Theme.of(context).textTheme.apply(
              bodyColor: Colors.black,
            ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderSide: const BorderSide(width: 2, color: kcDarkGreyColor),
            borderRadius: BorderRadius.circular(50.0),
          ),
          // enabledBorder: OutlineInputBorder(
          //   borderSide: const BorderSide(width: 2, color: kcDarkGreyColor),
          //   borderRadius: BorderRadius.circular(50.0),
          // ),
          // focusedBorder: OutlineInputBorder(
          //   borderSide: const BorderSide(width: 2, color: kcDarkGreyColor),
          //   borderRadius: BorderRadius.circular(50.0),
          // ),
          // errorBorder: OutlineInputBorder(
          //   borderSide: const BorderSide(width: 2, color: Colors.red),
          //   borderRadius: BorderRadius.circular(50.0),
          // ),
        ),
      ),
      // initialRoute: Routes.startupView,
      initialRoute: Routes.startupView,
      onGenerateRoute: StackedRouter().onGenerateRoute,
      navigatorKey: StackedService.navigatorKey,
      navigatorObservers: [
        StackedService.routeObserver,
      ],
    );
  }
}
