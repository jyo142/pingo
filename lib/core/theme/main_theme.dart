import 'package:flutter/material.dart';

final ThemeData mainTheme = ThemeData(
  colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
  useMaterial3: true,
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF5B5BD6),
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 0,
    ),
  ),
);

// extension CustomButtonStyles on ButtonThemeData {
//   ButtonStyle get secondaryButtonStyle {
//     return OutlinedButton.styleFrom(
//       primary: const Color(0xFFFFFFFF),
//       foregroundColor: const Color(0xFFA7BAC2), //adding this would work

//       backgroundColor: const Color(0xFFFFFFFF),
//       side: const BorderSide(width: 1.0, color: Color(0xFFA7BAC2)),
//       textStyle: const TextStyle(
//         fontSize: 16.0,
//         letterSpacing: .5,
//         fontFamily: "Outfit",
//         fontWeight: FontWeight.w600,
//         color: Colors.black,
//       ),
//     );
//   }

//   ButtonStyle get errorButtonStyle {
//     return OutlinedButton.styleFrom(
//       primary: const Color(0xFFFFFFFF),
//       foregroundColor: Color(0xFFFF4D53), //adding this would work
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28.0)),
//       padding: EdgeInsets.fromLTRB(100.0, 15.0, 100.0, 15.0),
//       backgroundColor: const Color(0xFFFEDCDD),
//       side: const BorderSide(width: 1.0, color: Color(0xFFA7BAC2)),
//       textStyle: const TextStyle(
//         fontSize: 16.0,
//         letterSpacing: .5,
//         fontFamily: "Outfit",
//         fontWeight: FontWeight.w600,
//         color: Color(0xFFFF4D53),
//       ),
//     );
//   }
// }
