import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sizer/sizer.dart';

import '../../../theme/theme_controller.dart';
import '../../../util/common/bottom_nav.dart';
import '../../../util/common/drawer.dart';
import '../../../util/custom_widgets.dart';
import '../controller/route_history_controller.dart'; // reuse RoutePoint model

class ManagerRouteViewPage extends StatefulWidget {
  const ManagerRouteViewPage({super.key});

  @override
  State<ManagerRouteViewPage> createState() => _ManagerRouteViewPageState();
}

class _ManagerRouteViewPageState extends State<ManagerRouteViewPage> {
  // ── Args passed from manager controller ──────────────────────────────
  late final List<dynamic> _geoDetails;
  late final String _empName;
  late final String _date;

  // ── State ─────────────────────────────────────────────────────────────
  final RxList<RoutePoint>   _routePoints = <RoutePoint>[].obs;
  final RxSet<Marker>        _markers     = <Marker>{}.obs;
  final RxSet<Polyline>      _polylines   = <Polyline>{}.obs;
  final RxBool               _isLoading   = true.obs;
  GoogleMapController?       _mapController;

  @override
  void initState() {
    super.initState();
    final args = Get.arguments as Map<String, dynamic>;
    _geoDetails = args['geoDetails'] as List<dynamic>;
    _empName    = args['empName']    as String;
    _date       = args['date']       as String;
    _buildRoutePoints();
  }

  // ── Parse geo_details → RoutePoint list (same logic as RouteHistoryController) ──
  Future<void> _buildRoutePoints() async {
    _isLoading.value = true;
    final List<RoutePoint> points = [];
    int routeIndex = 1;

    for (int i = 0; i < _geoDetails.length; i++) {
      final geo = _geoDetails[i];
      final double lat =
          double.tryParse(geo['latitude']?.toString()  ?? '0') ?? 0;
      final double lng =
          double.tryParse(geo['longitude']?.toString() ?? '0') ?? 0;

      String address     = 'Location not available';
      String locationArea = 'Unknown';

      try {
        final placemarks = await placemarkFromCoordinates(lat, lng);
        if (placemarks.isNotEmpty) {
          final p = placemarks.first;
          address = '${p.street}, ${p.subLocality}, ${p.locality}, '
              '${p.administrativeArea} ${p.postalCode}';
          locationArea =
          '${p.subLocality ?? p.locality ?? 'Unknown'}, '
              '${p.administrativeArea ?? ''}';
          address = address
              .replaceAll(RegExp(r'^[\s,]+'), '')
              .replaceAll(RegExp(r'null,'), '')
              .replaceAll('null', '')
              .trim();
        }
      } catch (_) {}

      Uint8List? imageBytes;
      if (geo['file_path'] != null &&
          geo['file_path'].toString().isNotEmpty) {
        try {
          String b64 = geo['file_path']
              .toString()
              .replaceAll('\n', '')
              .replaceAll('\r', '');
          if (b64.contains(',')) b64 = b64.split(',').last;
          imageBytes = base64Decode(b64);
        } catch (_) {}
      }

      final String name = geo['action_type'] == 'clock_in'
          ? 'Clock IN'
          : geo['action_type'] == 'clock_out'
          ? 'Clock Out'
          : 'Route ${routeIndex++}';

      points.add(RoutePoint(
        id:          geo['geo_time_id']?.toString() ?? 'id_$i',
        name:        name,
        location:    locationArea,
        gpsLocation: '${lat.toStringAsFixed(4)}° N, '
            '${lng.toStringAsFixed(4)}° E',
        time:        geo['action_time']?.toString() ?? '',
        latLng:      LatLng(lat, lng),
        address:     address,
        imageBytes:  imageBytes,
      ));
    }

    _routePoints.value = points;
    _initMap();
    _isLoading.value = false;
  }

