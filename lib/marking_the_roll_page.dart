import 'globals.dart';
import 'package:flutter/material.dart';

class MarkingRollPage extends StatefulWidget {
  final Map lessonDetails;
  const MarkingRollPage({super.key, required this.lessonDetails});

  @override
  State<MarkingRollPage> createState() => _MarkingRollPageState();
}

class _MarkingRollPageState extends State<MarkingRollPage> {
  List presentStudents = [];
  List<bool> isCheckedList =[];

  @override
  void initState() {
    super.initState();
    isCheckedList = List.filled(widget.lessonDetails['expand']['students'].length, false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text("Marking Roll"),
        ),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Text("${widget.lessonDetails['time']}", style: TextStyle(fontSize: 50),),
              Spacer(),
              Text("${widget.lessonDetails['instrument']}",style: TextStyle(fontSize: 30)),
            ],
          ),
        ),
        for (int x = 0; x< widget.lessonDetails['expand']['students'].length; x++) ... [
        Padding(
      padding: const EdgeInsets.all(4.0),
      child: Card(
        child: Row(children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(widget.lessonDetails['expand']['students'][x]['name']),
          ),
          Spacer(),
          Checkbox(value: isCheckedList[x], onChanged: (value) => setState(() {
            isCheckedList[x] = value!;
            presentStudents.add(widget.lessonDetails['expand']['students'][x].toString());
            print(presentStudents);
          }) )
        ],),
      ),
    )
        ]
      ]),
    );
  }
}
