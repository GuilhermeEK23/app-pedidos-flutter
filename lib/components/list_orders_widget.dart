import 'package:app_colono/components/order_details_screen.dart';
import 'package:app_colono/models/order_model.dart';
import 'package:app_colono/services/order_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ListOrdersWidget extends StatelessWidget {
  final NumberFormat real = NumberFormat.currency(locale: 'pt_BR', name: 'R\$');
  final OrderModel? order;
  final OrderService orderService;

  ListOrdersWidget({
    super.key,
    required this.order,
    required this.orderService,
  });

  @override
  Widget build(BuildContext context) {
    if (order == null) {
      return const SizedBox(
        child: Text("Você não realizou nenhum pedido ainda"),
      );
    } else {
      // Determina o ícone e a cor do status
      IconData statusIcon;
      Color statusColor;
      switch (order!.status) {
        case "CONCLUIDO":
          statusIcon = Icons.check_circle;
          statusColor = Colors.green;
          break;
        case "CANCELADO":
          statusIcon = Icons.cancel;
          statusColor = Colors.red;
          break;
        case "PENDENTE":
        default:
          statusIcon = Icons.pending;
          statusColor = Colors.orange;
      }

      return Card(
        child: ListTile(
          title: Text(order!.client,
              style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Valor Total: ${real.format(order!.value)}"),
              if (order!.deliveryDate != null)
                Text("Data: ${order!.deliveryDate}"),
            ],
          ),
          trailing: Icon(statusIcon, color: statusColor),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => OrderDetailsScreen(
                    order: order!, orderService: orderService),
              ),
            );
          },
        ),
      );
    }
  }
}
