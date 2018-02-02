import 'package:json_object/json_object.dart' show JsonObject;

class Quest {
  final int world;
  final int boss;
  final int currentStep;
  final int currentQuest;

  Quest({
    this.world,
    this.boss,
    this.currentStep,
    this.currentQuest,
  });

  JsonObject toJson() =>
    new JsonObject
      .fromMap({
        'world': world,
        'boss': boss,
        'currentStep': currentStep,
        'currentQuest': currentQuest,
      });

  String toString() =>
    toJson().toString();
}
