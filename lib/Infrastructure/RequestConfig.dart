import 'dart:async' show Future, Stream;
import 'dart:convert' show JSON, UTF8;
import 'dart:io' show HttpClientResponse, ContentType;

import 'package:html/dom.dart' show Document;
import 'package:html/parser.dart' as Parser show parse;

class RequestMethod {
  static const GET = 'GET';
  static const POST = 'POST';
  static const PUT = 'PUT';
  static const DELETE = 'DELETE';
  static const PATCH = 'PATCH';
}

class RequestBody {
  static _JsonRequest json(Map data) => new _JsonRequest(data);
  static _FormDataRequest formData(Map data) => new _FormDataRequest(data);
}

class ResponseBody {
  static _JsonResponse json() => new _JsonResponse();
  static _DocumentResponse document() => new _DocumentResponse();
}

class Config {
  final String method;
  final Uri uri;
  final _RequestBodyType body;
  final _ResponseBodyType responseType;
  final Map headers;
  final Map cookies;

  Config({
    this.method,
    this.uri,
    this.body,
    this.responseType,
    this.headers = const {},
    this.cookies = const {},
  });

  void addHeader(String name, Object value) =>
    headers[name] = value;

  void addCookie(String name, Object value) =>
    cookies[name] = value;

  bool hasResponse() =>
    responseType != null;

  bool hasBody() =>
    body != null;
}

abstract class _RequestBodyType {
  ContentType getContentType() =>
    new ContentType('application', _type(), charset: 'utf-8');
  String getBody();
  String _type();
}

class _JsonRequest extends _RequestBodyType {
  final Map json;

  _JsonRequest(this.json);
  String _type() => 'json';
  String getBody() => JSON.encode(json);
}

class _FormDataRequest extends _RequestBodyType {
  final Map formData;

  _FormDataRequest(this.formData);

  String _type() => 'x-www-form-urlencoded';

  String getBody() =>
      formData.keys
        .map((key) => '${key}=${formData[key]}')
        .join('&');
}

abstract class _ResponseBodyType {
  String getAcceptHeader() => 'Accept';
  String getAcceptValue();
  dynamic parse(HttpClientResponse response);
}

class _JsonResponse extends _ResponseBodyType {
  String getAcceptValue() => 'application/json';

  Future<Map> parse(HttpClientResponse response) async =>
    JSON.decode(await response.transform(UTF8.decoder).join());
}

class _DocumentResponse extends _ResponseBodyType {
  String getAcceptValue() => 'text/html';

  Future<Document> parse(HttpClientResponse response) async =>
     Parser.parse(
       await response.asyncExpand(
         (bytes) => new Stream.fromIterable(bytes)
       ).toList());
}
