import 'package:db_miner/models/quotes_model.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:convert';
import 'package:sqflite/sqlite_api.dart';

class QuotesController extends GetxController {
  List<Quote> quotes = [];

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
      quotes = responseData
          .map((quote) => Quote(
              id: quote['id'],
              text: quote['text'],
              author: quote['author'],
              category: quote['category']))
          .toList();
      _saveQuotesToDatabase(quotes);
      print(quotes);
    }
    update();
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
  void update([List<Object>? ids, bool condition = true]) {
    // TODO: implement update
    super.update(ids, condition);
  }
}
