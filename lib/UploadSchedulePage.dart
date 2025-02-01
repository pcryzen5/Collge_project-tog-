import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo;

class UploadSchedulePage extends StatefulWidget {
  const UploadSchedulePage({super.key});

  @override
  _UploadSchedulePageState createState() => _UploadSchedulePageState();
}

class _UploadSchedulePageState extends State<UploadSchedulePage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _professorController = TextEditingController();
  final _notesController = TextEditingController();
  String? _selectedClass; // Variable to hold selected class
  DateTime? selectedDateTime;
  bool isLoading = false;
  List<String> availableClasses = []; // List to store available classes

  final String mongoUri = "mongodb://purkaitshubham5:sam@students-shard-00-00.x3rdy.mongodb.net:27017,students-shard-00-01.x3rdy.mongodb.net:27017,students-shard-00-02.x3rdy.mongodb.net:27017/mdbuser_test_db?ssl=true&replicaSet=atlas-123-shard-0&authSource=admin";
  final String dbteach = "mongodb://purkaitshubham5:sam@students-shard-00-00.x3rdy.mongodb.net:27017,students-shard-00-01.x3rdy.mongodb.net:27017,students-shard-00-02.x3rdy.mongodb.net:27017/Teacher?ssl=true&replicaSet=atlas-123-shard-0&authSource=admin";
  final String collectionName = "schedules";

  // Fetch available classes for the teacher
  // Fetch available classes for the teacher
  Future<void> fetchAvailableClasses() async {
    try {
      final db = await mongo.Db.create(dbteach);
      await db.open();
      final collection = db.collection('teacher'); // Teachers collection

      // Fetch teacher data
      final teacherData = await collection.findOne(
        mongo.where.eq('professor', _professorController.text.trim()),
      );

      if (teacherData != null) {
        // Debugging: Print the teacher data to check the format
        print("Teacher data found: $teacherData");

        setState(() {
          availableClasses = List<String>.from(teacherData['classes'] ?? []);
        });
      } else {
        // Debugging: Print message if no teacher data is found
        print("No teacher data found for professor: ${_professorController.text.trim()}");
      }

      await db.close();
    } catch (e) {
      print("Error fetching classes: $e");
    }
  }


  // Helper function to format DateTime
  String formatDateTime(DateTime? dateTime) {
    if (dateTime == null) {
      return "Select Date and Time";
    }
    return "${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} "
        "${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}";
  }

  // Combine Date and Time selection into a single method
  Future<void> selectDateTime() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      final pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (pickedTime != null) {
        setState(() {
          selectedDateTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  Future<void> uploadSchedule() async {
    if (!_formKey.currentState!.validate() || selectedDateTime == null || _selectedClass == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all required fields.")),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    final Map<String, dynamic> scheduleData = {
      "title": _titleController.text.trim(),
      "dateTime": selectedDateTime, // Upload combined DateTime
      "professor": _professorController.text.trim(),
      "notes": _notesController.text.trim(),
      "classes": _selectedClass, // Add the selected class here
    };

    try {
      final db = await mongo.Db.create(mongoUri);
      await db.open();
      final collection = db.collection(collectionName);

      await collection.insert(scheduleData);

      await db.close();

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Schedule uploaded successfully!")),
      );

      // Clear all fields after successful upload
      _titleController.clear();
      _professorController.clear();
      _notesController.clear();
      setState(() {
        selectedDateTime = null;
        _selectedClass = null; // Clear the class selection
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error uploading schedule: $e")),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    // Fetch available classes when the professor field is populated
    _professorController.addListener(() {
      fetchAvailableClasses();
    });
  }

  @override
  void dispose() {
    super.dispose();
    _professorController.removeListener(() {
      fetchAvailableClasses();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:AppBar(backgroundColor: Color(0xE60C0569),
        automaticallyImplyLeading: true, // Enables the back button
        iconTheme: IconThemeData(
          color: Colors.white, // Changes the back button color to blue
        ),
        title: Text(
          'Upload Schedule',
          style: GoogleFonts.inter( // Using Google Fonts
            textStyle: TextStyle(
              color: Colors.white,
              fontSize: 22,
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
              // DateTime selection with formatted text and button
              Row(
                children: [
                  Text(formatDateTime(selectedDateTime)),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: selectDateTime,
                    child: const Icon(Icons.calendar_today,color: Colors.white,),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF231D77),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                      padding:
                      EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Title Field
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: "Title",
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter the title.";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),

              // Professor Name Field
              TextFormField(
                controller: _professorController,
                decoration: const InputDecoration(
                  labelText: "Professor's Name",
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter the professor's name.";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),

              // Class Dropdown
              DropdownButtonFormField<String>(
                value: _selectedClass,
                decoration: const InputDecoration(
                  labelText: "Class",
                  border: OutlineInputBorder(),
                ),
                onChanged: (String? newClass) {
                  setState(() {
                    _selectedClass = newClass;
                  });
                },
                items: availableClasses.map((className) {
                  return DropdownMenuItem<String>(
                    value: className,
                    child: Text(className),
                  );
                }).toList(),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please select a class.";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),

              // Notes Field
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: "Additional Notes (Optional)",
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 20),

              // Upload Button
              ElevatedButton(
                onPressed: isLoading ? null : uploadSchedule,
                child: const Text("Upload Schedule",style: TextStyle(fontSize: 14, color: Colors.white),),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF231D77),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                  padding:
                  EdgeInsets.symmetric(horizontal: 50, vertical: 10),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
