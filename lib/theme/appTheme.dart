// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  Color grey = Colors.grey.shade200;
  static final Color darkGreyGreet = const Color(0XFF232323);
  final Color darkGrey = const Color(0XFF232323);
  final Color appBG = Colors.white;
  final Color lightGrey = const Color(0XFF1A502F);
  final Color appColor = const Color(0XFFCB6CE6);
  final Color white = const Color(0XFFFFFFFF);
  final Color white54 = Colors.white54;
  final Color black = const Color(0xFF000000);
  final Color black87 = Colors.black87;
  final Color black26 = Colors.black26;
  final Color black54 = Colors.black54;
  final Color green = const Color(0xFF4CAF50);
  final Color successBG = const Color(0xFF004AAD);
  final Color calendarApproved = const Color(0xFF7ED957);
  final Color calendarHoliday = const Color(0xFFBBCCDD);
  final Color calendarPending = const Color(0xFFFFde59);
  final Color calendarRejected = const Color(0xFFFF3131);
  final Color calendarOvertime= const Color(0xFF5ce1e6);

  Color appThemeLight = const Color(0XFFCB6CE6);
  Color greyBox = const Color(0XFFBBBBBC);
  final Color orange = const Color(0XFFf46545);
  final Color red = Colors.red;

  final Color appGradient = const Color(0XFFCB6CE6);
  final Color gradientBlue = const Color(0XFF004A75);
  final List<Color> popUp1 = const [Color(0XFF5DE0E6), Color(0XFF004A75)];
  //payslip
  final List<Color> popUp1Border = const [
    Color(0x8086A0FF),
    Color(0x80FF99DD),
  ];
  final List<Color> popUp2Border = const [
    Color(0x8086A0FF),
    Color(0x80FF99DD),
  ];
  final List<Color> popUp3Border = const [Color(0x8086A0FF), Color(0x80FF99DD)];
  final Color popUpBG = Colors.black26;
  final Color popUpCardBG = Colors.white;
  final Color leaveDetailsBG = Colors.white;
  Color infoIconPaySlip = Colors.black26;

  final List<Color> waveGradient = const [
    Color(0x809584FF),
    Color(0x80FF3e89),
  ];
  final List<Color> taxDetailsBG = const [
    Color(0x8086A0FF),
    Color(0x80FF99DD),
  ];
  final List<Color> paySlipDetailsBG = const [
    Color(0x8086A0FF),
    Color(0x80FF99DD),
  ];
  final List<Color> bannerGradient = const [
    Color(0xFF5170ff),
    Color(0xFFff66c4)
  ];
  final List<Color> categoryGradient = const [
    Color(0xFF5170ff),
    Color(0xFFff66c4)
  ];
  final List<Color> buttonGradient = const [
    Color(0xFF5170ff),
    Color(0xFFff66c4)
  ];
  final List<Color> payslipExpandable = const [
    Color(0xFFa6a6a6),
    Color(0xFFffffff)
  ];
  final List<Color> buttonGradientApproved = const [
    Color(0XFF009FB2),
    Color(0XFF7ED957)
  ];
  final List<Color> buttonPending = const [
    Color(0Xfff00000),
    Color(0xFFEE0000)
  ];
  final List<Color> buttonGradientRejected = const [
    Color(0XFFFF3131),
    Color(0XFFFF914D)
  ];
  final List<Color> dividerGradient = const [
    Color(0xFF5170ff),
    Color(0xFFff66c4)
  ];
  final Color orangeGradient = const Color(0xFFFF6B6B);

  ///UI colors
  final Color welcomeText = const Color(0XFFCB6CE6);
  final List<Color> textFieldBorderGradient = const [
    Color(0xFF5170ff),
    Color(0xFFff66c4)
  ];
  final Color textFieldBorder = const Color(0XFF5170FF);
  final Color textFieldLabel = const Color(0xFF9E9E9E);
  final Color appGradientStart = const Color(0xFF5170ff);
  final Color appGradientEnd = const Color(0xFFff66c4);

  ColorScheme? kColorScheme;

  AppTheme() {
    kColorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: appColor,
      onPrimary: Colors.white,
      secondary: appGradientEnd,
      onSecondary: Colors.white,
      surface: Colors.white,
      onSurface: lightGrey,
      error: Colors.red,
      onError: Colors.white,
    );
  }

  ThemeData get lightTheme => ThemeData(
        textTheme: GoogleFonts.dmSansTextTheme(),
        primaryColor: appThemeLight,
        colorScheme: kColorScheme,
        cardColor: kColorScheme?.surface,
        cardTheme: CardThemeData(color: kColorScheme?.surface),
        scaffoldBackgroundColor: appBG,
        appBarTheme: AppBarTheme(
          backgroundColor: appBG,
        ),
      );
}

