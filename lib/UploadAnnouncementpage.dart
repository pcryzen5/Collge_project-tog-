import 'package:flutter/material.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo;

class UploadAnnouncementPage extends StatefulWidget {
  const UploadAnnouncementPage({super.key});

  @override
  _UploadAnnouncementPageState createState() => _UploadAnnouncementPageState();
}

class _UploadAnnouncementPageState extends State<UploadAnnouncementPage> {
  final String dbUrl =
      "mongodb://purkaitshubham5:sam@students-shard-00-00.x3rdy.mongodb.net:27017,students-shard-00-01.x3rdy.mongodb.net:27017,students-shard-00-02.x3rdy.mongodb.net:27017/mdbuser_test_db?ssl=true&replicaSet=atlas-123-shard-0&authSource=admin";
  mongo.Db? db;
  mongo.DbCollection? announcementCollection;

  final _formKey = GlobalKey<FormState>();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  String? selectedClass;

  List<String> classes = [
    "SyBscIt_A",
    "SyBscIt_B",
    "FyBscIt_A",
    "FyBscIt_B"
  ]; // Example class list

  Future<void> uploadAnnouncement() async {
    if (!_formKey.currentState!.validate() || selectedClass == null) return;

    try {
      db = await mongo.Db.create(dbUrl);
      await db!.open();
      announcementCollection = db!.collection('announcements');

      await announcementCollection!.insert({
        'title': titleController.text,
        'description': descriptionController.text,
        'class': selectedClass,
        'createdAt': DateTime.now().toIso8601String(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Announcement uploaded successfully!')),
      );

      titleController.clear();
      descriptionController.clear();
      setState(() {
        selectedClass = null;
      });
    } catch (e) {
      debugPrint("Error uploading announcement: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to upload announcement!')),
      );
    } finally {
      db?.close();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Upload Announcement")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: titleController,
                decoration: const InputDecoration(labelText: "Title"),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter a title.";
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: "Description"),
                maxLines: 4,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter a description.";
                  }
                  return null;
                },
              ),
              DropdownButtonFormField<String>(
                value: selectedClass,
                hint: const Text("Select Class"),
                items: classes.map((className) {
                  return DropdownMenuItem(
                    value: className,
                    child: Text(className),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedClass = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return "Please select a class.";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: uploadAnnouncement,
                child: const Text("Upload Announcement"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
