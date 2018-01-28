import 'package:game/Game/Entity/Energy.dart';

class PlayerStats {
  final int id;
  final String name;
  final int level;
  final Energy fightingEnergy;
  final Energy questEnergy;
  final int currency;
  final int specialCurrency;

  PlayerStats({
    this.id,
    this.name,
    this.level,
    this.fightingEnergy,
    this.questEnergy,
    this.currency,
    this.specialCurrency,
  }) {}
}
