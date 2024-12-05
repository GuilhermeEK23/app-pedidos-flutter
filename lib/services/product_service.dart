import 'package:app_colono/models/product_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProductService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addProduct(ProductModel product) async {
    return await _firestore
        .collection("products")
        .doc(product.id)
        .set(product.toMap());
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> connectStreamProducts() {
    return _firestore.collection("products").snapshots();
  }

  Future<void> removeProduct({required String idProduct}) {
    return _firestore.collection("products").doc(idProduct).delete();
  }

  Future<int> getTotalProducts() async {
    int total = 0;
    try {
      final snapshot = await _firestore.collection("products").get();
      total = snapshot.size;
    } catch (e) {
      return 0; // Retorna 0 em caso de erro
    }
    return total;
  }

  Future<int> getTotalProductsPurchased(String userId) async {
    int total = 0;
    try {
      final snapshot = await _firestore
          .collection("orders")
          // .where('status', isNotEqualTo: "CANCELADO")
          .where('userId', isEqualTo: userId)
          .get();
      for (var order in snapshot.docs) {
        // Obter a subcoleção de "products" para cada pedido
        final productsSnapshot = await _firestore
            .collection("orders")
            .doc(order.id)
            .collection("products")
            .get();
        if (productsSnapshot.docs.isEmpty) {
          // Se não houver produtos neste pedido, pule para o próximo pedido
          continue;
        }
        for (var product in productsSnapshot.docs) {
          total += product['quantity'] as int;
        }
      }
    } catch (e) {
      return 0; // Retorna 0 em caso de erro
    }
    return total;
  }
}
