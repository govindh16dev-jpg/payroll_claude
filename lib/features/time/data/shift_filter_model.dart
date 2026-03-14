class ShiftFilterModel {
  final String shiftId;
  final String shiftName;
  final String shiftTime;

  ShiftFilterModel({
    required this.shiftId,
    required this.shiftName,
    required this.shiftTime,
  });

  factory ShiftFilterModel.fromJson(Map<String, dynamic> json) {
    return ShiftFilterModel(
      shiftId: json['shift_id'] ?? '',
      shiftName: json['shift_name'] ?? '',
      // Ensure shiftTime is populated, fallback to shiftName if needed
      shiftTime: json['shift_name'] ?? '',
    );
  }

  Map<String, String> toUiMap() {
    return {
      'shiftId': shiftId,
      'shiftName': shiftName,
      'shiftTime': shiftTime, // UI uses shiftTime key
    };
  }
}
