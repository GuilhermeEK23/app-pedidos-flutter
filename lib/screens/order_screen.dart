import 'package:app_colono/components/list_orders_widget.dart';
import 'package:app_colono/models/order_model.dart';
import 'package:app_colono/services/order_service.dart';
import 'package:flutter/material.dart';

class OrderScreen extends StatefulWidget {
  final List<OrderModel> listOrders;

  const OrderScreen(
      {super.key, required this.listOrders});

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  late List<OrderModel> filteredOrders;
  final OrderService orderService = OrderService();

  @override
  void initState() {
    super.initState();
    filteredOrders = widget.listOrders;
  }

  @override
  void didUpdateWidget(covariant OrderScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.listOrders != widget.listOrders) {
      filteredOrders = widget.listOrders;
    }
  }

  @override void dispose() {
    super.dispose();
  }

  List<OrderModel> filteredOrdersWithFilter(String filter) {
    return widget.listOrders.where((order) => order.status == filter).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              const Text("Filtrar por"),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    filteredOrders = filteredOrdersWithFilter("CONCLUIDO");
                  });
                },
                style: ButtonStyle(
                  padding: WidgetStateProperty.all(const EdgeInsets.all(8)),
                ),
                child: const Column(
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 20,
                    ),
                    Text(
                      "Concluído",
                      style: TextStyle(fontSize: 10, color: Colors.black),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    filteredOrders = filteredOrdersWithFilter("CANCELADO");
                  });
                },
                style: ButtonStyle(
                  padding: WidgetStateProperty.all(const EdgeInsets.all(8)),
                ),
                child: const Column(
                  children: [
                    Icon(
                      Icons.cancel,
                      color: Colors.red,
                      size: 20,
                    ),
                    Text(
                      "Cancelado",
                      style: TextStyle(fontSize: 10, color: Colors.black),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    filteredOrders = filteredOrdersWithFilter("PENDENTE");
                  });
                },
                style: ButtonStyle(
                  padding: WidgetStateProperty.all(const EdgeInsets.all(8)),
                ),
                child: const Column(
                  children: [
                    Icon(
                      Icons.pending,
                      color: Colors.orange,
                      size: 20,
                    ),
                    Text(
                      "Pendente",
                      style: TextStyle(fontSize: 10, color: Colors.black),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            children: List.generate(filteredOrders.length, (index) {
              OrderModel order = filteredOrders[index];
              return ListOrdersWidget(
                order: order,
                orderService: orderService,
              );
            }),
          ),
        ),
      ],
    );
  }
}
