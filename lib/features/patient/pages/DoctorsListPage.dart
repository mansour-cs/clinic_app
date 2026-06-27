import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DoctorsListPage extends StatefulWidget {
  const DoctorsListPage({super.key});

  @override
  State<DoctorsListPage> createState() => _DoctorsListPageState();
}

class _DoctorsListPageState extends State<DoctorsListPage> {
  List doctors = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchDoctors();
  }

  Future<void> fetchDoctors() async {
    var response = await http.get(
      Uri.parse("http://10.0.2.2:8000/doctors"),
    );

    var data = jsonDecode(response.body);

    if (data["status"] == "success") {
      setState(() {
        doctors = data["data"];
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to load doctors")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Doctors")),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : doctors.isEmpty
              ? Center(child: Text("No doctors found"))
              : ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: doctors.length,
                  itemBuilder: (context, index) {
                    var doctor = doctors[index];

                    return Card(
                      margin: EdgeInsets.only(bottom: 16),
                      child: ListTile(
                        title: Text(
                          doctor["full_name"],
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 6),
                            Text("Specialty: ${doctor["specialty_name"]}"),
                            Text("Phone: ${doctor["phone"] ?? "N/A"}"),
                            Text("Fee: ${doctor["consultation_fee"]}"),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
