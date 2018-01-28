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
    _getHeroData()
      .then(_makePlayerStats);

  Future<Quest> getQuest() =>
    _getHeroData()
      .then(_makeQuestFromMap);

  Future<Map> _getHeroData() =>
    getHome()
      .then(_extractHtml)
      .then(_extractHeroJson)
      .then(_jsonToMap);

  String _extractHtml(Document document) =>
    document.outerHtml;

  String _extractHeroJson(String html) =>
    (new RegExp(r'Hero\["infos"\] = (.*?);'))
      .allMatches(html)
      .map((Match match) => match.group(1))
      .first;

  Map _jsonToMap(String json) =>
      JSON.decode((new HtmlUnescape()).convert(json));

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
      currentStep: data['questing']['step'],
      currentQuest: data['questing']['id_quest'],
    );
}


