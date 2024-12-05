import 'package:app_colono/_common/modal_order_confirmation.dart';
import 'package:app_colono/components/cart_provider.dart';
import 'package:app_colono/components/list_cart_widget.dart';
import 'package:app_colono/models/order_model.dart';
import 'package:app_colono/models/user_model.dart';
import 'package:app_colono/services/order_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class CartScreen extends StatefulWidget {
  final UserModel user;
  const CartScreen({super.key, required this.user});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final OrderService _orderService = OrderService();
  OrderModel? lastOrderClient;

  Future<void> _loadLastOrderClient() async {
    lastOrderClient = await _orderService.getLastOrderClient(widget.user.id);
  }

  @override
  void initState() {
    super.initState();
    _loadLastOrderClient();
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    final orderClient = cartProvider.orderClient;
    final OrderService orderService = OrderService();
    final NumberFormat real =
        NumberFormat.currency(locale: 'pt_BR', name: 'R\$');

    orderClient.value = orderClient.products.fold(
      0,
      (sum, product) => sum + (product.price * product.quantity!),
    );
    orderClient.userId = widget.user.id;

    return Padding(
      padding: const EdgeInsets.all(8),
      child: orderClient.products.isNotEmpty
          ? Column(
              children: [
                Expanded(
                  child: ListView(
                    children: List.generate(
                      orderClient.products.length,
                      (index) {
                        return ListCartWidget(
                          product: orderClient.products[index],
                        );
                      },
                    ),
                  ),
                ),
                const Divider(),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text("Total: ${real.format(orderClient.value)}",
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold)),
                ),
                ElevatedButton(
                  onPressed: () => _showOrderConfirmationModal(
                      context, orderClient, orderService),
                  child: const Text("Confirmar Pedido"),
                ),
              ],
            )
          : const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Você não tem nenhum produto no carrinho, Adicione produtos para continuar",
                  textAlign: TextAlign.center,
                ),
              ],
            ),
    );
  }

  void _showOrderConfirmationModal(
      BuildContext context, OrderModel orderClient, OrderService orderService) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (context) {
        orderClient.client = widget.user.name;
        return ModalOrderConfirmation(
          orderClient: orderClient,
          orderService: orderService,
        );
      },
    );
  }
}
