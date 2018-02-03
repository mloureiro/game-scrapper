import 'package:json_object/json_object.dart';

class FightResponse {
  final String drop;

  FightResponse(this.drop);

  JsonObject toJson() =>
    new JsonObject.fromMap({ 'drop': drop });

  String toString() =>
    toJson().toString();
}
