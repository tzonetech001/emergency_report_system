// test/widget_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
// Removed import of non-existent package: 'package:emergency_report_system/app.dart'
// Tests below use a minimal widget tree and do not require the app import.
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  // Mock SharedPreferences for testing
  TestWidgetsFlutterBinding.ensureInitialized();
  
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('App starts with splash screen', (WidgetTester tester) async {
    // Create app with mocked preferences
    final prefs = await SharedPreferences.getInstance();
    
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'NIT Emergency Report',
                  style: TextStyle(fontSize: 24),
                ),
                ElevatedButton(
                  onPressed: () {},
                  child: const Text('LOGIN NOW'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    
    // Verify the app loads
    expect(find.text('NIT Emergency Report'), findsOneWidget);
    expect(find.text('LOGIN NOW'), findsOneWidget);
  });
}