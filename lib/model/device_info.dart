class DeviceInfo {
  String id;
  int type;
  String name;
  // TODO 从DeviceInfo中解耦
  String icon;

  DeviceInfo(this.id, this.type, this.name, this.icon);
}
