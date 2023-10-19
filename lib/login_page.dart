import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'globals.dart';
import 'home_page.dart';
import 'dart:convert';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  String _email = "";
  String _password = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: const Text("Login - $version")),
      body: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(50.0),
            child: Column(
              children: [
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Email',
                  ),
                  onSaved: (value) {
                    _email = value!
                        .toLowerCase(); //pb doesn't automatically allow caps emails
                  },
                ),
                const SizedBox(height: 20),
                TextFormField(
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                  ),
                  onSaved: (value) {
                    _password = value!;
                  },
                ),
                const SizedBox(height: 20),
                Semantics(
                  label: "Login Button",
                  child: ElevatedButton(
                    onPressed: () {
                      _formKey.currentState!.save();
                      if (_email != "" && _password != "") {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ConfirmLoginPage(
                                    email: _email, password: _password)));
                      }
                    },
                    child: const Text('Login'),
                  ),
                ),
              ],
            ),
          )),
    );
  }
}

class ConfirmLoginPage extends StatelessWidget {
  //checks email and password are correct before moving to home page
  const ConfirmLoginPage(
      {super.key, required this.email, required this.password});
  final String email;
  final String password;

  Future logIn(email, password) async {
    try {
      final authData = await pb.collection('users').authWithPassword(
            email,
            password,
          ); //if wrong password, try block will fail, and snapshot.data will be "Fail"

      const storage = FlutterSecureStorage();
      await storage.write(
          key: "email", value: email); //only writes to FSS if correct password
      await storage.write(key: "password", value: password);


  final encoded = jsonEncode(<String, dynamic>{
    "token": pb.authStore.token,
    "model": pb.authStore.model,
  });
    storage.write(key: "pb_auth", value: encoded);

      return authData;
    } catch (e) {
      return "Fail";
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: logIn(email, password),
      initialData: null,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data != "Fail") {
            return const MyHomePage(title: "Home");
          } else {
            return const FailedLoginPage();
          }
        } else {
          return Scaffold(
              appBar: AppBar(
                backgroundColor: Theme.of(context).colorScheme.inversePrimary,
                title: const Text("Loading"),
                automaticallyImplyLeading: false,
              ),
              body: const Center(child: CircularProgressIndicator()));
        }
      },
    );
  }
}

class FailedLoginPage extends StatelessWidget {
  //if your email/password is wrong, or PB crashed
  const FailedLoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        automaticallyImplyLeading: false,
        leading: null,
      ),
      body: Center(
        child: Column(children: [
          const SizedBox(
            height: 10,
          ),
          const Text("Something went wrong"),
          const Text("Make sure your email and password are correct."),
          const SizedBox(
            height: 20,
          ),
          ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Try Again"))
        ]),
      ),
    );
  }
}
