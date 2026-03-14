import 'package:intl/intl.dart';

class ManagerRegularizeModel {
  final String employeeName;
  final String employeeId;
  final String date;
  final String type;
  final String action;
  final String allotedStartTime;
  final String allotedEndTime;
  final String actualStartTime;
  final String actualEndTime;
  final String modifyInTime; // L.Entry
  final String modifyOutTime; // L.Exit
  final String allotedBreak;
  final String actualBreak; // A.Break
  final String modifyBreak; // E.Break (if available) / checkInOverTime in UI logic
  final String employeeRemark;
  final String statusType;

  final String systemEmployeeId; // Mapped from employee_id (e.g. "106")
  final String empTimeId; // Mapped from emp_time_id (e.g. "453")

  ManagerRegularizeModel({
    required this.employeeName,
    required this.employeeId,
    required this.systemEmployeeId,
    required this.empTimeId,
    required this.date,
    required this.type,
    required this.action,
    required this.allotedStartTime,
    required this.allotedEndTime,
    required this.actualStartTime,
    required this.actualEndTime,
    required this.modifyInTime,
    required this.modifyOutTime,
    required this.allotedBreak,
    required this.actualBreak,
    required this.modifyBreak,
    required this.employeeRemark,
    required this.statusType,
  });

  factory ManagerRegularizeModel.fromJson(Map<String, dynamic> json) {
    return ManagerRegularizeModel(
      employeeName: json['employee_name'] ?? '',
      employeeId: json['employee_no'] ?? '', // Using employee_no as it looks like ID
      systemEmployeeId: json['employee_id'] ?? '',
      empTimeId: json['emp_time_id'] ?? '',
      date: json['date'] ?? '',
      type: json['type'] ?? '',
      action: json['action'] ?? 'Pending',
      allotedStartTime: json['alloted_start_time'] ?? '',
      allotedEndTime: json['alloted_end_time'] ?? '',
      actualStartTime: json['actual_start_time'] ?? '',
      actualEndTime: json['actual_end_time'] ?? '',
      modifyInTime: json['modify_in_time'] ?? '',
      modifyOutTime: json['modify_out_time'] ?? '',
      allotedBreak: json['alloted_break'] ?? '',
      actualBreak: json['actual_break'] ?? '0 Hrs 0 Mins',
      modifyBreak: json['modify_break'] ?? '0 Hrs 0 Mins',
      employeeRemark: json['employee_remark'] ?? '',
      statusType: json['type'] ?? '',
    );
  }

  /// Convert to UI Map format expected by ManagerTimePage
  Map<String, String> toUiMap() {
    return {
      'empId': employeeId,
      'empName': employeeName,
      'systemEmployeeId': systemEmployeeId,
      'empTimeId': empTimeId,
      'status': 'Regularization',
      'statusType': statusType,
      'shiftStart': _formatTime(allotedStartTime),
      'shiftEnd': _formatTime(allotedEndTime),
      'actualStart': _formatTime(actualStartTime),
      'actualEnd': _formatTime(actualEndTime),
      'break': allotedBreak,
      // Map checkInFirstIn to modify_in_time (L.Entry)
      'checkInFirstIn': _formatTime(modifyInTime),
      // Map checkInLastOut to modify_out_time (L.Exit)
      'checkInLastOut': _formatTime(modifyOutTime),
      // Map checkInBreakHours to A.Break
      'checkInBreakHours': actualBreak,
      // Map checkInOverTime to E.Break (Modify Break)
      'checkInOverTime': modifyBreak,
      'reason': employeeRemark,
      'requestStatus': _capitalize(action),
      'date': date,
    };
  }

  String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1);
  }

  String _formatTime(String timeStr) {
    if (timeStr.isEmpty) return '--:--';
    try {
      // Handle ISO format like "2026-01-12T18:30:00.694Z"
      if (timeStr.contains('T')) {
        final dt = DateTime.parse(timeStr).toLocal();
        return DateFormat('hh:mm a').format(dt);
      }
      // Handle "HH:mm:ss" like "11:52:41"
      if (timeStr.contains(':')) {
        final parts = timeStr.split(':');
        if (parts.length >= 2) {
          final now = DateTime.now();
          final dt = DateTime(
            now.year,
            now.month,
            now.day,
            int.parse(parts[0]),
            int.parse(parts[1]),
          );
          return DateFormat('hh:mm a').format(dt);
        }
      }
      return timeStr;
    } catch (e) {
      return timeStr;
    }
  }
}
