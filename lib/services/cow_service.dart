import 'package:cow_monitor/services/cow_repository.dart';

class CowService {
  final CowRepository _cowRepository = CowRepository();

  Future<List<Cow>> fetchCowsDataForSelectedCow(
    int cowId, DateTime start, DateTime end) async {
    int startTimestamp = start.millisecondsSinceEpoch ~/ 1000;
    int endTimestamp = end.millisecondsSinceEpoch ~/ 1000;

    return await _cowRepository.fetchCowData(
      startTimestamp, endTimestamp, cowId);
  }

  List<CowAction> processCowData(List<Cow> cows) {
    final actionCounts = <String, int>{};

    for (final cow in cows) {
      actionCounts[cow.action] = (actionCounts[cow.action] ?? 0) + 1;
    }

    return actionCounts.entries
      .map((entry) => CowAction(entry.key, entry.value))
      .toList();
  }
}

class CowAction {
  final String name;
  final int timeSpent;

  CowAction(this.name, this.timeSpent);
}