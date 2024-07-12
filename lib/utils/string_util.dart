
extension StringExtensions on String {
  String removeSubstring(String toRemove) {
    return replaceAll(toRemove, '');
  }

  // 一个忽略大小写移除子字符串的方法
  String removeSubstringIgnoreCase(String toRemove) {
    String lowerOriginal = toLowerCase();
    String lowerToRemove = toRemove.toLowerCase();

    String result = this;

    while (lowerOriginal.contains(lowerToRemove)) {
      int startIndex = lowerOriginal.indexOf(lowerToRemove);
      result = result.replaceRange(startIndex, startIndex + toRemove.length, '');
      lowerOriginal = result.toLowerCase();
    }

    return result;
  }
}
