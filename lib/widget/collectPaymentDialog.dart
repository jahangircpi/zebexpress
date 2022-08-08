import 'dart:math';

import 'package:democab/brand_colors.dart';
import 'package:democab/widget/TaxiButton.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import 'package:democab/globalvariable.dart';

import 'BrandDivider.dart';

class CollectPayment extends StatefulWidget {
  final String paymentMethod;
  final int fares;
  final String driverID;

  CollectPayment({this.paymentMethod, this.fares, this.driverID});

  @override
  _CollectPaymentState createState() => _CollectPaymentState();
}

class _CollectPaymentState extends State<CollectPayment> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      backgroundColor: Colors.transparent,
      child: Container(
        margin: EdgeInsets.all(4.0),
        width: double.infinity,
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(4)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            SizedBox(
              height: 20,
            ),
            Text('${widget.paymentMethod.toUpperCase()} PAYMENT'),
            SizedBox(
              height: 20,
            ),
            BrandDivider(),
            SizedBox(
              height: 16.0,
            ),
            Text(
              '\NGN${widget.fares}',
              style: TextStyle(fontFamily: 'Brand-Bold', fontSize: 50),
            ),
            SizedBox(
              height: 16,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Amount above is the total fares to be charged to the rider',
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(
              height: 30,
            ),
            Container(
              width: 230,
              child: TaxiButton(
                title:
                    (widget.paymentMethod == 'cash') ? 'PAY CASH' : 'CONFIRM',
                color: BrandColors.colorGreen,
                onPressed: () {
                  if (widget.paymentMethod == 'cash') {
                    Navigator.pop(context, 'close');
                  }
                  if (widget.paymentMethod == 'wallet') {
                    if (widget.fares < currentUserInfo.wallet) {
                      deductPayment(context);
                      Navigator.pop(context, 'close');
                    } else {
                      Navigator.pop(context, 'low');
                    }
                    //Navigator.pop(context, 'close');
                  }
                },
              ),
            ),
            SizedBox(
              height: 40,
            )
          ],
        ),
      ),
    );
  }

  String generateRandomNumber() {
    var random = new Random();
    var rand = new Random();
    return 'txRef_${random.nextInt(999999999)}_${rand.nextInt(999999999)}';
  }

  void deductPayment(context) async {
    var wallet = currentUserInfo.wallet - widget.fares;

    DatabaseReference userWlt = FirebaseDatabase.instance
        .reference()
        .child('users/${currentFirebaseUser.uid}/wallet');
    userWlt.set(wallet);

    // var result;
    // //update driver wallet
    // var drivereran = await FirebaseDatabase.instance
    //     .reference()
    //     .child('drivers/${widget.driverID}/earnings')
    //     .once()
    //     .then((snapshot) {
    //   result = snapshot.value;
    //   //print(result);
    // });

    // print(result);
    // //process driver account

    // var f = widget.fares - (widget.fares * 0.1);
    // var newEarn = result + f;

    // drivereran.set(newEarn);

    setState(() {
      currentUserInfo.wallet = wallet;
    });
    //RequestMethods.showSnackbar(
    // '${widget.fares} was deducted Successfully', context);

    //Navigator.pop(context, 'close');
  }
}
