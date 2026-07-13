import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final fullNameController = TextEditingController();
  final emailController = TextEditingController();

  String selectedRole = "patient"; // default
  int? selectedSpecialty;

  bool isLoading = false;
  List specialties = [];

  @override
  void initState() {
    super.initState();
    fetchSpecialties();
  }

  Future<void> fetchSpecialties() async {
    var response = await http.get(
      Uri.parse("http://10.206.6.18:8000/specialties"),
    );

    var data = jsonDecode(response.body);
    if (data["status"] == "success") {
      setState(() {
        specialties = data["data"];
      });
    }
  }

  Future<void> registerUser() async {
    setState(() => isLoading = true);

    var bodyData = {
      "username": usernameController.text,
      "password": passwordController.text,
      "role": selectedRole,
      "full_name": fullNameController.text,
      "email": emailController.text,
    };

    if (selectedRole == "doctor") {
      bodyData["specialty_id"] = selectedSpecialty.toString();
    }

    var response = await http.post(
      Uri.parse("http://10.206.6.18:8000/register"),
      headers: {"Content-Type": "application/x-www-form-urlencoded"},
      body: bodyData,
    );

    setState(() => isLoading = false);

    var data = jsonDecode(response.body);

    if (!mounted) return;

    if (data["status"] == "success") {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("User Registered Successfully")),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(data["message"] ?? "Registration Failed")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Create Account")),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: fullNameController,
                decoration: InputDecoration(
                  labelText: "Full Name",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: "Email",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              TextField(
                controller: usernameController,
                decoration: InputDecoration(
                  labelText: "Username",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: "Password",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),

              // ROLE DROPDOWN
              DropdownButtonFormField(
                value: selectedRole,
                decoration: InputDecoration(
                  labelText: "Account Type",
                  border: OutlineInputBorder(),
                ),
                items: [
                  DropdownMenuItem(value: "patient", child: Text("Patient")),
                  DropdownMenuItem(value: "doctor", child: Text("Doctor")),
                ],
                onChanged: (value) {
                  setState(() {
                    selectedRole = value!;
                  });
                },
              ),

              const SizedBox(height: 16),

              // SPECIALTY DROPDOWN (ONLY FOR DOCTOR)
              if (selectedRole == "doctor")
                DropdownButtonFormField(
                  decoration: InputDecoration(
                    labelText: "Specialty",
                    border: OutlineInputBorder(),
                  ),
                  items: specialties.map((s) {
                    return DropdownMenuItem(
                      value: s["id"],
                      child: Text(s["name"]),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                     selectedSpecialty = value as int;

 
                    });
                  },
                ),

              const SizedBox(height: 24),

              ElevatedButton(
                onPressed: isLoading ? null : registerUser,
                child: isLoading
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text("Register"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
