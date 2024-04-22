import 'package:flutter/material.dart';
import 'package:buoi8/app/data/api.dart';
import 'package:buoi8/app/page/auth/login.dart';


class forgetWiget extends StatefulWidget {
  const forgetWiget({super.key});

  @override
  State<forgetWiget> createState() => _forgetWigetState();
}

class _forgetWigetState extends State<forgetWiget> {
  TextEditingController accountIDController = TextEditingController();
  TextEditingController numberIDController = TextEditingController();
  TextEditingController newPasswordController = TextEditingController();
  @override
  Widget build(BuildContext context) {
     return Scaffold(
      appBar: AppBar(
        title: Text('Forgot Password'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: accountIDController,
              decoration: InputDecoration(labelText: 'Account ID'),
            ),
            SizedBox(height: 12.0),
            TextField(
              controller: numberIDController,
              decoration: InputDecoration(labelText: 'Number ID'),
            ),
            SizedBox(height: 12.0),
            TextField(
              controller: newPasswordController,
              decoration: InputDecoration(labelText: 'New Password'),
              obscureText: true,
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () async {
                String respone = await forgetPass();
                if (respone == "ok") {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const LoginScreen()));
                } else {
                  print(respone);
                }
              },
              child: Text('Reset Password'),
            ),
          ],
        ),
      ),
    );
  }
    Future<String> forgetPass() async {
    return await APIRepository().forgetPass(accountIDController.text,numberIDController.text,newPasswordController.text);
  }
}