import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:payroll/service/break_reminder_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:payroll/features/leave_page/controller/leave_page_controller.dart';
import 'package:payroll/features/leave_page/data/repository/leave_provider.dart';
import 'package:payroll/features/login/domain/model/login_model.dart';
import 'package:payroll/features/manager/model/check_delagate.dart';
import 'package:payroll/features/manager/model/leave_action.dart';
import 'package:payroll/features/manager/model/manager_delegate.dart';
import 'package:payroll/features/manager/model/managers_dropdown.dart';
import 'package:payroll/features/time/controller/manager_time_controller.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sizer/sizer.dart';

import '../../../routes/app_pages.dart';
import '../../../routes/app_route.dart';
import '../../../theme/theme_controller.dart';
import '../../../util/custom_widgets.dart';
import '../../../util/getUserdata.dart';
import '../../leave_page/model/leave_model.dart';
import '../../manager/model/employee_leaves_list.dart';
import '../../profile_page/data/model/profile_model.dart';
import '../data/repository/time_provider.dart';

import '../data/time_model.dart';
import '../views/leaves_item.dart';
import '../views/widgets/time_details_popup.dart';
import '../views/widgets/attendance_details_popup.dart';

class TimePageController extends GetxController {
  var loading = Loading.initial.obs;
  late Future<void> _initDone;
  RxList sortedEarnings = [].obs;
  RxBool isHavingDelegate = false.obs;
  String currentDelegateId = '';
  RxList<LeavesDetail> leaveItems = [LeavesDetail()].obs;
  RxList<Calendar> teamLeaves = [Calendar()].obs;
  RxnInt expandedIndex = RxnInt();
  RxString offset = '0'.obs;
  final appStateController = Get.put(AppStates());
  UserData userData = UserData();
  RxBool isManager = false.obs;
  Rxn<DateTime?> fromDate = Rxn<DateTime?>();
  Rxn<DateTime?> toDate = Rxn<DateTime?>();
  Rxn<TimeOfDay?> fromDateStart = Rxn<TimeOfDay?>();
  Rxn<TimeOfDay?> fromDateEnd = Rxn<TimeOfDay?>();
  Rxn<TimeOfDay?> toDateStart = Rxn<TimeOfDay?>();
  Rxn<TimeOfDay?> toDateEnd = Rxn<TimeOfDay?>();
  final ScrollController scrollController = ScrollController();
  final FocusNode focusNode = FocusNode();
  final LeaveProvider leaveProvider = Get.put(LeaveProvider());
  final TimeProvider managerProvider = Get.put(TimeProvider());
  final TextEditingController reasonController = TextEditingController();
  final TimeProvider timeProvider = TimeProvider();
  RxString selectedLeaveTypeID = "12".obs;
  RxString selectedDayTypeIDFromDate = "1".obs;
  RxString selectedDayTypeIDToDate = "1".obs;
  RxString selectedLeaveRemaining = "0".obs;
  RxString totalLeaveDays = "0".obs;
  late ProfilePostData profileData;
  List<Map<String, String?>>? employeeLeaveHistory;
  List<Map<String, String?>>? selectedDayLeaves;
  var isClockedIn = false.obs;
  var isLoadingLocation = false.obs;
  var currentPosition = Rxn<Position>();
  var currentAddress = ''.obs;
  var clockInTime = ''.obs;
  var clockOutTime = ''.obs;
  var breakStartTime = ''.obs;
  var breakEndTime = ''.obs;
  var isOnBreak = false.obs;
  var totalWorkedTime = ''.obs;
  var totalBreakTime = ''.obs;
  var shiftStartTime = '09:00 AM'.obs;
  var shiftEndTime = '06:30 PM'.obs;
  var shiftName = 'Regular shift'.obs;
  RxList<Map<String, String>> breakHistory = <Map<String, String>>[].obs;
  var todayWorkedHours = ''.obs;
  var todayBreakHours = ''.obs;
  GoogleMapController? mapController;
  Set<Marker> markers = <Marker>{}.obs;
  var isConfirmingClockIn = false.obs;
  var isPhotoUpload = true.obs;
  var isClockOutPhotoUpload = true.obs;
  var capturedImage = Rxn<File>();
  var capturedImageClockOut = Rxn<File>();
  var isUploadingPhoto = false.obs;
  var isConfirmingClockOut = false.obs;
  var currentMonth = DateTime.now().obs;
  var shortHoursDates = <DateTime>[].obs;
  var overtimeDates = <DateTime>[].obs;
  var isBiometricEnabled = false.obs;
  var regularizeBreakData = <PopupEmployeeBreakTime>[].obs;
  // API Response Models - Updated to use proper model classes
  var employeeTimeList = <EmployeeTimeModel>[].obs;
  var employeeBreakList = <EmployeeBreakModel>[].obs;
  var previousShiftTimeList = <ShiftTimeModel>[].obs;
  var currentShiftList = <CurrentShiftModel>[].obs;
  var timeCalendarList = <TimeCalendarModel>[].obs;
  var geoTimeList = <GeoTimeModel>[].obs;
  var workingStatusList = <WorkingStatusModel>[].obs;

  // Stats Variables
  var weekWorkedHours = '0h 00m'.obs;
  var weekShortHours = '0h 00m'.obs;
  var weekOverTime = '0h 00m'.obs;

  var monthWorkedHours = '0h 00m'.obs;
  var monthShortHours = '0h 00m'.obs;
  var monthOverTime = '0h 00m'.obs;

  var yesterdayWorkedHours = '0h 00m'.obs;
  var yesterdayShortHours = '0h 00m'.obs;
  var yesterdayOverTime = '0h 00m'.obs;

  var todayOverTime = '0h 00m'.obs;
  var todayShortHours = '0h 00m'.obs; // Optional if we want today's short hours
  
  // Current session IDs for API calls
  var currentEmpTimeId = ''.obs;
  var currentBreakId = ''.obs;
  
  // Timer for dynamic working time calculation
  Timer? _workingTimeTimer;
  Rxn<DateTime> clockInDateTime = Rxn<DateTime>();
  var totalBreakDuration = Duration.zero.obs;
  var storedTodayWorkedHours = ''.obs; // Store API returned hours for today

  // Break reminder service for local notifications
  final BreakReminderService _breakReminderService = BreakReminderService();
  var allottedBreakMinutes = 15.obs; // Default 15 minutes, updated from API

  // Route capture state
  var isCapturingRoute = false.obs;
  var capturedRouteImage = Rxn<File>();
  var isAddingRoute = false.obs;

  // Regularize Page Variables
  final regularizeDateController = TextEditingController();
  final regularizeClockInController = TextEditingController();
  final regularizeClockOutController = TextEditingController();
  final regularizeReasonController = TextEditingController();

  // Dynamic Break Controllers
  RxList<TextEditingController> regularizeBreakStartControllers = <TextEditingController>[].obs;
  RxList<TextEditingController> regularizeBreakEndControllers = <TextEditingController>[].obs;

  var regularizeSelectedDate = Rxn<DateTime>();
  var regularizeClockInTime = Rxn<TimeOfDay>();
  var regularizeClockOutTime = Rxn<TimeOfDay>();
  
  RxList<Rxn<TimeOfDay>> regularizeBreakStartTimes = <Rxn<TimeOfDay>>[].obs;
  RxList<Rxn<TimeOfDay>> regularizeBreakEndTimes = <Rxn<TimeOfDay>>[].obs;

  // Overtime Page Variables
  final overtimeDateController = TextEditingController();
  final overtimeClockInController = TextEditingController();
  final overtimeClockOutController = TextEditingController();
  final overtimeOvertimeController = TextEditingController();
  final overtimeBaseRateController = TextEditingController();
  final overtimeReasonController = TextEditingController();

  var overtimeSelectedDate = Rxn<DateTime>();
  var overtimeClockInTime = Rxn<TimeOfDay>();
  var overtimeClockOutTime = Rxn<TimeOfDay>();

  var selectedDate = DateTime.now().obs;
  var focusedDay = DateTime.now().obs;

  // Rest of your existing methods remain the same...
  // Just keeping the key methods for brevity

  // Parse API response with corrected model names
  void parseApiResponse(Map<String, dynamic> data) {
    // Parse employee_time
    if (data['employee_time'] != null) {
      employeeTimeList.value = (data['employee_time'] as List)
          .map((item) => EmployeeTimeModel.fromJson(item))
          .toList();

      if (employeeTimeList.isNotEmpty) {
        final firstEntry = employeeTimeList.first;
        
        // Handle different active statuses
        // clock_in = just clocked in, break_in = on break, break_out = finished break but still clocked in
        if (firstEntry.activeStatus == 'clock_in' ||
            firstEntry.activeStatus == 'break_in' || 
            firstEntry.activeStatus == 'break_out') {
          isClockedIn.value = true;
          
          // Parse and store clock-in DateTime for timer calculation
          if (firstEntry.inTime != null && firstEntry.inTime!.isNotEmpty) {
            try {
              String timeStr = firstEntry.inTime!.trim();
              int hour = 0;
              int minute = 0;
              
              // Check if time contains AM/PM
              bool isPM = timeStr.toUpperCase().contains('PM');
              bool isAM = timeStr.toUpperCase().contains('AM');
              
              // Remove AM/PM for parsing
              timeStr = timeStr.replaceAll(RegExp(r'\s*(AM|PM|am|pm)\s*', caseSensitive: false), '');
              
              final timeParts = timeStr.split(':');
              if (timeParts.length >= 2) {
                hour = int.parse(timeParts[0]);
                minute = int.parse(timeParts[1].replaceAll(RegExp(r'[^0-9]'), ''));
                
                // If time has AM/PM suffix, convert to 24-hour format
                if (isPM && hour != 12) {
                  hour += 12;
                } else if (isAM && hour == 12) {
                  hour = 0;
                } else if (!isPM && !isAM) {
                  // No AM/PM suffix - API returns 12-hour format without suffix
                  // If hour is small (1-12) and current time is past noon, assume PM
                  final now = DateTime.now();
                  if (hour <= 12 && now.hour >= 12 && hour <= now.hour - 12 + 1) {
                    hour += 12;
                  }
                }
                
                final now = DateTime.now();
                
                // Store the exact clock-in DateTime for timer calculation
                clockInDateTime.value = DateTime(now.year, now.month, now.day, hour, minute);
                
                // Format for display (e.g., "Jan 31 at 3:18 PM")
                clockInTime.value = DateFormat('MMM d \'at\' h:mm a').format(clockInDateTime.value!);
              } else {
                clockInTime.value = firstEntry.inTime ?? '';
              }
            } catch (e) {
              debugPrint('Error parsing in_time: $e');
              clockInTime.value = firstEntry.inTime ?? '';
            }
          }
          
          // Set break status
          if (firstEntry.activeStatus == 'break_in') {
            isOnBreak.value = true;
          } else {
            isOnBreak.value = false;
          }
        } else {
          // Not clocked in
          isClockedIn.value = false;
          clockInDateTime.value = null;
          stopWorkingTimeTimer();
        }
        
        // Store the current emp_time_id for break/clock-out operations
        currentEmpTimeId.value = firstEntry.empTimeId ?? '';

        // Store today's working hours if available (for display when clocked out)
        if (firstEntry.workingHours != null) {
          storedTodayWorkedHours.value = _formatHoursMinutes('${firstEntry.workingHours}');
          // If not clocked in, show this immediately
          if (!isClockedIn.value) {
             todayWorkedHours.value = storedTodayWorkedHours.value;
          }
        }
      }
    }

    // Parse employee_break
    if (data['employee_break'] != null) {
      employeeBreakList.value = (data['employee_break'] as List)
          .map((item) => EmployeeBreakModel.fromJson(item))
          .toList();
      print('empelle ${employeeBreakList.length}');
      // Update break info from response
      if (employeeBreakList.isNotEmpty) {
        final currentBreak = employeeBreakList.first;
        print('currentBreak ${currentBreak.startBreak}');
        if (currentBreak.startBreak != null && currentBreak.startBreak!.isNotEmpty &&
            (currentBreak.endBreak == null || currentBreak.endBreak!.isEmpty)) {
          isOnBreak.value = true;
          breakStartTime.value = currentBreak.startBreak!;
          currentBreakId.value = currentBreak.empBreakId ?? '';
        }
        // Store break ID for ending break
        currentBreakId.value = currentBreak.empBreakId ?? '';
      }
    }

    // Parse previous_shift_time
    if (data['previous_shift_time'] != null) {
      previousShiftTimeList.value = (data['previous_shift_time'] as List)
          .map((item) => ShiftTimeModel.fromJson(item))
          .toList();
      
      // Update shift info if available
      if (previousShiftTimeList.isNotEmpty) {
        final shift = previousShiftTimeList.first;
        if (shift.startTime != null) shiftStartTime.value = shift.startTime!;
        if (shift.endTime != null) shiftEndTime.value = shift.endTime!;

        // Populate yesterdayData for UI
        yesterdayData.clear();
        yesterdayData.add({
          'date': shift.date ?? '',
          'firstIn': shift.inTime ?? 'N/A',
          'lastOut': shift.outTime ?? 'N/A',
          'breakHours': '00:00 hrs', // Not currently in ShiftTimeModel, update if API provides
          'shiftDetails': '${shift.startTime ?? ""} to ${shift.endTime ?? ""}',
          'workedHours': shift.workingHours ?? '00:00',
          'status': shift.workingStatusName ?? 'Present',
        });
      }
    }

    // Parse current_shift
    if (data['current_shift'] != null) {
      currentShiftList.value = (data['current_shift'] as List)
          .map((item) => CurrentShiftModel.fromJson(item))
          .toList();

      if (currentShiftList.isNotEmpty) {
        final shift = currentShiftList.first;
        shiftStartTime.value = shift.startTime ?? '';
        shiftEndTime.value = shift.endTime ?? '';
        shiftName.value = shift.shiftName ?? 'Regular Shift';
        
        // Set extended break threshold from API's break_duration
        if (shift.breakDuration != null && shift.breakDuration!.isNotEmpty) {
          final breakMins = int.tryParse(shift.breakDuration!) ?? 15;
          allottedBreakMinutes.value = breakMins;
          _breakReminderService.setExtendedBreakThreshold(breakMins);
        }
      }
    }

    // Parse time_calendar
    if (data['time_calendar'] != null) {
      timeCalendarList.value = (data['time_calendar'] as List)
          .map((item) => TimeCalendarModel.fromJson(item))
          .toList();
    }

    // Parse geo_time
    if (data['geo_time'] != null) {
      geoTimeList.value = (data['geo_time'] as List)
          .map((item) => GeoTimeModel.fromJson(item))
          .toList();
      
      // Update location info from geo_time if available
      if (geoTimeList.isNotEmpty) {
        final geoInfo = geoTimeList.first;
        if (geoInfo.latitude != null && geoInfo.longitude != null) {
          // Store geo coordinates for map display
        }
      }
    }

    // Parse working_status
    if (data['working_status'] != null) {
      workingStatusList.value = (data['working_status'] as List)
          .map((item) => WorkingStatusModel.fromJson(item))
          .toList();

      if (workingStatusList.isNotEmpty) {
        final status = workingStatusList.first;

        monthWorkedHours.value = _formatHoursMinutes(status.workedMonthHours ?? '');
        monthShortHours.value = _formatHoursMinutes(status.shortMonthHours ?? '');
        monthOverTime.value = _formatHoursMinutes(status.overtimeMonthHours ?? '');

        weekWorkedHours.value = _formatHoursMinutes(status.workedWeekHours ?? '');
        weekShortHours.value = _formatHoursMinutes(status.shortWeekHours ?? '');
        weekOverTime.value = _formatHoursMinutes(status.overtimeWeekHours ?? '');

        yesterdayWorkedHours.value = _formatHoursMinutes(status.workedYesterdayHours ?? '');
        yesterdayShortHours.value = _formatHoursMinutes(status.shortYesterdayHours ?? '');
        yesterdayOverTime.value = _formatHoursMinutes(status.overtimeYesterdayHours ?? '');
      }
    }
    
    // Calculate total break duration for accurate working time
    calculateTotalBreakDuration();
    
    // Start the timer if clocked in
    if (isClockedIn.value && clockInDateTime.value != null) {
      startWorkingTimeTimer();
    }
  }

