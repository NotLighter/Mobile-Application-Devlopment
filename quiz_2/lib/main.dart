import 'package:flutter/material.dart';

void main() {
  runApp(const ProfileApp());
}

class ProfileApp extends StatelessWidget {
  const ProfileApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ProfileApp',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      // Set the home to the main profile screen
      home: const ProfileScreen(),
    );
  }
}

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // 5. Controller and state for the separate username validation field
  final TextEditingController _usernameController = TextEditingController();
  String? _usernameErrorText;

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  // Method to validate the username field (shows error if empty)
  void _validateUsername(String? value) {
    setState(() {
      if (value == null || value.isEmpty) {
        _usernameErrorText = 'Username cannot be empty';
      } else {
        _usernameErrorText = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // 6. Determine the current screen orientation
    final Orientation orientation = MediaQuery.of(context).orientation;
    final String orientationText =
    orientation == Orientation.portrait ? 'Portrait' : 'Landscape';

    return Scaffold(
      // 1. Scaffold with an AppBar titled "Profile Screen"
      appBar: AppBar(
        title: const Text('Profile Screen'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      // 2. Wrap the content inside a SafeArea
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          // 3. Use a Column widget
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // 3. Profile picture (using Icon as allowed)
              const Center(
                child: Icon(
                  Icons.account_circle,
                  size: 100,
                  color: Colors.teal,
                ),
              ),
              const SizedBox(height: 16),

              // 3. RichText widget for name and email
              Center(
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: TextStyle(
                      fontSize: 18.0,
                      color: Theme.of(context).colorScheme.onSurface,
                      height: 1.5,
                    ),
                    children: <TextSpan>[
                      // User's name in bold
                      const TextSpan(
                        text: 'Alex Johnson\n',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 24.0,
                        ),
                      ),
                      // Email in a smaller font
                      TextSpan(
                        text: 'alex.johnson@example.com',
                        style: TextStyle(
                          fontSize: 16.0,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // 3. Row inside the column showing two buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  // ElevatedButton
                  ElevatedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Edit Profile Pressed')),
                      );
                    },
                    icon: const Icon(Icons.edit),
                    label: const Text('Edit Profile'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
                    ),
                  ),
                  // TextButton
                  TextButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Message Pressed')),
                      );
                    },
                    child: const Text(
                      'Message',
                      style: TextStyle(color: Colors.teal),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // 4. Container with background color and padding to display a short description
              Container(
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: Colors.teal.withOpacity(0.1), // Light background color
                  borderRadius: BorderRadius.circular(8.0),
                  border: Border.all(color: Colors.teal.shade200),
                ),
                child: const Text(
                  'A passionate mobile developer specializing in Flutter framework. Enthusiastic about creating beautiful and performant cross-platform applications.',
                  style: TextStyle(
                    fontSize: 16.0,
                    color: Colors.black87,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // 5. Textfield to edit username and show a validation message
              TextField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: 'Edit Username',
                  hintText: 'Enter new username',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.person_outline),
                  errorText: _usernameErrorText, // Show validation message
                ),
                onChanged: _validateUsername, // Validate on change
                onEditingComplete: () => _validateUsername(_usernameController.text),
              ),
              const SizedBox(height: 32),

              // 6. Display current screen orientation at the bottom
              Center(
                child: Text(
                  'Current Orientation: $orientationText',
                  style: const TextStyle(
                    fontSize: 16.0,
                    fontStyle: FontStyle.italic,
                    color: Colors.grey,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}