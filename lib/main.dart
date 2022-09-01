import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'splashScreen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'Utils.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'overview.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  AwesomeNotifications().initialize(
      null,
      [
        NotificationChannel(
          channelKey: 'basic_channel',
          channelName: 'Basic Notifications',
          channelDescription: 'notification',
          defaultColor: Colors.indigo,
          ledColor: Colors.white,
          playSound: false,
          enableLights: true,
          enableVibration: true,
        )
      ]
  );
  await Firebase.initializeApp();

  runApp(MyApp());
}

final navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatefulWidget {

  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final utils = Utils();

  @override
  void initState() {
    super.initState();

    AwesomeNotifications().displayedStream.listen((notification) async {
      // on display stream, we need to delete that notification from FireStore notifications array
      FirebaseAuth auth = FirebaseAuth.instance;
      String uid = auth.currentUser!.uid.toString();
      final doc = FirebaseFirestore.instance.collection('user_data').doc(uid);
      var snapshot =  await doc.get();

      var tempList = snapshot.data()!['notifications'];

      int index = 0;
      for(var entry in tempList)
      {
        if(entry['title'] == notification.title)
          {
            tempList.removeAt(index);
            break;
          }
        index = index + 1;
      }

      // update specific fields of the document
      doc.update({
        'notifications': tempList,
      });
    });

    // when a user taps on displayed notification, redirect to Overview screen
    // TODO: redirect to Goals screen but with bottom navbar of overview screen
    AwesomeNotifications().actionStream.listen((notification) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => Overview()));

    });
  }

  @override
  void dispose() {
    super.dispose();
    AwesomeNotifications().actionSink.close();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      scaffoldMessengerKey: utils.messengerKey,
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }

}
