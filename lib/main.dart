import 'package:flutter/material.dart';
import 'package:sample_project/ReadingScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:english_words/english_words.dart';
import 'package:provider/provider.dart';
import 'package:oktoast/oktoast.dart';

late SharedPreferences sharedPreferences;
void main() async {
// need to be called when initializing the app asynchronously
  WidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

//innitialize shared preference
  sharedPreferences = await SharedPreferences.getInstance();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {

    return OKToast(child: 
      ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
      // hidet the debug banner shown at the top right of the screen
      debugShowCheckedModeBanner: false,
      title: 'Windows Login with SQLite DB',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Color.fromRGBO(255, 111, 0, 1), primary: Color.fromRGBO(37, 55, 128, 1), secondary: Color.fromRGBO(255, 111, 0, 0.8)),
        useMaterial3: true,
      ),

      // when the application loads, show the login screen if the user is not logged in
      // else show home
      // initialRoute: isLoggedIn == true ? '/' : '/register',
      initialRoute: '/',
      // define the routes for login and home screen
      routes: {
        '/': (context) => const ReadingScreen(),
        // '/': (context) => const AdminNavigateScreen(),
      },
    )
    )
    );
  }
}

class MyAppState extends ChangeNotifier {
  var current = WordPair.random();

  void getNext() {
    current = WordPair.random();
    notifyListeners();
  }

  var favorites = <WordPair>[];

  void toggleFavorite() {
    if (favorites.contains(current)) {
      favorites.remove(current);
    } else {
      favorites.add(current);
    }
    notifyListeners();
  }
}