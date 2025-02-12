import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo;

class MarkAttendancePage extends StatefulWidget {
  const MarkAttendancePage({super.key});

  @override
  _MarkAttendancePageState createState() => _MarkAttendancePageState();
}

class _MarkAttendancePageState extends State<MarkAttendancePage> {
  // student database url
  final String studentMongoUrl =
      "mongodb://purkaitshubham5:sam@students-shard-00-00.x3rdy.mongodb.net:27017,students-shard-00-01.x3rdy.mongodb.net:27017,students-shard-00-02.x3rdy.mongodb.net:27017/mdbuser_test_db?ssl=true&replicaSet=atlas-123-shard-0&authSource=admin";
  // teacher database url
  final String teacherMongoUrl =
      "mongodb://purkaitshubham5:sam@students-shard-00-00.x3rdy.mongodb.net:27017,students-shard-00-01.x3rdy.mongodb.net:27017,students-shard-00-02.x3rdy.mongodb.net:27017/Teacher?ssl=true&replicaSet=atlas-123-shard-0&authSource=admin";
  final String studentsCollectionName = "students";
  final String teachersCollectionName = "teacher";
  final String attendanceCollectionNamePrefix = "attendance";

  mongo.Db? studentDb;
  mongo.Db? teacherDb;

  String? professorName;
  String? selectedClass;
  String? selectedSubject;

