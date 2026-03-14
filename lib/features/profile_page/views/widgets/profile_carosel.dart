import 'package:flutter/material.dart';
import 'package:flutter_carousel_widget/flutter_carousel_widget.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:payroll/features/profile_page/views/controller/profile_page_controller.dart';
import 'package:payroll/routes/app_route.dart';
import 'package:sizer/sizer.dart';

import '../../../../theme/theme_controller.dart';
import '../../../homepage/views/widgets/notification_carosel.dart';

class ProfileCarousel extends GetView<ProfilePageController> {
  final RxInt _current = 0.obs;

    ProfileCarousel({super.key});

  @override
  Widget build(BuildContext context) {
    var appTheme = Get.find<ThemeController>().currentTheme;
    return Obx(() => Column(
          children: [
            FlutterCarousel(
              options: FlutterCarouselOptions(
                height: 45.h,
                viewportFraction: 0.9,
                enableInfiniteScroll: true,
                showIndicator: false,
                onPageChanged: (index, reason) {
                  _current.value = index;
                },
              ),
              items: controller.bannerData.keys.map((tabName) {
                List<Map<String, dynamic>> sectionList =
                    controller.bannerData[tabName]!;

                return Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      // Header (Sticky)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        width: double.infinity,
                        height: 5.h,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: appTheme.buttonGradient,
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Center(
                          child: Text(
                            tabName,
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w900,
                              color: appTheme.white,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 1.h),

                      // Scrollable Section
                      Expanded(
                        child: Stack(
                          children: [
                            sectionList.isEmpty
                                ? Text(
                                    "No Data Available for $tabName",
                                    textAlign: TextAlign.center,
                                    maxLines: 1,
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w900,
                                      color: appTheme.white,
                                    ),
                                  )
                                : SingleChildScrollView(
                                    physics: BouncingScrollPhysics(),
                                    child: Column(
                                      children: sectionList
                                          .map((item) => profileCarouselItem(
                                              item,
                                              isIdDocument:
                                                  tabName == 'ID Information'))
                                          .toList(),
                                    ),
                                  ),
                            if (tabName == 'ID Information')
                              Positioned(
                                bottom: 10,
                                left: 10,
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    Get.toNamed(AppRoutes.documentPage);
                                  },
                                  icon: Icon(Icons.add_circle_outline),
                                  label: Text("Add documents",style: TextStyle(fontWeight: FontWeight.w600),),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor:appTheme.appColor,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),

            // Carousel Dots
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: CustomCarouselIndicator(
                itemCount: controller.bannerData.keys.length,
                currentIndex: _current.value, activeColor: appTheme.appColor, inactiveColor: appTheme.appColor,
              ),
            ),
          ],
        ));
  }

}
void showDeleteConfirmationDialog(documentID,docName) {
  final ProfilePageController controller = Get.find<ProfilePageController>();
  showDialog(
    context: Get.context!,
    builder: (BuildContext context) {
      var appTheme = Get.find<ThemeController>().currentTheme;
      return AlertDialog(
        title: Text("Confirm Deletion",style:TextStyle(
            fontSize: 16.sp,
            color: appTheme.black87,
            fontWeight: FontWeight.bold
        ),),
        content: Text("Are you sure you want to delete the $docName document?"),
        actions: [
          TextButton(
            child: Text("No",style:TextStyle(
              fontSize: 14.sp,
              color: appTheme.black87,
            )),
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
            },
          ),
          TextButton(
            child: Text("Yes",style:TextStyle(
              fontSize: 14.sp,
              color: appTheme.black87,
            )),
            onPressed: () {
              Navigator.of(context).pop();
              controller.removeDocument(documentID);
            },
          ),
        ],
      );
    },
  );
}

Widget profileCarouselItem(Map<String, dynamic> item,
    {bool isIdDocument = false}) {
  var appTheme = Get.find<ThemeController>().currentTheme;
  return Padding(
    padding: const EdgeInsets.only(bottom: 8.0),
    child: GestureDetector(
      onTap: () {
        isIdDocument
            ? Get.toNamed(AppRoutes.documentPage, arguments: {
                'docID': item['employee_document_id'],
              })
            : null;
      },
      child: Container(
        padding: EdgeInsets.all(15),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: appTheme.popUp1Border,
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              spreadRadius: 2,
            )
          ],
        ),
        child: Column(
          children: item.entries
              .where((e) =>
                  e.key != 'tab_name' &&
                  e.key != 'img' &&
                  e.key != 'row_type' &&
                  e.key != 'document_type_id' &&
                  e.key != 'document_category' &&
                  e.key != 'file_name' &&
                  e.key != 'employee_document_id' &&
                  e.key != 'employee_family_id' &&
                  e.key != 'employee_id' &&
                  e.key != 'client_id' &&
                  e.key != 'relation_order' &&
                  e.key != 'employment_id' && e.key != 'profile_img' &&
                  e.key.isNotEmpty &&
                  ((e.key == 'document_path') ||
                      (e.value != null &&
                          e.value.toString().trim().isNotEmpty)))
              .map<Widget>((entry) => buildInfoRow(
                    entry.key.replaceAll('_', ' ').toUpperCase(),
                    entry.value.toString(),
                    isIdDocument: isIdDocument,
                    docID: item['employee_document_id'] ?? '',
                  ))
              .toList(),
        ),
      ),
    ),
  );
}

Widget buildInfoRow(String label, String value,
    {bool isIdDocument = false, String docID = ""}) {
  var appTheme = Get.find<ThemeController>().currentTheme;
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 5),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.bold,
              color: appTheme.black54,
            ),
            overflow: TextOverflow.ellipsis, // Prevents overflow issues
          ),
        ),
        Expanded(
          flex: 2, // Gives more space to value
          child: isIdDocument && label == "DOCUMENT PATH" && value == "null"
              ? Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                      onTap: () {
                        Get.toNamed(AppRoutes.documentPage, arguments: {
                          'docID': docID,
                        });
                      },
                      child: Icon(Icons.cloud_upload_outlined,size:18.sp,color: appTheme.appColor,)),
                )
              : isIdDocument && label == "DOCUMENT TYPE"
                  ? Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        value,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: appTheme.black87,
                        ),
                        textAlign: TextAlign.right,
                        overflow:
                        TextOverflow.ellipsis, // Prevents overflow issues
                      ),

                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: GestureDetector(
                            onTap: () {
                              Get.toNamed(AppRoutes.documentPage, arguments: {
                                'docID': docID,
                              });
                            },
                            child: FaIcon(FontAwesomeIcons.penToSquare,size:18.sp,color: appTheme.appColor,)),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: GestureDetector(
                            onTap: () {
                              showDeleteConfirmationDialog(docID,value);
                            },
                            child: Icon(Icons.delete_forever_outlined,size:20.sp,color: appTheme.red,)),
                      ),
                    ],
                  )
                  : Text(
                      value,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: appTheme.black87,
                      ),
                      textAlign: TextAlign.right,
                      overflow:
                          TextOverflow.ellipsis, // Prevents overflow issues
                    ),
        ),
      ],
    ),
  );
}
