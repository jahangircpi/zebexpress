import 'dart:convert';
import 'dart:io';

import 'package:democab/brand_colors.dart';
import 'package:democab/globalvariable.dart';
import 'package:democab/requests/requesthelper.dart';
import 'package:democab/screens/home.dart';
import 'package:democab/widget/TaxiButton.dart';
import 'package:democab/widget/progressDialog.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class PromoCode extends StatefulWidget {
  static const String id = 'promo';
  @override
  _PromoCodeState createState() => _PromoCodeState();
}

class _PromoCodeState extends State<PromoCode> {
  final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();

  bool rememberMe = false;

  var promocodeCtrl = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: BrandColors.colorTextDark,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          'Promo code',
          style: TextStyle(fontFamily: 'Brand-Bold'),
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.pushNamedAndRemoveUntil(
                context, MyMainHomePage.id, (route) => false);
          },
          icon: Icon(Icons.arrow_back_ios),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              color: BrandColors.colorTextDark,
              width: double.infinity,
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 70),
                child: Column(
                  children: [
                    Text(
                      'Promo Code',
                      style: TextStyle(color: Colors.white),
                    ),
                    Text(
                      (currentUserInfo.promoCode != null)
                          ? '${currentUserInfo.promoCode}'
                          : 'No Entry',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 40,
                          fontFamily: 'Brand-Bold'),
                    )
                  ],
                ),
              ),
            ),
            Container(
              height: Platform.isAndroid ? 400 : 350,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(14),
                    topRight: Radius.circular(14)),
              ),
              child: Column(
                children: [
                  SizedBox(
                    height: 20,
                  ),
                  Row(
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 11.0),
                        child: Text(
                          'Activate Promo Code',
                          style: TextStyle(
                              fontFamily: 'Brand-Bold',
                              fontSize: 27,
                              color: BrandColors.colorTextLight),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 14,
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 11.0),
                    child: Column(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: BrandColors.colorLightGrayFair,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: TextField(
                            controller: promocodeCtrl,
                            keyboardType: TextInputType.name,
                            decoration: InputDecoration(
                              hintText: 'Promo Code',
                              fillColor: BrandColors.colorLightGrayFair,
                              filled: true,
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding:
                                  EdgeInsets.only(left: 10, top: 8, bottom: 8),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 14,
                        ),
                        TaxiButton(
                          title: 'Submit',
                          color: Colors.black,
                          height: 40,
                          onPressed: () {
                            sendCode();
                            print('___________pressed');
                          },
                        ),
                      ],
                    ),
                  ),
                  Divider(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future sendCode() async {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) => ProgressDialog(
        status: 'Processing',
      ),
    );
    final url = '$baseUrl/confirm-promo';
    Map<String, String> headerMap = {
      'Content-Type': 'application/x-www-form-urlencoded',
    };
    Map bodyMap = {
      'code': promocodeCtrl.text,
    };
    var response = await RequestHelper.postRequest(url, headerMap, bodyMap);

    if (response["status"] == 200) {
      DatabaseReference userRef = FirebaseDatabase.instance
          .reference()
          .child('users/${currentUserInfo.id}/promoCode');
      userRef.set(promocodeCtrl.text);
      setState(() {
        currentUserInfo.promoCode = promocodeCtrl.text;
      });
      showSnackBar('Promo Code Activated', scaffoldKey);
      print('_______________trues');
    } else {
      showSnackBar('Promo Code Denied', scaffoldKey);
      print('error');
    }

    promocodeCtrl.text = '';
    Navigator.pop(context);
  }
}
