import 'dart:async';

import 'package:game/Game/Entity/Activity.dart';
import 'package:game/Game/Service/GameClient.dart';
import 'package:game/Game/Response/ActivityBonusCollectResponse.dart';
import 'package:game/Game/Response/ActivityRewardCollectResponse.dart';

class ActivityService {
  final GameClient _client;

  ActivityService(this._client);

  Future<List<Activity>> getAvailableActivities() =>
    _client.fetchPage('activities.html?tab=missions')
      .then(_client.extractHtml)
      .then((String html) =>
        new RegExp(r'data-d="(.*?)"')
          .allMatches(html)
          .map((Match match) => match.group(1))
          .toList())
      .then(_client.jsonListToMap)
      .then(_makeActivityList);

  Future startActivity(Activity activity) =>
    _client.performAction({
      'class': 'Missions',
      'action': 'start_mission',
      'id_mission': activity.categoryId,
      'id_member_mission': activity.id,
    });

  Future<ActivityRewardCollectResponse> collectActivity(Activity activity) =>
    _client.performAction({
      'class': 'Missions',
      'action': 'claim_reward',
      'id_mission': activity.categoryId,
      'id_member_mission': activity.id,
    })
      .then(_makeActivityRewardCollectResponse);

  Future collectBonus() =>
    _client.performAction({
      'class': 'Missions',
      'action': 'give_gift',
    })
      .then(_makeActivityBonusCollectResponse);

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

  ActivityRewardCollectResponse _makeActivityRewardCollectResponse(Map json) =>
    new ActivityRewardCollectResponse(
      money: json['hero']['soft_currency'],
      experience: json['hero']['xp'],
      items: json['items'],
      workers: json['girls'],
      equipment: json['equipment'],
      skins: json['skins'],
    );

  ActivityBonusCollectResponse _makeActivityBonusCollectResponse(Map json) =>
    new ActivityBonusCollectResponse(
      specialCurrency: json['changes']['hard_currency']);
}
