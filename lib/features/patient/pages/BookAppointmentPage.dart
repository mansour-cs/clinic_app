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
  List specialties = [];
  List doctors = [];

  String? selectedSpecialtyId;
  int? selectedDoctorId;
  DateTime? selectedDate;

  bool loadingSpecialties = true;
  bool loadingDoctors = false;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchSpecialties();
  }

  // جلب التخصصات
  Future<void> fetchSpecialties() async {
    var response = await http.get(Uri.parse("http://10.0.2.2:8000/specialties"));
    var data = jsonDecode(response.body);

    setState(() {
      specialties = data["data"];
      loadingSpecialties = false;
    });
  }

  // جلب الدكاترة حسب التخصص
  Future<void> fetchDoctorsBySpecialty(String specialtyId) async {
    setState(() {
      loadingDoctors = true;
      doctors = [];
      selectedDoctorId = null;
    });

    var response = await http.get(
      Uri.parse("http://10.0.2.2:8000/doctors/by_specialty/$specialtyId"),
    );

    var data = jsonDecode(response.body);

    setState(() {
      doctors = data["data"];
      loadingDoctors = false;
    });
  }

  // حجز الموعد
  Future<void> bookAppointment() async {
    if (selectedDoctorId == null || selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please select doctor and date")),
      );
      return;
    }

    setState(() => isLoading = true);

    var response = await http.post(
      Uri.parse("http://10.0.2.2:8000/appointments/book"),
      headers: {"Content-Type": "application/x-www-form-urlencoded"},
      body: {
        "patient_id": widget.userId.toString(),
        "doctor_id": selectedDoctorId.toString(),
        "appointment_date": selectedDate.toString().split(" ")[0],
      },
    );

    setState(() => isLoading = false);

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
            // اختيار التخصص
            loadingSpecialties
                ? Center(child: CircularProgressIndicator())
                : DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: "Select Specialty",
                      border: OutlineInputBorder(),
                    ),
                    items: specialties.map<DropdownMenuItem<String>>((spec) {
                      return DropdownMenuItem<String>(
                        value: spec["id"].toString(),
                        child: Text(spec["name"]),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedSpecialtyId = value;
                      });
                      fetchDoctorsBySpecialty(value!);
                    },
                  ),

            const SizedBox(height: 20),

            // اختيار الطبيب حسب التخصص
            if (selectedSpecialtyId != null)
              loadingDoctors
                  ? Center(child: CircularProgressIndicator())
                  : DropdownButtonFormField<int>(
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

            // اختيار التاريخ
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
                    : "Selected: ${selectedDate!.toLocal()}".split(' ')[0],
              ),
            ),

            const SizedBox(height: 30),

            // زر الحجز
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
