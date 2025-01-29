import 'package:flutter/material.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo;
import 'package:tog/WelcomePage.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  String? username;
  String? password;

  // MongoDB connection string and collection name
  final String mongoUrl =
      "mongodb://purkaitshubham5:sam@students-shard-00-00.x3rdy.mongodb.net:27017,students-shard-00-01.x3rdy.mongodb.net:27017,students-shard-00-02.x3rdy.mongodb.net:27017/Teacher?ssl=true&replicaSet=atlas-123-shard-0&authSource=admin";
  final String collectionName = "teacher";

  Future<Map<String, dynamic>?> _validateCredentials(
      String username, String password) async {
    try {
      final db = await mongo.Db.create(mongoUrl);
      await db.open();

      final collection = db.collection(collectionName);

      // Find the user with the provided username and password
      final user = await collection.findOne({
        "username": username,
        "password": password, // Note: Passwords should be hashed in production
      });

      await db.close();

      return user; // Return the user document if found
    } catch (e) {
      print("Error connecting to MongoDB: $e");
      return null;
    }
  }

  void _login() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final user = await _validateCredentials(username!, password!);

      if (user != null) {
        // Extract department from user document
        final department = user["department"] ?? "Unknown Department";

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => WelcomePage(
              teacherName: username!,
              department: department,
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Invalid credentials!")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Teacher Login"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: "Username"),
                validator: (value) =>
                    value!.isEmpty ? "Please enter your username" : null,
                onSaved: (value) => username = value,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: "Password"),
                obscureText: true,
                validator: (value) =>
                    value!.isEmpty ? "Please enter your password" : null,
                onSaved: (value) => password = value,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _login,
                child: const Text("Login"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
