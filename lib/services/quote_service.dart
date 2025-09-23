import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/quote_model.dart';

class QuoteService {
  static Future<List<Quote>> loadQuotes() async {
    try {
      final String response = await rootBundle.loadString('assets/quotes.json');
      final List<dynamic> data = json.decode(response);
      return data.map((json) => Quote.fromJson(json)).toList();
    } catch (e) {
      print('Error loading quotes: $e');
      return [];
    }
  }

  static Quote getDailyQuote(List<Quote> quotes) {
    if (quotes.isEmpty) return _getDefaultQuote();
    
    final now = DateTime.now();
    final dayOfYear = now.difference(DateTime(now.year, 1, 1)).inDays;
    final index = dayOfYear % quotes.length;
    return quotes[index];
  }

  static Quote _getDefaultQuote() {
    return Quote(
      id: 0,
      text: "The only way to do great work is to love what you do.",
      author: "Steve Jobs",
      category: "Motivation",
    );
  }
}

