import 'dart:async';

import 'package:game/Game/Entity/Energy.dart';
import 'package:game/Game/Entity/PlayerStats.dart';
import 'package:game/Game/Entity/Quest.dart';
import 'package:game/Game/Response/FightResponse.dart';
import 'package:game/Game/Service/GameClientInterface.dart';
import 'package:game/Infrastructure/Log.dart';

class PlayerService {
  static const _ACTION_FETCH_STATS = 'player.get_stats';
  static const _ACTION_FETCH_QUEST_CURRENT = 'quest.get_current';
  static const _ACTION_FIGHT = 'player.fight_boss';

  final GameClientInterface _client;

  PlayerService(this._client);

  Future<PlayerStats> getPlayerStats() =>
    _log('fetch', _ACTION_FETCH_STATS, Log.debug)
      .then((_) => _getHeroData())
      .then((map) => _log('done', _ACTION_FETCH_STATS, Log.debug, result: map))
      .then(_makePlayerStats)
      .then((stats) =>
        _log('current stats: $stats', _ACTION_FETCH_STATS, Log.info, result: stats));

  Future<Quest> getQuest() =>
    _log('fetch', _ACTION_FETCH_QUEST_CURRENT, Log.debug)
      .then((_) => _getHeroData())
      .then((map) =>
        _log('done', _ACTION_FETCH_QUEST_CURRENT, Log.debug, result: map))
      .then(_makeQuestFromMap)
      .then((quest) =>
        _log('current quest: $quest', _ACTION_FETCH_QUEST_CURRENT, Log.info, result: quest));

  Future<FightResponse> fightBoss(Quest quest) =>
    _log('fetch', _ACTION_FIGHT, Log.debug)
      .then((_) => _client.performAction({
        'class': 'Battle',
        'action': 'fight',
        'who[id_troll]': quest.boss,
        'who[id_world]': quest.world,
      }))
      .then((map) => _log('done', _ACTION_FIGHT, Log.debug, result: map))
      .then((Map response) =>
        new FightResponse(
          winner: response['end']['drops'] != null,
          drop: response['end']['drops'],
        ))
      .then((FightResponse response) => _log(
        'Fight result: ${response.winner ? 'victory' : 'loss'} - Reward: ${response.drop}',
        _ACTION_FIGHT,
        Log.info,
        result: response));

  Future<Map> _getHeroData() =>
    _client.fetchPage('home.html')
      .then(_client.extractHtml)
      .then(_extractHeroJson)
      .then(_client.jsonToMap);

  String _extractHeroJson(String html) =>
    new RegExp(r'Hero\["infos"\] = (.*?);')
      .allMatches(html)
      .map((Match match) => match.group(1))
      .first;

  PlayerStats _makePlayerStats(Map data) =>
    new PlayerStats(
      id: data['id'],
      level: data['level'],
      name: data['Name'],
      currency: data['soft_currency'],
      specialCurrency: data['hard_currency'],
      fightingEnergy: (new Energy(
        current: data['energy_fight'],
        max: data['energy_fight_max'],
      )),
      questEnergy: (new Energy(
        current: data['energy_quest'],
        max: data['energy_quest_max'],
      )),
    );

  Quest _makeQuestFromMap(Map data) =>
    new Quest(
      world: data['questing']['id_world'],
      boss: data['questing']['id_world'] - 1,
      currentStep: data['questing']['step'],
      currentQuest: data['questing']['id_quest'],
    );

  Future _log(
    String message,
    String action,
    Function callable,
    { error, result }
    ) async {
    callable(message, context: ['player', action], error: error);

    return result;
  }
}
