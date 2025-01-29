import 'dart:convert'; // Import for base64Decode
import 'package:flutter/material.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo;

class StudentsByClassPage extends StatefulWidget {
  const StudentsByClassPage({super.key});

  @override
  _StudentsByClassPageState createState() => _StudentsByClassPageState();
}

class _StudentsByClassPageState extends State<StudentsByClassPage> {
  final List<String> classes = [
    'FyBscIt_A',
    'SyBscIt_A',
    'TyBscIt_A',
    'FyBMS_A',
    'SyBMS_A',
    'TyBMS_A'
  ]; // Add more classes here
  String? selectedClass;
  late mongo.Db db;
  late mongo.DbCollection studentsCollection;
  List<Map<String, dynamic>> students = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    initializeDatabase();
  }

  /// Initialize MongoDB connection
  Future<void> initializeDatabase() async {
    try {
      db = await mongo.Db.create(
          "mongodb://purkaitshubham5:sam@students-shard-00-00.x3rdy.mongodb.net:27017,students-shard-00-01.x3rdy.mongodb.net:27017,students-shard-00-02.x3rdy.mongodb.net:27017/mdbuser_test_db?ssl=true&replicaSet=atlas-123-shard-0&authSource=admin");
      await db.open();
      studentsCollection =
          db.collection('students'); // Replace with your collection name
    } catch (e) {
      debugPrint("Error initializing database: $e");
    }
  }

  /// Fetch students based on the selected class
  Future<void> fetchStudents() async {
    if (selectedClass == null) return;

    setState(() {
      isLoading = true;
      students = [];
    });

    try {
      final result =
          await studentsCollection.find({"class_name": selectedClass}).toList();
      setState(() {
        students = result.map((e) => Map<String, dynamic>.from(e)).toList();
      });
    } catch (e) {
      debugPrint("Error fetching students: $e");
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
        title: const Text("Students By Class"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Dropdown to select class
            DropdownButtonFormField<String>(
              value: selectedClass,
              decoration: const InputDecoration(
                labelText: "Select Class",
                border: OutlineInputBorder(),
              ),
              items: classes
                  .map((className) => DropdownMenuItem<String>(
                        value: className,
                        child: Text(className),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  selectedClass = value;
                });
                fetchStudents();
              },
            ),
            const SizedBox(height: 20),

            // Display students list
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : students.isEmpty
                      ? const Center(
                          child: Text("No students found for this class."))
                      : ListView.builder(
                          itemCount: students.length,
                          itemBuilder: (context, index) {
                            final student = students[index];
                            return Card(
                              elevation: 4.0,
                              margin: const EdgeInsets.symmetric(vertical: 8.0),
                              child: ListTile(
                                leading: student["id_card_print"] != null
                                    ? Image.memory(
                                        base64Decode(student["id_card_print"]),
                                        width: 80,
                                        height: 80,
                                        fit: BoxFit.cover,
                                      )
                                    : const Icon(Icons.person, size: 80),
                                title: Text(
                                  student["full_name"] ?? "N/A",
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                        "Username: ${student["username"] ?? "N/A"}"),
                                    Text("Email: ${student["email"] ?? "N/A"}"),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    db.close();
    super.dispose();
  }
}
