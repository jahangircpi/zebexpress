import 'dart:async';

import 'package:democab/model/carItem.dart';
import 'package:democab/widget/carTile.dart';

class CarBloc {
  var _pickupController = new StreamController();
  var carList = CarTile.getCarList();

  get stream => _pickupController.stream;
  var currentSelected = 0;

  void selectItem(int index) {
    currentSelected = index;
    _pickupController.sink.add(currentSelected);
  }

  bool isSelected(int index) {
    return index == currentSelected;
  }

  CarItem getCurrentCar() {
    return carList.elementAt(currentSelected);
  }

  void dispose() {
    _pickupController.close();
  }
}
