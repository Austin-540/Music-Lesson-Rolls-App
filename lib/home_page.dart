// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'package:adaptive_theme/adaptive_theme.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_profile_picture/flutter_profile_picture.dart';
import 'package:music_lessons_attendance/uploading_csv_page.dart';
import 'package:quds_popup_menu/quds_popup_menu.dart';
import 'package:restart_app/restart_app.dart';
import 'new_lesson_marking.dart';
import 'dart:io';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';

import 'package:flutter/material.dart';
import 'package:music_lessons_attendance/marking_the_roll_page.dart';
import 'globals.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'login_page.dart';
import 'package:pocketbase/pocketbase.dart';

import 'more_detailed_page.dart';
import 'clear_db_page.dart';
import 'package:http/http.dart' as http;

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Future logIn() async {
    
    try {
      const storage = FlutterSecureStorage();
      final String? raw = await storage.read(key: "pb_auth");
      if (raw != null && raw.isNotEmpty) {
        final decoded = jsonDecode(raw);
        final token =
            (decoded as Map<String, dynamic>)["token"] as String? ?? "";
        final model = RecordModel.fromJson(
            decoded["model"] as Map<String, dynamic>? ?? {});

        pb.authStore.save(token, model);
      } else {
        throw "no saved data";
      }

      final authData = await pb.collection('users').getFullList();

      final authDataMap = jsonDecode(authData.toString())[0];
      loggedInTeacher = authDataMap["id"];

      final latestVersion = await http.get(Uri.parse(
          "https://austin-540.github.io/Database-Stuff/current_version.html"));
      if (latestVersion.body != "$version\n") {
        showDialog(
            context: context,
            builder: (context) => AlertDialog(
                  title: const Text("Please update"),
                  content: Text(
                      "You are using an outdated version of the website. You may need to restart your web browser for it to update.\n\nYour website version: $version\nLatest version: ${latestVersion.body}"),
                ));
      }

      final checkForCustomError = await http
          .get(Uri.parse("https://austin-540.github.io/Database-Stuff/"));
      //Allows me to set a custom error message if something breaks
      if (checkForCustomError.body == "OK\n") {
        return authDataMap; //finish the FutureBuilder
      } else {
        showDialog(
            context: context,
            builder: (context) => AlertDialog(
                  title: Text(checkForCustomError.body),
                )); //show error message
      }
    } on SocketException {
      //sometimes occours when PB cant be reached, but usually its ClientException
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return const AlertDialog(
              title: Text("Internet error"),
            );
          });
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false);
    } on ClientException {
      //Occours when PB can't be reached, or PB sends an error response
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return const AlertDialog(
              title: Text("Internet Connection Error"),
            );
          });
    } catch (e) {
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false);
    }
    //first try to see if password is already saved, then if its not push to login screen
  }

  Future deleteSavedData() async {
    const storage = FlutterSecureStorage();
    await storage.delete(key: "pb_auth");
    await storage.delete(key: "username");
    await storage.deleteAll();
    pb.authStore.clear();
  }

  Future getNameForMenu() async {
    String username = "Undefined";
    const storage = FlutterSecureStorage();
    String? maybeUsername = await storage.read(key: "username");
    if (maybeUsername == null) {
      username = "Undefined";
    } else {
      username = maybeUsername;
    }
    return username;
  }

  Future getLessons() async {
    final lessonList = await pb.collection('lessons').getFullList(
        sort: '+time',
        expand: "students,teacher",
        filter: "weekday = '${DateFormat('EEEE').format(DateTime.now())}'");
    // print(lessonList);
    final fullList = jsonDecode(lessonList.toString());

    var lessons = [];

    for (int i = 0; i <= fullList.length - 1; i++) {
      if (loggedInTeacher == fullList[i]['teacher'] &&
          fullList[i]['date_last_marked'] !=
              "${DateTime.now().day}_${DateTime.now().month}") {
        lessons.add(fullList[i]);
        //loggedInTeacher check is no longer required - handled in PB permissions (keeping in case change PB permissions)
        //Date last marked is used to check wether the roll is overdue
        //eg 12 july => date_last_marked = 12_7
      }
    }
    return lessons;
  }

  String? loggedInTeacher;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text(widget.title),
          automaticallyImplyLeading: false, //don't show a back button
          actions: [
            IconButton(
                onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const MoreDetailedLessonsPage())),
                icon: const Icon(Icons.more_horiz)),
            Padding(
              padding: const EdgeInsets.fromLTRB(5, 0, 10, 0),
              child: FutureBuilder(
                future: getNameForMenu(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return Builder(
                      builder: (context) {
                        return QudsPopupButton(
                            items: [
                              QudsPopupMenuSection(
                                  titleText: snapshot.data,
                                  leading: const Icon(Icons.person_outline),
                                  subItems: [
                                    QudsPopupMenuItem(
                                        title: const Text("Log out"),
                                        leading: const Icon(Icons.logout),
                                        onPressed: () {
                                          deleteSavedData();
                                          Restart.restartApp();
                                        })
                                  ]),
                              QudsPopupMenuSection(
                                  titleText: "Server Options",
                                  leading: const Icon(Icons.cloud_outlined),
                                  subItems: [
                                    kIsWeb
                                        ? QudsPopupMenuItem(
                                            title: const Text("Upload CSV File"),
                                            leading: const Icon(Icons.upload_file),
                                            onPressed: () {
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          const UploadingCSVPage()));
                                            })
                                        : //For if the CSV can be uploaded
                                        QudsPopupMenuItem(

                                            title:
                                                const Text("Upload CSV File"),
                                            onPressed: () {
                                              showDialog(context: context,
                                              builder: (context) {
                                                return AlertDialog(
                                                  title: Text("This button only works from a web browser."),
                                                  
                                                );
                                              });
                                            },
                                            subTitle: const Text(
                                                "Only available from a web browser."),
                                            leading: const Icon(
                                                Icons.error_outline_rounded)),
                                    QudsPopupMenuItem(
                                        title: const Text("Clear The Backend"),
                                        onPressed: () => Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    const ClearDBPage())),
                                        leading: const Icon(
                                            Icons.delete_forever_outlined)),
                                    QudsPopupMenuItem(
                                        title: const Text("Manually Edit Lessons"),
                                        leading: const Icon(Icons.edit_outlined),
                                        subTitle: const Text(
                                            "Requires an admin account."),
                                        onPressed: () {
                                          launchUrl(Uri.parse(
                                              "https://app.shcmusiclessonrolls.com/_/#/collections?collectionId=as04pbul6udp6bt&filter=&sort=-created"));
                                        })
                                  ]),
                              QudsPopupMenuItem(
                                  title: const Text("App Info"),
                                  leading: const Icon(Icons.info_outline),
                                  onPressed: () {
                                    showAboutDialog(
                                        //shows the licences page also - to comply with MIT licenses etc
                                        context: context,
                                        applicationIcon:
                                            const Icon(Icons.class_outlined),
                                        applicationVersion: version,
                                        applicationLegalese:
                                            """Created by Austin-540. Check out the source code on GitHub if you want.  
                         
                                     Copyright (c) 2023 Austin-540
                                     
                                     This software is provided 'as-is', without any express or implied warranty. In no event will the authors be held liable for any damages arising from the use of this software.
                                     
                                     Permission is granted to anyone to use this software for any purpose, including commercial applications, and to alter it and redistribute it freely, subject to the following restrictions:
                                     
                                     1. The origin of this software must not be misrepresented; you must not claim that you wrote the original software. If you use this software in a product, an acknowledgment in the product documentation would be appreciated but is not required.
                                     
                                     2. Altered source versions must be plainly marked as such, and must not be misrepresented as being the original software.
                                     
                                     3. This notice may not be removed or altered from any distribution.""");
                                  },
                                  onLongPressed: () => showDialog(
                                      context: context,
                                      builder: (context) => const Dialog(
                                            child: Padding(
                                              padding: EdgeInsets.all(20.0),
                                              child: Text(
                                                "In memory of Thomas Park(he didn't die but asked to be remembered)",
                                                style: TextStyle(fontSize: 20),
                                              ), //easter egg
                                            ),
                                          ))),
                              QudsPopupMenuItem(
                                  title: const Text("Send Feedback"),
                                  leading: const Icon(Icons.feedback_outlined),
                                  onPressed: () async {
                                    final records =
                                        await pb.collection('my_email').getFullList(
                                              sort: '-created',
                                            );
                                    final recipientEmail = records[0].data['email'];
                                    try {
                                      launchUrl(Uri.parse(
                                          "mailto:$recipientEmail?subject=App%20Feedback"));
                                    } catch (e) {
                                      showDialog(
                                          context: context,
                                          builder: (context) => Dialog(
                                                child: Text(
                                                    "You can send an email to $recipientEmail"),
                                              ));
                                    }
                                  }),
                                  QudsPopupMenuItem(
                                    title: const Text("Toggle Dark Mode"),
                                    leading: const Icon(Icons.dark_mode_outlined),
                                    onPressed: () {
                                      setState(() {
                                         if(Theme.of(context).brightness == Brightness.dark) {
                                      AdaptiveTheme.of(context).setLight();
                                     } else {
                                      AdaptiveTheme.of(context).setDark();
                                     }
                                      });
                                    
                                    },
                                  )
                            ],
                            child: ProfilePicture(
                              name: snapshot.data,
                              random: true,
                              radius: 20,
                              fontsize: 20,
                            ));
                      }
                    );
                  } else if (snapshot.hasError) {
                    return GestureDetector(
                        onTap: () {
                          deleteSavedData();
                          Restart.restartApp();
                        },
                        child: const Icon(Icons.error_outline));
                  } else {
                    return GestureDetector(
                      child: const CircularProgressIndicator(),
                      onTap: () {
                        deleteSavedData();
                        Restart.restartApp();
                      },
                    );
                  }
                },
              ),
            )
          ],
        ),
        body: Center(
          child: FutureBuilder(
            //future builder for "Welcome $name"
            future: logIn(),
            initialData: null,
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.hasData) {
                return ListView(children: [
                  Column(
                    children: [
                      FutureBuilder(
                        // future builder for lessons
                        future: getLessons(),
                        initialData: null,
                        builder:
                            (BuildContext context, AsyncSnapshot snapshot) {
                          if (snapshot.hasData) {
                            //once getLessons() has completed:
                            return ListOfLessons(
                              lessonList: snapshot.data,
                              showAll: false,
                              showTeacher: false,
                            );
                          } else if (snapshot.hasError) {
                            //if getLessons() didn't work:
                            return const Text("error");
                          } else {
                            //while waiting for getLessons():
                            return const Center(
                                child: CircularProgressIndicator());
                          }
                        },
                      ),
                    ],
                  ),
                ]);
              } else {
                return const CircularProgressIndicator();
              }
            },
          ),
        ));
  }
}

