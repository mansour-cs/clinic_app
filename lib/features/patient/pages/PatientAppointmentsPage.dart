import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PatientAppointmentsPage extends StatefulWidget {
  final int userId;

  const PatientAppointmentsPage({super.key, required this.userId});

  @override
  State<PatientAppointmentsPage> createState() => _PatientAppointmentsPageState();
}

class _PatientAppointmentsPageState extends State<PatientAppointmentsPage> {
  List appointments = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchAppointments();
  }

  // ⭐ جلب patient_id الحقيقي من الـ API
  Future<int?> fetchPatientId(int userId) async {
    var response = await http.get(
      Uri.parse("http://10.206.6.18:8000/patients/by_user/$userId"),
    );

    var data = jsonDecode(response.body);

    if (data["status"] == "success") {
      return data["patient_id"];
    }
    return null;
  }

  // ⭐ جلب مواعيد المريض باستخدام patient_id الصحيح
  Future<void> fetchAppointments() async {
    int? patientId = await fetchPatientId(widget.userId);

    if (patientId == null) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Patient not found")),
      );
      return;
    }

    var response = await http.get(
      Uri.parse("http://10.206.6.18:8000/appointments/patient/$patientId"),
    );

    var data = jsonDecode(response.body);

    if (data["status"] == "success") {
      setState(() {
        appointments = data["data"];
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to load appointments")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("My Appointments")),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : appointments.isEmpty
              ? Center(child: Text("No appointments found"))
              : ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: appointments.length,
                  itemBuilder: (context, index) {
                    var appt = appointments[index];

                    return Card(
                      margin: EdgeInsets.only(bottom: 16),
                      child: ListTile(
                        title: Text("Doctor: ${appt["doctor_name"]}"),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 6),
                            Text("Date: ${appt["appointment_date"]}"),
                            Text("Status: ${appt["status"]}"),
                            if (appt["doctor_notes"] != null)
                              Text("Notes: ${appt["doctor_notes"]}"),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
