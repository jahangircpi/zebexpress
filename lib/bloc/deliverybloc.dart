import 'dart:async';

import 'package:democab/model/carItem.dart';
import 'package:democab/widget/carTile.dart';

class DeliveryBloc {
  var _pickupController = new StreamController();
  var bikeList = CarTile.getDeliveryList();

  get stream => _pickupController.stream;
  var currentSelected = 0;

  void selectItem(int index) {
    currentSelected = index;
    _pickupController.sink.add(currentSelected);
  }

  CarItem getCurrentBike() {
    return bikeList.elementAt(currentSelected);
  }

  void dispose() {
    _pickupController.close();
  }

  bool isSelected(int index) {
    return index == currentSelected;
  }
}
