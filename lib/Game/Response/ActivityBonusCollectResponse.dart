import 'package:json_object/json_object.dart';

class ActivityBonusCollectResponse {
  final int specialCurrency;

  ActivityBonusCollectResponse({ this.specialCurrency });

  JsonObject toJson() =>
    new JsonObject.fromMap({ 'specialCurrency': specialCurrency });

  String toString() =>
    toJson().toString();
}
