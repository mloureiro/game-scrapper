import 'dart:async' show Future, Stream;
import 'dart:io'
  show HttpClient, HttpClientRequest, HttpClientResponse, ContentType, Cookie;
import 'dart:convert' show JSON, UTF8;

import 'package:html/dom.dart' show Document;
import 'package:html/parser.dart' show parse;
import 'package:game/Infrastructure/RequestConfig.dart';

class Client {
  final String baseUri;
  final Map cookies;
  final Map headers;

  Client({
    this.baseUri = '',
    this.cookies: const {},
    this.headers: const {},
  }) {}

  Future<Document> getToDocument(String path) {
    Uri uri = _setupUriFromPath(path);
    return _makeRequest(uri, 'get')
      .then((HttpClientResponse res) =>
        res.asyncExpand((bytes) => new Stream.fromIterable(bytes)).toList())
      .then((bytes) => parse(bytes, sourceUrl: uri.toString()));
  }

  Future<Map> postToJson(String path, { Map data }) =>
    _makeRequest(_setupUriFromPath(path), 'post', data: data)
      .then((HttpClientResponse response) =>
        response.transform(UTF8.decoder).toList())
      .then((List l) => JSON.decode(l.join()));

  Uri _setupUriFromPath(String path) =>
    Uri.parse('${baseUri}${path}');

  Future<HttpClientResponse> _makeRequest(
    Uri uri,
    String method,
    { Map data: const {} }
  ) =>
    new HttpClient()
      .openUrl(method, uri)
      .then((HttpClientRequest request) =>
        _setupRequest(request, formData: data).close());

  HttpClientRequest _setupRequest(HttpClientRequest request, { Map formData }) {
    cookies.forEach((String key, String value) =>
      request.cookies.add(new Cookie(key, value)));

    headers.forEach((String key, String value) =>
      request.headers.add(key, value));

    if (formData != null) {
      request.headers.contentType =
        new ContentType('application', 'x-www-form-urlencoded', charset: 'utf-8');
      request.write(
        formData.keys
          .map((String key) => '$key=${formData[key]}')
          .join('&')
      );
    }

    return request;
  }
}