  List<String> professorClasses = [];
  List<Map<String, dynamic>> students = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    initializeDatabases();
  }

  Future<void> initializeDatabases() async {
    try {
      studentDb = await mongo.Db.create(studentMongoUrl);
      teacherDb = await mongo.Db.create(teacherMongoUrl);

      await studentDb!.open();
      debugPrint("Student Database connected: ${studentDb!.state}");

      await teacherDb!.open();
      debugPrint("Teacher Database connected: ${teacherDb!.state}");

      setState(() {});
    } catch (e) {
      debugPrint("Error connecting to MongoDB: $e");
    }
  }

  // Fetch classes for the professor(similar to UploadSchedulePage)
  Future<void> fetchProfessorClasses(String professorName) async {
    if (teacherDb == null || teacherDb!.state != mongo.State.OPEN) {
      debugPrint("Teacher database is not ready yet.");
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final teachersCollection = teacherDb!.collection(teachersCollectionName);
      final professorDoc = await teachersCollection.findOne({
        "professor": {
          "\$regex": professorName,
          "\$options": "i"
        }
      });

      if (professorDoc != null && professorDoc["classes"] != null) {
        setState(() {
          professorClasses = List<String>.from(professorDoc["classes"]);
          isLoading = false;
        });
        debugPrint("Classes fetched: $professorClasses");
      } else {
        setState(() {
          professorClasses = [];
          isLoading = false;
        });
        debugPrint("No classes found for professor: $professorName");
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      debugPrint("Error fetching professor classes: $e");
    }
  }

  Future<void> fetchStudents(String className) async {
    if (studentDb == null) return;

    setState(() {
      isLoading = true;
      students = [];
    });

    try {
      final studentsCollection = studentDb!.collection(studentsCollectionName);
      final result =
          await studentsCollection.find({"class_name": className}).toList();

      setState(() {
        students = result.map((e) => Map<String, dynamic>.from(e)).toList();
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      debugPrint("Error fetching students: $e");
    }
  }

  // Mark attendance for students
  Future<void> markAttendance(
      String userId, String subject, bool isPresent) async {
    // Ensure the database is open
    if (studentDb == null || studentDb!.state != mongo.State.OPEN) {
      debugPrint("Student database is not connected.");
      return;
    }

    final currentDate = DateTime.now();
    final formattedDate =
        "${currentDate.day}/${currentDate.month}/${currentDate.year}";
    final attendanceField = "${subject}_$formattedDate";
    final attendanceCollectionName =
        "$attendanceCollectionNamePrefix${currentDate.month}_${currentDate.year}";

    try {
      // Access attendance database and collection
      final attendanceDb = await mongo.Db.create(
          studentMongoUrl.replaceFirst("/mdbuser_test_db", "/attendance"));
      await attendanceDb.open();
      final attendanceCollection =
          attendanceDb.collection(attendanceCollectionName);

      // Fetch student details from student collection
      final studentsCollection = studentDb!.collection(studentsCollectionName);
      final studentDetails =
          await studentsCollection.findOne({"user_id": userId});

      if (studentDetails == null) {
        debugPrint("No student found with user_id: $userId");
        return;
      }

      final rollNo = studentDetails["roll_no"];
      final className = studentDetails["class_name"];


      final existingAttendance =
          await attendanceCollection.findOne({"user_id": userId});

      if (existingAttendance == null) {
        // Insert new attendance
        final newAttendance = {
          "user_id": userId,
          "roll_no": rollNo,
          "class_name": className,
          "attendance": {
            subject: {attendanceField: isPresent}
          },
        };
        await attendanceCollection.insertOne(newAttendance);
        debugPrint("New attendance record created for $userId: $newAttendance");
      } else {
        // Update existing attendance
        final updatedAttendance = existingAttendance["attendance"] ?? {};

        // Check if the subject already exists in attendance coll
        if (!updatedAttendance.containsKey(subject)) {
          updatedAttendance[subject] = {};
        }
        updatedAttendance[subject][attendanceField] = isPresent;

        // Update the document in mongodb
        await attendanceCollection.updateOne(
          mongo.where.eq("user_id", userId),
          mongo.modify.set("attendance", updatedAttendance),
        );
        debugPrint("Attendance updated for $userId: $updatedAttendance");
      }

      await attendanceDb.close();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Attendance marked successfully!")),
      );
    } catch (e) {
      debugPrint("Error marking attendance: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error marking attendance: $e")),
      );
    }
  }

  @override
  void dispose() {
    studentDb?.close();
    teacherDb?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Color(0xE60C0569),
        automaticallyImplyLeading: true,
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
        title: Text(
          'Mark Attendance',
          style: GoogleFonts.inter(
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
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: "Professor Name",
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                professorName = value;
                fetchProfessorClasses(
                    value); // Fetch classes 
              },
            ),
            const SizedBox(height: 16),
            // Displaying dropdown of classes if available
            if (isLoading)
              CircularProgressIndicator()
            else
              DropdownButtonFormField<String>(
                value: selectedClass,
                decoration: InputDecoration(
                  labelText: "Select Class",
                  border: OutlineInputBorder(),
                ),
                items: professorClasses
                    .map((className) => DropdownMenuItem(
                          value: className,
                          child: Text(className),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    selectedClass = value;
                    students = [];
                  });
                  if (value != null) {
                    fetchStudents(value); // Fetch students for selected class
                  }
                },
              ),
            const SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: "Enter Subject Name",
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                selectedSubject = value;
              },
            ),
            const SizedBox(height: 16),
            if (isLoading) CircularProgressIndicator(),
            if (students.isNotEmpty)
              Expanded(
                child: ListView.builder(
                  itemCount: students.length,
                  itemBuilder: (context, index) {
                    final student = students[index];
                    return Card(
                      child: ListTile(
                        title: Text(student["full_name"] ?? "N/A"),
                        subtitle: Text("Roll No: ${student["roll_no"]}"),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.check, color: Colors.green),
                              onPressed: () => markAttendance(
                                  student["user_id"], selectedSubject!, true),
                            ),
                            IconButton(
                              icon: Icon(Icons.close, color: Colors.red),
                              onPressed: () => markAttendance(
                                  student["user_id"], selectedSubject!, false),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            if (!isLoading && students.isEmpty && selectedClass != null)
              Text("No students found for the selected class."),
          ],
        ),
      ),
    );
  }
}
