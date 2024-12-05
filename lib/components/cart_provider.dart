import 'package:app_colono/models/order_model.dart';
import 'package:app_colono/models/product_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';


class CartProvider extends ChangeNotifier {
  OrderModel orderClient = OrderModel(
    id: const Uuid().v1(),
    client: "",
    address: "",
    value: 0,
    userId: "",
    createAt: Timestamp.now(),
    status: "PENDENTE",
    products: [],
  );

  void addProduct(ProductModel product) {
    bool productExists = false;

    for (var element in orderClient.products) {
      if (element.id == product.id) {
        productExists = true;
        element.quantity = (element.quantity ?? 0) + (product.quantity ?? 0);
        break;
      }
    }

    if (!productExists) {
      orderClient.products.add(product);
    }

    notifyListeners();
  }

  void editProduct(ProductModel product) {
    for (var element in orderClient.products) {
      if (element.id == product.id) {
        element.quantity = product.quantity ?? 0;
        break;
      }
    }

    notifyListeners();
  }

  void removeProduct(ProductModel product) {
    orderClient.products.removeWhere((element) => (element.id == product.id));

    notifyListeners();
  }

  void finishOrder() async {
    orderClient = OrderModel(
      id: const Uuid().v1(),
      client: "",
      address: "",
      value: 0,
      userId: "",
      createAt: Timestamp.now(),
      status: "PENDENTE",
      products: [],
    );
    notifyListeners(); // Notifica os ouvintes sobre a atualização do pedido
  }
}
