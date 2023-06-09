import 'package:flutter/material.dart';



class MoreDetailedLessonsPage extends StatefulWidget {
  const MoreDetailedLessonsPage({super.key});

  @override
  State<MoreDetailedLessonsPage> createState() => _MoreDetailedLessonsPageState();
}

class _MoreDetailedLessonsPageState extends State<MoreDetailedLessonsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("More Options",), backgroundColor: Theme.of(context).colorScheme.inversePrimary),
      body: ListView(
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton.icon(
          
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => Placeholder())), 
                icon: Icon(Icons.add), 
                label: Text("Mark a one-off lesson")
                ),
            ),
          )
          
        ],
      ),
    );
  }
}