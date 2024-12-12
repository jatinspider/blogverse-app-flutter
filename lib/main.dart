import 'package:blogverse/appwrite/auth_check.dart';
import 'package:flutter/material.dart';
import 'package:appwrite/appwrite.dart';
import 'package:blogverse/constants/constants.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Client client = Client().setEndpoint(APPWRITE_URL).setProject(APPWRITE_PROJECT_ID);
  Account account = Account(client);
 
  runApp(MyApp(account: account));
}

class MyApp extends StatelessWidget {
  final Account account;

  const MyApp({super.key, required this.account});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BlogVerse',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: AuthCheck(account: account),
    );
  }
}
