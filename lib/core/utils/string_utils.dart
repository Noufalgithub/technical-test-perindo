class StringUtils {
  static String maskText(String text, int startVisible, int endVisible) {
    if (text.length <= startVisible + endVisible) return text;
    final start = text.substring(0, startVisible);
    final end = text.substring(text.length - endVisible);
    final middle = '*' * (text.length - startVisible - endVisible);
    return '$start$middle$end';
  }
}
