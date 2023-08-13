import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

void main() {
  runApp(RandomQuotesApp());
}

class Quote {
  final int id;
  final String text;
  final String author;
  final String category;

  Quote(
      {required this.id,
      required this.text,
      required this.author,
      required this.category});

  Map<String, dynamic> toMap() {
    return {'id': id, 'text': text, 'author': author, 'category': category};
  }
}

class RandomQuotesApp extends StatefulWidget {
  @override
  _RandomQuotesAppState createState() => _RandomQuotesAppState();
}

class _RandomQuotesAppState extends State<RandomQuotesApp> {
  List<Quote> quotes = [];

  @override
  void initState() {
    super.initState();
    fetchQuotes();
  }

  Future<void> fetchQuotes() async {
    final response = await http.get(
      Uri.parse(
          'https://famous-quotes4.p.rapidapi.com/random?category=all&count=1000'),
      headers: {
        'X-RapidAPI-Key': '584670a96amsh3aacfd1bdc09c36p124693jsn795fc8d11be7',
        'X-RapidAPI-Host': 'famous-quotes4.p.rapidapi.com'
      },
    );
    if (response.statusCode == 200) {
      final List<dynamic> responseData = json.decode(response.body);
      setState(() {
        quotes = responseData
            .map((quote) => Quote(
                id: quote['id'],
                text: quote['text'],
                author: quote['author'],
                category: quote['category']))
            .toList();
        _saveQuotesToDatabase(quotes);
        print(quotes);
      });
    }
  }

  Future<void> _saveQuotesToDatabase(List<Quote> quotes) async {
    final dbPath = await getDatabasesPath();
    final databasePath = join(dbPath, 'quotes.db');
    final database = await openDatabase(databasePath, version: 1,
        onCreate: (Database db, int version) async {
      await db.execute('''
          CREATE TABLE quotes(id INTEGER PRIMARY KEY, text TEXT, author TEXT, category TEXT)
        ''');
    });

    for (var quote in quotes) {
      await database.insert(
        'quotes',
        quote.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          actions: [
            IconButton(
              onPressed: () {
                setState(() {
                  fetchQuotes();
                });
              },
              icon: const Icon(Icons.refresh),
            ),
          ],
          backgroundColor: Colors.white,
          title: const Text('Random Quotes App'),
        ),
        body: Center(
          child: quotes.isEmpty
              ? const CircularProgressIndicator()
              : ListView.builder(
                  itemCount: quotes.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.all(16),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.2),
                              blurRadius: 10,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              quotes[index].text,
                              style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w500,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Row(
                              children: [
                                Text(
                                  quotes[index].author,
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontWeight: FontWeight.w400,
                                    fontSize: 16,
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  quotes[index].category.toUpperCase(),
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }
}
