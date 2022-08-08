import 'package:democab/model/address.dart';
import 'package:democab/model/fare.dart';
import 'package:democab/model/history.dart';
import 'package:democab/model/image.dart';
import 'package:democab/model/message.dart';
import 'package:flutter/cupertino.dart';

class AppData extends ChangeNotifier {
  Address pickupAddress;
  Address destinationAddress;

  Address deliPickAddress;

  bool myPickup = false;
  bool mydest = false;

  Fare fare;
  UserIcon userIcon;

  String wallet = '0';
  String payType = 'wallet';

  var p;

  int tripCount = 0;
  List<String> tripHistoryKeys = [];
  List<History> tripHistory = [];

  List<String> messageKeys = [];
  List<Message> messages = [];

  String userPhonenumber;
  String userItem;

  void updateWallet(String newWallet) {
    wallet = newWallet;
    notifyListeners();
  }

  void updatePrice(int newPrice) {
    p = newPrice;
    notifyListeners();
  }

  void updatePayType(String newPayType) {
    payType = newPayType;
    notifyListeners();
  }

  void updateTripCount(int newTripCount) {
    tripCount = newTripCount;
    notifyListeners();
  }

  void resetInput() {
    checkDest(false);
    checkPickup(false);
  }

  void updaatePickupAddress(Address pickup) {
    pickupAddress = pickup;
    notifyListeners();
  }

  void updateFare(Fare fa) {
    fare = fa;
    notifyListeners();
  }

  void updatePic(UserIcon pic) {
    userIcon = pic;
    notifyListeners();
  }

  void updateDestinationAddress(Address destination) {
    destinationAddress = destination;
    notifyListeners();
  }

  void updateDeliPickAddress(Address pickupplace) {
    deliPickAddress = pickupplace;
    notifyListeners();
  }

  void checkPickup(bool value) {
    myPickup = value;
    notifyListeners();
  }

  void checkDest(bool value) {
    mydest = value;
    notifyListeners();
  }

  void getMobile(String numbr) {
    userPhonenumber = numbr;
    notifyListeners();
  }

  void getItem(String item) {
    userItem = item;
    notifyListeners();
  }

  void updateTripHistory(History historyItem) {
    tripHistory.add(historyItem);
    notifyListeners();
  }

  void updateTripKeys(List<String> newKeys) {
    tripHistoryKeys = newKeys;
    notifyListeners();
  }

  void clearTripHistory() {
    tripHistory.clear();
    notifyListeners();
  }

  void clearMessage() {
    messages.clear();
    messageKeys.clear();
    notifyListeners();
  }

  void updateMessage(Message messageItem) {
    messages.add(messageItem);
    notifyListeners();
  }

  void updateMessageKeys(List<String> newKeys) {
    messageKeys = newKeys;
    notifyListeners();
  }
}
