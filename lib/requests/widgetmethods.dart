import 'package:democab/dataprovider/appdata.dart';
import 'package:democab/globalvariable.dart';
import 'package:democab/model/address.dart';
import 'package:democab/requests/requesthelper.dart';
import 'package:democab/widget/progressDialog.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MyMethods {
  static void getPlaceDetails(String placeID, context) async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) => ProgressDialog(
              status: 'Please wait...',
            ));
    String url =
        'https://maps.googleapis.com/maps/api/place/details/json?placeid=$placeID&key=$mapKey';
    var response = await RequestHelper.getRequest(url);
    //after verification
    Navigator.pop(context);

    if (response == 'failed') {
      return;
    }
    if (response['status'] == 'OK') {
      //address
      Address thisPlace = Address();
      thisPlace.placeName = response['result']['name'];
      thisPlace.placeId = placeID;
      thisPlace.latitude = response['result']['geometry']['location']['lat'];
      thisPlace.longitude = response['result']['geometry']['location']['lng'];

      Provider.of<AppData>(context, listen: false)
          .updateDestinationAddress(thisPlace);

      Navigator.pop(context, 'getDirection');
      //Navigator.popAndPushNamed(context, ShareRidePage.id);
      // Navigator.push(
      //   context,
      //   MaterialPageRoute(
      //     builder: (context) => PersonalRidePage(),
      //     // Pass the arguments as part of the RouteSettings. The
      //     // DetailScreen reads the arguments from these settings.
      //     settings: RouteSettings(
      //       arguments: 'getDirection',
      //     ),
      //   ),
      // );
    }
  }

  static void pickAddress(pickID, context) async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) => ProgressDialog(
              status: 'Please wait...',
            ));
    String url =
        'https://maps.googleapis.com/maps/api/place/details/json?placeid=$pickID&key=$mapKey';
    var response = await RequestHelper.getRequest(url);
    //after verification
    Navigator.pop(context);

    if (response == 'failed') {
      return;
    }
    if (response['status'] == 'OK') {
      //address
      Address thisPlace = Address();
      thisPlace.placeName = response['result']['name'];
      thisPlace.placeId = pickID;
      thisPlace.latitude = response['result']['geometry']['location']['lat'];
      thisPlace.longitude = response['result']['geometry']['location']['lng'];

      Provider.of<AppData>(context, listen: false)
          .updateDeliPickAddress(thisPlace);
    }
  }

  static void showLoading(String text, context) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) => ProgressDialog(
        status: text,
      ),
    );
  }
}
