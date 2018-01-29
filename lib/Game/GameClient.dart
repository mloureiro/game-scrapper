import 'dart:async';
import 'dart:convert';

import 'package:html/dom.dart';
import 'package:html_unescape/html_unescape.dart';

import 'package:game/Infrastructure/Client.dart';

class GameClient {
  final Client client;

  GameClient(this.client);

  Future<Document> getPage(String path) =>
    client.getToDocument(path);

  Future<Map> executeAction(Map data) =>
    client.postToJson('ajax.php', data: data)
      .then((Map json) {
        if (!json['success']) {
          throw new Exception('Request failed:\nAction: $data\nReply: $json');
        }

        return json;
      });

  String extractHtml(Document document) =>
    document.outerHtml;

  Map jsonToMap(String json) =>
    JSON.decode((new HtmlUnescape()).convert(json));

  List<Map> jsonListToMap(List<String> json) =>
    json.map(jsonToMap).toList();
}
