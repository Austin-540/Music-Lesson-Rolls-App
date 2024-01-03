import 'package:flutter/material.dart';
import 'package:file_selector/file_selector.dart';
import 'package:music_lessons_attendance/home_page.dart';
import 'package:url_launcher/url_launcher.dart';
import 'globals.dart';

class UploadingCSVPage extends StatefulWidget {
  const UploadingCSVPage({super.key});

  @override
  State<UploadingCSVPage> createState() => _UploadingCSVPageState();
}

class _UploadingCSVPageState extends State<UploadingCSVPage> {
  XFile? file;
  Future pickFile() async {
    file = await openFile(); //opens the native file picker
    if (file!.name.endsWith("csv")) {
      //if file is CSV update UI, otherwise show an alert
      setState(() {});
    } else {
      file = null;
      // ignore: use_build_context_synchronously
      showDialog(
          context: context,
          builder: (context) => const AlertDialog(
                title: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text("Wrong file type. CSV file required."),
                ),
              ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Lessons"),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Center(
              child: file == null
                  ? //if file hasn't been picked yet
                  Column(
                    children: [
                      ElevatedButton.icon(
                          onPressed: () {
                            pickFile();
                          },
                          icon: const Icon(Icons.upload_file),
                          label: const Text("Select file")),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: OutlinedButton(onPressed: ()=>launchUrl(Uri.parse("https://austin-540.github.io/Database-Stuff/csv_formatting_guide.html")), child: const Text("CSV Formatting Guide")),
                          )
                    ],
                  )
                  :
                  //once file has been picked
                  Column(
                      children: [
                        Text(
                          file!.name,
                          style: const TextStyle(fontSize: 20),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            UploadingLoadingPage(file: file!)),
                                    (route) => false);
                              },
                              icon: const Icon(Icons.upload),
                              label: const Text("Upload")),
                        )
                      ],
                    )),
        )
      ]),
    );
  }
}

class UploadingLoadingPage extends StatefulWidget {
  final XFile file;
  const UploadingLoadingPage({super.key, required this.file});

  @override
  State<UploadingLoadingPage> createState() => _UploadingLoadingPageState();
}

class _UploadingLoadingPageState extends State<UploadingLoadingPage> {
  Future uploadFile() async {
    final stringFile =
        await widget.file.readAsString(); //read the file as plaintext
    await pb.collection('csv_files').create(
      //then submit the file as a string
      body: {"csv": stringFile},
    );

    return "";
  }


  Future isThereDataInTheDB() async {
    final records = await pb.collection('csv_files').getFullList(
  sort: '-created',
);
    if (records.isEmpty) {
      return false;
    } else {
      for (int x=0; x<records.length; x++) {
        await pb.collection('csv_files').delete(records[x].id);
      }
      return true;
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Uploading"),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: FutureBuilder(
        //wait until the file has been added to DB
        future: uploadFile(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            return Center(
              child: FutureBuilder(
                future: isThereDataInTheDB(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {

                  if (snapshot.data == false) {
                  return Column(
                  children: [
                    const Icon(Icons.check),
                    const Text(
                      "The file was accepted by the server.",
                      textAlign: TextAlign.center,
                    ),
                    //my knowledge of Go is not good enough to check in the main.go file if the formatting is correct
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const MyHomePage(title: "Home Page")));
                          },
                          child: const Text("Home Page")),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const UploadingCSVPage()));
                          },
                          child: const Text("Add Another")),
                    )
                  ],
                );} else {
                  return Column(
                    children: [
                      const Icon(Icons.error),
                      const Text("This CSV file isn't formatted correctly."),
                      const Text("Has the teacher's account been made?"),
                      ElevatedButton(onPressed: () => Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const UploadingCSVPage()), (route) => false), child: const Text("Try Again"))
                    ],
                  );
                }
                } else if (snapshot.hasError){
                  return const Text("Something went wrong :/");
                } else {
                  return const CircularProgressIndicator();
                }
                },
          ),
            );
          } else if (snapshot.hasError) {
            return const Center(
              child: Icon(Icons.sms_failed),
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
