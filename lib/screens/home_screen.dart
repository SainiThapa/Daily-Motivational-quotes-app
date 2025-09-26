import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'dart:ui';
import '../controllers/quote_controller.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  PageController _pageController = PageController();
  int _currentIndex = 0;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  Future<bool> _onWillPop() async {
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return _buildExitConfirmationDialog();
      },
    ) ?? false;
  }

  Widget _buildExitConfirmationDialog() {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: _buildGlassmorphismContainer(
        context,
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.exit_to_app,
              size: 48,
              color: Colors.white,
            ),
            SizedBox(height: 16),
            Text(
              'Exit App?',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 12),
            Text(
              'Are you sure you want to exit?',
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _buildDialogButton(
                    context,
                    text: 'Cancel',
                    isPrimary: false,
                    onTap: () => Navigator.of(context).pop(false),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _buildDialogButton(
                    context,
                    text: 'Exit',
                    isPrimary: true,
                    onTap: () => Navigator.of(context).pop(true),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDialogButton(
    BuildContext context, {
    required String text,
    required bool isPrimary,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: isPrimary 
            ? Colors.white.withOpacity(0.8)
            : Colors.transparent,
          border: Border.all(
            color: Colors.white.withOpacity(0.5),
            width: 1,
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isPrimary 
              ? Colors.white
              : Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        body: Consumer<QuoteController>(
          builder: (context, quoteController, child) {
            if (quoteController.isLoading) {
              return _buildLoadingScreen(context);
            }

            if (quoteController.allQuotes.isEmpty) {
              return _buildEmptyScreen(context);
            }

            // Prepare quotes list with daily quote first
            final dailyQuote = quoteController.dailyQuote;
            final otherQuotes = quoteController.randomizedQuotes
                .where((quote) => quote != dailyQuote)
                .toList();
            final allQuotesToShow = [
              if (dailyQuote != null) dailyQuote,
              ...otherQuotes,
            ];

            return _buildQuotePageView(context, quoteController, allQuotesToShow);
          },
        ),
      ),
    );
  }

  Widget _buildLoadingScreen(BuildContext context) {
    return Container(
      decoration: _getBackgroundDecoration(context),
      child: Center(
        child: _buildGlassmorphismContainer(
          context,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                strokeWidth: 3,
              ),
              SizedBox(height: 24),
              Text(
                'Loading Inspiration...',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyScreen(BuildContext context) {
    return Container(
      decoration: _getBackgroundDecoration(context),
      child: Center(
        child: _buildGlassmorphismContainer(
          context,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.auto_stories_outlined,
                size: 64,
                color: Colors.white.withOpacity(0.9),
              ),
              SizedBox(height: 24),
              Text(
                'No Quotes Available',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Pull to refresh and try again',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuotePageView(
    BuildContext context,
    QuoteController quoteController,
    List allQuotesToShow,
  ) {
    return Container(
      decoration: _getBackgroundDecoration(context),
      child: PageView.builder(
        controller: _pageController,
        scrollDirection: Axis.vertical,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
          _fadeController.reset();
          _fadeController.forward();
        },
        itemCount: allQuotesToShow.length,
        itemBuilder: (context, index) {
          final quote = allQuotesToShow[index];
          final isDaily = index == 0;

          return AnimatedBuilder(
            animation: _fadeAnimation,
            builder: (context, child) {
              return FadeTransition(
                opacity: _fadeAnimation,
                child: _buildQuoteScreen(
                  context,
                  quote,
                  isDaily,
                  quoteController,
                  index,
                  allQuotesToShow.length,
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildQuoteScreen(
    BuildContext context,
    quote,
    bool isDaily,
    QuoteController quoteController,
    int currentIndex,
    int totalQuotes,
  ) {
    return Padding(
      padding: EdgeInsets.all(20),
      child: Column(
        children: [
          // Top area with daily quote indicator only
          SafeArea(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Daily quote badge
                if (isDaily)
                  _buildGlassmorphismContainer(
                    context,
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.auto_awesome, color: Colors.white, size: 16),
                        SizedBox(width: 6),
                        Text(
                          'Daily Motivation for you',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  SizedBox(),

                // Empty space where counter was - removed as requested
                SizedBox(),
              ],
            ),
          ),

          // Main quote content
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Quote text in glassmorphism container
                  _buildGlassmorphismContainer(
                    context,
                    padding: EdgeInsets.all(32),
                    child: Column(
                      children: [
                        // Category badge
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white,
                              width: 1,
                            ),
                          ),
                          child: Text(
                            quote.category.toUpperCase(),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),

                        SizedBox(height: 32),

                        // Quote text
                        Text(
                          '"${quote.text}"',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.w300,
                            height: 1.4,
                            letterSpacing: 0.5,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        SizedBox(height: 24),

                        // Author
                        Text(
                          '— ${quote.author}',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom actions - Updated with new buttons
          SafeArea(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Favorite button
                _buildActionButton(
                  context,
                  icon: quoteController.isFavorite(quote)
                      ? Icons.favorite
                      : Icons.favorite_border,
                  color: quoteController.isFavorite(quote)
                      ? Colors.red
                      : Colors.white,
                  onTap: () => quoteController.toggleFavorite(quote),
                ),

                // Share button
                _buildActionButton(
                  context,
                  icon: Icons.share,
                  color: Colors.white,
                  onTap: () => _shareQuote(quote),
                ),

                // Copy button (replaces refresh for daily quote)
                _buildActionButton(
                  context,
                  icon: Icons.copy,
                  color: Colors.white,
                  onTap: () => _copyQuote(quote),
                ),
              ],
            ),
          ),

          // Swipe indicator
          Padding(
            padding: EdgeInsets.only(bottom: 20),
            child: Column(
              children: [
                Icon(
                  Icons.keyboard_arrow_up,
                  color: Colors.white,
                  size: 24,
                ),
                Text(
                  'Swipe up for next quote',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassmorphismContainer(
    BuildContext context, {
    required Widget child,
    EdgeInsets? padding,
  }) {
    return Container(
      padding: padding ?? EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.2), width: 1.5),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.15),
            Colors.white.withOpacity(0.05),
          ],
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: child,
        ),
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 1.5),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withOpacity(0.2),
              Colors.white.withOpacity(0.2),
            ],
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Center(child: Icon(icon, color: color, size: 28)),
          ),
        ),
      ),
    );
  }

  BoxDecoration _getBackgroundDecoration(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: isDark
            ? [
                Color(0xFF1a1a2e),
                Color(0xFF16213e),
                Color(0xFF0f0f23),
                Color(0xFF533483),
              ]
            : [
                Color(0xFF667eea),
                Color(0xFF764ba2),
                Color(0xFF6B73FF),
                Color(0xFF9A9CE3),
              ],
      ),
    );
  }

  void _shareQuote(quote) {
    final shareText = '"${quote.text}"\n\n— ${quote.author}';
    // Add your share implementation here
    print('Sharing: $shareText');
  }

  void _copyQuote(quote) {
    final copyText = '"${quote.text}"\n\n— ${quote.author}';
    Clipboard.setData(ClipboardData(text: copyText));
    
    // Show a snackbar to confirm copy
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Quote copied to clipboard!'),
        duration: Duration(seconds: 2),
        backgroundColor: Colors.white.withOpacity(0.8),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}