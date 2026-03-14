// ignore_for_file: file_names, library_private_types_in_public_api, use_super_parameters

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

import '../../routes/app_route.dart';

class PinTextField extends StatefulWidget {
  const PinTextField(
      {Key? key, required void Function(dynamic value) onChanged})
      : super(key: key);

  @override
  _PinTextFieldState createState() => _PinTextFieldState();
}

class _PinTextFieldState extends State<PinTextField> {
  final int requiredNumber = 1234;

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: PinCodeTextField(
        cursorColor: Colors.transparent,
        appContext: context,
        length: 4,
        onChanged: (value) {},
        pinTheme: PinTheme(
            shape: PinCodeFieldShape.underline,
            selectedColor: Colors.orangeAccent,
            fieldOuterPadding: const EdgeInsets.symmetric(horizontal: 10),
            inactiveColor: Colors.black45,
            activeColor: Colors.orangeAccent),
        blinkDuration: const Duration(seconds: 1),
        onCompleted: (value) {
          if (int.parse(value) == requiredNumber) {
            setState(() {
              Get.toNamed(AppRoutes.homePage);
            });
          } else {
            showCupertinoDialog(
              context: context,
              builder: (context) => CupertinoAlertDialog(
                insetAnimationCurve: Curves.ease,
                title: const Text(
                  'Incorrect pin',
                ),
                actions: [
                  CupertinoButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        'try again',
                        style: TextStyle(color: Colors.red),
                      ))
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
