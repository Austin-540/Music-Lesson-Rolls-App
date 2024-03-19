// ignore_for_file: non_constant_identifier_names

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:music_lessons_attendance/home_page.dart';
import 'globals.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:url_launcher/url_launcher.dart';

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
  

class EditLessonsPage extends StatefulWidget {
  const EditLessonsPage({super.key});

  @override
  State<EditLessonsPage> createState() => _EditLessonsPageState();
}

class _EditLessonsPageState extends State<EditLessonsPage> {
  Future getLessonsToEdit() async {
    final resultList =
        await pb.collection('lessons').getFullList(expand: 'students', sort: 'time');
    return resultList;
  }

  String instrument = "";
  String time = "";
  String weekday ="";

  @override
  Widget build(BuildContext context) {
        double paddingWidth = 8;
    if (MediaQuery.of(context).size.width > 550) {
      paddingWidth = (MediaQuery.of(context).size.width - 550) / 2;
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.home_outlined), onPressed: () {
          kIsWeb? launchUrl(Uri.parse("app.shcmusiclessonrolls.com/",), webOnlyWindowName: "_self"):
    showDialog(
      barrierDismissible: false,
      context: context, builder: (context) => const AlertDialog(
      title: Text("Automatic restart isn't supported here."),
      content: Text("Please close the app. When you restart the app you will be taken to the home page."),
      ));
  
        },),
          title: const Text("Edit Lessons"),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary),
      body: FutureBuilder(
        future: getLessonsToEdit(),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else {
            return ListView(children: [
              const Center(child: Text("Updating a lesson here won't automatically update the Google Sheet.", textAlign: TextAlign.center,)),
              Padding(

                padding: EdgeInsets.symmetric(horizontal: paddingWidth),
                child: Column(
                  children: [
                    for (int i = 0; i < snapshot.data.length; i++) ...[
                      LessonCard(lessonData: snapshot.data[i]),
                    ],
                    Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: ElevatedButton.icon(
                          onPressed: () async {
                            var teacherProfileData = await pb.collection('users').getFullList();
                            var teacherId = teacherProfileData[0].id;
                            if (!mounted) return;
                                      
                            showDialog(context: context, builder: (context) => AlertDialog(
                              title: const Text("Add a lesson"),
                              content: Column(children: [
                                TextFormField(
                                  onChanged: (value) => instrument = value,
                                  decoration: const InputDecoration(labelText: "Instrument"),
                                ),
                                TextFormField(
                                  onChanged: (value) => time = value,
                                  decoration: const InputDecoration(labelText: "Time", hintText: "Enter the time as 4 digit 24hr time"),
                                ),
                                TextFormField(
                                  onChanged: (value) => weekday = value,
                                  decoration: const InputDecoration(labelText: "Weekday"),
                                )
                              ]),
                              actions: [
                                TextButton(onPressed: ()=>Navigator.pop(context), child: const Text("Cancel")),
                                TextButton(onPressed: ()async{
                                  try {
                                      if (int.tryParse(time) == null) {
                                        throw "Invalid time format - Time must be in 24hr time as 4 digits, with no colon.";
                              }
                                      
                                    final body = <String, dynamic>{
                                        "teacher": teacherId,
                                        "instrument": instrument,
                                        "students": [],
                                        "weekday": weekday,
                                        "time": time,
                                        "date_last_marked": "",
                                        "dont_send_email": false
                                      };
                                      
                                      await pb.collection('lessons').create(body: body);
                                      if (!mounted) return;
                                      
                                      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const EditLessonsPage()), (route) => false);
                                      
                                      
                                  } catch(e) {
                                    if (!mounted) return;
                                    showDialog(context: context, builder: (context) => AlertDialog(
                        title: const Text("Something went wrong :/"),
                        content: Text(e.toString()),));
                                  }
                                      
                                      
                                }, child: const Text("Submit"))
                              ],
                            ), );
                          },
                          icon: const Icon(Icons.add),
                          label: const Text("Add a lesson")),
                    )
                  ],
                ),
              ),
            ]);
          }
        },
      ),
    );
  }
}

class LessonCard extends StatefulWidget {
  const LessonCard({super.key, required this.lessonData});
  final RecordModel lessonData;

  @override
  State<LessonCard> createState() => _LessonCardState();
}

class _LessonCardState extends State<LessonCard> {

  @override
 void initState() {
    super.initState();
    checkboxValue = widget.lessonData.data['dont_send_email'];
 }



