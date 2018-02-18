import 'package:json_object/json_object.dart';

class FightResponse {
  final bool winner;
  final String drop;
  final int currency;
  final int specialCurrency;
  final int experience;
  final int rankPoints;

  FightResponse({
    this.winner,
    this.drop,
    this.currency = 0,
    this.specialCurrency = 0,
    this.experience = 0,
    this.rankPoints = 0,
  });

  JsonObject toJson() =>
    new JsonObject.fromMap({
      'winner': winner,
      'drop': drop,
      'currency': currency,
      'specialCurrency': specialCurrency,
      'experience': experience,
      'rankPoints': rankPoints,
    });

  String toString() =>
    toJson().toString();
}
