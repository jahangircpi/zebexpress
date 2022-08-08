import 'package:democab/model/paymodel.dart';

class PaymentModel {
  List<PayType> userpays;

  List<PayType> getType() {
    userpays = new List();
    userpays.add(PayType('Cash'));
    userpays.add(PayType('Card'));

    return userpays;
  }
}
