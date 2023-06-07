import 'dart:io';

import 'package:flutter/material.dart';
import 'globals.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'settings_page.dart';
import 'login_page.dart';
import 'package:pocketbase/pocketbase.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

Future logIn() async {
    Future.delayed(Duration(milliseconds: 500));

  String? email;
  String? password;
  RecordAuth? authData;

    try {
    final storage = new FlutterSecureStorage();
    String? email = await storage.read(key: "email");
    String? password = await storage.read(key: "password");

    if (email == null) {
      throw "no saved data";
    }

    final authData = await pb.collection('users').authWithPassword(
  email!, password!,
    );
    print(authData);
    return authData;


    } on SocketException {
      print("SocketException");
      showDialog(context: context, builder: (BuildContext context) {
        print("Internet error");
        return AlertDialog(title: Text("Internet error"),
        );
      });
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => LoginScreen()), (route) => false);

    } on ClientException {
      showDialog(context: context, builder: (BuildContext context) {
        return AlertDialog(title: Text("Wrong password/email"),
        );
      });

    } catch (e) {
      print("Caught $e");
       Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => LoginScreen()), (route) => false);
    }
    //first try to see if password is already saved, then if its not push to login screen

    

  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder:(context) => SettingsPage())), icon: Icon(Icons.settings))
        ],
      ),
      body: Center(
        child: FutureBuilder(
          future: logIn(),
          initialData: null,
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.hasData) {
              return Text(snapshot.data.toString());
            } else {
              print("108");
              return CircularProgressIndicator();
            }
          },
        ),
    ));
  }
}