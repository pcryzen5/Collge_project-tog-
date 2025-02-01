import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo;
import 'package:google_fonts/google_fonts.dart';

class AddStudentPage extends StatefulWidget {
  const AddStudentPage({super.key});

  @override
  _AddStudentPageState createState() => _AddStudentPageState();
}

class _AddStudentPageState extends State<AddStudentPage> {
  final _formKey = GlobalKey<FormState>();
  final mogourl =
      "mongodb://purkaitshubham5:sam@students-shard-00-00.x3rdy.mongodb.net:27017,students-shard-00-01.x3rdy.mongodb.net:27017,students-shard-00-02.x3rdy.mongodb.net:27017/mdbuser_test_db?ssl=true&replicaSet=atlas-123-shard-0&authSource=admin";
  String? username,
      password,
      fullName,
      rollNo,
      userId,
      className,
      collegeId,
      department,
      email,
      ebooksLink;
  File? idCardImage;

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        idCardImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _addStudentToDatabase() async {
    if (!_formKey.currentState!.validate()) return;

    _formKey.currentState!.save();

    // Check if user_id already exists in the database
    final existingStudent = await _checkUserIdDuplicate(userId!);
    if (existingStudent != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Duplicate user_id! This ID already exists.")),
      );
      return; // Prevent the insert if duplicate is found
    }

    try {
      final db = await mongo.Db.create(
        mogourl,
      );
      await db.open();
      final collection = db.collection('students');

      final studentData = {
        '_id': mongo.ObjectId(),
        'username': username,
        'password': password,
        'full_name': fullName,
        'roll_no': rollNo,
        'user_id': userId,
        'class_name': className,
        'college_id': collegeId,
        'department': department,
        'email': email,
        'ebooks_link': ebooksLink,
        'id_card_print': idCardImage != null
            ? base64Encode(await idCardImage!.readAsBytes())
            : null,
      };

      await collection.insertOne(studentData);
      await db.close();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Student added successfully!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<Map<String, dynamic>?> _checkUserIdDuplicate(String userId) async {
    try {
      final db = await mongo.Db.create(
        mogourl,
      );
      await db.open();
      final collection = db.collection('students');

      // Check if a student with the same user_id already exists
      final existingStudent =
          await collection.findOne(mongo.where.eq('user_id', userId));

      await db.close();

      return existingStudent;
    } catch (e) {
      print("Error checking user_id duplication: $e");
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Color(0xE60C0569),
        automaticallyImplyLeading: true, // Enables the back button
        iconTheme: IconThemeData(
          color: Colors.white, // Changes the back button color to blue
        ),
        title: Text(
          'Add Student',
          style: GoogleFonts.inter( // Using Google Fonts
            textStyle: TextStyle(
              color: Colors.white,
              fontSize: 22,
              letterSpacing: 0.0,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: "Username"),
                validator: (value) => value!.isEmpty ? "Enter username" : null,
                onSaved: (value) => username = value,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: "Password"),
                validator: (value) => value!.isEmpty ? "Enter password" : null,
                onSaved: (value) => password = value,
                obscureText: true,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: "Full Name"),
                validator: (value) => value!.isEmpty ? "Enter full name" : null,
                onSaved: (value) => fullName = value,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: "Roll No"),
                validator: (value) =>
                    value!.isEmpty ? "Enter roll number" : null,
                onSaved: (value) => rollNo = value,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: "PRN (User ID)"),
                validator: (value) => value!.isEmpty ? "Enter PRN" : null,
                onSaved: (value) => userId = value,
              ),
              TextFormField(
                decoration: const InputDecoration(
                    labelText: "Class Name(for eg. FyBscit_A)"),
                validator: (value) => value!.isEmpty
                    ? "Enter class name(for eg. FyBscit_A)"
                    : null,
                onSaved: (value) => className = value,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: "College ID"),
                validator: (value) =>
                    value!.isEmpty ? "Enter college ID" : null,
                onSaved: (value) => collegeId = value,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: "Department"),
                validator: (value) =>
                    value!.isEmpty ? "Enter department" : null,
                onSaved: (value) => department = value,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: "Email"),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Enter email";
                  }
                  final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                  return emailRegex.hasMatch(value)
                      ? null
                      : "Enter a valid email";
                },
                onSaved: (value) => email = value,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: "E-books Link"),
                validator: (value) =>
                    value!.isEmpty ? "Enter e-books link" : null,
                onSaved: (value) => ebooksLink = value,
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _pickImage,
                child: const Text("Pick ID Card Image",
                    style: TextStyle(fontSize: 16, color: Colors.white),
              ),
                style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xFF231D77),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50),
        ),
        padding:
        EdgeInsets.symmetric(horizontal: 50, vertical: 10),
      ),
              ),
              if (idCardImage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Image.file(idCardImage!, width: 100, height: 100),
                ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _addStudentToDatabase,
                child: const Text("Submit",style: TextStyle(fontSize: 16, color: Colors.white),),
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
