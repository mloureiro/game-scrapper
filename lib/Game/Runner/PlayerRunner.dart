import 'dart:async';

import 'package:game/Game/Entity/PlayerStats.dart';
import 'package:game/Game/Entity/Quest.dart';
import 'package:game/Game/Service/GameClient.dart';
import 'package:game/Game/Service/PlayerService.dart';

class PlayerRunner {
  PlayerService _playerService;

  PlayerRunner(GameClient client) {
    _playerService = new PlayerService(client);
  }

  Future run() async {
    Quest quest = await _playerService.getQuest();
    PlayerStats stats = await _playerService.getPlayerStats();

    _fight(quest, stats);
  }

  Future _fight(Quest quest, PlayerStats stats) async {
    if (stats.fightingEnergy.current < 2) {
      return;
    }

    await _playerService.fightBoss(quest);
    _fight(quest, await _playerService.getPlayerStats());
  }
}
