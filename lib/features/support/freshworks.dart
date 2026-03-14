// import 'dart:convert';
//
// import 'package:flutter/material.dart';
// import 'package:flutter_inappwebview/flutter_inappwebview.dart';
// import 'package:flutter/services.dart' show rootBundle;
// import 'package:sizer/sizer.dart';
// class FreshdeskSupportScreen extends StatefulWidget {
//   const FreshdeskSupportScreen({super.key});
//
//   @override
//   FreshdeskSupportScreenState createState() => FreshdeskSupportScreenState();
// }
//
// class FreshdeskSupportScreenState extends State<FreshdeskSupportScreen> {
//   InAppWebViewController? webViewController;
//   double progress = 0;
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Support"),
//         leading: IconButton(
//           icon: Icon(Icons.arrow_back),
//           onPressed: () => Navigator.pop(context),
//         ),
//       ),
//       body: Column(
//         children: [
//
//           progress < 1.0
//               ? LinearProgressIndicator(value: progress)
//               : SizedBox.shrink(),
//           SizedBox(
//             height: 60.h,
//             width:70.w ,
//             child: FutureBuilder<String>(
//               future: rootBundle.loadString('assets/freshworks_widget.html'),
//               builder: (context, snapshot) {
//                 if (snapshot.connectionState == ConnectionState.done) {
//                   final htmlContent = snapshot.data!;
//                   final dataUri = Uri.dataFromString(
//                     htmlContent,
//                     mimeType: 'text/html',
//                     encoding: Encoding.getByName('utf-8'),
//                   ).toString();
//
//                   return InAppWebView(
//                     initialUrlRequest: URLRequest(
//                       url: WebUri(dataUri),
//                     ),
//                     onWebViewCreated: (controller) {
//                       webViewController = controller;
//                     },
//                   );
//                 } else {
//                   return Center(child: CircularProgressIndicator());
//                 }
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
