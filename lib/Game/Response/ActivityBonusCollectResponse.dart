import 'package:json_object/json_object.dart' show JsonObject;

class ActivityBonusCollectResponse {
  final int specialCurrency;

  ActivityBonusCollectResponse({ this.specialCurrency });

  JsonObject toJson() =>
    new JsonObject.fromMap({ 'specialCurrency': specialCurrency });

  String toString() =>
    toJson().toString();
}
