import 'package:flutter/material.dart';

abstract final class AppTheme {
  static final _inputBorderRadius = BorderRadius.circular(4);

  static InputDecorationTheme get _inputDecorationTheme => InputDecorationTheme(
    border: OutlineInputBorder(borderRadius: _inputBorderRadius),
    contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
    isCollapsed: true,
    isDense: true,
    suffixIconConstraints: BoxConstraints(),
  );

  static MenuButtonThemeData get _menuButtonTheme => MenuButtonThemeData(
    style: ButtonStyle(
      padding: .all(.symmetric(horizontal: 8, vertical: 8)),
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
