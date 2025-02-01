import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo;
import 'package:intl/intl.dart'; // For date formatting

class UploadNoticePage extends StatefulWidget {
  const UploadNoticePage({super.key});

  @override
  _UploadNoticePageState createState() => _UploadNoticePageState();
}

class _UploadNoticePageState extends State<UploadNoticePage> {
  final _titleController = TextEditingController(); // Controller for title
  final _descriptionController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  DateTime? selectedDateTime;
  File? selectedImage;
  String? base64Image;

  bool isLoading = false;

  // MongoDB connection details
  final String mongoUrl =
      "mongodb://purkaitshubham5:sam@students-shard-00-00.x3rdy.mongodb.net:27017,students-shard-00-01.x3rdy.mongodb.net:27017,students-shard-00-02.x3rdy.mongodb.net:27017/mdbuser_test_db?ssl=true&replicaSet=atlas-123-shard-0&authSource=admin";
  final String collectionName = "notices";

  Future<void> uploadNotice() async {
    if (!_formKey.currentState!.validate() || selectedDateTime == null || base64Image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields and upload an image!")),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final db = await mongo.Db.create(mongoUrl);
      await db.open();

      final collection = db.collection(collectionName);

      // Prepare notice data with ObjectId
      final noticeData = {
        '_id': mongo.ObjectId(),
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'date': selectedDateTime!.toIso8601String(),
        'image': base64Image!,
      };

      // Insert notice into the notices collection
      await collection.insert(noticeData);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Notice uploaded successfully!")),
      );

      // Clear fields after upload
      _titleController.clear();
      _descriptionController.clear();
      setState(() {
        selectedDateTime = null;
        selectedImage = null;
        base64Image = null;
      });

      await db.close(); // Close the database connection
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error uploading notice: $e")),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> selectImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final imageFile = File(pickedFile.path);
      final bytes = await imageFile.readAsBytes(); // Asynchronous file read
      setState(() {
        selectedImage = imageFile;
        base64Image = base64Encode(bytes);
      });
    }
  }

  Future<void> selectDateTime() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
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

  String formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return "No date & time selected";
    return DateFormat('yyyy-MM-dd hh:mm a').format(dateTime);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title Field
                const Text(
                  "Title",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 5),
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    hintText: "Enter notice title",
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter a title";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Date & Time Picker
                const Text(
                  "Date & Time",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    Text(formatDateTime(selectedDateTime)),
                    const Spacer(),
                    ElevatedButton(
                      onPressed: selectDateTime,
                      child:const Icon(Icons.calendar_today,color: Colors.white,),
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
                const SizedBox(height: 20),

                // Description Field
                const Text(
                  "Description",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 5),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    hintText: "Enter notice description",
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 4,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter a description";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Image Picker
                const Text(
                  "Image",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    if (selectedImage != null)
                      Image.file(
                        selectedImage!,
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                      )
                    else
                      const Text("No image selected"),
                    const Spacer(),
                    ElevatedButton(
                      onPressed: selectImage,
                      child: const Text("Upload Image",style: TextStyle(fontSize: 14, color: Colors.white),),
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
                const SizedBox(height: 20),

                // Loading Indicator
                if (isLoading)
                  const Center(child: CircularProgressIndicator()),

                // Upload Notice Button
                if (!isLoading)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: uploadNotice,
                      child: const Text("Upload Notice",style: TextStyle(fontSize: 14, color: Colors.white),),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF231D77),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                        padding:
                        EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
