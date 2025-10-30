import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:farmaciaap/theme/app_theme.dart';

void main() {
  group('AppTheme', () {
    test('lightTheme has correct brightness', () {
      final theme = AppTheme.lightTheme;
      
      expect(theme.brightness, Brightness.light);
    });

    test('lightTheme uses Material 3', () {
      final theme = AppTheme.lightTheme;
      
      expect(theme.useMaterial3, true);
    });

    test('lightTheme has AppBar theme configured', () {
      final theme = AppTheme.lightTheme;
      
      expect(theme.appBarTheme, isNotNull);
      expect(theme.appBarTheme.elevation, 0);
      expect(theme.appBarTheme.centerTitle, true);
    });

    test('lightTheme has FloatingActionButton theme', () {
      final theme = AppTheme.lightTheme;
      
      expect(theme.floatingActionButtonTheme, isNotNull);
    });

    test('lightTheme has CardTheme configured', () {
      final theme = AppTheme.lightTheme;
      
      expect(theme.cardTheme, isNotNull);
      expect(theme.cardTheme.elevation, 2);
    });

    test('darkTheme has correct brightness', () {
      final theme = AppTheme.darkTheme;
      
      expect(theme.brightness, Brightness.dark);
    });

    test('darkTheme uses Material 3', () {
      final theme = AppTheme.darkTheme;
      
      expect(theme.useMaterial3, true);
    });

    test('darkTheme has AppBar theme configured', () {
      final theme = AppTheme.darkTheme;
      
      expect(theme.appBarTheme, isNotNull);
      expect(theme.appBarTheme.elevation, 0);
      expect(theme.appBarTheme.centerTitle, true);
    });

    test('darkTheme has Card theme configured', () {
      final theme = AppTheme.darkTheme;
      
      expect(theme.cardTheme, isNotNull);
      expect(theme.cardTheme.elevation, 2);
    });

    test('both themes have InputDecoration configured', () {
      expect(AppTheme.lightTheme.inputDecorationTheme, isNotNull);
      expect(AppTheme.darkTheme.inputDecorationTheme, isNotNull);
    });

    test('both themes have ElevatedButton configured', () {
      expect(AppTheme.lightTheme.elevatedButtonTheme, isNotNull);
      expect(AppTheme.darkTheme.elevatedButtonTheme, isNotNull);
    });

    test('light and dark themes have different brightness', () {
      expect(AppTheme.lightTheme.brightness, Brightness.light);
      expect(AppTheme.darkTheme.brightness, Brightness.dark);
    });

    test('both themes have TextTheme configured', () {
      expect(AppTheme.lightTheme.textTheme, isNotNull);
      expect(AppTheme.darkTheme.textTheme, isNotNull);
    });

    test('both themes have ColorScheme configured', () {
      expect(AppTheme.lightTheme.colorScheme, isNotNull);
      expect(AppTheme.darkTheme.colorScheme, isNotNull);
    });

    test('both themes have BottomSheetTheme configured', () {
      expect(AppTheme.lightTheme.bottomSheetTheme, isNotNull);
      expect(AppTheme.darkTheme.bottomSheetTheme, isNotNull);
    });
  });
}
