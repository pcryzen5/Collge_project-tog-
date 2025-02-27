import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo;

class UploadMarksPage extends StatefulWidget {
  const UploadMarksPage({super.key});

  @override
  _UploadMarksPageState createState() => _UploadMarksPageState();
}

class _UploadMarksPageState extends State<UploadMarksPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController userIdController = TextEditingController();
  String? selectedSemester;
  List<Map<String, TextEditingController>> subjects = [
    {"name": TextEditingController(), "marks": TextEditingController()},
  ];

  bool isLoading = false;
  late mongo.Db db;
  late mongo.DbCollection studentCollection;

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
      studentCollection = db.collection('students');
    } catch (e) {
      debugPrint("Error initializing database: $e");
    }
  }

  /// Function to upload marks to MongoDB
  Future<void> uploadMarks() async {
    if (!_formKey.currentState!.validate() || selectedSemester == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all required fields.")),
      );
      return;
    }

    final newMarksData = {
      for (var subject in subjects)
        subject["name"]!.text.trim(): int.parse(subject["marks"]!.text.trim()),
    };

    setState(() {
      isLoading = true;
    });

    try {
      // Check if the student exists
      final student = await studentCollection
          .findOne({"user_id": userIdController.text.trim()});

      if (student != null) {
        // Student exists, retrieve current semester data
        final semesterData = student['semester'] ?? {};
        final currentSemesterData =
            Map<String, dynamic>.from(semesterData[selectedSemester] ?? {});

        // Merge new marks with existing data
        newMarksData.forEach((subjectName, marks) {
          currentSemesterData[subjectName] = marks;
        });

        // Update the database with the modified semester data
        semesterData[selectedSemester] = currentSemesterData;
        await studentCollection.updateOne(
          {"user_id": userIdController.text.trim()},
          {
            "\$set": {"semester": semesterData},
          },
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Marks updated successfully!")),
        );
      } else {
        // Student does not exist, create a new record
        await studentCollection.insertOne({
          "user_id": userIdController.text.trim(),
          "semester": {selectedSemester: newMarksData},
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Marks uploaded successfully!")),
        );
      }

      // Clear fields after successful upload
      clearFields();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error uploading marks: $e")),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  /// Clear form fields
  void clearFields() {
    setState(() {
      userIdController.clear();
      selectedSemester = null;
      subjects = [
        {"name": TextEditingController(), "marks": TextEditingController()},
      ];
    });
  }

  /// Add a new subject field
  void addSubject() {
    setState(() {
      subjects.add(
          {"name": TextEditingController(), "marks": TextEditingController()});
    });
  }

  /// Remove a subject field
  void removeSubject(int index) {
    setState(() {
      subjects.removeAt(index);
    });
  }

  @override
  void dispose() {
    userIdController.dispose();
    for (var subject in subjects) {
      subject["name"]?.dispose();
      subject["marks"]?.dispose();
    }
    db.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xE60C0569),
        automaticallyImplyLeading: true, // Enables the back button
        iconTheme: IconThemeData(
          color: Colors.white, // Changes the back button color to blue
        ),
        title: Text(
          'Upload Marks',
          style: GoogleFonts.inter( // Using Google Fonts
            textStyle: TextStyle(
              color: Colors.white,
              fontSize: 18,
              letterSpacing: 0.0,
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              /// User_ID (PRN Number)
              TextFormField(
                controller: userIdController,
                decoration: const InputDecoration(
                  labelText: "User ID (PRN Number)",
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter the User ID.";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              /// Semester Dropdown
              DropdownButtonFormField<String>(
                value: selectedSemester,
                decoration: const InputDecoration(
                  labelText: "Select Semester",
                  border: OutlineInputBorder(),
                ),
                items: List.generate(
                  8,
                  (index) => DropdownMenuItem(
                    value: "Semester ${index + 1}",
                    child: Text("Semester ${index + 1}"),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    selectedSemester = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please select a semester.";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              ...subjects.asMap().entries.map((entry) {
                int index = entry.key;
                Map<String, TextEditingController> subject = entry.value;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: subject["name"],
                            decoration: const InputDecoration(
                              labelText: "Subject Name",
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Please enter the subject name.";
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextFormField(
                            controller: subject["marks"],
                            decoration: const InputDecoration(
                              labelText: "Marks",
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Please enter the marks.";
                              }
                              if (int.tryParse(value) == null) {
                                return "Please enter a valid number.";
                              }
                              int marks = int.parse(value);
                              if (marks < 0 || marks > 150) {
                                return "Marks must be between 0 and 150.";
                              }
                              return null;
                            },
                          ),
                        ),
                        IconButton(
                          onPressed: () => removeSubject(index),
                          icon: const Icon(Icons.delete, color: Colors.red),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                  ],
                );
              }),

              // Add Subject Button
              OutlinedButton(
                onPressed: addSubject,
                child: const Text("Add Subject",style: TextStyle(fontSize: 14, color: Color(0xff231D77)),),
              ),
              const SizedBox(height: 20),

              // Upload Button
              ElevatedButton(
                onPressed: isLoading ? null : uploadMarks,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF231D77),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                  padding:
                  EdgeInsets.symmetric(horizontal: 50, vertical: 10),
                ),
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Upload Marks",style: TextStyle(fontSize: 14, color: Colors.white),),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
