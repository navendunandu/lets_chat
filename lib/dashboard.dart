import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:lets_chat/notes.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  int _selectedIndex = 0;

  String _name = 'LOading...';
  String? _imageUrl = 'https://via.placeholder.com/150';

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    String userId = user!.uid;
    final userRef =
        FirebaseDatabase.instance.ref().child('users').child(userId);
    try {
      final nameEvent = await userRef.child('name').once();
      final nameSnapshot = nameEvent.snapshot;
      final imageUrlEvent = await userRef.child('imageUrl').once();
      final imageUrlSnapshot = imageUrlEvent.snapshot;

      setState(() {
        _name = nameSnapshot.value.toString(); // Convert value to string
        _imageUrl =
            imageUrlSnapshot.value.toString(); // Convert value to string
      });
      print('Name: $_name');
      print('Image: $_imageUrl');
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lets Chat'),
      ),
      drawer: Container(
        width: 200,
        color: Colors.blue,
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: _imageUrl != null
                  ? CircleAvatar(
                      radius: 50,
                      backgroundImage: NetworkImage(_imageUrl!),
                    )
                  : const SizedBox(),
            ),
            _name != null
                ? Text(
                    _name,
                    style: const TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                    ),
                  )
                : const SizedBox(),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.home, color: Colors.white),
              title: const Text('Home', style: TextStyle(color: Colors.white)),
              onTap: () => _onItemTapped(0),
            ),
            ListTile(
              leading: const Icon(Icons.settings, color: Colors.white),
              title: const Text('Notes', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const TodoListApp(),));
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.white),
              title: const Text('Logout', style: TextStyle(color: Colors.white)),
              onTap: () => _onItemTapped(2),
            ),
          ],
        ),
      ),
      body: Row(
        children: <Widget>[
          Expanded(
            child: Center(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const Text(
                      'Welcome to Lets Chat!',
                      style: TextStyle(fontSize: 24),
                    ),
                    const SizedBox(height: 20),
                    if (_selectedIndex == 0)
                      const Text('Home Content')
                    else if (_selectedIndex == 1)
                      const Text('Settings Content')
                    else
                      const Text('Logout Content'),
                    const SizedBox(height: 20),
                    GridView.count(
                      shrinkWrap: true,
                      crossAxisCount: 2,
                      children: List.generate(4, (index) {
                        return Card(
                          child: Column(
                            children: <Widget>[
                              AspectRatio(
                                aspectRatio: 18.0 / 11.0,
                                child: Container(
                                  decoration: const BoxDecoration(
                                    image: DecorationImage(
                                      image: NetworkImage(
                                          'https://via.placeholder.com/150'),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text('Card Title $index'),
                              ),
                            ],
                          ),
                        );
                      }),
                    ),
                  ]),
            ),
          ),
        ],
      ),
    );
  }
}
