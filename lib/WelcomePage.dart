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
import 'package:tog/LoginPage.dart';

class WelcomePage extends StatelessWidget {
  final String teacherName;
  final String department;
  final List<String> classes; // List of assigned classes

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
            // Profile Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(0),
                  bottomRight: Radius.circular(0),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Profile Picture on Left
                  const CircleAvatar(
                    radius: 75,
                    backgroundImage: AssetImage('assets/logo.png'),
                  ),
                  const SizedBox(width: 16),

                  // Name and Details on Right
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        Text(
                          'Full name: $teacherName',
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 22,
                          ),
                        ),
                        const SizedBox(height: 5),
                        const Text(
                          "College: Hinduja College",
                          style: TextStyle(color: Colors.black45, fontSize: 16),
                        ),
                        const SizedBox(height: 10,),

                        // Display Assigned Classes
                        Text(
                          "Assigned Classes:",
                          style: const TextStyle(
                            color: Colors.black38,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: classes.map((cls) => Text(
                            "- $cls",
                            style: const TextStyle(color: Colors.black45, fontSize: 16),
                          )).toList(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsetsDirectional.fromSTEB(0, 15, 0, 15),
              child: Text(
                'College: K.P.B Hinduja College of Arts \n and Commerce',
                textAlign: TextAlign.start,
                style: TextStyle(
                  fontFamily: 'Inter Tight',
                  letterSpacing: 0.0,
                  decoration: TextDecoration.underline,
                  fontSize: 20, // Set your desired font size here
                  fontWeight: FontWeight.w600, // Set your desired font weight here
                ),
              ),
            ),

            Divider(
              thickness: 18,
              color: Color(0xE60C0569),
            ),
            const SizedBox(height: 20),

            // Action Sections
            _buildActionSection(
              title: "Student Management",
              buttons: [
                _buildActionButton(
                  context, "Add Student", () => _navigate(context, AddStudentPage()),
                  width: 150, height: 40,
                ),
                _buildActionButton(
                  context, "Edit/Delete Student", () => _navigate(context, EditStudentPage()),
                  width: 250, height: 40,
                ),
              ],
            ),

            _buildActionSection(
              title: "Marks Management",
              buttons: [
                _buildActionButton(
                  context, "Upload Marks", () => _navigate(context, UploadMarksPage()),
                  width: 150, height: 40,
                ),
              ],
            ),

            _buildActionSection(
              title: "Schedule Management",
              buttons: [
                _buildActionButton(
                  context, "Upload Schedule", () => _navigate(context, UploadSchedulePage()),
                  width: 250, height: 40,
                ),
              ],
            ),

            _buildActionSection(
              title: "Notice Management",
              buttons: [
                _buildActionButton(
                  context, "Upload Notice", () => _navigate(context, UploadNoticePage()),
                  width: 150, height: 40,
                ),
                _buildActionButton(
                  context, "Upload Announcement", () => _navigate(context, UploadAnnouncementPage()),
                  width: 250, height: 40,
                ),
              ],
            ),

            _buildActionSection(
              title: "Attendance",
              buttons: [
                _buildActionButton(
                  context, "Mark Attendance", () => _navigate(context, MarkAttendancePage()),
                  width: 250, height: 40,
                ),
                _buildActionButton(
                  context, "View Attendance", () => _navigate(context, TeacherAttendancePage()),
                  width: 250, height: 40,
                ),
              ],
            ),

            _buildActionSection(
              title: "Student Details",
              buttons: [
                _buildActionButton(
                  context, "Display Students", () => _navigate(context, StudentsByClassPage()),
                  width: 250, height: 40,
                ),
              ],
            ),

            const SizedBox(height: 30),
          ],
        ),
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
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          ...buttons,
        ],
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, String text, VoidCallback onPressed, {double width = 280, double height = 50}) {
    return Container(
      width: width,
      height: height,
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF0C0569),
          padding: EdgeInsets.symmetric(vertical: height * 0.1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: Colors.white,
            fontSize: height * 0.4,
          ),
        ),
      ),
    );
  }

  void _navigate(BuildContext context, Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }
}
