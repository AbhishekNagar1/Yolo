import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:yolo/models/order.dart';
import 'package:yolo/services/location_service.dart';
import 'package:yolo/services/navigation_service.dart';
import 'package:yolo/services/notification_service.dart';
import 'package:yolo/screens/order_history_screen.dart';
import 'package:yolo/widgets/order_status_widget.dart';

class OrderScreen extends StatefulWidget {
  const OrderScreen({super.key});

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  // Sample mock order data
  late Order _order;
  Position? _currentPosition;
  double _distanceToRestaurant = 0;
  double _distanceToCustomer = 0;
  final LocationService _locationService = LocationService();
  bool _isLocationUpdating = false;
  bool _locationPermissionGranted = false;
  List<Order> _orderHistory = []; // For bonus feature
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _initializeOrder();
    _initializeOrderHistory(); // Initialize with dummy orders
    _requestLocationPermission();
  }

  void _initializeOrder() {
    _order = Order(
      orderId: 'YOLO-1001',
      restaurant: Restaurant(
        name: 'Spicebox',
        lat: 28.6139,
        lng: 77.2090,
      ),
      customer: Customer(
        name: 'Ravi Kumar',
        lat: 28.6170,
        lng: 77.2150,
      ),
      amount: 249.00,
    );
  }

  void _initializeOrderHistory() {
    // Add some dummy orders to history for testing
    _orderHistory = [
      Order(
        orderId: 'YOLO-1002',
        restaurant: Restaurant(
          name: 'Pizza Palace',
          lat: 28.6145,
          lng: 77.2100,
        ),
        customer: Customer(
          name: 'Amit Sharma',
          lat: 28.6180,
          lng: 77.2160,
        ),
        amount: 349.00,
        status: OrderStatus.delivered,
        deliveredTime: DateTime.now().subtract(const Duration(days: 1)),
      ),
      Order(
        orderId: 'YOLO-1003',
        restaurant: Restaurant(
          name: 'Burger Junction',
          lat: 28.6150,
          lng: 77.2110,
        ),
        customer: Customer(
          name: 'Priya Patel',
          lat: 28.6190,
          lng: 77.2170,
        ),
        amount: 299.00,
        status: OrderStatus.delivered,
        deliveredTime: DateTime.now().subtract(const Duration(days: 2)),
      ),
      Order(
        orderId: 'YOLO-1004',
        restaurant: Restaurant(
          name: 'Chinese Corner',
          lat: 28.6155,
          lng: 77.2120,
        ),
        customer: Customer(
          name: 'Rohan Mehta',
          lat: 28.6200,
          lng: 77.2180,
        ),
        amount: 429.00,
        status: OrderStatus.delivered,
        deliveredTime: DateTime.now().subtract(const Duration(days: 3)),
      ),
    ];
  }

  void _requestLocationPermission() async {
    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse) {
      setState(() {
        _locationPermissionGranted = true;
      });
      _startLocationUpdates();
      // Show notification that permission was granted
      NotificationService.showSnackBar(
        context,
        'Location permission granted! Geofencing is now enabled.',
        backgroundColor: Colors.green,
      );
    } else {
      // Show a dialog explaining why location permission is needed
      _showLocationPermissionDialog();
    }
  }

  void _showLocationPermissionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Location Permission Required',
            style: TextStyle(
              fontFamily: 'NeuePowerTrial',
              fontWeight: FontWeight.bold,
            ),
          ),
          content: const Text(
            'This app needs location permission to track your delivery progress and enable geofencing features.',
            style: TextStyle(
              fontFamily: 'NeueMontreal',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'Cancel',
                style: TextStyle(
                  fontFamily: 'NeueMontreal',
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _requestLocationPermission();
              },
              child: const Text(
                'Try Again',
                style: TextStyle(
                  fontFamily: 'NeuePowerTrial',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _startLocationUpdates() {
    setState(() {
      _isLocationUpdating = true;
    });

    _locationService.startLocationUpdates((Position position) {
      setState(() {
        _currentPosition = position;
        _calculateDistances();
      });
    });
  }

  void _calculateDistances() {
    Position positionToUse = _currentPosition ?? _locationService.mockPosition;

    _distanceToRestaurant = _locationService.calculateDistance(
      positionToUse.latitude,
      positionToUse.longitude,
      _order.restaurant.lat,
      _order.restaurant.lng,
    );

    _distanceToCustomer = _locationService.calculateDistance(
      positionToUse.latitude,
      positionToUse.longitude,
      _order.customer.lat,
      _order.customer.lng,
    );
  }

  @override
  void dispose() {
    _locationService.stopLocationUpdates();
    super.dispose();
  }

  void _updateOrderStatus(OrderStatus newStatus) {
    setState(() {
      _order = _order.copyWith(status: newStatus);
    });

    // Show notifications for status changes
    String message = '';
    Color color = Colors.green;

    switch (newStatus) {
      case OrderStatus.tripStarted:
        message = 'Trip started! Navigate to the restaurant.';
        break;
      case OrderStatus.arrivedAtRestaurant:
        message = 'You have arrived at the restaurant!';
        NotificationService.showInAppNotification(
          context,
          'Arrived at Restaurant',
          'You have arrived at the restaurant. Please pick up the order.',
          backgroundColor: Colors.blue,
        );
        break;
      case OrderStatus.pickedUp:
        message = 'Order picked up! Head to the customer.';
        NotificationService.showInAppNotification(
          context,
          'Order Picked Up',
          'Order picked up! Navigate to the customer location.',
          backgroundColor: Colors.orange,
        );
        break;
      case OrderStatus.arrivedAtCustomer:
        message = 'You have arrived at the customer!';
        NotificationService.showInAppNotification(
          context,
          'Arrived at Customer',
          'You have arrived at the customer. Please deliver the order.',
          backgroundColor: Colors.purple,
        );
        break;
      case OrderStatus.delivered:
        message = 'Order delivered successfully!';
        NotificationService.showInAppNotification(
          context,
          'Order Delivered',
          'Order delivered successfully! Thank you for using Yolo.',
          backgroundColor: Colors.green,
        );
        // Add to order history
        _addToOrderHistory();
        break;
      default:
        message = 'Order status updated';
    }

    if (message.isNotEmpty) {
      NotificationService.showSnackBar(
        context,
        message,
        backgroundColor: color,
      );
    }
  }

  void _addToOrderHistory() {
    setState(() {
      _orderHistory.add(
        _order.copyWith(
          deliveredTime: DateTime.now(),
          status: OrderStatus.delivered,
        ),
      );
    });
  }

  void _navigateToRestaurant() async {
    if (!_locationPermissionGranted) {
      _showLocationPermissionDialog();
      return;
    }

    Position positionToUse = _currentPosition ?? _locationService.mockPosition;

    try {
      print('Attempting to open navigation to restaurant...');
      print('Current position: ${positionToUse.latitude}, ${positionToUse.longitude}');
      print('Restaurant position: ${_order.restaurant.lat}, ${_order.restaurant.lng}');
      
      await NavigationService.openGoogleMapsDirections(
        positionToUse.latitude,
        positionToUse.longitude,
        _order.restaurant.lat,
        _order.restaurant.lng,
      );

      NotificationService.showSnackBar(
        context,
        'Opening navigation to restaurant...',
        backgroundColor: Colors.blue,
      );

      // For development/testing: simulate arrival after navigation
      // This allows developers to test the flow without real GPS
      Future.delayed(const Duration(seconds: 3), () {
        NotificationService.showSnackBar(
          context,
          'For testing: You can now tap "Arrived at Restaurant"',
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 5),
        );
      });
    } catch (e) {
      String errorMessage = e.toString();
      print('Navigation error: $errorMessage'); // Debug log
      
      if (errorMessage.contains('Could not open Google Maps')) {
        errorMessage = 'Could not open Google Maps. Please make sure Google Maps is installed and location services are enabled.';
      } else {
        errorMessage = 'Error opening navigation: $errorMessage';
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  void _navigateToCustomer() async {
    if (!_locationPermissionGranted) {
      _showLocationPermissionDialog();
      return;
    }

    Position positionToUse = _currentPosition ?? _locationService.mockPosition;

    try {
      print('Attempting to open navigation to customer...');
      print('Current position: ${positionToUse.latitude}, ${positionToUse.longitude}');
      print('Customer position: ${_order.customer.lat}, ${_order.customer.lng}');
      
      await NavigationService.openGoogleMapsDirections(
        positionToUse.latitude,
        positionToUse.longitude,
        _order.customer.lat,
        _order.customer.lng,
      );

      NotificationService.showSnackBar(
        context,
        'Opening navigation to customer...',
        backgroundColor: Colors.blue,
      );

      // For development/testing: simulate arrival after navigation
      // This allows developers to test the flow without real GPS
      Future.delayed(const Duration(seconds: 3), () {
        NotificationService.showSnackBar(
          context,
          'For testing: You can now tap "Arrived at Customer"',
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 5),
        );
      });
    } catch (e) {
      String errorMessage = e.toString();
      print('Navigation error: $errorMessage'); // Debug log
      
      if (errorMessage.contains('Could not open Google Maps')) {
        errorMessage = 'Could not open Google Maps. Please make sure Google Maps is installed and location services are enabled.';
      } else {
        errorMessage = 'Error opening navigation: $errorMessage';
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  bool _canArriveAtRestaurant() {
    // For development/testing: Allow manual override when no location permission
    if (!_locationPermissionGranted) {
      // Show a dialog to allow manual confirmation for testing
      return true;
    }

    Position positionToUse = _currentPosition ?? _locationService.mockPosition;

    return _locationService.calculateDistance(
          positionToUse.latitude,
          positionToUse.longitude,
          _order.restaurant.lat,
          _order.restaurant.lng,
        ) <=
        50.0;
  }

  bool _canArriveAtCustomer() {
    // For development/testing: Allow manual override when no location permission
    if (!_locationPermissionGranted || _locationPermissionGranted) {
      // Show a dialog to allow manual confirmation for testing
      return true;
    }

    Position positionToUse = _currentPosition ?? _locationService.mockPosition;

    return _locationService.calculateDistance(
          positionToUse.latitude,
          positionToUse.longitude,
          _order.customer.lat,
          _order.customer.lng,
        ) <=
        50.0;
  }

  void _viewOrderHistory() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OrderHistoryScreen(orderHistory: _orderHistory),
      ),
    );
  }

  void _showProfileMenu() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              // Profile header
              Row(
                children: [
                  const CircleAvatar(
                    radius: 30,
                    backgroundColor: Color(0xFF4CAF50),
                    child: Icon(
                      Icons.person,
                      size: 30,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Driver Name',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'NeuePowerTrial',
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'driver@yolo.com',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                          fontFamily: 'NeueMontreal',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 10),
              // Menu items
              ListTile(
                leading: const Icon(Icons.history, color: Color(0xFF2196F3)),
                title: const Text(
                  'Order History',
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'NeueMontreal',
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _viewOrderHistory();
                },
              ),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text(
                  'Sign Out',
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'NeueMontreal',
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/',
                    (route) => false,
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    Position positionToUse = _currentPosition ?? _locationService.mockPosition;

    return Scaffold(
      key: _scaffoldKey,
      body: Stack(
        children: [
          // Main content
          SingleChildScrollView(
            padding:
                const EdgeInsets.only(top: 90, left: 16, right: 16, bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Order details card with improved styling
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Order ID:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                fontFamily: 'NeuePowerTrial',
                              ),
                            ),
                            Text(
                              _order.orderId,
                              style: const TextStyle(
                                fontSize: 18,
                                fontFamily: 'NeuePowerTrial',
                                color: Color(0xFF4CAF50),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Divider(),
                        const SizedBox(height: 12),
                        const Text(
                          'Restaurant',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            fontFamily: 'NeuePowerTrial',
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _order.restaurant.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontFamily: 'NeueMontreal',
                          ),
                        ),
                        Text(
                          'Lat: ${_order.restaurant.lat.toStringAsFixed(4)}, '
                          'Lng: ${_order.restaurant.lng.toStringAsFixed(4)}',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                            fontFamily: 'NeueMontreal',
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Customer',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            fontFamily: 'NeuePowerTrial',
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _order.customer.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontFamily: 'NeueMontreal',
                          ),
                        ),
                        Text(
                          'Lat: ${_order.customer.lat.toStringAsFixed(4)}, '
                          'Lng: ${_order.customer.lng.toStringAsFixed(4)}',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                            fontFamily: 'NeueMontreal',
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Divider(),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Amount:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                fontFamily: 'NeuePowerTrial',
                              ),
                            ),
                            Text(
                              '₹${_order.amount.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF4CAF50),
                                fontFamily: 'NeuePowerTrial',
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Driver location and distances card with improved styling
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Your Location',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            fontFamily: 'NeuePowerTrial',
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _currentPosition != null
                              ? 'Lat: ${positionToUse.latitude.toStringAsFixed(4)}, '
                                  'Lng: ${positionToUse.longitude.toStringAsFixed(4)}'
                              : 'Lat: ${positionToUse.latitude.toStringAsFixed(4)}, '
                                  'Lng: ${positionToUse.longitude.toStringAsFixed(4)} (Mock Location)',
                          style: const TextStyle(
                            fontSize: 16,
                            fontFamily: 'NeueMontreal',
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Distance to Restaurant: ${_distanceToRestaurant.toStringAsFixed(0)} m',
                          style: TextStyle(
                            fontSize: 16,
                            fontFamily: 'NeueMontreal',
                            color: _distanceToRestaurant <= 50
                                ? Colors.green
                                : Colors.orange,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Distance to Customer: ${_distanceToCustomer.toStringAsFixed(0)} m',
                          style: TextStyle(
                            fontSize: 16,
                            fontFamily: 'NeueMontreal',
                            color: _distanceToCustomer <= 50
                                ? Colors.green
                                : Colors.orange,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (!_locationPermissionGranted)
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.orange.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.orange),
                            ),
                            child: const Row(
                              children: [
                                Icon(
                                  Icons.warning,
                                  color: Colors.orange,
                                  size: 20,
                                ),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Location permission not granted. Geofencing features are disabled. For testing, buttons will be enabled.',
                                    style: TextStyle(
                                      fontFamily: 'NeueMontreal',
                                      color: Colors.orange,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Order status with improved visibility
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 2,
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Order Progress',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            fontFamily: 'NeuePowerTrial',
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 16),
                        OrderStatusWidget(orderStatus: _order.status),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Action buttons with improved styling
                Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: _order.status == OrderStatus.assigned
                            ? () => _updateOrderStatus(OrderStatus.tripStarted)
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2196F3),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 3,
                          textStyle: const TextStyle(
                            fontFamily: 'NeuePowerTrial',
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        child: const Text('Start Trip'),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 50,
                            child: ElevatedButton(
                              onPressed:
                                  _order.status == OrderStatus.tripStarted
                                      ? _navigateToRestaurant
                                      : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey[700],
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                textStyle: const TextStyle(
                                  fontFamily: 'NeueMontreal',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              child: const Text('Navigate to Restaurant'),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: SizedBox(
                            height: 50,
                            child: ElevatedButton(
                              onPressed:
                                  _order.status == OrderStatus.tripStarted &&
                                          _canArriveAtRestaurant()
                                      ? () => _updateOrderStatus(
                                          OrderStatus.arrivedAtRestaurant)
                                      : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _canArriveAtRestaurant()
                                    ? const Color(0xFF4CAF50)
                                    : Colors.grey[400],
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                textStyle: const TextStyle(
                                  fontFamily: 'NeuePowerTrial',
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              child: const Text('Arrived at Restaurant'),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed:
                            _order.status == OrderStatus.arrivedAtRestaurant
                                ? () => _updateOrderStatus(OrderStatus.pickedUp)
                                : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 3,
                          textStyle: const TextStyle(
                            fontFamily: 'NeuePowerTrial',
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        child: const Text('Picked Up'),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 50,
                            child: ElevatedButton(
                              onPressed: _order.status == OrderStatus.pickedUp
                                  ? _navigateToCustomer
                                  : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey[700],
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                textStyle: const TextStyle(
                                  fontFamily: 'NeueMontreal',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              child: const Text('Navigate to Customer'),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: SizedBox(
                            height: 50,
                            child: ElevatedButton(
                              onPressed:
                                  _order.status == OrderStatus.pickedUp &&
                                          _canArriveAtCustomer()
                                      ? () => _updateOrderStatus(
                                          OrderStatus.arrivedAtCustomer)
                                      : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _canArriveAtCustomer()
                                    ? const Color(0xFF4CAF50)
                                    : Colors.grey[400],
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                textStyle: const TextStyle(
                                  fontFamily: 'NeuePowerTrial',
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              child: const Text('Arrived at Customer'),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: _order.status ==
                                OrderStatus.arrivedAtCustomer
                            ? () => _updateOrderStatus(OrderStatus.delivered)
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 3,
                          textStyle: const TextStyle(
                            fontFamily: 'NeuePowerTrial',
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        child: const Text('Delivered'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Location update status
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _isLocationUpdating
                        ? Colors.green.withOpacity(0.1)
                        : Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _isLocationUpdating ? Colors.green : Colors.red,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _isLocationUpdating
                            ? Icons.location_on
                            : Icons.location_off,
                        color: _isLocationUpdating ? Colors.green : Colors.red,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _isLocationUpdating
                            ? 'Location updating every 10s'
                            : 'Location updates stopped',
                        style: TextStyle(
                          fontSize: 14,
                          fontFamily: 'NeueMontreal',
                          color:
                              _isLocationUpdating ? Colors.green : Colors.red,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
          // Custom app bar with improved theme and fixed overflow
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 90,
              decoration: const BoxDecoration(
                color:
                    Color(0xFF4CAF50), // Solid green color instead of gradient
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.only(top: 25, left: 16, right: 16),
                child: Row(
                  children: [
                    // Heading with constrained width to prevent overflow
                    Expanded(
                      child: Text(
                        'Assigned Order',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontFamily: 'NeuePowerTrial',
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    // Notification icon
                    IconButton(
                      icon: const Icon(
                        Icons.notifications,
                        color: Colors.white,
                        size: 24,
                      ),
                      onPressed: () {
                        // Could show notifications here
                      },
                    ),
                    const SizedBox(width: 8),
                    // Profile picture
                    GestureDetector(
                      onTap: _showProfileMenu,
                      child: const CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.white,
                        child: Icon(
                          Icons.person,
                          size: 20,
                          color: Color(0xFF4CAF50),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
