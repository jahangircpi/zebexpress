import 'package:democab/brand_colors.dart';
import 'package:democab/dataprovider/appdata.dart';
import 'package:democab/globalvariable.dart';
import 'package:democab/model/prediction.dart';
import 'package:democab/requests/requesthelper.dart';
import 'package:democab/widget/BrandDivider.dart';
import 'package:democab/widget/pickupTile.dart';
import 'package:democab/widget/predictiontile.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BookForSomeone extends StatefulWidget {
  final String type;
  BookForSomeone({Key key, @required this.type}) : super(key: key);
  @override
  _BookForSomeoneState createState() => _BookForSomeoneState();
}

class _BookForSomeoneState extends State<BookForSomeone> {
  final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();
  var pickupCtrl = TextEditingController();
  var destinationCtrl = TextEditingController();
  var phoneCtrl = TextEditingController();
  var item = TextEditingController();

  var focusDestination = FocusNode();
  bool focused = false;

  bool myNumber = false;
  bool myPickup = false;

  void setFocus() {
    if (!focused) {
      FocusScope.of(context).requestFocus(focusDestination);
      focused = true;
    }
  }

  List<Prediction> destinationPredictionList = [];
  List<Prediction> pickupPredictionList = [];

  void searchPlace(String placeName) async {
    if (placeName.length > 1) {
      String url =
          'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$placeName&key=$mapKey&sessiontoken=1234567890&components=country:ng';
      var response = await RequestHelper.getRequest(url);

      if (response == 'failed') {
        return;
      }
      if (response['status'] == 'OK') {
        var predictionJson = response['predictions'];
        //create list
        var thisList = (predictionJson as List)
            .map((e) => Prediction.fromJson(e))
            .toList();
        //update list
        setState(() {
          destinationPredictionList = thisList;
        });
      }
    }
  }

