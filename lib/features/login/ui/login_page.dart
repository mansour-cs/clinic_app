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

  bool isLoading = false;

  Future<void> loginUser() async {
    setState(() {
      isLoading = true;
    });

    try {
      var response = await http.post(
        Uri.parse("http://10.206.6.18:8000/login"),
        headers: {"Content-Type": "application/x-www-form-urlencoded"},
        body: {
          "username": usernameController.text.trim(),
          "password": passwordController.text.trim(),
        },
      );

      print("RAW RESPONSE: ${response.body}");
      print("STATUS CODE: ${response.statusCode}");

      if (response.statusCode != 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Server error: ${response.statusCode}")),
        );
        setState(() => isLoading = false);
        return;
      }

      Map<String, dynamic> data;

      try {
        data = jsonDecode(response.body);
      } catch (e) {
        print("JSON ERROR: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Invalid server response")),
        );
        setState(() => isLoading = false);
        return;
      }

      print("DECODED JSON: $data");

      if (data["status"] == "success") {
        var user = data["user"];

        int userId = user["id"];
        String role = user["role"];
        String fullName = user["full_name"];

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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data["message"] ?? "Wrong username or password")),
        );
      }
    } catch (e) {
      print("ERROR: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Network error: $e")),
      );
    }

    setState(() {
      isLoading = false;
    });
  }

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

            isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
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
    );
  }
}
