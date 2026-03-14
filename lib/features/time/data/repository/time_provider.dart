import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:payroll/features/manager/model/leave_action.dart';

import '../../../../routes/app_pages.dart';
import '../../../../util/getUserdata.dart';
import '../../../manager/model/manager_delegate.dart';
import '../../../profile_page/data/model/profile_model.dart';

class TimeProvider extends ApiProvider {

  // ==================== TIME MODULE APIS ====================

  /// Get Employee Time View Data (Main API for time page)
  /// Returns: employee_time, employee_break, previous_shift_time, current_shift, time_calendar, geo_time
  Future<http.Response> getEmployeeTimeView(ProfilePostData profileData, String month) async {
    try {
      final response = await post(
        ApiConstants.employeeTimeView, // "/mobile/time/view"
        body: {
          "client_id": profileData.clientId,
          "company_id": profileData.companyId,
          "employee_id": profileData.employeeId,
          "from_month_date": month,
        },
      );

      if (response.statusCode == 200) {
        return response;
      } else if (response.statusCode == 401) {
        throw CustomException('Session Expired Login/Authenticate Again!');
      } else {
        throw CustomException('Error fetching time data');
      }
    } catch (e, s) {
      debugPrint("getEmployeeTimeView Error: $e $s");
      rethrow;
    }
  }

  /// Get Time Popup Details
  Future<http.Response> getTimePopupDetails(ProfilePostData profileData, String date) async {
    try {
      final response = await post(
        ApiConstants.timePopup,
        body: {
          "client_id": profileData.clientId,
          "company_id": profileData.companyId,
          "employee_id": profileData.employeeId,
          "login_user_id": profileData.employeeId, // Assuming login_user_id is same as employee_id for now
          "date": date,
        },
      );

      if (response.statusCode == 200) {
        return response;
      } else if (response.statusCode == 401) {
        throw CustomException('Session Expired Login/Authenticate Again!');
      } else {
        throw CustomException('Error fetching popup details');
      }
    } catch (e, s) {
      debugPrint("getTimePopupDetails Error: $e $s");
      rethrow;
    }
  }

  /// Get Working Status before clock out
  Future<http.Response> getWorkingStatus(
      ProfilePostData profileData, String outTime) async {
    try {
      final response = await post(
        'time/working/status',
        body: {
          "client_id": profileData.clientId,
          "company_id": profileData.companyId,
          "employee_id": profileData.employeeId,
          "login_user_id": profileData.employeeId,
          "out_time": outTime,
        },
      );

      if (response.statusCode == 200) {
        return response;
      } else if (response.statusCode == 401) {
        throw CustomException('Session Expired Login/Authenticate Again!');
      } else {
        throw CustomException('Error fetching working status');
      }
    } catch (e, s) {
      debugPrint("getWorkingStatus Error: $e $s");
      rethrow;
    }
  }

  /// Clock In API - With Image Upload Support
  Future<http.Response> clockIn({
    required String clientId,
    required String companyId,
    required String employeeId,
    required String inTime,
    String? latitude,
    String? longitude,
    File? image, // Changed from 'photo' to 'image' to match API
  }) async {
    try {
      // Prepare body data
      Map<String, dynamic> body = {
        "client_id": clientId,
        "company_id": companyId,
        "employee_id": employeeId,
        "in_time": inTime, // Format: "HH:mm:ss" like "11:30:00"
      };

      if (latitude != null) body["latitude"] = latitude;
      if (longitude != null) body["longitude"] = longitude;

      // Prepare image map
      Map<String, File> images = {};
      if (image != null) {
        images['image'] = image; // Key must match API parameter name
      }

      // Use uploadImageFormData for multipart/form-data with image
      final response = await uploadImageFormData(
        images,
        body,
        ApiConstants.clockIn, // "/mobile/time/clock_in"
        type: "POST",
      );

      if (response.statusCode == 200) {
        return response;
      } else if (response.statusCode == 401) {
        throw CustomException('Session Expired Login/Authenticate Again!');
      } else {
        final responseData = jsonDecode(response.body);
        String errorMsg = responseData['message'] ?? 'Clock in failed';
        throw CustomException(errorMsg);
      }
    } catch (e, s) {
      debugPrint("clockIn Error: $e $s");
      rethrow;
    }
  }

