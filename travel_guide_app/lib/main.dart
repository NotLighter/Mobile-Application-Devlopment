import 'package:flutter/material.dart';

void main() {
  runApp(TravelGuideApp());
}

class TravelGuideApp extends StatefulWidget {
  @override
  State<TravelGuideApp> createState() => _TravelGuideAppState();
}

class _TravelGuideAppState extends State<TravelGuideApp> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    HomeScreen(),
    ListScreen(),
    AboutScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Travel Guide App',
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Travel Guide',style:TextStyle(color: Colors.white) ,),
          backgroundColor: Colors.black,
        ),
        body: SafeArea(
          child: _screens[_selectedIndex],
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          selectedItemColor: Colors.teal,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.list),
              label: 'Destinations',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.info_outline),
              label: 'About',
            ),
          ],
        ),
      ),
    );
  }
}

//
// 🏠 HOME SCREEN
//
class HomeScreen extends StatelessWidget {
  final TextEditingController destinationController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Travel image
          Image.network(
            'https://images.pexels.com/photos/731217/pexels-photo-731217.jpeg?_gl=1*vbm0eq*_ga*MTkxODIwNjI3NC4xNzYwNTg1NTAz*_ga_8JE65Q40S6*czE3NjA1ODU1MDMkbzEkZzEkdDE3NjA1ODU1MjMkajQwJGwwJGgw',
            height: 220,
            width: double.infinity,
            fit: BoxFit.cover,
          ),

          // Welcome message
          Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.teal.shade50,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Text(
              'Welcome to the Travel Guide App! Discover amazing destinations, plan your adventures, and explore the beauty of our world.',

              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16 , color: Colors.black),
            ),
          ),

          // Slogan using RichText
          RichText(
            text: const TextSpan(
              children: [
                TextSpan(
                  text: 'Explore ',
                  style: TextStyle(color: Colors.black, fontSize: 20),
                ),
                TextSpan(
                  text: 'the World ',
                  style: TextStyle(
                      color: Colors.teal,
                      fontWeight: FontWeight.bold,
                      fontSize: 22),
                ),
                TextSpan(
                  text: 'with Us!',
                  style: TextStyle(color: Colors.orange, fontSize: 20),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Destination input
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: destinationController,
              decoration: const InputDecoration(
                labelText: 'Enter Destination Name',
                border: OutlineInputBorder(),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () {
                  final destination = destinationController.text;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(destination.isEmpty
                          ? 'Please enter a destination!'
                          : 'Searching for $destination...'),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                child: const Text('Search', style:TextStyle(color: Colors.white),),
              ),
              TextButton(
                onPressed: () {
                  print('Travel Tips button pressed!');
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Travel tips coming soon!')),
                  );
                },
                child: const Text(
                  'Travel Tips',
                  style: TextStyle(color: Colors.teal),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

//
// 📜 LIST SCREEN
//
class ListScreen extends StatelessWidget {
  final List<Map<String, String>> destinations = [
    {'name': 'Paris', 'desc': 'City of Light and Love'},
    {'name': 'Tokyo', 'desc': 'Blend of tradition and technology'},
    {'name': 'New York', 'desc': 'The city that never sleeps'},
    {'name': 'Dubai', 'desc': 'Luxury and innovation in the desert'},
    {'name': 'Sydney', 'desc': 'Famous for its Opera House'},
    {'name': 'Istanbul', 'desc': 'Where East meets West'},
    {'name': 'Rome', 'desc': 'Ancient city with timeless beauty'},
    {'name': 'Bali', 'desc': 'Island of peace and natural beauty'},
    {'name': 'Cairo', 'desc': 'Home of the Great Pyramids'},
    {'name': 'London', 'desc': 'Historic and modern blend perfectly'},
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: destinations.length,
      itemBuilder: (context, index) {
        final dest = destinations[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: ListTile(
            leading: const Icon(Icons.location_on, color: Colors.redAccent),
            title: Text(dest['name']!),
            subtitle: Text(dest['desc']!),
          ),
        );
      },
    );
  }
}

//
// ℹ️ ABOUT SCREEN
//
class AboutScreen extends StatelessWidget {
  final List<Map<String, String>> attractions = [
    {
      'image':
      'https://images.pexels.com/photos/1530259/pexels-photo-1530259.jpeg?_gl=1*1gdmzm4*_ga*MTkxODIwNjI3NC4xNzYwNTg1NTAz*_ga_8JE65Q40S6*czE3NjA1ODU1MDMkbzEkZzEkdDE3NjA1ODU3MzgkajMyJGwwJGgw',
      'name': 'Eiffel Tower'
    },
    {
      'image':
      'https://images.pexels.com/photos/1603650/pexels-photo-1603650.jpeg?_gl=1*f21u98*_ga*MTkxODIwNjI3NC4xNzYwNTg1NTAz*_ga_8JE65Q40S6*czE3NjA1ODU1MDMkbzEkZzEkdDE3NjA1ODU4NDEkajM5JGwwJGgw',
      'name': 'Taj Mahal'
    },
    {
      'image':
      'https://images.pexels.com/photos/10952316/pexels-photo-10952316.jpeg?_gl=1*88m7v*_ga*MTkxODIwNjI3NC4xNzYwNTg1NTAz*_ga_8JE65Q40S6*czE3NjA1ODU1MDMkbzEkZzEkdDE3NjA1ODU5NDgkajgkbDAkaDA.',
      'name': 'Great Wall of China'
    },
    {
      'image':
      'https://images.pexels.com/photos/2225439/pexels-photo-2225439.jpeg?_gl=1*n9ta84*_ga*MTkxODIwNjI3NC4xNzYwNTg1NTAz*_ga_8JE65Q40S6*czE3NjA1ODU1MDMkbzEkZzEkdDE3NjA1ODYwMTIkajUwJGwwJGgw',
      'name': 'Colosseum'
    },
    {
      'image':
      'https://images.pexels.com/photos/3463964/pexels-photo-3463964.jpeg?_gl=1*1d2ju4r*_ga*MTkxODIwNjI3NC4xNzYwNTg1NTAz*_ga_8JE65Q40S6*czE3NjA1ODU1MDMkbzEkZzEkdDE3NjA1ODYwNzMkajUwJGwwJGgw',
      'name': 'Machu Picchu'
    },
    {
      'image':
      'https://images.pexels.com/photos/64271/queen-of-liberty-statue-of-liberty-new-york-liberty-statue-64271.jpeg?_gl=1*168kh0c*_ga*MTkxODIwNjI3NC4xNzYwNTg1NTAz*_ga_8JE65Q40S6*czE3NjA1ODU1MDMkbzEkZzEkdDE3NjA1ODYxNDIkajQxJGwwJGgw',
      'name': 'Statue of Liberty'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(10),
      itemCount: attractions.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 10,
        childAspectRatio: 0.8,
      ),
      itemBuilder: (context, index) {
        final item = attractions[index];
        return Column(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  item['image']!,
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
              ),
            ),
            const SizedBox(height: 5),
            Text(
              item['name']!,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        );
      },
    );
  }
}

