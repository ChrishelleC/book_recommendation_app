import 'package:flutter/material.dart';
import 'constants.dart';

// Define missing constants
const Color darkBackgroundColor = Color(0xFF121212);
const Color darkCardColor = Color(0xFF1E1E1E);
const Color secondaryAccentColor = Color(0xFF03DAC6);
const TextStyle bodyStyle = TextStyle(
  fontSize: 16,
  color: textColor,
  height: 1.5,
);

ThemeData _createTheme({
  required Brightness brightness,
  required Color primaryColor,
  required Color backgroundColor,
  required Color cardColor,
  required Color textColor,
  required Color navigationBarColor,
  required Color secondaryColor,
}) {
  final isDark = brightness == Brightness.dark;
  final borderRadius = BorderRadius.circular(buttonBorderRadius);
  final roundedBorder = RoundedRectangleBorder(borderRadius: borderRadius);
  final appBarShape = const RoundedRectangleBorder(
    borderRadius: BorderRadius.only(
      bottomLeft: Radius.circular(16),
      bottomRight: Radius.circular(16),
    ),
  );
  
  const buttonPadding = EdgeInsets.symmetric(
    horizontal: defaultPadding * 1.5,
    vertical: defaultPadding * 0.8,
  );
  const buttonTextStyle = TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 16,
    letterSpacing: 0.5,
  );
  
  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    primaryColor: primaryColor,
    colorScheme: isDark 
      ? ColorScheme.dark(
          primary: primaryColor,
          secondary: secondaryColor,
          surface: cardColor,
          error: errorColor,
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onSurface: Colors.white,
          onError: Colors.white,
        )
      : ColorScheme.light(
          primary: primaryColor,
          secondary: secondaryColor,
          surface: Colors.white,
          error: errorColor,
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onSurface: textColor,
          onError: Colors.white,
        ),
    scaffoldBackgroundColor: backgroundColor,
    cardTheme: CardTheme(
      color: cardColor,
      elevation: 1.5,
      shape: roundedBorder,
      shadowColor: primaryColor.withOpacity(0.2),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: isDark ? cardColor : primaryColor,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      toolbarHeight: 64.0,
      shape: appBarShape,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 2,
        shape: roundedBorder,
        padding: buttonPadding,
        textStyle: buttonTextStyle,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryColor,
        side: BorderSide(color: primaryColor, width: 1.5),
        shape: roundedBorder,
        padding: buttonPadding,
        textStyle: buttonTextStyle,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primaryColor,
        textStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: isDark ? const Color(0xFF2A2A2A) : Colors.white,
      border: OutlineInputBorder(
        borderRadius: borderRadius,
        borderSide: BorderSide(color: isDark ? Colors.grey[700]! : Colors.grey[300]!),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: borderRadius,
        borderSide: BorderSide(color: isDark ? Colors.grey[700]! : Colors.grey[300]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: borderRadius,
        borderSide: BorderSide(color: primaryColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: borderRadius,
        borderSide: BorderSide(color: errorColor, width: 1),
      ),
      contentPadding: const EdgeInsets.all(16),
      labelStyle: isDark ? const TextStyle(color: Colors.grey) : null,
      hintStyle: isDark ? TextStyle(color: Colors.grey[500]) : null,
    ),
    textTheme: isDark 
      ? const TextTheme(
          displayLarge: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
          displayMedium: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
          bodyLarge: TextStyle(fontSize: 16, color: Colors.white, height: 1.5),
          bodyMedium: TextStyle(fontSize: 14, color: Colors.white70, height: 1.5),
          labelLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
        ) 
      : const TextTheme(
          displayLarge: headingStyle,
          displayMedium: subheadingStyle,
          bodyLarge: bodyStyle,
          bodyMedium: TextStyle(fontSize: 14, color: textColor, height: 1.5),
          labelLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor),
        ),
    chipTheme: ChipThemeData(
      backgroundColor: isDark ? cardColor : primaryColor.withOpacity(0.1),
      selectedColor: isDark ? primaryColor.withOpacity(0.3) : primaryColor.withOpacity(0.25),
      disabledColor: isDark ? Colors.grey[800] : Colors.grey[200],
      labelStyle: TextStyle(color: isDark ? Colors.white : textColor),
      secondaryLabelStyle: TextStyle(color: primaryColor),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: navigationBarColor,
      elevation: 8,
      selectedItemColor: primaryColor,
      unselectedItemColor: isDark ? Colors.grey[500] : Colors.grey[600],
      selectedIconTheme: const IconThemeData(size: 28),
      unselectedIconTheme: const IconThemeData(size: 24),
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
    ),
    tabBarTheme: TabBarTheme(
      labelColor: primaryColor,
      unselectedLabelColor: isDark ? Colors.grey[400] : Colors.grey[600],
      indicatorSize: TabBarIndicatorSize.tab,
      indicator: BoxDecoration(
        border: Border(bottom: BorderSide(color: primaryColor, width: 3)),
      ),
    ),
    iconTheme: IconThemeData(color: primaryColor, size: 24),
    dividerTheme: DividerThemeData(
      color: isDark ? Colors.grey[800] : Colors.grey[300],
      thickness: 1,
      space: 24,
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: isDark ? Colors.grey[900] : Colors.grey[800],
      contentTextStyle: const TextStyle(color: Colors.white),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      behavior: SnackBarBehavior.floating,
    ),
  );
}

final ThemeData lightTheme = _createTheme(
  brightness: Brightness.light,
  primaryColor: primaryColor,
  backgroundColor: backgroundColor,
  cardColor: cardColor,
  textColor: textColor,
  navigationBarColor: Colors.white,
  secondaryColor: accentColor,
);

final ThemeData darkTheme = _createTheme(
  brightness: Brightness.dark,
  primaryColor: accentColor,
  backgroundColor: darkBackgroundColor,
  cardColor: darkCardColor,
  textColor: Colors.white,
  navigationBarColor: darkCardColor,
  secondaryColor: secondaryAccentColor,
);