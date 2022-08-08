import 'package:firebase_database/firebase_database.dart';

class Message {
  String message;
  String createdAt;
  String key;

  Message({
    this.key,
    this.message,
    this.createdAt,
  });

  Message.fromSnapshot(DataSnapshot snapshot) {
    key = snapshot.key;
    message = snapshot.value['message'];
    createdAt = snapshot.value['created_at'];
  }
}
