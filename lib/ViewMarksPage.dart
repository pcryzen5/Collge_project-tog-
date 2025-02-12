import 'package:flutter/material.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo;

class ViewMarksPage extends StatefulWidget {
  @override
  _ViewMarksPageState createState() => _ViewMarksPageState();
}

class _ViewMarksPageState extends State<ViewMarksPage> {
  TextEditingController prnController = TextEditingController();
  Map<String, dynamic>? studentData;
  bool isLoading = false;
  String? errorMessage;

  Future<void> fetchMarks() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
      studentData = null;
    });

    try {
      var db = await mongo.Db.create("mongodb://purkaitshubham5:sam@students-shard-00-00.x3rdy.mongodb.net:27017,students-shard-00-01.x3rdy.mongodb.net:27017,students-shard-00-02.x3rdy.mongodb.net:27017/mdbuser_test_db?ssl=true&replicaSet=atlas-123-shard-0&authSource=admin");
      await db.open();
      var collection = db.collection("students");

      // Fetch student by PRNno.
      var student = await collection.findOne(mongo.where.eq("user_id", prnController.text));

      setState(() {
        studentData = student;
        if (student == null) {
          errorMessage = "No student found with this PRN.";
        }
      });

      await db.close();
    } catch (e) {
      print("Error fetching marks: $e");
      setState(() {
        errorMessage = "An error occurred while fetching data.";
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
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
        title: Text("View Marks",
          style: TextStyle(color: Colors.white)
        ),
        backgroundColor: const Color(0xFF0C0569),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // PRN Input Field
            TextField(
              controller: prnController,
              decoration: InputDecoration(
                labelText: "Enter PRN (User ID)",
                border: OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: fetchMarks,
                ),
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20),

            // Loading Indicator
            if (isLoading) CircularProgressIndicator(),

            // Error Message
            if (errorMessage != null)
              Text(errorMessage!,
                  style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),

            // Display Student Marks
            if (studentData != null) _buildStudentMarks(),
          ],
        ),
      ),
    );
  }

  Widget _buildStudentMarks() {
    return Expanded(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Student: ${studentData!['full_name']}",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              "Roll No: ${studentData!['roll_no']}",
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 10),
            Divider(thickness: 2),

            // Display Marks Semester-wise
            ...studentData!['semester'].entries.map<Widget>((semesterEntry) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${semesterEntry.key}:",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue),
                  ),
                  SizedBox(height: 5),
                  ...(semesterEntry.value as Map<String, dynamic>).entries.map<Widget>((subjectEntry) {
                    return Padding(
                      padding: const EdgeInsets.only(left: 10, bottom: 4),
                      child: Text(
                        "📖 ${subjectEntry.key}: ${subjectEntry.value}",
                        style: TextStyle(fontSize: 16),
                      ),
                    );
                  }).toList(),
                  SizedBox(height: 10),
                ],
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}
