// ignore_for_file: file_names, use_key_in_widget_constructors, library_private_types_in_public_api, empty_catches

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:payroll/features/profile_page/views/controller/profile_page_controller.dart';
import 'package:sizer/sizer.dart';

class MyDetails extends GetView<ProfilePageController> {
  const MyDetails({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
           Text(
            'Employee Details:',
            style: TextStyle(
              fontSize: 20.sp ,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Obx(() => controller.user.isNotEmpty
              ? Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.shade400,
                        offset: const Offset(2, 2),
                        blurRadius: 4,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildDetailRow('Name:', controller.user[0].empcontroller.user[0].departmentNameloyeeName),
                      buildDetailRow('Email:', controller.user[0].email),
                      buildDetailRow('Mobile:', controller.user[0].mobile),
                      buildDetailRow('Date of Birth:', controller.user[0].dob),
                      buildDetailRow(
                          'Department:', controller.user[0].departmentName),
                      buildDetailRow('Sex:', controller.user[0].sex),
                      buildDetailRow(
                          'Date of Joining:', controller.user[0].dataOfJoining),
                      buildDetailRow('Work Experiences:',
                          controller.user[0].workExperiences),
                      buildDetailRow('Bank Name:', controller.user[0].bankName),
                      buildDetailRow(
                          'Account Number:', controller.user[0].accountNumber),
                      buildDetailRow(
                          'Account Type:', controller.user[0].accountType),
                      buildDetailRow(
                          'Bank Branch:', controller.user[0].bankBranch),
                      const SizedBox(height: 16),
                      const Text('Decoded image for the User'),
                      const SizedBox(height: 10),
                      // Display the image here
                      controller.user[0].img != null
                          ? Image.memory(
                              base64Decode(controller.user[0].img!),
                              width: 100,
                              height: 100,
                            )
                          : const SizedBox.shrink(),
                    ],
                  ),
                )
              : const SizedBox.shrink()),
          Obx(() => controller.user.isEmpty
              ? const Column(
                  children: [
                    SizedBox(height: 100),
                    Center(
                      child: SpinKitWave(
                        color: Colors.lightGreenAccent,
                      ),
                    ),
                  ],
                )
              : const SizedBox.shrink())
        ],
      ),
    );
  }

  Widget buildDetailRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value ?? 'N/A', // Provide a default value if value is null
              style: TextStyle(color: Colors.grey.shade700),
            ),
          ),
        ],
      ),
    );
  }
}
