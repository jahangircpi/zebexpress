import 'dart:convert';

import 'package:democab/brand_colors.dart';
import 'package:democab/globalvariable.dart';
import 'package:democab/widget/TaxiOutlineButton.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ForgotPassDialog extends StatelessWidget {
  final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();
  final forgotemail = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      child: Container(
        margin: EdgeInsets.all(0),
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Padding(
          padding: EdgeInsets.all(10.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(
                  height: 10,
                ),
                Text(
                  'Forgot Password',
                  style: TextStyle(fontSize: 16.0, fontFamily: 'Brand-Regular'),
                ),
                SizedBox(
                  height: 25,
                ),
                Padding(
                  padding: EdgeInsets.all(1.0),
                  child: TextField(
                    controller: forgotemail,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'Enter your email',
                      labelStyle: TextStyle(
                        color: Colors.grey,
                        fontSize: 14.0,
                      ),
                    ),
                    style: TextStyle(fontSize: 20),
                  ),
                ),
                SizedBox(
                  height: 30,
                ),
                Container(
                  width: 200,
                  child: TaxiOutlineButton(
                    title: 'SUBMIT',
                    color: BrandColors.colorLightGrayFair,
                    onPressed: () {
                      mailEmail();
                      Navigator.pop(context, 'emailMessage');
                    },
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void mailEmail() async {
    Map<String, String> headerMap = {
      'Content-Type': 'application/json',
    };
    Map bodyMap = {
      'email': forgotemail.text,
    };
    var response = await http.post('$baseUrl/forgot/users',
        headers: headerMap, body: jsonEncode(bodyMap));
    if (response.statusCode != null) {
      print('SENTEMAIL_____$response');
    }
  }
}
