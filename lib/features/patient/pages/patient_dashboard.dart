import 'package:clinic_app/features/login/ui/login_page.dart';
import 'package:clinic_app/features/patient/pages/BookAppointmentPage.dart';
import 'package:clinic_app/features/patient/pages/DoctorsListPage.dart';
import 'package:clinic_app/features/patient/pages/PatientAppointmentsPage.dart';
import 'package:flutter/material.dart';


class PatientDashboard extends StatelessWidget {
  final int userId;

  const PatientDashboard({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
    appBar: AppBar(
  title: Text("Patient Dashboard"),
  actions: [
    IconButton(
      icon: Icon(Icons.logout),
      onPressed: () {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => LoginPage()),
          (route) => false,
        );
      },
    ),
  ],
),

      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),

        
            Text(
              "Welcome Patient",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 40),

      
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BookAppointmentPage(userId: userId),
                  ),
                );
              },
              child: Text("Book Appointment"),
            ),

            const SizedBox(height: 20),

            // زر مواعيدي
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PatientAppointmentsPage(userId: userId),
                  ),
                );
              },
              child: Text("My Appointments"),
            ),

            const SizedBox(height: 20),

            // زر الأطباء
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DoctorsListPage(),
                  ),
                );
              },
              child: Text("Doctors"),
            ),
          ],
        ),
      ),
    );
  }
}
