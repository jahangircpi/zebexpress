import 'dart:convert';
import 'dart:math';

import 'package:democab/dataprovider/appdata.dart';
import 'package:democab/globalvariable.dart';
import 'package:democab/model/address.dart';
import 'package:democab/model/directiondetails.dart';
import 'package:democab/model/fare.dart';
import 'package:democab/model/history.dart';
import 'package:democab/model/image.dart';
import 'package:democab/model/message.dart';
import 'package:democab/model/user.dart';
import 'package:democab/requests/requesthelper.dart';
import 'package:connectivity/connectivity.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class RequestMethods {
  static Future<String> findCordinatAddress(Position position, context) async {
    String placeAddress = '';
    var connect = await Connectivity().checkConnectivity();
    if (connect != ConnectivityResult.mobile &&
        connect != ConnectivityResult.wifi) {
      return placeAddress;
    }
    String url =
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=$mapKey';
    var response = await RequestHelper.getRequest(url);
    if (response != 'failed') {
      placeAddress = response['results'][0]['formatted_address'];

      Address pickupAddress = new Address();

      pickupAddress.longitude = position.longitude;
      pickupAddress.latitude = position.latitude;
      pickupAddress.placeName = placeAddress;
      Provider.of<AppData>(context, listen: false)
          .updaatePickupAddress(pickupAddress);
    }

    return placeAddress;
  }

  static Future<DirectionDetails> getDirectionDetails(
      LatLng startPosition, LatLng endPosition) async {
    String url =
        'https://maps.googleapis.com/maps/api/directions/json?origin=${startPosition.latitude},${startPosition.longitude}&destination=${endPosition.latitude},${endPosition.longitude}&mode=driving&key=$mapKey';
    var response = await RequestHelper.getRequest(url);
    if (response == 'failed') {
      return null;
    }
    DirectionDetails directionDetails = DirectionDetails();
    directionDetails.durationText =
        response['routes'][0]['legs'][0]['duration']['text'];
    directionDetails.durationValue =
        response['routes'][0]['legs'][0]['duration']['value'];

    directionDetails.distanceText =
        response['routes'][0]['legs'][0]['distance']['text'];
    directionDetails.distanceValue =
        response['routes'][0]['legs'][0]['distance']['value'];

    directionDetails.encodedPoints =
        response['routes'][0]['overview_polyline']['points'];
    return directionDetails;
  }

  static Future getFare(context) async {
    String url = '$baseUrl/fares/api';
    var response = await RequestHelper.getRequest(url);
    if (response == 'failed') {
      return null;
    }
    fare = Fare.fromJson(response);
    // Fare fare = Fare();
    // fare.baseFare = response['base_fare'];
    // fare.perKm = response['fare_per_km'];
    // fare.perMinute = response['fare_per_minute'];

    Provider.of<AppData>(context, listen: false).updateFare(fare);
    //return fare;
    print(response);
  }

  static int estimateFares(DirectionDetails details) {
    //per km = $0.3,
    //per minute = $0.2,
    //base fare = $3,
    //var res = getFare();

    int baseFare = 3;
    double distanceFare = (details.distanceValue / 1000) * 0.3; //per Km
    var timeFare = (details.durationValue / 60) * 0.2; //per minute
    double totalFare = baseFare + distanceFare + timeFare;
    return totalFare.truncate();
  }

  static int estimateFare(DirectionDetails details, Fare fare) {
    var baseFare = fare.baseFare;
    var discount = fare.promo / 100;
    var n = details.distanceValue / 1000;
    if (n < 6) {
      double total =
          currentUserInfo.promoCode != null ? 500.0 * discount : 500.0;
      return total.truncate();
      //print('___________${details.distanceValue}');
    }
    var distanceFare = (details.distanceValue / 1000) * fare.perKm; //per Km
    var timeFare = (details.durationValue / 60) * fare.perMinute; //per minute
    double totalFare = currentUserInfo.promoCode != null
        ? (baseFare + distanceFare + timeFare) * discount
        : baseFare + distanceFare + timeFare;
    return totalFare.truncate();
  }

  static void getCurrentUserInfo(context) async {
    currentFirebaseUser = await FirebaseAuth.instance.currentUser();
    String userID = currentFirebaseUser.uid;
    DatabaseReference userRef =
        FirebaseDatabase.instance.reference().child('users/$userID');
    userRef.once().then((DataSnapshot snapshot) {
      if (snapshot.value != null) {
        currentUserInfo = User.fromSnapshot(snapshot);
      }
    });
    RequestMethods.getHistoryInfo(context);
    RequestMethods.getMessageInfo(context);
  }

  static Future getPic(context) async {
    String url =
        'http://delivery.talabscollection.com/icon/${currentFirebaseUser.uid}';
    var response = await RequestHelper.getRequest(url);
    if (response == null) {
      return null;
    }
    userIcon = UserIcon.fromJson(response);
    Provider.of<AppData>(context, listen: false).updatePic(userIcon);
  }

  static double generateRandomNumber(int max) {
    var randomGenerator = Random();
    int radInt = randomGenerator.nextInt(max);

    return radInt.toDouble();
  }

  static sendNotification(String token, context, String rideid) async {
    var destination =
        Provider.of<AppData>(context, listen: false).destinationAddress;

    Map<String, String> headerMap = {
      'Content-Type': 'application/json',
      //add server key
      'Authorization':
          'key=AAAA-3klaiQ:APA91bFNnYkw7pPvKPlSkKw6nPmIRDSTb16MibQIy5UbLMFB8Ve1ogHRXvoC27koxx0Je2HtoADsD1MwPA9EDcmK0MYx-vQjQYMLuq86Wk5ErR8w_KpAweEQi90jmnB5xniwXyf-lgbk',
    };

    Map notificationMap = {
      'title': 'NEW DELIVERY REQUEST',
      'body': 'Destination, ${destination.placeName}'
    };

    Map dataMap = {
      'click_action': 'FLUTTER_NOTIFICATION_CLICK',
      'id': '1',
      'status': 'done',
      'ride_id': rideid,
    };

    Map bodyMap = {
      'notification': notificationMap,
      'data': dataMap,
      'priority': 'high',
      'to': token
    };

    var response = await http.post('https://fcm.googleapis.com/fcm/send',
        headers: headerMap, body: jsonEncode(bodyMap));

    print(response.body);
  }

  static void setHistory(rideRef) {
    DatabaseReference historyRef = FirebaseDatabase.instance
        .reference()
        .child('users/${currentFirebaseUser.uid}/history/${rideRef.key}');
    historyRef.set(true);
  }

  static void setmessage(msgRef) {
    DatabaseReference messageRef = FirebaseDatabase.instance
        .reference()
        .child('users/${currentFirebaseUser.uid}/message/${msgRef.key}');
    messageRef.set(true);
  }

  static void getHistoryInfo(context) {
    DatabaseReference historyRef = FirebaseDatabase.instance
        .reference()
        .child('users/${currentFirebaseUser.uid}/history');
    historyRef.once().then((DataSnapshot snapshot) {
      if (snapshot.value != null) {
        Map<dynamic, dynamic> values = snapshot.value;
        int tripCount = values.length;

        // update trip count to data provider
        Provider.of<AppData>(context, listen: false).updateTripCount(tripCount);

        List<String> tripHistoryKeys = [];
        values.forEach((key, value) {
          if (!tripHistoryKeys.contains(key)) {
            tripHistoryKeys.add(key);
          }
        });

        // update trip keys to data provider
        Provider.of<AppData>(context, listen: false)
            .updateTripKeys(tripHistoryKeys);

        getHistoryData(context);
      }
    });
  }

  static void getHistoryData(context) {
    var keys = Provider.of<AppData>(context, listen: false).tripHistoryKeys;

    for (String key in keys) {
      DatabaseReference historyRef =
          FirebaseDatabase.instance.reference().child('rideRequest/$key');

      historyRef.once().then((DataSnapshot snapshot) {
        if (snapshot.value != null) {
          var history = History.fromSnapshot(snapshot);
          Provider.of<AppData>(context, listen: false)
              .updateTripHistory(history);

          print(history.destination);
        }
      });
    }
  }

  static void getMessageInfo(context) {
    DatabaseReference messageRef = FirebaseDatabase.instance
        .reference()
        .child('users/${currentFirebaseUser.uid}/message');
    messageRef.once().then((DataSnapshot snapshot) {
      if (snapshot.value != null) {
        Map<dynamic, dynamic> values = snapshot.value;
        // int msgCount = values.length;

        // update trip count to data provider
        //Provider.of<AppData>(context, listen: false).u(msgCount);

        List<String> messageKeys = [];
        values.forEach((key, value) {
          if (!messageKeys.contains(key)) {
            messageKeys.add(key);
          }
        });

        // update trip keys to data provider
        Provider.of<AppData>(context, listen: false)
            .updateMessageKeys(messageKeys);

        getMessageData(context);
      }
    });
  }

  static void getMessageData(context) {
    var keys = Provider.of<AppData>(context, listen: false).messageKeys;

    for (String key in keys) {
      DatabaseReference messageRef =
          FirebaseDatabase.instance.reference().child('messages/$key');

      messageRef.once().then((DataSnapshot snapshot) {
        if (snapshot.value != null) {
          var message = Message.fromSnapshot(snapshot);
          Provider.of<AppData>(context, listen: false).updateMessage(message);

          print(message.message);
        }
      });
    }
  }

  static String formatMyDate(String datestring) {
    DateTime thisDate = DateTime.parse(datestring);
    String formattedDate =
        '${DateFormat.MMMd().format(thisDate)}, ${DateFormat.y().format(thisDate)} - ${DateFormat.jm().format(thisDate)}';

    return formattedDate;
  }

  static void showSnackbar(txt, context) {
    Scaffold.of(context).showSnackBar(
      SnackBar(
        content: Text(txt),
        backgroundColor: Colors.black,
        duration: Duration(
          seconds: 5,
        ),
      ),
    );
  }
}
