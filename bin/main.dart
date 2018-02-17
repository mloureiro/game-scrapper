import 'package:game/Game/Runner/Runner.dart' show Runner;
import 'package:game/Game/Service/AuthenticateClientProxy.dart';
import 'package:game/Game/Service/GameClient.dart' show GameClient;
import 'package:game/Infrastructure/Client.dart' show Client;
import 'package:game/Infrastructure/Config.dart' show Config;

// @TODO use event based (check once trigger required events)
// change energy, trigger check energy command again

main(List<String> arguments) {
  Config credentials = new Config('.credentials.json');
  Config gameData = new Config('.gameData.json');

  GameClient game = new GameClient(
    client: new Client(),
    username: credentials.get('username'),
    password: credentials.get('password'),
    baseUri: credentials.get('baseUri'),
  );

  new Runner(new AuthenticateClientProxy(game), gameData).run();
}
