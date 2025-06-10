class ShiftAssignment {
  final int shiftId;
  final DateTime date;
  final String startTime;
  final String endTime;
  final int shift_assignment_id;

  ShiftAssignment({
    required this.shiftId,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.shift_assignment_id,
  });

  factory ShiftAssignment.fromJson(Map<String, dynamic> json) {
    return ShiftAssignment(
      shiftId: json['shiftId'] ?? 0,
      date: DateTime.parse(json['date'] ?? DateTime.now().toIso8601String()),
      startTime: json['start_time']?.toString() ?? '',
      endTime: json['end_time']?.toString() ?? '',
      shift_assignment_id: json['shift_assignment_id'] ?? 0,
    );
  }
}