class ListOfLessons extends StatelessWidget {
  final bool showTeacher;
  final List lessonList;
  final bool showAll;

  const ListOfLessons(
      {super.key,
      required this.lessonList,
      required this.showAll,
      required this.showTeacher});

  String getLessonStatus(x) {
    DateTime now = DateTime.now();
    String formattedNow = "${now.hour}".padLeft(2) +
        "${now.minute}".padLeft(
            2, "0"); //convert the time into the same format as what the DB uses

    if (lessonList[x]['weekday'] != DateFormat('EEEE').format(DateTime.now())) {
      // if looking at a lesson that isn't today
      return "...";
    } else if (lessonList[x]['date_last_marked'] == "${now.day}_${now.month}") {
      return "Completed";
    } else {
      if (int.parse(formattedNow) - 10 <= int.parse(lessonList[x]["time"])) {
        //gives a 10 minute margin before saying overdue
        return "Upcoming";
      } else {
        return "Overdue";
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    double paddingWidth = 8;
    if (MediaQuery.of(context).size.width > 550) {
      paddingWidth = (MediaQuery.of(context).size.width - 550) / 2;
    }

    if (lessonList.isNotEmpty) {
      if (showAll == false) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: paddingWidth),
          child: Column(children: [
            for (int x = 0; x <= lessonList.length - 1; x++) ...[
              getLessonStatus(x) == "Upcoming" ||
                      getLessonStatus(x) == "Overdue"
                  ? //upcoming or overdue (hiding completed)
                  NewLessonInList(
                      details: lessonList[x], status: getLessonStatus(x))
                  : const SizedBox()
            ]
          ]),
        );
      } else {
        return Column(children: [
          for (int x = 0; x <= lessonList.length - 1; x++) ...[
            NewLessonInList(details: lessonList[x], status: getLessonStatus(x))
          ]
        ]);
      }
    } else {
      //if lessonList is empty, show a message
      return const Padding(
        padding: EdgeInsets.all(20.0),
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(10.0),
            child: Text(
              "Looks like there's nothing to show",
              style: TextStyle(fontSize: 15),
            ),
          ),
        ),
      );
    }
  }
}

