import 'package:flutter/material.dart';
import 'splashScreen.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'Utils.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // final prefs = await SharedPreferences.getInstance();
  // final showSignIn = prefs.getBool('showSignIn') ?? false;

  // runApp(MyApp(showSignIn: showSignIn));
  runApp(MyApp());
}

final navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatefulWidget {

  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // final bool showSignIn;
  final utils = Utils();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      scaffoldMessengerKey: utils.messengerKey,
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      // home: showSignIn ? SignIn() : SplashScreen(),
      home: SplashScreen(),
    );
  }
}
