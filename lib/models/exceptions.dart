class FetchDataException implements Exception {
  String _message;

  FetchDataException(this._message);

  @override
  String toString() {
    return "Exception: $_message";
  }
}

class ResponseErrorException implements Exception {
  Map<String, dynamic> body;
  int statusError;

  ResponseErrorException(this.statusError, this.body);

  @override
  String toString() {
    return "Exception: $body";
  }
}

class ConnException implements Exception {
  String _message;

  ConnException(this._message);

  @override
  String toString() {
    return "Exception: $_message";
  }
}
