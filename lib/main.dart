import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:restart_app/restart_app.dart';




final pb = PocketBase('http://127.0.0.1:8090');

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 134, 193,
                234)), //"Oxford Blue" according to the communications part of adminitstration
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

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


    } catch (e) {
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
              return CircularProgressIndicator();
            }
          },
        ),
    ));
  }
}



class LoginScreen extends StatefulWidget {

  @override
  _LoginScreenState createState() => _LoginScreenState(); }

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  String _email = "example@example.com";
  String _password = "password";
  
  Future logIn(email, password) async {
    try {
    final authData = await pb.collection('users').authWithPassword(
  email, password,
);


final storage = new FlutterSecureStorage();
  await storage.write(key: "email", value: email);
  await storage.write(key: "password", value: password);
  return authData;
    } catch (e) {
      return "Fail";
    }

  }
  Future waitAndPushToHome() async {
    await Future.delayed(Duration(milliseconds: 600)); //Minimum time seems to be 400ms
    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => MyHomePage(title: "Home Screen")), (route) => false);
  }


  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text("Login")
        ),
      body: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(50.0),
            child: Column(
              
              children: [
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Email',
                  ),
                  
                  onSaved: (value) {
                    _email = value!;
                  },
                ),
                SizedBox(height: 20),
                TextFormField(
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Password',
                  ),
                  onSaved: (value) {
                    _password = value!;
                  },
                  
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    _formKey.currentState!.save();
                    if (_email != "" && _password != "") {
                      //TODO verify password + go to home screen

                        print("trying login");
                        if (logIn(_email, _password) == "Fail") {
                          print("login fail");
                        } else {
                          waitAndPushToHome();
                          
                        }


                      
                        
                    }
                  },
                  child: Text('Login'),
                ),
              ],
            ),
          )),
    );
  }
}


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
      ),
      body: Column(children: [
        ElevatedButton.icon(onPressed: () { deleteSavedData(); Restart.restartApp();}, icon: Icon(Icons.warning_amber), label: Text("delete all saved data"))
      ]),
    );
  }
}