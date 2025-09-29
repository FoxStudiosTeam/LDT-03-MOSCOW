class AuthError extends Error{
  var message = "AuthError: Some error inside AuthLib";

  AuthError(this.message);

  @override
  String toString() {
    return message;
  }
}

class TimeOutError extends Error{
  var message = "TimeOutError: Request processing so long";
  TimeOutError(this.message);

  @override
  String toString() {
    return message;
  }
}