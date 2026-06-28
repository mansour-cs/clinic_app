import 'package:clinic_app/features/login/register_page.dart';
import 'package:clinic_app/features/login/ui/doctor_dashboard.dart';
import 'package:clinic_app/features/patient/pages/patient_dashboard.dart';
import 'package:flutter/material.dart';
import '../../../core/theme.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  Future<void> loginUser() async {
    try {
      var response = await http.post(
        Uri.parse("http://10.0.2.2:8000/login"),
        body: {
          "username": usernameController.text,
          "password": passwordController.text,
        },
      );

      print("Response: ${response.body}");

      var data = jsonDecode(response.body);

      if (data["status"] == "success") {
        var user = data["user"];

        int userId = user["id"];
        String role = user["role"];
        String fullName = user["full_name"];

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Welcome $fullName")),
        );

        if (role == "patient") {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PatientDashboard(userId: userId),
            ),
          );
        } else if (role == "doctor") {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => DoctorDashboard(userId: userId),
            ),
          );
        }
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Wrong username or password")),
        );
      }
    } catch (e) {
      print("Error: $e");
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Connection error")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 80),
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
              ElevatedButton(
                style: AppButtons.primaryButton,
                onPressed: loginUser,
                child: const Text("Login"),
              ),
              const SizedBox(height: 24),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => RegisterPage()),
                  );
                },
                child: const Text("Create an account"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
