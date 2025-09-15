class Order {
  final String orderId;
  final Restaurant restaurant;
  final Customer customer;
  final double amount;
  final OrderStatus status;

  Order({
    required this.orderId,
    required this.restaurant,
    required this.customer,
    required this.amount,
    this.status = OrderStatus.assigned,
  });

  Order copyWith({
    String? orderId,
    Restaurant? restaurant,
    Customer? customer,
    double? amount,
    OrderStatus? status,
  }) {
    return Order(
      orderId: orderId ?? this.orderId,
      restaurant: restaurant ?? this.restaurant,
      customer: customer ?? this.customer,
      amount: amount ?? this.amount,
      status: status ?? this.status,
    );
  }
}

class Restaurant {
  final String name;
  final double lat;
  final double lng;

  Restaurant({
    required this.name,
    required this.lat,
    required this.lng,
  });
}

class Customer {
  final String name;
  final double lat;
  final double lng;

  Customer({
    required this.name,
    required this.lat,
    required this.lng,
  });
}

enum OrderStatus {
  assigned,
  tripStarted,
  arrivedAtRestaurant,
  pickedUp,
  arrivedAtCustomer,
  delivered,
}