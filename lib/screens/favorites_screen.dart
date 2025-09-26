import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:ui';
import '../controllers/quote_controller.dart';
import '../models/quote_model.dart';
import '../services/quote_image_downloader.dart';

class FavoritesScreen extends StatefulWidget {
  @override
  _FavoritesScreenState createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen>
    with TickerProviderStateMixin {
  late AnimationController _heartAnimationController;
  late AnimationController _downloadController;
  late Animation<double> _heartScaleAnimation;
  late Animation<double> _heartRotationAnimation;

  @override
  void initState() {
    super.initState();
    _heartAnimationController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );
    _downloadController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );

    _heartScaleAnimation = Tween<double>(begin: 1.0, end: 0.8).animate(
      CurvedAnimation(
        parent: _heartAnimationController,
        curve: Interval(0.0, 0.5, curve: Curves.elasticInOut),
      ),
    );

    _heartRotationAnimation = Tween<double>(begin: 0.0, end: 0.2).animate(
      CurvedAnimation(
        parent: _heartAnimationController,
        curve: Interval(0.0, 1.0, curve: Curves.elasticOut),
      ),
    );
  }

  @override
  void dispose() {
    _heartAnimationController.dispose();
    _downloadController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: _getBackgroundDecoration(context),
        child: Consumer<QuoteController>(
          builder: (context, quoteController, child) {
            final favoriteQuotes = quoteController.favoriteQuotes;

            return CustomScrollView(
              slivers: [
                // Modern Glass App Bar
                SliverAppBar(
                  expandedHeight: 120,
                  floating: false,
                  pinned: true,
                  elevation: 0,
                  backgroundColor: Colors.transparent,
                  automaticallyImplyLeading: false,
                  flexibleSpace: FlexibleSpaceBar(
                    title: _buildGlassContainer(
                      context,
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.favorite,
                            color: Colors.white,
                            size: 20,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'My Favorites',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    centerTitle: true,
                    titlePadding: EdgeInsets.only(bottom: 16),
                  ),
                ),

                // Content
                if (favoriteQuotes.isEmpty)
                  SliverFillRemaining(
                    child: _buildEmptyState(context),
                  )
                else
                  SliverPadding(
                    padding: EdgeInsets.all(16),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final quote = favoriteQuotes[index];
                          return Padding(
                            padding: EdgeInsets.only(bottom: 16),
                            child: _buildQuoteCard(
                              context,
                              quote,
                              quoteController,
                              index,
                            ),
                          );
                        },
                        childCount: favoriteQuotes.length,
                      ),
                    ),
                  ),

                // Bottom padding
                SliverToBoxAdapter(
                  child: SizedBox(height: 100),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildGlassContainer(
            context,
            padding: EdgeInsets.all(40),
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        Colors.white.withOpacity(0.3),
                        Colors.white.withOpacity(0.1),
                      ],
                    ),
                  ),
                  child: Icon(
                    Icons.favorite_outline,
                    size: 64,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
                SizedBox(height: 24),
                Text(
                  'No Favorites Yet',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  'Start building your collection by\ntapping the heart icon on quotes',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 16,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuoteCard(
    BuildContext context,
    Quote quote,
    QuoteController quoteController,
    int index,
  ) {
    return _buildGlassContainer(
      context,
      padding: EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Quote header with category and number
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Text(
                  quote.category.toUpperCase(),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ),
              Spacer(),
              // Text(
              //   '#${quote.id}',
              //   style: TextStyle(
              //     color: Colors.white.withOpacity(0.6),
              //     fontSize: 12,
              //     fontWeight: FontWeight.w500,
              //   ),
              // ),
            ],
          ),

          SizedBox(height: 20),

          // Quote text
          Text(
            '"${quote.text}"',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w400,
              height: 1.5,
              letterSpacing: 0.3,
            ),
          ),

          SizedBox(height: 16),

          // Author
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              '— ${quote.author}',
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 16,
                fontWeight: FontWeight.w600,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),

          SizedBox(height: 20),

          // Action buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // Share button
              _buildActionButton(
                context,
                icon: Icons.share_outlined,
                color: Colors.white,
                onTap: () => _shareQuote(quote),
              ),
              
              SizedBox(width: 12),
              
              // Download button
              _buildActionButton(
                context,
                icon: Icons.download_outlined,
                color: Colors.white,
                onTap: () => _showDownloadDialog(context, quote),
              ),
              
              SizedBox(width: 12),
              
              // Favorite button with animation
              AnimatedBuilder(
                animation: _heartAnimationController,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _heartScaleAnimation.value,
                    child: Transform.rotate(
                      angle: _heartRotationAnimation.value,
                      child: _buildActionButton(
                        context,
                        icon: Icons.favorite,
                        color: Colors.red.shade300,
                        onTap: () => _toggleFavoriteWithAnimation(
                          context,
                          quote,
                          quoteController,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGlassContainer(
    BuildContext context, {
    required Widget child,
    EdgeInsets? padding,
    double? borderRadius,
  }) {
    return Container(
      padding: padding ?? EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius ?? 24),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1.5,
        ),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.15),
            Colors.white.withOpacity(0.08),
            Colors.white.withOpacity(0.05),
          ],
          stops: [0.0, 0.5, 1.0],
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius ?? 24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
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
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white.withOpacity(0.3),
            width: 1.5,
          ),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withOpacity(0.25),
              Colors.white.withOpacity(0.1),
            ],
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(25),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Center(
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showDownloadDialog(BuildContext context, Quote quote) {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.6),
      builder: (BuildContext context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Container(
            padding: EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isDark ? Color(0xFF2D2D2D) : Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 20,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Close button
                Align(
                  alignment: Alignment.topRight,
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isDark 
                            ? Colors.white.withOpacity(0.1) 
                            : Colors.black.withOpacity(0.1),
                      ),
                      child: Icon(
                        Icons.close,
                        color: isDark ? Colors.white : Colors.black,
                        size: 20,
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 8),

                // Download icon
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                  ),
                  child: Icon(
                    Icons.download_outlined,
                    size: 48,
                    color: Theme.of(context).primaryColor,
                  ),
                ),

                SizedBox(height: 20),

                // Title
                Text(
                  'Download Quote',
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                SizedBox(height: 12),

                // Description
                Text(
                  'Save this inspirational quote as an image to your device?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isDark 
                        ? Colors.white.withOpacity(0.7) 
                        : Colors.black.withOpacity(0.7),
                    fontSize: 16,
                    height: 1.4,
                  ),
                ),

                SizedBox(height: 24),

                // Quote preview (mini)
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark 
                        ? Colors.white.withOpacity(0.05) 
                        : Colors.black.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark 
                          ? Colors.white.withOpacity(0.1) 
                          : Colors.black.withOpacity(0.1),
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '"${quote.text.length > 60 ? quote.text.substring(0, 60) + '...' : quote.text}"',
                        style: TextStyle(
                          color: isDark 
                              ? Colors.white.withOpacity(0.8) 
                              : Colors.black.withOpacity(0.8),
                          fontSize: 14,
                          fontStyle: FontStyle.italic,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 8),
                      Text(
                        '— ${quote.author}',
                        style: TextStyle(
                          color: isDark 
                              ? Colors.white.withOpacity(0.6) 
                              : Colors.black.withOpacity(0.6),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 28),

                // Action buttons
                Row(
                  children: [
                    // Cancel button
                    Expanded(
                      child: _buildSolidDialogButton(
                        context,
                        text: 'Cancel',
                        isPrimary: false,
                        onTap: () => Navigator.of(context).pop(),
                      ),
                    ),
                    
                    SizedBox(width: 12),
                    
                    // Download button
                    Expanded(
                      child: _buildSolidDialogButton(
                        context,
                        text: 'Download',
                        isPrimary: true,
                        onTap: () {
                          Navigator.of(context).pop();
                          _downloadQuoteImage(context, quote);
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSolidDialogButton(
    BuildContext context, {
    required String text,
    required bool isPrimary,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          color: isPrimary 
              ? Theme.of(context).primaryColor
              : (isDark ? Colors.grey[800] : Colors.grey[200]),
          boxShadow: isPrimary ? [
            BoxShadow(
              color: Theme.of(context).primaryColor.withOpacity(0.3),
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ] : [],
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              color: isPrimary 
                  ? Colors.white 
                  : (isDark ? Colors.white : Colors.black),
              fontSize: 16,
              fontWeight: isPrimary ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  void _toggleFavoriteWithAnimation(
    BuildContext context,
    Quote quote,
    QuoteController quoteController,
  ) {
    // Trigger heart animation
    _heartAnimationController.forward().then((_) {
      _heartAnimationController.reverse();
    });

    // Add haptic feedback
    HapticFeedback.lightImpact();

    // Show confirmation with animation
    _showUnfavoriteConfirmation(context, quote, quoteController);
  }

  void _showUnfavoriteConfirmation(
    BuildContext context,
    Quote quote,
    QuoteController quoteController,
  ) {
    final snackBar = SnackBar(
      content: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [
              Colors.white.withOpacity(0.2),
              Colors.white.withOpacity(0.1),
            ],
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(Icons.heart_broken, color: Colors.white),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Removed from favorites',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      backgroundColor: Colors.transparent,
      elevation: 0,
      duration: Duration(seconds: 2),
      action: SnackBarAction(
        label: 'UNDO',
        textColor: Colors.white,
        onPressed: () {
          quoteController.toggleFavorite(quote);
        },
      ),
    );

    // Remove from favorites
    quoteController.toggleFavorite(quote);

    // Show snackbar
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void _downloadQuoteImage(BuildContext context, Quote quote) async {
    // Add haptic feedback
    HapticFeedback.mediumImpact();

    try {
      // Show loading state
      _showLoadingSnackbar(context);

      // Call the download service
      final success = await QuoteImageDownloader.downloadQuoteImage(quote);

      if (success) {
        // Show success message
        _showSuccessSnackbar(context);
      } else {
        // Show error message
        _showErrorSnackbar(context);
      }
    } catch (e) {
      print('Error downloading quote: $e');
      _showErrorSnackbar(context);
    }
  }

  void _showLoadingSnackbar(BuildContext context) {
    final snackBar = SnackBar(
      content: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Theme.of(context).primaryColor.withOpacity(0.9),
        ),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  strokeWidth: 2,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Creating quote image...',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
      backgroundColor: Colors.transparent,
      elevation: 0,
      duration: Duration(seconds: 2),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void _showSuccessSnackbar(BuildContext context) {
    final snackBar = SnackBar(
      content: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.green.withOpacity(0.9),
        ),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(Icons.download_done, color: Colors.white),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Quote image saved to gallery!',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
      backgroundColor: Colors.transparent,
      elevation: 0,
      duration: Duration(seconds: 3),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void _showErrorSnackbar(BuildContext context) {
    final snackBar = SnackBar(
      content: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.red.withOpacity(0.9),
        ),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(Icons.error_outline, color: Colors.white),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Failed to save image. Please try again.',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
      backgroundColor: Colors.transparent,
      elevation: 0,
      duration: Duration(seconds: 3),
      action: SnackBarAction(
        label: 'RETRY',
        textColor: Colors.white,
        onPressed: () {
          // Retry download logic would go here
        },
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void _shareQuote(Quote quote) {
    // Add haptic feedback
    HapticFeedback.lightImpact();

    final shareText = '"${quote.text}"\n\n— ${quote.author}\n\nCategory: ${quote.category}\n\nShared from Daily Motivational Quotes';
    
    Share.share(
      shareText,
      subject: 'Motivational Quote by ${quote.author}',
    );

    // Show feedback snackbar
    final snackBar = SnackBar(
      content: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Theme.of(context).primaryColor.withOpacity(0.9),
        ),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(Icons.share, color: Colors.white),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Quote shared successfully!',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
      backgroundColor: Colors.transparent,
      elevation: 0,
      duration: Duration(seconds: 2),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
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
}