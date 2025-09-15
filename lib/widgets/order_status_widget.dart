import 'package:flutter/material.dart';
import 'package:yolo/models/order.dart';

class OrderStatusWidget extends StatelessWidget {
  final OrderStatus orderStatus;

  const OrderStatusWidget({super.key, required this.orderStatus});

  @override
  Widget build(BuildContext context) {
    final statusInfo = _getStatusInfo(orderStatus);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: statusInfo.color.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: statusInfo.color.withOpacity(0.1),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: statusInfo.color,
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    statusInfo.icon,
                    color: statusInfo.color,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        statusInfo.title,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: statusInfo.color,
                          fontFamily: 'NeuePowerTrial',
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Status Update',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                          fontFamily: 'NeueMontreal',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: statusInfo.color.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: statusInfo.color.withOpacity(0.2),
                ),
              ),
              child: Text(
                statusInfo.description,
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 16,
                  height: 1.5,
                  fontFamily: 'NeueMontreal',
                ),
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
          description: 'Your order has been assigned. Tap "Start Trip" to begin your delivery.',
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