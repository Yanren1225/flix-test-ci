class DeviceInfo {
  String id;
  int type;
  String name;
  // TODO 从DeviceInfo中解耦
  String icon;
  int? version;
  DeviceInfo(this.id, this.type, this.name, this.icon, this.version);

  @override
  String toString() {
    return 'DeviceInfo{id: $id, type: $type, name: $name, icon: $icon, version: $version}';
  }
}
