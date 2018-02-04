import 'dart:async';

import 'package:game/Game/Entity/Activity.dart';
import 'package:game/Game/Service/ActivityService.dart';
import 'package:game/Game/Service/GameClient.dart';

class ActivityRunner {
  ActivityService _activityService;

  ActivityRunner(GameClient client) {
    _activityService = new ActivityService(client);
  }

  Future run() async {
    List<Activity> list = await _activityService.getAvailableActivities();

    if (list.isEmpty) {
      return _collectBonus();
    }

    await _startActivity(list);
    await _collectActivities(list);
  }

  Future _startActivity(List<Activity> list) async {
    Activity next = _getNextActivity(list);
    if (next != null && !_hasRunningActivity(list)) {
      return _activityService.startActivity(next);
    }
  }

  Future _collectActivities(List<Activity> list) async {
    return Future.wait(
      list.where((activity) => activity.isFinished())
        .map((activity) => _activityService.collectActivity(activity)));
  }

  Future _collectBonus() async =>
    _activityService.collectBonus();

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
