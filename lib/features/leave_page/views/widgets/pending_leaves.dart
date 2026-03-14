// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:google_fonts/google_fonts.dart';
//
// import '../../../../routes/app_pages.dart';
// import '../../controller/time_page_controller.dart';
// import '../../model/leave_model.dart';
//
// class PendingLeavesCard extends GetView<LeavePageController>  {
//   const PendingLeavesCard({super.key, required this.leave});
//
//   final LeaveData leave;
// Widget leaveRow(title,data){
//   return   Padding(
//     padding: const EdgeInsets.all(8.0),
//     child: Row(
//       mainAxisAlignment:
//       MainAxisAlignment.spaceBetween,
//       children: [
//         Text(
//           title,
//           style: GoogleFonts.getFont(
//             'Poppins',
//             fontWeight: FontWeight.w400,
//             fontSize: 14,
//             color: AppColors.primaryAppColor,
//           ),
//         ),
//         Text(
//        data,
//           style: GoogleFonts.getFont(
//             'Poppins',
//             fontWeight: FontWeight.w600,
//             fontSize: 14,
//             color: AppColors.primaryAppColor,
//           ),
//         ),
//       ],
//     ),
//   );
// }
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.all( 8.0),
//       child: Card(
//         color: AppColors.cardBG,
//         child: Column(
//           mainAxisSize: MainAxisSize.max,
//           mainAxisAlignment: MainAxisAlignment.start,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Align(
//               alignment: Alignment.topRight,
//               child:   Padding(
//                 padding: const EdgeInsets.all(8.0),
//                 child: Container(
//                   decoration: BoxDecoration(
//                     color: leave.leaveStatus == 'Pending'
//                         ? AppColors.appRedColor
//                         : AppColors.textGreenColor,
//                     borderRadius: BorderRadius.circular(5),
//                   ),
//                   child: Container(
//                     padding: const EdgeInsets.fromLTRB(8, 0, 8.1, 0),
//                     child: Text(
//                       leave.leaveStatus ?? 'Completed',
//                       style: GoogleFonts.getFont(
//                         'Poppins',
//                         fontWeight: FontWeight.w600,
//                         fontSize: 10,
//                         height: 2.6,
//                         letterSpacing: 0.1,
//                         color: AppColors.whiteColor,
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//             // leaveRow('Applied On',    dateTimeToString(
//             //     leave.appliedDate??DateTime.now(),
//             //     format: "dd-MM-yyyy hh:mm:a"),),
//             leaveRow('Leave Date', leave.fromDate??'',),
//             leaveRow('No of Days', leave.noOfDays,),
//             leaveRow('Leave Reason', leave.leaveReason,),
//           ],
//         ),
//       ),
//     );
//   }
// }