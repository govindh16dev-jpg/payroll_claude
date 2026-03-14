// ─────────────────────────────────────────────
// MAIN TIME PAGE MODELS (from /mobile/time/view)
// ─────────────────────────────────────────────

class EmployeeTimeModel {
  String? dataKey;
  String? empTimeId;
  String? shiftId;
  String? inTime;
  String? outTime;
  String? workingHours;
  String? workingStatusId;
  String? workingStatusName;
  String? date;
  String? clockOutDate;
  String? activeStatus;

  EmployeeTimeModel({
    this.dataKey,
    this.empTimeId,
    this.shiftId,
    this.inTime,
    this.outTime,
    this.workingHours,
    this.workingStatusId,
    this.workingStatusName,
    this.date,
    this.clockOutDate,
    this.activeStatus,
  });

  factory EmployeeTimeModel.fromJson(Map<String, dynamic> json) {
    return EmployeeTimeModel(
      dataKey: json['data_key'],
      empTimeId: json['emp_time_id'],
      shiftId: json['shift_id'],
      inTime: json['in_time'],
      outTime: json['out_time'],
      workingHours: json['working_hours'],
      workingStatusId: json['working_status_id'],
      workingStatusName: json['working_status_name'],
      date: json['date'],
      clockOutDate: json['clock_out_date'],
      activeStatus: json['active_status'],
    );
  }

  Map<String, dynamic> toJson() => {
        'data_key': dataKey,
        'emp_time_id': empTimeId,
        'shift_id': shiftId,
        'in_time': inTime,
        'out_time': outTime,
        'working_hours': workingHours,
        'working_status_id': workingStatusId,
        'working_status_name': workingStatusName,
        'date': date,
        'clock_out_date': clockOutDate,
        'active_status': activeStatus,
      };
}

class WorkingStatusModel {
  String? dataKey;
  String? workedMonthHours;
  String? shortMonthHours;
  String? overtimeMonthHours;
  String? workedWeekHours;
  String? shortWeekHours;
  String? overtimeWeekHours;
  String? workedYesterdayHours;
  String? shortYesterdayHours;
  String? overtimeYesterdayHours;

  WorkingStatusModel({
    this.dataKey,
    this.workedMonthHours,
    this.shortMonthHours,
    this.overtimeMonthHours,
    this.workedWeekHours,
    this.shortWeekHours,
    this.overtimeWeekHours,
    this.workedYesterdayHours,
    this.shortYesterdayHours,
    this.overtimeYesterdayHours,
  });

  factory WorkingStatusModel.fromJson(Map<String, dynamic> json) {
    return WorkingStatusModel(
      dataKey: json['data_key'],
      workedMonthHours: json['worked_month_hours'],
      shortMonthHours: json['short_month_hours'],
      overtimeMonthHours: json['overtime_month_hours'],
      workedWeekHours: json['worked_week_hours'],
      shortWeekHours: json['short_week_hours'],
      overtimeWeekHours: json['overtime_week_hours'],
      workedYesterdayHours: json['worked_yesterday_hours'],
      shortYesterdayHours: json['short_yesterday_hours'],
      overtimeYesterdayHours: json['overtime_yesterday_hours'],
    );
  }

  Map<String, dynamic> toJson() => {
        'data_key': dataKey,
        'worked_month_hours': workedMonthHours,
        'short_month_hours': shortMonthHours,
        'overtime_month_hours': overtimeMonthHours,
        'worked_week_hours': workedWeekHours,
        'short_week_hours': shortWeekHours,
        'overtime_week_hours': overtimeWeekHours,
        'worked_yesterday_hours': workedYesterdayHours,
        'short_yesterday_hours': shortYesterdayHours,
        'overtime_yesterday_hours': overtimeYesterdayHours,
      };
}

class EmployeeBreakModel {
  String? dataKey;
  String? empBreakId;
  String? empTimeId; // ✅ ADDED — needed for endBreak API call
  String? startBreak;
  String? endBreak;
  String? totalBreak;

  EmployeeBreakModel({
    this.dataKey,
    this.empBreakId,
    this.empTimeId,
    this.startBreak,
    this.endBreak,
    this.totalBreak,
  });