class AppThemeGreen {
  Color grey = Colors.grey.shade200;

  final Color darkGrey = const Color(0XFF232323);
  final Color appBG = Colors.white;
  final Color lightGrey = const Color(0XFF1A502F);

  final Color white = const Color(0XFFFFFFFF);
  final Color white54 = Colors.white54;
  final Color black = const Color(0xFF000000);
  final Color black87 = Colors.black87;
  final Color black26 = Colors.black26;
  final Color black54 = Colors.black54;
  final Color green = const Color(0xFF4CAF50);
  final Color successBG = const Color(0xFF004AAD);
  final Color calendarApproved = const Color(0xFF7ED957);
  final Color calendarHoliday = const Color(0xFFBBCCDD);
  final Color calendarPending = const Color(0xFFFFde59);
  final Color calendarRejected = const Color(0xFFFF3131);
  final Color calendarOvertime= const Color(0xFF5ce1e6);

  Color greyBox = const Color(0XFFBBBBBC);
  final Color orange = const Color(0XFFf46545);
  final Color red = Colors.red;

//colors for theme with gradient
  final Color appGradient = const Color(0xFF4CAF50);
  final Color appColor = const Color(0xFF4CAF50);
  Color appThemeLight = const Color(0xFF4CAF50);

  final Color gradientBlue = const Color(0XFF004A75);
  final List<Color> popUp1 = const [Color(0XFF5DE0E6), Color(0XFF004A75)];
  // payslip
  final List<Color> popUp1Border = const [
    Color(0x800097b2),
    Color(0x807ed957),
  ];
  final List<Color> popUp2Border = const [
    Color(0x800097b2),
    Color(0x807ed957),
  ];
  final List<Color> popUp3Border = const [
    Color(0x800097b2),
    Color(0x807ed957),
  ];
  final Color popUpBG = Colors.black26;
  final Color popUpCardBG = Colors.white;
  final Color leaveDetailsBG = Colors.white;
  Color infoIconPaySlip = Colors.black26;

  final List<Color> waveGradient = const [
    Color(0x800097b2),
    Color(0x807ed957),
  ];
  final List<Color> taxDetailsBG = const [
    Color(0x800097b2),
    Color(0x807ed957),
  ];
  final List<Color> paySlipDetailsBG = const [
    Color(0x800097b2),
    Color(0x807ed957),
  ];
  final List<Color> bannerGradient = const [
    Color(0xFF0097b2),
    Color(0xFF7ed957),
  ];
  final List<Color> categoryGradient = const [
    Color(0xFF0097b2),
    Color(0xFF7ed957),
  ];
  final List<Color> buttonGradient = const [
    Color(0xFF0097b2),
    Color(0xFF7ed957),
  ];
  final List<Color> payslipExpandable = const [
    Color(0xFFa6a6a6),
    Color(0xFFffffff),
  ];
  final List<Color> buttonGradientApproved = const [
    Color(0xFF009FB2),
    Color(0xFF7ED957),
  ];
  final List<Color> buttonPending = const [
    Color(0xFFf00000),
    Color(0xFFEE0000),
  ];
  final List<Color> buttonGradientRejected = const [
    Color(0xFFFF3131),
    Color(0xFFFF914D),
  ];
  final List<Color> dividerGradient = const [
    Color(0xFF0097b2),
    Color(0xFF7ed957),
  ];
  final Color orangeGradient = const Color(0xFFFF6B6B);

// UI colors
  final Color welcomeText = const Color(0xFF0097b2); // or customize as needed
  final List<Color> textFieldBorderGradient = const [
    Color(0xFF0097b2),
    Color(0xFF7ed957),
  ];
  final Color textFieldBorder = const Color(0xFF0097b2);
  final Color textFieldLabel = const Color(0xFF9E9E9E);
  final Color appGradientStart = const Color(0xFF0097b2);
  final Color appGradientEnd = const Color(0xFF7ed957);

