import 'dart:mirrors';

import 'package:game/Game/Service/GameClientInterface.dart';

class AuthenticateClientProxy implements GameClientInterface {
  final GameClientInterface _client;
  bool _isAuthenticated = false;

  AuthenticateClientProxy(this._client);

  noSuchMethod(Invocation invocation) async {
    if (!_isAuthenticated) {
      await _client.authenticate();
      _isAuthenticated = true;
    }

    return reflect(_client).invoke(
      invocation.memberName,
      invocation.positionalArguments,
      invocation.namedArguments
    ).reflectee;
  }
}
