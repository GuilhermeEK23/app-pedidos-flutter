import 'package:app_colono/components/list_product_widget.dart';
import 'package:app_colono/models/product_model.dart';
import 'package:app_colono/services/product_service.dart';
import 'package:flutter/material.dart';

class ProductScreen extends StatefulWidget {
  final bool isAdmin;
  final List<ProductModel>? listProducts;

  const ProductScreen({super.key, this.listProducts, required this.isAdmin});

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  late String filter;
  late List<ProductModel> filteredProducts;
  final TextEditingController _searchController = TextEditingController();
  final ProductService productService = ProductService();

  @override
  void initState() {
    super.initState();
    filteredProducts = widget.listProducts ?? [];
  }

  @override
  void didUpdateWidget(covariant ProductScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.listProducts != widget.listProducts) {
      filteredProducts = widget.listProducts!;
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  List<ProductModel> filteredProductsWithFilter(String filter) {
    return widget.listProducts!
        .where((product) =>
            product.description.toLowerCase().contains(filter.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextFormField(
            controller: _searchController,
            onChanged: (value) {
              setState(() {
                filter = value;
                filteredProducts = filteredProductsWithFilter(filter);
              });
            },
            decoration: const InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(25),
                ),
              ),
              hintText: "pesquisar",
              suffixIcon: Icon(Icons.search),
            ),
          ),
        ),
        Expanded(
          child: ListView(
            children: List.generate(filteredProducts.length, (index) {
              ProductModel product = filteredProducts[index];
              return ListProductWidget(
                product: product,
                productService: productService,
                isAdmin: widget.isAdmin,
              );
            }),
          ),
        ),
      ],
    );
  }
}