  void _initMap() {
    _markers.clear();
    _polylines.clear();
    if (_routePoints.isEmpty) return;

    for (int i = 0; i < _routePoints.length; i++) {
      final pt = _routePoints[i];
      _markers.add(Marker(
        markerId:    MarkerId(pt.id),
        position:    pt.latLng,
        infoWindow:  InfoWindow(title: pt.name, snippet: pt.location),
        icon: BitmapDescriptor.defaultMarkerWithHue(
          i == 0
              ? BitmapDescriptor.hueGreen
              : i == _routePoints.length - 1
              ? BitmapDescriptor.hueRed
              : BitmapDescriptor.hueViolet,
        ),
      ));
    }

    _polylines.add(Polyline(
      polylineId: const PolylineId('route'),
      points:     _routePoints.map((p) => p.latLng).toList(),
      color:
      Get.find<ThemeController>().currentTheme.appColor.withOpacity(0.6),
      width: 4,
      patterns: [PatternItem.dash(20), PatternItem.gap(10)],
      geodesic: true,
    ));
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    if (_routePoints.length >= 2) {
      Future.delayed(const Duration(milliseconds: 500), () {
        double minLat = _routePoints.first.latLng.latitude;
        double maxLat = minLat;
        double minLng = _routePoints.first.latLng.longitude;
        double maxLng = minLng;
        for (final p in _routePoints) {
          if (p.latLng.latitude  < minLat) minLat = p.latLng.latitude;
          if (p.latLng.latitude  > maxLat) maxLat = p.latLng.latitude;
          if (p.latLng.longitude < minLng) minLng = p.latLng.longitude;
          if (p.latLng.longitude > maxLng) maxLng = p.latLng.longitude;
        }
        _mapController?.animateCamera(CameraUpdate.newLatLngBounds(
          LatLngBounds(
            southwest: LatLng(minLat - 0.01, minLng - 0.01),
            northeast: LatLng(maxLat + 0.01, maxLng + 0.01),
          ),
          50,
        ));
      });
    }
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  // ── Build ─────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final appTheme = Get.find<ThemeController>().currentTheme;

    return Scaffold(
      drawer: CustomDrawer(),
      drawerEnableOpenDragGesture: false,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(5.h),
        child: AppBar(
          leading: Padding(
            padding: const EdgeInsets.only(left: 20.0),
            child: Builder(
              builder: (ctx) => IconButton(
                onPressed: () => Scaffold.of(ctx).openDrawer(),
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
              CustomHeader(title: 'Route History'),
              SizedBox(height: 1.h),

              // ── Employee & Date info banner (replaces date picker) ────
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                decoration: BoxDecoration(
                  color: appTheme.appColor.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.person, color: appTheme.appColor, size: 16.sp),
                    SizedBox(width: 2.w),
                    Text(
                      _empName,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: appTheme.darkGrey,
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Icon(Icons.calendar_today,
                        color: appTheme.appColor, size: 14.sp),
                    SizedBox(width: 1.w),
                    Text(
                      _date,
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                        color: appTheme.darkGrey,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 2.h),

              // ── Map ──────────────────────────────────────────────────
              Container(
                height: 35.h,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: appTheme.appColor, width: 3),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Obx(() {
                    if (_isLoading.value) {
                      return Center(
                        child: CircularProgressIndicator(
                            color: appTheme.appColor),
                      );
                    }
                    return GoogleMap(
                      onMapCreated:          _onMapCreated,
                      initialCameraPosition: CameraPosition(
                        target: _routePoints.isNotEmpty
                            ? _routePoints.first.latLng
                            : const LatLng(12.9260, 80.1685),
                        zoom: 11.5,
                      ),
                      markers:               _markers.toSet(),
                      polylines:             _polylines.toSet(),
                      myLocationEnabled:     false,
                      zoomControlsEnabled:   true,
                      zoomGesturesEnabled:   true,
                      scrollGesturesEnabled: true,
                      tiltGesturesEnabled:   true,
                      rotateGesturesEnabled: true,
                      mapToolbarEnabled:     false,
                      compassEnabled:        true,
                    );
                  }),
                ),
              ),
              SizedBox(height: 2.h),

              // ── Route detail table ───────────────────────────────────
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

  Widget _buildRouteDetails(dynamic appTheme) {
    return Container(
      padding: EdgeInsets.all(1.w),
      decoration: BoxDecoration(
        gradient:     LinearGradient(colors: appTheme.popUp1Border),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding:     EdgeInsets.all(3.w),
        decoration: BoxDecoration(
          color:        appTheme.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Obx(() {
          if (_isLoading.value) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(4.h),
                child: CircularProgressIndicator(color: appTheme.appColor),
              ),
            );
          }
          if (_routePoints.isEmpty) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(4.h),
                child: Text(
                  'No routes found',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color:      appTheme.darkGrey,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            );
          }
          return Column(
            children: [
              // Header
              Padding(
                padding: EdgeInsets.symmetric(vertical: 1.h),
                child: Row(
                  children: [
                    _headerCell('Route #',      appTheme, flex: 2),
                    _headerCell('GPS Location', appTheme, flex: 2),
                    _headerCell('Time',         appTheme, flex: 2),
                    _headerCell('Photo',        appTheme, flex: 2),
                  ],
                ),
              ),
              Divider(color: appTheme.appColor, thickness: 1),
              ListView.separated(
                shrinkWrap: true,
                physics:    const NeverScrollableScrollPhysics(),
                itemCount:  _routePoints.length,
                separatorBuilder: (_, __) => Divider(
                  color:     appTheme.appColor.withOpacity(0.3),
                  thickness: 0.5,
                ),
                itemBuilder: (_, i) =>
                    _buildRouteItem(_routePoints[i], appTheme),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _headerCell(String label, dynamic appTheme, {int flex = 2}) {
    return Expanded(
      flex: flex,
      child: Text(
        label,
        style: TextStyle(
          fontSize:   14.sp,
          fontWeight: FontWeight.bold,
          color:      appTheme.darkGrey,
        ),
      ),
    );
  }

  Widget _buildRouteItem(RoutePoint point, dynamic appTheme) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 1.h),
      child: Row(
        children: [
          // Route name
          Expanded(
            flex: 2,
            child: Text(
              point.name,
              style: TextStyle(
                fontSize:   13.sp,
                fontWeight: FontWeight.w600,
                color:      appTheme.darkGrey,
              ),
            ),
          ),
          // GPS
          Expanded(
            flex: 2,
            child: Text(
              point.address,
              style:    TextStyle(fontSize: 12.sp, color: appTheme.darkGrey),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          // Time
          Expanded(
            flex: 2,
            child: Text(
              point.time,
              style: TextStyle(fontSize: 12.sp, color: appTheme.darkGrey),
            ),
          ),
          // Photo + chat
          Expanded(
            flex: 2,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () {
                    if (point.imageBytes != null ||
                        point.imageFile  != null ||
                        point.imageUrl   != null) {
                      _showFullImage(point, appTheme);
                    }
                  },
                  child: Container(
                    width:  10.w,
                    height: 5.h,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: appTheme.appColor),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: point.imageBytes != null
                          ? Image.memory(point.imageBytes!, fit: BoxFit.cover)
                          : Icon(Icons.image,
                          color: appTheme.appColor, size: 16.sp),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Full-screen image viewer (same as RouteHistoryController) ─────────
  void _showFullImage(RoutePoint point, dynamic appTheme) {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        elevation:       0,
        insetPadding:    EdgeInsets.zero,
        child: Container(
          width:   95.w,
          padding: EdgeInsets.all(8),
          child: ListView(
            shrinkWrap: true,
            children: [
              Align(
                alignment: Alignment.topRight,
                child: GestureDetector(
                  onTap:  () => Get.back(),
                  child:  CloseButtonWidget(),
                ),
              ),
              SizedBox(height: 1.h),
              Container(
                decoration: BoxDecoration(
                  gradient:     LinearGradient(colors: appTheme.popUp1Border),
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: EdgeInsets.all(3),
                child: Container(
                  padding:     EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color:        appTheme.leaveDetailsBG,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Container(
                        height: 50.h,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: appTheme.appColor.withOpacity(0.3)),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: InteractiveViewer(
                            panEnabled:     true,
                            minScale:       0.5,
                            maxScale:       3.0,
                            child: point.imageBytes != null
                                ? Image.memory(point.imageBytes!,
                                fit: BoxFit.contain)
                                : const Icon(Icons.image, size: 60),
                          ),
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Row(
                        children: [
                          Icon(Icons.access_time,
                              color: appTheme.appColor, size: 16.sp),
                          SizedBox(width: 2.w),
                          Text('Captured at: ${point.time}',
                              style: TextStyle(
                                  fontSize:   14.sp,
                                  fontWeight: FontWeight.bold,
                                  color:      appTheme.darkGrey)),
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
}
