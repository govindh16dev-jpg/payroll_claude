import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';
import '../../../../util/getUserdata.dart';

import '../../../config/constants.dart';
import '../../login/domain/model/login_model.dart';
import '../../profile_page/data/model/profile_model.dart';
import '../data/repository/time_provider.dart';
import '../../../theme/theme_controller.dart';
import '../../../util/custom_widgets.dart';

class RouteHistoryController extends GetxController {
  var selectedDate = Rx<DateTime?>(null);
  late Future<void> _initDone;
  final TextEditingController dateController = TextEditingController();
  var dateText = ''.obs;
  GoogleMapController? mapController;
  UserData userData = UserData();
  // Make these properly observable with RxSet
  final RxSet<Marker> markers = <Marker>{}.obs;
  final RxSet<Polyline> polylines = <Polyline>{}.obs;

  var isLoading = false.obs;
  final RxList<RoutePoint> routePoints = <RoutePoint>[].obs;

  @override
  void onInit() {
    super.onInit();
    selectedDate.value = DateTime.now();
    dateText.value = DateFormat('dd/MM/yyyy').format(DateTime.now());
    dateController.text = dateText.value;
    _initDone = _init();

  }
  Future<void> waitUntilReady() => _initDone;
  Future<void> _init() async {
    await getUserData();
    await fetchRouteHistory();
  }

