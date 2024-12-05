import 'package:app_colono/models/order_model.dart';
import 'package:app_colono/models/product_model.dart';
import 'package:app_colono/services/order_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class OrderDetailsScreen extends StatefulWidget {
  final OrderModel order;
  final OrderService orderService;

  const OrderDetailsScreen({
    super.key,
    required this.order,
    required this.orderService,
  });

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  final NumberFormat real = NumberFormat.currency(locale: 'pt_BR', name: 'R\$');
  late String selectedStatus;

  @override
  void initState() {
    super.initState();
    selectedStatus = widget.order.status;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Detalhes do Pedido"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Cliente: ${widget.order.client}",
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text("Endereço: ${widget.order.address}"),
            Text(
                "Data de Entrega: ${widget.order.deliveryDate ?? 'Não definida'}"),
            Text(
                "Horário de Entrega: ${widget.order.deliveryTime ?? 'Não definido'}"),
            const SizedBox(height: 16),
            const Text("Produtos:",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Expanded(
              child: StreamBuilder(
                stream: widget.orderService
                    .connectStreamOrdersProducts(widget.order.id),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  } else {
                    List<ProductModel> products = [];

                    for (var element in snapshot.data!.docs) {
                      products.add(ProductModel.fromMap(element.data()));
                    }

                    return ListView.builder(
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        ProductModel product = products[index];
                        return ListTile(
                          title: Text(product.description),
                          subtitle: Text("Quantidade: ${product.quantity}"),
                          trailing: Text(real.format(product.price)),
                        );
                      },
                    );
                  }
                },
              ),
            ),
            const SizedBox(height: 16),
            Text("Total do Pedido: ${real.format(widget.order.value)}",
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text("Status: "),
                const SizedBox(width: 8),
                DropdownButton<String>(
                  value: selectedStatus,
                  items: ["CONCLUIDO", "CANCELADO", "PENDENTE"]
                      .map((status) =>
                          DropdownMenuItem(value: status, child: Text(status)))
                      .toList(),
                  onChanged: (String? newStatus) {
                    if (newStatus != null) {
                      setState(() {
                        selectedStatus = newStatus;
                      });
                      widget.orderService
                          .updateOrderStatus(widget.order.id, newStatus);
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
