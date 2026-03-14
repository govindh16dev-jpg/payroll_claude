import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:payroll/features/document_page/views/controller/document_page_controller.dart';
import 'package:sizer/sizer.dart';

import '../../../config/constants.dart';
import '../../../theme/theme_controller.dart';
import '../../../util/common/bottom_nav.dart';
import '../../../util/common/drawer.dart';
import '../../../util/custom_widgets.dart';

class DocumentPage extends GetView<DocumentPageController> {
    DocumentPage({super.key});
  var appTheme = Get.find<ThemeController>().currentTheme;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
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
              controller: controller.scrollController,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Obx(()=> CustomHeader(
                      title:controller.isEditingDoc.value?'Update Document' :'Add Document',
                    ),),
                    SizedBox(
                      height: 4.h,
                    ),
                    documentSelection("Document Type", context,
                        isMandatory: true),
                    textField(
                        "Name on Document",
                        isMandatory: true,
                        context,
                        controller.nameController,
                        controller.nameFocusNode),
                    textField(
                        "Document No",
                        isMandatory: true,
                        context,
                        controller.docNoController,
                        controller.docNoFocusNode),
                    _buildRowDateSelect("Issue Date", context,
                        isIssueDate: true),
                    textField("Issue Place", context,
                        controller.placeController, controller.placeFocusNode),
                    _buildRowDateSelect(
                        "Valid From", isValidFrom: true, context),
                    _buildRowDateSelect("Valid To", isValidTo: true, context),
                    _buildRowFileSelect(
                        "Upload File/Take a Picture Data", context),
                    SizedBox(height: 3.h),
                    Obx(()=> Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if(controller.isEditingDoc.value)Center(
                          child: Container(
                            width: 35.w,
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
                              onPressed: () {
                                controller.fetchDocPdf();
                              },
                              child: Text(
                                "Download",
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w900,
                                  color: appTheme.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                        if(controller.isEditingDoc.value)SizedBox(width: 3.h),
                        Center(
                          child: Container(
                            width: 35.w,
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
                              onPressed: () {
                                controller.submitDocument();
                              },
                              child: Text(
                                controller.documentID==null?"Submit":"Update",
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w900,
                                  color: appTheme.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),),
                    SizedBox(
                      height: 40.h,
                    ),
                  ],
                ),
              ),
            ),
            Obx(
              () => Visibility(
                  visible: controller.loading.value == Loading.loading,
                  child: loadingIndicator()),
            )
          ],
        ),
        floatingActionButton: CustomBottomNaviBar(),
        floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      );
  }

  Widget _buildRowDateSelect(String label, BuildContext context,
      {bool isMandatory = false,
      bool isValidFrom = false,
      bool isValidTo = false,
      bool isIssueDate = false}) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
              width: controller.labelWidth,
              child: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: label,
                      style: TextStyle(
                          color: appTheme.darkGrey,
                          fontWeight: FontWeight.bold),
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
              )),
          SizedBox(
            width: 2.w,
          ),
          GestureDetector(
            onTap: (){
              controller.selectDate(
                  context,
                  isValidFrom,
                  isValidTo,
                  isIssueDate);
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  width: controller.inputWidth,
                  child: CustomPaint(
                    painter: DottedBorderPainter(),
                    child: Align(
                        alignment: Alignment.center,
                        child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 0),
                            height: 4.h,
                            alignment: Alignment.centerLeft,
                            child: Obx(() => TextField(
                                  readOnly: true,
                                  textAlign: TextAlign.start,
                                  decoration: InputDecoration(
                                      border: InputBorder.none,
                                    contentPadding:
                                    EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                      hintStyle: TextStyle(fontSize: 16.sp),
                                      hintText: isIssueDate
                                          ? controller.issueDate.value != null
                                              ? DateFormat('dd/MM/yyyy')
                                                  .format(controller.issueDate.value!)
                                              : 'Select Date'
                                          : isValidFrom
                                              ? controller.validFrom.value != null
                                                  ? DateFormat('dd/MM/yyyy').format(
                                                      controller.validFrom.value!)
                                                  : 'Select Date'
                                              : controller.validTo.value != null
                                                  ? DateFormat('dd/MM/yyyy').format(
                                                      controller.validTo.value!)
                                                  : 'Select Date',
                                      fillColor: appTheme.greyBox,
                                )))),
                  ),
                ),),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: Icon(
                    Icons.calendar_month,
                    color: appTheme.appThemeLight,
                    size: 22.sp,
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildRowFileSelect(String label, BuildContext context,
      ) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
              width: controller.labelWidth,
              child: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: label,
                      style: TextStyle(
                          color: appTheme.darkGrey,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              )),
          SizedBox(
            width: 2.w,
          ),
          GestureDetector(
            onTap: (){
              controller.pickFromCamera();
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  width: controller.inputWidth,
                  child: CustomPaint(
                    painter: DottedBorderPainter(),
                    child: Align(
                      alignment: Alignment.center,
                      child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 0),
                          height: 4.h,
                          alignment: Alignment.centerLeft,
                          child: Obx(() => TextField(
                              readOnly: true,
                              textAlign: TextAlign.start,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                contentPadding:
                                EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                hintStyle: TextStyle(fontSize: 16.sp),
                                hintText:controller.imageName.value??"Select Image"
                              )))),
                    ),
                  ),),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: Icon(
                    Icons.camera_enhance,
                    color: appTheme.appThemeLight,
                    size: 22.sp,
                  ),
                )
              ],
            ),
          ),
          GestureDetector(
            onTap: (){
              controller.pickAnyFile();
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2.0),
              child: Icon(
                Icons.cloud_upload_outlined,
                color: appTheme.appThemeLight,
                size: 22.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget documentSelection(
    String label,
    BuildContext context, {
    bool isMandatory = false,
    bool isFilled = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 16.0),
      child: SizedBox(
        height: 4.h,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
                width: controller.labelWidth,
                child: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: label,
                        style: TextStyle(
                            color: appTheme.darkGrey,
                            fontWeight: FontWeight.bold),
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
                )),
            SizedBox(
              width: 2.w,
            ),
          _buildDropdown(context)
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown(context) {
    return GestureDetector(
      onTap: () {
        _buildDropdownScroll(context);
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            width: controller.inputWidth,
            child: CustomPaint(
              painter: DottedBorderPainter(),
              child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  height: 4.h,
                  alignment: Alignment.centerLeft,
                  child: Obx(
                        () => SizedBox(
                      width: 30.w,
                      child: Text(
                        overflow: TextOverflow.ellipsis,
                        controller.selectedDocumentType.value.documentType
                            ?.replaceAll("_", " ") ??
                            'Select Document Type',
                        style: TextStyle(fontSize: 16.sp),
                      ),
                    ),
                  )),
            ),
          ),
          arrowIconDown()
        ],
      ),
    );
  }

  Widget textField(
    String label,
    BuildContext context,
    TextEditingController textController,
    FocusNode focusNode, {
    bool isMandatory = false,
    bool isFilled = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 16.0),
      child: SizedBox(
        height: 4.h,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
                width: controller.labelWidth,
                child: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: label,
                        style: TextStyle(
                            color: appTheme.darkGrey,
                            fontWeight: FontWeight.bold),
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
                )),
            SizedBox(
              width: 2.w,
            ),
            SizedBox(
              width: controller.inputWidth,
              child: CustomPaint(
                painter: DottedBorderPainter(),
                child: Align(
                  alignment: Alignment.center,
                  child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 0),
                      alignment: Alignment.centerLeft,
                      child: TextField(
                        maxLines: 1,
                        controller: textController,
                        focusNode: focusNode,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                          hintStyle: TextStyle(fontSize: 16.sp),
                          hintText: 'Enter $label',
                          fillColor: appTheme.greyBox,
                        ),
                      )),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget arrowIconDown(){
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Container(
        width: 7.w,
        height: 7.h,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: appTheme.appColor, // Background color
        ),
        child: Center(
          child: FaIcon(
            FontAwesomeIcons.angleDown, // FontAwesome down-arrow icon
            color: Colors.white,
            size: 16.sp,
          ),
        ),
      ),
    );
  }

    _buildDropdownScroll(BuildContext context) {
      final appTheme = Get.find<ThemeController>().currentTheme;

      // Safely get the list
      final docList = controller.documentTypeDropdown ?? [];

      // Find the initial index based on currently selectedDocumentType
      final initialIndex = docList.indexWhere(
            (item) => item.documentTypeId == controller.selectedDocumentTypeID.value,
      );

      final scrollController = FixedExtentScrollController(
        initialItem: initialIndex >= 0 ? initialIndex : 0,
      );

      return showCupertinoModalPopup(
        context: context,
        builder: (_) => Container(
          height: 30.h,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: appTheme.darkGrey,
          ),
          child: Column(
            children: [
              // Done Button
              Container(
                height: 5.h,
                color: Colors.white,
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Done',
                    style: TextStyle(fontSize: 18.sp),
                  ),
                ),
              ),
              Expanded(
                child: CupertinoPicker(
                  backgroundColor: Colors.white,
                  itemExtent: 40,
                  scrollController: scrollController,
                  onSelectedItemChanged: (int index) {
                    final selectedDocType = docList[index];
                    controller.selectedDocumentTypeID.value =
                    selectedDocType.documentTypeId!;
                    controller.selectedDocumentType.value = selectedDocType;
                  },
                  children: docList
                      .map(
                        (leave) => Center(
                      child: Text(
                        leave.documentType?.replaceAll("_", " ") ?? '',
                      ),
                    ),
                  )
                      .toList(),
                ),
              ),
            ],
          ),
        ),
      );
    }

}
