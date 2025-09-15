import 'package:flutter/material.dart';
import 'package:yolo/models/order.dart';

class OrderStatusWidget extends StatelessWidget {
  final OrderStatus orderStatus;

  const OrderStatusWidget({super.key, required this.orderStatus});

  @override
  Widget build(BuildContext context) {
    final statusInfo = _getStatusInfo(orderStatus);

    return Card(
      color: statusInfo.color.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  statusInfo.icon,
                  color: statusInfo.color,
                ),
                const SizedBox(width: 8),
                Text(
                  statusInfo.title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: statusInfo.color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              statusInfo.description,
              style: const TextStyle(
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  ({String title, String description, IconData icon, Color color}) _getStatusInfo(
      OrderStatus status) {
    switch (status) {
      case OrderStatus.assigned:
        return (
          title: 'Order Assigned',
          description: 'Your order has been assigned. Tap "Start Trip" to begin.',
          icon: Icons.assignment,
          color: Colors.blue
        );
      case OrderStatus.tripStarted:
        return (
          title: 'Trip Started',
          description:
              'You\'re on your way to the restaurant. Use navigation to reach the destination.',
          icon: Icons.directions_car,
          color: Colors.orange
        );
      case OrderStatus.arrivedAtRestaurant:
        return (
          title: 'Arrived at Restaurant',
          description: 'You\'ve reached the restaurant. Please pick up the order.',
          icon: Icons.store,
          color: Colors.green
        );
      case OrderStatus.pickedUp:
        return (
          title: 'Order Picked Up',
          description: 'You\'ve picked up the order. Head to the customer location.',
          icon: Icons.shopping_bag,
          color: Colors.purple
        );
      case OrderStatus.arrivedAtCustomer:
        return (
          title: 'Arrived at Customer',
          description: 'You\'ve reached the customer. Please deliver the order.',
          icon: Icons.home,
          color: Colors.green
        );
      case OrderStatus.delivered:
        return (
          title: 'Order Delivered',
          description: 'Order successfully delivered! Thank you for using Yolo.',
          icon: Icons.check_circle,
          color: Colors.green
        );
    }
  }
}