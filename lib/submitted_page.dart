import 'package:glowy_borders/glowy_borders.dart';
import 'package:music_lessons_attendance/clear_db_page.dart';
import 'package:music_lessons_attendance/home_page.dart';

import 'globals.dart';
import 'package:flutter/material.dart';

class SubmittedPage extends StatefulWidget {
  //used when submitting a regular lesson (not one off)
  const SubmittedPage(
      {super.key, required this.lessonDetails, required this.statuses});
  final Map lessonDetails;
  final List statuses;

  @override
  State<SubmittedPage> createState() => _SubmittedPageState();
}

class _SubmittedPageState extends State<SubmittedPage> {
  Future pushAwayFromPage() async {
    await Future.delayed(Duration(milliseconds: 1500));
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                const MyHomePage(title: "Home Page")),
                        (route) => false);
  }

  var alreadySubmitted = false;
  Future submitRoll() async {
    if (alreadySubmitted == true) {
      throw "Already Submitted";
    } else {
      alreadySubmitted = true;
    }
    final currentlyInDb =
        await pb.collection("rolls").getFullList(sort: '-created');
    if (currentlyInDb.isNotEmpty) {
      throw "Things currently in DB";
    }

    for (int x = 0; x < widget.lessonDetails['students'].length; x++) {
      bool? finalVar;
      if (x != widget.lessonDetails['students'].length - 1) {
        //is this the final student?
        finalVar = false;
      } else {
        finalVar = true;
      }

      final body = <String, dynamic>{
        "students": widget.lessonDetails['students'][x],
        "lesson": widget.lessonDetails['id'],
        "present": widget.statuses[x],
        "final": finalVar
      };
      await pb.collection('rolls').create(body: body);
      await pb.collection('lessons').update(widget.lessonDetails['id'], body: {
        "date_last_marked": "${DateTime.now().day}_${DateTime.now().month}"
      }); //submit that student to PB
    }
    await pb.collection('send_email_ready').create(body: {"empty": "_"});

    return "Success";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Submitting"),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: FutureBuilder(
        //wait until roll is finished submitting before showing tick
        future: submitRoll(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            return Column(
              children: [
                FutureBuilder(
                  future: pushAwayFromPage(),
                  builder: (BuildContext context, AsyncSnapshot snapshot) => Center(
                      child: 
                      Theme.of(context).brightness == Brightness.dark?
                      AnimatedGradientBorder(
                          borderSize: 2,
                          glowSize: 15,
                          borderRadius:
                              const BorderRadius.all(Radius.circular(800)),
                          gradientColors: const [
                            Colors.purple,
                            Colors.blue,
                            Colors.red,
                          ],
                          child: Container(
                              decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(800)),
                                  color:
                                      Theme.of(context).colorScheme.background),
                              child: const AnimatedCheckmark())):
                              const AnimatedCheckmark()
                              ),
                ),
              ],
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                children: [
                  const Text(
                      "Something went wrong. \nMost likely you tried to mark a roll at the same time as someone else, or tried to mark 2 rolls in too short an amount of time. Please try again in 20ish seconds.\n\nYou can also try pressing the \"Clear the backend\" button if this doesn't resolve itself."),
                  ElevatedButton(
                      onPressed: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  const MyHomePage(title: "Today's Lessons")),
                          (route) => false,
                        );
                      },
                      child: const Text("Go Back")),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: OutlinedButton(
                        onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const ClearDBPage())),
                        child: const Text("Clear the backend")),
                  )
                ],
              ),
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }
}

class AnimatedCheckmark extends StatefulWidget {
  const AnimatedCheckmark({super.key});

  @override
  State<AnimatedCheckmark> createState() => _AnimatedCheckmarkState();
}

class _AnimatedCheckmarkState extends State<AnimatedCheckmark>
    with TickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    duration: const Duration(seconds: 1),
    vsync: this,
  )..forward();
  late final Animation<double> _animation = CurvedAnimation(
    parent: _controller,
    curve: Curves.elasticOut,
  );

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _animation,
      child: const Icon(
        Icons.check,
        size: 250,
      ),
    );
  }
}
