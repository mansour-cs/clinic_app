import 'package:clinic_app/features/login/ui/page/DoctorAppointmentsPage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DoctorDashboard extends StatefulWidget {
  final int userId;

  const DoctorDashboard({super.key, required this.userId});

  @override
  State<DoctorDashboard> createState() => _DoctorDashboardState();
}

class _DoctorDashboardState extends State<DoctorDashboard> {
  int? doctorId;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchDoctorId();
  }

  // ⭐ جلب doctor_id الحقيقي من الـ API
  Future<void> fetchDoctorId() async {
    var response = await http.get(
      Uri.parse("http://10.206.6.18:8000/doctors/by_user/${widget.userId}"),
    );

    var data = jsonDecode(response.body);

    if (data["status"] == "success") {
      setState(() {
        doctorId = data["doctor_id"];
        loading = false;
      });
    } else {
      setState(() {
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Scaffold(
        appBar: AppBar(title: const Text("Doctor Dashboard")),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (doctorId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Doctor Dashboard")),
        body: const Center(child: Text("Doctor not found")),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Doctor Dashboard"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),

            Text(
              "Welcome Doctor",
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 40),

            // ⭐ مواعيد اليوم فقط
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DoctorAppointmentsPage(
                      doctorId: doctorId!,
                      onlyToday: true,
                    ),
                  ),
                );
              },
              child: const Text("Today's Appointments"),
            ),

            const SizedBox(height: 20),

            // ⭐ كل المواعيد
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DoctorAppointmentsPage(
                      doctorId: doctorId!,
                      onlyToday: false,
                    ),
                  ),
                );
              },
              child: const Text("All Appointments"),
            ),
          ],
        ),
      ),
    );
  }
}
