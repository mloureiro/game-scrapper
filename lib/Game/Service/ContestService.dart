import 'dart:async';

import 'package:game/Game/Entity/Contest.dart';
import 'package:game/Game/Response/RewardCollectResponse.dart';
import 'package:game/Game/Service/GameClientInterface.dart';
import 'package:game/Infrastructure/Log.dart';
import 'package:html/dom.dart';

class ContestService {
  static const _ACTION_FETCH = 'fetch_available';
  static const _ACTION_COLLECT = 'collect';

  final GameClientInterface _client;

  ContestService(this._client);

  Future getAvailableContests() =>
    _log('fetch', _ACTION_FETCH, Log.debug)
      .then((_) => _client.fetchPage('activities.html?tab=contests'))
      .then((document) =>
        _log('done', _ACTION_FETCH, Log.debug, result: document))
      .then((Document document) =>
        document.querySelectorAll('.contest[id_contest]').map(_makeContest))
      .then((List<Contest> list) =>
        _log('found $list', _ACTION_FETCH, Log.info, result: list));

  Future<RewardCollectResponse> collectActivity(Contest contest) =>
    _log('execute $contest', _ACTION_COLLECT, Log.debug)
      .then((_) => _client.performAction({
      'class': 'Contest',
      'action': 'give_reward',
      'id_contest': contest.id,
    }))
      .then(_makeRewardCollectResponse)
      .then((reward) =>
        _log('done $reward', _ACTION_COLLECT, Log.debug, result: reward))
      .then((reward) =>
        _log('collected $reward', _ACTION_COLLECT, Log.info, result: reward));

  Contest _makeContest(Element contest) {
    Element timer = contest.querySelector('[data-duration]');

    return timer == null
      ? new Contest(id: contest.attributes['id_contest'])
      : new Contest(
        id: contest.attributes['id_contest'],
        duration: timer.attributes['data-duration'],
        remainingDuration: timer.attributes['data-remaining_time'],
      );
  }

  RewardCollectResponse _makeRewardCollectResponse(Map json) =>
    new RewardCollectResponse(
      currency: json['rewards']['hero']['soft_currency'],
      specialCurrency: json['rewards']['hero']['hard_currency'],
      experience: json['rewards']['hero']['xp'],
      items: json['rewards']['items'],
      workers: json['rewards']['girls'],
      equipment: json['rewards']['equipment'],
      skins: json['rewards']['skins'],
    );

  Future _log(
    String message,
    String action,
    Function callable,
    { error, result }
  ) async {
    callable(message, context: ['contest', action], error: error);

    return result;
  }
}
