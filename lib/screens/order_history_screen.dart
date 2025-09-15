import 'package:flutter/material.dart';
import 'package:yolo/models/order.dart';

class OrderHistoryScreen extends StatefulWidget {
  final List<Order> orderHistory;

  const OrderHistoryScreen({super.key, required this.orderHistory});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  // Track which orders are expanded
  final Set<int> _expandedOrders = <int>{};

  void _toggleExpansion(int index) {
    setState(() {
      if (_expandedOrders.contains(index)) {
        _expandedOrders.remove(index);
      } else {
        _expandedOrders.add(index);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order History', style: TextStyle(color: Colors.white),),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: widget.orderHistory.isEmpty
          ? const Center(
              child: Text(
                'No order history yet',
                style: TextStyle(
                  fontSize: 18,
                  fontFamily: 'NeueMontreal',
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: widget.orderHistory.length,
              itemBuilder: (context, index) {
                final order = widget.orderHistory[index];
                final isExpanded = _expandedOrders.contains(index);
                
                return Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: InkWell(
                    onTap: () => _toggleExpansion(index),
                    borderRadius: BorderRadius.circular(16),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                order.orderId,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  fontFamily: 'NeuePowerTrial',
                                  color: Color(0xFF4CAF50),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.green.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Text(
                                  'Delivered',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: Colors.green,
                                    fontFamily: 'NeueMontreal',
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const Divider(),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              const Icon(
                                Icons.store,
                                color: Colors.blue,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  order.restaurant.name,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontFamily: 'NeueMontreal',
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(
                                Icons.person,
                                color: Colors.purple,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  order.customer.name,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontFamily: 'NeueMontreal',
                                  ),
                                ),
                              ),
                            ],
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
                                  fontSize: 16,
                                  fontFamily: 'NeuePowerTrial',
                                ),
                              ),
                              Text(
                                '₹${order.amount.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF4CAF50),
                                  fontFamily: 'NeuePowerTrial',
                                ),
                              ),
                            ],
                          ),
                          // Expandable content
                          if (isExpanded) ...[
                            const SizedBox(height: 12),
                            const Divider(),
                            const SizedBox(height: 12),
                            const Text(
                              'Order Details',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                fontFamily: 'NeuePowerTrial',
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Text(
                                  'Restaurant Location:',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'NeueMontreal',
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Lat: ${order.restaurant.lat.toStringAsFixed(4)}, '
                                  'Lng: ${order.restaurant.lng.toStringAsFixed(4)}',
                                  style: const TextStyle(
                                    fontFamily: 'NeueMontreal',
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Text(
                                  'Customer Location:',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'NeueMontreal',
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Lat: ${order.customer.lat.toStringAsFixed(4)}, '
                                  'Lng: ${order.customer.lng.toStringAsFixed(4)}',
                                  style: const TextStyle(
                                    fontFamily: 'NeueMontreal',
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Text(
                                  'Delivered:',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'NeueMontreal',
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  order.deliveredTime != null
                                      ? '${order.deliveredTime!.day}/${order.deliveredTime!.month}/${order.deliveredTime!.year} at ${order.deliveredTime!.hour}:${order.deliveredTime!.minute.toString().padLeft(2, '0')}'
                                      : 'N/A',
                                  style: const TextStyle(
                                    fontFamily: 'NeueMontreal',
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ],
                          // Expansion indicator
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                isExpanded ? 'Show Less' : 'Show More',
                                style: const TextStyle(
                                  color: Color(0xFF2196F3),
                                  fontFamily: 'NeueMontreal',
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Icon(
                                isExpanded ? Icons.expand_less : Icons.expand_more,
                                color: const Color(0xFF2196F3),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}