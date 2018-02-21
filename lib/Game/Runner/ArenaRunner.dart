import 'dart:async';
import 'package:game/Game/Response/FightResponse.dart';
import 'package:game/Game/Service/ArenaService.dart';
import 'package:game/Game/Service/GameClientInterface.dart';
import 'package:game/Infrastructure/Config.dart';
import 'package:game/Infrastructure/Log.dart';

class ArenaRunner {
  static const _ARENAS_IDS = const [0, 1, 2];
  static const _CONFIG_FIGHT_KEY = 'arena.fight.next_run';

  ArenaService _arenaService;
  final Config _gameConfig;

  ArenaRunner(GameClientInterface client, this._gameConfig) {
    _arenaService = new ArenaService(client);
  }

  Future run() async {
    if (!_isTimeToFight()) {
      return;
    }

    for(int i = 0; i < _ARENAS_IDS.length; i++) {
      await _fight(_ARENAS_IDS[i]);
    }

    await _setNextFightRun();
  }

  Future<FightResponse> _fight(int id) =>
    _arenaService.fetchChallenger(id)
      .then(_arenaService.fight)
      .catchError((error) =>
        _log('arena fight #$id failed', 'fight', Log.warning, error: error));

  Future _setNextFightRun() async =>
    _arenaService.getChallengersRefreshTime()
      .then((int timeInSeconds) =>
        _gameConfig.set(
          _CONFIG_FIGHT_KEY,
          ((timeInSeconds + 30) * 1000) + new DateTime.now().millisecondsSinceEpoch));

  bool _isTimeToFight() =>
    _gameConfig.get(_CONFIG_FIGHT_KEY) == null
      || _gameConfig.get(_CONFIG_FIGHT_KEY) < new DateTime.now().millisecondsSinceEpoch;

  Future _log(
    String message,
    String action,
    Function callable,
    { error, result }
  ) async {
    callable(message, context: ['runner.arena', action], error: error);

    return result;
  }
}
