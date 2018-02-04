import 'package:json_object/json_object.dart' show JsonObject;

class Activity {
  final int id;
  final int categoryId;
  final int duration;
  final int remainingDuration;

  static int sortByDuration(Activity a, Activity b) =>
    a.duration != b.duration
      ? (a.duration > b.duration ? 1 : -1)
      : 0;

  Activity({
    this.id,
    this.categoryId,
    this.duration,
    this.remainingDuration,
  });

  bool isReadyToStart() =>
    remainingDuration == duration;

  bool isExecuting() =>
    remainingDuration > 0 && remainingDuration < duration;

  bool isFinished() =>
    remainingDuration == 0;

  JsonObject toJson() =>
    new JsonObject
      .fromMap({
        'id': id,
        'categoryId': categoryId,
        'duration': duration,
        'remainingDuration': remainingDuration,
    });

  String toString() =>
    toJson().toString();
}
