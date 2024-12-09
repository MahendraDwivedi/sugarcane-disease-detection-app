import 'package:Cane_Guard/screens/select_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:Cane_Guard/reusable_widgets/reusable_widget.dart';
import 'package:Cane_Guard/screens/home_screen.dart';
import 'package:Cane_Guard/utils/color_utils.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  TextEditingController _emailTextController = TextEditingController();
  TextEditingController _passwordTextController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Sign Up",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
            gradient: LinearGradient(
                colors: [
                  hexStringToColor("276221"),
                  hexStringToColor("46923c"),
                  hexStringToColor("5bb450")
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter
            )
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.fromLTRB(20, 120, 20, 0),
            child: Column(
              children: <Widget>[
                const SizedBox(height: 20),
                reusableTextField("Enter Email Id", Icons.email_outlined, false, _emailTextController),
                const SizedBox(height: 20),
                reusableTextField("Enter Password", Icons.lock_outlined, true, _passwordTextController),
                const SizedBox(height: 20),
              firebaseUIButton(context, "Sign Up", () async {
                final email = _emailTextController.text.trim();
                final password = _passwordTextController.text.trim();

                // Validate input (email, password checks)
                if (email.isEmpty || password.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("All fields are required.")),
                  );
                  return;
                }

                if (!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(email)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Please enter a valid email address.")),
                  );
                  return;
                }

                if (password.length < 6) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Password must be at least 6 characters long.")),
                  );
                  return;
                }

                // Firebase Authentication
                try {
                  UserCredential userCredential = await FirebaseAuth.instance
                      .createUserWithEmailAndPassword(email: email, password: password);

                  // Save login state
                  SharedPreferences prefs = await SharedPreferences.getInstance();
                  await prefs.setBool('isLoggedIn', true);

                  // Navigate to the disease detection screen
                  Navigator.pushReplacementNamed(context, '/select_image');
                } catch (error) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Error: ${error.toString()}")),
                  );
                }
              })
              ],
            ),
          ),
        ),
      ),
    );
  }
}