import 'package:app_colono/models/order_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class OrderService {
  String userId;
  OrderService() : userId = FirebaseAuth.instance.currentUser!.uid;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addOrder(OrderModel order) async {
    DocumentReference orderRef = _firestore.collection("orders").doc(order.id);

    await orderRef.set(order.toMap());

    for (var product in order.products) {
      await orderRef
          .collection("products")
          .doc(product.id)
          .set(product.toMap());
    }
  }

  Future<void> updateOrderStatus(String idOrder, String newStatus) async {
    DocumentReference orderRef = _firestore.collection("orders").doc(idOrder);

    orderRef.update({
      'status': newStatus,
    });
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> connectStreamOrders() {
    return _firestore.collection("orders").snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> connectStreamOrdersProducts(
      String idOrder) {
    return _firestore
        .collection("orders")
        .doc(idOrder)
        .collection("products")
        .snapshots();
  }

  Future<OrderModel?> getLastOrderClient(String userId) async {
    try {
      QuerySnapshot<Map<String, dynamic>> snapshot = await _firestore
          .collection("orders")
          .where('userId', isEqualTo: userId)
          .get();
      if (snapshot.docs.isEmpty) {
        return null;
      }
      return OrderModel.fromMap(snapshot.docs.first.data());
    } catch (e) {
      return null;
    }
  }

  Future<int> getTotalOrders() async {
    int total = 0;
    try {
      final snapshot = await _firestore.collection("orders").get();
      total = snapshot.size; // Retorna a quantidade de documentos na coleção
    } catch (e) {
      return 0; // Retorna 0 em caso de erro
    }
    return total;
  }

  Future<double> getTotalSales() async {
    double total = 0.0;
    try {
      final snapshot = await _firestore
          .collection("orders")
          .where('status', isEqualTo: "CONCLUIDO")
          .get();
      for (var order in snapshot.docs) {
        total += order.data()['value'] as double;
      }
    } catch (e) {
      return 0.0; // Retorna 0.0 em caso de erro
    }
    return total;
  }

  Future<int> getTotalOrdersUser(String userId) async {
    int total = 0;
    try {
      final snapshot = await _firestore
          .collection("orders")
          .where('userId', isEqualTo: userId)
          .get();
      total = snapshot.size; // Retorna a quantidade de documentos na coleção
    } catch (e) {
      return 0; // Retorna 0 em caso de erro
    }
    return total;
  }

  Future<double> getTotalSpent(String userId) async {
    double total = 0.0;
    try {
      final snapshot = await _firestore
          .collection("orders")
          .where('status', isNotEqualTo: "CANCELADO")
          .where('userId', isEqualTo: userId)
          .get();
      if (snapshot.docs.isEmpty) {
        return 0.0;
      }
      for (var order in snapshot.docs) {
        // Verifica se o campo 'value' existe e é numérico
        final value = order.data()['value'];
        if (value is double || value is int) {
          total += value.toDouble();
        } else {}
      }
    } catch (e) {
      return 0.0; // Retorna 0.0 em caso de erro
    }
    return total;
  }
}
