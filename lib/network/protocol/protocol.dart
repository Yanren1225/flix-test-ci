class Response<T> {
  var protocolVersion = 1;
  var data;

  void setData(Payload<T> data) {
    this.data = data;
  }

  Payload<T> getData() {
    return data;
  }

  Response(this.data);
}

class Payload<T> {
  String action = "";
}
