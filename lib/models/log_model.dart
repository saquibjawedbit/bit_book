enum AttendanceType { present, absent, leave }

class LogModel {
  final String id; // Add this field
  final String subjectId;
  final AttendanceType type;
  final String? reason;
  final DateTime date;

  LogModel({
    String? id, // Make it optional in constructor
    required this.subjectId,
    required this.type,
    this.reason,
    DateTime? date,
  })  : this.id = id ??
            'log_${DateTime.now().millisecondsSinceEpoch}_${DateTime.now().microsecond}', // Generate if not provided
        this.date = date ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id, // Add to JSON
      'subjectId': subjectId,
      'type': type.toString(),
      'reason': reason,
      'date': date.toIso8601String(),
    };
  }

  factory LogModel.fromMap(Map<String, dynamic> map) {
    return LogModel(
      id: map['id'] ??
          'log_${DateTime.now().millisecondsSinceEpoch}_${DateTime.now().microsecond}', // Add to factory constructor
      subjectId: map['subjectId'] as String,
      type: AttendanceType.values.firstWhere(
        (e) => e.toString() == map['type'],
      ),
      reason: map['reason'] as String?,
      date: DateTime.parse(map['date'] as String),
    );
  }

  String getType() {
    if (type == AttendanceType.present) {
      return "Present";
    } else if (type == AttendanceType.absent) {
      return "Absent";
    } else {
      return "Leave";
    }
  }

  // Helper method to get logs between date range
  static bool isInDateRange(LogModel log, DateTime start, DateTime end) {
    return log.date.isAfter(start) && log.date.isBefore(end);
  }

  // Helper method to get logs by type
  static bool isSameType(LogModel log, AttendanceType type) {
    return log.type == type;
  }
}
