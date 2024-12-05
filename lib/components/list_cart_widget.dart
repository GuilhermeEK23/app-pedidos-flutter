import 'package:app_colono/_common/modal_product.dart';
import 'package:app_colono/models/product_model.dart';
import 'package:app_colono/services/product_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ListCartWidget extends StatelessWidget {
  final ProductModel product;

  const ListCartWidget({
    super.key,
    required this.product,
  });

  @override
  Widget build(BuildContext context) {
    final NumberFormat currencyFormat = NumberFormat.currency(locale: 'pt_BR', name: 'R\$');
    final ProductService productService = ProductService();

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ElevatedButton(
        style: const ButtonStyle(elevation: WidgetStatePropertyAll(0)),
        onPressed: () {
          showModalProduct(context, productService, product: product, true);
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Imagem do Produto
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.grey[200],
                ),
                child: (product.imagePath != null)
                    ? Image.asset(
                        product.imagePath!,
                        fit: BoxFit.cover,
                      )
                    : const Icon(
                        Icons.photo,
                        size: 50,
                        color: Colors.grey,
                      ),
              ),
              const SizedBox(width: 16),
              // Detalhes do Produto
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nome do Produto
                    Text(
                      product.description,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Categoria
                    Text(
                      "Categoria: ${product.categorie}",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Preço Unitário e Quantidade
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Preço Unitário
                        Text(
                          "Preço: ${currencyFormat.format(product.price)}",
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.blueGrey,
                          ),
                        ),
                        // Quantidade
                        Text(
                          "Qtd: ${product.quantity}",
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Total do Produto
                    Text(
                      "Total: ${currencyFormat.format(product.price * product.quantity!)}",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
