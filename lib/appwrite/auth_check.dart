import 'package:blogverse/Pages/home_page.dart';
import 'package:blogverse/Pages/login_signup_page.dart';
import 'package:flutter/material.dart';
import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as models;

class AuthCheck extends StatelessWidget {
  final Account account;

  const AuthCheck({super.key, required this.account});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<models.User?>(
      future: account.get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasData && snapshot.data != null) {
          return HomePage(user: snapshot.data!, account: account);
        } else {
          return LoginSignupPage(account: account);
        }
      },
    );
  }
}
