import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DoctorAppointmentsPage extends StatefulWidget {
  final int doctorId;
  final bool onlyToday;

  const DoctorAppointmentsPage({
    super.key,
    required this.doctorId,
    required this.onlyToday,
  });

  @override
  State<DoctorAppointmentsPage> createState() => _DoctorAppointmentsPageState();
}

class _DoctorAppointmentsPageState extends State<DoctorAppointmentsPage> {
  List appointments = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchAppointments();
  }

  Future<void> fetchAppointments() async {
    var response = await http.get(
      Uri.parse("http://10.0.2.2:8000/appointments/doctor/${widget.doctorId}"),
    );

    var data = jsonDecode(response.body);

    if (data["status"] == "success") {
      List allAppointments = data["data"];

      // إذا بدنا فقط مواعيد اليوم
      if (widget.onlyToday) {
        DateTime today = DateTime.now();
        allAppointments = allAppointments.where((appt) {
          DateTime date = DateTime.parse(appt["appointment_date"]);
          return date.year == today.year &&
              date.month == today.month &&
              date.day == today.day;
        }).toList();
      }

      setState(() {
        appointments = allAppointments;
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to load appointments")),
      );
    }
  }

  void openAddNotesPage(int appointmentId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddNotesPage(appointmentId: appointmentId),
      ),
    );
  }

  void updateStatus(int appointmentId, String newStatus) async {
    var response = await http.post(
      Uri.parse("http://10.0.2.2:8000/appointments/update_status"),
      headers: {"Content-Type": "application/x-www-form-urlencoded"},
      body: {
        "appointment_id": appointmentId.toString(),
        "status": newStatus,
      },
    );

    var data = jsonDecode(response.body);

    if (data["status"] == "success") {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Status updated")),
      );
      fetchAppointments(); // إعادة تحميل المواعيد
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.onlyToday ? "Today's Appointments" : "All Appointments"),
      ),
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
                        title: Text(
                          "Patient: ${appt["patient_name"]}",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
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
                        trailing: PopupMenuButton<String>(
                          onSelected: (value) {
                            if (value == "notes") {
                              openAddNotesPage(appt["id"]);
                            } else {
                              updateStatus(appt["id"], value);
                            }
                          },
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              value: "confirmed",
                              child: Text("Confirm"),
                            ),
                            PopupMenuItem(
                              value: "completed",
                              child: Text("Mark Completed"),
                            ),
                            PopupMenuItem(
                              value: "cancelled",
                              child: Text("Cancel"),
                            ),
                            PopupMenuItem(
                              value: "notes",
                              child: Text("Add Notes"),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}

// صفحة إضافة الملاحظات
class AddNotesPage extends StatefulWidget {
  final int appointmentId;

  const AddNotesPage({super.key, required this.appointmentId});

  @override
  State<AddNotesPage> createState() => _AddNotesPageState();
}

class _AddNotesPageState extends State<AddNotesPage> {
  final notesController = TextEditingController();

  Future<void> saveNotes() async {
    var response = await http.post(
      Uri.parse("http://10.0.2.2:8000/appointments/add_notes"),
      headers: {"Content-Type": "application/x-www-form-urlencoded"},
      body: {
        "appointment_id": widget.appointmentId.toString(),
        "doctor_notes": notesController.text,
      },
    );

    var data = jsonDecode(response.body);

    if (data["status"] == "success") {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Notes added")),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Add Notes")),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            TextField(
              controller: notesController,
              maxLines: 5,
              decoration: InputDecoration(
                labelText: "Doctor Notes",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: saveNotes,
              child: Text("Save"),
            ),
          ],
        ),
      ),
    );
  }
}
