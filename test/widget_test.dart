import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:farmaciaap/services/theme_service.dart';
import 'package:farmaciaap/theme/app_theme.dart';
import 'package:farmaciaap/screens/home_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('HomeScreen widget loads successfully', (WidgetTester tester) async {
    final themeService = ThemeService();
    
    await tester.pumpWidget(
      ChangeNotifierProvider<ThemeService>.value(
        value: themeService,
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: const HomeScreen(),
        ),
      ),
    );

    // Solo verificar que el widget se construye sin errores
    expect(find.byType(HomeScreen), findsOneWidget);
  });
}
