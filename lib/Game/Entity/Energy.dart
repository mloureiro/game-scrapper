import 'package:json_object/json_object.dart';

class Energy {
  int current;
  final int max;

  Energy({ this.current, this.max}) {}

  JsonObject toJson() =>
    new JsonObject
      .fromMap({
      'current': current,
      'max': max,
    });

  String toString() =>
    toJson.toString();
}
