import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pocketbase/pocketbase.dart';


final storage = new FlutterSecureStorage();

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


      final authData = await pb.collection('users').authWithPassword(
  email!, password!,
    );
    print(authData);
    return authData;

    }
    //first try to see if password is already saved, then if its not push to login screen

    

  }
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      logIn();
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
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

  await storage.write(key: "email", value: email);
  await storage.write(key: "password", value: password);
  return authData;
    } catch (e) {
      return "Fail";
    }

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
                        logIn(_email, _password);


                      
                        
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