  /// Clock Out API - With Image Upload Support
  Future<http.Response> clockOut({
    required String clientId,
    required String companyId,
    required String employeeId,
    required String empTimeId,
    required String outTime,
    String? latitude,
    String? longitude,
    File? image,
    String? workingStatusId,
    String? workingHours,
  }) async {
    try {
      // Prepare body data
      Map<String, dynamic> body = {
        "client_id": clientId,
        "company_id": companyId,
        "employee_id": employeeId,
        "emp_time_id": empTimeId,
        "out_time": outTime, // Format: "HH:mm:ss"
      };

      if (latitude != null) body["latitude"] = latitude;
      if (longitude != null) body["longitude"] = longitude;
      if (workingStatusId != null) body["working_status_id"] = workingStatusId;
      if (workingHours != null) body["working_hours"] = workingHours;

      // Prepare image map
      Map<String, File> images = {};
      if (image != null) {
        images['image'] = image;
      }

      // Use uploadImageFormData for multipart/form-data with image
      final response = await uploadImageFormData(
        images,
        body,
        ApiConstants.clockOut, // "/mobile/time/clock_out"
        type: "POST",
      );

      if (response.statusCode == 200) {
        return response;
      } else if (response.statusCode == 401) {
        throw CustomException('Session Expired Login/Authenticate Again!');
      } else {
        final responseData = jsonDecode(response.body);
        String errorMsg = responseData['message'] ?? 'Clock out failed';
        throw CustomException(errorMsg);
      }
    } catch (e, s) {
      debugPrint("clockOut Error: $e $s");
      rethrow;
    }
  }

  /// Start Break API
  Future<http.Response> startBreak({
    required String clientId,
    required String companyId,
    required String employeeId,
    required String startBreakTime,
    required String loginUserId,
  }) async {
    try {
      final response = await post(
        ApiConstants.startBreak, // "/mobile/time/break/start"
        body: {
          "client_id": clientId,
          "company_id": companyId,
          "employee_id": employeeId,
          "start_break": startBreakTime,
          "login_user_id": loginUserId,
        },
      );

      if (response.statusCode == 200) {
        return response;
      } else if (response.statusCode == 401) {
        throw CustomException('Session Expired Login/Authenticate Again!');
      } else {
        throw CustomException('Failed to start break');
      }
    } catch (e, s) {
      debugPrint("startBreak Error: $e $s");
      rethrow;
    }
  }

  /// End Break API
  Future<http.Response> endBreak({
    required String clientId,
    required String companyId,
    required String employeeId,
    required String endBreakTime,
    required String loginUserId,
  }) async {
    try {
      final response = await post(
        ApiConstants.endBreak, // "/mobile/time/break/end"
        body: {
          "client_id": clientId,
          "company_id": companyId,
          "employee_id": employeeId,
          "login_user_id": loginUserId,
          "end_break": endBreakTime,
        },
      );

      if (response.statusCode == 200) {
        return response;
      } else if (response.statusCode == 401) {
        throw CustomException('Session Expired Login/Authenticate Again!');
      } else {
        throw CustomException('Failed to end break');
      }
    } catch (e, s) {
      debugPrint("endBreak Error: $e $s");
      rethrow;
    }
  }

  /// Get Time Calendar Data for specific month
  Future<http.Response> getTimeCalendar({
    required String clientId,
    required String companyId,
    required String employeeId,
    required String month, // Format: "2025-01"
  }) async {
    try {
      final response = await post(
        ApiConstants.timeCalendar, // "/mobile/time/calendar"
        body: {
          "client_id": clientId,
          "company_id": companyId,
          "employee_id": employeeId,
          "month": month,
        },
      );

      if (response.statusCode == 200) {
        return response;
      } else if (response.statusCode == 401) {
        throw CustomException('Session Expired Login/Authenticate Again!');
      } else {
        throw CustomException('Failed to fetch calendar data');
      }
    } catch (e, s) {
      debugPrint("getTimeCalendar Error: $e $s");
      rethrow;
    }
  }

