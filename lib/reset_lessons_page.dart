import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:url_launcher/url_launcher.dart';
import 'globals.dart';

class ResetLessonsPage extends StatefulWidget {
  const ResetLessonsPage({super.key});

  @override
  State<ResetLessonsPage> createState() => _ResetLessonsPageState();
}

class _ResetLessonsPageState extends State<ResetLessonsPage>
 {
  List<RecordModel>? lessons;
  Future getListOfLessons() async{
    lessons = await pb.collection('lessons').getFullList();
    setState(() {});
  }
  @override
  void initState() {
    super.initState();
    getListOfLessons();
  }
  @override
  Widget build(BuildContext context) {
    lessons ??= [];
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.red, actions: [IconButton(icon: Icon(Icons.home_outlined,), onPressed: () {kIsWeb? launchUrl(Uri.parse("https://app.shcmusiclessonrolls.com/",), webOnlyWindowName: "_self"):print("auto restart doesn't work here");},)], title: Text("Reset all your lessons"),),
      body: ListView(
        children: [
          Text("To cancel, press the home button in the top right. \n\nAll of your lessons will be deleted. Please check that this is what you are expecting to see:", style: TextStyle(fontSize: 30),),
          for (var lesson in lessons!) ... [
            Card(child: Text("${lesson.getStringValue("weekday")} ${lesson.getStringValue("time")}, number of students: ${lesson.getListValue("students").length}, updated on: ${lesson.getStringValue("updated")}"))
          ]
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(onPressed: () async {
        showDialog(barrierDismissible: false,context: context, builder: (context) => AlertDialog(title: Text("Resetting..."),));
        for (var lesson in lessons!) {
          try {
            await pb.collection("lessons").delete(lesson.id);
          } catch (e) {}
        }
        launchUrl(Uri.parse("https://app.shcmusiclessonrolls.com/",), webOnlyWindowName: "_self");
      }, label: Text("Reset (this action can't be easily reversed!!)"), backgroundColor: Colors.red,),
    );
  }
}