import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:music_lessons_attendance/home_page.dart';

void main() {
  testWidgets('Multiple Students Test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      MaterialApp(home: LessonDetailsInList(instrument: "Trumpet", time: "12:30", status: "Upcoming", numberOfStudents: "5")));


    expect(find.text('Trumpet'), findsOneWidget);
    expect(find.text('12:30'), findsOneWidget);
    expect(find.text('Upcoming'), findsOneWidget);
    expect(find.text('5 Students'), findsOneWidget);


    // await tester.tap(find.byType(GestureDetector));
    // await tester.pumpAndSettle();

    // expect(find.byWidget(Placeholder()), findsOneWidget);
    //Uncomment this when more is implemented
  });

  testWidgets('Single Student Test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(MaterialApp(home: LessonDetailsInList(instrument: "Trumpet", time: "12:30", status: "Upcoming", numberOfStudents: "1")));


    expect(find.text('Trumpet'), findsOneWidget);
    expect(find.text('12:30'), findsOneWidget);
    expect(find.text('Upcoming'), findsOneWidget);
    expect(find.text('1 Student'), findsOneWidget);


    // await tester.tap(find.byType(GestureDetector));
    // await tester.pumpAndSettle();

    // expect(find.byWidget(Placeholder()), findsOneWidget);
    //Uncomment this when it is implemented
  });
}
