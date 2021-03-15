import 'package:ello/screens/registration.dart';
import 'package:ello/services/routeBasedOnAuth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initialization,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          print(snapshot.error);
        }

        if (snapshot.connectionState == ConnectionState.done) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Flutter Demo',
            theme: ThemeData(
                primaryColor: Colors.pink,
                scaffoldBackgroundColor: Colors.pink[200],
                buttonColor: Colors.pink,
            elevatedButtonTheme:ElevatedButtonThemeData(style: ButtonStyle(backgroundColor: MaterialStateProperty.resolveWith<Color>(
            (Set<MaterialState> states) {
            if (states.contains(MaterialState.pressed))
            return Colors.pink[300];
            return Colors.pink; // Use the component's default.
            },)) ),
              floatingActionButtonTheme: FloatingActionButtonThemeData(backgroundColor: Colors.pink),
            ),
            home: RouteWidget().checkAuth(),
          );
        }

        return Center(child: CircularProgressIndicator());
      },
    );
  }
}
