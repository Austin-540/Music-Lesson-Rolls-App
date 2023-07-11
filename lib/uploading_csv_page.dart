import 'package:flutter/material.dart';
import 'package:file_selector/file_selector.dart';

class UploadingCSVPage extends StatefulWidget {
  const UploadingCSVPage({super.key});

  @override
  State<UploadingCSVPage> createState() => _UploadingCSVPageState();
}

class _UploadingCSVPageState extends State<UploadingCSVPage> {
  XFile? file;
  Future pickFile() async {
    file = await openFile();
    print(file!.name);
    if (file!.name.endsWith("csv")) {
      setState(() {});
    } else {
      file = null;
      showDialog(context: context, builder: (context) => Dialog(child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text("Wrong file type. CSV file required."),
      ),));
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add Lessons"),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Center(
              child: file == null? ElevatedButton.icon(
                  onPressed: () {
                    pickFile();
                  },
                  icon: Icon(Icons.upload_file),
                  label: Text("Select file")): Text(file!.name, style: TextStyle(fontSize: 20),)),
        )
      ]),
    );
  }
}
