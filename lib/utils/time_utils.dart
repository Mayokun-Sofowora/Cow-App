class TimeUtils {
  static String formatTimeSpent(int minutes) {
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    return '$hours hrs $mins mins';
  }
}