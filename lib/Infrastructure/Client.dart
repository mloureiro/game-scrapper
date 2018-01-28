import 'dart:async';
import 'dart:io';
import 'dart:convert';

import 'package:html/dom.dart';
import 'package:html/parser.dart';

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
    Uri uri = this._setupUriFromPath(path);
    return this._makeRequest(uri, 'get')
      .then((HttpClientResponse res) =>
        res.asyncExpand((bytes) => new Stream.fromIterable(bytes)).toList())
      .then((bytes) => parse(bytes, sourceUrl: uri.toString()));
  }

  Future<Map> postToJson(String path, { Map data: null }) =>
    this._makeRequest(this._setupUriFromPath(path), 'post', data: data)
    .then((HttpClientResponse response) =>
      response.transform(UTF8.decoder).toList())
    .then((List l) => JSON.decode(l.join()));

  Uri _setupUriFromPath(String path) =>
    Uri.parse('${this.baseUri}${path}');

  Future<HttpClientResponse> _makeRequest(
    Uri uri,
    String method,
    { Map data }
  ) =>
    new HttpClient()
      .openUrl(method, uri)
      .then((HttpClientRequest request) =>
        this._setupRequest(request, formData: data).close());

  HttpClientRequest _setupRequest(HttpClientRequest request, { Map formData }) {
    this.cookies.forEach((String key, String value) =>
      request.cookies.add(new Cookie(key, value)));

    this.headers.forEach((String key, String value) =>
      request.headers.add(key, value));

    if (formData != null) {
      request.write(
        formData.keys
          .map((String key) => '$key=${formData[key]}')
          .join('&')
      );
      request.headers.contentType =
        new ContentType('application', 'x-www-form-urlencoded', charset: 'utf-8');
    }

    return request;
  }
}
