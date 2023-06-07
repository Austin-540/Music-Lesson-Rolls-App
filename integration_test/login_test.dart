import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:music_lessons_attendance/main.dart' as app;

void main() {

  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Login Test - Looking for failed login', () {
    testWidgets('Try to login with no/bad/good details',
        (tester) async {
        final storage = new FlutterSecureStorage();
        await storage.deleteAll();
      app.main();
      await tester.pumpAndSettle();


      expect(find.text('Login'), findsNWidgets(2));

  
      //Expect nothing to happen if login triggered after doing nothing


      expect(find.byType(TextFormField), findsNWidgets(2));

      await tester.enterText(find.byType(TextFormField).first, "x@x.com");
      await tester.enterText(find.byType(TextFormField).last, "passw");
      final loginButton = find.bySemanticsLabel("Login Button");
      // Emulate a tap on the floating action button.
      await tester.tap(loginButton);
      
      await tester.pumpAndSettle();

      expect(find.text("Something went wrong"), findsOneWidget);




      await tester.tap(find.byType(ElevatedButton).first);
      await tester.pumpAndSettle();

      expect(find.byType(TextFormField), findsNWidgets(2));

      await tester.enterText(find.byType(TextFormField).first, "example@example.com");
      await tester.enterText(find.byType(TextFormField).last, "Password1");

      // Emulate a tap on the floating action button.
      await tester.tap(find.bySemanticsLabel("Login Button"));
      
      await tester.pumpAndSettle();


      expect(find.textContaining("AustinS"), findsOneWidget);

      
    });
  });
}