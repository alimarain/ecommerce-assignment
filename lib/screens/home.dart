import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:math';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  List<dynamic> posts = [];

  @override
  void initState() {
    super.initState();
    getPosts();
  }

  String generateUniqueId() {
    final currentTime = DateTime.now().microsecondsSinceEpoch;
    final random = Random().nextInt(999999);
    return '$currentTime$random';
  }

  Future<void> savePost() async {
    String uniqueId = generateUniqueId();
    DatabaseReference ref = FirebaseDatabase.instance.ref("posts/$uniqueId");

    await ref.set({
      "title": "Post heading",
      "subtitle": "Post subtitle",
      "img":
          "https://t3.ftcdn.net/jpg/00/74/80/30/360_F_74803077_tAM730fGIeVYoFTDLTgt8AIMXZCqh1rQ.jpg",
      "isFav": false,
      "id": uniqueId
    });
  }

  Future<void> addToFav(String id) async {
    DatabaseReference ref = FirebaseDatabase.instance.ref("posts/$id");

    await ref.update({
      "isFav": true,
    });
  }

  Future<void> getPosts() async {
    final ref = FirebaseDatabase.instance.ref();
    final snapshot = await ref.child('posts').get();
    if (snapshot.exists) {
      Object? json = snapshot.value;

      if (json is Map<dynamic, dynamic>) {
        List<dynamic> values = json.values.toList();

        setState(() {
          posts = values;
        });
      }
    } else {
      print('No data available.');
    }
  }

  void _onTabTapped(int index) async {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Mega Mail"),
        actions: [
          IconButton(onPressed: () {}, icon: Icon(Icons.notifications)),
          IconButton(onPressed: () {}, icon: Icon(Icons.shopping_cart))
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(28.0),
        child: Column(
          children: [
            const TextField(
              decoration: InputDecoration(
                hintText: 'Search',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Expanded(
              child: ListView.builder(
                itemCount: posts.length,
                itemBuilder: (context, index) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(20.0),
                    child: Card(
                      elevation: 2.0,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    posts[index]['title'],
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    posts[index]['subtitle'],
                                    style: TextStyle(fontSize: 14),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Container(
                            width: 180,
                            child: Image.network(
                              posts[index]['img'],
                              fit: BoxFit.cover,
                              height: 100,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(
              Icons.home,
              color: Colors.black,
            ),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.search,
              color: Colors.black,
            ),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.favorite,
              color: Colors.black,
            ),
            label: 'Favorites',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.person,
              color: Colors.black,
            ),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
