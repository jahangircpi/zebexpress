import 'package:firebase_database/firebase_database.dart';

class User {
  String fullname;
  String email;
  String phone;
  String id;
  int wallet;
  String icon;
  String promoCode;

  User(
      {this.fullname,
      this.promoCode,
      this.email,
      this.phone,
      this.wallet,
      this.icon,
      this.id});

  User.fromSnapshot(DataSnapshot snapshot) {
    id = snapshot.key;
    phone = snapshot.value['phone'];
    promoCode = snapshot.value['promoCode'];
    email = snapshot.value['email'];
    fullname = snapshot.value['fullname'];
    wallet = snapshot.value['wallet'];
    icon = snapshot.value['link'];
  }
}
