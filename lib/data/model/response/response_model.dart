class ResponseModel {
  String _message;
  bool _isSuccess;

  ResponseModel(this._message, this._isSuccess);

  bool get isSuccess => _isSuccess;
  String get message => _message;
}

class ResponseTokenModel {
  String _message;
  bool _isSuccess;
  String forgottoken;

  ResponseTokenModel(this._message, this._isSuccess, this.forgottoken);

  bool get isSuccess => _isSuccess;
  String get message => _message;
  // String get forgottoken => forgottoken;
}
