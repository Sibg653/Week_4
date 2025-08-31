import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// Define a simple User model to parse the JSON data into a Dart object.
class User {
  final int id;
  final String name;
  final String email;
  final String username;
  final String website;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.username,
    required this.website,
  });

  // A factory constructor to create a User object from a JSON map.
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
      username: json['username'] as String,
      website: json['website'] as String,
    );
  }
}

// The main function where the app execution begins.
void main() {
  runApp(const MyApp());
}

// The root widget of the application.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'API Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'Inter',
      ),
      home: const UserProfileScreen(),
    );
  }
}

// The main screen that fetches and displays user profiles.
class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  // A list to hold the fetched User objects.
  late Future<List<User>> futureUsers;

  @override
  void initState() {
    super.initState();
    // Start fetching data when the widget is initialized.
    futureUsers = fetchUsers();
  }

  // Asynchronous function to fetch user data from the API.
  Future<List<User>> fetchUsers() async {
    final response = await http.get(Uri.parse('https://jsonplaceholder.typicode.com/users'));

    // Check if the request was successful (status code 200).
    if (response.statusCode == 200) {
      // Decode the JSON string into a list of maps.
      List<dynamic> data = json.decode(response.body);
      // Map the list of maps to a list of User objects.
      return data.map((json) => User.fromJson(json)).toList();
    } else {
      // If the server returns an error, throw an exception.
      throw Exception('Failed to load users. Status code: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Profiles'),
        centerTitle: true,
      ),
      body: Center(
        // Use a FutureBuilder to handle the different states of the asynchronous operation.
        child: FutureBuilder<List<User>>(
          future: futureUsers,
          builder: (context, snapshot) {
            // Check for connection state.
            if (snapshot.connectionState == ConnectionState.waiting) {
              // Show a loading indicator while data is being fetched.
              return const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
              );
            } else if (snapshot.hasError) {
              // Show an error message if the data fetching fails.
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 60),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${snapshot.error}',
                    style: const TextStyle(fontSize: 18, color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ],
              );
            } else if (snapshot.hasData) {
              // If data is successfully fetched, display it in a ListView.
              return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  User user = snapshot.data![index];
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16.0),
                      leading: CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.blue.shade100,
                        // Display a profile picture. Using a placeholder image for this example.
                        backgroundImage: NetworkImage('https://placehold.co/100x100/A0C4FF/000?text=${user.name[0].toUpperCase()}'),
                      ),
                      title: Text(
                        user.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text(
                            user.email,
                            style: TextStyle(color: Colors.grey.shade700),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            user.website,
                            style: TextStyle(color: Colors.blue.shade700, decoration: TextDecoration.underline),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            } else {
              // Fallback for no data.
              return const Text('No users found.');
            }
          },
        ),
      ),
    );
  }
}
