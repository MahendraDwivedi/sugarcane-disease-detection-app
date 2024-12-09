

import 'package:Cane_Guard/screens/loading.dart';
import 'package:Cane_Guard/screens/select_image.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:Cane_Guard/screens/sign_in.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
    print("Firebase initialized successfully.");
  } catch (e) {
    print("Firebase initialization failed: $e");
  }
  runApp(MyApp());
}


class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => Loading(),
        '/sign_in': (context) => SignInScreen(),
        '/select_image':(context)=>DiseaseDetectionScreen(),
      },
    );
  }
}
