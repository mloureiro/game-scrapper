import 'package:json_object/json_object.dart' show JsonObject;

class FightDetails {
  final int id;
  final int arenaId;
  final double power;
  final int stamina;
  final int x;
  final int figure;
  final int org;

  FightDetails({
    this.id,
    this.arenaId,
    this.power,
    this.stamina,
    this.x,
    this.figure,
    this.org,
  });

  double get d => power;

  JsonObject toJson() =>
    new JsonObject
      .fromMap({
        'id': id,
        'arenaId': arenaId,
        'power': power,
        'stamina': stamina,
        'x': x,
        'figure': figure,
        'org': org,
      });

  String toString() =>
    toJson().toString();
}