  factory EmployeeBreakModel.fromJson(Map<String, dynamic> json) {
    return EmployeeBreakModel(
      dataKey: json['data_key'],
      empBreakId: json['emp_break_id'],
      empTimeId: json['emp_time_id'], // ✅ ADDED
      startBreak: json['start_break'],
      endBreak: json['end_break'],
      totalBreak: json['total_break'],
    );
  }

  Map<String, dynamic> toJson() => {
        'data_key': dataKey,
        'emp_break_id': empBreakId,
        'emp_time_id': empTimeId,
        'start_break': startBreak,
        'end_break': endBreak,
        'total_break': totalBreak,
      };
}

class ShiftTimeModel {
  String? dataKey;
  String? shiftId;
  String? inOutDate;
  String? startTime;
  String? endTime;
  String? inTime;
  String? outTime;
  String? workingHours;
  String? workingStatusName;
  String? workingStatusId;
  String? date;

  ShiftTimeModel({
    this.dataKey,
    this.shiftId,
    this.inOutDate,
    this.startTime,
    this.endTime,
    this.inTime,
    this.outTime,
    this.workingHours,
    this.workingStatusName,
    this.workingStatusId,
    this.date,
  });

  factory ShiftTimeModel.fromJson(Map<String, dynamic> json) {
    return ShiftTimeModel(
      dataKey: json['data_key'],
      shiftId: json['shift_id'],
      inOutDate: json['in_out_date'],
      startTime: json['start_time'],
      endTime: json['end_time'],
      inTime: json['in_time'],
      outTime: json['out_time'],
      workingHours: json['working_hours'],
      workingStatusName: json['working_status_name'],
      workingStatusId: json['working_status_id'],
      date: json['date'],
    );
  }

  Map<String, dynamic> toJson() => {
        'data_key': dataKey,
        'shift_id': shiftId,
        'in_out_date': inOutDate,
        'start_time': startTime,
        'end_time': endTime,
        'in_time': inTime,
        'out_time': outTime,
        'working_hours': workingHours,
        'working_status_name': workingStatusName,
        'working_status_id': workingStatusId,
        'date': date,
      };
}

class CurrentShiftModel {
  String? dataKey;
  String? shiftId;
  String? shiftName;
  String? startTime;
  String? endTime;
  String? currentShift;
  String? breakDuration;

  CurrentShiftModel({
    this.dataKey,
    this.shiftId,
    this.shiftName,
    this.startTime,
    this.endTime,
    this.currentShift,
    this.breakDuration,
  });

  factory CurrentShiftModel.fromJson(Map<String, dynamic> json) {
    String? startTime = json['start_time'];
    String? endTime = json['end_time'];
    final String? currentShift = json['current_shift'];

    // Parse "09:30 AM - 07:00 PM" format if direct fields are missing
    if ((startTime == null || startTime.isEmpty) &&
        currentShift != null &&
        currentShift.contains(' - ')) {
      final parts = currentShift.split(' - ');
      if (parts.length == 2) {
        startTime = parts[0].trim();
        endTime = parts[1].trim();
      }
    }

    return CurrentShiftModel(
      dataKey: json['data_key'],
      shiftId: json['shift_id'],
      shiftName: json['shift_name'],
      startTime: startTime,
      endTime: endTime,
      currentShift: currentShift,
      breakDuration: json['break_duration']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'data_key': dataKey,
        'shift_id': shiftId,
        'shift_name': shiftName,
        'start_time': startTime,
        'end_time': endTime,
        'current_shift': currentShift,
        'break_duration': breakDuration,
      };
}

class TimeCalendarModel {
  String? dataKey;
  String? start;
  String? end;
  String? shiftId;
  String? allotedTime;
  String? actualTime;
  String? empTimeId;
  String? isCompOff;
  String? status;
  String? statusKey;
  String? isRegularize;

  TimeCalendarModel({
    this.dataKey,
    this.start,
    this.end,
    this.shiftId,
    this.allotedTime,
    this.actualTime,
    this.empTimeId,
    this.isCompOff,
    this.status,
    this.statusKey,
    this.isRegularize,
  });

