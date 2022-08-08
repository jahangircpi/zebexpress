import 'package:democab/brand_colors.dart';
import 'package:democab/dataprovider/appdata.dart';
import 'package:democab/globalvariable.dart';
import 'package:democab/requests/requestmethods.dart';
import 'package:democab/requests/stripeService.dart';
import 'package:democab/tabs/historytab.dart';
import 'package:democab/widget/BrandDivider.dart';
import 'package:democab/widget/TaxiButton.dart';
import 'package:democab/widget/progressDialog.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class WalletTab extends StatefulWidget {
  @override
  _WalletTabState createState() => _WalletTabState();
}

class _WalletTabState extends State<WalletTab> {
  var fundCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    // StripeService.init();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
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
                    'Total Amount',
                    style: TextStyle(color: Colors.white),
                  ),
                  Text(
                    (currentUserInfo != null)
                        ? '\NGN${currentUserInfo.wallet}'
                        : '...',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 40,
                        fontFamily: 'Brand-Bold'),
                  )
                ],
              ),
            ),
          ),
          FlatButton(
            padding: EdgeInsets.all(0),
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => HistoryTab()));
            },
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 30, vertical: 18),
              child: Row(
                children: [
                  Image.asset(
                    'assets/taxi.png',
                    width: 70,
                  ),
                  SizedBox(
                    width: 16,
                  ),
                  Text(
                    'Total Trips',
                    style: TextStyle(fontSize: 16),
                  ),
                  Expanded(
                      child: Container(
                          child: Text(
                    Provider.of<AppData>(context, listen: false)
                        .tripCount
                        .toString(),
                    textAlign: TextAlign.end,
                    style: TextStyle(fontSize: 18),
                  ))),
                ],
              ),
            ),
          ),
          BrandDivider(),
          SizedBox(
            height: 10,
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 30, vertical: 18),
            child: Container(
              decoration: BoxDecoration(
                color: BrandColors.colorLightGrayFair,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Padding(
                padding: const EdgeInsets.all(2.0),
                child: TextField(
                  controller: fundCtrl,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    hintText: 'Amount',
                    fillColor: BrandColors.colorLightGrayFair,
                    filled: true,
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding:
                        EdgeInsets.only(left: 10, top: 8, bottom: 8),
                  ),
                ),
              ),
            ),
          ),
          BrandDivider(),
          SizedBox(
            height: 10,
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 30, vertical: 18),
            child: TaxiButton(
              title: 'Fund Wallet',
              color: BrandColors.colorTextDark,
              onPressed: () async {
                if (fundCtrl.text.isNotEmpty && int.parse(fundCtrl.text) > 9) {
                  double f = double.tryParse(fundCtrl.text);
                  // payViaNewCard(context);
                  //var chk = await beginPayment(context, f);
                  // if (chk) {
                  //   setState(() {
                  //     currentUserInfo.wallet =
                  //         currentUserInfo.wallet + int.parse(fundCtrl.text);
                  //   });
                  // }
                  var n = int.parse(fundCtrl.text);
                } else {
                  RequestMethods.showSnackbar(
                      'Enter valid amount eg: NGN1000', context);
                }
                fundCtrl.text = '';
              },
              // child: Container(
              //   width: double.infinity,
              //   child: Center(
              //       child: Text(
              //     'Fund My Wallet',
              //     style:
              //         TextStyle(fontFamily: 'Brand-Bold', color: Colors.white),
              //   )),
              // ),
            ),
          ),
        ],
      ),
    );
  }

  // payViaNewCard(BuildContext context) async {
  //   showDialog(
  //     barrierDismissible: false,
  //     context: context,
  //     builder: (BuildContext context) => ProgressDialog(
  //       status: 'Processing',
  //     ),
  //   );
  //   var response =
  //       await StripeService.payWithNewCard(amount: '1500', currency: 'USD');
  //   Navigator.pop(context);
  //   Scaffold.of(context).showSnackBar(SnackBar(
  //     content: Text(response.message),
  //     duration:
  //         new Duration(milliseconds: response.success == true ? 1200 : 3000),
  //   ));
  // }
}