  ColorScheme? kColorScheme;

  AppThemeGreen() {
    kColorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: appColor, // Access appColor in the constructor body
      onPrimary: Colors.white,
      secondary: appGradientEnd,
      onSecondary: Colors.white,
      surface: Colors.white,
      onSurface: lightGrey,
      error: Colors.red,
      onError: Colors.white,
    );
  }

  ThemeData get lightTheme => ThemeData(
      textTheme: GoogleFonts.dmSansTextTheme(),
      primaryColor: appThemeLight,
      colorScheme: kColorScheme,
      cardColor: kColorScheme?.surface,
      cardTheme: CardThemeData(color: kColorScheme?.surface),
      scaffoldBackgroundColor: appBG,
      appBarTheme: AppBarTheme(
        backgroundColor: appBG,
      ));
}

class AppThemeYellow {
  Color grey = Colors.grey.shade200;

  final Color darkGrey = const Color(0XFF232323);
  final Color appBG = Colors.white;
  final Color lightGrey = const Color(0XFF1A502F);

  final Color white = const Color(0XFFFFFFFF);
  final Color white54 = Colors.white54;
  final Color black = const Color(0xFF000000);
  final Color black87 = Colors.black87;
  final Color black26 = Colors.black26;
  final Color black54 = Colors.black54;
  final Color green = const Color(0xFF4CAF50);
  final Color successBG = const Color(0xFF004AAD);
  final Color calendarApproved = const Color(0xFF7ED957);
  final Color calendarHoliday = const Color(0xFFBBCCDD);
  final Color calendarPending = const Color(0xFFFFde59);
  final Color calendarRejected = const Color(0xFFFF3131);
  final Color calendarOvertime= const Color(0xFF5ce1e6);

  Color greyBox = const Color(0XFFBBBBBC);
  final Color orange = const Color(0XFFf46545);
  final Color red = Colors.red;

//colors for theme with gradient
  final Color appGradient = const Color(0xFFffde59);
  final Color appColor = const Color(0xFFffde59);
  Color appThemeLight = const Color(0xFFffde59);

  final Color gradientBlue = const Color(0XFF004A75);
  final List<Color> popUp1 = const [Color(0XFF5DE0E6), Color(0XFF004A75)];
  // payslip
  final List<Color> popUp1Border = const [
    Color(0x80ffde59),
    Color(0x80ff914d),
  ];
  final List<Color> popUp2Border = const [
    Color(0x80ffde59),
    Color(0x80ff914d),
  ];
  final List<Color> popUp3Border = const [
    Color(0x80ffde59),
    Color(0x80ff914d),
  ];
  final Color popUpBG = Colors.black26;
  final Color popUpCardBG = Colors.white;
  final Color leaveDetailsBG = Colors.white;
  Color infoIconPaySlip = Colors.black26;

