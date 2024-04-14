import 'dart:async';
import 'package:adaptive_theme/adaptive_theme.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_profile_picture/flutter_profile_picture.dart';
import 'package:music_lessons_attendance/one_off_lesson_page.dart';
import 'package:music_lessons_attendance/uploading_csv_page.dart';
import 'package:quds_popup_menu/quds_popup_menu.dart';
import 'new_lesson_marking.dart';
import 'dart:io';
import 'edit_lessons_page.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';

import 'package:flutter/material.dart';
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
  Future? logInData;

  @override
  void initState() {
    super.initState();
    logInData = logIn();
  }

  String getPlatform() {
    String platform = "Undefined";
    if (kIsWeb) {
      platform = "Web";
    }
                    if(Platform.isWindows) {
                      platform = "Windows";
                    } else if (Platform.isLinux) {
                      platform = "Linux";
                    } else if (Platform.isAndroid) {
                      platform = "Android";
                    }
    return platform;
  }
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

      final latestVersionRecordList = await pb.collection('current_version').getFullList(
  sort: '-created',
);
      String? fss_version = await FlutterSecureStorage().read(key: "currentVersion");
      
      final latestVersion = latestVersionRecordList[0].data['current_version'];
      if (latestVersion != version) {
        if (!context.mounted) return;
        showDialog(
            context: context,
            builder: (context) => AlertDialog(
                  title: const Text("Please update"),
                  content: Text(
                      "You are using an outdated version of the website. You may need to restart your web browser for it to update.\n\nYour website version: $version\nLatest version: $latestVersion"),
                  actions: [kIsWeb? const SizedBox(): TextButton(onPressed: (){
                    launchUrl(Uri.parse("https://github.com/Austin-540/Austin-Scholarship-2023/releases/download/latest/Latest${getPlatform()}.zip"));
                    }, child: Text("Download latest ${getPlatform()} release"))],
                ));
      } else {
        if (fss_version != version) {
      FlutterSecureStorage().write(key: "currentVersion", value: version);
      showDialog(context: context, 
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text("The app was updated"),
        content: Text(latestVersionRecordList[0].data['change_notes']),
        actions: [TextButton(onPressed: ()=>Navigator.pop(context), child: Text("OK"))],
      ));
      }
      }

      final checkForCustomError = await http
          .get(Uri.parse("https://austin-540.github.io/Database-Stuff/"));
      //Allows me to set a custom error message if something breaks
      if (checkForCustomError.body == "OK\n") {
        return authDataMap; //finish the FutureBuilder
      } else {
        if (!context.mounted) return;
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
    pb.authStore.clear();
    await Future.delayed(const Duration(milliseconds: 500));
    if (!context.mounted) return;
    kIsWeb? launchUrl(Uri.parse("app.shcmusiclessonrolls.com/",), webOnlyWindowName: "_self"):
    
    showDialog(
      barrierDismissible: false,
      context: context, builder: (context) => const AlertDialog(
      title: Text("Automatic restart isn't supported here."),
      content: Text("Please close the app. When you restart the app you will be taken to the login screen. Your login details have been deleted."),
      ));
  }

  Future getNameForMenu() async {
    String username = "Undefined";
    const storage = FlutterSecureStorage();
    final themeFromFSS = await storage.read(key: "theme");
    if (themeFromFSS == "dark") {
      if (!context.mounted) return;
      AdaptiveTheme.of(context).setDark();
    } else {
      if (!context.mounted) return;
      AdaptiveTheme.of(context).setLight();
    }



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
        batch: 1000,
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
                                                return const AlertDialog(
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
                                    title: const Text("One Off Lessons"), 
                                    leading: Icon(Icons.person_add_alt),
                                    onPressed: ()=>Navigator.push(context,MaterialPageRoute(builder:(context) => OneOffLessonPage()))),
                                  QudsPopupMenuItem(
                                    title: const Text("Open Spreadsheet"), onPressed: () {launchUrl(Uri.parse("https://docs.google.com/spreadsheets/d/1dVxlgpGOyiAyGYhhiIW931gFhbEWHQL0oqVbnh2Qtlw/"));},
                                    leading: const Icon(Icons.table_chart_outlined)
                                  ),
                                  QudsPopupMenuItem(
                                    title: const Text("Edit Lessons"),
                                    leading: const Icon(Icons.edit_outlined),
                                    onPressed: () => Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const EditLessonsPage()), (route) => false)
                                  ),
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
                                      if (!context.mounted) return;
                                      showDialog(
                                          context: context,
                                          builder: (context) => Dialog(
                                                child: Text(
                                                    "You can send an email to $recipientEmail"),
                                              ));
                                    }
                                  }),
                                  QudsPopupMenuItem(
                                    title: Theme.of(context).brightness == Brightness.light? const Text("Dark Mode"): const Text("Light Mode"),
                                    leading: Theme.of(context).brightness == Brightness.light? const Icon(Icons.dark_mode_outlined): const Icon(Icons.light_mode_outlined),
                                    onPressed: () {
                                      const storage = FlutterSecureStorage();
                                      setState(() {
                                         if(Theme.of(context).brightness == Brightness.dark) {
                                      AdaptiveTheme.of(context).setLight();
                                      storage.write(key: "theme", value: "light");
                                     } else {
                                      AdaptiveTheme.of(context).setDark();
                                      storage.write(key: "theme", value: "dark");
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
                        },
                        child: const Icon(Icons.error_outline));
                  } else {
                    return GestureDetector(
                      child: const CircularProgressIndicator(),
                      onTap: () {
                        deleteSavedData();
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
            future: logInData,
            initialData: null,
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.hasData) {
                return RefreshIndicator(
                  onRefresh: () async {
                    setState(() {});
                    return Future.delayed(const Duration(milliseconds: 700));
                    },
                  child: 
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
                      
                 
                );
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
        return ListView(
          addAutomaticKeepAlives: true,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: paddingWidth),
                child: Column(
                  children: [
                    for (int index=0; index<lessonList.length; index++) ... [
                        
                        getLessonStatus(index) == "Upcoming" ||
                          getLessonStatus(index) == "Overdue"
                      ? //upcoming or overdue (hiding completed)
                      NewLessonInList(
                          details: lessonList[index], status: getLessonStatus(index))
                      : const SizedBox()
                  ]
                  ],
                ),
              )
        
            
                
            ]
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
