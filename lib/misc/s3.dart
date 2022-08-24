import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';

class S3 {
  final String _accessKeyId;
  //final String _secretAccessKey;
  final Function _hmacFactory;
  String _host;
  String bucket;

  HttpClient client = new HttpClient();

  S3(String accessKeyId, String secretAccessKey, String host, String bucket)
      : this.config(accessKeyId, host, bucket,
            () => new Hmac(sha1, const Utf8Codec().encode(secretAccessKey)));

  S3.config(this._accessKeyId, this._host, this.bucket, this._hmacFactory);

  Uri getUrl(String path) => Uri.parse('$_host/$bucket/$path');

  Future<Null> upload(List<int> data, String path,
      {ContentType contentType, int maxAge, int trials: 100}) async {
    // TODO use maxAge
    final String ct = contentType == null ? '' : contentType.toString();
    return _repeatMoreTimes(() => _put(path, data, ct), trials);
  }

  Future<HttpClientRequest> delete(String path) {
    return client
        .openUrl('DELETE', getUrl(path))
        .then((HttpClientRequest request) {
      final DateTime now = new DateTime.now();
      request.headers.date = now;
      final Map<String, dynamic> amzHeaders = <String, dynamic>{};
      final String contentType = '';
      request.headers.add(HttpHeaders.acceptEncodingHeader, 'deflate');
      final String authorization = _getAuthorization(
          path, 'DELETE', '', contentType, now, bucket,
          amzHeaders: amzHeaders);
      request.headers.add(HttpHeaders.authorizationHeader, authorization);

      return request.close();
    }).then((HttpClientResponse response) {
      _examineResponse(response, 'uploading');
      return null;
    });
  }

  Future<List<int>> _put(
      String path, List<int> data, String contentType) async {
    try {
      final DateTime now = new DateTime.now();
      final Map<String, String> amzHeaders = <String, String>{
        'x-amz-acl': 'public-read'
      };
      final String authorization = _getAuthorization(
          path, 'PUT', '', contentType, now, bucket,
          amzHeaders: amzHeaders);

      /*
      var req = new http.MultipartRequest("PUT",getUrl(path));
      req.headers = {
        HttpHeaders.CONTENT_TYPE: contentType,
        HttpHeaders.CONTENT_LENGTH: data.length.toString(),
        HttpHeaders.CONNECTION: 'keep-alive',
        'x-amz-acl': 'public-read',
        HttpHeaders.ACCEPT_ENCODING: 'deflate',
        HttpHeaders.AUTHORIZATION: authorization
      };
      req.files.add(new http.MultipartFile(field, stream, length)
          'package',
          new File('build/package.tar.gz'),
          contentType: new ContentType('application', 'x-tar'));
      */

      final HttpClientRequest request =
          await client.openUrl('PUT', getUrl(path));
      request.headers.date = now;
      request.headers.add(HttpHeaders.contentTypeHeader, contentType);
      request.headers.add(HttpHeaders.contentLengthHeader, data.length);
      request.headers.add(HttpHeaders.connectionHeader, 'keep-alive');
      request.headers.add('x-amz-acl', 'public-read');
      request.headers.add(HttpHeaders.acceptEncodingHeader, 'deflate');
      request.headers.add(HttpHeaders.authorizationHeader, authorization);

      request.add(data);
      final HttpClientResponse response = await request.close();
      return _examineResponse(response, 'uploading');
    } catch (e) {
      print("errorrrrrrrrrrrrrrre $e");
    }
    return null;
  }

  Future<List<int>> _examineResponse(
      HttpClientResponse response, String operation) {
    if (response.statusCode == 200 || response.statusCode == 204) {
      print('File $operation successful. Status code: ${response.statusCode}');
      return response.drain();
    } else {
      final Utf8Decoder utf8decoder = const Utf8Decoder();
      return response.transform(utf8decoder).toList().then((List<String> data) {
        final String message = 'File $operation not successful!\n'
            'Status code: ${response.statusCode}\n'
            'Reason phrase: ${response.reasonPhrase}\n'
            'Response body:\n${data.join('')}\n';
        throw new Exception(message);
      });
    }
  }

  Future<Null> _repeatMoreTimes(Function toCall, num trials) async {
    // _repeatMoreTimes(() => _put(path, data, ct), trials)
    final Function _toCall = () =>
        toCall().then((dynamic _) => false).catchError((dynamic e, dynamic s) {
          if (e is SocketException || e is HttpException) {
            print('Repeating upload due to exception:\n$e');
            return new Future<bool>.delayed(
                new Duration(milliseconds: 100), () => true);
          } else {
            print('Error: \n' + e + s);
            throw e;
          }
        });
    await _toCall();

    //return doWhileAsync(new List.filled(trials, null), _toCall);
  }

  String _getAuthorization(String path, String httpVerb, String contentMD5,
      String contentType, DateTime now, String bucket,
      {Map<String, String> subresources: const <String, String>{},
      Map<String, String> amzHeaders: const <String, String>{}}) {
    final String date = HttpDate.format(now.toUtc());

    String canonicalizedResource = "";
    canonicalizedResource += bucket == "" ? "/" : "/$bucket/$path";
    if (subresources.isNotEmpty) {
      final List<String> keyList = subresources.keys.toList();
      keyList.sort();
      canonicalizedResource += "?${keyList[0]}";
      if (subresources[keyList[0]] != "") {
        canonicalizedResource += "=${subresources[keyList[0]]}";
      }
      keyList.removeAt(0);

      keyList.forEach((String key) {
        canonicalizedResource += "&$key";
        if (subresources[key] != "") {
          canonicalizedResource += "=${subresources[key]}";
        }
      });
    }
    String canonicalizedAmzHeaders = "";
    if (amzHeaders.isNotEmpty) {
      final List<String> buf = <String>[];
      final List<String> keyList = amzHeaders.keys.toList();
      keyList.forEach((String key) {
        final String value = amzHeaders[key];
        final String canonizedLine = '${key.toLowerCase()}:$value';
        buf.add(canonizedLine);
      });
      buf.sort();
      canonicalizedAmzHeaders = buf.join("\n");
      canonicalizedAmzHeaders += "\n";
    }

    final String stringToSign =
        "$httpVerb\n$contentMD5\n$contentType\n$date\n$canonicalizedAmzHeaders$canonicalizedResource";
    final Hmac hmac = _hmacFactory();
    final Utf8Codec codec = const Utf8Codec();
    final Base64Codec base64codec = const Base64Codec();
    print("Signature:\n$stringToSign");
    print("...end of signature.");
    final List<int> encodedToSign = codec.encode(stringToSign);
    final Digest signed = hmac.convert(encodedToSign);
    final String signature = base64codec.encode(signed.bytes);
    final String authorization = "AWS $_accessKeyId:$signature";
    return authorization;
  }

  Future<Null> dispose() {
    client.close(force: true);
    return new Future<Null>.delayed(new Duration(milliseconds: 100));
  }
}
