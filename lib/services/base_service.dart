import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart';
import 'package:shuttertop/misc/shuttertop.dart';
import 'package:shuttertop/models/exceptions.dart';
import 'package:http/http.dart' as http;

class ResponseApi<T> {
  T element;
  bool success;
  Map<String, dynamic> errors;

  ResponseApi(this.success, {this.element, this.errors});
}

class RequestListPage<T> {
  List<T> entries;
  final int totalEntries;
  int totalPages;
  int pageSize;
  int pageNumber;

  RequestListPage(this.entries, this.totalEntries);
}

abstract class BaseService {
  String get url;

  Future<bool> presign(int id, String schema, String now) async {
    final Map<String, dynamic> ret = await httpPut(
        id, <String, dynamic>{"now": now},
        putUrl: "${shuttertop.siteUrl}/presign_upload/$schema");
    return ret["success"];
  }

  Future<dynamic> httpGet(
      {Map<String, dynamic> params, String id, String getUrl}) async {
    String i = id != null ? "/$id" : "";
    if (params != null) {
      i += "?";
      String p = "";
      for (String key in params.keys) {
        if (p != "") p += "&";
        p += "$key=${params[key]}";
      }
      i += p;
    }
    print(
        "HTTP GET - ${getUrl ?? "${shuttertop.siteUrl}$url"}$i - TOKEN: ${shuttertop.token}");
    try {
      final Response response = await http.get(
          "${getUrl ?? "${shuttertop.siteUrl}$url"}$i",
          headers: _getRequestHeaders());
      return await _checkHttpResponse(response);
    } on ClientException catch (e) {
      throw new ConnException(e.message);
    } on SocketException catch (e) {
      throw new ConnException(e.message);
    }
  }

  Future<dynamic> httpPut(int id, Map<String, dynamic> body,
      {String putUrl}) async {
    const JsonCodec json = const JsonCodec();
    final String jsonBody = json.encode(body);
    print(
        "HTTP PUT - ${putUrl ?? "${shuttertop.siteUrl}$url"}/$id - BODY: $jsonBody - TOKEN: ${shuttertop.token}");
    try {
      final Response response = await http.put(
          "${putUrl ?? "${shuttertop.siteUrl}$url"}/$id",
          body: jsonBody,
          headers: _getRequestHeaders());
      return await _checkHttpResponse(response);
    } on ClientException catch (e) {
      throw new ConnException(e.message);
    } on SocketException catch (e) {
      throw new ConnException(e.message);
    }
  }

  Future<dynamic> httpDelete({
    dynamic id,
    String deleteUrl,
    Map<String, String> params,
  }) async {
    String i = id != null ? "/$id" : "";
    if (params != null) {
      i += "?";
      String p = "";
      for (String key in params.keys) {
        if (p != "") p += "&";
        p += "$key=${params[key]}";
      }
      i += p;
    }
    print(
        "HTTP DELETE - ${deleteUrl ?? "${shuttertop.siteUrl}$url"}$i - TOKEN: ${shuttertop.token}");
    try {
      final Response response = await http.delete(
          "${deleteUrl ?? "${shuttertop.siteUrl}$url"}$i",
          headers: _getRequestHeaders());
      return await _checkHttpResponse(response);
    } on ClientException catch (e) {
      throw new ConnException(e.message);
    } on SocketException catch (e) {
      throw new ConnException(e.message);
    }
  }

  Future<dynamic> httpPost(Map<String, dynamic> body, {String postUrl}) async {
    const JsonCodec json = const JsonCodec();
    final String jsonBody = json.encode(body);
    print(
        "HTTP POST - ${postUrl ?? "${shuttertop.siteUrl}$url"} - BODY: $jsonBody - TOKEN: ${shuttertop.token} - APIKEY: ${shuttertop.apiKey}");
    try {
      final Response response = await http.post(
          postUrl ?? "${shuttertop.siteUrl}$url",
          body: jsonBody,
          headers: _getRequestHeaders());
      return await _checkHttpResponse(response);
    } on ClientException catch (e) {
      throw new ConnException(e.message);
    } on SocketException catch (e) {
      throw new ConnException(e.message);
    }
  }

  /*
  Future<bool> addChannel(String name) async {
    try {
      final PhoenixSocket socket = await app.socket;
      if (!socket.channels.containsKey(name)) {
        final PhoenixChannel channel =
            new PhoenixChannel(name, <String, dynamic>{}, socket);
        channel
            .join()
            .receive(
                "ok", (dynamic resp) => print("joined the $name channel $resp"))
            .receive("error",
                (dynamic reason) => print("channel $name join failed $reason"))
            .receive("ignore",
                (Map<dynamic, dynamic> e) => print("channel $name auth error"));
        socket.channels[name] = channel;
        print("---------addChannel topic: ${channel.topic}");
        return true;
      } else
        return false;
    } catch (e) {
      print("ERRORE addChannel $e - $name");
      rethrow;
    }
  }

  Future<bool> leaveChannel(String name) async {
    print("---------leaveChannel topic: $name");
    final PhoenixSocket socket = await app.socket;
    if (socket.channels.containsKey(name)) {
      socket.channels[name].leave();
      socket.channels.remove(name);
      return true;
    }
    return false;
  }*/

  dynamic _checkHttpResponse(http.Response response) async {
    const JsonCodec json = const JsonCodec();
    final int statusCode = response.statusCode;

    if (statusCode < 200 || statusCode >= 300) {
      print(
          "ERRORE CHECK HTTP RESPONSE - $statusCode - ${response.reasonPhrase} - ${response.body}");
      if (statusCode == 422 &&
          response.body != null &&
          response.body.isNotEmpty)
        throw new ResponseErrorException(
            statusCode, json.decode(response.body));
      else
        throw new FetchDataException(
            "Error while getting [StatusCode:$statusCode, Error:${response.reasonPhrase}]");
    }
    print("HTTP RESPONSE: ${response.body}");
    if (response.body != null && response.body.isNotEmpty)
      return json.decode(response.body);
    else
      return null;
  }

  Map<String, String> _getRequestHeaders() {
    final Map<String, String> headers = <String, String>{
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'X-Api-Key': shuttertop.apiKey
    };
    if (shuttertop.token != null)
      headers['authorization'] = "Bearer ${shuttertop.token}";
    return headers;
  }

  Future<bool> checkStatusGetUrl(String url) async {
    final Response response = await http.get(url);
    return (response.statusCode >= 200 || response.statusCode < 300);
  }
}
