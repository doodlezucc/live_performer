import 'package:flutter/material.dart';

abstract final class AppTheme {
  static InputDecorationTheme get _inputDecorationTheme => InputDecorationTheme(
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
    contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
    isCollapsed: true,
    isDense: true,
    suffixIconConstraints: BoxConstraints(),
  );

  static MenuButtonThemeData get _menuButtonTheme => MenuButtonThemeData(
    style: ButtonStyle(
      padding: .all(.symmetric(horizontal: 8, vertical: 12)),
      minimumSize: .all(.zero),
      textStyle: .all(TextStyle(fontWeight: .normal)),
    ),
  );

  static ThemeData get theme => ThemeData(
    inputDecorationTheme: _inputDecorationTheme,
    menuButtonTheme: _menuButtonTheme,
    dropdownMenuTheme: DropdownMenuThemeData(
      inputDecorationTheme: _inputDecorationTheme,
      textStyle: TextStyle(fontSize: 14),
      menuStyle: MenuStyle(
        padding: .all(.zero),
        visualDensity: VisualDensity.standard,
        maximumSize: .all(Size.fromHeight(300)),
      ),
    ),
  );
}
