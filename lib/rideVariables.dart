import 'dart:math';

import 'package:democab/globalvariable.dart';
import 'package:firebase_database/firebase_database.dart';

int driverRequestTimeout = 30;

String status = '';

String driverCarDetails = '';

String driverFullName = '';

String driverId = '';

String driverImage = '';

String driverPlateNumber = '';

String driverPhoneNumber;

String tripStatusDisplay = 'Driver is Arriving';

String narration = 'Best ride';

String generateRandomNumber() {
  var random = new Random();
  var rand = new Random();
  return 'txRef_${random.nextInt(999999999)}_${rand.nextInt(999999999)}';
}

void saveMessage(String text) {
  msgRef = FirebaseDatabase().reference().child('messages').push();
  Map msgMap = {
    'created_at': DateTime.now().toString(),
    'message': text,
  };
  msgRef.set(msgMap);
  var userMsg = FirebaseDatabase.instance
      .reference()
      .child('users/${currentFirebaseUser.uid}/message/${msgRef.key}');
  userMsg.set(true);
}
