import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:yolo/models/order.dart';
import 'package:yolo/services/location_service.dart';
import 'package:yolo/services/navigation_service.dart';
import 'package:yolo/widgets/yolo_logo.dart';
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

  @override
  void initState() {
    super.initState();
    _initializeOrder();
    _startLocationUpdates();
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
  }

  void _navigateToRestaurant() async {
    Position positionToUse = _currentPosition ?? _locationService.mockPosition;
    
    try {
      await NavigationService.openGoogleMapsDirections(
        positionToUse.latitude,
        positionToUse.longitude,
        _order.restaurant.lat,
        _order.restaurant.lng,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error opening navigation: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _navigateToCustomer() async {
    Position positionToUse = _currentPosition ?? _locationService.mockPosition;
    
    try {
      await NavigationService.openGoogleMapsDirections(
        positionToUse.latitude,
        positionToUse.longitude,
        _order.customer.lat,
        _order.customer.lng,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error opening navigation: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  bool _canArriveAtRestaurant() {
    Position positionToUse = _currentPosition ?? _locationService.mockPosition;
    
    return _locationService.calculateDistance(
          positionToUse.latitude,
          positionToUse.longitude,
          _order.restaurant.lat,
          _order.restaurant.lng,
        ) <= 50.0;
  }

  bool _canArriveAtCustomer() {
    Position positionToUse = _currentPosition ?? _locationService.mockPosition;
    
    return _locationService.calculateDistance(
          positionToUse.latitude,
          positionToUse.longitude,
          _order.customer.lat,
          _order.customer.lng,
        ) <= 50.0;
  }

  @override
  Widget build(BuildContext context) {
    Position positionToUse = _currentPosition ?? _locationService.mockPosition;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Assigned Order'),
        leading: const YoloLogo(size: 30),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/',
                (route) => false,
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order details
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
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
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          _order.orderId,
                          style: const TextStyle(
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Divider(),
                    const SizedBox(height: 8),
                    const Text(
                      'Restaurant',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(_order.restaurant.name),
                    Text(
                      'Lat: ${_order.restaurant.lat.toStringAsFixed(4)}, '
                      'Lng: ${_order.restaurant.lng.toStringAsFixed(4)}',
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Customer',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(_order.customer.name),
                    Text(
                      'Lat: ${_order.customer.lat.toStringAsFixed(4)}, '
                      'Lng: ${_order.customer.lng.toStringAsFixed(4)}',
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Divider(),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Amount:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          '₹${_order.amount.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Driver location and distances
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Your Location',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _currentPosition != null
                          ? 'Lat: ${positionToUse.latitude.toStringAsFixed(4)}, '
                              'Lng: ${positionToUse.longitude.toStringAsFixed(4)}'
                          : 'Lat: ${positionToUse.latitude.toStringAsFixed(4)}, '
                              'Lng: ${positionToUse.longitude.toStringAsFixed(4)} (Mock Location)',
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Distance to Restaurant: ${_distanceToRestaurant.toStringAsFixed(0)} m',
                      style: TextStyle(
                        color: _distanceToRestaurant <= 50 ? Colors.green : Colors.orange,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Distance to Customer: ${_distanceToCustomer.toStringAsFixed(0)} m',
                      style: TextStyle(
                        color: _distanceToCustomer <= 50 ? Colors.green : Colors.orange,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Order status
            OrderStatusWidget(orderStatus: _order.status),
            const SizedBox(height: 16),
            // Action buttons
            Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _order.status == OrderStatus.assigned
                        ? () => _updateOrderStatus(OrderStatus.tripStarted)
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.all(16),
                    ),
                    child: const Text('Start Trip'),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _order.status == OrderStatus.tripStarted
                            ? _navigateToRestaurant
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[700],
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Navigate to Restaurant'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _order.status == OrderStatus.tripStarted &&
                                _canArriveAtRestaurant()
                            ? () => _updateOrderStatus(OrderStatus.arrivedAtRestaurant)
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _canArriveAtRestaurant()
                              ? Colors.green
                              : Colors.grey[400],
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Arrived at Restaurant'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _order.status == OrderStatus.arrivedAtRestaurant
                        ? () => _updateOrderStatus(OrderStatus.pickedUp)
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Picked Up'),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _order.status == OrderStatus.pickedUp
                            ? _navigateToCustomer
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[700],
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Navigate to Customer'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _order.status == OrderStatus.pickedUp &&
                                _canArriveAtCustomer()
                            ? () => _updateOrderStatus(OrderStatus.arrivedAtCustomer)
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _canArriveAtCustomer()
                              ? Colors.green
                              : Colors.grey[400],
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Arrived at Customer'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _order.status == OrderStatus.arrivedAtCustomer
                        ? () => _updateOrderStatus(OrderStatus.delivered)
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Delivered'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Location update status
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _isLocationUpdating ? Icons.location_on : Icons.location_off,
                  color: _isLocationUpdating ? Colors.green : Colors.red,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  _isLocationUpdating
                      ? 'Location updating every 10s'
                      : 'Location updates stopped',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}