  Future<void> fetchRouteHistory() async {
    try {
      isLoading.value = true;

      String formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate.value ?? DateTime.now());

      var response = await TimeProvider().getEmployeeRouteList(
        employeeId: userData.user?.employeeId?? '',
        companyId: userData.user?.companyId?? '',
        clientId: userData.user?.clientId?? '',
        fromDate: formattedDate,
      );

      var responseData = jsonDecode(response.body);
      if (responseData['success'] == true && responseData['data'] != null && responseData['data']['geo_details'] != null) {
        List<dynamic> geoDetails = responseData['data']['geo_details'];
        List<RoutePoint> newRoutePoints = [];

        int routeIndex = 1;
        for (int i = 0; i < geoDetails.length; i++) {
          var geo = geoDetails[i];
          double lat = double.tryParse(geo['latitude']?.toString() ?? '0') ?? 0;
          double lng = double.tryParse(geo['longitude']?.toString() ?? '0') ?? 0;

          String address = 'Location not available';
          String locationArea = 'Unknown';
          try {
            List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);
            if (placemarks.isNotEmpty) {
              Placemark place = placemarks.first;
              address = "${place.street}, ${place.subLocality}, ${place.locality}, ${place.administrativeArea} ${place.postalCode}";
              locationArea = "${place.subLocality ?? place.locality ?? 'Unknown'}, ${place.administrativeArea ?? ''}";
              // Cleanup leading commas if any fields were null
              address = address.replaceAll(RegExp(r'^[\s,]+'), '').replaceAll(RegExp(r'null,'), '').replaceAll('null', '').trim();
            }
          } catch (e) {
            debugPrint("Geocoding error: $e");
          }

          Uint8List? imageBytes;
          if (geo['file_path'] != null && geo['file_path'].toString().isNotEmpty) {
            try {
              String base64String = geo['file_path'].toString().replaceAll('\n', '').replaceAll('\r', '');
              if (base64String.contains(',')) {
                base64String = base64String.split(',').last;
              }
              imageBytes = base64Decode(base64String);
            } catch (e) {
              debugPrint("Base64 decode error: $e");
            }
          }

          String name = geo['action_type'] == 'clock_in' ? 'Clock IN'
              : geo['action_type'] == 'clock_out' ? 'Clock Out'
              : 'Route ${routeIndex++}';

          newRoutePoints.add(RoutePoint(
            id: geo['geo_time_id']?.toString() ?? 'id_$i',
            name: name,
            location: locationArea,
            gpsLocation: "${lat.toStringAsFixed(4)}° N, ${lng.toStringAsFixed(4)}° E",
            time: geo['action_time']?.toString() ?? '',
            latLng: LatLng(lat, lng),
            address: address,
            imageBytes: imageBytes,
          ));
        }

        routePoints.value = newRoutePoints;
      } else {
        routePoints.clear();
      }
    } catch (e) {
      debugPrint("Error fetching route history: $e");
      routePoints.clear();
    } finally {
      isLoading.value = false;
      initializeMap();
    }
  }
  Future<UserData>? getUserData() async {
    const storage = FlutterSecureStorage();
    final String? userDataLocalStr = await storage.read(
      key: PrefStrings.userData,
    );

    if (userDataLocalStr != null) {
      final UserData userDataLocal = userDataFromJson(userDataLocalStr);
      userData = userDataLocal;
    }

    return userData;
  }

  void initializeMap() {
    markers.clear();
    polylines.clear();
    
    if (routePoints.isEmpty) {
      markers.refresh();
      polylines.refresh();
      return;
    }
    for (int i = 0; i < routePoints.length; i++) {
      markers.add(
        Marker(
          markerId: MarkerId(routePoints[i].id),
          position: routePoints[i].latLng,
          infoWindow: InfoWindow(
            title: routePoints[i].name,
            snippet: routePoints[i].location,
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(i == 0
              ? BitmapDescriptor.hueGreen
              : i == routePoints.length - 1
                  ? BitmapDescriptor.hueRed
                  : BitmapDescriptor.hueViolet),
          onTap: () => showRoutePointDialog(routePoints[i]),
        ),
      );
    }

    List<LatLng> polylineCoordinates =
        routePoints.map((point) => point.latLng).toList();

    polylines.add(
      Polyline(
        polylineId: PolylineId('route'),
        points: polylineCoordinates,
        color:
            Get.find<ThemeController>().currentTheme.appColor.withOpacity(0.6),
        width: 4,
        patterns: [PatternItem.dash(20), PatternItem.gap(10)],
        geodesic: true,
      ),
    );

    markers.refresh();
    polylines.refresh();

    if (mapController != null && routePoints.isNotEmpty) {
      Future.delayed(Duration(milliseconds: 500), () {
        LatLngBounds bounds = _calculateBounds();
        mapController?.animateCamera(CameraUpdate.newLatLngBounds(bounds, 50));
      });
    }
  }

  void onMapCreated(GoogleMapController controller) {
    mapController = controller;

    if (routePoints.isNotEmpty) {
      Future.delayed(Duration(milliseconds: 500), () {
        LatLngBounds bounds = _calculateBounds();
        mapController?.animateCamera(CameraUpdate.newLatLngBounds(bounds, 50));
      });
    }
  }

  LatLngBounds _calculateBounds() {
    double minLat = routePoints.first.latLng.latitude;
    double maxLat = routePoints.first.latLng.latitude;
    double minLng = routePoints.first.latLng.longitude;
    double maxLng = routePoints.first.latLng.longitude;

    for (var point in routePoints) {
      if (point.latLng.latitude < minLat) minLat = point.latLng.latitude;
      if (point.latLng.latitude > maxLat) maxLat = point.latLng.latitude;
      if (point.latLng.longitude < minLng) minLng = point.latLng.longitude;
      if (point.latLng.longitude > maxLng) maxLng = point.latLng.longitude;
    }

    return LatLngBounds(
      southwest: LatLng(minLat - 0.01, minLng - 0.01),
      northeast: LatLng(maxLat + 0.01, maxLng + 0.01),
    );
  }

  Future<void> selectDate(BuildContext context) async {
    var appTheme = Get.find<ThemeController>().currentTheme;

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate.value ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: appTheme.appColor,
              onPrimary: appTheme.white,
              onSurface: appTheme.darkGrey,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: appTheme.appColor,
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      selectedDate.value = picked;
      dateText.value = DateFormat('dd/MM/yyyy').format(picked); // ✅ UPDATE THIS
      dateController.text = dateText.value; // Keep controller in sync
     await fetchRouteHistory();
    }
  }

  void showRoutePointDialog(RoutePoint point) {
    var appTheme = Get.find<ThemeController>().currentTheme;

    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        insetPadding: EdgeInsets.all(0),
        child: Container(
          width: 95.w,
          padding: EdgeInsets.all(8),
          child: ListView(
            shrinkWrap: true,
            children: [
              Align(
                alignment: Alignment.topRight,
                child: GestureDetector(
                  onTap: () => Get.back(),
                  child: CloseButtonWidget(),
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 3.w, vertical: 1.h),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: appTheme.buttonGradient,
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: Text(
                          point.name,
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w900,
                            color: appTheme.white,
                          ),
                        ),
                      ),
                      SizedBox(height: 2.h),

                      // GPS Location
                      _buildInfoRow(Icons.location_on, 'GPS Location',
                          point.gpsLocation, appTheme),
                      SizedBox(height: 1.h),

                      // Time
                      _buildInfoRow(
                          Icons.access_time, 'Time', point.time, appTheme),
                      SizedBox(height: 1.h),

                      // Address
                      _buildInfoRow(
                          Icons.home, 'Address', point.address, appTheme),
                      SizedBox(height: 2.h),

                      // Photo
                      if (point.imageBytes != null || point.imageUrl != null ||
                          point.imageFile != null) ...[
                        Text(
                          'Photo',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                            color: appTheme.darkGrey,
                          ),
                        ),
                        SizedBox(height: 1.h),
                        GestureDetector(
                          onTap: () {
                            showFullScreenImage(point: point);
                          },
                          child: Container(
                            height: 20.h,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: appTheme.appColor),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
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
                                  : Image.network(
                                      point.imageUrl!,
                                      fit: BoxFit.cover,
                                      loadingBuilder:
                                          (context, child, loadingProgress) {
                                        if (loadingProgress == null) {
                                          return child;
                                        }
                                        return Center(
                                          child: CircularProgressIndicator(
                                            color: appTheme.appColor,
                                          ),
                                        );
                                      },
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return Icon(
                                          Icons.image,
                                          color: appTheme.appColor,
                                          size: 40.sp,
                                        );
                                      },
                                    ),
                            ),
                          ),
                        ),
                      ],
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

  Widget _buildInfoRow(
      IconData icon, String label, String value, dynamic appTheme) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: appTheme.appColor, size: 18.sp),
        SizedBox(width: 2.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: appTheme.darkGrey.withOpacity(0.7),
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: appTheme.darkGrey,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void showFullScreenImage(
      {required RoutePoint point}) {
    var appTheme = Get.find<ThemeController>().currentTheme;

    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        insetPadding: EdgeInsets.all(0),
        child: Container(
          width: 95.w,
          padding: EdgeInsets.all(8),
          child: ListView(
            shrinkWrap: true,
            children: [
              Align(
                alignment: Alignment.topRight,
                child: GestureDetector(
                  onTap: () => Get.back(),
                  child: CloseButtonWidget(),
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
                    children: [
                      // Title
                      Align(
                        alignment: Alignment.topLeft,
                        child: Container(
                          width: 40.w,
                          height: 4.h,
                          padding: EdgeInsets.symmetric(
                              horizontal: 2.w, vertical: 0.8.h),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: appTheme.buttonGradient,
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: Text(
                            textAlign: TextAlign.center,
                            "${point.name} Photo",
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w900,
                              color: appTheme.white,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 2.h),

                      // Image viewer
                      Container(
                        height: 50.h,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: appTheme.appColor.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: InteractiveViewer(
                            panEnabled: true,
                            boundaryMargin: EdgeInsets.all(10),
                            minScale: 0.5,
                            maxScale: 3.0,
                            child: point.imageBytes != null
                                ? Image.memory(
                                    point.imageBytes!,
                                    fit: BoxFit.contain,
                                  )
                                : point.imageFile != null
                                ? Image.file(
                                    point.imageFile!,
                                    fit: BoxFit.contain,
                                  )
                                : Image.network(
                                    point.imageUrl!,
                                    fit: BoxFit.contain,
                                    loadingBuilder:
                                        (context, child, loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return Center(
                                        child: CircularProgressIndicator(
                                          color: appTheme.appColor,
                                          value: loadingProgress
                                                      .expectedTotalBytes !=
                                                  null
                                              ? loadingProgress
                                                      .cumulativeBytesLoaded /
                                                  loadingProgress
                                                      .expectedTotalBytes!
                                              : null,
                                        ),
                                      );
                                    },
                                    errorBuilder: (context, error, stackTrace) {
                                      return Center(
                                        child: Icon(
                                          Icons.error_outline,
                                          color: appTheme.appColor,
                                          size: 50.sp,
                                        ),
                                      );
                                    },
                                  ),
                          ),
                        ),
                      ),
                      SizedBox(height: 2.h),

                      // Info section
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: appTheme.greyBox.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.access_time,
                                  color: appTheme.appColor,
                                  size: 16.sp,
                                ),
                                SizedBox(width: 2.w),
                                Text(
                                  'Captured at: ${point.time}',
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.bold,
                                    color: appTheme.darkGrey,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 0.5.h),
                            Row(
                              children: [
                                Icon(
                                  Icons.location_on,
                                  color: appTheme.appColor,
                                  size: 16.sp,
                                ),
                                SizedBox(width: 2.w),
                                Expanded(
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
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 2.h),

                      // Done button
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
                          onPressed: () => Get.back(),
                          child: Text(
                            "Done",
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

  @override
  void dispose() {
    dateController.dispose();
    mapController?.dispose();
    super.dispose();
  }
}

class RoutePoint {
  final String id;
  final String name;
  final String location;
  final String gpsLocation;
  final String time;
  final LatLng latLng;
  final String address;
  final String? imageUrl;
  final File? imageFile;
  final Uint8List? imageBytes;

  RoutePoint({
    required this.id,
    required this.name,
    required this.location,
    required this.gpsLocation,
    required this.time,
    required this.latLng,
    required this.address,
    this.imageUrl,
    this.imageFile,
    this.imageBytes,
  });
}