  final List<Color> waveGradient = const [
    Color(0x80ffde59),
    Color(0x80ff914d),
  ];
  final List<Color> taxDetailsBG = const [
    Color(0x80ffde59),
    Color(0x80ff914d),
  ];
  final List<Color> paySlipDetailsBG = const [
    Color(0x80ffde59),
    Color(0x80ff914d),
  ];
  final List<Color> bannerGradient = const [
    Color(0xFFffde59),
    Color(0xFFff914d),
  ];
  final List<Color> categoryGradient = const [
    Color(0xFFffde59),
    Color(0xFFff914d),
  ];
  final List<Color> buttonGradient = const [
    Color(0xFFffde59),
    Color(0xFFff914d),
  ];
  final List<Color> payslipExpandable = const [
    Color(0xFFa6a6a6),
    Color(0xFFffffff),
  ];
  final List<Color> buttonGradientApproved = const [
    Color(0xFF009FB2),
    Color(0xFF7ED957),
  ];
  final List<Color> buttonPending = const [
    Color(0xFFf00000),
    Color(0xFFEE0000),
  ];
  final List<Color> buttonGradientRejected = const [
    Color(0xFFFF3131),
    Color(0xFFFF914D),
  ];
  final List<Color> dividerGradient = const [
    Color(0xFFffde59),
    Color(0xFFff914d),
  ];
  final Color orangeGradient = const Color(0xFFFF6B6B);

// UI colors
  final Color welcomeText = const Color(0xFFff914d); // or customize as needed
  final List<Color> textFieldBorderGradient = const [
    Color(0xFFffde59),
    Color(0xFFff914d),
  ];
  final Color textFieldBorder = const Color(0xFFffde59);
  final Color textFieldLabel = const Color(0xFF9E9E9E);
  final Color appGradientStart = const Color(0xFFffde59);
  final Color appGradientEnd = const Color(0xFFff914d);

  ColorScheme? kColorScheme;

  AppThemeYellow() {
    kColorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: appColor, // Access appColor in the constructor body
      onPrimary: Colors.white,
      secondary: appGradientEnd,
      onSecondary: Colors.white,
      surface: Colors.white,
      onSurface: lightGrey,
      error: Colors.red,
      onError: Colors.white,
    );
  }

  ThemeData get lightTheme => ThemeData(
      textTheme: GoogleFonts.dmSansTextTheme(),
      primaryColor: appThemeLight,
      colorScheme: kColorScheme,
      cardColor: kColorScheme?.surface,
      cardTheme: CardThemeData(color: kColorScheme?.surface),
      scaffoldBackgroundColor: appBG,
      appBarTheme: AppBarTheme(
        backgroundColor: appBG,
      ));
}

class AppThemeCoralRed {
  Color grey = Colors.grey.shade200;

  final Color darkGrey = const Color(0XFF232323);
  final Color appBG = Colors.white;
  final Color lightGrey = const Color(0XFF1A502F);

  final Color white = const Color(0XFFFFFFFF);
  final Color white54 = Colors.white54;
  final Color black = const Color(0xFF000000);
  final Color black87 = Colors.black87;
  final Color black26 = Colors.black26;
  final Color black54 = Colors.black54;
  final Color green = const Color(0xFF4CAF50);
  final Color successBG = const Color(0xFF004AAD);
  final Color calendarApproved = const Color(0xFF7ED957);
  final Color calendarHoliday = const Color(0xFFBBCCDD);
  final Color calendarPending = const Color(0xFFFFde59);
  final Color calendarRejected = const Color(0xFFFF3131);
  final Color calendarOvertime= const Color(0xFF5ce1e6);

  Color greyBox = const Color(0XFFBBBBBC);
  final Color orange = const Color(0XFFf46545);
  final Color red = Colors.red;

//colors for theme with gradient
  final Color appGradient = const Color(0xFFff4858);
  final Color appColor = const Color(0xFFff4858);
  Color appThemeLight = const Color(0xFFff4858);

  final Color gradientBlue = const Color(0XFF004A75);
  final List<Color> popUp1 = const [Color(0XFF5DE0E6), Color(0XFF004A75)];

  // payslip
  final List<Color> popUp1Border = const [
    Color(0x80ff4858),
    Color(0x80ff4858),
  ];
  final List<Color> popUp2Border = const [
    Color(0x80ff4858),
    Color(0x80ff4858),
  ];
  final List<Color> popUp3Border = const [
    Color(0x80ff4858),
    Color(0x80ff4858),
  ];
  final Color popUpBG = Colors.black26;
  final Color popUpCardBG = Colors.white;
  final Color leaveDetailsBG = Colors.white;
  Color infoIconPaySlip = Colors.black26;

