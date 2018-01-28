import 'dart:async';
import 'dart:convert';

import 'package:html/dom.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:game/Infrastructure/Client.dart' as Infrastructure;

class Client {
  Infrastructure.Client client;

  Client(this.client) {}

  Future<Document> getHome() =>
    client.getToDocument('home.html');

  Future<Map> getPlayerStats() =>
    this.getHome()
      .then((Document document) =>
        this._extractJsonWithRegex(
          document,
          new RegExp(r'Hero\["infos"\] = (.*?);')
        ).first);

  List<Map> _extractJsonWithRegex(Document document, RegExp expression) =>
    expression
      .allMatches(document.outerHtml)
      .map((Match match) => match.group(1))
      .map((String rawJson) =>
        JSON.decode((new HtmlUnescape()).convert(rawJson)))
      .toList();
}


