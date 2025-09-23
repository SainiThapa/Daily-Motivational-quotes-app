import 'package:flutter/foundation.dart';
import '../models/quote_model.dart';
import '../services/quote_service.dart';
import '../services/storage_service.dart';

class QuoteController extends ChangeNotifier {
  List<Quote> _allQuotes = [];
  List<Quote> _favoriteQuotes = [];
  Quote? _dailyQuote;
  bool _isLoading = true;

  List<Quote> get allQuotes => _allQuotes;
  List<Quote> get favoriteQuotes => _favoriteQuotes;
  Quote? get dailyQuote => _dailyQuote;
  bool get isLoading => _isLoading;

  QuoteController() {
    _initializeQuotes();
  }

  Future<void> _initializeQuotes() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Load all quotes
      _allQuotes = await QuoteService.loadQuotes();
      
      // Load favorite quotes
      _favoriteQuotes = await StorageService.getFavoriteQuotes();
      
      // Set daily quote
      _dailyQuote = QuoteService.getDailyQuote(_allQuotes);
      
    } catch (e) {
      print('Error initializing quotes: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  bool isFavorite(Quote quote) {
    return _favoriteQuotes.contains(quote);
  }

  Future<void> toggleFavorite(Quote quote) async {
    if (isFavorite(quote)) {
      _favoriteQuotes.remove(quote);
    } else {
      _favoriteQuotes.add(quote);
    }
    
    await StorageService.saveFavoriteQuotes(_favoriteQuotes);
    notifyListeners();
  }

  Future<void> refreshDailyQuote() async {
    if (_allQuotes.isNotEmpty) {
      _dailyQuote = QuoteService.getDailyQuote(_allQuotes);
      notifyListeners();
    }
  }
}

