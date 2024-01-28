abstract class MultiCastApi {
  void startScan(String multiGroup, [int? port]);

  void disconnect();

  Future<void> sendAnnouncement();
}