  /// Get Time Details for specific date
  Future<http.Response> getTimeDetails({
    required String clientId,
    required String companyId,
    required String employeeId,
    required String date, // Format: "2025-01-06"
  }) async {
    try {
      final response = await post(
        ApiConstants.timeDetails, // "/mobile/time/details"
        body: {
          "client_id": clientId,
          "company_id": companyId,
          "employee_id": employeeId,
          "date": date,
        },
      );

      if (response.statusCode == 200) {
        return response;
      } else if (response.statusCode == 401) {
        throw CustomException('Session Expired Login/Authenticate Again!');
      } else {
        throw CustomException('Failed to fetch time details');
      }
    } catch (e, s) {
      debugPrint("getTimeDetails Error: $e $s");
      rethrow;
    }
  }

  /// Request Regularization - With Image Upload Support
  Future<http.Response> requestRegularization({
    required String clientId,
    required String companyId,
    required String employeeId,
    required String empTimeId,
    required String date,
    required String inTime,
    required String outTime,
    required String reason,
    File? attachment,
  }) async {
    try {
      // Prepare body data
      Map<String, dynamic> body = {
        "client_id": clientId,
        "company_id": companyId,
        "employee_id": employeeId,
        "emp_time_id": empTimeId,
        "date": date,
        "in_time": inTime,
        "out_time": outTime,
        "reason": reason,
      };

      // Prepare image map
      Map<String, File> images = {};
      if (attachment != null) {
        images['attachment'] = attachment;
      }

      // Use uploadImageFormData if there's an attachment
      final response = attachment != null
          ? await uploadImageFormData(
        images,
        body,
        ApiConstants.timeRegularization, // "/mobile/time/regularize"
        type: "POST",
      )
          : await post(
        ApiConstants.timeRegularization,
        body: body,
      );

      if (response.statusCode == 200) {
        return response;
      } else if (response.statusCode == 401) {
        throw CustomException('Session Expired Login/Authenticate Again!');
      } else {
        final responseData = jsonDecode(response.body);
        String errorMsg = responseData['message'] ?? 'Regularization request failed';
        throw CustomException(errorMsg);
      }
    } catch (e, s) {
      debugPrint("requestRegularization Error: $e $s");
      rethrow;
    }
  }

  /// Get Time Statistics (Today, Yesterday, Week, Month)
  Future<http.Response> getTimeStatistics({
    required String clientId,
    required String companyId,
    required String employeeId,
    required String period, // "today", "yesterday", "week", "month"
  }) async {
    try {
      final response = await post(
        ApiConstants.timeStatistics, // "/mobile/time/statistics"
        body: {
          "client_id": clientId,
          "company_id": companyId,
          "employee_id": employeeId,
          "period": period,
        },
      );

      if (response.statusCode == 200) {
        return response;
      } else if (response.statusCode == 401) {
        throw CustomException('Session Expired Login/Authenticate Again!');
      } else {
        throw CustomException('Failed to fetch statistics');
      }
    } catch (e, s) {
      debugPrint("getTimeStatistics Error: $e $s");
      rethrow;
    }
  }

  /// Get Time History
  Future<http.Response> getTimeHistory({
    required String clientId,
    required String companyId,
    required String employeeId,
    required String fromDate,
    required String toDate,
  }) async {
    try {
      final response = await post(
        ApiConstants.timeHistory, // "/mobile/time/history"
        body: {
          "client_id": clientId,
          "company_id": companyId,
          "employee_id": employeeId,
          "from_date": fromDate,
          "to_date": toDate,
        },
      );

      if (response.statusCode == 200) {
        return response;
      } else if (response.statusCode == 401) {
        throw CustomException('Session Expired Login/Authenticate Again!');
      } else {
        throw CustomException('Failed to fetch time history');
      }
    } catch (e, s) {
      debugPrint("getTimeHistory Error: $e $s");
      rethrow;
    }
  }

  /// Get Employee Route List (geo details for employee)
  Future<http.Response> getEmployeeRouteList({
    required String clientId,
    required String companyId,
    required String employeeId,
    required String fromDate,
  }) async {
    try {
      final response = await post(
        ApiConstants.employeeRouteList, // "/mobile/time/route/list"
        body: {
          "client_id": clientId,
          "company_id": companyId,
          "employee_id": employeeId,
          "from_date": fromDate,
        },
      );

      if (response.statusCode == 200) {
        return response;
      } else if (response.statusCode == 401) {
        throw CustomException('Session Expired Login/Authenticate Again!');
      } else {
        throw CustomException('Failed to fetch route list');
      }
    } catch (e, s) {
      debugPrint("getEmployeeRouteList Error: \$e \$s");
      rethrow;
    }
  }

