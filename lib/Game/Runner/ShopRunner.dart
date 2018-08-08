import 'dart:async';

import 'package:game/Game/Entity/Item.dart';
import 'package:game/Game/Entity/PlayerStats.dart';
import 'package:game/Game/Service/GameClientInterface.dart';
import 'package:game/Game/Service/PlayerService.dart';
import 'package:game/Game/Service/ShopService.dart';
import 'package:game/Infrastructure/Config.dart';

class ShopRunner {
  static const _CONFIG_KEY = 'shop.next_run';

  PlayerService _playerService;
  ShopService _shopService;
  final Config _gameConfig;

  ShopRunner(GameClientInterface client, this._gameConfig) {
    _playerService = new PlayerService(client);
    _shopService = new ShopService(client);
  }

  Future run() async {
    if (!_isTimeToRun()) {
      return null;
    }

    List<Item> list = await _shopService.getItemsInShop();

    await new Future.value(_extractType(list, Item.TYPE_GIFT))
      .then(_sort)
      .then(_buyList);

    await new Future.value(_extractType(list, Item.TYPE_BOOK))
      .then(_sort)
      .then(_buyList);

    return _setTimerToNextRun();
  }

  bool _isTimeToRun() =>
    _gameConfig.get(_CONFIG_KEY) == null
      || _gameConfig.get(_CONFIG_KEY) < new DateTime.now().millisecondsSinceEpoch;

  Future _setTimerToNextRun() =>
    _shopService.getTimeForRefreshInSeconds()
      .then((_) => _gameConfig.set(_CONFIG_KEY,
        new DateTime.now().millisecondsSinceEpoch + (30 * 60 * 1000) + 3000));

  List<Item> _extractType(List<Item> list, String type) =>
    list.where((item) => item.type == type).toList();

  List<Item> _sort(List<Item> list) {
    list.sort(Item.sortByHigherValue);

    return list;
  }

  Future _buyList(List<Item> list) async =>
    list.isNotEmpty
      ? _buy(await _playerService.getPlayerStats(), list.first)
          .then((isSuccess) => isSuccess ? _buyList(list.sublist(1)) : false)
      : true;

  Future<bool> _buy(PlayerStats stats, Item item) async =>
    stats.specialCurrency >= item.price.specialCurrency
    && stats.currency >= item.price.currency
      ? _shopService.buy(item).then((_) => true)
      : false;
}
