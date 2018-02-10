import 'dart:async';

import 'package:game/Game/Entity/Activity.dart';
import 'package:game/Game/Service/ActivityService.dart';
import 'package:game/Game/Service/GameClient.dart';
import 'package:game/Infrastructure/Config.dart';

class ActivityRunner {
  static const _CONFIG_KEY = 'activity.next_run';

  ActivityService _activityService;
  final Config _gameConfig;

  ActivityRunner(GameClient client, this._gameConfig) {
    _activityService = new ActivityService(client);
  }

  Future run() async {
    if (!_isTimeToRun()) {
      return null;
    }

    await _run();
  }

  bool _isTimeToRun() =>
    _gameConfig.get(_CONFIG_KEY) == null
      || _gameConfig.get(_CONFIG_KEY) < new DateTime.now().millisecondsSinceEpoch;

  _run() =>
    _activityService.getAvailableActivities()
      .then((list) => _runCommand(list, _startActivity))
      .then((list) => _runCommand(list, _collectActivities))
      .then((list) => _runCommand(list, _collectBonus))
      .then(_setNextTimeToRun);

  Future _startActivity(List<Activity> list) async {
    Activity next = _getNextActivity(list);
    if (next != null && !_hasRunningActivity(list)) {
      return _activityService.startActivity(next);
    }
  }

  Future _collectActivities(List<Activity> list) =>
    Future.wait(
      list.where((activity) => activity.isFinished())
        .map((activity) => _activityService.collectActivity(activity)));

  Future _collectBonus(List<Activity> list) async =>
    _getNextActivity(list) == null
      ? _activityService.collectBonus()
      : null;

  Future _setNextTimeToRun(List<Activity> list) =>
    (!list.isEmpty
      ? new Future.value(list.firstWhere((activity) => activity.isExecuting()).remainingDuration)
      : _activityService.getTimeForRefreshInSeconts())
      .then((int timeInSeconds) async =>
        _gameConfig.set(_CONFIG_KEY,
          new DateTime.now().millisecondsSinceEpoch + (timeInSeconds * 1000)));

  Future<List<Activity>> _runCommand(List<Activity> list, command) async {
    await command(list);

    return list;
  }

  Activity _getRunningActivity(List<Activity> list) =>
    list.firstWhere(
      (activity) => activity.isExecuting(),
      orElse: () => null);

  Activity _getNextActivity(List<Activity> list) {
    list.sort(Activity.sortByDuration);

    return list.firstWhere(
      (activity) => activity.isReadyToStart(),
      orElse: () => null);
  }

  bool _hasRunningActivity(List<Activity> list) =>
    _getRunningActivity(list) != null;
}
