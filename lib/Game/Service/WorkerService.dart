import 'dart:async' show Future;

import 'package:game/Game/Service/GameClient.dart';
import 'package:game/Game/Entity/Worker.dart';
import 'package:game/Game/Response/CollectSalaryResponse.dart';
import 'package:game/Infrastructure/Log.dart';

class WorkerService {
  static const _ACTION_FETCH_WORKERS = 'fetch_list';
  static const _ACTION_COLLECT_SALARY = 'collect_salary';

  final GameClient client;

  WorkerService(this.client);

  Future<List<Worker>> getWorkers() =>
    _log('fetch', _ACTION_FETCH_WORKERS, Log.debug)
      .then((_) => client.fetchPage('harem.html'))
      .then((result) =>
        _log('done', _ACTION_FETCH_WORKERS, Log.debug, result: result))
      .then(client.extractHtml)
      .then(_extractWorkerList)
      .then(client.jsonListToMap)
      .then(_mapListToWorker)
      .then((list) => _log(
        'found: [${list.map((worker) => worker.id).join(', ')}]',
        _ACTION_FETCH_WORKERS,
        Log.info, result: list));

  Future<CollectSalaryResponse> collectSalary(Worker worker) =>
    _log('fetch $worker', _ACTION_COLLECT_SALARY, Log.debug)
      .then((_) => client.performAction({
        'class': 'Girl',
        'action': 'get_salary',
        'who': worker.id,
      }))
      .then((result) =>
        _log('done $worker', _ACTION_COLLECT_SALARY, Log.debug, result: result))
      .then((Map response) => new CollectSalaryResponse(
        salary: response['money'],
        timeToNextSalary: response['time'],
      ))
      .then((salary) => _log(
        'Collected salary of #${worker.id}: \$${salary.salary}',
        _ACTION_COLLECT_SALARY,
        Log.info,
        result: salary));

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

  Future _log(
    String message,
    String action,
    Function callable,
    { error, result }
    ) async {
    callable(message, context: ['worker', action], error: error);

    return result;
  }
}
