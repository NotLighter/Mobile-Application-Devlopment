import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const PlatformChannelApp());
}

class PlatformChannelApp extends StatelessWidget {
  const PlatformChannelApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Platform Channel Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const PlatformChannelHomePage(),
    );
  }
}

class PlatformChannelHomePage extends StatefulWidget {
  const PlatformChannelHomePage({super.key});

  @override
  State<PlatformChannelHomePage> createState() => _PlatformChannelHomePageState();
}

class _PlatformChannelHomePageState extends State<PlatformChannelHomePage> {
  // Create a MethodChannel with unique name
  static const _methodChannel = MethodChannel('platformchannel.companyname.com/device info');

  // Variable to store device information
  String _deviceInfo = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _getDeviceInfo();
  }

  // Async method to get device info from native platform
  Future<void> _getDeviceInfo() async {
    String deviceInfo;
    setState(() {
      _isLoading = true;
    });

    try {
      // Invoke method on native platform
      deviceInfo = await _methodChannel.invokeMethod('getDeviceInfo');
    } on PlatformException catch (e) {
      deviceInfo = "Failed to get device info: '${e.message}'.";
    } catch (e) {
      deviceInfo = "An error occurred: ${e.toString()}";
    }

    setState(() {
      _deviceInfo = deviceInfo;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.blue.shade50,
                Colors.blue.shade100,
              ],
            ),
          ),
          child: Column(
            children: [
              // App Bar
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.blue.shade700,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.phone_android,
                      color: Colors.white,
                      size: 32,
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Platform Channel',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Info Card
                      Card(
                        elevation: 8,
                        shadowColor: Colors.blue.shade200,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.shade100,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      Icons.info_outline,
                                      color: Colors.blue.shade700,
                                      size: 28,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  const Expanded(
                                    child: Text(
                                      'Device Info:',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),
                              const Divider(),
                              const SizedBox(height: 16),
                              _isLoading
                                  ? Center(
                                child: Column(
                                  children: const [
                                    CircularProgressIndicator(),
                                    SizedBox(height: 16),
                                    Text(
                                      'Loading device information...',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                                  : _deviceInfo.isEmpty
                                  ? const Center(
                                child: Text(
                                  'No device information available',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey,
                                  ),
                                ),
                              )
                                  : Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade50,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.grey.shade300,
                                  ),
                                ),
                                child: Text(
                                  _deviceInfo,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    height: 1.6,
                                    fontFamily: 'monospace',
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Refresh Button
                      ElevatedButton.icon(
                        onPressed: _isLoading ? null : _getDeviceInfo,
                        icon: const Icon(Icons.refresh, size: 24),
                        label: const Text(
                          'Refresh Device Info',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 4,
                        ),
                      ),

                      const SizedBox(height: 32),

                      // How it Works Section
                      Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.lightbulb_outline,
                                    color: Colors.amber.shade700,
                                    size: 24,
                                  ),
                                  const SizedBox(width: 12),
                                  const Text(
                                    'How It Works',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              const Divider(),
                              const SizedBox(height: 12),
                              _buildInfoRow(
                                Icons.code,
                                'Platform Channel',
                                'Uses MethodChannel to communicate between Flutter and native code',
                              ),
                              const SizedBox(height: 12),
                              _buildInfoRow(
                                Icons.apple,
                                'iOS (Swift)',
                                'Uses UIDevice API to retrieve device information',
                              ),
                              const SizedBox(height: 12),
                              _buildInfoRow(
                                Icons.android,
                                'Android (Kotlin)',
                                'Uses Build API to retrieve device information',
                              ),
                              const SizedBox(height: 12),
                              _buildInfoRow(
                                Icons.sync,
                                'Async Communication',
                                'Method calls are asynchronous and return Future',
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String title, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 20,
          color: Colors.blue.shade600,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade700,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}