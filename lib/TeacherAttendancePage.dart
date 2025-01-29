import 'package:flutter/material.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo;
import 'package:intl/intl.dart';

class TeacherAttendancePage extends StatefulWidget {
  const TeacherAttendancePage({Key? key}) : super(key: key);

  @override
  _TeacherAttendancePageState createState() => _TeacherAttendancePageState();
}

class _TeacherAttendancePageState extends State<TeacherAttendancePage> {
  final String dbUrl ="mongodb://purkaitshubham5:sam@students-shard-00-00.x3rdy.mongodb.net:27017,students-shard-00-01.x3rdy.mongodb.net:27017,students-shard-00-02.x3rdy.mongodb.net:27017/attendance?ssl=true&replicaSet=atlas-123-shard-0&authSource=admin";
  final TextEditingController userIdController = TextEditingController();
  bool isLoading = false;
  Map<String, dynamic>? attendanceData;
  String errorMessage = '';

  Future<void> fetchAttendance(String userId) async {
    setState(() {
      isLoading = true;
      attendanceData = null;
      errorMessage = '';
    });

    try {
      // Determine the current month and year
      final DateTime now = DateTime.now();
      final String collectionName = "attendance${now.month}_${now.year}";

      // Connect to MongoDB and fetch attendance data
      final db = await mongo.Db.create(dbUrl);
      await db.open();
      final collection = db.collection(collectionName);

      final studentAttendance = await collection.findOne({'user_id': userId});
      if (studentAttendance == null) {
        throw Exception("No attendance found for PRN/User ID: $userId");
      }

      setState(() {
        attendanceData = studentAttendance['attendance'];
      });

      await db.close();
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("View Attendance")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Input Field for User ID (PRN)
            TextField(
              controller: userIdController,
              decoration: InputDecoration(
                labelText: "Enter User ID (PRN)",
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    if (userIdController.text.isNotEmpty) {
                      fetchAttendance(userIdController.text.trim());
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Display Attendance Data
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : errorMessage.isNotEmpty
                ? Text(
              errorMessage,
              style: const TextStyle(color: Colors.red),
            )
                : attendanceData != null
                ? Expanded(
              child: ListView(
                children: attendanceData!.entries.map((entry) {
                  String subject = entry.key;
                  Map<String, dynamic> attendanceDates = entry.value;

                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Subject: $subject",
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          ...attendanceDates.entries.map((dateEntry) {
                            String date = dateEntry.key.split('_').last;
                            bool isPresent = dateEntry.value;
                            return Row(
                              mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                              children: [
                                Text("Date: $date"),
                                Text(
                                  isPresent ? "Present" : "Absent",
                                  style: TextStyle(
                                    color: isPresent
                                        ? Colors.green
                                        : Colors.red,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            )
                : const Text("Enter a User ID to view attendance."),
          ],
        ),
      ),
    );
  }
}
