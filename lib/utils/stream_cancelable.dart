extension StreamChain on Stream<List<int>> {
  Stream<List<int>> chain(Future<void> Function(Stream<List<int>>) method) {
    return asyncMap((data) async {
      await method(this);
      return data;
    });
  }
}

class Cancelable {
  var isCanceled = false;
  void cancel() {
    isCanceled = true;
  }
}

class CancelException implements Exception {
  final String? message;
  CancelException([this.message]);


  String toString() {
    Object? message = this.message;
    if (message == null) return "Exception";
    return "Exception: $message";
  }
}