import 'dart:io';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:gal/gal.dart';
import '../models/quote_model.dart';

class QuoteImageDownloader {
  static Future<bool> downloadQuoteImage(Quote quote) async {
    try {
      // Request storage permission
      final hasPermission = await _requestStoragePermission();
      if (!hasPermission) {
        throw Exception('Storage permission denied');
      }

      // Create quote image
      final imageBytes = await _createQuoteImage(quote);

      // Get temporary directory
      final tempDir = await getTemporaryDirectory();
      final fileName = 'quote_${quote.id}_${DateTime.now().millisecondsSinceEpoch}.png';
      final file = File('${tempDir.path}/$fileName');
      
      // Write image to file
      await file.writeAsBytes(imageBytes);

      // Save to gallery using gal package
      await Gal.putImage(file.path, album: 'Daily Motivational Quotes');

      // Clean up temporary file
      await file.delete();

      return true;
    } catch (e) {
      print('Error downloading quote image: $e');
      return false;
    }
  }

  static Future<bool> _requestStoragePermission() async {
    if (Platform.isAndroid) {
      // For Android 13+ (API 33+), we need photos permission
      final androidInfo = await _getAndroidVersion();
      if (androidInfo >= 33) {
        return await Permission.photos.request().isGranted;
      } else {
        // For older Android versions, we need storage permission
        return await Permission.storage.request().isGranted;
      }
    } else if (Platform.isIOS) {
      return await Permission.photos.request().isGranted;
    }
    return false;
  }

  static Future<int> _getAndroidVersion() async {
    if (Platform.isAndroid) {
      // This is a simple way to check Android version
      // You might want to use device_info_plus package for more accurate detection
      return 33; // Assume modern Android for now
    }
    return 0;
  }

  static Future<Uint8List> _createQuoteImage(Quote quote) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final size = Size(800, 1200);

    // Create gradient background
    final gradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0xFF667eea),
        Color(0xFF764ba2),
        Color(0xFF6B73FF),
        Color(0xFF9A9CE3),
      ],
    );

    final paint = Paint()
      ..shader = gradient.createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);

    // Add glass effect overlay for the main content area
    final glassPaint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    final glassRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(30, 150, size.width - 60, size.height - 250),
      Radius.circular(25),
    );
    canvas.drawRRect(glassRect, glassPaint);

    // Draw border
    final borderPaint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawRRect(glassRect, borderPaint);

    // Draw category badge at top center
    final categoryTextPainter = TextPainter(
      text: TextSpan(
        text: quote.category.toUpperCase(),
        style: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          letterSpacing: 2.0,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    categoryTextPainter.layout();

    // Category badge background
    final categoryWidth = categoryTextPainter.width + 32;
    final categoryHeight = 50.0;
    final categoryX = (size.width - categoryWidth) / 2;
    final categoryY = 180.0;

    final categoryRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(categoryX, categoryY, categoryWidth, categoryHeight),
      Radius.circular(25),
    );
    final categoryPaint = Paint()
      ..color = Colors.white.withOpacity(0.25);
    canvas.drawRRect(categoryRect, categoryPaint);

    // Draw category border
    final categoryBorderPaint = Paint()
      ..color = Colors.white.withOpacity(0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawRRect(categoryRect, categoryBorderPaint);

    // Draw category text
    categoryTextPainter.paint(
      canvas, 
      Offset(categoryX + 16, categoryY + (categoryHeight - categoryTextPainter.height) / 2)
    );

    // Calculate optimal font size for quote text
    final maxWidth = size.width - 100; // More padding for readability
    final optimalFontSize = _getOptimalFontSize(quote.text, maxWidth);

    // Draw quote text with better positioning
    final quoteTextPainter = TextPainter(
      text: TextSpan(
        text: '"${quote.text}"',
        style: TextStyle(
          color: Colors.white,
          fontSize: optimalFontSize,
          fontWeight: FontWeight.w400,
          height: 1.5, // Better line height for readability
          letterSpacing: 0.8,
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );
    quoteTextPainter.layout(maxWidth: maxWidth);

    // Position quote text in the center of available space
    final availableHeight = size.height - 350 - 120; // Space between category and author
    final quoteY = 270 + (availableHeight - quoteTextPainter.height) / 2;
    quoteTextPainter.paint(
      canvas,
      Offset((size.width - quoteTextPainter.width) / 2, quoteY),
    );

    // Draw author text at bottom with proper spacing
    final authorTextPainter = TextPainter(
      text: TextSpan(
        text: '— ${quote.author}',
        style: TextStyle(
          color: Colors.white.withOpacity(0.95),
          fontSize: 28, // Larger author text
          fontWeight: FontWeight.w600,
          fontStyle: FontStyle.italic,
          letterSpacing: 1.0,
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );
    authorTextPainter.layout();

    // Position author name with space from bottom
    final authorY = size.height - 150; // 150px from bottom
    authorTextPainter.paint(
      canvas,
      Offset((size.width - authorTextPainter.width) / 2, authorY),
    );

    // Draw app branding at the very bottom
    final brandingTextPainter = TextPainter(
      text: TextSpan(
        text: 'Daily Motivational Quotes',
        style: TextStyle(
          color: Colors.white.withOpacity(0.7),
          fontSize: 18,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );
    brandingTextPainter.layout();
    brandingTextPainter.paint(
      canvas,
      Offset(
        (size.width - brandingTextPainter.width) / 2,
        size.height - 60, // 60px from bottom
      ),
    );

    // Convert to image
    final picture = recorder.endRecording();
    final img = await picture.toImage(size.width.toInt(), size.height.toInt());
    final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }

  static double _getOptimalFontSize(String text, double maxWidth) {
    // Calculate optimal font size based on text length and available space
    final baseSize = 40.0;
    
    if (text.length < 30) return baseSize + 8; // Short quotes - larger font
    if (text.length < 60) return baseSize + 4; // Medium quotes
    if (text.length < 100) return baseSize; // Normal quotes
    if (text.length < 150) return baseSize - 6; // Long quotes
    if (text.length < 200) return baseSize - 10; // Very long quotes
    return baseSize - 14; // Extra long quotes
  }
}
