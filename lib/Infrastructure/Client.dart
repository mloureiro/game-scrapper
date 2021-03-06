import 'dart:async' show Future;
import 'dart:io'
  show HttpClient, HttpClientRequest, HttpClientResponse, Cookie;

import 'package:game/Infrastructure/RequestConfig.dart';

class Client {
  Future request(Config config) =>
    new HttpClient().openUrl(config.method, config.uri)
      .then((HttpClientRequest request) => _addHeaders(request, config))
      .then((HttpClientRequest request) => _addCookies(request, config))
      .then((HttpClientRequest request) => _addBody(request, config))
      .then((HttpClientRequest request) => request.close())
      .then((HttpClientResponse response) =>
        config.hasResponse()
          ? config.responseType.parse(response)
          : response);

  HttpClientRequest _addCookies(HttpClientRequest request, Config config) {
    config.cookies.forEach((String key, value) =>
      value is Cookie
        ? request.cookies.add(value)
        : request.cookies.add(new Cookie(key, value)));

    return request;
  }

  HttpClientRequest _addHeaders(HttpClientRequest request, Config config) {
    config.headers.forEach((String key, value) =>
      request.headers.add(key, value));

    return request;
  }

  HttpClientRequest _addBody(HttpClientRequest request, Config config) {
    if (config.hasBody()) {
      request.headers.contentType = config.body.getContentType();
      request.contentLength = config.body.getBody().length;
      request.write(config.body.getBody());
    }

    return request;
  }
}
