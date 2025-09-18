import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

// Root widget
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bidding Page',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Bidding'),
          backgroundColor: Colors.deepPurple,
        ),
        body: const Center(
          child: MaximumBid(startingBid: 250), // You can set initial bid here
        ),
      ),
    );
  }
}

// MaximumBid widget
class MaximumBid extends StatefulWidget {
  final int startingBid;

  const MaximumBid({super.key, required this.startingBid});

  @override
  State<MaximumBid> createState() => _MaximumBidState();
}

// State class
class _MaximumBidState extends State<MaximumBid> {
  late int _currentBid;

  @override
  void initState() {
    super.initState();
    _currentBid = widget.startingBid; // Initialize from constructor
  }

  void _increaseBid() {
    setState(() {
      _currentBid += 50;
    });
  }

  Widget _buildTitle() {
    return const Text(
      'Your Current Maximum Bid:',
      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildBidDisplay() {
    return Text(
      '\$$_currentBid',
      style: const TextStyle(fontSize: 36, color: Colors.deepPurple),
    );
  }

  Widget _buildIncreaseButton() {
    return ElevatedButton(
      onPressed: _increaseBid,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.deepPurple,
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
      ),
      child: const Text(
        'Increase Bid (+\$50)',
        style: TextStyle(
          fontSize: 18,
          color: Colors.white, // Set color to white
        ),
      )
      ,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildTitle(),
        const SizedBox(height: 10),
        _buildBidDisplay(),
        const SizedBox(height: 20),
        _buildIncreaseButton(),
      ],
    );
  }
}