  final List<Color> waveGradient = const [
    Color(0x80ff4858),
    Color(0x80ff4858),
  ];
  final List<Color> taxDetailsBG = const [
    Color(0x80ff4858),
    Color(0x80ff4858),
  ];
  final List<Color> paySlipDetailsBG = const [
    Color(0x80ff4858),
    Color(0x80ff4858),
  ];
  final List<Color> bannerGradient = const [
    Color(0xFFff4858),
    Color(0xFFff4858),
  ];
  final List<Color> categoryGradient = const [
    Color(0xFFff4858),
    Color(0xFFff4858),
  ];
  final List<Color> buttonGradient = const [
    Color(0xFFff4858),
    Color(0xFFff4858),
  ];
  final List<Color> payslipExpandable = const [
    Color(0xFFa6a6a6),
    Color(0xFFffffff),
  ];
  final List<Color> buttonGradientApproved = const [
    Color(0xFF009FB2),
    Color(0xFF7ED957),
  ];
  final List<Color> buttonPending = const [
    Color(0xFFf00000),
    Color(0xFFEE0000),
  ];
  final List<Color> buttonGradientRejected = const [
    Color(0xFFFF3131),
    Color(0xFFFF914D),
  ];
  final List<Color> dividerGradient = const [
    Color(0xFFff4858),
    Color(0xFFff4858),
  ];
  final Color orangeGradient = const Color(0xFFFF6B6B);

// UI colors
  final Color welcomeText = const Color(0xFFff4858); // or adjust for contrast
  final List<Color> textFieldBorderGradient = const [
    Color(0xFFff4858),
    Color(0xFFff4858),
  ];
  final Color textFieldBorder = const Color(0xFFff4858);
  final Color textFieldLabel = const Color(0xFF9E9E9E);
  final Color appGradientStart = const Color(0xFFff4858);
  final Color appGradientEnd = const Color(0xFFff4858);

  ColorScheme? kColorScheme;

  AppThemeCoralRed() {
    kColorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: appColor, // Access appColor in the constructor body
      onPrimary: Colors.white,
      secondary: appGradientEnd,
      onSecondary: Colors.white,
      surface: Colors.white,
      onSurface: lightGrey,
      error: Colors.red,
      onError: Colors.white,
    );
  }

  ThemeData get lightTheme => ThemeData(
      textTheme: GoogleFonts.dmSansTextTheme(),
      primaryColor: appThemeLight,
      colorScheme: kColorScheme,
      cardColor: kColorScheme?.surface,
      cardTheme: CardThemeData(color: kColorScheme?.surface),
      scaffoldBackgroundColor: appBG,
      appBarTheme: AppBarTheme(
        backgroundColor: appBG,
      ));
}

class AppThemeBlue {
  Color grey = Colors.grey.shade200;

  final Color darkGrey = const Color(0XFF232323);
  final Color appBG = Colors.white;
  final Color lightGrey = const Color(0XFF1A502F);

  final Color white = const Color(0XFFFFFFFF);
  final Color white54 = Colors.white54;
  final Color black = const Color(0xFF000000);
  final Color black87 = Colors.black87;
  final Color black26 = Colors.black26;
  final Color black54 = Colors.black54;
  final Color green = const Color(0xFF4CAF50);
  final Color successBG = const Color(0xFF004AAD);
  final Color calendarApproved = const Color(0xFF7ED957);
  final Color calendarHoliday = const Color(0xFFBBCCDD);
  final Color calendarPending = const Color(0xFFFFde59);
  final Color calendarRejected = const Color(0xFFFF3131);
  final Color calendarOvertime= const Color(0xFF5ce1e6);

  Color greyBox = const Color(0XFFBBBBBC);
  final Color orange = const Color(0XFFf46545);
  final Color red = Colors.red;

  // Blue theme base colors
  final Color appGradient = const Color(0xFF5ce1e6);
  final Color appColor = const Color(0xFF5ce1e6);
  Color appThemeLight = const Color(0xFF5ce1e6);

