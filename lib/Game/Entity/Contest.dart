import 'package:json_object/json_object.dart' show JsonObject;

class Contest {
  final int id;
  final int duration;
  final int remainingDuration;

  Contest({
    this.id,
    this.duration = 0,
    this.remainingDuration = 0,
  });

  bool isFinished() =>
    remainingDuration == 0;

  JsonObject toJson() =>
    new JsonObject
      .fromMap({
        'id': id,
        'duration': duration,
        'remainingDuration': remainingDuration,
    });

  String toString() =>
    toJson().toString();
}
