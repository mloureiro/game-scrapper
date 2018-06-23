import 'dart:async';
import 'dart:math';

import 'package:game/Game/Entity/Energy.dart';
import 'package:game/Game/Entity/PlayerStats.dart';
import 'package:game/Game/Entity/Quest.dart';
import 'package:game/Game/Service/GameClientInterface.dart';
import 'package:game/Game/Service/PlayerService.dart';
import 'package:game/Infrastructure/Config.dart';

class PlayerRunner {
  static const _ENERGY_RECOVER_TIME_IN_SECONDS = 20 * 60;
  static const _MIN_ENERGY_TO_RUN = .75;
  static const _REQUIRED_ENERGY_TO_FIGHT = 1;
  static const _CONFIG_FIGHT_KEY = 'player.fight.next_run';

  PlayerService _playerService;
  final Config _gameConfig;

  PlayerRunner(GameClientInterface client, this._gameConfig) {
    _playerService = new PlayerService(client);
  }

  Future run() async =>
    !_isTimeToFight()
      ? null
      : Future.wait([
        _playerService.getQuest(),
        _playerService.getPlayerStats()
      ])
      .then((List list) => new _PlayerData(list[0], list[1]))
      .then((_PlayerData data) =>
        _fight(data.quest, data.stats)
          .then((_) => _setNextFightRun(data.stats.fightingEnergy)));

  Future _fight(Quest quest, PlayerStats stats) async =>
    stats.fightingEnergy.current >= _REQUIRED_ENERGY_TO_FIGHT
      ? _playerService.fightBoss(quest)
        .then((_) async => _fight(quest, await _playerService.getPlayerStats()))
      : null;

  Future _setNextFightRun(Energy energy) async =>
    _gameConfig.set(
      _CONFIG_FIGHT_KEY,
      (_calculateNextMinimumEnergy(energy) * _ENERGY_RECOVER_TIME_IN_SECONDS * 1000)
      + new DateTime.now().millisecondsSinceEpoch
    );

  int _calculateNextMinimumEnergy(Energy energy) =>
    (_MIN_ENERGY_TO_RUN * energy.max).round()
      + (new Random()).nextInt(((1 - _MIN_ENERGY_TO_RUN) * energy.max).round())
      - 2;

  bool _isTimeToFight() =>
    _gameConfig.get(_CONFIG_FIGHT_KEY) == null
      || _gameConfig.get(_CONFIG_FIGHT_KEY) < new DateTime.now().millisecondsSinceEpoch;
}

class _PlayerData {
  final Quest quest;
  final PlayerStats stats;

  _PlayerData(this.quest, this.stats);
}