  factory TimeCalendarModel.fromJson(Map<String, dynamic> json) {
    return TimeCalendarModel(
      dataKey: json['data_key'],
      start: json['start'],
      end: json['end'],
      shiftId: json['shift_id'],
      allotedTime: json['alloted_time'],
      actualTime: json['actual_time'],
      empTimeId: json['emp_time_id'],
      isCompOff: json['is_comp_off'],
      status: json['status'],
      statusKey: json['status_key'],
      isRegularize: json['is_regularize'],
    );
  }

  Map<String, dynamic> toJson() => {
        'data_key': dataKey,
        'start': start,
        'end': end,
        'shift_id': shiftId,
        'alloted_time': allotedTime,
        'actual_time': actualTime,
        'emp_time_id': empTimeId,
        'is_comp_off': isCompOff,
        'status': status,
        'status_key': statusKey,
        'is_regularize': isRegularize,
      };
}

class GeoTimeModel {
  String? dataKey;
  String? geoTimeId;
  String? empTimeId;
  String? file;
  String? fileName;
  String? actionType;
  String? latitude;
  String? longitude;

  GeoTimeModel({
    this.dataKey,
    this.geoTimeId,
    this.empTimeId,
    this.file,
    this.fileName,
    this.actionType,
    this.latitude,
    this.longitude,
  });

  factory GeoTimeModel.fromJson(Map<String, dynamic> json) {
    return GeoTimeModel(
      dataKey: json['data_key'],
      geoTimeId: json['geo_time_id'],
      empTimeId: json['emp_time_id'],
      file: json['file'],
      fileName: json['file_name'],
      actionType: json['action_type'],
      latitude: json['latitude'],
      longitude: json['longitude'],
    );
  }

  Map<String, dynamic> toJson() => {
        'data_key': dataKey,
        'geo_time_id': geoTimeId,
        'emp_time_id': empTimeId,
        'file': file,
        'file_name': fileName,
        'action_type': actionType,
        'latitude': latitude,
        'longitude': longitude,
      };
}


class TimePopupModel {
  List<PopupShiftTime>? shiftTime;
  List<PopupShiftBreak>? shiftBreak;
  List<PopupEmployeeShiftTime>? employeeShiftTime;
  List<PopupEmployeeBreakTime>? employeeBreakTime;
  List<dynamic>? leavePlanType;

  TimePopupModel({
    this.shiftTime,
    this.shiftBreak,
    this.employeeShiftTime,
    this.employeeBreakTime,
    this.leavePlanType,
  });

  factory TimePopupModel.fromJson(Map<String, dynamic> json) {
    return TimePopupModel(
      shiftTime: json['shift_time'] != null
          ? (json['shift_time'] as List)
              .map((i) => PopupShiftTime.fromJson(i))
              .toList()
          : null,
      shiftBreak: json['shift_break'] != null
          ? (json['shift_break'] as List)
              .map((i) => PopupShiftBreak.fromJson(i))
              .toList()
          : null,
      employeeShiftTime: json['employee_shift_time'] != null
          ? (json['employee_shift_time'] as List)
              .map((i) => PopupEmployeeShiftTime.fromJson(i))
              .toList()
          : null,
      employeeBreakTime: json['employee_break_time'] != null
          ? (json['employee_break_time'] as List)
              .map((i) => PopupEmployeeBreakTime.fromJson(i))
              .toList()
          : null,
      leavePlanType: json['leave_plan_type'],
    );
  }
}

class PopupShiftTime {
  String? allotedStart;
  String? allotedEnd;
  String? allotedHours;
  String? timeFormat;
  String? date;
  String? clockOutDate;

  PopupShiftTime({
    this.allotedStart,
    this.allotedEnd,
    this.allotedHours,
    this.timeFormat,
    this.date,
    this.clockOutDate,
  });

  factory PopupShiftTime.fromJson(Map<String, dynamic> json) {
    return PopupShiftTime(
      allotedStart: json['alloted_start'],
      allotedEnd: json['alloted_end'],
      allotedHours: json['alloted_hours'],
      timeFormat: json['time_format'],
      date: json['date'],
      clockOutDate: json['clock_out_date'],
    );
  }
}

class PopupShiftBreak {
  String? breakStartTime;
  String? breakEndTime;
  String? breaksLabel;
  String? breaksInMinutes;

