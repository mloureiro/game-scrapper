import 'dart:async' show Future;

import 'package:game/Game/Service/GameClient.dart';
import 'package:game/Game/Entity/Worker.dart';
import 'package:game/Game/Response/CollectSalaryResponse.dart';

class WorkerService {
  final GameClient client;

  WorkerService(this.client);

  Future<List<Worker>> getWorkers() =>
    client.fetchPage('harem.html')
      .then(client.extractHtml)
      .then(_extractWorkerList)
      .then(client.jsonListToMap)
      .then(_mapListToWorker);

  Future<CollectSalaryResponse> collectSalary(Worker worker) =>
    client.performAction( {
      'class': 'Girl',
      'action': 'get_salary',
      'who': worker.id,
    })
      .then((Map response) => new CollectSalaryResponse(
        salary: response['money'],
        timeToNextSalary: response['time'],
      ));

  List<String> _extractWorkerList(String html) =>
    new RegExp(r'new Girl\((.+?)\)')
      .allMatches(html)
      .map((Match match) => match.group(1))
      .toList();

  List<Worker> _mapListToWorker(List<Map> list) =>
    list.map((Map data) =>
      new Worker(
        id: int.parse(data['id_girl']),
        name: data['Name'],
        level: int.parse(data['level']),
        grade: data['graded'],
        salary: data['salary'],
        periodToGetSalary: data['4500'],
        remainingPeriodToGetSalary: data['pay_in'],
      ))
      .toList();
}
