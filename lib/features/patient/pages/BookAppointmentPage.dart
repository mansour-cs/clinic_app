import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class BookAppointmentPage extends StatefulWidget {
  final int userId;

  const BookAppointmentPage({super.key, required this.userId});

  @override
  State<BookAppointmentPage> createState() => _BookAppointmentPageState();
}

class _BookAppointmentPageState extends State<BookAppointmentPage> {
  List doctors = [];
  int? selectedDoctorId;
  DateTime? selectedDate;

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchDoctors();
  }

  Future<void> fetchDoctors() async {
    var response = await http.get(Uri.parse("http://10.206.6.18:8000/doctors"));
    var data = jsonDecode(response.body);

    if (data["status"] == "success") {
      setState(() {
        doctors = data["data"];
      });
    }
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

  Future<void> bookAppointment() async {
    if (selectedDoctorId == null || selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please select doctor and date")),
      );
      return;
    }

    setState(() => isLoading = true);

    // ⭐ جلب patient_id الصحيح
    int? patientId = await fetchPatientId(widget.userId);

    if (patientId == null) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Patient not found")),
      );
      return;
    }

    // ⭐ تنسيق التاريخ بشكل صحيح لـ MySQL
    String formattedDate =
        "${selectedDate!.year}-${selectedDate!.month.toString().padLeft(2, '0')}-${selectedDate!.day.toString().padLeft(2, '0')}";

    var response = await http.post(
      Uri.parse("http://10.206.6.18:8000/appointments/book"),
      headers: {"Content-Type": "application/x-www-form-urlencoded"},
      body: {
        "patient_id": patientId.toString(),   // ← التعديل الحقيقي
        "doctor_id": selectedDoctorId.toString(),
        "appointment_date": formattedDate,
      },
    );

    setState(() => isLoading = false);

    print("STATUS: ${response.statusCode}");
    print("BODY: ${response.body}");

    var data = jsonDecode(response.body);

    if (data["status"] == "success") {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Appointment booked successfully")),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to book appointment")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Book Appointment")),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DropdownButtonFormField<int>(
              decoration: InputDecoration(
                labelText: "Select Doctor",
                border: OutlineInputBorder(),
              ),
              items: doctors.map<DropdownMenuItem<int>>((doctor) {
                return DropdownMenuItem<int>(
                  value: doctor["id"],
                  child: Text("${doctor["full_name"]} - ${doctor["specialty_name"]}"),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedDoctorId = value;
                });
              },
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () async {
                DateTime? date = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2030),
                );

                if (date != null) {
                  setState(() {
                    selectedDate = date;
                  });
                }
              },
              child: Text(
                selectedDate == null
                    ? "Select Appointment Date"
                    : "Selected: ${selectedDate!.year}-${selectedDate!.month}-${selectedDate!.day}",
              ),
            ),

            const SizedBox(height: 30),

            ElevatedButton(
              onPressed: isLoading ? null : bookAppointment,
              child: isLoading
                  ? CircularProgressIndicator(color: Colors.white)
                  : Text("Book Appointment"),
            ),
          ],
        ),
      ),
    );
  }
}