  /// Update Geo Location (for tracking during work)
  Future<http.Response> updateGeoLocation({
    required String clientId,
    required String companyId,
    required String employeeId,
    required String empTimeId,
    required String latitude,
    required String longitude,
    required String address,
  }) async {
    try {
      final response = await post(
        ApiConstants.updateGeoLocation, // "/mobile/time/geo/update"
        body: {
          "client_id": clientId,
          "company_id": companyId,
          "employee_id": employeeId,
          "emp_time_id": empTimeId,
          "latitude": latitude,
          "longitude": longitude,
          "address": address,
        },
      );

      if (response.statusCode == 200) {
        return response;
      } else if (response.statusCode == 401) {
        throw CustomException('Session Expired Login/Authenticate Again!');
      } else {
        throw CustomException('Failed to update location');
      }
    } catch (e, s) {
      debugPrint("updateGeoLocation Error: $e $s");
      rethrow;
    }
  }

  /// Get Shift Details
  // Future<http.Response> getShiftDetails({
  //   required String clientId,
  //   required String companyId,
  //   required String employeeId,
  // }) async {
  //   try {
  //     final response = await post(
  //       ApiConstants.shiftDetails, // "/mobile/time/shift"
  //       body: {
  //         "client_id": clientId,
  //         "company_id": companyId,
  //         "employee_id": employeeId,
  //       },
  //     );
  //
  //     if (response.statusCode == 200) {
  //       return response;
  //     } else if (response.statusCode == 401) {
  //       throw CustomException('Session Expired Login/Authenticate Again!');
  //     } else {
  //       throw CustomException('Failed to fetch shift details');
  //     }
  //   } catch (e, s) {
  //     debugPrint("getShiftDetails Error: $e $s");
  //     rethrow;
  //   }
  // }

  /// Get Calendar Popup Data for specific date
  Future<http.Response> getCalendarPopup({
    required String clientId,
    required String companyId,
    required String employeeId,
    required String loginUserId,
    required String date,
  }) async {
    try {
      final response = await post(
        ApiConstants.calendarPopup, // "/mobile/time/calendar/popup"
        body: {
          "client_id": clientId,
          "company_id": companyId,
          "login_user_id": loginUserId,
          "employee_id": employeeId,
          "date": date,
        },
      );

      if (response.statusCode == 200) {
        return response;
      } else if (response.statusCode == 401) {
        throw CustomException('Session Expired Login/Authenticate Again!');
      } else {
        throw CustomException('Failed to get calendar popup data');
      }
    } catch (e, s) {
      debugPrint("getCalendarPopup Error: $e $s");
      rethrow;
    }
  }

  /// Modify Attendance - Request time modification
  Future<http.Response> modifyAttendance({
    required String actionFlag,
    required String clientId,
    required String companyId,
    required String employeeId,
    required String modifyInTime,
    required String modifyOutTime,
    required String otKey,
    required String modifyEmpTimeId,
    required List<Map<String, String>> empBreaks, // each map must include all required fields
    required String employeeRemark,
    required String loginUserId,
  }) async {
    try {
      final response = await post(
        ApiConstants.modifyAttendance, // mobile/time/modify/attendance
        body: {
          'action_flag': actionFlag,
          'client_id': clientId,
          'company_id': companyId,
          'employee_id': employeeId,
          'modify_in_time': modifyInTime,
          'modify_out_time': modifyOutTime,
          'ot_key': otKey,
          'modify_emp_time_id': modifyEmpTimeId,
          'emp_breaks': empBreaks,
          'employee_remark': employeeRemark,
          'login_user_id': loginUserId,
        },
      );
      if (response.statusCode == 200) return response;
      else if (response.statusCode == 401) throw CustomException('Session Expired. Login/Authenticate Again!');
      else {
        final responseData = jsonDecode(response.body);
        throw CustomException(responseData['message'] ?? 'Failed to modify attendance');
      }
    } catch (e, s) {
      debugPrint('modifyAttendance Error: $e $s');
      rethrow;
    }
  }

