import 'package:democab/model/carItem.dart';

class CarTile {
  static List<CarItem> cars;
  static List<CarItem> bikes;

  static List<CarItem> getCarList() {
    if (cars != null) {
      return cars;
    }

    cars = new List();
    cars.add(CarItem("Bike", 'assets/taxi.png', 1));
    cars.add(CarItem("Van", 'assets/van.png', 1.5));
    cars.add(CarItem("Truck", 'assets/truck.png', 2.0));

    return cars;
  }

  static List<CarItem> getDeliveryList() {
    if (bikes != null) {
      return bikes;
    }

    bikes = new List();
    bikes.add(CarItem("Bike", 'assets/guy2.png', 1));
    bikes.add(CarItem("Van", 'assets/ic_pickup_van.png', 1.5));

    return bikes;
  }
}
