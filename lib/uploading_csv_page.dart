import 'package:flutter/material.dart';
import 'package:file_selector/file_selector.dart';

class UploadingCSVPage extends StatefulWidget {
  const UploadingCSVPage({super.key});

  @override
  State<UploadingCSVPage> createState() => _UploadingCSVPageState();
}

class _UploadingCSVPageState extends State<UploadingCSVPage> {
  Future pickFile() async {
    
final XFile? file =
    await openFile();
    print(file);
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
              child: ElevatedButton.icon(
                  onPressed: () {
                    pickFile();
                  },
                  icon: Icon(Icons.upload_file),
                  label: Text("Select file"))),
        )
      ]),
    );
  }
}
