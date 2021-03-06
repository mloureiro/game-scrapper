import 'dart:async';

import 'package:game/Game/Entity/Activity.dart';
import 'package:game/Game/Service/ActivityService.dart';
import 'package:game/Game/Service/GameClientInterface.dart';
import 'package:game/Infrastructure/Config.dart';

class ActivityRunner {
  static const _CONFIG_KEY = 'activity.next_run';

  ActivityService _activityService;
  final Config _gameConfig;

  ActivityRunner(GameClientInterface client, this._gameConfig) {
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
      .then((list) => Future.wait([
        _startActivity(list),
        _collectActivities(list),
        _collectBonus(list),
      ]))
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
    _activityService.isBonusActivityAvailable()
      .then((bool isAvailable) =>
        isAvailable && !_hasUnfinishedActivity(list)
          ? _activityService.collectBonus()
          : null);

  Future _setNextTimeToRun(List<Activity> list) =>
    _activityService.getAvailableActivities()
      .then((list) => !list.isEmpty
        ? list.firstWhere((activity) => activity.isExecuting()).remainingDuration
        : _activityService.getTimeForRefreshInSeconds())
      .then((int timeInSeconds) async =>
        _gameConfig.set(_CONFIG_KEY,
          new DateTime.now().millisecondsSinceEpoch + (timeInSeconds * 1000)));

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


  bool _hasUnfinishedActivity(List<Activity> list) =>
    list.where((activity) =>
    activity.isExecuting() || activity.isReadyToStart())
      .length != 0;
}
