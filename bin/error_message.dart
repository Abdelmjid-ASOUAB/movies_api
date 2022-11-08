class ErrorMessage {
  String message = "";

  ErrorMessage({this.message = ""});

  Map<String, dynamic> toMap() {
    return {"message": message};
  }
}