  PopupShiftBreak({
    this.breakStartTime,
    this.breakEndTime,
    this.breaksLabel,
    this.breaksInMinutes,
  });

  factory PopupShiftBreak.fromJson(Map<String, dynamic> json) {
    return PopupShiftBreak(
      breakStartTime: json['break_start_time'],
      breakEndTime: json['break_end_time'],
      breaksLabel: json['breaks_label'],
      breaksInMinutes: json['breaks_in_minutes'],
    );
  }
}

class PopupEmployeeShiftTime {
  String? actualStart;
  String? actualEnd;
  String? actualHours;
  String? date;
  String? employeeNo;
  String? dayStatus;
  String? action;
  String? modifyInTime;
  String? modifyOutTime;
  String? employeeRemark;
  String? clockOutDate;
  String? empTimeId;
  String? isRegularize;
  String? shortHours;
  String? overTime;
  String? breakHours;
  String? workingHours;

  PopupEmployeeShiftTime({
    this.actualStart,
    this.actualEnd,
    this.actualHours,
    this.date,
    this.employeeNo,
    this.dayStatus,
    this.action,
    this.modifyInTime,
    this.modifyOutTime,
    this.employeeRemark,
    this.clockOutDate,
    this.empTimeId,
    this.isRegularize,
    this.shortHours,
    this.overTime,
    this.breakHours,
    this.workingHours,
  });

  factory PopupEmployeeShiftTime.fromJson(Map<String, dynamic> json) {
    return PopupEmployeeShiftTime(

      actualStart: json['actual_start'],
      actualEnd: json['actual_end'],
      actualHours: json['actual_hours'],
      date: json['date'],
      employeeNo: json['employee_no'],
      dayStatus: json['day_status'],
      action: json['action'],
      modifyInTime: json['modify_in_time'],
      modifyOutTime: json['modify_out_time'],
      employeeRemark: json['employee_remark'],
      clockOutDate: json['clock_out_date'],
      empTimeId: json['emp_time_id'],
      isRegularize: json['is_regularize'],
      shortHours: json['short_hours'],
      overTime: json['over_time'],
      breakHours: json['break_hours'],
      workingHours: json['working_hours'],
    );
  }
}

class WorkStatusItem {
  final String? empTimeId;
  final String? employeeId;
  final String? timeDate;
  final String? clockIn;
  final String? clockOut;
  final String? breakDuration; // "0h:52m"
  final String? shiftName;    // "09:00 AM to 06:00 PM"

  WorkStatusItem({
    this.empTimeId,
    this.employeeId,
    this.timeDate,
    this.clockIn,
    this.clockOut,
    this.breakDuration,
    this.shiftName,
  });

  factory WorkStatusItem.fromJson(Map<String, dynamic> json) {
    return WorkStatusItem(
      empTimeId:     json['emp_time_id'],
      employeeId:    json['employee_id'],
      timeDate:      json['time_date'],
      clockIn:       json['clock_in'],
      clockOut:      json['clock_out'],
      breakDuration: json['break_duration'],
      shiftName:     json['shift_name'],
    );
  }
}

class PopupEmployeeBreakTime {
  String? startBreak;
  String? endBreak;
  String? totalBreak;
  String? modifyStartBreak;
  String? modifyEndBreak;
  String? empBreakId;
  String? empTimeId;

  PopupEmployeeBreakTime({
    this.startBreak,
    this.endBreak,
    this.totalBreak,
    this.modifyStartBreak,
    this.modifyEndBreak,
    this.empBreakId,
    this.empTimeId,
  });

  factory PopupEmployeeBreakTime.fromJson(Map<String, dynamic> json) {
    return PopupEmployeeBreakTime(
      startBreak: json['start_break'],
      endBreak: json['end_break'],
      totalBreak: json['total_break'],
      modifyStartBreak: json['modify_start_break'],
      modifyEndBreak: json['modify_end_break'],
      empBreakId: json['emp_break_id'],
      empTimeId: json['emp_time_id'],
    );
  }
}
