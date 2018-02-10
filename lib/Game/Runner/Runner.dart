import 'dart:async';

import 'package:game/Game/Runner/ActivityRunner.dart';
import 'package:game/Game/Runner/PlayerRunner.dart';
import 'package:game/Game/Runner/WorkerRunner.dart';
import 'package:game/Game/Service/GameClient.dart';
import 'package:game/Infrastructure/Config.dart';

class Runner {
  final GameClient _client;
  final Config _gameConfig;
  ActivityRunner _activityRunner;
  PlayerRunner _playerRunner;
  WorkerRunner _workerRunner;

    _playerRunner = new PlayerRunner(_client);
  Runner(this._client, this._gameConfig) {
    _activityRunner = new ActivityRunner(_client, _gameConfig);
    _workerRunner = new WorkerRunner(_client, _gameConfig);
  }

  Future run() async {
    await _client.authenticate();
    await _activityRunner.run();
    await _playerRunner.run();
    await _workerRunner.run();

    _gameConfig.store();
  }
}
