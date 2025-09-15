import 'package:flutter/material.dart';

class NotificationService {
  static void showInAppNotification(
    BuildContext context,
    String title,
    String message, {
    Duration duration = const Duration(seconds: 3),
    Color backgroundColor = Colors.green,
  }) {
    // Create a simple banner notification
    final banner = MaterialBanner(
      content: Text(
        message,
        style: const TextStyle(
          fontFamily: 'NeueMontreal',
          color: Colors.white,
        ),
      ),
      leading: Icon(
        _getIconForNotification(title),
        color: Colors.white,
      ),
      backgroundColor: backgroundColor,
      actions: [
        TextButton(
          onPressed: () => ScaffoldMessenger.of(context).hideCurrentMaterialBanner(),
          child: const Text(
            'DISMISS',
            style: TextStyle(
              fontFamily: 'NeuePowerTrial',
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );

    // Show the notification
    ScaffoldMessenger.of(context).showMaterialBanner(banner);

    // Auto-dismiss after duration
    Future.delayed(duration, () {
      try {
        ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
      } catch (e) {
        // Ignore if banner is already dismissed
      }
    });
  }

  static IconData _getIconForNotification(String title) {
    if (title.toLowerCase().contains('arrived')) {
      return Icons.location_on;
    } else if (title.toLowerCase().contains('picked')) {
      return Icons.shopping_bag;
    } else if (title.toLowerCase().contains('delivered')) {
      return Icons.check_circle;
    } else if (title.toLowerCase().contains('error')) {
      return Icons.error;
    } else {
      return Icons.info;
    }
  }

  static void showSnackBar(
    BuildContext context,
    String message, {
    Color backgroundColor = Colors.green,
    Duration duration = const Duration(seconds: 2),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            fontFamily: 'NeueMontreal',
            color: Colors.white,
          ),
        ),
        backgroundColor: backgroundColor,
        duration: duration,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}