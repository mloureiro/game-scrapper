import 'dart:async';

import 'package:game/Game/Entity/FightDetails.dart';
import 'package:game/Game/Response/FightResponse.dart';
import 'package:game/Game/Service/GameClientInterface.dart';
import 'package:game/Infrastructure/Log.dart';
import 'package:html/dom.dart';

class ArenaService {
  static const _ACTION_FETCH_CHALLENGER = 'fetch_challenger';
  static const _ACTION_FIGHT = 'fight';

  final GameClientInterface _client;

  ArenaService(this._client);

  Future<FightDetails> fetchChallenger(int arenaId) =>
    _log('fetch #$arenaId', _ACTION_FETCH_CHALLENGER, Log.debug)
      .then((_) => _fetchBattlePage(arenaId))
      .then((document) =>
        _log('done', _ACTION_FETCH_CHALLENGER, Log.debug, result: document))
      .then(_client.extractHtml)
      .then(_extractFightDetails)
      .then(_client.jsonToMap)
      .then(_makeFightDetails)
      .then((FightDetails challenger) =>
        _log('found #$arenaId: $challenger',
          _ACTION_FETCH_CHALLENGER, Log.info, result: challenger));

  Future<FightResponse> fight(FightDetails details) =>
    _log('start $details', _ACTION_FIGHT, Log.debug)
      .then((_) => _client.performAction({
      'class': 'Battle',
      'action': 'fight',
      'who[id_arena]': details.arenaId,
      'who[id_member]': details.id,
    }))
    .then((map) => _log('done', _ACTION_FIGHT, Log.debug, result: map))
    .then((Map result) => new FightResponse(
      winner: result['end']['winner'] == 1,
      experience: result['end']['up2']['xp'],
      rankPoints: result['end']['up2']['victory_points'],
      drop: result['end']['drops'].toString().replaceAll('\n', ''),
    ))
    .then((FightResponse response) => _log(
      'Fight result: ${response.winner ? 'victory' : 'loss'} - details: $response',
      _ACTION_FIGHT,
      Log.info,
      result: response
    ));

  String _extractFightDetails(String html) =>
    new RegExp(r'({.+id_arena.+})')
      .allMatches(html)
      .map((Match match) => match.group(1))
      .first;

  FightDetails _makeFightDetails(Map json) =>
    new FightDetails(
      id: int.parse(json['id_member']),
      arenaId: int.parse(json['id_arena']),
      power: json['ego'] is int
        ? json['ego'].toDouble()
        : json['ego'],
      x: json['x'],
      figure: json['figure'],
      org: json['nb_org'],
    );

  Future<Document> _fetchBattlePage(int arenaId) =>
    _client.fetchPage('battle.html?id_arena=$arenaId');

  Future _log(
    String message,
    String action,
    Function callable,
    { error, result }
  ) async {
    callable(message, context: ['arena', action], error: error);

    return result;
  }
}
