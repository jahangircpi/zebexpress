import 'package:democab/screens/home.dart';
import 'package:democab/screens/register.dart';
import 'package:democab/widget/ForgotDialog.dart';
import 'package:democab/widget/TaxiButton.dart';
import 'package:democab/widget/progressDialog.dart';
import 'package:connectivity/connectivity.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LoginPage extends StatefulWidget {
  static const String id = 'login';
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
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
  var emailCtrl = TextEditingController();
  var passwordCtrl = TextEditingController();

  void login() async {
    //show dialog
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) => ProgressDialog(
        status: 'Processing',
      ),
    );
    final FirebaseUser user = (await _auth
            .signInWithEmailAndPassword(
                email: emailCtrl.text, password: passwordCtrl.text)
            .catchError((e) {
      //check for error
      Navigator.pop(context);
      PlatformException thisE = e;
      showSnackBar(thisE.message);
    }))
        .user;
    if (user != null) {
      DatabaseReference userRef =
          FirebaseDatabase.instance.reference().child('users/${user.uid}');
      userRef.once().then((DataSnapshot snapshot) => {
            if (snapshot.value != null)
              {
                Navigator.pushNamedAndRemoveUntil(
                    context, MyMainHomePage.id, (route) => false),
              }
          });
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
                  image: AssetImage(
                    'assets/spalshScreenwhite.jpeg',
                  ),
                  height: 150.0,
                  width: 150.0,
                  alignment: Alignment.center,
                ),
                SizedBox(
                  height: 40,
                ),
                Text(
                  'Sign In',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 25, fontFamily: 'Brand-Bold'),
                ),
                Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Column(
                    children: [
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
                        height: 10.0,
                      ),
                      GestureDetector(
                        onTap: () {
                          forgetpassword();
                        },
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Forgot Password? Click me!'),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 40.0,
                      ),
                      TaxiButton(
                        title: 'LOGIN',
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
                          if (!emailCtrl.text.contains('@')) {
                            showSnackBar('Please provide a valid email');
                            return;
                          }
                          if (passwordCtrl.text.length < 6) {
                            showSnackBar(
                                'Password must be at least 7 characters');
                            return;
                          }
                          login();
                        },
                      )
                    ],
                  ),
                ),
                FlatButton(
                  onPressed: () {
                    Navigator.pushNamedAndRemoveUntil(
                        context, RegistrationPage.id, (route) => false);
                  },
                  child: Text('Don\'t have an account, sign up here'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void forgetpassword() async {
    var res = await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) => ForgotPassDialog());
    if (res == 'emailMessage') {
      showSnackBar('Check your email');
    }
  }
}
