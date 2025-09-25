import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart';
import '../models/quote_model.dart';

class QuoteService {
  static final Random _random = Random();

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

  // Get a truly random daily quote (changes each day)
  static Quote getDailyQuote(List<Quote> quotes) {
    if (quotes.isEmpty) return _getDefaultQuote();
    
    final now = DateTime.now();
    // Create a seed based on the current date for consistent daily randomness
    final dateSeed = now.year * 10000 + now.month * 100 + now.day;
    final random = Random(dateSeed);
    final index = random.nextInt(quotes.length);
    
    return quotes[index];
  }

  // Get randomized list of all quotes
  static List<Quote> getRandomizedQuotes(List<Quote> quotes) {
    if (quotes.isEmpty) return [];
    
    final shuffledQuotes = List<Quote>.from(quotes);
    shuffledQuotes.shuffle(_random);
    return shuffledQuotes;
  }

  // Get quotes by category (for future features)
  static List<Quote> getQuotesByCategory(List<Quote> quotes, String category) {
    return quotes.where((quote) => 
        quote.category.toLowerCase() == category.toLowerCase()).toList();
  }

  // Get random quote from specific category
  static Quote? getRandomQuoteFromCategory(List<Quote> quotes, String category) {
    final categoryQuotes = getQuotesByCategory(quotes, category);
    if (categoryQuotes.isEmpty) return null;
    
    final randomIndex = _random.nextInt(categoryQuotes.length);
    return categoryQuotes[randomIndex];
  }

  static Quote _getDefaultQuote() {
    return Quote(
      id: 0,
      text: "The only way to do great work is to love what you do.",
      author: "Steve Jobs",
      category: "Motivation",
    );
  }

  // Get all unique categories
  static List<String> getCategories(List<Quote> quotes) {
    final categories = quotes.map((quote) => quote.category).toSet().toList();
    categories.sort();
    return categories;
  }
}
