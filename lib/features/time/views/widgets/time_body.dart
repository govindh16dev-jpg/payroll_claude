//
// Widget _buildTimeTrackingBody() {
//   return Container(
//     decoration: BoxDecoration(
//       gradient: LinearGradient(
//         colors: appTheme.popUp2Border, // Using existing gradient from theme
//         begin: Alignment.topCenter,
//         end: Alignment.bottomCenter,
//       ),
//       borderRadius: BorderRadius.circular(20),
//     ),
//     margin: EdgeInsets.symmetric(horizontal: 2.w, vertical: 2.h),
//     child: Container(
//       margin: EdgeInsets.all(3), // Inner margin for gradient border effect
//       decoration: BoxDecoration(
//         color: appTheme.white,
//         borderRadius: BorderRadius.circular(17),
//       ),
//       padding: EdgeInsets.all(4.w),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           _buildActiveStatus(),
//           SizedBox(height: 3.h),
//           _buildToggleSwitch(),
//           SizedBox(height: 4.h),
//           _buildTimeRecordSection(),
//           SizedBox(height: 4.h),
//           _buildClockInButton(),
//           SizedBox(height: 3.h),
//           _buildLocationInfo(),
//           SizedBox(height: 4.h),
//           _buildWeeklyStats(),
//           SizedBox(height: 3.h),
//           _buildMonthlyStats(),
//         ],
//       ),
//     ),
//   );
// }
//
// Widget _buildActiveStatus() {
//   return Row(
//     children: [
//       Container(
//         width: 3.w,
//         height: 3.w,
//         decoration: BoxDecoration(
//           color: Colors.green,
//           shape: BoxShape.circle,
//         ),
//       ),
//       SizedBox(width: 2.w),
//       Text(
//         'Active',
//         style: TextStyle(
//           fontSize: 14.sp,
//           fontWeight: FontWeight.w500,
//           color: appTheme.darkGrey,
//         ),
//       ),
//     ],
//   );
// }
//
// Widget _buildToggleSwitch() {
//   return Row(
//     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//     children: [
//       Text(
//         'Manager',
//         style: TextStyle(
//           fontSize: 14.sp,
//           color: appTheme.darkGrey,
//         ),
//       ),
//       Obx(() => Container(
//         width: 15.w,
//         height: 4.h,
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             colors: controller.isManager.value
//                 ? appTheme.buttonGradient
//                 : [Colors.grey.shade300, Colors.grey.shade400],
//           ),
//           borderRadius: BorderRadius.circular(20),
//         ),
//         child: Switch(
//           value: controller.isManager.value,
//           onChanged: (value) => controller.isManager.value = value,
//           activeColor: Colors.transparent,
//           inactiveThumbColor: Colors.white,
//           activeTrackColor: Colors.transparent,
//           inactiveTrackColor: Colors.transparent,
//         ),
//       )),
//       Text(
//         'Employee',
//         style: TextStyle(
//           fontSize: 14.sp,
//           color: appTheme.darkGrey,
//         ),
//       ),
//     ],
//   );
// }
//
// Widget _buildTimeRecordSection() {
//   return Column(
//     crossAxisAlignment: CrossAxisAlignment.start,
//     children: [
//       Text(
//         'Record your Time',
//         style: TextStyle(
//           fontSize: 18.sp,
//           fontWeight: FontWeight.bold,
//           color: appTheme.darkGrey,
//         ),
//       ),
//       SizedBox(height: 1.h),
//       Text(
//         '9:00 AM to 5:30 PM (Regular shift)',
//         style: TextStyle(
//           fontSize: 12.sp,
//           color: appTheme.darkGrey,
//         ),
//       ),
//       SizedBox(height: 2.h),
//       Text(
//         'Oh 00m Today',
//         style: TextStyle(
//           fontSize: 24.sp,
//           fontWeight: FontWeight.bold,
//           color: appTheme.darkGrey,
//         ),
//       ),
//     ],
//   );
// }
//
// Widget _buildClockInButton() {
//   return Center(
//     child: Container(
//       width: 40.w,
//       height: 6.h,
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           colors: appTheme.buttonGradient,
//           begin: Alignment.centerLeft,
//           end: Alignment.centerRight,
//         ),
//         borderRadius: BorderRadius.circular(30),
//       ),
//       child: ElevatedButton(
//         style: ElevatedButton.styleFrom(
//           backgroundColor: Colors.transparent,
//           shadowColor: Colors.transparent,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(30),
//           ),
//         ),
//         onPressed: () {
//           // Handle clock in/out logic
//           controller.toggleClockInOut();
//         },
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(
//               Icons.access_time,
//               color: appTheme.white,
//               size: 18.sp,
//             ),
//             SizedBox(width: 2.w),
//             Obx(() => Text(
//               controller.isClockedIn.value ? 'Clock Out' : 'Clock In',
//               style: TextStyle(
//                 fontSize: 16.sp,
//                 fontWeight: FontWeight.bold,
//                 color: appTheme.white,
//               ),
//             )),
//           ],
//         ),
//       ),
//     ),
//   );
// }
//
// Widget _buildLocationInfo() {
//   return Row(
//     children: [
//       Icon(
//         Icons.location_pin,
//         color: Colors.purple,
//         size: 18.sp,
//       ),
//       SizedBox(width: 2.w),
//       Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             'Clocked Out: Nov 5 at 7:30 PM',
//             style: TextStyle(
//               fontSize: 12.sp,
//               color: appTheme.darkGrey,
//             ),
//           ),
//           Text(
//             'Location: Perungudi, Chennai, IN',
//             style: TextStyle(
//               fontSize: 12.sp,
//               color: appTheme.darkGrey,
//             ),
//           ),
//         ],
//       ),
//     ],
//   );
// }
//
// Widget _buildWeeklyStats() {
//   return Column(
//     crossAxisAlignment: CrossAxisAlignment.start,
//     children: [
//       Text(
//         'This Week',
//         style: TextStyle(
//           fontSize: 16.sp,
//           fontWeight: FontWeight.bold,
//           color: appTheme.darkGrey,
//         ),
//       ),
//       SizedBox(height: 1.h),
//       Row(
//         mainAxisAlignment: MainAxisAlignment.spaceAround,
//         children: [
//           _buildStatItem('43h 52m', 'Worked hours'),
//           _buildStatItem('01h 08m', 'Short hours'),
//           _buildStatItem('01h 08m', 'Over Time'),
//         ],
//       ),
//     ],
//   );
// }
//
// Widget _buildMonthlyStats() {
//   return Column(
//     crossAxisAlignment: CrossAxisAlignment.start,
//     children: [
//       Text(
//         'This Month',
//         style: TextStyle(
//           fontSize: 16.sp,
//           fontWeight: FontWeight.bold,
//           color: appTheme.darkGrey,
//         ),
//       ),
//       SizedBox(height: 1.h),
//       Row(
//         mainAxisAlignment: MainAxisAlignment.spaceAround,
//         children: [
//           _buildStatItem('168h 52m', 'Worked hours'),
//           _buildStatItem('06h 08m', 'Short hours'),
//           _buildStatItem('01h 08m', 'Over Time'),
//         ],
//       ),
//     ],
//   );
// }
//
// Widget _buildStatItem(String value, String label) {
//   Color textColor;
//   if (label.contains('Short') || label.contains('Over')) {
//     textColor = Colors.red;
//   } else {
//     textColor = Colors.purple;
//   }
//
//   return Column(
//     children: [
//       Text(
//         value,
//         style: TextStyle(
//           fontSize: 14.sp,
//           fontWeight: FontWeight.bold,
//           color: textColor,
//         ),
//       ),
//       SizedBox(height: 0.5.h),
//       Text(
//         label,
//         style: TextStyle(
//           fontSize: 10.sp,
//           color: appTheme.darkGrey,
//         ),
//         textAlign: TextAlign.center,
//       ),
//     ],
//   );
// }
