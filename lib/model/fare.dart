class Fare {
  final int baseFare;
  final int promo;
  final int perKm;
  final int perMinute;

  Fare({this.baseFare, this.promo, this.perKm, this.perMinute});

  factory Fare.fromJson(Map<String, dynamic> json) {
    return Fare(
      baseFare: int.parse(json['base_fare']),
      promo: int.parse(json['user_promo']),
      perKm: int.parse(json['fare_per_km']),
      perMinute: int.parse(json['fare_per_minute']),
    );
  }
}