  final Color gradientBlue = const Color(0XFF004A75);
  final List<Color> popUp1 = const [Color(0XFF5ce1e6), Color(0XFF004A75)];
  final List<Color> popUp1Border = const [
    Color(0x805ce1e6),
    Color(0x80ffffff),
  ];
  final List<Color> popUp2Border = const [
    Color(0x805ce1e6),
    Color(0x80ffffff),
  ];
  final List<Color> popUp3Border = const [
    Color(0x805ce1e6),
    Color(0x80ffffff),
  ];
  final Color popUpBG = Colors.black26;
  final Color popUpCardBG = Colors.white;
  final Color leaveDetailsBG = Colors.white;
  Color infoIconPaySlip = Colors.black26;

  final List<Color> waveGradient = const [
    Color(0x805ce1e6),
    Color(0x80ffffff),
  ];
  final List<Color> taxDetailsBG = const [
    Color(0x805ce1e6),
    Color(0x80ffffff),
  ];
  final List<Color> paySlipDetailsBG = const [
    Color(0x805ce1e6),
    Color(0x80ffffff),
  ];
  final List<Color> bannerGradient = const [
    Color(0xFF5ce1e6),
    Color(0x805ce1e6),
  ];
  final List<Color> categoryGradient = const [
    Color(0xFF5ce1e6),
    Color(0x805ce1e6),
  ];
  final List<Color> buttonGradient = const [
    Color(0xFF5ce1e6),
    Color(0x805ce1e6),
  ];
  final List<Color> payslipExpandable = const [
    Color(0xFFa6a6a6),
    Color(0x805ce1e6),
  ];
  final List<Color> buttonGradientApproved = const [
    Color(0xFF5ce1e6),
    Color(0xFF7ED957),
  ];
  final List<Color> buttonPending = const [
    Color(0xFFf00000),
    Color(0xFFEE0000),
  ];
  final List<Color> buttonGradientRejected = const [
    Color(0xFFFF3131),
    Color(0xFFFF914D),
  ];
  final List<Color> dividerGradient = const [
    Color(0xFF5ce1e6),
    Color(0x805ce1e6),
  ];
  final Color orangeGradient = const Color(0xFFFF6B6B);

  // UI Colors
  final Color welcomeText = const Color(0xFF5ce1e6);
  final List<Color> textFieldBorderGradient = const [
    Color(0xFF5ce1e6),
    Color(0x805ce1e6),
  ];
  final Color textFieldBorder = const Color(0xFF5ce1e6);
  final Color textFieldLabel = const Color(0xFF9E9E9E);
  final Color appGradientStart = const Color(0xFF5ce1e6);
  final Color appGradientEnd = const Color(0x805ce1e6);

  ColorScheme? kColorScheme;

  AppThemeBlue() {
    kColorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: appColor,
      onPrimary: Colors.white,
      secondary: appGradientEnd,
      onSecondary: Colors.black,
      surface: Colors.white,
      onSurface: lightGrey,
      error: Colors.red,
      onError: Colors.white,
    );
  }

  ThemeData get lightTheme => ThemeData(
        textTheme: GoogleFonts.dmSansTextTheme(),
        primaryColor: appThemeLight,
        colorScheme: kColorScheme,
        cardColor: kColorScheme?.surface,
        cardTheme: CardThemeData(color: kColorScheme?.surface),
        scaffoldBackgroundColor: appBG,
        appBarTheme: AppBarTheme(
          backgroundColor: appBG,
        ),
      );
}

class AppThemeOrange {
  Color grey = Colors.grey.shade200;

  final Color darkGrey = const Color(0XFF232323);
  final Color appBG = Colors.white;
  final Color lightGrey = const Color(0XFF1A502F);

  final Color white = const Color(0XFFFFFFFF);
  final Color white54 = Colors.white54;
  final Color black = const Color(0xFF000000);
  final Color black87 = Colors.black87;
  final Color black26 = Colors.black26;
  final Color black54 = Colors.black54;
  final Color green = const Color(0xFF4CAF50);
  final Color successBG = const Color(0xFF004AAD);
  final Color calendarApproved = const Color(0xFF7ED957);
  final Color calendarHoliday = const Color(0xFFBBCCDD);
  final Color calendarPending = const Color(0xFFFFde59);
  final Color calendarRejected = const Color(0xFFFF3131);
  final Color calendarOvertime= const Color(0xFF5ce1e6);

