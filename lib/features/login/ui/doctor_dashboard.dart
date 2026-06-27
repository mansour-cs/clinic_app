import 'package:clinic_app/features/login/ui/page/DoctorAppointmentsPage.dart';
import 'package:flutter/material.dart';

class DoctorDashboard extends StatelessWidget {
  final int userId;

  const DoctorDashboard({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
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

            // عنوان ترحيبي
            Text(
              "Welcome Doctor",
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 40),

            // زر مواعيد اليوم
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DoctorAppointmentsPage(
                      doctorId: userId,
                      onlyToday: true,
                    ),
                  ),
                );
              },
              child: const Text("Today's Appointments"),
            ),

            const SizedBox(height: 20),

            // زر كل المواعيد
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DoctorAppointmentsPage(
                      doctorId: userId,
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
