import 'dart:async';

import 'package:html/dom.dart';

abstract class GameClientInterface {
  Future authenticate();

  String getAuthenticationKey();

  void setAuthenticationKey(String key);

  Future<Document> fetchPage(String path);

  Future<Map> performAction(Map data);

  String extractHtml(Document document);

  Map jsonToMap(String json);

  List<Map> jsonListToMap(List<String> json);
}
