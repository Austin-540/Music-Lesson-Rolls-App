import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:music_lessons_attendance/main.dart' as app;
import 'dart:io';


void main() {
  String password = File("/Users/austin/Programming/music_lessons_attendance/integration_test/password.txt").readAsLinesSync()[0];

  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Login Test - Looking for failed login', () {
    testWidgets('Try to login with no/bad/good details',
        (tester) async {
        const storage = FlutterSecureStorage();
        await storage.deleteAll();
      app.main();
      await tester.pumpAndSettle();


      expect(find.textContaining('Login'), findsNWidgets(2));

  
      //Expect nothing to happen if login triggered after doing nothing


      expect(find.byType(TextFormField), findsNWidgets(2));

      await tester.enterText(find.byType(TextFormField).first, "testing@example.com");
      await tester.enterText(find.byType(TextFormField).last, "wrong_password");
      final loginButton = find.bySemanticsLabel("Login Button");
      // Emulate a tap on the floating action button.
      await tester.tap(loginButton);
      
      await tester.pumpAndSettle();

      expect(find.text("Something went wrong"), findsOneWidget);




      await tester.tap(find.byType(ElevatedButton).first);
      await tester.pumpAndSettle();

      expect(find.byType(TextFormField), findsNWidgets(2));

      await tester.enterText(find.byType(TextFormField).first, "testing@example.com");
      await tester.enterText(find.byType(TextFormField).last, password);

      // Emulate a tap on the floating action button.
      await tester.tap(find.bySemanticsLabel("Login Button"));
      
      await tester.pumpAndSettle();


      expect(find.textContaining("Testing"), findsOneWidget);

      
    });
  });
}