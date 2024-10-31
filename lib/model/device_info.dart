class DeviceInfo {
  String id;
  int type;
  String name;
  // TODO 从DeviceInfo中解耦
  String icon;
  int? version;
  String from;
  bool isConnecting;
  DeviceInfo(this.id, this.type, this.name, this.icon, this.version, this.from, this.isConnecting);

  @override
  String toString() {
    return 'DeviceInfo{id: $id, type: $type, name: $name, icon: $icon, version: $version, from: $from, isConnecting: $isConnecting}';
  }
}
