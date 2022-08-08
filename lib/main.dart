import 'dart:io';

import 'package:democab/dataprovider/appdata.dart';
import 'package:democab/globalvariable.dart';
import 'package:democab/screens/home.dart';
import 'package:democab/screens/loginpage.dart';
import 'package:democab/screens/profile.dart';
import 'package:democab/screens/register.dart';
import 'package:democab/widget/promocode.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final FirebaseApp app = await FirebaseApp.configure(
    name: 'db2',
    options: Platform.isIOS
        ? const FirebaseOptions(
            googleAppID: '1:297855924061:ios:c6de2b69b03a5be8',
            gcmSenderID: '297855924061',
            databaseURL: 'https://democab-f0957-default-rtdb.firebaseio.com/',
          )
        : const FirebaseOptions(
            googleAppID: '1:1080069286436:android:3796782afb715c42c306b1',
            apiKey: 'AIzaSyCx0eobeVFyAU7LpvdntMaPbq0PnWaf_mQ',
            databaseURL: 'https://zeexpress-4c406-default-rtdb.firebaseio.com/',
          ),
  );
  currentFirebaseUser = await FirebaseAuth.instance.currentUser();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AppData(),
      child: MaterialApp(
        title: 'Zebxpress',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          fontFamily: 'Brand-Regular',
          //primarySwatch: Colors.black,
          primaryColor: Colors.black,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        // initialRoute:
        //     (currentFirebaseUser == null) ? LoginPage.id : MyMainHomePage.id,
        home: Splash(),
        routes: {
          RegistrationPage.id: (context) => RegistrationPage(),
          LoginPage.id: (context) => LoginPage(),
          MyMainHomePage.id: (context) => MyMainHomePage(),
          ProfilePage.id: (context) => ProfilePage(),
          PromoCode.id: (context) => PromoCode(),
        },
      ),
    );
  }
}

class Splash extends StatefulWidget {
  @override
  _SplashState createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  check() {
    Future.delayed(Duration(milliseconds: 2000), () {
      Navigator.pushNamedAndRemoveUntil(
          context,
          (currentFirebaseUser == null) ? LoginPage.id : MyMainHomePage.id,
          (route) => false);
    });
  }

  Widget build(BuildContext context) {
    check();
    return Scaffold(
      backgroundColor: Colors.white,
      body: Image.asset(
        'assets/spalshScreenwhite.jpeg',
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.contain,
      ),
    );
  }
}
