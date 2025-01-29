import 'package:flutter/material.dart';
import 'AddStudentPage.dart'; // Add Student Page
import 'EditStudentPage.dart'; // Edit Student Page
import 'UploadNoticePage.dart'; // Upload Notice Page
import 'UploadSchedulePage.dart'; // Upload Schedule Page
import 'UploadMarksPage.dart'; // Upload Marks Page
import 'ViewStudent.dart'; // View Student Page
import 'MarkAttendancePage.dart'; // Mark Attendance Page
import 'UploadAnnouncementPage.dart'; // Upload Announcement Page
import 'TeacherAttendancePage.dart'; // Teacher Attendance Page

class WelcomePage extends StatelessWidget {
  final String teacherName; // User's username
  final String department;

  const WelcomePage({
    super.key,
    required this.teacherName,
    required this.department,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Welcome"),
      ),
      body: Column(
        children: [
          // Top half: Teacher Profile
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16.0),
            color: Colors.blue[100],
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 40,
                  backgroundImage: AssetImage('assets/logo.png'),
                ),
                const SizedBox(height: 10),
                Text(
                  teacherName,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text("Department: $department"),
                const Text("College: Hinduja College"),
              ],
            ),
          ),
          // Bottom half: Buttons
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Button 1: Add_Student
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AddStudentPage(),
                        ),
                      );
                    },
                    child: const Text("Add Student"),
                  ),
                  const SizedBox(height: 10),
                  // Button 2: Edit_Student
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const EditStudentPage(),
                        ),
                      );
                    },
                    child: const Text("Edit Student"),
                  ),
                  const SizedBox(height: 10),
                  // Button 3: Upload_Notice
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const UploadNoticePage(),
                        ),
                      );
                    },
                    child: const Text("Upload Notice"),
                  ),
                  const SizedBox(height: 10),
                  // Button 4: Upload_Schedule
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const UploadSchedulePage(),
                        ),
                      );
                    },
                    child: const Text("Upload Schedule"),
                  ),
                  const SizedBox(height: 10),
                  // Button 5: Upload_Marks
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const UploadMarksPage(),
                        ),
                      );
                    },
                    child: const Text("Upload Marks"),
                  ),
                  const SizedBox(height: 10),
                  // Button 6: Display_Students
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const StudentsByClassPage(),
                        ),
                      );
                    },
                    child: const Text("Display Students"),
                  ),
                  const SizedBox(height: 10),
                  // Button 7: Mark_Attendance
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MarkAttendancePage(),
                        ),
                      );
                    },
                    child: const Text("Mark Attendance"),
                  ),
                  const SizedBox(height: 10),
                  // Button 8: Upload_Announcement
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => UploadAnnouncementPage(),
                        ),
                      );
                    },
                    child: const Text("Upload Announcement"),
                  ),
                  const SizedBox(height: 10),
                  // Button 9: View_Attendance
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const TeacherAttendancePage(),
                        ),
                      );
                    },
                    child: const Text("View Attendance"),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
