import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/quote_controller.dart';
import '../widgets/quote_card.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Daily Quote'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Consumer<QuoteController>(
        builder: (context, quoteController, child) {
          if (quoteController.isLoading) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          if (quoteController.allQuotes.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No quotes available',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Please check your internet connection',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: quoteController.refreshDailyQuote,
            child: ListView.builder(
              physics: AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.all(16),
              itemCount: quoteController.allQuotes.length,
              itemBuilder: (context, index) {
                final quote = quoteController.allQuotes[index];
                final isDailyQuote = quote == quoteController.dailyQuote;
                
                return Column(
                  children: [
                    if (isDailyQuote) ...[
                      Container(
                        width: double.infinity,
                        margin: EdgeInsets.only(bottom: 8),
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Theme.of(context).primaryColor.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.star,
                              size: 16,
                              color: Theme.of(context).primaryColor,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Quote of the Day',
                              style: TextStyle(
                                color: Theme.of(context).primaryColor,
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    QuoteCard(
                      quote: quote,
                      isHighlighted: isDailyQuote,
                    ),
                    SizedBox(height: 16),
                  ],
                );
              },
            ),
          );
        },
      ),
    );
  }
}
