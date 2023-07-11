import 'package:flutter/material.dart';
import 'package:file_selector/file_selector.dart';
import 'globals.dart';
import 'package:http/http.dart' as http;

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
                  label: Text("Select file")): Column(
                    children: [
                      Text(file!.name, style: TextStyle(fontSize: 20),),
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: ElevatedButton.icon(onPressed: () {Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => UploadingLoadingPage(file: file)), (route) => false);}, icon: Icon(Icons.upload), label: Text("Upload")),
                      )
                    ],
                  )),
        )
      ]),
    );
  }
}

class UploadingLoadingPage extends StatefulWidget {
  final file;
  const UploadingLoadingPage({super.key, required this.file});

  @override
  State<UploadingLoadingPage> createState() => _UploadingLoadingPageState();
}

class _UploadingLoadingPageState extends State<UploadingLoadingPage> {

Future uploadFile() async {
  final bytesFile = await widget.file.readAsBytes();
final record = await pb.collection('csv_files').create(
  files: [http.MultipartFile.fromBytes(
    "field", bytesFile, filename: "csv_file.csv"
    )]);
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Uploading"), backgroundColor: Theme.of(context).colorScheme.inversePrimary,),
      body: FutureBuilder(
        future: uploadFile(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            return Center(child: Icon(Icons.check),);
          } else if (snapshot.hasError) {
            return Center(child: Icon(Icons.sms_failed),);
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}