class ManagerTimeStatsModel {
  final String leaveCount;
  final String halfDay;
  final String overTime;
  final String shortHours;
  final String fullHours;
  final String onTimeEntry;
  final String onTimeExit;
  final String lateEntry;
  final String lateExit;
  final String extendedBreak;

  ManagerTimeStatsModel({
    this.leaveCount = '0',
    this.halfDay = '0',
    this.overTime = '0',
    this.shortHours = '0',
    this.fullHours = '0',
    this.onTimeEntry = '0',
    this.onTimeExit = '0',
    this.lateEntry = '0',
    this.lateExit = '0',
    this.extendedBreak = '0',
  });

  factory ManagerTimeStatsModel.fromJson(Map<String, dynamic> json) {
    final data = json['today_emp_details'] ?? json;
    return ManagerTimeStatsModel(
      leaveCount: (data['leave_count'] ?? '0').toString(),
      halfDay: (data['half_day'] ?? '0').toString(),
      overTime: (data['over_time'] ?? '0').toString(),
      shortHours: (data['short_hours'] ?? '0').toString(),
      fullHours: (data['full_hours'] ?? '0').toString(),
      onTimeEntry: (data['on_time_entry'] ?? '0').toString(),
      onTimeExit: (data['on_time_exit'] ?? '0').toString(),
      lateEntry: (data['late_entry'] ?? '0').toString(),
      lateExit: (data['late_exit'] ?? '0').toString(),
      extendedBreak: (data['extended_break'] ?? '0').toString(),
    );
  }

  /// Convert model fields to the statsData map keys used by the UI
  Map<String, String> toStatsMap() {
    return {
      'Full Hours': fullHours,
      'Extended Breaks': extendedBreak,
      'Leave': leaveCount,
      'On-time(Entry)': onTimeEntry,
      'On-time(Exit)': onTimeExit,
      'Late Entry': lateEntry,
      'Late Exit': lateExit,
      'Short Hours': shortHours,
      'Over Time': overTime,
    };
  }
}
