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

  Quote({required this.id, required this.text, required this.author});

  Map<String, dynamic> toMap() {
    return {'id': id, 'text': text, 'author': author};
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
    final response = await http.get(Uri.parse('https://your-api-endpoint.com/quotes'));
    if (response.statusCode == 200) {
      final List<dynamic> responseData = json.decode(response.body);
      setState(() {
        quotes = responseData
            .map((quote) => Quote(id: quote['id'], text: quote['text'], author: quote['author']))
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
          CREATE TABLE quotes(id INTEGER PRIMARY KEY, text TEXT, author TEXT)
        ''');
        });

    for (var quote in quotes) {
      await database.insert('quotes', quote.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,);
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
          backgroundColor: Colors.white,
          title: const Text('Random Quotes App'),
        ),
        body: Center(
          child: quotes.isEmpty
              ? const CircularProgressIndicator()
              : ListView.builder(
            itemCount: quotes.length,
            itemBuilder: (ctx, index) {
              return ListTile(
                title: Text(quotes[index].text),
                subtitle: Text(quotes[index].author),
              );
            },
          ),
        ),
      ),
    );
  }
}
