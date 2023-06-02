import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pocketbase/pocketbase.dart';
import 'globals.dart';
import 'main.dart';
import 'package:restart_app/restart_app.dart';



class LoginScreen extends StatefulWidget {

  @override
  _LoginScreenState createState() => _LoginScreenState(); }

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  String _email = "";
  String _password = "";
  
  Future logIn(email, password) async {
    try {
    final authData = await pb.collection('users').authWithPassword(
  email, password,);


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
                        print("trying login");
                        logIn(_email, _password).then((value) {
                        var status = value;
                        if (status == "Fail") {
                          print("login fail");
                          //TODO have a popup showing that password/email is incorrect
                        } else {
                          waitAndPushToHome();
                          
                        }

                        } 
                        );


                      
                        
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


