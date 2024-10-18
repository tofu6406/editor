import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';

class CustomTextSpan {
  const CustomTextSpan({
    required this.text,
  });

  final String text;
  static double fontSize = 14;
  static Color color = const Color(0xff111111);

  /// URL用のTextSpan
  static TextSpan urlTextSpan(String text, {required Function() onTap}) {
    return TextSpan(
      text: text,
      style: TextStyle(
        fontSize: fontSize,
        color: Colors.blue,  // リンクは青色
        decoration: TextDecoration.underline,  // 下線をつける
      ),
      recognizer: TapGestureRecognizer()..onTap = onTap,  // タップ時の処理
    );
  }

  /// 通常のTextSpan
  static TextSpan normalTextSpan(String text) {
    return TextSpan(
      text: text,
      style: TextStyle(
        fontSize: fontSize,
        color: color,
      ),
    );
  }
}
