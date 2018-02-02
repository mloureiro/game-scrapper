import 'package:json_object/json_object.dart' show JsonObject;

class ActivityRewardCollectResponse {
  final int money;
  final int experience;
  final List<String> items;
  final List<String> workers;
  final List<String> equipment;
  final List<String> skins;

  ActivityRewardCollectResponse({
    this.money = 0,
    this.experience = 0,
    this.items = const [],
    this.workers = const [],
    this.equipment = const [],
    this.skins = const [],
  });

  JsonObject toJson() =>
    new JsonObject.fromMap({
      'money': money,
      'experience': experience,
      'items': items,
      'workers': workers,
      'equipment': equipment,
      'skins': skins,
    });

  String toString() =>
    toJson().toString();
}
