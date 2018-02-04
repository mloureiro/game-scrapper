import 'dart:async';

import 'package:game/Game/Entity/Worker.dart';
import 'package:game/Game/Service/GameClient.dart';
import 'package:game/Game/Service/WorkerService.dart';

class WorkerRunner {
  WorkerService _workerService;

  WorkerRunner(GameClient client) {
    _workerService = new WorkerService(client);
  }

  Future run() async {
    List<Worker> list = await _workerService.getWorkers();

    return Future.wait(
      list.where((worker) => worker.hasSalaryToCollect())
        .map((worker) => _workerService.collectSalary(worker)));
  }
}
