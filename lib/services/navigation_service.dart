import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

class NavigationService {
  // Open Google Maps with directions from current location to destination
  static Future<void> openGoogleMapsDirections(
    double startLat,
    double startLng,
    double endLat,
    double endLng,
  ) async {
    // List of URL schemes to try in order of preference
    final List<Uri> urlsToTry = [
      // Standard Google Maps URL with directions
      Uri.parse(
        'https://www.google.com/maps/dir/?api=1&origin=$startLat,$startLng&destination=$endLat,$endLng&travelmode=driving',
      ),
      // Android-specific navigation scheme
      Uri.parse(
        'google.navigation:q=$endLat,$endLng&mode=driving',
      ),
      // Generic geo intent with query
      Uri.parse(
        'geo:$startLat,$startLng?q=$endLat,$endLng(End Point)',
      ),
      // Fallback to simple Google Maps search
      Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=$endLat,$endLng',
      ),
    ];

    // Try each URL scheme until one works
    for (final Uri url in urlsToTry) {
      try {
        print('Trying URL: $url'); // Debug log
        if (await canLaunchUrl(url)) {
          await launchUrl(url);
          return; // Success, exit the function
        }
      } catch (e) {
        print('Failed to launch URL $url: $e'); // Debug log
        continue; // Try the next URL scheme
      }
    }

    // If we get here, none of the URL schemes worked
    throw 'Could not open Google Maps. Please make sure Google Maps is installed and updated to the latest version.';
  }

  // Open Google Maps to a specific location
  static Future<void> openGoogleMapsLocation(
    double lat,
    double lng,
  ) async {
    // List of URL schemes to try in order of preference
    final List<Uri> urlsToTry = [
      // Standard Google Maps URL with search
      Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=$lat,$lng',
      ),
      // Android-specific geo intent
      Uri.parse(
        'geo:$lat,$lng?q=$lat,$lng',
      ),
      // Fallback to coordinates only
      Uri.parse(
        'geo:$lat,$lng',
      ),
    ];

    // Try each URL scheme until one works
    for (final Uri url in urlsToTry) {
      try {
        print('Trying URL: $url'); // Debug log
        if (await canLaunchUrl(url)) {
          await launchUrl(url);
          return; // Success, exit the function
        }
      } catch (e) {
        print('Failed to launch URL $url: $e'); // Debug log
        continue; // Try the next URL scheme
      }
    }

    // If we get here, none of the URL schemes worked
    throw 'Could not open Google Maps. Please make sure Google Maps is installed and updated to the latest version.';
  }
}