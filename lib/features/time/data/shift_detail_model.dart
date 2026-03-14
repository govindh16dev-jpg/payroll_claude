class ShiftDetailModel {
  final String employeeNo;
  final String employeeName;
  final String employeeId;
  final String empTimeId;
  final String date;
  final String shiftId;
  final String actualStartTime;
  final String actualEndTime;

  ShiftDetailModel({
    required this.employeeNo,
    required this.employeeName,
    required this.employeeId,
    required this.empTimeId,
    required this.date,
    required this.shiftId,
    required this.actualStartTime,
    required this.actualEndTime,
  });

  factory ShiftDetailModel.fromJson(Map<String, dynamic> json) {
    return ShiftDetailModel(
      employeeNo: json['employee_no'] ?? '',
      employeeName: json['employee_name'] ?? '',
      employeeId: json['employee_id'] ?? '',
      empTimeId: json['emp_time_id'] ?? '',
      date: json['date'] ?? '',
      shiftId: json['shift_id'] ?? '',
      actualStartTime: json['actual_start_time'] ?? '--:--',
      actualEndTime: json['actual_end_time'] ?? '--:--',
    );
  }

  Map<String, String> toUiMap({String? overrideShiftId, String? overrideShiftName}) {
    return {
      'empId': employeeNo, // Using employee_no as display ID
      'empName': employeeName,
      'shiftId': overrideShiftId ?? shiftId,
      'shiftName': overrideShiftName ?? '',
      'from': _formatTime(actualStartTime), // Map to UI 'from'
      'to': _formatTime(actualEndTime),     // Map to UI 'to'
      'date': date,
    };
  }

  String _formatTime(String time) {
    if (time.isEmpty || time == '--:--') return time;
    try {
      // Assuming time is "HH:mm:ss"
      final parts = time.split(':');
      if (parts.length >= 2) {
        final dt = DateTime(2022, 1, 1, int.parse(parts[0]), int.parse(parts[1]));
        // Format to "10:30 AM"
        // Need to import intl in file or use basic logic
        final hour = dt.hour;
        final minute = dt.minute;
        final period = hour >= 12 ? 'PM' : 'AM';
        final hour12 = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
        return "${hour12.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} $period";
      }
      return time;
    } catch (e) {
      return time;
    }
  }
}