  /// Get Work Status Popup Data (Yesterday / Week / Month)
  Future getWorkStatusPopup({
    required String clientId,
    required String companyId,
    required String employeeId,
    required String calendarFilter, // "yesterday", "week", "month"
  }) async {
    try {
      final response = await post(
        ApiConstants.timeWorkStatusPopup,
        body: {
          "client_id": clientId,
          "company_id": companyId,
          "employee_id": employeeId,
          "calendar_filter": calendarFilter,
        },
      );
      if (response.statusCode == 200) return response;
      if (response.statusCode == 401) {
        throw CustomException('Session Expired Login/Authenticate Again!');
      }
      throw CustomException('Error fetching work status popup');
    } catch (e, s) {
      debugPrint("getWorkStatusPopup Error: $e $s");
      rethrow;
    }
  }

  /// Get Manager Time Stats (Dashboard stats for manager time page)
  Future<http.Response> getManagerTimeStats({
    required String clientId,
    required String companyId,
    required String employeeId,
    required String fromDate, // Format: "yyyy-MM-dd"
  }) async {
    try {
      final response = await post(
        ApiConstants.timeManagerStats, // "/mobile/time-manager/stats"
        body: {
          "client_id": clientId,
          "company_id": companyId,
          "employee_id": employeeId,
          "from_date": fromDate,
          "to_date": fromDate,
        },
      );

      if (response.statusCode == 200) {
        return response;
      } else if (response.statusCode == 401) {
        throw CustomException('Session Expired Login/Authenticate Again!');
      } else {
        throw CustomException('Failed to fetch manager time stats');
      }
    } catch (e, s) {
      debugPrint("getManagerTimeStats Error: $e $s");
      rethrow;
    }
  }

  /// Get Manager Regularize List (Action Needed list)
  Future<http.Response> getManagerRegularizeList({
    required String clientId,
    required String companyId,
    required String employeeId,
  }) async {
    try {
      final response = await post(
        ApiConstants.timeManagerRegularizeList, // "/mobile/time-manager/regularize-list"
        body: {
          "client_id": clientId,
          "company_id": companyId,
          "employee_id": employeeId,
        },
      );

      if (response.statusCode == 200) {
        return response;
      } else if (response.statusCode == 401) {
        throw CustomException('Session Expired Login/Authenticate Again!');
      } else {
        throw CustomException('Failed to fetch regularize list');
      }
    } catch (e, s) {
      debugPrint("getManagerRegularizeList Error: $e $s");
      rethrow;
    }
  }

  /// Post Manager Action (Approve/Reject)
  Future<http.Response> postManagerAction({
    required String clientId,
    required String companyId,
    required String employeeId,
    required String timeStatus, // "approved" or "rejected"
    required String empTimeId,
    required String requestEmployeeId,
    String managerRemarks = "",
  }) async {
    try {
      final response = await post(
        ApiConstants.timeManagerAction, // "/mobile/time-manager/action"
        body: {
          "client_id": clientId,
          "company_id": companyId,
          "employee_id": int.tryParse(employeeId) ?? employeeId,
          "time_status": timeStatus,
          "emp_time_id": int.tryParse(empTimeId) ?? empTimeId,
          "request_employee_id": int.tryParse(requestEmployeeId) ?? requestEmployeeId,
          "manager_remarks": managerRemarks,
        },
      );

      if (response.statusCode == 200) {
        return response;
      } else if (response.statusCode == 401) {
        throw CustomException('Session Expired Login/Authenticate Again!');
      } else {
        throw CustomException('Failed to update status');
      }
    } catch (e, s) {
      debugPrint("postManagerAction Error: $e $s");
      rethrow;
    }
  }

  /// Get Employee Dropdown for Individual Employee Time Page
  Future<http.Response> getEmployeeDropdown({
    required String clientId,
    required String companyId,
    required String employeeId,
    required String fromDate,
    required String toDate,
  }) async {
    try {
      final response = await post(
        ApiConstants.timeManagerEmployeeDropdown, // "/mobile/time-manager/employee/dropdown"
        body: {
          "client_id": clientId,
          "company_id": companyId,
          "employee_id": employeeId,
          "from_date": fromDate,
          "to_date": toDate,
        },
      );

      if (response.statusCode == 200) {
        return response;
      } else if (response.statusCode == 401) {
        throw CustomException('Session Expired Login/Authenticate Again!');
      } else {
        throw CustomException('Failed to fetch employee dropdown');
      }
    } catch (e, s) {
      debugPrint("getEmployeeDropdown Error: $e $s");
      rethrow;
    }
  }