  // Start the working time timer for real-time updates
  void startWorkingTimeTimer() {
    stopWorkingTimeTimer(); // Cancel any existing timer
    _workingTimeTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      updateWorkingTime();
    });
    updateWorkingTime(); // Initial update
  }

  // Stop the working time timer
  void stopWorkingTimeTimer() {
    _workingTimeTimer?.cancel();
    _workingTimeTimer = null;
  }

  // Calculate and update the working time dynamically
  void updateWorkingTime() {
    if (!isClockedIn.value) {
      if (storedTodayWorkedHours.value.isNotEmpty) {
         todayWorkedHours.value = storedTodayWorkedHours.value;
      } else {
         todayWorkedHours.value = '0h 00m';
      }
      return;
    }

    if (clockInDateTime.value == null) {
       todayWorkedHours.value = '0h 00m';
       return;
    }

    final now = DateTime.now();
    Duration elapsed = now.difference(clockInDateTime.value!);
    
    // Subtract total break duration
    Duration actualWorked = elapsed - totalBreakDuration.value;
    
    // If on break, also subtract current break time
    if (isOnBreak.value && breakStartTime.value.isNotEmpty) {
      try {
        final breakParts = breakStartTime.value.replaceAll(' AM', '').replaceAll(' PM', '').split(':');
        if (breakParts.length >= 2) {
          int breakHour = int.parse(breakParts[0]);
          int breakMinute = int.parse(breakParts[1]);
          
          // Handle 12-hour format
          if (breakStartTime.value.contains('PM') && breakHour != 12) {
            breakHour += 12;
          } else if (breakStartTime.value.contains('AM') && breakHour == 12) {
            breakHour = 0;
          }
          
          final breakStart = DateTime(now.year, now.month, now.day, breakHour, breakMinute);
          final currentBreakDuration = now.difference(breakStart);
          actualWorked = actualWorked - currentBreakDuration;
        }
      } catch (e) {
        debugPrint('Error calculating break time: $e');
      }
    }
    
    // Ensure we don't show negative time
    if (actualWorked.isNegative) {
      actualWorked = Duration.zero;
    }

    final hours = actualWorked.inHours;
    final minutes = actualWorked.inMinutes.remainder(60);
    todayWorkedHours.value = '${hours}h ${minutes.toString().padLeft(2, '0')}m';
  }

  // Calculate total break duration from break list
  void calculateTotalBreakDuration() {
    Duration total = Duration.zero;
    debugPrint('Calculating breaks from ${employeeBreakList.length} break entries:');
    
    for (var breakItem in employeeBreakList) {
      if (breakItem.totalBreak != null && breakItem.totalBreak!.isNotEmpty) {
        // Parse total_break format like "00:02:00" (HH:MM:SS)
        try {
          final parts = breakItem.totalBreak!.split(':');
          if (parts.length >= 3) {
            final breakDuration = Duration(
              hours: int.parse(parts[0]),
              minutes: int.parse(parts[1]),
              seconds: int.parse(parts[2]),
            );
            total += breakDuration;
            debugPrint('  Break ${breakItem.empBreakId}: ${breakItem.totalBreak} added');
          }
        } catch (e) {
          debugPrint('Error parsing break duration: $e');
        }
      }
    }
    
    totalBreakDuration.value = total;
    
    // Update display value for break hours
    final hours = total.inHours;
    final minutes = total.inMinutes.remainder(60);
    todayBreakHours.value = '${hours}h ${minutes.toString().padLeft(2, '0')}m';
    
    debugPrint('Total break duration: ${todayBreakHours.value}');
  }

  // Get calendar events for TableCalendar
  List<TimeCalendarModel> getEventsForDay(DateTime day) {
    return timeCalendarList.where((event) {
      final eventDate = DateTime.parse(event.start ?? '');
      return isSameDay(eventDate, day);
    }).toList();
  }

  List<Holiday> getCalendarDays() {
    return timeCalendarList.map((model) {
      // ✅ Use statusKey as fallback when status display name is empty
      final displayName = (model.status != null && model.status!.isNotEmpty)
          ? model.status!
          : (model.statusKey ?? '');

      return Holiday(
        holidayName: displayName,
        holidayDate: model.start != null ? DateTime.tryParse(model.start!) : null,
        status: model.statusKey,
      );
    }).where((h) => h.holidayDate != null).toList();
  }

  // Get TimeCalendarModel for a specific day
  TimeCalendarModel? getTimeCalendarModelForDay(DateTime day) {
    try {
      return timeCalendarList.firstWhere((element) {
        if (element.start == null) return false;
        final eventDate = DateTime.parse(element.start!);
        return isSameDay(eventDate, day);
      });
    } catch (e) {
      return null;
    }
  }

  // Fetch detailed time popup data
  Future<TimePopupModel?> fetchTimePopupDetails(DateTime date) async {
    try {
      loading.value = Loading.loading;
      ProfilePostData employeeData = ProfilePostData(
        employeeId: userData.user?.employeeId,
        companyId: userData.user?.companyId,
        clientId: userData.user?.clientId,
      );
      
      String dateStr = DateFormat('yyyy-MM-dd').format(date);
      
      final response = await timeProvider.getTimePopupDetails(employeeData, dateStr);
      final responseData = jsonDecode(response.body);
      
      loading.value = Loading.loaded;
      
      if (responseData['success'] == true && responseData['data'] != null) {
        return TimePopupModel.fromJson(responseData['data']);
      } else {
        // appSnackBar(
        //   data: responseData['message'] ?? 'Failed to load details',
        //   color: AppColors.appRedColor,
        // );
        return null; // Return null if no data
      }
    } on CustomException catch (err) {
      loading.value = Loading.loaded;
      appSnackBar(data: err.message, color: AppColors.appRedColor);
      return null;
    } catch (error, st) {
      loading.value = Loading.loaded;
      debugPrint("fetchTimePopupDetails Error: $error $st");
      // appSnackBar(
      //   data: 'Failed to fetch details: ${error.toString()}',
      //   color: AppColors.appRedColor,
      // );
      return null;
    }
  }

  // Check if same day
  bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  // Get holiday color based on status
  Color getHolidayColor(String? statusKey) {
    switch (statusKey) {
      case 'week_holiday':
        return Colors.grey;
      case 'full_hours':
        return Colors.green;
      case 'half_day':
        return Colors.orange;
      case 'short_hours':
        return Colors.yellow;
      case 'over_time':
        return Colors.cyan;
      case 'leave':
        return Colors.red;
      default:
        return Colors.blue.shade100;
    }
  }

  void initRegularizeData(DateTime date, {TimePopupModel? popupData}) {
    regularizeSelectedDate.value = date;
    regularizeDateController.text = DateFormat('dd/MM/yyyy').format(date); // ✅ fills date field

    // Pre-fill clock in / out from popup API
    if (popupData?.employeeShiftTime?.isNotEmpty == true) {
      final empTime = popupData!.employeeShiftTime!.first;
      regularizeClockInController.text =
          empTime.modifyInTime ?? empTime.actualStart ?? '09:00:00 AM';
      regularizeClockOutController.text =
          empTime.modifyOutTime ?? empTime.actualEnd ?? '06:00:00 PM';
      regularizeReasonController.text =
          empTime.employeeRemark ?? '';
    } else {
      regularizeClockInController.text = '09:00:00 AM';
      regularizeClockOutController.text = '06:00:00 PM';
    }

    // Pre-fill break data and store raw break objects for submitRegularize
    regularizeBreakData.value = popupData?.employeeBreakTime ?? [];

    // Clear old controllers
    for (var c in regularizeBreakStartControllers) { c.dispose(); }
    for (var c in regularizeBreakEndControllers) { c.dispose(); }
    regularizeBreakStartControllers.clear();
    regularizeBreakEndControllers.clear();
    regularizeBreakStartTimes.clear();
    regularizeBreakEndTimes.clear();

    // Only map Break 2 and Break 3 if they exist in the regularizeBreakData array
    // The user requested to "only break 2 ,3 if it is avialbae onbemplotee break lst"
    // Assuming break 1 is often ignored or the index mapping is what they meant.
    // Let's create controllers for all breaks returned, up to a limit, but the user specifically said:
    // "also only only break 2 ,3 if it is avialbae onbemplotee break lst"
    // I will map all available breaks so they can modify start and end.

    for (int i = 0; i < regularizeBreakData.length; i++) {
        final brk = regularizeBreakData[i];
        
        final startController = TextEditingController(text: brk.modifyStartBreak ?? brk.startBreak ?? '00:00:00');
        final endController = TextEditingController(text: brk.modifyEndBreak ?? brk.endBreak ?? '00:00:00');
        
        regularizeBreakStartControllers.add(startController);
        regularizeBreakEndControllers.add(endController);
        
        regularizeBreakStartTimes.add(Rxn<TimeOfDay>(_parseTimeOfDay(startController.text)));
        regularizeBreakEndTimes.add(Rxn<TimeOfDay>(_parseTimeOfDay(endController.text)));
    }

    // Parse TimeOfDay from text for the time pickers
    regularizeClockInTime.value  = _parseTimeOfDay(regularizeClockInController.text);
    regularizeClockOutTime.value = _parseTimeOfDay(regularizeClockOutController.text);
  }

