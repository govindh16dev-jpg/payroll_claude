import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';

import '../../theme/theme_controller.dart';

List<String> financialUpdateData = [
  'The company has achieved significant growth in both revenue and profitability, reflecting its strong performance in the market. This success has enabled the company to expand into new geographic regions, seizing opportunities for further market penetration and expansion. The strategic decision to open up new geographies underscores the company\'s commitment to sustained growth and its ability to capitalize on emerging markets',
  'We invite all employees to actively participate in our organization\'s Corporate Social Responsibility (CSR) initiatives focusing on education and skill development. Your involvement in these activities will not only make a positive impact on the communities we serve but also contribute to personal and professional growth. Let\'s join hands in empowering individuals through education and skill-building, embodying our commitment to social responsibility and making a meaningful difference in people\'s lives.',
  'We\'re pleased to announce our annual information security policy review, a crucial exercise for all employees to familiarize themselves with our company\'s protocols and practices. This initiative ensures that every team member understands their role in safeguarding sensitive information and upholding our commitment to data security. Your participation in this exercise is vital to maintaining a secure and resilient work environment for all',
];

List<String> titles = [
  'Financial Updates',
  'Social Responsibility',
  'Cyber Security'
];

List<Color> colours = [
  Colors.red,
  Colors.orange,
  Colors.green,
];

class Notifications extends StatelessWidget {
  const Notifications({super.key});

  @override
  Widget build(BuildContext context) {
    var appTheme = Get.find<ThemeController>().currentTheme;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: appTheme.black,
        actionsIconTheme:   IconThemeData(color: appTheme.black),
        title: const Text(
          'Notifications',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 15.0),
        child: ListView.builder(
          itemCount: financialUpdateData.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListTile(
                    leading: Image.asset(
                      'assets/logos/widget_logo/megaphones.png',
                      height: 40,
                    ),
                    iconColor: appTheme.green,
                    title: Text(
                      titles[index],
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16.sp,
                          color: colours[index]),
                    ),
                    subtitle: Text(
                      index == 0
                          ? financialUpdateData[index]
                          : '${financialUpdateData[index].substring(0, 100)}...',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.black),
                    ),
                    onTap: () {
                      // Show full text when tapped
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('Announcement'),
                            content: SingleChildScrollView(
                              child: Text(financialUpdateData[index]),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text('Close'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    '5 mins ago',
                    style: TextStyle(color: Colors.grey),
                  ),
                  Divider(
                    color: Colors.grey.shade300,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
