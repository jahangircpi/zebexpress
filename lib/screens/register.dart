import 'package:democab/screens/loginpage.dart';
import 'package:democab/screens/home.dart';
import 'package:democab/widget/TaxiButton.dart';
import 'package:democab/widget/progressDialog.dart';
import 'package:connectivity/connectivity.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class RegistrationPage extends StatefulWidget {
  static const String id = 'register';
  @override
  _RegistrationPage createState() => _RegistrationPage();
}

class _RegistrationPage extends State<RegistrationPage> {
  final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();
  void showSnackBar(String title) {
    final snackbar = SnackBar(
      content: Text(
        title,
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 15),
      ),
    );
    scaffoldKey.currentState.showSnackBar(snackbar);
  }

  final FirebaseAuth _auth = FirebaseAuth.instance;

  var fullnameCtrl = TextEditingController();
  var phoneCtrl = TextEditingController();
  var emailCtrl = TextEditingController();
  var passwordCtrl = TextEditingController();

  void registerUser() async {
    //show dialog
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) => ProgressDialog(
        status: 'Registering...',
      ),
    );
    final FirebaseUser user = (await _auth
            .createUserWithEmailAndPassword(
                email: emailCtrl.text, password: passwordCtrl.text)
            .catchError((e) {
      //check for error
      Navigator.pop(context);
      PlatformException thisE = e;
      showSnackBar(thisE.message);
    }))
        .user;

    //check for error
    Navigator.pop(context);
    if (user != null) {
      DatabaseReference newUserRef =
          FirebaseDatabase.instance.reference().child('users/${user.uid}');

      //prepare data
      Map userMap = {
        'fullname': fullnameCtrl.text,
        'email': emailCtrl.text,
        'phone': phoneCtrl.text,
        'wallet': 0,
        'promoCode': null,
        'link': 'assets/user_icon.png',
      };
      newUserRef.set(userMap);
      //Take to mainPage
      Navigator.pushNamedAndRemoveUntil(
          context, MyMainHomePage.id, (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(8.0),
            child: Column(
              children: [
                SizedBox(
                  height: 70,
                ),
                Image(
                  image: AssetImage('assets/spalshScreenwhite.jpeg'),
                  height: 150.0,
                  width: 150.0,
                  alignment: Alignment.center,
                ),
                SizedBox(
                  height: 30,
                ),
                Text(
                  'Create An Account',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 25, fontFamily: 'Brand-Bold'),
                ),
                Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      //fullname
                      TextField(
                        controller: fullnameCtrl,
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(
                          labelText: 'Full name',
                          labelStyle: TextStyle(
                            color: Colors.grey,
                            fontSize: 14.0,
                          ),
                        ),
                        style: TextStyle(fontSize: 20),
                      ),
                      SizedBox(
                        height: 10.0,
                      ),
                      //emailAddress
                      TextField(
                        controller: emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: 'Email Address',
                          labelStyle: TextStyle(
                            color: Colors.grey,
                            fontSize: 14.0,
                          ),
                        ),
                        style: TextStyle(fontSize: 20),
                      ),
                      SizedBox(
                        height: 10.0,
                      ),
                      //Phone Number
                      TextField(
                        controller: phoneCtrl,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          labelText: 'Phone Number',
                          labelStyle: TextStyle(
                            color: Colors.grey,
                            fontSize: 14.0,
                          ),
                        ),
                        style: TextStyle(fontSize: 20),
                      ),
                      SizedBox(
                        height: 10.0,
                      ),
                      //Password
                      TextField(
                        controller: passwordCtrl,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          labelStyle: TextStyle(
                            color: Colors.grey,
                            fontSize: 14.0,
                          ),
                        ),
                        style: TextStyle(fontSize: 20),
                      ),

                      SizedBox(
                        height: 40.0,
                      ),
                      TaxiButton(
                        title: 'REGISTER',
                        color: Colors.black,
                        height: 50,
                        onPressed: () async {
                          var connect =
                              await Connectivity().checkConnectivity();
                          if (connect != ConnectivityResult.mobile &&
                              connect != ConnectivityResult.wifi) {
                            showSnackBar('No internet connection');
                            return;
                          }
                          if (fullnameCtrl.text.length < 3) {
                            showSnackBar('Please provide a valid name');
                            return;
                          }
                          if (phoneCtrl.text.length < 10) {
                            showSnackBar('Please provide a valid phone number');
                            return;
                          }
                          if (passwordCtrl.text.length < 6) {
                            showSnackBar(
                                'Password must be at least 7 characters');
                            return;
                          }
                          if (!emailCtrl.text.contains('@')) {
                            showSnackBar('Please provide a valid email');
                            return;
                          }

                          registerUser();
                        },
                      ),
                    ],
                  ),
                ),
                FlatButton(
                  onPressed: () {
                    Navigator.pushNamedAndRemoveUntil(
                        context, LoginPage.id, (route) => false);
                  },
                  child: Text('Have an account? Sign in here'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