// Helper to parse "09:00:00 AM" or "09:00 AM" → TimeOfDay
  TimeOfDay? _parseTimeOfDay(String timeStr) {
    try {
      final formats = [
        DateFormat('hh:mm:ss a'),
        DateFormat('hh:mm a'),
        DateFormat('HH:mm:ss'),
        DateFormat('HH:mm'),
      ];
      for (final fmt in formats) {
        try {
          final dt = fmt.parse(timeStr.trim().toUpperCase());
          return TimeOfDay(hour: dt.hour, minute: dt.minute);
        } catch (_) {}
      }
    } catch (_) {}
    return null;
  }

  // Initialize overtime data
  void initOvertimeData(DateTime date) {
    overtimeSelectedDate.value = date;
    overtimeDateController.text = DateFormat('dd/MM/yyyy').format(date);
    overtimeClockInController.text = '08:00:00 AM';
    overtimeClockOutController.text = '08:30:00 PM';
    overtimeOvertimeController.text = '03:00:00';
    overtimeBaseRateController.text = '1.5x';
  }

  // Time Dashboard Data - Now dynamically populated from timeCalendarList
  final RxList<Map<String, String>> yesterdayData = <Map<String, String>>[].obs;

  /// Build today's popup data from existing employee_time and employee_break
  Map<String, dynamic> _buildTodayPopupData() {
    List<Map<String, String>> data = [];
    String workedHours = '0h 00m';
    String breakHours = '0h 00m';
    String shortHours = '0h 00m';
    String overTime = '0h 00m';
    
    // Get today's employee_time entry
    if (employeeTimeList.isNotEmpty) {
      final todayTime = employeeTimeList.first;
      
      // Parse in_time and out_time
      String firstIn = todayTime.inTime ?? '';
      String lastOut = todayTime.outTime ?? '';
      
      // Calculate break hours from employeeBreakList
      int totalBreakMinutes = 0;
      for (var brk in employeeBreakList) {
        if (brk.totalBreak != null) {
          // Parse "00:20:00" format
          final parts = brk.totalBreak!.split(':');
          if (parts.length >= 2) {
            totalBreakMinutes += int.tryParse(parts[0]) ?? 0 * 60;
            totalBreakMinutes += int.tryParse(parts[1]) ?? 0;
          }
        }
      }
      breakHours = '${totalBreakMinutes ~/ 60}h ${(totalBreakMinutes % 60).toString().padLeft(2, '0')}m';
      
      // Get worked hours
      if (todayTime.workingHours != null) {
        workedHours = _formatHoursMinutes(todayTime.workingHours!);
      }
      
      // Build row data
      data.add({
        'date': todayTime.date ?? DateFormat('yyyy-MM-dd').format(DateTime.now()),
        'firstIn': firstIn,
        'lastOut': lastOut,
        'breakHours': breakHours,
        'shiftDetails': '${shiftStartTime.value} to ${shiftEndTime.value}',
      });
      
      // Check status for short hours / overtime
      if (todayTime.workingStatusName?.toLowerCase() == 'overtime') {
        overTime = '1h 00m'; // Estimate
      }
    }
    
    return {
      'data': data,
      'workedHours': workedHours,
      'shortHours': shortHours,
      'overTime': overTime,
    };
  }

  /// Build popup data from popup API response
  Map<String, String> _buildRowFromPopupData(TimePopupModel popupData, String date) {
    String firstIn = '';
    String lastOut = '';
    String breakHours = '0h 00m';
    String shiftDetails = '';
    
    // Get actual times from employee_shift_time
    if (popupData.employeeShiftTime != null && popupData.employeeShiftTime!.isNotEmpty) {
      final empTime = popupData.employeeShiftTime!.first;
      firstIn = empTime.actualStart ?? '';
      lastOut = empTime.actualEnd ?? '';
    }
    
    // Get shift details from shift_time
    if (popupData.shiftTime != null && popupData.shiftTime!.isNotEmpty) {
      final shift = popupData.shiftTime!.first;
      shiftDetails = '${shift.allotedStart ?? ''} to ${shift.allotedEnd ?? ''}';
    }
    
    // Calculate break hours from employee_break_time
    if (popupData.employeeBreakTime != null && popupData.employeeBreakTime!.isNotEmpty) {
      int totalBreakMinutes = 0;
      for (var brk in popupData.employeeBreakTime!) {
        if (brk.totalBreak != null) {
          // Parse "00:20:00" format
          final parts = brk.totalBreak!.split(':');
          if (parts.length >= 2) {
            totalBreakMinutes += (int.tryParse(parts[0]) ?? 0) * 60;
            totalBreakMinutes += int.tryParse(parts[1]) ?? 0;
          }
        }
      }
      breakHours = '${totalBreakMinutes ~/ 60}h ${(totalBreakMinutes % 60).toString().padLeft(2, '0')}m';
    }
    
    return {
      'date': date,
      'firstIn': firstIn,
      'lastOut': lastOut,
      'breakHours': breakHours,
      'shiftDetails': shiftDetails,
    };
  }

  int _parseBreakDuration(String? s) {
    if (s == null || s.isEmpty) return 0;
    // Format: "0h:52m"  or "1h:18m"
    final hMatch = RegExp(r'(\d+)h').firstMatch(s);
    final mMatch = RegExp(r'(\d+)m').firstMatch(s);
    final h = int.tryParse(hMatch?.group(1) ?? '0') ?? 0;
    final m = int.tryParse(mMatch?.group(1) ?? '0') ?? 0;
    return h * 60 + m;
  }

// ── Helper: parse "hh:mm a" (e.g. "06:36 PM") → minutes since midnight ──
  int _timeToMinutes(String? t) {
    if (t == null || t.isEmpty) return 0;
    try {
      final dt = DateFormat('hh:mm a').parse(t.trim().toUpperCase());
      return dt.hour * 60 + dt.minute;
    } catch (_) {
      return 0;
    }
  }

// ── Helper: minutes → "Xh YYm" ──────────────────────────────────────────
  String _minsToHm(int mins) {
    if (mins < 0) mins = 0;
    return '${mins ~/ 60}h ${(mins % 60).toString().padLeft(2, '0')}m';
  }

// ── Fetch work-status popup from new single API ─────────────────────────
  Future<List<WorkStatusItem>?> _fetchWorkStatusPopup(String filter) async {
    try {
      loading.value = Loading.loading;
      final response = await timeProvider.getWorkStatusPopup(
        clientId:      userData.user?.clientId  ?? '',
        companyId:     userData.user?.companyId ?? '',
        employeeId:    userData.user?.employeeId ?? '',
        calendarFilter: filter,
      );
      loading.value = Loading.loaded;
      final body = jsonDecode(response.body);
      if (body['success'] == true && body['data'] != null) {
        final list = body['data']['working_list'] as List;
        return list.map((e) => WorkStatusItem.fromJson(e)).toList();
      }
      return null;
    } catch (e) {
      loading.value = Loading.loaded;
      debugPrint('_fetchWorkStatusPopup error: $e');
      return null;
    }
  }

// ── Convert WorkStatusItem list → table rows + totals ───────────────────
  Map<String, dynamic> _buildStatsFromWorkList(List<WorkStatusItem> items) {
    final List<Map<String, String>> rows = [];
    int totalWorked = 0;
    int totalBreak  = 0;

    // Allotted shift hours – derive from shift_name ("09:00 AM to 06:00 PM")
    // Used to calculate short/overtime per row
    int totalShort = 0;
    int totalOver  = 0;

    for (final item in items) {
      // ── worked minutes (clock_out − clock_in, adjusted for overnight) ──
      int inMins  = _timeToMinutes(item.clockIn);
      int outMins = _timeToMinutes(item.clockOut);
      if (outMins <= inMins) outMins += 24 * 60; // overnight
      final int breakMins   = _parseBreakDuration(item.breakDuration);
      final int workedMins  = outMins - inMins - breakMins;

      totalWorked += workedMins > 0 ? workedMins : 0;
      totalBreak  += breakMins;

      // ── allotted minutes from shift_name ───────────────────────────────
      int allotted = 9 * 60; // default 9 h
      if (item.shiftName != null && item.shiftName!.contains(' to ')) {
        final parts = item.shiftName!.split(' to ');
        if (parts.length == 2) {
          final s = _timeToMinutes(parts[0].trim());
          int e = _timeToMinutes(parts[1].trim());
          if (e <= s) e += 24 * 60;
          allotted = e - s;
        }
      }

      final diff = workedMins - allotted;
      if (diff < 0) totalShort += diff.abs();
      if (diff > 0) totalOver  += diff;

      rows.add({
        'date':         item.timeDate ?? '',
        'firstIn':      item.clockIn  ?? '',
        'lastOut':      item.clockOut ?? '',
        'breakHours':   _minsToHm(breakMins),
        'shiftDetails': item.shiftName ?? '',
      });
    }

    return {
      'rows':       rows,
      'workedHours': _minsToHm(totalWorked),
      'shortHours':  _minsToHm(totalShort),
      'overTime':    _minsToHm(totalOver),
    };
  }