  /// Get Employee Details (time details for a specific employee)
  Future<http.Response> getEmployeeDetails({
    required String clientId,
    required String companyId,
    required String employeeId,
    required String requestEmployeeId,
    required String fromDate,
    required String toDate,
  }) async {
    try {
      final response = await post(
        ApiConstants.timeManagerEmployeeDetails, // "/mobile/time-manager/employee-details"
        body: {
          "client_id": clientId,
          "company_id": companyId,
          "employee_id": employeeId,
          "request_employee_id": requestEmployeeId,
          "from_date": fromDate,
          "to_date": toDate,
        },
      );

      if (response.statusCode == 200) {
        return response;
      } else if (response.statusCode == 401) {
        throw CustomException('Session Expired Login/Authenticate Again!');
      } else {
        throw CustomException('Failed to fetch employee details');
      }
    } catch (e, s) {
      debugPrint("getEmployeeDetails Error: $e $s");
      rethrow;
    }
  }

  /// Get Route List (geo details for employee time)
  Future<http.Response> getRouteList({
    required String clientId,
    required String companyId,
    required String requestEmployeeId,
    required String fromDate,
    required String toDate,
  }) async {
    try {
      final response = await post(
        ApiConstants.timeManagerRouteList, // "/mobile/time-manager/route/list"
        body: {
          "client_id": clientId,
          "company_id": companyId,
          "request_employee_id": requestEmployeeId,
          "from_date": fromDate,
          "to_date": toDate,
        },
      );

      if (response.statusCode == 200) {
        return response;
      } else if (response.statusCode == 401) {
        throw CustomException('Session Expired Login/Authenticate Again!');
      } else {
        throw CustomException('Failed to fetch route list');
      }
    } catch (e, s) {
      debugPrint("getRouteList Error: $e $s");
      rethrow;
    }
  }

  /// Get Stats Popup (time details for a specific stat)
  Future<http.Response> getStatsPopup({
    required String clientId,
    required String companyId,
    required String employeeId,
    required String fromDate,
    required String toDate,
    required String statusKey,
  }) async {
    try {
      final response = await post(
        ApiConstants.timeManagerStatsPopup,
        body: {
          "client_id": clientId,
          "company_id": companyId,
          "employee_id": employeeId,
          "from_date": fromDate,
          "to_date": toDate,
          "status_key": statusKey,
        },
      );

      if (response.statusCode == 200) {
        return response;
      } else if (response.statusCode == 401) {
        throw CustomException('Session Expired Login/Authenticate Again!');
      } else {
        throw CustomException('Failed to fetch stats popup data');
      }
    } catch (e, s) {
      debugPrint("getStatsPopup Error: $e $s");
      rethrow;
    }
  }

  /// Get Shift Filter Dropdown
  Future<http.Response> getShiftFilterDropdown({
    required String clientId,
    required String companyId,
    required String employeeId,
    required String fromDate,
    required String toDate,
  }) async {
    try {
      final response = await post(
        ApiConstants.timeManagerDropdown, // "/mobile/time-manager/dropdown"
        body: {
          "client_id": clientId,
          "company_id": companyId,
          "employee_id": employeeId,
          "from_date": fromDate,
          "to_date": toDate,
        },
      );

      if (response.statusCode == 200) {
        return response;
      } else if (response.statusCode == 401) {
        throw CustomException('Session Expired Login/Authenticate Again!');
      } else {
        throw CustomException('Failed to fetch dropdown data');
      }
    } catch (e, s) {
      debugPrint("getShiftFilterDropdown Error: $e $s");
      rethrow;
    }
  }

  /// Get Shift Details
  Future<http.Response> getShiftDetails({
    required String clientId,
    required String companyId,
    required String employeeId,
    required String shiftId,
    required String fromDate,
    required String toDate,
  }) async {
    try {
      final response = await post(
        ApiConstants.timeManagerShift, // "/mobile/time-manager/shift"
        body: {
          "client_id": clientId,
          "company_id": companyId,
          "employee_id": employeeId,
          "shift_id": shiftId,
          "from_date": fromDate,
          "to_date": toDate,
        },
      );

      if (response.statusCode == 200) {
        return response;
      } else if (response.statusCode == 401) {
        throw CustomException('Session Expired Login/Authenticate Again!');
      } else {
        throw CustomException('Failed to fetch shift details');
      }
    } catch (e, s) {
      debugPrint("getShiftDetails Error: $e $s");
      rethrow;
    }
  }

