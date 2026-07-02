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

  String selectedRole = "patient"; // اختيار الدور
  String? selectedSpecialty; // اختيار التخصص للدكتور

  List specialties = []; // قائمة التخصصات

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchSpecialties();
  }

  Future<void> fetchSpecialties() async {
    var response = await http.get(Uri.parse("http://10.0.2.2:8000/specialties"));
    var data = jsonDecode(response.body);

    setState(() {
      specialties = data["data"];
    });
  }

  Future<void> registerUser() async {
    setState(() => isLoading = true);

    // منع تسجيل دكتور بدون اختيار تخصص
    if (selectedRole == "doctor" && selectedSpecialty == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please select a specialty")),
      );
      setState(() => isLoading = false);
      return;
    }

    var response = await http.post(
      Uri.parse("http://10.0.2.2:8000/register"),
      headers: {"Content-Type": "application/x-www-form-urlencoded"},
      body: {
        "username": usernameController.text,
        "password": passwordController.text,
        "role": selectedRole,
        "full_name": fullNameController.text,
        "email": emailController.text,
        if (selectedRole == "doctor") "specialty_id": selectedSpecialty!,
      },
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
        SnackBar(content: Text("Registration Failed")),
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
              const SizedBox(height: 16),

              // اختيار الدور
              DropdownButtonFormField(
                value: selectedRole,
                decoration: InputDecoration(
                  labelText: "Select Role",
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(
                    value: "patient",
                    child: Text("Patient"),
                  ),
                  DropdownMenuItem(
                    value: "doctor",
                    child: Text("Doctor"),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    selectedRole = value!;
                    selectedSpecialty = null; // إعادة التعيين
                  });
                },
              ),

              // اختيار التخصص إذا كان دكتور
              if (selectedRole == "doctor") ...[
                const SizedBox(height: 16),
                DropdownButtonFormField(
                  decoration: InputDecoration(
                    labelText: "Select Specialty",
                    border: OutlineInputBorder(),
                  ),
                  items: specialties.map<DropdownMenuItem<String>>((item) {
                    return DropdownMenuItem(
                      value: item["id"].toString(),
                      child: Text(item["name"]),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedSpecialty = value;
                    });
                  },
                ),
              ],

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