  void searchPickup(String placeName) async {
    if (placeName.length > 1) {
      String url =
          'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$placeName&key=$mapKey&sessiontoken=1234567890&components=country:ng';
      var response = await RequestHelper.getRequest(url);

      if (response == 'failed') {
        return;
      }
      if (response['status'] == 'OK') {
        var predictionJson = response['predictions'];
        //create list
        var thisList = (predictionJson as List)
            .map((e) => Prediction.fromJson(e))
            .toList();
        //update list
        setState(() {
          pickupPredictionList = thisList;
        });
      }
    }
  }

  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              height: 290,
              decoration: BoxDecoration(color: Colors.white, boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 5.0,
                  spreadRadius: 0.5,
                  offset: Offset(0.7, 0.7),
                ),
              ]),
              child: Padding(
                padding:
                    EdgeInsets.only(left: 24, top: 48, right: 24, bottom: 20),
                child: SingleChildScrollView(
                  child: Column(
                    children: <Widget>[
                      SizedBox(
                        height: 5,
                      ),
                      Stack(
                        children: [
                          GestureDetector(
                              onTap: () {
                                Navigator.pop(context);
                              },
                              child: Icon(Icons.arrow_back)),
                          Center(
                            child: Text(
                              'Set Pickup and Location',
                              style: TextStyle(
                                  fontSize: 18, fontFamily: 'Brand-Bold'),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 18,
                      ),
                      Row(
                        children: [
                          Image.asset(
                            'assets/box.png',
                            height: 16,
                            width: 16,
                          ),
                          SizedBox(
                            width: 18,
                          ),
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: BrandColors.colorLightGrayFair,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(2.0),
                                child: TextField(
                                  onChanged: (value) {
                                    checkValue(value);
                                    Provider.of<AppData>(context, listen: false)
                                        .getItem(value);
                                  },
                                  controller: item,
                                  keyboardType: TextInputType.text,
                                  decoration: InputDecoration(
                                    hintText: 'Type of Item',
                                    fillColor: BrandColors.colorLightGrayFair,
                                    filled: true,
                                    border: InputBorder.none,
                                    isDense: true,
                                    contentPadding: EdgeInsets.only(
                                        left: 10, top: 8, bottom: 8),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        children: [
                          Image.asset(
                            'assets/telephone.png',
                            height: 16,
                            width: 16,
                          ),
                          SizedBox(
                            width: 18,
                          ),
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: BrandColors.colorLightGrayFair,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(2.0),
                                child: TextField(
                                  onChanged: (value) {
                                    checkValue(value);
                                    Provider.of<AppData>(context, listen: false)
                                        .getMobile(value);
                                  },
                                  controller: phoneCtrl,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    hintText: (widget.type == 'deliver')
                                        ? 'Phone number of picker'
                                        : 'Rider\'s phone number',
                                    fillColor: BrandColors.colorLightGrayFair,
                                    filled: true,
                                    border: InputBorder.none,
                                    isDense: true,
                                    contentPadding: EdgeInsets.only(
                                        left: 10, top: 8, bottom: 8),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      (Provider.of<AppData>(context).mydest == true)
                          ? Row(
                              children: [
                                Image.asset(
                                  'assets/pickicon.png',
                                  height: 16,
                                  width: 16,
                                ),
                                SizedBox(
                                  width: 18,
                                ),
                                Expanded(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: BrandColors.colorLightGrayFair,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Padding(
                                      padding: EdgeInsets.all(2.0),
                                      child: TextField(
                                        onChanged: (value) {
                                          searchPickup(value);
                                        },
                                        controller: pickupCtrl,
                                        decoration: InputDecoration(
                                          hintText: 'Pickup Location',
                                          fillColor:
                                              BrandColors.colorLightGrayFair,
                                          filled: true,
                                          border: InputBorder.none,
                                          isDense: true,
                                          contentPadding: EdgeInsets.only(
                                              left: 10, top: 8, bottom: 8),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : Row(),
                      SizedBox(
                        height: 10,
                      ),
                      (Provider.of<AppData>(context).myPickup == true)
                          ? Row(
                              children: [
                                Image.asset(
                                  'assets/desticon.png',
                                  height: 16,
                                  width: 16,
                                ),
                                SizedBox(
                                  width: 18,
                                ),
                                Expanded(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: BrandColors.colorLightGrayFair,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(2.0),
                                      child: TextField(
                                        onChanged: (value) {
                                          searchPlace(value);
                                        },
                                        focusNode: focusDestination,
                                        controller: destinationCtrl,
                                        decoration: InputDecoration(
                                          hintText: 'Destination',
                                          fillColor:
                                              BrandColors.colorLightGrayFair,
                                          filled: true,
                                          border: InputBorder.none,
                                          isDense: true,
                                          contentPadding: EdgeInsets.only(
                                              left: 10, top: 8, bottom: 8),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : Row(),
                    ],
                  ),
                ),
              ),
            ),
            (destinationPredictionList.length > 0)
                ? Padding(
                    padding:
                        EdgeInsets.symmetric(vertical: 8.0, horizontal: 16),
                    child: ListView.separated(
                      padding: EdgeInsets.all(0),
                      itemBuilder: (context, index) {
                        return PredictionTile(
                          prediction: destinationPredictionList[index],
                        );
                      },
                      separatorBuilder: (BuildContext context, int index) =>
                          BrandDivider(),
                      itemCount: destinationPredictionList.length,
                      shrinkWrap: true,
                      physics: ClampingScrollPhysics(),
                    ),
                  )
                : Container(),
            (pickupPredictionList.length > 0)
                ? Padding(
                    padding:
                        EdgeInsets.symmetric(vertical: 8.0, horizontal: 16),
                    child: ListView.separated(
                      padding: EdgeInsets.all(0),
                      itemBuilder: (context, index) {
                        return PickupTile(
                          prediction: pickupPredictionList[index],
                          pick: pickupCtrl,
                        );
                      },
                      separatorBuilder: (BuildContext context, int index) =>
                          BrandDivider(),
                      itemCount: pickupPredictionList.length,
                      shrinkWrap: true,
                      physics: ClampingScrollPhysics(),
                    ),
                  )
                : Container(),
          ],
        ),
      ),
    );
  }

  void checkValue(String value) {
    if (value.length > 10) {
      setState(() {
        Provider.of<AppData>(context, listen: false).checkDest(true);
      });
      Provider.of<AppData>(context, listen: false).getMobile(phoneCtrl.text);
    } else {
      setState(() {
        Provider.of<AppData>(context, listen: false).checkDest(false);
        Provider.of<AppData>(context, listen: false).checkPickup(false);
      });
    }
    //return false;
  }
}
