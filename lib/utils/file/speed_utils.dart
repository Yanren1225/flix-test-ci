extension SpeedUtils on int {
  String formatSpeed() {
    if (this < 1024) {
      return '${toStringAsFixed(2)} B/S';
    } else if (this < 1024 * 1024) {
      return '${(this / 1024.0).toStringAsFixed(2)} KB/S';
    } else if (this < 1024 * 1024 * 1024) {
      return '${(this / 1024.0 / 1024).toStringAsFixed(2)} MB/S';
    } else {
      return '${(this / 1024.0 / 1024 / 1024).toStringAsFixed(2)} GB/S';
    }
  }
}
