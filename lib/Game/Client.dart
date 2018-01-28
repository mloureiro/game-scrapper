import 'dart:async';
import 'dart:convert';

import 'package:html/dom.dart';
import 'package:html_unescape/html_unescape.dart';

import 'package:game/Game/Entity/Energy.dart';
import 'package:game/Game/Entity/PlayerStats.dart';
import 'package:game/Game/Entity/Quest.dart';
import 'package:game/Infrastructure/Client.dart' as Infrastructure;

class Client {
  Infrastructure.Client client;

  Client(this.client) {}

  Future<Document> getHome() =>
    client.getToDocument('home.html');

  Future<PlayerStats> getPlayerStats() =>
    this._getHeroData()
      .then(this._makePlayerStatsFromMap);

  Future<Quest> getQuest() =>
    this._getHeroData()
      .then(this._makeQuestFromMap);

  Future<Map> _getHeroData() => this.getHome()
      .then((Document document) =>
        this._extractJsonWithRegex(
          document,
          new RegExp(r'Hero\["infos"\] = (.*?);')
        ).first);

  List<Map> _extractJsonWithRegex(Document document, RegExp expression) =>
    expression
      .allMatches(document.outerHtml)
      .map((Match match) => match.group(1))
      .map((String rawJson) =>
        JSON.decode((new HtmlUnescape()).convert(rawJson)))
      .toList();

  PlayerStats _makePlayerStatsFromMap(Map data) =>
    new PlayerStats()
      ..id = data['id']
      ..level = data['level']
      ..name = data['Name']
      ..fightingEnergy = (new Energy()
        ..current = data['energy_fight']
        ..max = data['energy_fight_max']
      )
      ..questEnergy = (new Energy()
        ..current = data['energy_quest']
        ..max = data['energy_quest_max']
      )
      ..currency = data['soft_currency']
      ..specialCurrency = data['hard_currency']
    ;

  Quest _makeQuestFromMap(Map data) =>
    new Quest()
      ..world = data['questing']['id_world']
      ..currentStep = data['questing']['step']
      ..currentQuest = data['questing']['id_quest']
    ;
}


