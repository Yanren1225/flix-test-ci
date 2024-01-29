extension SizeUtils on int {
  String formateBinarySize() {
    if (this < 1024) {
      return '$this B';
    } else if (this < 1024 * 1024) {
      return '${this / 1024.0} KB';
    } else if (this < 1024 * 1024 * 1024) {
      return '${this / 1024.0 / 1024} MB';
    } else {
      return '${this / 1024.0 / 1024 / 1024} GB';
    }
  }
}
