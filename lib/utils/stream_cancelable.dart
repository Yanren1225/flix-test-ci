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

class CancelException implements Exception {}