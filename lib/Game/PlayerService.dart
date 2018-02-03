import 'dart:async';

import 'package:game/Game/GameClient.dart';
import 'package:game/Game/Entity/Energy.dart';
import 'package:game/Game/Entity/PlayerStats.dart';
import 'package:game/Game/Entity/Quest.dart';
import 'package:game/Game/Response/FightResponse.dart';

class PlayerService {
  final GameClient _client;

  PlayerService(this._client);

  Future<PlayerStats> getPlayerStats() =>
    _getHeroData()
      .then(_makePlayerStats);

  Future<Quest> getQuest() =>
    _getHeroData()
      .then(_makeQuestFromMap);

  Future<FightResponse> fightBoss(Quest quest) =>
    _client.performAction({
      'class': 'Battle',
      'action': 'fight',
      'who[id_troll]': quest.boss,
      'who[id_world]': quest.world,
    })
      .then((Map response) =>
        new FightResponse(response['end']['drop']));

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
}
