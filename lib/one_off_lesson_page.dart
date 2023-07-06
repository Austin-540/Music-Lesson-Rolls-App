import 'package:flutter/material.dart';

class OneOffLessonPage extends StatefulWidget {
  const OneOffLessonPage({super.key});

  @override
  State<OneOffLessonPage> createState() => _OneOffLessonPageState();
}

class _OneOffLessonPageState extends State<OneOffLessonPage> {
  var time = "hello";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("One-off Lesson"), backgroundColor: Theme.of(context).colorScheme.inversePrimary,),
      body: Column(children: [
        Center(child: Text(time, style: TextStyle(fontSize: 40),)),

        Padding(
          padding: const EdgeInsets.all(8.0),
          child: ElevatedButton.icon(label: Text("Select Time"), icon: Icon(Icons.access_time), 
          onPressed: () async {
           final timeOfDay = await showTimePicker(context: context, initialTime: TimeOfDay.now());
            setState(() {
              time = "${timeOfDay!.hour}:${timeOfDay.minute}";
            });
            })
        ),

        
      ]),
    );
  }
}