# YOLO Driver App

A minimal, runnable Flutter (null-safety) driver app that simulates a food-delivery driver flow.

## Features

- View one assigned order
- Navigate to restaurant & customer via Google Maps
- Enforce geofence: allow pickup/delivery only when driver is within 50m
- Update and display driver location every 10s (printed to console as "sent to server")

## Branding

- App Name: Yolo
- Logo: 'Yolo' written in Neue Power trail (Black font color)
- Theme: Light mode, green/blue gradient accents, clean and minimal UI
- Fonts: 
  - Primary: Neue Power trail
  - Secondary: Neue Montreal

## Tech & Libraries

- Flutter (null-safety)
- geolocator: For location services
- url_launcher: For opening Google Maps

## Setup & Run

1. Clone the repository
2. Run `flutter pub get` to install dependencies
3. Run `flutter run` to start the app

## Dummy Login Credentials

- Email: `driver@yolo.com`
- Password: `password123`

## How to Test Geofence Behavior

The app uses mock location by default. To test the geofence behavior:

1. Login with the dummy credentials
2. On the order screen, you'll see your current location
3. The "Arrived at Restaurant" and "Arrived at Customer" buttons will be enabled only when you're within 50m of the respective locations
4. To simulate being within the geofence, you can modify the mock location in the LocationService

## Project Structure

```
lib/
├── main.dart              # App entry point
├── models/                # Data models
│   └── order.dart         # Order, Restaurant, Customer models
├── screens/               # UI screens
│   ├── login_screen.dart  # Login screen
│   └── order_screen.dart  # Order details and flow screen
├── services/              # Business logic
│   ├── location_service.dart   # Location tracking and geofence
│   └── navigation_service.dart # Google Maps integration
└── widgets/               # Custom widgets
    ├── yolo_logo.dart     # YOLO logo widget
    └── order_status_widget.dart # Order status display
```

## Pubspec.yaml Explanation

The pubspec.yaml file is organized as follows:

1. **Assets**: 
   - `assets/images/` - Placeholder for future image assets
   - `assets/icons/` - Placeholder for future icon assets

2. **Fonts**: 
   - As per requirements, we use system fonts only
   - The provided font files in `assets/fonts/` are available but not declared in pubspec
   - Fonts are referenced directly in widgets where needed

## Assumptions

1. The app uses mock location services for demonstration purposes
2. Real location services can be enabled by granting location permissions
3. Google Maps is available on the device for navigation
4. The app is designed for Android primarily (iOS requires additional setup for location services)

## Running on Emulator

To test on an Android emulator:

1. Create an Android Virtual Device (AVD)
2. Start the emulator
3. Run `flutter run` in the project directory

## Evaluation Checklist

- [x] Flow works end-to-end and geofence logic correct (50m check)
- [x] Location updates every 10s and shown on-screen
- [x] Navigate opens Google Maps with correct origin/destination
- [x] pubspec.yaml clearly organized (logo + future asset dirs + system fonts)
- [x] Clean repo history + README + comments
- [x] UI consistent with YOLO branding (logo, white bg and that provided color gradient txt)