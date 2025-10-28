
class Schedule {
  final String id;
  String title;
  String description;
  DateTime start;
  DateTime end;
  bool enabled;

  Schedule({
    required this.id,
    required this.title,
    required this.description,
    required this.start,
    required this.end,
    this.enabled = true,
  });

  bool isSameDay(DateTime other) {
    return start.year == other.year && start.month == other.month && start.day == other.day;
  }
}