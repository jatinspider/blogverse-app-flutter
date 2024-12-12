import 'package:flutter/material.dart';
import 'package:appwrite/appwrite.dart';

class ProfileTab extends StatelessWidget {
  final Account account;
  final String userName;

  const ProfileTab({Key? key, required this.account, required this.userName}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("Profile Tab", style: TextStyle(fontSize: 24)),
          Text("Username: $userName", style: TextStyle(fontSize: 18)),
         
          // Add more profile-related information here
        ],
      ),
    );
  }
}
