// ignore_for_file: library_private_types_in_public_api

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sizer/sizer.dart';

import '../../../theme/theme_controller.dart';
import '../../../util/common/bottom_nav.dart';
import '../../../util/common/drawer.dart';
import '../../../util/custom_widgets.dart';
import '../controller/route_history_controller.dart';

class RouteHistoryPage extends GetView<RouteHistoryController> {
  const RouteHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    var appTheme = Get.find<ThemeController>().currentTheme;

    return Scaffold(
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
                icon: FaIcon(FontAwesomeIcons.ellipsis),
                iconSize: 22.sp,
                color: appTheme.appThemeLight,
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            children: [
              CustomHeader(
                title: 'Route History',
              ),
              SizedBox(height: 2.h),

              // Date selector
              _buildDateSelector(context, appTheme),
              SizedBox(height: 2.h),

              // Map view
              _buildMapView(appTheme),
              SizedBox(height: 2.h),

              // Route details cards
              _buildRouteDetails(appTheme),
              SizedBox(height: 10.h),
            ],
          ),
        ),
      ),
      floatingActionButton: CustomBottomNaviBar(),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
    );
  }

  Widget _buildDateSelector(BuildContext context, dynamic appTheme) {
    return Row(
      children: [
        Container(
          width: 25.w,
          padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: appTheme.buttonGradient,
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(50),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Select Date',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w900,
                  color: appTheme.white,
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: 1.w),
        GestureDetector(
          onTap: () => controller.selectDate(context),
          child: Container(
            width: 45.w,
            padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
            decoration: BoxDecoration(
              border: Border.all(color: appTheme.appColor, width: 1.5),
              borderRadius: BorderRadius.circular(50),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Obx(() => Text(
                      // ✅ Now observes controller.dateText
                      controller
                          .dateText.value, // Changed from dateController.text
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: appTheme.darkGrey,
                      ),
                    )),
              ],
            ),
          ),
        ),
        SizedBox(width: 3.w),
        GestureDetector(
          onTap: () => controller.selectDate(context),
          child: Icon(
            Icons.calendar_month,
            color: appTheme.appColor,
            size: 22.sp,
          ),
        ),
      ],
    );
  }

  Widget _buildMapView(dynamic appTheme) {
    return Container(
      height: 35.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: appTheme.appColor, width: 3),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Obx(
          () {
            if (controller.isLoading.value) {
              return Center(
                child: CircularProgressIndicator(color: appTheme.appColor),
              );
            }
            return GoogleMap(
              onMapCreated: controller.onMapCreated,
              initialCameraPosition: CameraPosition(
                target: controller.routePoints.isNotEmpty 
                    ? controller.routePoints.first.latLng 
                    : LatLng(12.9260, 80.1685),
                zoom: 11.5,
              ),
              markers: controller.markers.toSet(),
              polylines: controller.polylines.toSet(),
              myLocationEnabled: false,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: true, // Enable zoom controls
              zoomGesturesEnabled: true, // Enable pinch to zoom
              scrollGesturesEnabled: true, // Enable pan
              tiltGesturesEnabled: true, // Enable tilt
              rotateGesturesEnabled: true, // Enable rotate
              mapToolbarEnabled: false,
              compassEnabled: true,
            );
          }
        ),
      ),
    );
  }

  Widget _buildRouteDetails(dynamic appTheme) {
    return Container(
      padding: EdgeInsets.all(1.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: appTheme.popUp1Border),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: EdgeInsets.all(3.w),
        decoration: BoxDecoration(
          color: appTheme.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Obx(() {
          if (controller.isLoading.value) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(4.h),
                child: CircularProgressIndicator(color: appTheme.appColor),
              ),
            );
          }
          if (controller.routePoints.isEmpty) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(4.h),
                child: Text(
                  "No routes found for this date",
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: appTheme.darkGrey,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            );
          }
          return Column(
            children: [
              // Header row
              Padding(
                padding: EdgeInsets.symmetric(vertical: 1.h),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        'Route #',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                          color: appTheme.darkGrey,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        'GPS Location',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                          color: appTheme.darkGrey,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        'Time',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                          color: appTheme.darkGrey,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        'Photo',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                          color: appTheme.darkGrey,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Divider(color: appTheme.appColor, thickness: 1),

              // Route items
              ListView.separated(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: controller.routePoints.length,
                separatorBuilder: (context, index) => Divider(
                  color: appTheme.appColor.withOpacity(0.3),
                  thickness: 0.5,
                ),
                itemBuilder: (context, index) {
                  final point = controller.routePoints[index];
                  return _buildRouteItem(point, appTheme);
                },
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildRouteItem(RoutePoint point, dynamic appTheme) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 1.h),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              point.name,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: appTheme.darkGrey,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              point.address,
              style: TextStyle(
                fontSize: 12.sp,
                color: appTheme.darkGrey,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              point.time,
              style: TextStyle(
                fontSize: 12.sp,
                color: appTheme.darkGrey,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Photo thumbnail - TAP TO OPEN FULL IMAGE
                GestureDetector(
                  onTap: () {
                    if (point.imageBytes != null || point.imageFile != null || point.imageUrl != null) {
                      controller.showFullScreenImage(point: point);
                    }
                  },
                  child: Container(
                    width: 10.w,
                    height: 5.h,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: appTheme.appColor),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: point.imageBytes != null 
                          ? Image.memory(
                              point.imageBytes!,
                              fit: BoxFit.cover,
                            )
                          : point.imageFile != null
                          ? Image.file(
                              point.imageFile!,
                              fit: BoxFit.cover,
                            )
                          : point.imageUrl != null
                              ? Image.network(
                                  point.imageUrl!,
                                  fit: BoxFit.cover,
                                  loadingBuilder:
                                      (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Center(
                                      child: CircularProgressIndicator(
                                        color: appTheme.appColor,
                                        strokeWidth: 2,
                                      ),
                                    );
                                  },
                                  errorBuilder: (context, error, stackTrace) {
                                    return Icon(
                                      Icons.image,
                                      color: appTheme.appColor,
                                      size: 16.sp,
                                    );
                                  },
                                )
                              : Icon(
                                  Icons.image,
                                  color: appTheme.appColor,
                                  size: 16.sp,
                                ),
                    ),
                  ),
                ),
                SizedBox(width: 2.w),
// Menu button - Chat/Comment icon
                GestureDetector(
                  onTap: () => controller.showRoutePointDialog(point),
                  child: Icon(
                    Icons.chat_bubble, // Changed to chat bubble icon
                    color: appTheme.appColor,
                    size: 20.sp, // Slightly smaller size
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