  // ==================== ROUTE CAPTURE API ====================

  /// Add Route - Upload route image with location data
  Future<http.Response> addRoute({
    required String clientId,
    required String companyId,
    required String employeeId,
    required String empTimeId,
    String? latitude,
    String? longitude,
    File? image,
  }) async {
    try {
      Map<String, dynamic> body = {
        "client_id": clientId,
        "company_id": companyId,
        "employee_id": employeeId,
        "emp_time_id": empTimeId,
        "input_source_key": "mobile",
      };

      if (latitude != null) body["latitude"] = latitude;
      if (longitude != null) body["longitude"] = longitude;

      Map<String, File> images = {};
      if (image != null) {
        images['image'] = image;
      }

      final response = await uploadImageFormData(
        images,
        body,
        ApiConstants.routeAdd,
        type: "POST",
      );

      if (response.statusCode == 200) {
        return response;
      } else if (response.statusCode == 401) {
        throw CustomException('Session Expired Login/Authenticate Again!');
      } else {
        final responseData = jsonDecode(response.body);
        String errorMsg = responseData['message'] ?? 'Failed to add route';
        throw CustomException(errorMsg);
      }
    } catch (e, s) {
      debugPrint("addRoute Error: $e $s");
      rethrow;
    }
  }

  // ==================== EXISTING LEAVE/DELEGATE APIS ====================

  Future<http.Response> createDelegate(DelegateData delegateData) async {
    http.Response response;
    try {
      response = await post(
        ApiConstants.createDelegate,
        body: {
          "client_id": delegateData.clientId,
          "company_id": delegateData.companyId,
          "employee_id": delegateData.employeeId,
          "delegate_employee_id": delegateData.delicateEmployeeId,
          "notification_employees": delegateData.employeeNotification,
          "from_date": delegateData.fromDate,
          "to_date": delegateData.toDate,
        },
      );

      if (response.statusCode == 200) {
        return response;
      } else if (response.statusCode == 401) {
        throw CustomException('Session Expired Login/Authenticate Again!');
      } else {
        final responseData = jsonDecode(response.body);
        String cleanedError =
        responseData['data'][0]['error_msg'].split("]").last.trim();
        throw CustomException(cleanedError);
      }
    } catch (e, s) {
      debugPrint("we got  $e $s");
      rethrow;
    }
  }

  Future<http.Response> updateDelegate(DelegateData delegateData) async {
    http.Response response;
    try {
      response = await post(
        ApiConstants.updateDelegate,
        body: {
          "delegate_id": delegateData.delicateId,
          "client_id": delegateData.clientId,
          "company_id": delegateData.companyId,
          "employee_id": delegateData.employeeId,
          "delegate_employee_id": delegateData.delicateEmployeeId,
          "notification_employees": delegateData.employeeNotification,
          "from_date": delegateData.fromDate,
          "to_date": delegateData.toDate,
        },
      );

      if (response.statusCode == 200) {
        return response;
      } else if (response.statusCode == 401) {
        throw CustomException('Session Expired Login/Authenticate Again!');
      } else {
        final responseData = jsonDecode(response.body);
        String cleanedError =
        responseData['data'][0]['error_msg'].split("]").last.trim();
        throw CustomException(cleanedError);
      }
    } catch (e, s) {
      debugPrint("we got  $e $s");
      rethrow;
    }
  }

  Future<http.Response> getLeave(ProfilePostData leaveData) async {
    try {
      final response = await post(
        ApiConstants.getLeave,
        body: {
          "client_id": leaveData.clientId,
          "company_id": leaveData.companyId,
          "employee_id": leaveData.employeeId
        },
      );
      if (response.statusCode == 200) {
        return response;
      } else if (response.statusCode == 401) {
        throw CustomException('Session Expired Login/Authenticate Again!');
      } else {
        throw CustomException('Error Occurred');
      }
    } catch (e, s) {
      debugPrint("we got  $e $s");
      rethrow;
    }
  }

