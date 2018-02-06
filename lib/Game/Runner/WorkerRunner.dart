import 'dart:async';

import 'package:game/Game/Entity/Worker.dart';
import 'package:game/Game/Service/GameClient.dart';
import 'package:game/Game/Service/WorkerService.dart';
import 'package:game/Infrastructure/Config.dart';

class WorkerRunner {
  static const _CONFIG_KEY = 'worker.next_collect_timestamp';

  final Config _gameConfig;
  WorkerService _workerService;

  WorkerRunner(GameClient client, this._gameConfig) {
    _workerService = new WorkerService(client);
  }

  Future run() async {
    if (!_isTimeToCollect()) {
      return null;
    }

    await _collectSalary();
    return await _setNextCollectionTime();
  }

  Future _collectSalary() async =>
    Future.wait(
      (await _workerService.getWorkers())
        .where((worker) => worker.hasSalaryToCollect())
        .map((worker) => _workerService.collectSalary(worker)));

  bool _isTimeToCollect() =>
    _gameConfig.get(_CONFIG_KEY) == null
      || _gameConfig.get(_CONFIG_KEY) < new DateTime.now().millisecondsSinceEpoch;

  Future _setNextCollectionTime() =>
    _workerService.getWorkers()
      .then(_getNextReferenceWorker)
      .then((Worker worker) => worker.remainingPeriodToGetSalary)
      .then((int remainingSeconds) =>
        (remainingSeconds * 1000) + new DateTime.now().millisecondsSinceEpoch)
      .then((int secondsTillNextCollect) =>
        _gameConfig.set(_CONFIG_KEY, secondsTillNextCollect));

  Worker _getNextReferenceWorker(List<Worker> list) {
    list.sort((a, b) =>
      a.remainingPeriodToGetSalary > b.remainingPeriodToGetSalary ? 1 : -1);

    return list[0];
  }
}
