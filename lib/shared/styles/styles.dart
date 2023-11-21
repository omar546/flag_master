import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'colors.dart';

MaterialColor customColorOrange = const MaterialColor(0xFFFF3C38, {
  50: Color(0xffffeceb),
  100: Color(0xffffd8d7),
  200: Color(0xffffc5c3),
  300: Color(0xffffb1af),
  400: Color(0xffff9e9c),
  500: Color(0xffff8a88),
  600: Color(0xffff7774),
  700: Color(0xffff6360),
  800: Color(0xffff504c),
  900: Color(0xffff3c38),
});

ThemeData lightTheme = ThemeData(
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    elevation: 30,
    backgroundColor: MyColors.whiteColor,
    type: BottomNavigationBarType.fixed,
    selectedItemColor: MyColors.fire,
    unselectedItemColor: MyColors.greyColor,
    selectedLabelStyle: TextStyle(fontFamily: 'bebas'),
  ),
  appBarTheme: const AppBarTheme(
    iconTheme: IconThemeData(color: MyColors.fire),
    systemOverlayStyle: SystemUiOverlayStyle(
      statusBarColor: MyColors.whiteColor,
      statusBarIconBrightness: Brightness.dark,
    ),
    backgroundColor: MyColors.whiteColor,
    elevation: 0.0,
    titleTextStyle: TextStyle(color: MyColors.blackColor),
  ),
  scaffoldBackgroundColor: MyColors.whiteColor,
  primarySwatch: customColorOrange,
  textTheme: TextTheme(
    bodyMedium:
        const TextStyle(color: MyColors.blackColor, fontFamily: 'bitter-bold'),
    bodySmall: TextStyle(
        color: MyColors.blackColor.withOpacity(0.5), fontFamily: 'bitter'),
  ),
    inputDecorationTheme: const InputDecorationTheme(
        prefixIconColor: MyColors.blackColor,
        suffixIconColor: MyColors.blackColor,
        labelStyle: TextStyle(color: MyColors.blackColor),
    )
);
ThemeData darkTheme = ThemeData(
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      elevation: 30,
      backgroundColor: MyColors.blackColor,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: MyColors.fire,
      unselectedItemColor: MyColors.greyColor,
      selectedLabelStyle: TextStyle(fontFamily: 'bebas'),
    ),
    appBarTheme: const AppBarTheme(
      iconTheme: IconThemeData(color: MyColors.whiteColor),
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: MyColors.greyColor,
        statusBarIconBrightness: Brightness.light,
      ),
      backgroundColor: MyColors.greyColor,
      elevation: 0.0,
      titleTextStyle: TextStyle(color: MyColors.whiteColor),
    ),
    scaffoldBackgroundColor: MyColors.greyColor,
    primarySwatch: customColorOrange,
    textTheme: TextTheme(
      bodyMedium: const TextStyle(
          color: MyColors.whiteColor, fontFamily: 'bitter-bold'),
      bodySmall: TextStyle(
          color: MyColors.greyColor.withOpacity(0.5), fontFamily: 'bitter'),
    ),
    inputDecorationTheme: const InputDecorationTheme(
        prefixIconColor: MyColors.greyColor,
        suffixIconColor: MyColors.greyColor,
        labelStyle: TextStyle(color: MyColors.greyColor)));
