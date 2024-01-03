import 'package:flutter/material.dart';
import 'package:music_lessons_attendance/clear_db_page.dart';
import 'globals.dart';
import 'package:restart_app/restart_app.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'uploading_csv_page.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class SettingsPage extends StatelessWidget {
  Future deleteSavedData() async {
    //self explanatory
    const storage = FlutterSecureStorage();
    await storage.delete(key: "pb_auth");
    pb.authStore.clear();

  }

  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
        backgroundColor:
            Theme.of(context).colorScheme.inversePrimary, //defined in main.dart
      ),
      body: Column(children: [
        const SizedBox(
          height: 20,
        ),
        Center(
          child: ElevatedButton.icon(
              onPressed: () {
                deleteSavedData();
                Restart
                    .restartApp(); //sends you back to the login screen and resets all variables
              },
              icon: const Icon(Icons.warning_amber),
              label: const Text("Delete All Saved Data")),
        ),
        const Center(
            child: Padding(
          padding: EdgeInsets.all(25.0),
          child: Text(
            "This button deletes your saved email and password. Use it if you need to log out. The app will restart when it is pressed.",
            textAlign: TextAlign.center,
          ), //explanation of what button does
        )),
        Center(
          child: Column(
            children: [
              ElevatedButton.icon(
                  icon: const Icon(Icons.info),
                  label: const Text("App Info"),
                  onPressed: () => showAboutDialog(
                      //shows the licences page also - to comply with MIT licenses etc
                      context: context,
                      applicationIcon: const Icon(Icons.class_outlined),
                      applicationVersion: version,
                      applicationLegalese:
                          """Created by Austin-540. Check out the source code on GitHub if you want.  
        
Copyright (c) 2023 Austin-540

This software is provided 'as-is', without any express or implied warranty. In no event will the authors be held liable for any damages arising from the use of this software.

Permission is granted to anyone to use this software for any purpose, including commercial applications, and to alter it and redistribute it freely, subject to the following restrictions:

1. The origin of this software must not be misrepresented; you must not claim that you wrote the original software. If you use this software in a product, an acknowledgment in the product documentation would be appreciated but is not required.

2. Altered source versions must be plainly marked as such, and must not be misrepresented as being the original software.

3. This notice may not be removed or altered from any distribution."""),
                  onLongPress: () => showDialog(
                      context: context,
                      builder: (context) => const Dialog(
                            child: Padding(
                              padding: EdgeInsets.all(20.0),
                              child: Text(
                                "In memory of Thomas Park(he didn't die but asked to be remembered)",
                                style: TextStyle(fontSize: 20),
                              ), //easter egg
                            ),
                          ))),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ElevatedButton.icon(onPressed: () => Navigator.push(context, 
                                              MaterialPageRoute(builder: (context) => const ClearDBPage())), icon: const Icon(Icons.delete_forever), label: const Text("Clear the backend")),
                          )
            ],
          ),
        ),
        kIsWeb
            ? //hides this button unless accessing app from the website
            Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const UploadingCSVPage()));
                      },
                      icon: const Icon(Icons.add),
                      label: const Text("Add Lessons"),
                    ),
                    const Center(
                        child: Text(
                      "Upload a CSV file to add lessons. (Desktop only, CSV must be formatted correctly)",
                      textAlign: TextAlign.center,
                    )),
                    
                  ],
                ),
              )
            : const SizedBox()
      ]),
    );
  }
}
