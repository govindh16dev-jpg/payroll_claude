// ignore_for_file: avoid_print

import 'dart:convert';

import 'package:http/http.dart' as http;

import '../features/payslip_page/data/models/payslip_dropdown.dart';



Future<PayslipDropdownData> fetchPayslipDropdown({
  required String employeeId,
  required String companyId,
  required String clientId,
  required String token,
}) async {
  try {
    final response = await http.post(
      Uri.parse(
          'http://mobileapi.azatecon.com/api/employee-tabs/IND-employee-payroll/payslip/drop-down'),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      },
      body: jsonEncode(
        {
          'employee_id': employeeId,
          'company_id': companyId,
          'client_id': clientId,
        },
      ),
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);

      List<String> years = [];
      Map<String, List<String>> yearMonthMap = {};

      // Extract year numbers from the first array in the response data
      for (var item in responseData['data']['pay_slip'][0]) {
        years.add(item['year_no'].toString());
      }

      print('Years from API response: $years');

      // Extract month names and match them with corresponding year numbers
      for (var entry in responseData['data']['pay_slip'][1]) {
        String year = entry['year_no'];
        String month = entry['month_name'];
        if (!yearMonthMap.containsKey(year)) {
          yearMonthMap[year] = [];
        }
        yearMonthMap[year]!.add(month);
      }

      return PayslipDropdownData(years: years, yearMonthMap: yearMonthMap);
    } else {
      print('Failed to fetch data: ${response.statusCode}');
      return PayslipDropdownData(years: [], yearMonthMap: {});
    }
  } catch (e) {
    print('Error: $e');
    return PayslipDropdownData(years: [], yearMonthMap: {});
  }
}
