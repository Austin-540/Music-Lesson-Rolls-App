import 'package:flutter/material.dart';
import 'package:glowy_borders/glowy_borders.dart';
import 'package:music_lessons_attendance/home_page.dart';
import 'package:url_launcher/url_launcher.dart';
import 'edit_lessons_page.dart';
import 'reset_lessons_page.dart';

class FirstLoginOfYearPage extends StatefulWidget {
  const FirstLoginOfYearPage({super.key});

  @override
  State<FirstLoginOfYearPage> createState() => _FirstLoginOfYearPageState();
}

class _FirstLoginOfYearPageState extends State<FirstLoginOfYearPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            
            padding: const EdgeInsets.all(8.0),
            child: AnimatedGradientBorder(
              gradientColors: const [Colors.red, Colors.blue, Colors.purple],
              glowSize: 20,
              borderRadius: const BorderRadiusGeometry.all(Radius.circular(15)),
              child: Card(

                        
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                              Text("Looks like this is your first time logging in for ${DateTime.now().year}", style: const TextStyle(fontSize: 25),),
                              const Text("Which option do you want to do?",),
                              TextButton(onPressed: ()=>launchUrl(Uri.parse("https://app.shcmusiclessonrolls.com/",), webOnlyWindowName: "_self"), child: const Text("Ignore")),
                              const SizedBox(height: 10,),
                  TextButton(onPressed: ()=>Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const EditLessonsPage()), (route) => false), child: const Text("Edit Existing Lessons")),
                  const SizedBox(height: 10,),
                  TextButton(onPressed: ()=>Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const ResetLessonsPage()), (route) => false), child: const Text("Reset Lessons (You will get a preview before it actually resets everything)"))
                  ],),
                ),
              
              ),
            ),
          ),
        ],
      ));
  }
}