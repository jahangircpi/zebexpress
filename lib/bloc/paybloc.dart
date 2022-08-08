import 'dart:async';

import 'package:democab/model/payment.dart';
import 'package:democab/model/paymodel.dart';

class PayBloc {
  var _payUpController = new StreamController();
  var payList = PaymentModel().getType();
  get stream => _payUpController.stream;
  var currentSelected = 0;

  void selectItem(int index) {
    currentSelected = index;
    _payUpController.sink.add(currentSelected);
  }

  bool isSelected(int index) {
    return index == currentSelected;
  }

  PayType getCurrentCar() {
    return payList.elementAt(currentSelected);
  }

  void dispose() {
    _payUpController.close();
  }
}
