import 'package:GarageSync/services/auth/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';


class LoginPage extends StatefulWidget {
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _login() async {
    // auth service
    final authService = AuthService();

    // try login
    try {
      await authService.signWithEmailPassword(
          _emailController.text, _passwordController.text);
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(e.toString())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 100,
        centerTitle: true,
        title: Text(
          'GarageSync Mobile App',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 60),
                  child: Image(
                    height: 120,
                    width: 300,
                    image: AssetImage('images/grgsync.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'User Name',
                ),
              ),
              SizedBox(height: 20.0),
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                ),
                obscureText: true,
              ),
              SizedBox(height: 20.0),
              ElevatedButton(
                onPressed: _login ,
                child: Text('Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
