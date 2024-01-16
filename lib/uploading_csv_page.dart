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
                          child: OutlinedButton(
                              onPressed: () => launchUrl(Uri.parse(
                                  "https://austin-540.github.io/Database-Stuff/csv_formatting_guide.html")),
                              child: const Text("CSV Formatting Guide")),
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
      for (int x = 0; x < records.length; x++) {
        await pb.collection('csv_files').delete(records[x].id);
      }
      return true;
    }
  }

  Future getErrorMessage() async {
    final records = await pb.collection('error_message').getFullList(
  sort: '-created',
);
    final error_message = records[0].data['error'];


    await pb.collection('error_message').delete(records[0].id);

    if (records.length != 1) {
      return "There are multiple errors in the backend. Please delete them manually in the table 'error_message'.";
    }



    return error_message;
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
                                              const MyHomePage(
                                                  title: "Home Page")));
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
                      );
                    } else {
                      return Column(
                        children: [
                          const Icon(Icons.error),
                          const Text(
                              "This CSV file isn't formatted correctly."),
                          FutureBuilder(
                            future: getErrorMessage(),
                            builder: (BuildContext context, AsyncSnapshot snapshot) {
                              if (snapshot.hasData) {
                                return Column(
                                  children: [
                                    const SizedBox(height: 50,),
                                    Text(snapshot.data, style: const TextStyle(color: Color.fromARGB(255, 255, 36, 20))),
                                    const SizedBox(height: 50,),
                                    const Text("""What these error messages mean:


'local variable teacher_id referenced before assignment': The username in cell A2 doesn't match the username of any teacher's account. Make sure you have made their account before uploading the CSV file.


'Invalid weekday': The weekday in cell A3 doesn't match 'Monday' or 'Tuesday' etc. Ensure the word is capitalised and there is no trailing spacebar.


'The time provided isn't 4 characters long': The time value in the CSV file has omitted the leading zero/written the time in the wrong format. Ensure the time is 4 characters long by adding a leading zero. 
In Google Sheets format the cell as plain text to keep leading zeros. Example time: '0930' for 9:30AM and '1300' for 1PM
OR
You left a blank line where there shouldn't be one.
OR
There is extra data in the spreadsheet that shouldn't be there. Try opening the file with a text editor to see this data if you can't find it.


'Response error. Status code:400': Something else went wrong. Go to the logs section at app.shcmusiclessonrolls.com/_, enable 'include requests by admins' in the top right and select the first item with code 400. 
This will show the full error message.
"""
                                    ),
                                    SizedBox(height: 20,)
                                  ],
                                );
                              } else {
                                return const Column(
                                  children: [
                                    CircularProgressIndicator(),
                                    Text("Loading error message...")
                                  ],
                                );
                              }
                            },
                          ),
                          ElevatedButton(
                              onPressed: () => Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const UploadingCSVPage()),
                                  (route) => false),
                              child: const Text("Try Again"))
                        ],
                      );
                    }
                  } else if (snapshot.hasError) {
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
