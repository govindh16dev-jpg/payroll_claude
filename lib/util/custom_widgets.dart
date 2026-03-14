import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';

import '../features/homepage/views/widgets/category_icon.dart';
import '../theme/theme_controller.dart';

Widget loadingIndicator(){
  return  Center(
    child: PulsingInfinityIcon()
  );
}

class CloseButtonWidget extends StatelessWidget {
  const CloseButtonWidget({super.key});

  @override
  Widget build(BuildContext context) {
    var appTheme = Get.find<ThemeController>().currentTheme;
    return Container(
      width: 8.w,
      height: 5.h,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          width: 2, // Thin border
          color: appTheme.appColor
        ),
      ),
      child: Center(
        child: Icon(
          Icons.close,
          color: appTheme.appColor,
          size: 18.sp,
        ),
      ),
    );
  }
}
Widget arrowIconUp(){
  var appTheme = Get.find<ThemeController>().currentTheme;
  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: Container(
      width: 5.w,
      height: 5.h,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: appTheme.appColor, // Background color
      ),
      child: Center(
        child: FaIcon(
          FontAwesomeIcons.angleUp, // FontAwesome down-arrow icon
          color: Colors.white,
          size: 16.sp,
        ),
      ),
    ),
  );
}

Widget arrowIconDown(){
  var appTheme = Get.find<ThemeController>().currentTheme;
  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: Container(
      width: 5.w,
      height: 5.h,
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
messageAlert(String msg, String ttl, isOkay, context) {
  return showDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text(ttl),
          content: Text(msg),
          actions: [
            isOkay
                ? CupertinoDialogAction(
                    isDefaultAction: false,
                    child: const Column(
                      children: <Widget>[
                        Text('Okay'),
                      ],
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  )
                : const SizedBox(),
          ],
        );
      });
}


class DottedBorderPainter extends CustomPainter {
  final double borderRadius;

  DottedBorderPainter({this.borderRadius = 5});

  @override
  void paint(Canvas canvas, Size size) {
    var appTheme = Get.find<ThemeController>().currentTheme;
    Paint paint = Paint()
      ..color = appTheme.appThemeLight
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Radius.circular(borderRadius),
    );

    final Path path = Path()..addRRect(rrect);
    final PathMetrics pathMetrics = path.computeMetrics();

    double dashWidth = 5;
    double dashSpace = 3;

    for (final PathMetric metric in pathMetrics) {
      double distance = 0.0;
      while (distance < metric.length) {
        final extractPath = metric.extractPath(
          distance,
          distance + dashWidth,
        );
        canvas.drawPath(extractPath, paint);
        distance += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}