  Color greyBox = const Color(0XFFBBBBBC);
  final Color orange = const Color(0XFFf46545);
  final Color red = const Color(0xFFFF3131); // optional fallback

  // Core theme color for this theme
  final Color appGradient = const Color(0xFFFF9A6B);
  final Color appColor = const Color(0xFFFF9A6B);
  Color appThemeLight = const Color(0xFFFF9A6B);

  final Color gradientBlue = const Color(0XFF004A75);
  final List<Color> popUp1 = const [Color(0XFFFFA07A), Color(0XFFFF6B6B)];

  // payslip
  final List<Color> popUp1Border = const [
    Color(0x80FF9A6B),
    Color(0x80FF9A6B),
  ];
  final List<Color> popUp2Border = const [
    Color(0x80FF9A6B),
    Color(0x80FF9A6B),
  ];
  final List<Color> popUp3Border = const [
    Color(0x80FF9A6B),
    Color(0x80FF9A6B),
  ];
  final Color popUpBG = Colors.black26;
  final Color popUpCardBG = Colors.white;
  final Color leaveDetailsBG = Colors.white;
  Color infoIconPaySlip = Colors.black26;

  final List<Color> waveGradient = const [
    Color(0x80FF9A6B),
    Color(0x80FF9A6B),
  ];
  final List<Color> taxDetailsBG = const [
    Color(0x80FF9A6B),
    Color(0x80FF9A6B),
  ];
  final List<Color> paySlipDetailsBG = const [
    Color(0x80FF9A6B),
    Color(0x80FF9A6B),
  ];
  final List<Color> bannerGradient = const [
    Color(0xFFFF6B6B),
    Color(0xFFFF9A6B),
  ];
  final List<Color> categoryGradient = const [
    Color(0xFFFF6B6B),
    Color(0xFFFF9A6B),
  ];
  final List<Color> buttonGradient = const [
    Color(0xFFFF3131),
    Color(0xFFFF914D),
  ];
  final List<Color> payslipExpandable = const [
    Color(0xFFA6A6A6),
    Color(0x805ce1e6),
  ];
  final List<Color> buttonGradientApproved = const [
    Color(0xFF009FB2),
    Color(0xFF7ED957),
  ];
  final List<Color> buttonPending = const [
    Color(0xFFFF914D),
    Color(0xFFFFA07A),
  ];
  final List<Color> buttonGradientRejected = const [
    Color(0xFFFF3131),
    Color(0xFFFF914D),
  ];
  final List<Color> dividerGradient = const [
    Color(0xFFFF6B6B),
    Color(0xFFFF9A6B),
  ];
  final Color orangeGradient = const Color(0xFFFF6B6B);

  // UI colors
  final Color welcomeText = const Color(0xFFFF9A6B);
  final List<Color> textFieldBorderGradient = const [
    Color(0xFFFF9A6B),
    Color(0xFFFF9A6B),
  ];
  final Color textFieldBorder = const Color(0xFFFF3131);
  final Color textFieldLabel = const Color(0xFF9E9E9E);
  final Color appGradientStart = const Color(0xFFFF9A6B);
  final Color appGradientEnd = const Color(0xFFFF6B6B);

  ColorScheme? kColorScheme;

  AppThemeOrange() {
    kColorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: appColor,
      onPrimary: Colors.white,
      secondary: appGradientEnd,
      onSecondary: Colors.white,
      surface: Colors.white,
      onSurface: lightGrey,
      error: Colors.red,
      onError: Colors.white,
    );
  }

  ThemeData get lightTheme => ThemeData(
      textTheme: GoogleFonts.dmSansTextTheme(),
      primaryColor: appThemeLight,
      colorScheme: kColorScheme,
      cardColor: kColorScheme?.surface,
      cardTheme: CardThemeData(color: kColorScheme?.surface),
      scaffoldBackgroundColor: appBG,
      appBarTheme: AppBarTheme(
        backgroundColor: appBG,
      ));
}