class LessonDetailsInList extends StatefulWidget {
  //no longer used, replaced by NewLessonInList
  const LessonDetailsInList(
      {Key? key,
      required this.instrument,
      required this.time,
      required this.lessonDetails,
      required this.numberOfStudents,
      required this.status,
      required this.showTeacher})
      : super(key: key);
  final String instrument;
  final String time;
  final Map lessonDetails;
  final String numberOfStudents;
  final String status;
  final bool showTeacher;

  @override
  State<LessonDetailsInList> createState() => _LessonDetailsInListState();
}

class _LessonDetailsInListState extends State<LessonDetailsInList> {
  Timer? timer;
  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(
        const Duration(seconds: 20), (Timer t) => setState(() {}));
  }

  @override
  void dispose() {
    super.dispose();
    timer!.cancel();
  }

  @override
  Widget build(BuildContext context) {
    String? i12hrTime;
    if (int.parse(widget.time.substring(0, 2)) > 12) {
      i12hrTime =
          "${int.parse(widget.time.substring(0, 2)) - 12}:${widget.time.substring(2, 4)} PM";
    } else if (int.parse(widget.time.substring(0, 2)) == 12) {
      i12hrTime =
          "${int.parse(widget.time.substring(0, 2))}:${widget.time.substring(2, 4)} PM";
    } else {
      i12hrTime =
          "${widget.time.substring(0, 2)}:${widget.time.substring(2, 4)} AM";
    }
    Color? colour;

    if (widget.status == "Upcoming") {
      colour = const Color.fromARGB(255, 255, 255, 255);
    } else if (widget.status == "Overdue") {
      colour = const Color.fromARGB(255, 252, 199, 199);
    } else if (widget.status == "Completed") {
      colour = const Color.fromARGB(255, 213, 255, 220);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      MarkingRollPage(lessonDetails: widget.lessonDetails)));
        },
        child: Card(
            color: colour,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Text(
                    i12hrTime,
                    style: const TextStyle(fontSize: 35),
                  ),
                ),
                const Spacer(),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                  child: Align(
                    alignment: Alignment.topRight,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(widget.instrument),
                        Text(widget.status),
                        widget.numberOfStudents == "1"
                            ? //check if the number of students is 1, and depending on that show "student(s)"
                            Text("${widget.numberOfStudents} Student")
                            : Text("${widget.numberOfStudents} Students"),
                        widget.showTeacher == false
                            ? const SizedBox()
                            : Text(widget.lessonDetails['expand']['teacher']
                                ['username']),
                      ],
                    ),
                  ),
                )
              ],
            )),
      ),
    );
  }
}
