import 'dart:async';

import 'package:game/Game/Service/GameClientInterface.dart';
import 'package:game/Game/Service/PlayerService.dart';
import 'package:game/Infrastructure/Config.dart';
import 'package:html/dom.dart';

class AuthenticateClientProxy implements GameClientInterface {
  static const _CONFIG_AUTHENTICATION_KEY = 'authorization.key';

  final Config _gameConfig;
  final GameClientInterface _client;
  PlayerService _playerService;
  bool _isAuthenticated = false;

  AuthenticateClientProxy(this._client, this._gameConfig) {
    _playerService = new PlayerService(_client);
  }

  String getAuthenticationKey() =>
    _client.getAuthenticationKey();

  void setAuthenticationKey(String key) =>
    _client.setAuthenticationKey(key);

  Future authenticate() =>
    _ensureAuthenticated()
      .then((_) => _client.authenticate());

  Future<Document> fetchPage(String path) =>
    _ensureAuthenticated()
      .then((_) => _client.fetchPage(path));

  Future<Map> performAction(Map data) =>
    _ensureAuthenticated()
      .then((_) => _client.performAction(data));

  String extractHtml(Document document) =>
    _client.extractHtml(document);

  Map jsonToMap(String json) =>
    _client.jsonToMap(json);

  List<Map> jsonListToMap(List<String> json) =>
    _client.jsonListToMap(json);

  Future _ensureAuthenticated() async {
    if (_isAuthenticated) {
      return;
    }

    if (! await _hasAuthenticated()) {
      throw new Exception('Authentication failed');
    }

    _gameConfig.set(
      _CONFIG_AUTHENTICATION_KEY,
      _client.getAuthenticationKey());
    _isAuthenticated = true;
  }

  Future<bool> _hasAuthenticated() =>
    _authenticateWithCachedKey()
      .then((isAuthenticated) async =>
        !isAuthenticated
          ? _reAuthenticate()
          : true);

  Future _reAuthenticate() =>
    _client.authenticate()
      .then((_) => _checkAuthentication());

  Future<bool> _authenticateWithCachedKey() async =>
    new Future.value(_gameConfig.get(_CONFIG_AUTHENTICATION_KEY))
      .then((String cachedKey) =>
        cachedKey != null
          ? new Future.value(_client.setAuthenticationKey(cachedKey))
              .then((_) => _checkAuthentication())
          : false);

  Future<bool> _checkAuthentication() =>
    _playerService.getPlayerStats()
      .then((stats) => stats.name != null);
}
