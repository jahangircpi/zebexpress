import 'package:democab/model/fare.dart';
import 'package:democab/model/image.dart';
import 'package:democab/model/user.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import 'dataprovider/appdata.dart';

String serverKey =
    'key=AAAA-3klaiQ:APA91bFNnYkw7pPvKPlSkKw6nPmIRDSTb16MibQIy5UbLMFB8Ve1ogHRXvoC27koxx0Je2HtoADsD1MwPA9EDcmK0MYx-vQjQYMLuq86Wk5ErR8w_KpAweEQi90jmnB5xniwXyf-lgbk';
String mapKey = 'AIzaSyCx0eobeVFyAU7LpvdntMaPbq0PnWaf_mQ';
String baseUrl = 'https://delivery.talabscollection.com';

final CameraPosition googlePlex = CameraPosition(
  target: LatLng(37.42796133580664, -122.085749655962),
  zoom: 14.4746,
);

FirebaseUser currentFirebaseUser;

DatabaseReference msgRef;

User currentUserInfo;
UserIcon userIcon;

Fare fare;

launchURL(String url) async {
  if (await canLaunch(url)) {
    await launch(url, forceWebView: true);
  } else {
    print('Could not launch $url');
  }
}

void clearOut(context) {
  Provider.of<AppData>(context, listen: false).updateMessageKeys([]);
  Provider.of<AppData>(context, listen: false).updateWallet('0');
  Provider.of<AppData>(context, listen: false).updateTripCount(0);
  Provider.of<AppData>(context, listen: false).clearTripHistory();
  Provider.of<AppData>(context, listen: false).clearMessage();
  List<String> tripHistoryKeys = [];
  Provider.of<AppData>(context, listen: false).updateTripKeys(tripHistoryKeys);
}

void showSnackBar(String title, scaffoldKey) {
  final snackbar = SnackBar(
    content: Text(
      title,
      textAlign: TextAlign.center,
      style: TextStyle(fontSize: 15),
    ),
  );
  scaffoldKey.currentState.showSnackBar(snackbar);
}
