// ignore_for_file: file_names
import 'package:flutter/cupertino.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';

import '../features/login/domain/model/login_model.dart';
import '../routes/app_pages.dart';

Future<UserData>? getUserData() async {
  const storage = FlutterSecureStorage();
  final String? userDataLocal = await storage.read(key: PrefStrings.userData);
  final UserData userData = userDataFromJson(userDataLocal!);
  debugPrint(userData.accessToken);
  return userData;
}

String dateTimeToString(DateTime date, {String format = "dd-MM-yyyy"}) {
  DateFormat outputFormat = DateFormat(format);
  String outputDate = outputFormat.format(date);
  return outputDate;
}
