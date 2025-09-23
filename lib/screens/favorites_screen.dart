import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/quote_controller.dart';
import '../widgets/quote_card.dart';

class FavoritesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Favorites'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Consumer<QuoteController>(
        builder: (context, quoteController, child) {
          final favoriteQuotes = quoteController.favoriteQuotes;

          if (favoriteQuotes.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.favorite_outline,
                    size: 64,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No favorites yet',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Tap the heart icon to add quotes to favorites',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: favoriteQuotes.length,
            itemBuilder: (context, index) {
              final quote = favoriteQuotes[index];
              return Column(
                children: [
                  QuoteCard(quote: quote),
                  SizedBox(height: 16),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