// ── Main method (replaces old showTimeDetailsDialog) ────────────────────
  Future<void> showTimeDetailsDialog(String period) async {
    if (period == 'today') {
      // ── Today: keep existing local logic ──────────────────────────────
      final todayData = _buildTodayPopupData();
      Get.dialog(
        Dialog(
          backgroundColor: Colors.white,
          elevation: 0,
          insetPadding: EdgeInsets.zero,
          child: TimeDetailsPopup(
            data:        todayData['data'] as List<Map<String, String>>,
            title:       'Today',
            workedHours: todayData['workedHours'] as String,
            shortHours:  todayData['shortHours']  as String,
            overTime:    todayData['overTime']    as String,
          ),
        ),
      );
      return;
    }

    // ── Yesterday / Week / Month: single API call ──────────────────────
    final filterMap = {
      'yesterday': 'yesterday',
      'week':      'week',
      'month':     'month',
    };
    final filter = filterMap[period] ?? 'month';
    final titleMap = {
      'yesterday': 'Yesterday',
      'week':      'This Week',
      'month':     'This Month',
    };

    // Show spinner
    Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );

    final items = await _fetchWorkStatusPopup(filter);
    Get.back(); // Close spinner

    if (items == null || items.isEmpty) {
      appSnackBar(data: 'No data available', color: AppColors.appRedColor);
      return;
    }

    final stats = _buildStatsFromWorkList(items);

    String pWorked = '0h 00m';
    String pShort = '0h 00m';
    String pOver = '0h 00m';

    if (period == 'yesterday') {
      pWorked = yesterdayWorkedHours.value.isNotEmpty ? yesterdayWorkedHours.value : '0h 00m';
      pShort = yesterdayShortHours.value.isNotEmpty ? yesterdayShortHours.value : '0h 00m';
      pOver = yesterdayOverTime.value.isNotEmpty ? yesterdayOverTime.value : '0h 00m';
    } else if (period == 'week') {
      pWorked = weekWorkedHours.value.isNotEmpty ? weekWorkedHours.value : '0h 00m';
      pShort = weekShortHours.value.isNotEmpty ? weekShortHours.value : '0h 00m';
      pOver = weekOverTime.value.isNotEmpty ? weekOverTime.value : '0h 00m';
    } else if (period == 'month') {
      pWorked = monthWorkedHours.value.isNotEmpty ? monthWorkedHours.value : '0h 00m';
      pShort = monthShortHours.value.isNotEmpty ? monthShortHours.value : '0h 00m';
      pOver = monthOverTime.value.isNotEmpty ? monthOverTime.value : '0h 00m';
    } else {
      pWorked = stats['workedHours'] as String;
      pShort = stats['shortHours'] as String;
      pOver = stats['overTime'] as String;
    }

    Get.dialog(
      Dialog(
        backgroundColor: Colors.white,
        elevation: 0,
        insetPadding: EdgeInsets.zero,
        child: TimeDetailsPopup(
          data:        stats['rows']        as List<Map<String, String>>,
          title:       titleMap[period]!,
          workedHours: pWorked,
          shortHours:  pShort,
          overTime:    pOver,
        ),
      ),
    );
  }
  // Check biometric status from user data or API
  void checkBiometricStatus() {
    isBiometricEnabled.value = false;
  }


  // Select date for regularize
  Future<void> selectRegularizeDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: regularizeSelectedDate.value ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      regularizeSelectedDate.value = picked;
      regularizeDateController.text = DateFormat('dd/MM/yyyy').format(picked);
    }
  }

  void navigateToRouteReplay() {
    // Use GetX routing, Navigator, or other method as your app uses
    Get.toNamed(AppRoutes.routeHistoryPage);
  }

  // ==================== ROUTE CAPTURE ====================

  /// Start route capture flow
  Future<void> startRouteCapture() async {
    isLoadingLocation.value = true;
    capturedRouteImage.value = null;

    final hasPermission = await _handleLocationPermission();
    if (!hasPermission) {
      isLoadingLocation.value = false;
      appSnackBar(
        data: 'Location permission is required for route capture',
        color: AppColors.appRedColor,
      );
      return;
    }

    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 10),
      );

      currentPosition.value = position;
      await _getAddressFromCoordinates(position);
      _updateMapMarkers();

      isCapturingRoute.value = true;
      isLoadingLocation.value = false;
    } catch (e) {
      isLoadingLocation.value = false;
      appSnackBar(
        data: 'Failed to get location: ${e.toString()}',
        color: AppColors.appRedColor,
      );
    }
  }

  /// Capture photo for route
  Future  captureRoutePhoto() async {
    try {
      var status = await Permission.camera.status;
      if (!status.isGranted) {
        await requestCameraPermission();
        status = await Permission.camera.status;
        if (!status.isGranted) return;
      }

      final ImagePicker picker = ImagePicker();
      final XFile? photo = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 70,
        maxWidth: 1024,
      );

      if (photo != null) {
        capturedRouteImage.value = File(photo.path);
      }
    } catch (e) {
      debugPrint('Error capturing route photo: $e');
      appSnackBar(
        data: 'Failed to capture photo',
        color: AppColors.appRedColor,
      );
    }
  }

  /// Confirm and submit route to API
  Future<void> confirmRouteCapture() async {
    if (capturedRouteImage.value == null) {
      appSnackBar(
        data: 'Please take a photo first',
        color: AppColors.appRedColor,
      );
      return;
    }

    try {
      isAddingRoute.value = true;

      final response = await timeProvider.addRoute(
        clientId: userData.user?.clientId ?? '',
        companyId: userData.user?.companyId ?? '',
        employeeId: userData.user?.employeeId ?? '',
        empTimeId: currentEmpTimeId.value,
        latitude: currentPosition.value?.latitude.toString(),
        longitude: currentPosition.value?.longitude.toString(),
        image: capturedRouteImage.value,
      );

      final responseData = jsonDecode(response.body);

      if (responseData['success'] == true) {
        // Reset state first before showing snackbar
        cancelRouteCapture();

        final msg = responseData['message'];
        appSnackBar(
          data: (msg != null && msg.toString().isNotEmpty) ? msg : 'Route added successfully',
          color: AppColors.textGreenColor,
        );
      } else {
        final msg = responseData['message'];
        appSnackBar(
          data: (msg != null && msg.toString().isNotEmpty) ? msg : 'Failed to add route',
          color: AppColors.appRedColor,
        );
      }
    } on CustomException catch (err) {
      appSnackBar(data: err.message, color: AppColors.appRedColor);
    } catch (e, st) {
      debugPrint('confirmRouteCapture Error: $e $st');
      appSnackBar(
        data: 'Failed to add route: ${e.toString()}',
        color: AppColors.appRedColor,
      );
    } finally {
      isAddingRoute.value = false;
    }
  }

  /// Cancel route capture and return to working view
  void cancelRouteCapture() {
    isCapturingRoute.value = false;
    capturedRouteImage.value = null;
  }

  // Select time for regularize
  Future<void> selectRegularizeTime(
    BuildContext context,
    String fieldType, {
    int? index,
    bool isStart = true, // true for start break, false for end break
  }) async {
    var appTheme = Get.find<ThemeController>().currentTheme;
    TimeOfDay? initialTime;

    if (fieldType == 'clockIn') {
      initialTime = regularizeClockInTime.value ?? TimeOfDay.now();
    } else if (fieldType == 'clockOut') {
      initialTime = regularizeClockOutTime.value ?? TimeOfDay.now();
    } else if (fieldType == 'break' && index != null) {
      if (isStart) {
        initialTime = regularizeBreakStartTimes.length > index ? regularizeBreakStartTimes[index].value : TimeOfDay.now();
      } else {
        initialTime = regularizeBreakEndTimes.length > index ? regularizeBreakEndTimes[index].value : TimeOfDay.now();
      }
    }

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initialTime ?? TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            timePickerTheme: TimePickerThemeData(
              dayPeriodTextColor: WidgetStateColor.resolveWith(
                (states) => states.contains(WidgetState.selected)
                    ? appTheme.white
                    : Colors.black,
              ),
              dayPeriodColor: WidgetStateColor.resolveWith(
                (states) => states.contains(WidgetState.selected)
                    ? appTheme.appColor
                    : Colors.grey.shade300,
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      String formattedTime = _formatTimeOfDayRegularize(picked);

      if (fieldType == 'clockIn') {
        regularizeClockInTime.value = picked;
        regularizeClockInController.text = formattedTime;
      } else if (fieldType == 'clockOut') {
        regularizeClockOutTime.value = picked;
        regularizeClockOutController.text = formattedTime;
      } else if (fieldType == 'break' && index != null) {
        if (isStart) {
          if (regularizeBreakStartTimes.length > index) {
            regularizeBreakStartTimes[index].value = picked;
            regularizeBreakStartControllers[index].text = formattedTime;
          }
        } else {
          if (regularizeBreakEndTimes.length > index) {
            regularizeBreakEndTimes[index].value = picked;
            regularizeBreakEndControllers[index].text = formattedTime;
          }
        }
      }
    }
  }

  // Select date for overtime
  Future<void> selectOvertimeDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: overtimeSelectedDate.value ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      overtimeSelectedDate.value = picked;
      overtimeDateController.text = DateFormat('dd/MM/yyyy').format(picked);
    }
  }

  // Select time for overtime
  Future<void> selectOvertimeTime(
    BuildContext context,
    String fieldType,
  ) async {
    var appTheme = Get.find<ThemeController>().currentTheme;
    TimeOfDay? initialTime;

    switch (fieldType) {
      case 'clockIn':
        initialTime = overtimeClockInTime.value ?? TimeOfDay.now();
        break;
      case 'clockOut':
        initialTime = overtimeClockOutTime.value ?? TimeOfDay.now();
        break;
    }

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initialTime ?? TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            timePickerTheme: TimePickerThemeData(
              dayPeriodTextColor: WidgetStateColor.resolveWith(
                (states) => states.contains(WidgetState.selected)
                    ? appTheme.white
                    : Colors.black,
              ),
              dayPeriodColor: WidgetStateColor.resolveWith(
                (states) => states.contains(WidgetState.selected)
                    ? appTheme.appColor
                    : Colors.grey.shade300,
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      String formattedTime = _formatTimeOfDayRegularize(picked);

      switch (fieldType) {
        case 'clockIn':
          overtimeClockInTime.value = picked;
          overtimeClockInController.text = formattedTime;
          break;
        case 'clockOut':
          overtimeClockOutTime.value = picked;
          overtimeClockOutController.text = formattedTime;
          break;
      }

      calculateOvertime();
    }
  }

  // Calculate overtime
  void calculateOvertime() {
    if (overtimeClockInTime.value != null &&
        overtimeClockOutTime.value != null) {
      int totalMinutes = (overtimeClockOutTime.value!.hour * 60 +
              overtimeClockOutTime.value!.minute) -
          (overtimeClockInTime.value!.hour * 60 +
              overtimeClockInTime.value!.minute);

      int expectedMinutes = 9 * 60;
      int overtimeMinutes = totalMinutes - expectedMinutes;

      if (overtimeMinutes > 0) {
        int hours = overtimeMinutes ~/ 60;
        int minutes = overtimeMinutes % 60;
        overtimeOvertimeController.text =
            '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:00';
      } else {
        overtimeOvertimeController.text = '00:00:00';
      }
    }
  }

  // Helper method to format time
  String _formatTimeOfDayRegularize(TimeOfDay time) {
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    return DateFormat('hh:mm:ss a').format(dt);
  }
  Future<void> handleLocationCaptureTap() async {
    if (isOnBreak.value) {
      _showEndBreakForLocationDialog();
    } else {
      await startRouteCapture();
    }
  }
  void _showEndBreakForLocationDialog() {
    var appTheme = Get.find<ThemeController>().currentTheme;

    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        insetPadding: EdgeInsets.all(0),
        child: Container(
          width: 95.w,
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: appTheme.popUpBG,
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: ListView(
            shrinkWrap: true,
            children: [
              Align(
                alignment: Alignment.topRight,
                child: GestureDetector(
                  onTap: Get.back,
                  child: Icon(Icons.close, size: 24.sp, color: appTheme.darkGrey),
                ),
              ),
              SizedBox(height: 1.h),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: appTheme.popUp1Border),
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: EdgeInsets.all(3),
                child: Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: appTheme.leaveDetailsBG,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 36.sp,
                        color: appTheme.appColor,
                      ),
                      SizedBox(height: 1.5.h),
                      Text(
                        'End Break & Capture Location?',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: appTheme.darkGrey,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 1.h),
                      Text(
                        'You are currently on a break. Capturing your location will end your break. Are you sure you want to proceed?',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: appTheme.darkGrey,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 3.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          // Cancel button
                          Container(
                            width: 28.w,
                            height: 4.h,
                            decoration: BoxDecoration(
                              border: Border.all(color: appTheme.appColor),
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.symmetric(vertical: 6),
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                              ),
                              onPressed: Get.back,
                              child: Text(
                                'Cancel',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w900,
                                  color: appTheme.appColor,
                                ),
                              ),
                            ),
                          ),
                          // Proceed button
                          Container(
                            width: 28.w,
                            height: 4.h,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: appTheme.buttonGradient,
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.symmetric(vertical: 6),
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                              ),
                              onPressed: () async {
                                Get.back(); // close dialog first
                                await endBreak(); // end the active break
                                await startRouteCapture(); // then start location capture
                              },
                              child: Text(
                                'Proceed',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w900,
                                  color: appTheme.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: true,
    );
  }

  /// Submit regularize
  Future<void> submitRegularize() async {
    if (regularizeReasonController.text.isEmpty) {
      appSnackBar(data: 'Please enter reason', color: AppColors.appRedColor);
      return;
    }

    loading.value = Loading.loading;
    try {
      // ✅ Build emp_breaks with ALL required fields from the dynamic controllers
      final List<Map<String, String>> empBreaks = [];

      for (int i = 0; i < regularizeBreakData.length; i++) {
        final brk = regularizeBreakData[i];
        final empBreakId = brk.empBreakId ?? '';
        final empTimeId = brk.empTimeId ?? '';
        
        String startBreak = '';
        String endBreak = '';
        
        if (regularizeBreakStartControllers.length > i) {
          startBreak = regularizeBreakStartControllers[i].text;
        }
        if (regularizeBreakEndControllers.length > i) {
          endBreak = regularizeBreakEndControllers[i].text;
        }

        // Skip if no valid start break time
        if (startBreak.isEmpty || startBreak == '00:00:00' || startBreak == '00:00') continue;

        empBreaks.add({
          'modify_emp_break_id': empBreakId,
          'modify_emp_time_id': empTimeId,
          'modify_start_break': startBreak,
          'modify_end_break': endBreak,
        });
      }

      // Resolve empTimeId from calendar
      String resolvedEmpTimeId = currentEmpTimeId.value;
      if (regularizeSelectedDate.value != null) {
        final calendarEntry = getTimeCalendarModelForDay(regularizeSelectedDate.value!);
        if (calendarEntry?.empTimeId?.isNotEmpty == true) {
          resolvedEmpTimeId = calendarEntry!.empTimeId!;
        }
      }

      final response = await timeProvider.modifyAttendance(
        actionFlag: 'modify_time',
        clientId: userData.user?.clientId ?? '',
        companyId: userData.user?.companyId ?? '',
        employeeId: userData.user?.employeeId ?? '',
        modifyInTime: regularizeClockInController.text,
        modifyOutTime: regularizeClockOutController.text,
        otKey: 'popup_modify',
        modifyEmpTimeId: resolvedEmpTimeId,
        empBreaks: empBreaks,
        employeeRemark: regularizeReasonController.text,
        loginUserId: userData.user?.id.toString() ?? '',
      );

      final responseData = jsonDecode(response.body);
      loading.value = Loading.loaded;

      if (responseData['success'] == true) {
        await fetchEmployeeTimeView();
        Get.back();
        appSnackBar(
          data: responseData['message'] ?? 'Regularization request submitted successfully',
          color: AppColors.textGreenColor,
        );
      } else {
        appSnackBar(
          data: responseData['message'] ?? 'Failed to submit regularization request',
          color: AppColors.appRedColor,
        );
      }
    } on CustomException catch (err) {
      loading.value = Loading.loaded;
      appSnackBar(data: err.message, color: AppColors.appRedColor);
    } catch (e, s) {
      loading.value = Loading.loaded;
      debugPrint('submitRegularize Error: $e\n$s');
      appSnackBar(
        data: 'Failed to submit regularization: ${e.toString()}',
        color: AppColors.appRedColor,
      );
    }
  }


  // Submit overtime
  Future<void> submitOvertime() async {
    if (overtimeReasonController.text.isEmpty) {
      appSnackBar(data: 'Please enter reason', color: AppColors.appRedColor);
      return;
    }

    loading.value = Loading.loading;

    // Simulate API call
    await Future.delayed(Duration(seconds: 2));

    loading.value = Loading.loaded;
    Get.back();
    appSnackBar(
      data: 'Overtime request submitted successfully',
      color: AppColors.textGreenColor,
    );
  }

  // Update the dispose method to include new controllers
  @override
  void dispose() {
    // Regularize controllers
    regularizeDateController.dispose();
    regularizeClockInController.dispose();
    regularizeClockOutController.dispose();
    regularizeReasonController.dispose();

    for (var c in regularizeBreakStartControllers) { c.dispose(); }
    for (var c in regularizeBreakEndControllers) { c.dispose(); }

    // Overtime controllers
    overtimeDateController.dispose();
    overtimeClockInController.dispose();
    overtimeClockOutController.dispose();
    overtimeOvertimeController.dispose();
    overtimeBaseRateController.dispose();
    overtimeReasonController.dispose();

    // Dispose break reminder service
    _breakReminderService.dispose();

    Get.delete<TimePageController>();
    super.dispose();
  }

  Future<void> toggleClockInOut() async {
    if (!isClockedIn.value && !isConfirmingClockIn.value) {
      // Initial Clock In - Request location
      await _clockIn();
    } else if (isClockedIn.value) {
      // Clock Out

      await _clockOut();
    }
  }

  Future<void> _clockIn() async {
    if (isPhotoUpload.value) {
      isLoadingLocation.value = true;

      final hasPermission = await _handleLocationPermission();
      if (!hasPermission) {
        isLoadingLocation.value = false;
        appSnackBar(
          data: 'Location permission is required for clock in',
          color: AppColors.appRedColor,
        );
        return;
      }

      try {
        final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        );

        currentPosition.value = position;
        await _getAddressFromCoordinates(position);

        // Set clock-in time with proper format
        clockInTime.value = DateFormat(
          'MMM d \'at\' h:mm a',
        ).format(DateTime.now());

        _updateMapMarkers();
        isConfirmingClockIn.value = true;
        isLoadingLocation.value = false;

        appSnackBar(
          data: 'Location captured. Please confirm your clock in.',
          color: AppColors.textGreenColor,
        );
      } catch (e) {
        isLoadingLocation.value = false;
        appSnackBar(
          data: 'Failed to get location: ${e.toString()}',
          color: AppColors.appRedColor,
        );
      }
    } else {
      // Direct clock-in without photo
      clockInTime.value = DateFormat(
        'MMM d \'at\' h:mm a',
      ).format(DateTime.now());
      isClockedIn.value = true;
      todayWorkedHours.value = '0h 00m';

      appSnackBar(
        data: 'Clocked in successfully',
        color: AppColors.textGreenColor,
      );
    }
  }

  void cancelClockInConfirmation() {
    isConfirmingClockIn.value = false;
    capturedImage.value = null;
    currentPosition.value = null;
    currentAddress.value = '';
    clockInTime.value = '';

    appSnackBar(data: 'Clock in cancelled', color: AppColors.appRedColor);
  }

  void cancelClockOutConfirmation() {
    isConfirmingClockOut.value = false;
    capturedImageClockOut.value = null;
    clockOutTime.value = '';

    appSnackBar(data: 'Clock out cancelled', color: AppColors.appRedColor);
  }

  Future<bool> _handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Show dialog asking user to enable location services
      _showLocationServiceDialog();
      return false;
    }

    // Check current permission status
    permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      // Request permission from user
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        appSnackBar(
          data: 'Location permission is required for clock in',
          color: AppColors.appRedColor,
        );
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permission denied permanently, show dialog to open app settings
      _showLocationPermissionDialog();
      return false;
    }

    // Permission granted (either always or whileInUse)
    return true;
  }

  void _showLocationServiceDialog() {
    var appTheme = Get.find<ThemeController>().currentTheme;
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        insetPadding: EdgeInsets.all(0),
        child: Container(
          width: 95.w,
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: appTheme.popUpBG,
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: ListView(
            shrinkWrap: true,
            children: [
              Align(
                alignment: Alignment.topRight,
                child: GestureDetector(
                  onTap: () => Get.back(),
                  child: Icon(
                    Icons.close,
                    size: 24.sp,
                    color: appTheme.darkGrey,
                  ),
                ),
              ),
              SizedBox(height: 1.h),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: appTheme.popUp1Border),
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: EdgeInsets.all(3),
                child: Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: appTheme.leaveDetailsBG,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Location Services Disabled',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: appTheme.darkGrey,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 1.h),
                      Text(
                        'Please enable location services in your device settings to use this feature.',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: appTheme.darkGrey,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 3.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Container(
                            width: 28.w,
                            height: 4.h,
                            decoration: BoxDecoration(
                              border: Border.all(color: appTheme.appColor),
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.symmetric(vertical: 6),
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                              ),
                              onPressed: () => Get.back(),
                              child: Text(
                                "Cancel",
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w900,
                                  color: appTheme.appColor,
                                ),
                              ),
                            ),
                          ),
                          Container(
                            width: 28.w,
                            height: 4.h,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: appTheme.buttonGradient,
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.symmetric(vertical: 6),
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                              ),
                              onPressed: () {
                                Get.back();
                                Geolocator.openLocationSettings();
                              },
                              child: Text(
                                "Settings",
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w900,
                                  color: appTheme.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLocationPermissionDialog() {
    var appTheme = Get.find<ThemeController>().currentTheme;
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        insetPadding: EdgeInsets.all(0),
        child: Container(
          width: 95.w,
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: appTheme.popUpBG,
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: ListView(
            shrinkWrap: true,
            children: [
              Align(
                alignment: Alignment.topRight,
                child: GestureDetector(
                  onTap: () => Get.back(),
                  child: Icon(
                    Icons.close,
                    size: 24.sp,
                    color: appTheme.darkGrey,
                  ),
                ),
              ),
              SizedBox(height: 1.h),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: appTheme.popUp1Border),
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: EdgeInsets.all(3),
                child: Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: appTheme.leaveDetailsBG,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Location Permission Required',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: appTheme.darkGrey,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 1.h),
                      Text(
                        'Please enable your GPS location and try clocking in again.',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: appTheme.darkGrey,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 3.h),
                      Container(
                        width: 35.w,
                        height: 4.h,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: appTheme.buttonGradient,
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 6),
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                          ),
                          onPressed: () {
                            Get.back();
                          },
                          child: Text(
                            "OK",
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w900,
                              color: appTheme.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _getAddressFromCoordinates(Position position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        currentAddress.value =
            '${place.name ?? ''}, ${place.locality ?? ''}, ${place.administrativeArea ?? ''}';
      }
    } catch (e) {
      currentAddress.value =
          'Location: ${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}';
    }
  }

  void _updateMapMarkers() {
    if (currentPosition.value != null) {
      markers.clear();
      markers.add(
        Marker(
          markerId: MarkerId('current_location'),
          position: LatLng(
            currentPosition.value!.latitude,
            currentPosition.value!.longitude,
          ),
          infoWindow: InfoWindow(
            title: 'Clock In Location',
            snippet: currentAddress.value,
          ),
        ),
      );
    }
  }

  void onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  Future<void> confirmClockIn() async {
    if (isPhotoUpload.value && capturedImage.value == null) {
      appSnackBar(
        data: 'Please take a photo to confirm clock in',
        color: AppColors.appRedColor,
      );
      return;
    }

    try {
      loading.value = Loading.loading;
      
      // Format current time for API
      final now = DateTime.now();
      final inTimeForApi = DateFormat('HH:mm:ss').format(now);
      print('ss $inTimeForApi');
      // Call the clock in API
      final response = await timeProvider.clockIn(
        clientId: userData.user?.clientId ?? '',
        companyId: userData.user?.companyId ?? '',
        employeeId: userData.user?.employeeId ?? '',
        inTime: inTimeForApi,
        latitude: currentPosition.value?.latitude.toString(),
        longitude: currentPosition.value?.longitude.toString(),
        image: capturedImage.value,
      );
      
      final responseData = jsonDecode(response.body);
      
      if (responseData['success'] == true) {
        // Set clock-in time to current time with proper format for display
        clockInTime.value = DateFormat('MMM d \'at\' h:mm a').format(now);
        
        // Confirm clock-in
        isClockedIn.value = true;
        isConfirmingClockIn.value = false;
        
        // Reset worked hours for new session
        todayWorkedHours.value = '0h 00m';
        todayBreakHours.value = '0h 00m';
        
        // Refresh time data to get emp_time_id
        await fetchEmployeeTimeView();
        
        // Start break reminder notifications
        await _breakReminderService.init();
        _breakReminderService.startBreakReminder(allottedBreakMinutes.value);
        
        loading.value = Loading.loaded;
        
        final message = responseData['data']?['employee_time']?[0]?['message'] ?? 
                        'Clocked in successfully at ${currentAddress.value}';
        appSnackBar(
          data: message,
          color: AppColors.textGreenColor,
        );
      } else {
        loading.value = Loading.loaded;
        appSnackBar(
          data: responseData['message'] ?? 'Failed to clock in',
          color: AppColors.appRedColor,
        );
      }
    } on CustomException catch (err) {
      loading.value = Loading.loaded;
      appSnackBar(data: err.message, color: AppColors.appRedColor);
    } catch (e, st) {
      loading.value = Loading.loaded;
      debugPrint("confirmClockIn Error: $e $st");
      appSnackBar(
        data: 'Failed to clock in: ${e.toString()}',
        color: AppColors.appRedColor,
      );
    }
  }

  Future<void> requestCameraPermission() async {
    // Check current permission status first
    var status = await Permission.camera.status;

    if (status.isDenied) {
      // Request permission
      status = await Permission.camera.request();

      if (status.isGranted) {
        appSnackBar(
          data: 'Camera permission granted',
          color: AppColors.textGreenColor,
        );
      } else if (status.isDenied) {
        appSnackBar(
          data: 'Camera permission is required to take photo',
          color: AppColors.appRedColor,
        );
      } else if (status.isPermanentlyDenied) {
        // Show dialog to open settings
        _showCameraPermissionDialog();
      }
    } else if (status.isPermanentlyDenied) {
      _showCameraPermissionDialog();
    }
  }

  void _showCameraPermissionDialog() {
    var appTheme = Get.find<ThemeController>().currentTheme;
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: appTheme.leaveDetailsBG,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Camera Permission Required',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: appTheme.darkGrey,
                ),
              ),
              SizedBox(height: 1.h),
              Text(
                'Please enable camera permission in app settings to take photos.',
                style: TextStyle(fontSize: 14.sp, color: appTheme.darkGrey),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 3.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () => Get.back(),
                    child: Text("Cancel"),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Get.back();
                      openAppSettings(); // Opens iOS settings
                    },
                    child: Text("Settings"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> capturePhoto() async {
    // Check camera permission
    var status = await Permission.camera.status;
    if (!status.isGranted) {
      await requestCameraPermission();
      status = await Permission.camera.status;
      if (!status.isGranted) return;
    }

    try {
      final ImagePicker picker = ImagePicker();
      final XFile? photo = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 70,
        maxWidth: 1024,
        maxHeight: 1024,
        preferredCameraDevice: CameraDevice.front,
      );

      if (photo != null) {
        // Store in appropriate variable based on state
        if (isConfirmingClockOut.value) {
          capturedImageClockOut.value = File(photo.path);
        } else {
          capturedImage.value = File(photo.path);
        }

        appSnackBar(
          data: 'Photo captured successfully',
          color: AppColors.textGreenColor,
        );
      }
    } catch (e) {
      appSnackBar(
        data: 'Failed to capture photo: ${e.toString()}',
        color: AppColors.appRedColor,
      );
    }
  }

  Future<void> startBreak() async {
    try {
      loading.value = Loading.loading;
      
      final now = DateTime.now();
      final startBreakTimeForApi = DateFormat('HH:mm:ss').format(now);
      
      final response = await timeProvider.startBreak(
        clientId: userData.user?.clientId ?? '',
        companyId: userData.user?.companyId ?? '',
        employeeId: userData.user?.employeeId ?? '',
        startBreakTime: startBreakTimeForApi,
        loginUserId: userData.user?.id.toString() ?? '1',
      );
      
      final responseData = jsonDecode(response.body);
      
      if (responseData['success'] == true) {
        breakStartTime.value = DateFormat('hh:mm a').format(now);
        isOnBreak.value = true;
        
        // Start extended break warning timer
        await _breakReminderService.init();
        _breakReminderService.startExtendedBreakWarning();
        
        loading.value = Loading.loaded;
        
        final message = responseData['data']?['employee_time']?[0]?['message'] ?? 
                        'Break started at ${breakStartTime.value}';
        appSnackBar(
          data: message,
          color: AppColors.textGreenColor,
        );
      } else {
        loading.value = Loading.loaded;
        appSnackBar(
          data: responseData['message'] ?? 'Failed to start break',
          color: AppColors.appRedColor,
        );
      }
    } on CustomException catch (err) {
      loading.value = Loading.loaded;
      appSnackBar(data: err.message, color: AppColors.appRedColor);
    } catch (e, st) {
      loading.value = Loading.loaded;
      debugPrint("startBreak Error: $e $st");
      appSnackBar(
        data: 'Failed to start break: ${e.toString()}',
        color: AppColors.appRedColor,
      );
    }
  }

  Future<void> endBreak() async {
    debugPrint('endBreak called, breakStartTime: "${breakStartTime.value}", isOnBreak: ${isOnBreak.value}');

    // ✅ FIX: If breakStartTime is empty but isOnBreak is true,
    // use current time as fallback instead of silently returning
    if (breakStartTime.value.isEmpty) {
      if (isOnBreak.value) {
        // Fallback: use current time so the API call can still proceed
        breakStartTime.value = DateFormat('hh:mm a').format(DateTime.now());
      } else {
        return; // Genuinely not on break
      }
    }
    try {
      loading.value = Loading.loading;
      
      final now = DateTime.now();
      final endBreakTimeForApi = DateFormat('HH:mm:ss').format(now);
      String breakEnd = DateFormat('hh:mm a').format(now);
      
      final response = await timeProvider.endBreak(
        clientId: userData.user?.clientId ?? '',
        companyId: userData.user?.companyId ?? '',
        employeeId: userData.user?.employeeId ?? '',
        endBreakTime: endBreakTimeForApi,
        loginUserId: userData.user?.id.toString() ?? '1',
      );
      
      final responseData = jsonDecode(response.body);
      
      if (responseData['success'] == true) {
        // Calculate break duration for local display
        DateTime startTime = DateFormat('hh:mm a').parse(breakStartTime.value);
        DateTime endTime = DateFormat('hh:mm a').parse(breakEnd);
        Duration breakDuration = endTime.difference(startTime);

        // Add to break history
        breakHistory.add({
          'start': breakStartTime.value,
          'end': breakEnd,
          'duration': _formatDuration(breakDuration),
        });

        // Cancel extended break warning
        _breakReminderService.cancelExtendedBreakWarning();

        isOnBreak.value = false;
        breakStartTime.value = '';
        
        loading.value = Loading.loaded;
        
        final message = responseData['data']?['employee_time']?[0]?['message'] ?? 
                        'Break ended. Duration: ${_formatDuration(breakDuration)}';
        appSnackBar(
          data: message,
          color: AppColors.textGreenColor,
        );
      } else {
        loading.value = Loading.loaded;
        appSnackBar(
          data: responseData['message'] ?? 'Failed to end break',
          color: AppColors.appRedColor,
        );
      }
    } on CustomException catch (err) {
      loading.value = Loading.loaded;
      appSnackBar(data: err.message, color: AppColors.appRedColor);
    } catch (e, st) {
      loading.value = Loading.loaded;
      debugPrint("endBreak Error: $e $st");
      appSnackBar(
        data: 'Failed to end break: ${e.toString()}',
        color: AppColors.appRedColor,
      );
    }
  }

  void showBreakDialog() {
    var appTheme = Get.find<ThemeController>().currentTheme;
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        insetPadding: EdgeInsets.all(0),
        child: Container(
          width: 95.w,
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: appTheme.popUpBG,
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: ListView(
            shrinkWrap: true,
            children: [
              Align(
                alignment: Alignment.topRight,
                child: GestureDetector(
                  onTap: () => Get.back(),
                  child: Icon(
                    Icons.close,
                    size: 24.sp,
                    color: appTheme.darkGrey,
                  ),
                ),
              ),
              SizedBox(height: 1.h),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: appTheme.popUp1Border),
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: EdgeInsets.all(3),
                child: Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: appTheme.leaveDetailsBG,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Take a Break?',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: appTheme.darkGrey,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 1.h),
                      Text(
                        'It\'s time to take a quick break!',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: appTheme.darkGrey,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 3.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Container(
                            width: 28.w,
                            height: 4.h,
                            decoration: BoxDecoration(
                              border: Border.all(color: appTheme.appColor),
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.symmetric(vertical: 6),
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                              ),
                              onPressed: () => Get.back(),
                              child: Text(
                                "Cancel",
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w900,
                                  color: appTheme.appColor,
                                ),
                              ),
                            ),
                          ),
                          Container(
                            width: 28.w,
                            height: 4.h,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: appTheme.buttonGradient,
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.symmetric(vertical: 6),
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                              ),
                              onPressed: () {
                                Get.back();
                                startBreak();
                              },
                              child: Text(
                                "Start Break",
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w900,
                                  color: appTheme.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _clockOut() async {
    if (isClockOutPhotoUpload.value) {
      // Show confirmation screen for clock-out
      isLoadingLocation.value = true;

      final hasPermission = await _handleLocationPermission();
      if (!hasPermission) {
        isLoadingLocation.value = false;
        appSnackBar(
          data: 'Location permission is required for clock out',
          color: AppColors.appRedColor,
        );
        return;
      }

      try {
        final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        );

        currentPosition.value = position;
        await _getAddressFromCoordinates(position);
        clockOutTime.value = DateFormat('hh:mm a').format(DateTime.now());
        _updateMapMarkers();

        isConfirmingClockOut.value = true; // Show confirmation screen
        isLoadingLocation.value = false;

        appSnackBar(
          data: 'Location captured. Please confirm your clock out.',
          color: AppColors.textGreenColor,
        );
      } catch (e) {
        isLoadingLocation.value = false;
        appSnackBar(
          data: 'Failed to get location: ${e.toString()}',
          color: AppColors.appRedColor,
        );
      }
    } else {
      // Direct clock-out without photo
      await performClockOut();
    }
  }

  Future<void> confirmClockOut() async {
    if (isClockOutPhotoUpload.value && capturedImageClockOut.value == null) {
      appSnackBar(
        data: 'Please take a photo to confirm clock out',
        color: AppColors.appRedColor,
      );
      return;
    }

    await performClockOut();
  }

  Future<void> performClockOut() async {
    try {
      loading.value = Loading.loading;
      
      final now = DateTime.now();
      final outTimeForApi = DateFormat('HH:mm:ss').format(now);
      
      String? workingStatusId;
      String? workingHours;

      try {
        // Fetch working status before clocking out
        ProfilePostData employeeData = ProfilePostData(
          employeeId: userData.user?.employeeId,
          companyId: userData.user?.companyId,
          clientId: userData.user?.clientId,
        );

        final statusResponse = await timeProvider.getWorkingStatus(employeeData, outTimeForApi);
        final statusData = jsonDecode(statusResponse.body);
        
        if (statusData['success'] == true && statusData['data'] != null && 
            statusData['data']['employee_time'] != null && 
            (statusData['data']['employee_time'] as List).isNotEmpty) {
          final empTime = statusData['data']['employee_time'][0];
          workingStatusId = empTime['working_status_id'];
          workingHours = empTime['working_hours'];
        }
      } catch (e) {
        debugPrint("Error fetching working status: $e");
        // Proceed with clock out even if status fetch fails, or handle as needed
      }
      
      // Call the clock out API
      final response = await timeProvider.clockOut(
        clientId: userData.user?.clientId ?? '',
        companyId: userData.user?.companyId ?? '',
        employeeId: userData.user?.employeeId ?? '',
        empTimeId: currentEmpTimeId.value,
        outTime: outTimeForApi,
        latitude: currentPosition.value?.latitude.toString(),
        longitude: currentPosition.value?.longitude.toString(),
        image: capturedImageClockOut.value,
        workingStatusId: workingStatusId,
        workingHours: workingHours,
      );
      
      final responseData = jsonDecode(response.body);
      
      if (responseData['success'] == true) {
        clockOutTime.value = DateFormat('MMM d \'at\' h:mm a').format(now);

        // Calculate local time for display
        if (clockInTime.value.isNotEmpty) {
          try {
            DateTime clockIn;
            DateTime clockOut;

            // Handle both old format (hh:mm a) and new format (MMM d 'at' h:mm a)
            if (clockInTime.value.contains('at')) {
              clockIn = DateFormat('MMM d \'at\' h:mm a').parse(clockInTime.value);
            } else {
              DateTime parsedTime = DateFormat('hh:mm a').parse(clockInTime.value);
              clockIn = DateTime(now.year, now.month, now.day, parsedTime.hour, parsedTime.minute);
            }

            if (clockOutTime.value.contains('at')) {
              clockOut = DateFormat('MMM d \'at\' h:mm a').parse(clockOutTime.value);
            } else {
              DateTime parsedTime = DateFormat('hh:mm a').parse(clockOutTime.value);
              clockOut = DateTime(now.year, now.month, now.day, parsedTime.hour, parsedTime.minute);
            }

            Duration totalTime = clockOut.difference(clockIn);
            if (totalTime.isNegative) totalTime = Duration.zero;

            Duration totalBreaks = Duration.zero;
            for (var breakItem in breakHistory) {
              try {
                DateTime breakStart;
                DateTime breakEnd;

                if (breakItem['start']!.contains('at')) {
                  breakStart = DateFormat('MMM d \'at\' h:mm a').parse(breakItem['start']!);
                  breakEnd = DateFormat('MMM d \'at\' h:mm a').parse(breakItem['end']!);
                } else {
                  DateTime parsedStart = DateFormat('hh:mm a').parse(breakItem['start']!);
                  DateTime parsedEnd = DateFormat('hh:mm a').parse(breakItem['end']!);
                  breakStart = DateTime(now.year, now.month, now.day, parsedStart.hour, parsedStart.minute);
                  breakEnd = DateTime(now.year, now.month, now.day, parsedEnd.hour, parsedEnd.minute);
                }

                Duration breakDuration = breakEnd.difference(breakStart);
                if (!breakDuration.isNegative) totalBreaks += breakDuration;
              } catch (e) {
                debugPrint('Error parsing break time: $e');
              }
            }

            Duration actualWorkedTime = totalTime - totalBreaks;
            if (actualWorkedTime.isNegative) actualWorkedTime = Duration.zero;

            todayWorkedHours.value = _formatDuration(actualWorkedTime);
            todayBreakHours.value = _formatDuration(totalBreaks);
          } catch (e) {
            debugPrint('Error calculating worked time: $e');
            todayWorkedHours.value = '0h 00m';
            todayBreakHours.value = '0h 00m';
          }
        }

        // Stop all break notifications
        _breakReminderService.stopBreakReminder();
        _breakReminderService.cancelExtendedBreakWarning();

        // Reset all values
        isClockedIn.value = false;
        isOnBreak.value = false;
        isConfirmingClockOut.value = false;
        isConfirmingClockIn.value = false;
        currentPosition.value = null;
        breakHistory.clear();
        capturedImage.value = null;
        capturedImageClockOut.value = null;
        
        loading.value = Loading.loaded;
        
        final message = responseData['data']?['employee_time']?[0]?['message'] ?? 
                        'Clocked out successfully';
        appSnackBar(
          data: message,
          color: AppColors.textGreenColor,
        );
      } else {
        loading.value = Loading.loaded;
        appSnackBar(
          data: responseData['message'] ?? 'Failed to clock out',
          color: AppColors.appRedColor,
        );
      }
    } on CustomException catch (err) {
      loading.value = Loading.loaded;
      appSnackBar(data: err.message, color: AppColors.appRedColor);
    } catch (e, st) {
      loading.value = Loading.loaded;
      debugPrint("performClockOut Error: $e $st");
      appSnackBar(
        data: 'Failed to clock out: ${e.toString()}',
        color: AppColors.appRedColor,
      );
    }
  }

  String _formatDuration(Duration duration) {
    // Handle negative durations
    if (duration.isNegative) {
      return '0h 00m';
    }

    int hours = duration.inHours;
    int minutes = duration.inMinutes.remainder(60);
    return '${hours}h ${minutes.toString().padLeft(2, '0')}m';
  }

  /// Converts time string from "HH:MM" or "HH:MM:SS" or "HH:MM Hrs" format to "Xh YYm" format
  String _formatHoursMinutes(String timeString) {
    if (timeString.isEmpty) return '0h 00m';
    
    try {
      final cleanStr = timeString.replaceAll(RegExp(r'[^\d:]'), ''); // remove 'Hrs' and spaces
      final parts = cleanStr.split(':');
      if (parts.length >= 2) {
        int hours = int.parse(parts[0]);
        int minutes = int.parse(parts[1]);
        return '${hours}h ${minutes.toString().padLeft(2, '0')}m';
      }
    } catch (e) {
      debugPrint('Error formatting time: $e');
    }

    
    // If already in correct format or can't parse, return as-is
    if (timeString.contains('h') && timeString.contains('m')) {
      return timeString;
    }
    
    return '0h 00m';
  }

  void toggleSwitch(bool value) {
    isManager.value = value;
    if (!value) {
      if (Get.isRegistered<ManagerTimeController>()) {
        Get.delete<ManagerTimeController>();
      }
      Get.toNamed(AppRoutes.managerTimePage);
    }
  }

  var selectedManager = ManagerData(
    employeeId: "",
    employeeName: "",
    dropDownId: "",
    employeeNo: "",
  ).obs;
  var currentDelegateData = DelegateData().obs;
  RxList<ManagerData>? managerDropdownList = <ManagerData>[
    ManagerData(
      employeeId: "",
      employeeName: "",
      dropDownId: "",
      employeeNo: "",
    ),
  ].obs;
  final labelWidth = 20.w;
  final inputWidth = 40.w;

  void toggleExpanded(int index) {
    if (expandedIndex.value == index) {
      expandedIndex.value = null;
    } else {
      expandedIndex.value = index;
    }
    notifyChildrens();
  }

  void setSelectedManager(String dropDownId) {
    final index = managerDropdownList?.indexWhere(
      (doc) => doc.employeeId == dropDownId,
    );
    if (index != null && index != -1) {
      selectedManager.value = managerDropdownList![index];
    } else {
      if (kDebugMode) {
        print("Manager type not found.");
      }
    }
  }

  @override
  void onInit() {
    super.onInit();
    isManager.value =
        appStateController.menuItems.any((menu) => menu['menu_key'] == 'absence_manager');
    employeeLeaveHistory = [
      {
        "type": "Sick Leave",
        "from": "20-Jan-25",
        "to": "23-Jan-25",
        "days": '3',
      },
      {"type": "Sick Leave", "from": "2-Feb-25", "to": "3-Feb-25", "days": '1'},
      {
        "type": "Causal Leave",
        "from": "13-Jun-25",
        "to": "14-Jun-25",
        "days": '2',
      },
      {
        "type": "Paternity Leave",
        "from": "11-Sep-25",
        "to": "16-Sep-25",
        "days": '5',
      },
    ];
    selectedDayLeaves = [
      {
        'empId': 'EMP00100',
        'name': 'Chandrasekar Ramasubramanian',
        'type': 'Sick Leave',
        'days': '3',
      },
      {
        'empId': 'EMP231100',
        'name': 'Donald J Trump', // Fixed character encoding
        'type': 'Causal',
        'days': '1',
      },
      {
        'empId': 'EMP31130',
        'name': 'Malli Arjun Maddapli',
        'type': 'Sick Leave',
        'days': '1',
      },
      {
        'empId': 'EMP232100',
        'name': 'John Smith',
        'type': 'Sick Leave',
        'days': '5',
      },
    ];
    focusNode.addListener(() {
      if (focusNode.hasFocus) {
        Future.delayed(const Duration(milliseconds: 300), () {
          scrollController.animateTo(
            scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        });
      }
    });
    checkBiometricStatus();
    _initDone = _init();
  }

  void filterAndSetLeaveHistory(String employeeNo) {
    List<Map<String, String?>> filteredLeaves = [];

    // Filter leaves_details from your JSON data for the specific employee
    for (var leave in leaveItems) {
      if (leave.employeeNo == employeeNo) {
        filteredLeaves.add({
          "type": leave.planTypeName,
          "from": leave.fromDateFormat,
          "to": leave.toDateFormat,
          "days": leave.noOfDays != null
              ? leave.noOfDays!.split('.')[0] // Remove decimal part
              : '0',
          // Optional: Add more fields if needed
          "leave_status": leave.leaveStatus,
          "from_date": leave.fromDateFormat,
          "plan_type_name": leave.planTypeName,
        });
      }
    }

    // Update the leaveHistory with filtered data
    employeeLeaveHistory = filteredLeaves;
    update(); // Notify listeners about the change
  }

  Future<void> _init() async {
    await getUserData();
    await fetchEmployeeTimeView();
    await checkDelegate();
    // Note: getEmployeeLeaveList() removed - not used on time page
    _initializeSampleCalendarData();
  }

  /// Fetch Employee Time View data from API
  Future<void> fetchEmployeeTimeView() async {
    try {
      loading.value = Loading.loading;
      ProfilePostData employeeData = ProfilePostData(
        employeeId: userData.user?.employeeId,
        companyId: userData.user?.companyId,
        clientId: userData.user?.clientId,
      );
      
      String month = DateFormat('yyyy-MM').format(currentMonth.value);
      
      final response = await timeProvider.getEmployeeTimeView(employeeData, month);
      final responseData = jsonDecode(response.body);
      
      if (responseData['success'] == true) {
        parseApiResponse(responseData['data']);
        loading.value = Loading.loaded;
      } else {
        loading.value = Loading.loaded;
        appSnackBar(
          data: responseData['message'] ?? 'Failed to load time data',
          color: AppColors.appRedColor,
        );
      }
      update();
    } on CustomException catch (err) {
      loading.value = Loading.loaded;
      appSnackBar(data: err.message, color: AppColors.appRedColor);
    } catch (error, st) {
      loading.value = Loading.loaded;
      debugPrint("fetchEmployeeTimeView Error: $error $st");
      appSnackBar(
        data: 'Failed to fetch time data: ${error.toString()}',
        color: AppColors.appRedColor,
      );
    }
  }

  void _initializeSampleCalendarData() {
    // Add sample short hours dates for current month
    DateTime now = DateTime.now();
    shortHoursDates.addAll([
      DateTime(now.year, now.month, 2),
      DateTime(now.year, now.month, 15),
      DateTime(now.year, now.month, 23),
    ]);

    // Add sample overtime dates for current month
    overtimeDates.addAll([
      DateTime(now.year, now.month, 8),
      DateTime(now.year, now.month, 16),
      DateTime(now.year, now.month, 24),
    ]);
  }

  // Check if date has short hours
  bool hasShortHours(DateTime date) {
    return shortHoursDates.any(
      (d) => d.year == date.year && d.month == date.month && d.day == date.day,
    );
  }

  // Check if date has overtime
  bool hasOvertime(DateTime date) {
    return overtimeDates.any(
      (d) => d.year == date.year && d.month == date.month && d.day == date.day,
    );
  }

  // Navigate to regularize page for short hours
  void navigateToRegularize(DateTime date) {
    Get.toNamed(
      AppRoutes.regularizePage,
      arguments: {'date': date, 'type': 'short_hours'},
    );
  }

  // Navigate to overtime page
  void navigateToOvertime(DateTime date) {
    Get.toNamed(AppRoutes.overtimePage, arguments: {'date': date});
  }

  Future<void> waitUntilReady() => _initDone;

  checkDelegate() async {
    try {
      loading.value = Loading.loading;
      ProfilePostData employeeData = ProfilePostData(
        employeeId: userData.user?.employeeId,
        companyId: userData.user?.companyId,
        clientId: userData.user?.clientId,
      );
      await managerProvider.checkDelegate(employeeData).then((value) {
        final responseData = jsonDecode(value.body);
        if (responseData['success'] == true) {
          final delegate = checkDelegateFromJson(value.body);
          isHavingDelegate.value = delegate.data?.leaves?.isNotEmpty ?? false;
          if (isHavingDelegate.value) {
            currentDelegateId = delegate.data?.leaves?.first.delicateId ?? '';
          }
          fetchManagerDropdown();
          loading.value = Loading.loaded;
        }
      });
      update();
    } on CustomException catch (err) {
      loading.value = Loading.loaded;
      appSnackBar(data: err.message, color: AppColors.appRedColor);
    } catch (error) {
      loading.value = Loading.loaded;
      appSnackBar(
        data: 'Failed: ${error.toString()}',
        color: AppColors.appRedColor,
      );
    }
  }

  getCurrentDelegateData() async {
    try {
      loading.value = Loading.loading;
      ProfilePostData employeeData = ProfilePostData(
        employeeId: userData.user?.employeeId,
        companyId: userData.user?.companyId,
        clientId: userData.user?.clientId,
      );
      await managerProvider.getDelegateData(employeeData).then((value) {
        final responseData = jsonDecode(value.body);
        if (responseData['success'] == true) {
          final delegate = delegateDataResponseFromJson(value.body);
          loading.value = Loading.loaded;
          if (delegate.data?.leaves?.isNotEmpty ?? false) {
            currentDelegateData.value = delegate.data!.leaves!.first;
            DateFormat format = DateFormat("MM-dd-yyyy");
            fromDate.value = format.parse(currentDelegateData.value.fromDate!);
            toDate.value = format.parse(currentDelegateData.value.toDate!);
            setSelectedManager(currentDelegateData.value.delicateEmployeeId!);
          }
        }
      });
      update();
    } on CustomException catch (err) {
      loading.value = Loading.loaded;
      appSnackBar(data: err.message, color: AppColors.appRedColor);
    } catch (error) {
      loading.value = Loading.loaded;
      appSnackBar(
        data: 'Failed: ${error.toString()}',
        color: AppColors.appRedColor,
      );
    }
  }

  removeDelegate() async {
    try {
      loading.value = Loading.loading;
      ProfilePostData employeeData = ProfilePostData(
        employeeId: userData.user?.employeeId,
        companyId: userData.user?.companyId,
        clientId: userData.user?.clientId,
      );
      await managerProvider.removeDelegate(employeeData, '7').then((value) {
        final responseData = jsonDecode(value.body);
        if (responseData['success'] == true) {
          final delegate = checkDelegateFromJson(value.body);
          loading.value = Loading.loaded;
          appSnackBar(
            data: (delegate.message?.isNotEmpty ?? false)
                ? delegate.message!
                : 'Leave Revoked Successfully',
            color: AppColors.textGreenColor,
          );
          checkDelegate();
        }
      });
      update();
    } on CustomException catch (err) {
      loading.value = Loading.loaded;
      appSnackBar(data: err.message, color: AppColors.appRedColor);
    } catch (error) {
      loading.value = Loading.loaded;
      appSnackBar(
        data: 'Failed: ${error.toString()}',
        color: AppColors.appRedColor,
      );
    }
  }

  fetchManagerDropdown() async {
    try {
      loading.value = Loading.loading;
      ProfilePostData employeeData = ProfilePostData(
        employeeId: userData.user?.employeeId,
        companyId: userData.user?.companyId,
        clientId: userData.user?.clientId,
      );
      await managerProvider.getManagersDropdown(employeeData).then((value) {
        final responseData = jsonDecode(value.body);
        if (responseData['success'] == true) {
          final docData = managersDropDownFromJson(value.body);
          if (docData.data != null) {
            managerDropdownList?.value = docData.data?.leaves ?? [];
          }
          loading.value = Loading.loaded;
        }
      });
      update();
    } on CustomException catch (err) {
      loading.value = Loading.loaded;
      appSnackBar(data: err.message, color: AppColors.appRedColor);
    } catch (error) {
      loading.value = Loading.loaded;
      appSnackBar(
        data: 'Failed: ${error.toString()}',
        color: AppColors.appRedColor,
      );
    }
  }

  createDelegate() async {
    if (fromDate.value != null &&
        toDate.value != null &&
        selectedManager.value.employeeId!.isNotEmpty) {
      try {
        loading.value = Loading.loading;
        DelegateData delegateData = DelegateData(
          employeeId: userData.user?.employeeId,
          companyId: userData.user?.companyId,
          clientId: userData.user?.clientId,
          fromDate: fromDate.value != null
              ? dateTimeToString(fromDate.value!, format: "yyyy-MM-dd")
              : null,
          toDate: toDate.value != null
              ? dateTimeToString(toDate.value!, format: "yyyy-MM-dd")
              : null,
          employeeNo: selectedManager.value.employeeNo,
          delicateEmployeeId: selectedManager.value.employeeId,
          employeeNotification: selectedManager.value.employeeId,
        );
        await managerProvider.createDelegate(delegateData).then((value) {
          final responseData = jsonDecode(value.body);
          if (responseData['success'] == true) {
            final delegate = delegateDataResponseFromJson(value.body);
            appSnackBar(
              data: (delegate.message?.isNotEmpty ?? false)
                  ? delegate.message!
                  : 'Something went wrong',
              color: AppColors.textGreenColor,
            );
            loading.value = Loading.loaded;
            Get.offAllNamed(AppRoutes.homePage);
          } else {
            appSnackBar(
              data: responseData['message'] ?? 'Something went wrong',
              color: AppColors.textGreenColor,
            );
          }
        });
        update();
      } on CustomException catch (err) {
        loading.value = Loading.loaded;
        appSnackBar(data: err.message, color: AppColors.appRedColor);
      } catch (error, st) {
        loading.value = Loading.loaded;
        print(error.toString());
        print(st.toString());
        appSnackBar(
          data: 'Failed: ${error.toString()}',
          color: AppColors.appRedColor,
        );
      }
    } else {
      if (fromDate.value == null) {
        messageAlert('Select From Date', "Date Error", true, Get.context);
      }
      if (toDate.value == null) {
        messageAlert('Select To Date', "Date Error", true, Get.context);
      }
      if (selectedManager.value.employeeId == "") {
        messageAlert('Select Manager', "Manager Error", true, Get.context);
      }
    }
  }

  updateDelegate() async {
    if (fromDate.value != null &&
        toDate.value != null &&
        selectedManager.value.employeeId!.isNotEmpty) {
      try {
        loading.value = Loading.loading;
        DelegateData delegateData = DelegateData(
          delicateId: currentDelegateData.value.delicateId,
          employeeId: userData.user?.employeeId,
          companyId: userData.user?.companyId,
          clientId: userData.user?.clientId,
          fromDate: fromDate.value != null
              ? dateTimeToString(fromDate.value!, format: "yyyy-MM-dd")
              : null,
          toDate: toDate.value != null
              ? dateTimeToString(toDate.value!, format: "yyyy-MM-dd")
              : null,
          employeeNo: selectedManager.value.employeeNo,
          delicateEmployeeId: selectedManager.value.employeeId,
          employeeNotification: selectedManager.value.employeeId,
        );
        await managerProvider.updateDelegate(delegateData).then((value) {
          final responseData = jsonDecode(value.body);
          if (responseData['success'] == true) {
            final delegate = delegateDataResponseFromJson(value.body);
            appSnackBar(
              data: (delegate.message?.isNotEmpty ?? false)
                  ? delegate.message!
                  : 'Something went wrong',
              color: AppColors.textGreenColor,
            );
            loading.value = Loading.loaded;
            Get.offAllNamed(AppRoutes.homePage);
          } else {
            appSnackBar(
              data: responseData['message'] ?? 'Something went wrong',
              color: AppColors.textGreenColor,
            );
          }
        });
        update();
      } on CustomException catch (err) {
        loading.value = Loading.loaded;
        appSnackBar(data: err.message, color: AppColors.appRedColor);
      } catch (error, st) {
        loading.value = Loading.loaded;
        print(error.toString());
        print(st.toString());
        appSnackBar(
          data: 'Failed: ${error.toString()}',
          color: AppColors.appRedColor,
        );
      }
    } else {
      if (fromDate.value == null) {
        messageAlert('Select From Date', "Date Error", true, Get.context);
      }
      if (toDate.value == null) {
        messageAlert('Select To Date', "Date Error", true, Get.context);
      }
      if (selectedManager.value.employeeId == "") {
        messageAlert('Select Manager', "Manager Error", true, Get.context);
      }
    }
  }

  getEmployeeLeaveList() async {
    try {
      loading.value = Loading.loading;
      ProfilePostData employeeData = ProfilePostData(
        employeeId: userData.user?.employeeId,
        companyId: userData.user?.companyId,
        clientId: userData.user?.clientId,
      );
      await managerProvider.getLeaveData(employeeData).then((value) {
        final responseData = jsonDecode(value.body);
        if (responseData['success'] == true) {
          final employeeLeavesList = employeeLeavesListFromJson(value.body);
          final List<LeavesDetail> leaves =
              employeeLeavesList.data?.leavesDetails ?? [];
          final List<Calendar> calendar =
              employeeLeavesList.data?.calendar ?? [];
          leaveItems.value = leaves;
          teamLeaves.value = calendar;
          loading.value = Loading.loaded;
        } else {
          appSnackBar(
            data: responseData['message'] ?? 'Something went wrong',
            color: AppColors.textGreenColor,
          );
        }
      });
      update();
    } on CustomException catch (err) {
      loading.value = Loading.loaded;
      appSnackBar(data: err.message, color: AppColors.appRedColor);
    } catch (error, st) {
      loading.value = Loading.loaded;
      print(error.toString());
      print(st.toString());
      appSnackBar(
        data: 'Failed: ${error.toString()}',
        color: AppColors.appRedColor,
      );
    }
  }

  getCalendarLeaveList() async {
    try {
      loading.value = Loading.loading;
      ProfilePostData employeeData = ProfilePostData(
        employeeId: userData.user?.employeeId,
        companyId: userData.user?.companyId,
        clientId: userData.user?.clientId,
      );
      await managerProvider
          .getCalendarLeaveData(employeeData, fromDate.value!)
          .then((value) {
        final responseData = jsonDecode(value.body);
        if (responseData['success'] == true) {
          // Parse the new response format
          List<Map<String, String?>> todayLeavesList = [];

          if (responseData['data'] != null &&
              responseData['data']['leaves'] != null) {
            final List<dynamic> leaves = responseData['data']['leaves'];

            for (var leave in leaves) {
              String days = '0';
              if (leave["no_of_days"] != null) {
                // Convert to int to remove decimal, then back to string
                days = int.parse(
                  double.parse(leave["no_of_days"]).round().toString(),
                ).toString();
              }

              todayLeavesList.add({
                'empId': leave['employee_no'] ?? '',
                'name': leave['name'] ?? leave['first_name'] ?? '',
                'type': leave['plan_type_name'] ?? '',
                'days': days,
                // Additional fields if needed
                'employeeId': leave['employee_id'] ?? '',
                'date': leave['date'] ?? '',
                'reason': leave['leave_reason'] ?? '',
              });
            }
          }

          // Update selectedDayLeaves with the new data
          selectedDayLeaves = todayLeavesList;
          loading.value = Loading.loaded;
        } else {
          appSnackBar(
            data: responseData['message'] ?? 'Something went wrong',
            color: AppColors.textGreenColor,
          );
        }
      });
      update();
    } on CustomException catch (err) {
      loading.value = Loading.loaded;
      appSnackBar(data: err.message, color: AppColors.appRedColor);
    } catch (error, st) {
      loading.value = Loading.loaded;
      print(error.toString());
      print(st.toString());
      appSnackBar(
        data: 'Failed: ${error.toString()}',
        color: AppColors.appRedColor,
      );
    }
  }

  updateLeaveStatus(LeavesDetail leaveDetail, isApprove) async {
    try {
      loading.value = Loading.loading;
      LeaveActionPostData leaveData = LeaveActionPostData(
        leaveActionReason: reasonController.text,
        requestEmployeeId: int.parse(leaveDetail.employeeId ?? '0'),
        actionFlag: isApprove ? 'Approved' : 'Rejected',
        employeeId: int.parse(userData.user?.employeeId ?? '0'),
        companyId: userData.user?.companyId,
        leavePlanTypeId: int.parse(leaveDetail.leavePlanTypeId ?? '0'),
        employeeLeaveId: int.parse(leaveDetail.employeeLeaveId ?? '0'),
        noOfDays: leaveDetail.noOfDays,
        clientId: userData.user?.clientId,
      );
      await managerProvider.updateLeaveStatus(leaveData).then((value) async {
        final responseData = jsonDecode(value.body);
        if (responseData['success'] == true) {
          appSnackBar(
            data: responseData['data']['leaves'][0]['message'],
            color: AppColors.textGreenColor,
          );
          await getEmployeeLeaveList();
          loading.value = Loading.loaded;
        } else {
          appSnackBar(
            data: responseData['message'] ?? 'Something went wrong',
            color: AppColors.textGreenColor,
          );
        }
      });
      update();
    } on CustomException catch (err) {
      loading.value = Loading.loaded;
      appSnackBar(data: err.message, color: AppColors.appRedColor);
    } catch (error, st) {
      loading.value = Loading.loaded;
      print(error.toString());
      print(st.toString());
      appSnackBar(
        data: 'Failed: ${error.toString()}',
        color: AppColors.appRedColor,
      );
    }
  }

  Future<void> selectDate(BuildContext context, bool isFromDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isFromDate
          ? fromDate.value ?? DateTime.now().add(const Duration(days: 1))
          : fromDate.value,
      firstDate: isFromDate
          ? DateTime.now().add(const Duration(days: 1))
          : fromDate.value!,
      lastDate: DateTime(2026),
    );
    if (picked != null) {
      if (isFromDate) {
        fromDate.value = picked;
        toDate.value = picked;
      } else {
        toDate.value = picked;
      }
    }
  }

  Future<void> selectTime(
    BuildContext context,
    bool isFromDate,
    bool isStartTime,
  ) async {
    var appTheme = Get.find<ThemeController>().currentTheme;
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: fromDateStart.value ?? TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            timePickerTheme: TimePickerThemeData(
              dayPeriodTextColor: WidgetStateColor.resolveWith(
                (states) => states.contains(WidgetState.selected)
                    ? appTheme.white
                    : Colors.black,
              ),
              dayPeriodColor: WidgetStateColor.resolveWith(
                (states) => states.contains(WidgetState.selected)
                    ? appTheme.appColor
                    : Colors.grey.shade300,
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      if (isFromDate) {
        (isStartTime ? fromDateStart : fromDateEnd).value = picked;
      } else {
        (isStartTime ? toDateStart : toDateEnd).value = picked;
      }
    }
  }

  /// Convert TimeOfDay to a formatted string (HH:mm)
  String formatTimeOfDay(TimeOfDay time) {
    final now = DateTime.now();
    final dateTime = DateTime(
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );
    return DateFormat('HH:mm').format(dateTime); // 24-hour format
  }

  Future<UserData>? getUserData() async {
    const storage = FlutterSecureStorage();
    final String? userDataLocalStr = await storage.read(
      key: PrefStrings.userData,
    );
    focusNode.addListener(() {
      if (focusNode.hasFocus) {
        Future.delayed(const Duration(milliseconds: 300), () {
          scrollController.animateTo(
            scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        });
      }
    });
    if (userDataLocalStr != null) {
      final UserData userDataLocal = userDataFromJson(userDataLocalStr);
      userData = userDataLocal;
    }

    return userData;
  }

  List<Map<String, dynamic>> sortAttendance(List<dynamic> earningsData) {
    List<Map<String, dynamic>> earningsList = [];

    earningsList = earningsData
        .where((earning) => earning['data_type'] == 'list')
        .map<Map<String, dynamic>>(
          (earning) => {
            'leave_plan_type_name': earning['leave_plan_type_name'],
            'total_leave_days': earning['total_leave_days'],
            'taken_leave_days': earning['taken_leave_days'],
          },
        )
        .toList();

    earningsList.sort(
      (a, b) => double.parse(
        a['total_leave_days'],
      ).compareTo(double.parse(b['total_leave_days'])),
    );

    return earningsList;
  }

  void showAttendanceDetailsPopup(DateTime selectedDay, TimeCalendarModel calendarData) async {
    final popupData = await fetchTimePopupDetails(selectedDay);

    if (popupData != null) {
      // ── Shift details ───────────────────────────────────────────
      String startTime = 'N/A';
      String endTime = 'N/A';
      String breakTime = '00:00 HR';

      if (popupData.shiftTime?.isNotEmpty == true) {
        startTime = popupData.shiftTime!.first.allotedStart ?? 'N/A';
        endTime   = popupData.shiftTime!.first.allotedEnd   ?? 'N/A';
      }

      if (popupData.shiftBreak?.isNotEmpty == true) {
        int totalBreakMins = 0;
        for (final b in popupData.shiftBreak!) {
          if (b.breaksInMinutes != null) {
            final parts = b.breaksInMinutes!.split(':');
            if (parts.length == 2) {
              totalBreakMins += (int.tryParse(parts[0]) ?? 0) * 60
                  + (int.tryParse(parts[1]) ?? 0);
            }
          }
        }
        final bh = totalBreakMins ~/ 60;
        final bm = totalBreakMins % 60;
        breakTime = '${bh.toString().padLeft(2, '0')}:${bm.toString().padLeft(2, '0')} HR';
      }

      // ── Employee shift time ──────────────────────────────────────
      String status     = calendarData.status ?? 'Pending';
      String reason     = 'N/A';
      String empTimeId  = calendarData.empTimeId ?? '';
      String isRegularize = calendarData.isRegularize ?? '0';
      String employeeId = 'N/A';
      final formattedDate = DateFormat('yyyy-MM-dd').format(selectedDay);
      
      String allottedHours = '00:00 Hrs';
      String allottedStart = 'N/A';
      String allottedEnd = 'N/A';
      List<String> allottedBreaks = [];

      String actualHours = '00:00';
      String actualStart = 'N/A';
      String actualEnd = 'N/A';

      if (popupData.employeeShiftTime?.isNotEmpty == true) {
        final empTime = popupData.employeeShiftTime!.first;
        reason        = empTime.employeeRemark ?? 'N/A';
        status        = empTime.dayStatus ?? status;
        empTimeId     = empTime.empTimeId ?? empTimeId;
        isRegularize  = empTime.isRegularize ?? isRegularize;
        employeeId    = empTime.employeeNo ?? employeeId;

        if (empTime.workingHours != null) {
          actualHours = empTime.workingHours!;
        } else if (empTime.actualHours != null) {
          actualHours = empTime.actualHours!;
        }
        
        String inTime = empTime.modifyInTime ?? empTime.actualStart ?? 'N/A';
        actualStart = inTime;
        
        String outTime = empTime.modifyOutTime ?? empTime.actualEnd ?? 'N/A';
        actualEnd = outTime;
      }
      
      if (popupData.shiftTime?.isNotEmpty == true) {
        final shift = popupData.shiftTime!.first;
        allottedHours = '${shift.allotedHours ?? '00:00'} Hrs';
        allottedStart = shift.allotedStart ?? 'N/A';
        allottedEnd = shift.allotedEnd ?? 'N/A';
      }
      
      if (popupData.shiftBreak?.isNotEmpty == true) {
        for (var brk in popupData.shiftBreak!) {
          if (brk.breakStartTime != null && brk.breakEndTime != null) {
            allottedBreaks.add('${brk.breakStartTime} - ${brk.breakEndTime}');
          } else if (brk.breaksInMinutes != null) {
            allottedBreaks.add('${brk.breaksInMinutes} HR');
          }
        }
      }
      if (allottedBreaks.isEmpty) allottedBreaks.add('00:00');

      // ── Break hours ──────────────────────────────────────────────
      List<String> actualBreaks = [];
      if (popupData.employeeBreakTime?.isNotEmpty == true) {
        for (var brk in popupData.employeeBreakTime!) {
          if (brk.startBreak != null && brk.endBreak != null) {
            actualBreaks.add('${brk.startBreak} - ${brk.endBreak}');
          }
        }
      }
      
      if (actualBreaks.isEmpty) {
        String breakHrs = '00:00 hrs';
        if (popupData.employeeShiftTime?.isNotEmpty == true &&
            popupData.employeeShiftTime!.first.breakHours != null) {
          breakHrs = popupData.employeeShiftTime!.first.breakHours!;
        }
        actualBreaks.add(breakHrs);
      }

      String _formatStatusHelper(String st) {
        switch (st.toLowerCase()) {
          case 'half_day': return 'Half Day';
          case 'full_hours': return 'Full Hours';
          case 'short_hours': return 'Short Hours';
          case 'over_time': return 'Over Time';
          case 'overtime': return 'Over Time';
          case 'absent': return 'Absent';
          case 'present': return 'Present';
          case 'holiday': return 'Holiday';
          case 'regularize': return 'Regularize';
          case 'leave': return 'Leave';
          case 'weekend': return 'Weekend';
          default:
            return st.split('_').map((word) {
              if (word.isEmpty) return word;
              return word[0].toUpperCase() + word.substring(1);
            }).join(' ');
        }
      }

      // ── Show popup ───────────────────────────────────────────────
      final uiDate = DateFormat('dd-MMM-yyyy').format(selectedDay);
      Get.dialog(
        Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          insetPadding: EdgeInsets.all(0),
          child: AttendanceDetailsPopup(
            date:       uiDate,
            startTime:  startTime,
            endTime:    endTime,
            breakTime:  breakTime,
            allottedHours: allottedHours,
            allottedStart: allottedStart,
            allottedEnd:   allottedEnd,
            allottedBreaks: allottedBreaks,
            actualHours:   actualHours,
            actualStart:   actualStart,
            actualEnd:     actualEnd,
            actualBreaks:  actualBreaks,
            employeeId:    employeeId,
            reason:     reason,
            status:     _formatStatusHelper(status),
          ),
        ),
      );
    }
  }
}
