import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:music_lessons_attendance/home_page.dart';

void main() {
  testWidgets('Multiple Students Test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      MaterialApp(home: LessonDetailsInList(instrument: "Trumpet", time: "2359",  //Time set to max so it always says upcoming
      lessonDetails: {"id":"rgwldcvo3hsycqi","created":"2023-06-07 09:02:16.823Z","updated":"2023-06-07 09:02:16.823Z","collectionId":"as04pbul6udp6bt","collectionName":"lessons","expand":{"students":[{"id":"xi3cfl60750ax2j","created":"2023-06-07 09:02:16.798Z","updated":"2023-06-07 09:02:16.798Z","collectionId":"4kiqg55j5hqvh5h","collectionName":"students","expand":{},"homeroom":"00EXM","name":"Junior Jazz Band"},{"id":"1i3cfl60750ax2j","created":"2023-06-07 09:02:16.798Z","updated":"2023-06-07 09:02:16.798Z","collectionId":"4kiqg55j5hqvh5h","collectionName":"students","expand":{},"homeroom":"00EXM","name":"Fake Junior Jazz Band"}]},"instrument":"Guitar","students":["xi3cfl60750ax2j"],"teacher":"q5z39hisfadxgf9","time":"0730","weekday":"Monday"}, 
      numberOfStudents: "2", status: "Upcoming", showTeacher: false,)
      ));

    expect(find.byType(Text), findsNWidgets(4));
    expect(find.text('Trumpet'), findsOneWidget);
    expect(find.text('11:59 PM'), findsOneWidget);
    expect(find.text('2 Students'), findsOneWidget);


    // await tester.tap(find.byType(GestureDetector));
    // await tester.pumpAndSettle();

    // expect(find.byWidget(Placeholder()), findsOneWidget);
    //Uncomment this when more is implemented
  });

  testWidgets('Single Student Test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(MaterialApp(home: LessonDetailsInList(
      instrument: "Trumpet", time: "2359", //Same as above
      lessonDetails: {"id":"rgwldcvo3hsycqi","created":"2023-06-07 09:02:16.823Z","updated":"2023-06-07 09:02:16.823Z","collectionId":"as04pbul6udp6bt","collectionName":"lessons","expand":{"students":[{"id":"xi3cfl60750ax2j","created":"2023-06-07 09:02:16.798Z","updated":"2023-06-07 09:02:16.798Z","collectionId":"4kiqg55j5hqvh5h","collectionName":"students","expand":{},"homeroom":"00EXM","name":"Junior Jazz Band"}]},"instrument":"Guitar","students":["xi3cfl60750ax2j"],"teacher":"q5z39hisfadxgf9","time":"0730","weekday":"Monday"}, numberOfStudents: "1", status: "Upcoming", showTeacher: false,)));

    expect(find.byType(Text), findsNWidgets(4));
    expect(find.text('Trumpet'), findsOneWidget);
    expect(find.text('11:59 PM'), findsOneWidget);
    expect(find.text('1 Student'), findsOneWidget);


    // await tester.tap(find.byType(GestureDetector));
    // await tester.pumpAndSettle();

    // expect(find.byWidget(Placeholder()), findsOneWidget);
    //Uncomment this when it is implemented
  });

  

    
}
