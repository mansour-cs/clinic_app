import 'package:clinic_app/features/login/register_page.dart';
import 'package:flutter/material.dart';
import '../../../core/theme.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LoginPage extends StatelessWidget {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Welcome Back", style: AppTextStyles.heading),
            const SizedBox(height: 20),

            TextField(
              controller: usernameController,
              decoration: InputDecoration(
                labelText: "Username",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: "Password",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 24),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => RegisterPage()),
                );
              },
              child: Text("Create an account"),
            ),

            const SizedBox(height: 24),

            ElevatedButton(
              style: AppButtons.primaryButton,
              onPressed: () async {
                final username = usernameController.text;
                final password = passwordController.text;

                // إرسال البيانات للباك إند FastAPI
                var response = await http.post(
                  Uri.parse("http://10.0.2.2:8000/login"),
                  headers: {
                    "Content-Type": "application/x-www-form-urlencoded",
                  },
                  body: {"username": username, "password": password},
                );

                var data = jsonDecode(response.body);

                if (data["status"] == "success") {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text("Login Successful")));

                  // هون مننتقل لصفحة Home
                  // Navigator.push(context, MaterialPageRoute(builder: (_) => HomePage()));
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Wrong username or password")),
                  );
                }
              },

              child: const Text("Login"),
            ),
          ],
        ),
      ),
    );
  }
}
