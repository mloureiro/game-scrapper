import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:game/Game/Service/GameClientInterface.dart';
import 'package:game/Infrastructure/RequestConfig.dart';
import 'package:html/dom.dart';
import 'package:html_unescape/html_unescape.dart';

import 'package:game/Infrastructure/Client.dart';

class GameClient implements GameClientInterface {
  static const _AUTHENTICATION_COOKIE_NAME = 'stay_online';

  final Client client;
  final String baseUri;
  final String username;
  final String password;
  Cookie _authentication;

  GameClient({
    this.client,
    this.username,
    this.password,
    this.baseUri,
  });

  String getAuthenticationKey() =>
    _authentication != null
      ? _authentication.value
      : null;

  void setAuthenticationKey(String key) =>
    _authentication = new Cookie(_AUTHENTICATION_COOKIE_NAME, key);

  Future authenticate() =>
    client.request(new Config(
      method: RequestMethod.POST,
      uri: _buildUri('phoenix-ajax.php'),
      body: RequestBody.formData({
        'module': 'Member',
        'action': 'form_log_in',
        'call': 'Member',
        'login': username,
        'password': password,
        'stay_online': 1,
      }),
    ))
      .then(_extractAuthentication)
      .then(ResponseBody.json().parse)
      .then((Map json) => _throwIfRequestFail(json));

  Future<Document> fetchPage(String path) =>
    client.request(new Config(
      method: RequestMethod.GET,
      uri: _buildUri(path),
      responseType: ResponseBody.document(),
      cookies: { 'authentication': _authentication },
    ));

  Future<Map> performAction(Map data) =>
    client.request(new Config(
      method: RequestMethod.POST,
      uri: _buildUri('ajax.php'),
      body: RequestBody.formData(data),
      responseType: ResponseBody.json(),
      cookies: { 'authentication': _authentication },
    ))
      .then((Map json) => _throwIfRequestFail(json, data: data));

  String extractHtml(Document document) =>
    document.outerHtml;

  Map jsonToMap(String json) =>
    JSON.decode((new HtmlUnescape()).convert(json));

  List<Map> jsonListToMap(List<String> json) =>
    json.map(jsonToMap).toList();

  Uri _buildUri(String path) =>
    Uri.parse('${baseUri}${path}');

  Map _throwIfRequestFail(Map json, { Map data }) =>
    json['success']
      ? json
      : throw new Exception('Request failed #action: $data #reply: $json');

  HttpClientResponse _extractAuthentication(HttpClientResponse response) {
    _authentication = response.cookies.firstWhere(
      (Cookie cookie) => cookie.name == _AUTHENTICATION_COOKIE_NAME,
      orElse: () => null,
    );

    return response;
  }
}
