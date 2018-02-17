import 'dart:async';
import 'dart:mirrors';

import 'package:game/Game/Service/GameClientInterface.dart';
import 'package:game/Game/Service/PlayerService.dart';
import 'package:game/Infrastructure/Config.dart';

class AuthenticateClientProxy implements GameClientInterface {
  static const _CONFIG_AUTHENTICATION_KEY = 'authorization.key';

  final Config _gameConfig;
  final GameClientInterface _client;
  PlayerService _playerService;
  bool _isAuthenticated = false;

  AuthenticateClientProxy(this._client, this._gameConfig) {
    _playerService = new PlayerService(_client);
  }

  noSuchMethod(Invocation invocation) =>
    _ensureAuthenticated()
      .then((_) =>
        reflect(_client).invoke(
          invocation.memberName,
          invocation.positionalArguments,
          invocation.namedArguments
        ).reflectee);

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
