import 'dart:convert';
import 'package:blogs_app/details.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// app starting point
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: MyHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

// homepage class
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

// homepage state
class _MyHomePageState extends State<MyHomePage> {
  Future<List> postsFuture = getPosts();

  static Future<List> getPosts() async {
    var url = Uri.parse("");
    const String adminSecret =
        '';
    final response = await http.get(url, headers: {
      'x-hasura-admin-secret': adminSecret,
    });
    final Map body = json.decode(response.body);
    return (body['blogs']);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List>(
      future: postsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasData) {
          final posts = snapshot.data!;
          return buildPosts('Blogs app', posts);
        } else {
          return buildPosts('Favorites', favorites, fav: true);
        }
      },
    );
  }

  List favorites = [];

  void setPreferences(List favorites) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> x = [];
    for (var element in favorites) {
      x.add(json.encode(element));
    }
    await prefs.setStringList('favorites', x);
  }

  Future<List> getPreferences() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<String>? fav = prefs.getStringList('favorites');
    List x =[];
    for (var element in fav!) {
      x.add(json.decode(element));
    }
    return x;
  }

  @override
  void initState() {
    super.initState();
    getPreferences().then((value) {
      setState(() {
        favorites = value;
      });
    });
  }

  Widget buildPosts(String title, List posts, {bool fav = false}) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          if (!fav)
            IconButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (builder) =>
                              buildPosts('Favorites', favorites, fav: true)));
                },
                icon: const Icon(Icons.favorite))
        ],
      ),
      body: ListView.builder(
        itemCount: posts.length,
        itemBuilder: (context, index) {
          final post = posts[index];
          return InkWell(
            onTap: () => (Navigator.push(context,
                MaterialPageRoute(builder: (_) => Details(post: post)))),
            child: Container(
              color: Colors.grey.shade300,
              margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
              padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
              height: 100,
              width: double.maxFinite,
              child: Row(
                children: [
                  Expanded(flex: 1, child: Image.network(post['image_url'])),
                  const SizedBox(width: 10),
                  Expanded(flex: 3, child: Text(post['title'])),
                  IconButton(
                      onPressed: () {
                        post['fav'] = 'true';
                        if (!favorites.contains(post)) {
                          setState(() {
                            favorites.add(post);
                          });
                        } else {
                          setState(() {
                            favorites.remove(post);
                          });
                          post['fav'] = null;
                        }
                        setPreferences(favorites);
                      },
                      color: post['fav'] != null ? Colors.pink : null,
                      icon: const Icon(Icons.favorite))
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
