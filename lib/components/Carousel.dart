import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../screen/Detail.dart';

class CarouselComponent extends StatefulWidget {
  final String apiUrl;

  CarouselComponent({required this.apiUrl});

  @override
  _CarouselComponentState createState() => _CarouselComponentState();
}

class _CarouselComponentState extends State<CarouselComponent> {
  late Future<List<dynamic>> _comicsFuture;

  @override
  void initState() {
    super.initState();
    _comicsFuture = fetchComics();
  }

  Future<List<dynamic>> fetchComics() async {
    final response = await http.get(
      Uri.parse(widget.apiUrl),
      headers: {
        'Content-Type': 'application/json',
      }).timeout(Duration(seconds: 10));

    if (response.statusCode == 200) {
      Map<String, dynamic> data = json.decode(response.body);
      return data['popular'];
    } else {
      throw Exception('Failed to load comics');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: _comicsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: Padding(
              padding: EdgeInsets.only(top: 15.0),
              child: CircularProgressIndicator(),
            ),
          );
        } else if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Gagal mendapatkan data!'),
                SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _comicsFuture = fetchComics();
                    });
                  },
                  child: Text('Coba Lagi'),
                ),
              ],
            ),
          );
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No comics available'));
        } else {
          final comics = snapshot.data!;
          return CarouselSlider.builder(
            itemCount: comics.length,
            itemBuilder: (context, index, realIndex) {
              final comic = comics[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Detail(slug: comic['slug']),
                    ),
                  );
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15.0),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8.0),
                        child: Image.network(
                          comic['image'],
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        bottom: 20,
                        left: 20,
                        right: 20,
                        child: Container(
                          color: Colors.black.withOpacity(0.6),
                          padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                          child: Text(
                            comic['title'],
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
            options: CarouselOptions(
              height: 200,
              autoPlay: true,
              autoPlayInterval: Duration(seconds: 3),
              viewportFraction: 0.8,
              enableInfiniteScroll: true,
            ),
          );
        }
      },
    );
  }
}
