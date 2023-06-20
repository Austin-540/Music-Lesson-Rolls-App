import 'package:flutter/material.dart';
import 'globals.dart';
import 'package:restart_app/restart_app.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SettingsPage extends StatelessWidget {
  Future deleteSavedData() async {
    final storage = new FlutterSecureStorage();
    await storage.deleteAll();
  }

  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Settings"),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          SizedBox(height: 20,),
        Center(
          child: ElevatedButton.icon(
            onPressed: () { 
              deleteSavedData(); Restart.restartApp();
              }, 
              icon: Icon(Icons.warning_amber), 
              label: Text("Delete All Saved Data")
            ),
        ),
        Center(child: Padding(
          padding: const EdgeInsets.all(25.0),
          child: Text("This button deletes your saved email and password. Use it if you need to log out. The app will restart when it is pressed.", textAlign: TextAlign.center,),
        )),

        Center(child: ElevatedButton.icon(icon: Icon(Icons.info), label: Text("App Info"), 
        onPressed: () => showAboutDialog(context: context, applicationIcon: Icon(Icons.class_outlined), applicationVersion: "v0.1", 
        applicationLegalese: """Created by Austin-540. Check out the source code on GitHub if you want.  
        
Copyright (c) 2023 Austin-540

This software is provided 'as-is', without any express or implied warranty. In no event will the authors be held liable for any damages arising from the use of this software.

Permission is granted to anyone to use this software for any purpose, including commercial applications, and to alter it and redistribute it freely, subject to the following restrictions:

1. The origin of this software must not be misrepresented; you must not claim that you wrote the original software. If you use this software in a product, an acknowledgment in the product documentation would be appreciated but is not required.

2. Altered source versions must be plainly marked as such, and must not be misrepresented as being the original software.

3. This notice may not be removed or altered from any distribution."""),),)
      ]),
    );
  }
}