import 'package:flutter/material.dart';
import 'package:appwrite/appwrite.dart';
import 'package:blogverse/appwrite/auth_check.dart';

class LoginSignupPage extends StatefulWidget {
  final Account account;

  const LoginSignupPage({super.key, required this.account});

  @override
  _LoginSignupPageState createState() => _LoginSignupPageState();
}

class _LoginSignupPageState extends State<LoginSignupPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final nameController = TextEditingController();
  bool isLogin = true;

  Future<void> login(String email, String password) async {
    try {
      await widget.account.createEmailPasswordSession(email: email, password: password);
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => AuthCheck(account: widget.account)),
      );
    } catch (e) {
      _showErrorDialog('Login error: $e');
    }
  }

  Future<void> register(String email, String password, String name) async {
    try {
      await widget.account.create(userId: ID.unique(), email: email, password: password, name: name);
      await login(email, password);
    } catch (e) {
      _showErrorDialog('Register error: $e');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isLogin ? 'Login' : 'Sign Up'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: SingleChildScrollView(
            child: Card(
              elevation: 5,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: emailController,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    TextField(
                      controller: passwordController,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      obscureText: true,
                    ),
                    if (!isLogin)
                      Padding(
                        padding: const EdgeInsets.only(top: 16.0),
                        child: TextField(
                          controller: nameController,
                          decoration: InputDecoration(
                            labelText: 'Name',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    const SizedBox(height: 16.0),
                    ElevatedButton(
                      onPressed: () {
                        if (isLogin) {
                          login(emailController.text, passwordController.text);
                        } else {
                          register(emailController.text, passwordController.text, nameController.text);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        minimumSize: const Size(double.infinity, 0), // Make button full-width
                      ),
                      child: Text(isLogin ? 'Login' : 'Sign Up', style: const TextStyle(fontSize: 16)),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          isLogin = !isLogin;
                        });
                      },
                      child: Text(isLogin ? 'Create an account' : 'Already have an account? Login'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
