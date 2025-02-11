import 'package:flutter/material.dart';
import 'AddStudentPage.dart';
import 'EditStudentPage.dart';
import 'UploadNoticePage.dart';
import 'UploadSchedulePage.dart';
import 'UploadMarksPage.dart';
import 'ViewStudent.dart';
import 'MarkAttendancePage.dart';
import 'UploadAnnouncementPage.dart';
import 'TeacherAttendancePage.dart';
import 'ViewMarksPage.dart'; // Import Marks Page

class WelcomePage extends StatelessWidget {
  final String teacherName;
  final String department;
  final List<String> classes;

  const WelcomePage({
    Key? key,
    required this.teacherName,
    required this.department,
    required this.classes,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: const Color(0xFF0C0569),
        title: const Text(
          "Welcome",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildProfileSection(),
            _buildActionSection(
              title: "Student Management",
              buttons: [
                _buildActionButton(context, "Add Student", () => _navigate(context, AddStudentPage())),
                _buildActionButton(context, "Edit/Delete Student", () => _navigate(context, EditStudentPage())),
              ],
            ),
            _buildActionSection(
              title: "Marks Management",
              buttons: [
                _buildActionButton(context, "Upload Marks", () => _navigate(context, UploadMarksPage())),
                _buildActionButton(context, "View Marks", () => _navigate(context, ViewMarksPage())), // New Button
              ],
            ),
            _buildActionSection(
              title: "Schedule Management",
              buttons: [
                _buildActionButton(context, "Upload Schedule", () => _navigate(context, UploadSchedulePage())),
              ],
            ),
            _buildActionSection(
              title: "Notice Management",
              buttons: [
                _buildActionButton(context, "Upload Notice", () => _navigate(context, UploadNoticePage())),
                _buildActionButton(context, "Upload Announcement", () => _navigate(context, UploadAnnouncementPage())),
              ],
            ),
            _buildActionSection(
              title: "Attendance",
              buttons: [
                _buildActionButton(context, "Mark Attendance", () => _navigate(context, MarkAttendancePage())),
                _buildActionButton(context, "View Attendance", () => _navigate(context, TeacherAttendancePage())),
              ],
            ),
            _buildActionSection(
              title: "Student Details",
              buttons: [
                _buildActionButton(context, "Display Students", () => _navigate(context, StudentsByClassPage())),
              ],
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const CircleAvatar(
            radius: 75,
            backgroundImage: AssetImage('assets/logo.png'),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Full name: $teacherName', style: const TextStyle(fontSize: 22)),
                const SizedBox(height: 5),
                const Text("College: Hinduja College", style: TextStyle(color: Colors.black45, fontSize: 16)),
                const SizedBox(height: 10),
                Text("Assigned Classes: ${classes.join(", ")}", style: const TextStyle(fontSize: 16)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionSection({required String title, required List<Widget> buttons}) {
    return Container(
      width: 350,
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          ...buttons,
        ],
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, String text, VoidCallback onPressed) {
    return Container(
      width: 250,
      height: 45,
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF0C0569),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        ),
        child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 16)),
      ),
    );
  }

  void _navigate(BuildContext context, Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => page));
  }
}
