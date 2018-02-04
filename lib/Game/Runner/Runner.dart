import 'dart:async';

import 'package:game/Game/Runner/ActivityRunner.dart';
import 'package:game/Game/Runner/PlayerRunner.dart';
import 'package:game/Game/Runner/WorkerRunner.dart';
import 'package:game/Game/Service/GameClient.dart';

class Runner {
  GameClient _client;
  ActivityRunner _activityRunner;
  PlayerRunner _playerRunner;
  WorkerRunner _workerRunner;

  Runner(this._client) {
    _activityRunner = new ActivityRunner(_client);
    _playerRunner = new PlayerRunner(_client);
    _workerRunner = new WorkerRunner(_client);
  }

  Future run() async {
    await _client.authenticate();
    await _activityRunner.run();
    await _playerRunner.run();
    await _workerRunner.run();
  }
}
