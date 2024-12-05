import 'package:app_colono/models/product_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OrderModel {
  String id;
  String client;
  String address;
  double value;
  String userId;
  Timestamp createAt;
  String? deliveryDate; // Data da entrega, formato "YYYY-MM-DD"
  String? deliveryTime; // Horário da entrega, exemplo: "9hr - 10hr"
  String status;
  List<ProductModel> products;

  OrderModel({
    required this.id,
    required this.client,
    required this.address,
    required this.value,
    required this.userId,
    required this.createAt,
    required this.status,
    required this.products,
  });

  OrderModel.fromMap(Map<String, dynamic> map)
      : id = map["id"],
        client = map["client"],
        address = map["address"],
        value = map["value"],
        userId = map["userId"],
        createAt = map["createAt"],
        deliveryDate = map["deliveryDate"],
        deliveryTime = map["deliveryTime"],
        status = map["status"],
        products = [];

  // Converte para um formato compatível com o Firebase
  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "client": client,
      "address": address,
      "value": value,
      "userId": userId,
      "createAt": createAt,
      "deliveryDate": deliveryDate,
      "deliveryTime": deliveryTime,
      "status": status,
    };
  }
}
