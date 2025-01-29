import 'package:flutter/material.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo;

class EditStudentPage extends StatefulWidget {
  const EditStudentPage({super.key});

  @override
  _EditStudentPageState createState() => _EditStudentPageState();
}

class _EditStudentPageState extends State<EditStudentPage> {
  final _prnController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool isLoading = false;
  bool studentFound = false;

  Map<String, dynamic>? studentDetails;

  // MongoDB connection details
  final String mongoUrl =
      "mongodb://purkaitshubham5:sam@students-shard-00-00.x3rdy.mongodb.net:27017,students-shard-00-01.x3rdy.mongodb.net:27017,students-shard-00-02.x3rdy.mongodb.net:27017/mdbuser_test_db?ssl=true&replicaSet=atlas-123-shard-0&authSource=admin";
  final String collectionName = "students";

  Future<void> fetchStudentByPRN(String prn) async {
    setState(() {
      isLoading = true;
      studentFound = false;
      studentDetails = null;
    });

    try {
      final db = await mongo.Db.create(mongoUrl);
      await db.open();

      final collection = db.collection(collectionName);

      final result = await collection.findOne(mongo.where.eq('user_id', prn));

      setState(() {
        isLoading = false;
        if (result != null) {
          studentDetails = result;
          studentFound = true;
        } else {
          studentFound = false;
        }
      });

      await db.close();
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error fetching student: $e")),
      );
    }
  }

  Future<void> updateStudentDetails() async {
    if (!_formKey.currentState!.validate()) return;

    _formKey.currentState!.save();

    setState(() {
      isLoading = true;
    });

    try {
      final db = await mongo.Db.create(mongoUrl);
      await db.open();

      final collection = db.collection(collectionName);

      await collection.update(
        mongo.where.eq('user_id', studentDetails!['user_id']),
        studentDetails!,
      );

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Student details updated successfully!")),
      );

      await db.close();
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error updating student: $e")),
      );
    }
  }

  Future<void> deleteStudent() async {
    setState(() {
      isLoading = true;
    });

    try {
      final db = await mongo.Db.create(mongoUrl);
      await db.open();

      final collection = db.collection(collectionName);

      final result = await collection.findOne(mongo.where.eq('user_id', _prnController.text));

      if (result != null) {
        await collection.remove(mongo.where.eq('user_id', _prnController.text));
        setState(() {
          isLoading = false;
          studentDetails = null;
          studentFound = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Student deleted successfully!")),
        );
      } else {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("No student found with this PRN.")),
        );
      }

      await db.close();
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error deleting student: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit/Delete Student"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search by PRN
            TextFormField(
              controller: _prnController,
              decoration: const InputDecoration(
                labelText: "Enter PRN",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => fetchStudentByPRN(_prnController.text),
              child: const Text("Search Student"),
            ),
            const SizedBox(height: 20),

            // Loading indicator
            if (isLoading)
              const Center(child: CircularProgressIndicator()),

            // No student found
            if (!isLoading && !studentFound && _prnController.text.isNotEmpty)
              const Center(
                child: Text(
                  "No student found with the provided PRN.",
                  style: TextStyle(color: Colors.red),
                ),
              ),



            // Display and edit student details
            if (studentFound && studentDetails != null)
              Expanded(
                child: Form(
                  key: _formKey,
                  child: ListView(
                    children: [
                      TextFormField(//fullname
                        initialValue: studentDetails!['full_name'],
                        decoration: const InputDecoration(labelText: "Full Name"),
                        onSaved: (value) =>
                        studentDetails!['full_name'] = value,
                      ),
                      TextFormField(//rollno
                        initialValue: studentDetails!['roll_no'],
                        decoration: const InputDecoration(labelText: "Roll No"),
                        onSaved: (value) => studentDetails!['roll_no'] = value,
                      ),
                      TextFormField(//classname
                        initialValue: studentDetails!['class_name'],
                        decoration:
                        const InputDecoration(labelText: "Class Name"),
                        onSaved: (value) =>
                        studentDetails!['class_name'] = value,
                      ),
                      TextFormField(//department
                        initialValue: studentDetails!['department'],
                        decoration:
                        const InputDecoration(labelText: "Department"),
                        onSaved: (value) =>
                        studentDetails!['department'] = value,
                      ),
                      // Add email and ebook link fields
                      TextFormField(//email
                        initialValue: studentDetails!['email'],
                        decoration: const InputDecoration(labelText: "Email"),
                        onSaved: (value) => studentDetails!['email'] = value,
                      ),
                      TextFormField(//ebookslonk
                        initialValue: studentDetails!['ebooks_link'],
                        decoration: const InputDecoration(labelText: "E-books Link"),
                        onSaved: (value) => studentDetails!['ebooks_link'] = value,
                      ),
                      TextFormField(//password
                        initialValue: studentDetails!['password'],
                        decoration: const InputDecoration(labelText: "Students pasword"),
                        onSaved: (value) => studentDetails!['password'] = value,
                      ),
                      const SizedBox(height: 20),

                      ElevatedButton(
                        onPressed: updateStudentDetails,
                        child: const Text("Update Student Details"),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: deleteStudent,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                        child: const Text("Delete Student"),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
