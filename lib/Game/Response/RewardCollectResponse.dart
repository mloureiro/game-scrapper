import 'package:json_object/json_object.dart' show JsonObject;

class RewardCollectResponse {
  final int currency;
  final int specialCurrency;
  final int experience;
  final List<String> items;
  final List<String> workers;
  final List<String> equipment;
  final List<String> skins;

  RewardCollectResponse({
    this.currency = 0,
    this.specialCurrency = 0,
    this.experience = 0,
    this.items = const [],
    this.workers = const [],
    this.equipment = const [],
    this.skins = const [],
  });

  JsonObject toJson() =>
    new JsonObject.fromMap({
      'currency': currency,
      'specialCurrency': specialCurrency,
      'experience': experience,
      'items': items,
      'workers': workers,
      'equipment': equipment,
      'skins': skins,
    });

  String toString() =>
    toJson().toString();
}
