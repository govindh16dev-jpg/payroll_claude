import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';

import '../../../config/constants.dart';
import '../../../theme/theme_controller.dart';
import '../../../util/common/bottom_nav.dart';
import '../../../util/common/drawer.dart';
import '../../../util/custom_widgets.dart';
import '../controller/time_page_controller.dart';
import '../../leave_page/views/apply_leave_page.dart';
import '../data/time_model.dart';

class RegularizePage extends StatefulWidget {
  RegularizePage({super.key});

  @override
  State<RegularizePage> createState() => _RegularizePageState();
}

class _RegularizePageState extends State<RegularizePage> {
  final controller = Get.find<TimePageController>();

  var appTheme = Get.find<ThemeController>().currentTheme;

  @override
  void initState() {
    super.initState();

    // ✅ Read the date passed from calendar tap
    final args = Get.arguments as Map<String, dynamic>?;
    final DateTime? passedDate = args?['date'] as DateTime?;
    final TimeCalendarModel? calendarData = args?['data'] as TimeCalendarModel?;

    // ✅ Initialize fields with the selected date and popup data
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (passedDate != null) {
        // First set the date text immediately
        controller.regularizeSelectedDate.value = passedDate;
        controller.regularizeDateController.text =
            DateFormat('dd/MM/yyyy').format(passedDate);

        // Then fetch popup data to pre-fill clocked in/out and breaks
        final popupData = await controller.fetchTimePopupDetails(passedDate);
        controller.initRegularizeData(passedDate, popupData: popupData);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    appTheme = Get.find<ThemeController>().currentTheme;


    return Scaffold(
      resizeToAvoidBottomInset: true,
      drawer: CustomDrawer(),
      drawerEnableOpenDragGesture: false,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(5.h),
        child: AppBar(
          leading: Padding(
            padding: const EdgeInsets.only(left: 20.0),
            child: Builder(
              builder: (context) => IconButton(
                onPressed: () => Scaffold.of(context).openDrawer(),
                icon: FaIcon(FontAwesomeIcons.ellipsis,
                    size: 22.sp, color: appTheme.appThemeLight),
              ),
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 20.0),
              child: Align(
                alignment: Alignment.topRight,
                child: Image.asset('assets/logos/app_icon.png'),
              ),
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomHeader(title: 'Regularize'),
                  SizedBox(height: 1.h),
                  // Apply Leave button aligned to the right
                  Align(
                    alignment: Alignment.centerRight,
                    child: _buildApplyLeaveButton(),
                  ),
                  SizedBox(height: 2.h),

                  _buildRowField("Date", controller.regularizeDateController,
                      isReadOnly: true,
                      hasIcon: true,
                      icon: Icons.info_outline,
                      onTap: () {
                        final args = Get.arguments as Map<String, dynamic>?;
                        final calendarData = args?['data'] as TimeCalendarModel?;
                        if (controller.regularizeSelectedDate.value != null && calendarData != null) {
                          controller.showAttendanceDetailsPopup(controller.regularizeSelectedDate.value!, calendarData);
                        }
                      }
                  ),
                  _buildRowField("Clocked In", controller.regularizeClockInController,
                      hasIcon: true,
                      icon: Icons.access_time_rounded,
                      onTap: () => controller.selectRegularizeTime(context, 'clockIn')),
                  _buildRowField("Clocked Out", controller.regularizeClockOutController,
                      hasIcon: true,
                      icon: Icons.access_time_rounded,
                      onTap: () => controller.selectRegularizeTime(context, 'clockOut')),
                  Obx(() {
                    List<Widget> breakWidgets = [];
                    for (int i = 0; i < controller.regularizeBreakData.length; i++) {
                      final breakLabel = 'Break ${i + 1}';
                      
                      breakWidgets.add(
                       Padding(
                         padding: const EdgeInsets.only(bottom: 8.0),
                         child: Row(
                           crossAxisAlignment: CrossAxisAlignment.center,
                           children: [
                             SizedBox(
                               width: 25.w,
                               child: Padding(
                                 padding: const EdgeInsets.only(left: 8.0),
                                 child: Text(
                                   breakLabel,
                                   style: TextStyle(
                                     color: appTheme.darkGrey,
                                     fontWeight: FontWeight.bold,
                                   ),
                                 ),
                               ),
                             ),
                             SizedBox(width: 2.w),
                             // Start Break Input
                             _buildTimeBox(
                               controller.regularizeBreakStartControllers.length > i 
                                   ? controller.regularizeBreakStartControllers[i] 
                                   : TextEditingController(),
                               () => controller.selectRegularizeTime(context, 'break', index: i, isStart: true),
                             ),
                             SizedBox(width: 2.w),
                             Text("to", style: TextStyle(color: appTheme.darkGrey)),
                             SizedBox(width: 2.w),
                             // End Break Input
                             _buildTimeBox(
                               controller.regularizeBreakEndControllers.length > i 
                                   ? controller.regularizeBreakEndControllers[i] 
                                   : TextEditingController(),
                               () => controller.selectRegularizeTime(context, 'break', index: i, isStart: false),
                             ),
                             SizedBox(width: 2.w),
                             GestureDetector(
                               onTap: () => controller.selectRegularizeTime(context, 'break', index: i, isStart: false),
                               child: Icon(
                                 Icons.access_time_rounded,
                                 color: appTheme.appThemeLight,
                                 size: 22.sp,
                               ),
                             ),
                           ],
                         ),
                       )
                      );
                    }
                    return Column(children: breakWidgets);
                  }),
                  _buildRowField("Reason", controller.regularizeReasonController,
                      isReason: true,
                      isMandatory: true),

                  SizedBox(height: 3.h),
                  _buildActionButton(context),
                  SizedBox(height: 15.h),
                ],
              ),
            ),
          ),
          Obx(() => Visibility(
            visible: controller.loading.value == Loading.loading,
            child: loadingIndicator(),
          )),
        ],
      ),
      floatingActionButton: CustomBottomNaviBar(),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
    );
  }

  Widget _buildRowField(
      String label,
      TextEditingController textController, {
        bool isReadOnly = false,
        bool hasIcon = false,
        IconData? icon,
        bool isReason = false,
        bool isMandatory = false,
        double? width,
        VoidCallback? onTap,
      }) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 16.0),
      child: Row(
        crossAxisAlignment: isReason ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 25.w,
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: label,
                    style: TextStyle(
                      color: appTheme.darkGrey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (isMandatory)
                    TextSpan(
                      text: " *",
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                ],
              ),
            ),
          ),
          SizedBox(width: 2.w),
          if (isReason)
            Expanded(
              child: CustomPaint(
                painter: DottedBorderPainter(),
                child: TextField(
                  controller: textController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    hintStyle: TextStyle(fontSize: 16.sp),
                    hintText: 'Type in the reason',
                  ),
                ),
              ),
            )
          else
            Row(
              children: [
                GestureDetector(
                  onTap: onTap,
                  child: SizedBox(
                    width: width != null ? width.w : 40.w,
                    child: CustomPaint(
                      painter: DottedBorderPainter(),
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        height: 4.h,
                        alignment: Alignment.centerLeft,
                        child: AbsorbPointer(
                          child: TextField(
                            controller: textController,
                            readOnly: true,
                            textAlign: width != null ? TextAlign.center : TextAlign.start,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(vertical: 8),
                              hintStyle: TextStyle(fontSize: 16.sp),
                              hintText: label == "Date" ? 'dd/mm/yyyy' : '00:00:00',
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                if (hasIcon)
                  GestureDetector(
                    onTap: onTap,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 10.0),
                      child: Icon(
                        icon,
                        color: appTheme.appThemeLight,
                        size: 22.sp,
                      ),
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildTimeBox(TextEditingController controller, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 20.w,
        child: CustomPaint(
          painter: DottedBorderPainter(),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 4),
            height: 4.h,
            alignment: Alignment.center,
            child: AbsorbPointer(
              child: TextField(
                controller: controller,
                readOnly: true,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14.sp),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                  isDense: true,
                  hintStyle: TextStyle(fontSize: 12.sp),
                  hintText: '00:00',
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildApplyLeaveButton() {
    return Container(
      width: 30.w,
      height: 5.h,
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
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
        ),
        onPressed: () {
          // Navigate to ApplyLeavePage with date data
          Get.to(
            () => ApplyLeavePage(),
            arguments: {
              'date': controller.regularizeSelectedDate.value,
            },
          );
        },
        child: Text(
          "Apply Leave",
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w900,
            color: appTheme.white,
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(BuildContext context) {
    return Center(
      child: Container(
        width: 40.w,
        height: 5.h,
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
          onPressed: () => controller.submitRegularize(),
          child: Text(
            "Regularize",
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w900,
              color: appTheme.white,
            ),
          ),
        ),
      ),
    );
  }
}