  Future<http.Response> getLeaveData(ProfilePostData leaveData) async {
    try {
      final response = await post(
        ApiConstants.leaveManager,
        body: {
          "client_id": leaveData.clientId,
          "company_id": leaveData.companyId,
          "employee_id": leaveData.employeeId
        },
      );
      if (response.statusCode == 200) {
        return response;
      } else if (response.statusCode == 401) {
        throw CustomException('Session Expired Login/Authenticate Again!');
      } else {
        throw CustomException('Error Occurred');
      }
    } catch (e, s) {
      debugPrint("we got  $e $s");
      rethrow;
    }
  }

  Future<http.Response> getCalendarLeaveData(
      ProfilePostData leaveData, DateTime fromDate) async {
    try {
      final response = await post(
        ApiConstants.leaveCalendarData,
        body: {
          "client_id": leaveData.clientId,
          "company_id": leaveData.companyId,
          "employee_id": leaveData.employeeId,
          "from_date": dateTimeToString(fromDate, format: "yyyy-MM-dd"),
        },
      );
      if (response.statusCode == 200) {
        return response;
      } else if (response.statusCode == 401) {
        throw CustomException('Session Expired Login/Authenticate Again!');
      } else {
        throw CustomException('Error Occurred');
      }
    } catch (e, s) {
      debugPrint("we got  $e $s");
      rethrow;
    }
  }

  Future<http.Response> updateLeaveStatus(
      LeaveActionPostData leaveActionData) async {
    try {
      final response = await post(
        ApiConstants.leaveStatusUpdate,
        body: leaveActionData.toJson(),
      );
      if (response.statusCode == 200) {
        return response;
      } else if (response.statusCode == 401) {
        throw CustomException('Session Expired Login/Authenticate Again!');
      } else {
        throw CustomException('Error Occurred');
      }
    } catch (e, s) {
      debugPrint("we got  $e $s");
      rethrow;
    }
  }

  Future<http.Response> checkDelegate(ProfilePostData profileData) async {
    try {
      final response = await post(
        ApiConstants.checkDelegate,
        body: {
          "client_id": profileData.clientId,
          "company_id": profileData.companyId,
          "employee_id": profileData.employeeId
        },
      );
      if (response.statusCode == 200) {
        return response;
      } else if (response.statusCode == 401) {
        throw CustomException('Session Expired Login/Authenticate Again!');
      } else {
        throw CustomException('Error Occurred');
      }
    } catch (e, s) {
      debugPrint("we got  $e $s");
      rethrow;
    }
  }

  Future<http.Response> getDelegateData(ProfilePostData profileData) async {
    try {
      final response = await post(
        ApiConstants.editDelegate,
        body: {
          "client_id": profileData.clientId,
          "company_id": profileData.companyId,
          "employee_id": profileData.employeeId
        },
      );
      if (response.statusCode == 200) {
        return response;
      } else if (response.statusCode == 401) {
        throw CustomException('Session Expired Login/Authenticate Again!');
      } else {
        throw CustomException('Error Occurred');
      }
    } catch (e, s) {
      debugPrint("we got  $e $s");
      rethrow;
    }
  }

  Future<http.Response> removeDelegate(
      ProfilePostData profileData, String delegateID) async {
    try {
      final response = await post(
        ApiConstants.removeDelegate,
        body: {
          "client_id": profileData.clientId,
          "company_id": profileData.companyId,
          "employee_id": profileData.employeeId,
          "delegate_id": delegateID
        },
      );
      if (response.statusCode == 200) {
        return response;
      } else if (response.statusCode == 401) {
        throw CustomException('Session Expired Login/Authenticate Again!');
      } else {
        throw CustomException('Error Occurred');
      }
    } catch (e, s) {
      debugPrint("we got  $e $s");
      rethrow;
    }
  }

  Future<http.Response> getManagersDropdown(ProfilePostData profileData) async {
    try {
      final response = await post(
        ApiConstants.managerDropdown,
        body: {
          "client_id": profileData.clientId,
          "company_id": profileData.companyId,
          "employee_id": profileData.employeeId
        },
      );
      if (response.statusCode == 200) {
        return response;
      } else if (response.statusCode == 401) {
        throw CustomException('Session Expired Login/Authenticate Again!');
      } else {
        throw CustomException('Error Occurred');
      }
    } catch (e, s) {
      debugPrint("we got  $e $s");
      rethrow;
    }
  }
}
