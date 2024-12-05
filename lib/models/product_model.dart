class ProductModel {
  String id;
  String description;
  String categorie;
  double price;
  int? quantity;
  double? stock;
  String? imagePath;

  ProductModel({
    required this.id,
    required this.description,
    required this.categorie,
    required this.price,
    this.quantity,
    this.stock,
    this.imagePath,
  });

  ProductModel.fromMap(Map<String, dynamic> map)
      : id = map["id"],
        description = map["description"],
        categorie = map["categorie"],
        price = map["price"],
        quantity = map["quantity"],
        stock = map["stock"],
        imagePath = map["imagePath"];

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "description": description,
      "categorie": categorie,
      "price": price,
      "quantity": quantity,
      "stock": stock,
      "imagePath": imagePath,
    };
  }
}
