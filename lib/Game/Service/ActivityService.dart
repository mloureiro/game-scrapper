import 'dart:async';

import 'package:game/Game/Entity/Activity.dart';
import 'package:game/Game/Service/GameClient.dart';
import 'package:game/Game/Response/ActivityBonusCollectResponse.dart';
import 'package:game/Game/Response/RewardCollectResponse.dart';
import 'package:game/Infrastructure/Log.dart';
import 'package:html/dom.dart';

class ActivityService {
  static const _ACTION_FETCH = 'fetch_available';
  static const _ACTION_FETCH_REFRESH_TIME = 'fetch_refresh_time';
  static const _ACTION_START = 'start';
  static const _ACTION_COLLECT = 'collect';
  static const _ACTION_COLLECT_BONUS = 'collect_bonus';
  static const _ACTION_CHECK_BONUS_AVAILABILITY = 'check_bonus_availability';

  final GameClient _client;

  ActivityService(this._client);

  Future<List<Activity>> getAvailableActivities() =>
    _log('fetch', _ACTION_FETCH, Log.debug)
      .then((_) => fetchActivitiesPage())
      .then((document) =>
        _log('done', _ACTION_FETCH, Log.debug, result: document))
      .then((Document document) =>
        document.querySelectorAll('.mission_object[data-d]'))
      .then((list) =>
        list.map((Element element) => element.attributes['data-d']).toList())
      .then(_client.jsonListToMap)
      .then(_makeActivityList)
      .then((List<Activity> list) =>
        _log('found $list', _ACTION_FETCH, Log.info, result: list));

  Future<bool> isBonusActivityAvailable() =>
    _log('fetch', _ACTION_CHECK_BONUS_AVAILABILITY, Log.debug)
      .then((_) => fetchActivitiesPage())
      .then((document) =>
        _log('done', _ACTION_CHECK_BONUS_AVAILABILITY, Log.debug, result: document))
      .then(_client.extractHtml)
      .then((String html) =>
        new RegExp(r'mission_gift\s?=\s?(\d+);')
          .allMatches(html)
          .map((Match match) => match.group(1))
          .first)
      .then(int.parse)
      .then((int value) => value != 1)
      .then((bool isAvailable) =>
        _log(
          '${isAvailable ? 'is' : 'not'} available',
          _ACTION_CHECK_BONUS_AVAILABILITY,
          Log.info,
          result: isAvailable
        ));

  Future<int> getTimeForRefreshInSeconds() =>
    _log('fetch', _ACTION_FETCH_REFRESH_TIME, Log.debug)
      .then((_) => fetchActivitiesPage())
      .then((document) =>
        _log('done', _ACTION_FETCH_REFRESH_TIME, Log.debug, result: document))
      .then(_client.extractHtml)
      .then((String html) =>
        new RegExp(r'next_update\s?=\s?(\d+);')
          .allMatches(html)
          .map((Match match) => match.group(1))
          .first)
      .then(int.parse)
      .then((int time) =>
        _log('found $time', _ACTION_FETCH_REFRESH_TIME, Log.info, result: time));

  Future startActivity(Activity activity) =>
    _log('execute $activity', _ACTION_START, Log.debug)
      .then((_) => _client.performAction({
        'class': 'Missions',
        'action': 'start_mission',
        'id_mission': activity.categoryId,
        'id_member_mission': activity.id,
      }))
      .then((_) => _log('done $activity', _ACTION_START, Log.debug))
      .then((_) => _log('started $activity', _ACTION_START, Log.info));

  Future<RewardCollectResponse> collectActivity(Activity activity) =>
    _log('execute $activity', _ACTION_COLLECT, Log.debug)
      .then((_) => _client.performAction({
        'class': 'Missions',
        'action': 'claim_reward',
        'id_mission': activity.categoryId,
        'id_member_mission': activity.id,
      }))
      .then(_makeRewardCollectResponse)
      .then((reward) =>
        _log('done $reward', _ACTION_COLLECT, Log.debug, result: reward))
      .then((reward) =>
        _log('collected $reward', _ACTION_COLLECT, Log.info, result: reward));

  Future collectBonus() =>
    _log('execute', _ACTION_COLLECT_BONUS, Log.debug)
      .then((_) => _client.performAction({
        'class': 'Missions',
        'action': 'give_gift',
      }))
      .then((result) =>
        _log('done $result', _ACTION_COLLECT_BONUS, Log.debug, result: result))
      .then(_makeActivityBonusCollectResponse)
      .then((reward) =>
        _log('collected $reward', _ACTION_COLLECT_BONUS, Log.info, result: reward));

  Future<Document> fetchActivitiesPage() =>
    _client.fetchPage('activities.html?tab=missions');

  List<Activity> _makeActivityList(List<Map> list) =>
    list.map(_makeActivity).toList();

  Activity _makeActivity(Map json) =>
    new Activity(
      id: int.parse(json['id_member_mission']),
      categoryId: int.parse(json['id_mission']),
      duration: int.parse(json['duration']),
      remainingDuration: json['remaining_time'] == null
        ? int.parse(json['duration'])
        : int.parse(json['remaining_time']) > 0
          ? int.parse(json['remaining_time']) : 0
    );

  RewardCollectResponse _makeRewardCollectResponse(Map json) =>
    new RewardCollectResponse(
      currency: json['hero']['soft_currency'],
      specialCurrency: json['hero']['hard_currency'],
      experience: json['hero']['xp'],
      items: json['items'],
      workers: json['girls'],
      equipment: json['equipment'],
      skins: json['skins'],
    );

  ActivityBonusCollectResponse _makeActivityBonusCollectResponse(Map json) =>
    new ActivityBonusCollectResponse(
      specialCurrency: json['changes']['hard_currency']);

  Future _log(
    String message,
    String action,
    Function callable,
    { error, result }
  ) async {
    callable(message, context: ['activity', action], error: error);

    return result;
  }
}
