import 'dart:async';

import 'package:game/Game/Entity/Item.dart';
import 'package:game/Game/Response/RewardCollectResponse.dart';
import 'package:game/Game/Service/GameClientInterface.dart';
import 'package:game/Infrastructure/Log.dart';
import 'package:html/dom.dart';

class ShopService {
  static const _ACTION_FETCH = 'fetch_available';
  static const _ACTION_FETCH_REFRESH_TIME = 'fetch_refresh_time';
  static const _ACTION_BUY_ITEM = 'buy';
  static const _WORKER_BUYER_ID = 1;

  final GameClientInterface _client;

  ShopService(this._client);

  Future<List<Item>> getItemsInShop() =>
    _log('fetch', _ACTION_FETCH, Log.debug)
      .then((_) => _fetchShopPage())
      .then((document) =>
        _log('done', _ACTION_FETCH, Log.debug, result: document))
      .then((Document document) =>
        document.querySelectorAll('#shops_left [data-d]'))
      .then((list) =>
        list.map((Element element) => element.attributes['data-d']).toList())
      .then(_client.jsonListToMap)
      .then(_makeItemList)
      .then((List<Item> list) =>
        _log('found $list}', _ACTION_FETCH, Log.info, result: list));

  Future<int> getTimeForRefreshInSeconds() =>
    _log('fetch', _ACTION_FETCH_REFRESH_TIME, Log.debug)
      .then((_) => _fetchShopPage())
      .then((document) =>
        _log('done', _ACTION_FETCH_REFRESH_TIME, Log.debug, result: document))
      .then((Document document) =>
        document.querySelector('.shop_count [rel="count"]')
          .attributes['time'])
      .then(int.parse)
      .then((int time) =>
        _log('found $time', _ACTION_FETCH_REFRESH_TIME, Log.info, result: time));

  Future buy(Item item) =>
    _log('buy $item', _ACTION_BUY_ITEM, Log.debug)
      .then((_) => _client.performAction({
        'class': 'Item',
        'action': 'buy',
        'id_item': item.id,
        'type': item.type,
        'who': _WORKER_BUYER_ID,
      }))
      .then((map) => _log('done', _ACTION_BUY_ITEM, Log.debug, result: map))
      .then((Map response) => _log(
        'item bought $item', _ACTION_BUY_ITEM, Log.info, result: response));

  Future<Document> _fetchShopPage() =>
    _client.fetchPage('shop.html');

  List<Item> _makeItemList(List<Map> list) =>
    list.map(_makeItem).toList();

  Item _makeItem(Map json) =>
    new Item(
      id: int.parse(json['id_item']),
      type: json['type'],
      rarity: json['rarity'],
      price: new Price(
        currency: int.parse(json['price'].toString()),
        specialCurrency: json.containsKey('price_hc')
          ? int.parse(json['price_hc'].toString())
          : 0,
        reSellCurrency: int.parse(json['price_sell'].toString()),
      ),
    );

  Future _log(
    String message,
    String action,
    Function callable,
    { error, result }
  ) async {
    callable(message, context: ['shop', action], error: error);

    return result;
  }
}