  Future deleteLesson(lessonID, context) async {
    try {
      await pb.collection('lessons').delete(lessonID);
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const EditLessonsPage()),
          (route) => false);
    } catch (e) {
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
                title: const Text("Something went wrong :/"),
                content: Text(e.toString()),
              ));
    }
  }

  String newLessonTime = "";
  String studentName = "";
  bool? checkboxValue;
  

  @override
  Widget build(BuildContext context) {
    
    List? studentList = widget.lessonData.expand['students'];
    studentList = studentList ?? [];
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(children: [
            Row(
              children: [
                Text(widget.lessonData.data['weekday']),
                const Spacer()
              ],
            ),
            //Time
            Row(
              children: [
                Text(
                  widget.lessonData.data['time'],
                  style: const TextStyle(fontSize: 40),
                ),
                IconButton(
                    onPressed: () {
                      showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                                title: const Text("Edit Lesson Time"),
                                content: Column(
                                  children: [
                                    const Text(
                                        "Enter the time as 4 digits in 24hr time."),
                                    TextFormField(
                                      onChanged: (value) =>
                                          newLessonTime = value,
                                    ),
                                  ],
                                ),
                                actions: [
                                  TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text("Cancel")),
                                  TextButton(
                                      onPressed: () async {
                                        try {
                                          if (int.tryParse(newLessonTime) == null) {
                                            throw "Only numbers are allowed";
                                          }
                                          await pb.collection('lessons').update(
                                              widget.lessonData.id,
                                              body: {'time': newLessonTime});
                                          Navigator.pushAndRemoveUntil(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      const EditLessonsPage()),
                                              (route) => false);
                                        } catch (e) {
                                          showDialog(
                                              context: context,
                                              builder: (context) => AlertDialog(
                                                  title: const Text(
                                                      "Something went wrong :/"),
                                                  content: Text(e.toString())));
                                        }
                                      },
                                      child: const Text("Submit"))
                                ],
                              ));
                    },
                    icon: const Icon(Icons.edit_outlined)),
                const Spacer(),
                IconButton(
                    onPressed: () async {
                      showDialog(context: context, builder: (context) => AlertDialog(
                        title: const Text("Are you sure?"),
                        content: const Text("Delete this lesson?"),
                        actions: [TextButton(onPressed: ()=>Navigator.pop(context), child: const Text("Cancel")),
                        TextButton(onPressed: ()=>deleteLesson(widget.lessonData.id, context), child: const Text("I'm sure"))],
                      ));
                    },
                    icon: const Icon(
                      Icons.delete_forever_outlined,
                      color: Colors.red,
                    ))
              ],
            ),

            //Names
            for (int x = 0; x < studentList.length; x++) ...[
              NameAndDeleteButton(
                  name: studentList[x].data['name'],
                  student_db_id: studentList[x].id,
                  studentList: studentList,
                  lessonID: widget.lessonData.id,)
            ],

            //Button to add new student
            FilledButton.icon(
                onPressed: () {
                  showDialog(context: context, builder: (context) => AlertDialog(
                    title: const Text("Add a student"),
                    content: TextFormField(decoration: const InputDecoration(label: Text("Name")),
                    onChanged: (value) => studentName = value,),

                    actions: [
                      TextButton(onPressed: () =>Navigator.pop(context), child: const Text("Cancel")),
                      TextButton(onPressed: () async{
                        try{
                           final record = await pb.collection('students').create(body: {
                            "name": studentName,
                            "homeroom": "_"
                          });

                          List listOfStudents = [];
                          var lessonDataStudents = widget.lessonData.expand['students'];
                          lessonDataStudents ??= [];

                          for (var student in lessonDataStudents) {
                            listOfStudents.add(student.id);
                          }

                          listOfStudents.add(record.id);

                          await pb.collection('lessons').update(widget.lessonData.id, 
                          body: {
                            "students": listOfStudents
                          });
                          if (!mounted) return;

                          Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context)=> const EditLessonsPage()), (route) => false);
                          



                        } catch (e) {
                          if(!mounted) return;
                          showDialog(context: context, builder: (context) => AlertDialog(
      title: const Text("Something went wrong :/"),
      content: Text(e.toString()),));
                        }



                      }, child: const Text("Submit"))
                    ],
                  ));
                },
                icon: const Icon(Icons.add),
                label: const Text("Add a student")),

                Row(
                  children: [
                    Checkbox(value: checkboxValue, onChanged: (value)async{
                      setState(() {
                        checkboxValue = value;
                      });

                      await pb.collection('lessons').update(widget.lessonData.id,
                      body: {
                        'dont_send_email': value
                      });
                      if (!mounted) return;
                      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const EditLessonsPage()), (route) => false);
                    }),
                    const Text("This lesson is outside school time"),
                    const Spacer(),
                    IconButton(onPressed: () {
                      showDialog(context: context, builder: (context) => AlertDialog(
                        title: const Text("'This lesson is outside school time' option"),
                        content: const Text("This option is false by default. It tells the app not to send an email to Ms Relf.\n\nSet this to true if the lesson will exclusively take place before 8:40AM or after 3:15PM.\n\nThis will show a red asterix next to the lesson time."),
                        actions: [TextButton(onPressed: () =>Navigator.pop(context), child: const Text("OK"))],
                      ));
                    }, icon: const Icon(Icons.help_outline))
                  ],
                )

            //Switch for sending email
          ]),
        ),
      ),
    );
  }
}

class NameAndDeleteButton extends StatefulWidget {
  const NameAndDeleteButton(
      {super.key, required this.name, required this.student_db_id, required this.studentList, required this.lessonID});
  final String name;
  final String student_db_id;
  final studentList;
  final lessonID;

  @override
  State<NameAndDeleteButton> createState() => _NameAndDeleteButtonState();
}

class _NameAndDeleteButtonState extends State<NameAndDeleteButton> {
  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Text(widget.name),
      const Spacer(),
      IconButton(
          onPressed: () async{
            try {
            List newStudentList = widget.studentList;
            newStudentList.removeWhere((element) => element.id == widget.student_db_id);
            List formattedNewStudentList = [];
            for (var student in newStudentList) {
              formattedNewStudentList.add(student.id);
            }

            await pb.collection('lessons').update(widget.lessonID, 
            body: {
              "students": formattedNewStudentList
            });
            if (!mounted) return;
            Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const EditLessonsPage()), (route) => false);
              
            } catch (e) {
              
              if (!mounted) return;
              showDialog(context: context, builder: (context) => AlertDialog(
      title: const Text("Something went wrong :/"),
      content: Text(e.toString())));
            }

            
          },
          icon: const Icon(Icons.delete_outline))
    ]);
  }
}
