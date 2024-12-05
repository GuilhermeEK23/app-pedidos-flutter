import 'package:app_colono/_common/my_colors.dart';
import 'package:app_colono/components/cart_provider.dart';
import 'package:app_colono/models/product_model.dart';
import 'package:app_colono/services/product_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

showModalProduct(
    BuildContext context, ProductService productService, bool isEditingProductCart,
    {ProductModel? product}) {
  showModalBottomSheet(
    context: context,
    backgroundColor: MyColors.primaryColor,
    isDismissible: false,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(32),
      ),
    ),
    builder: (context) {
      return ModalProduct(
        product: product,
        productService: productService,
        isEditingProductCart: isEditingProductCart,
      );
    },
  );
}

class ModalProduct extends StatefulWidget {
  final ProductModel? product;
  final ProductService productService;
  final bool isEditingProductCart;

  const ModalProduct(
      {super.key,
      this.product,
      required this.productService,
      required this.isEditingProductCart});

  @override
  State<ModalProduct> createState() => _ModalProductState();
}

class _ModalProductState extends State<ModalProduct> {
  final NumberFormat real = NumberFormat.currency(locale: 'pt_BR', name: 'R\$');
  bool isLoading = false;
  bool isLoadingRemove = false;
  bool isEditingCart = false;
  String textButton = "Adicionar no carrinho";
  int quantity = 1; // Quantidade inicial do produto

  @override
  void initState() {
    if (widget.isEditingProductCart) {
      quantity = widget.product!.quantity ?? 1;
      textButton = "Salvar";
      isEditingCart = true;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      height: isEditingCart
          ? MediaQuery.of(context).size.height * 0.9
          : MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header com título e botão de fechar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Detalhes do Produto",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close, color: Colors.black),
              ),
            ],
          ),
          const Divider(),
          // Imagem do produto
          SizedBox(
            height: 200,
            child: (widget.product?.imagePath != null)
                ? Image.asset(
                    widget.product!.imagePath!,
                    fit: BoxFit.cover,
                  )
                : const Icon(
                    Icons.photo,
                    size: 100,
                  ),
          ),
          const SizedBox(height: 16),
          // Nome do produto
          Text(
            widget.product?.description ?? '',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          // Preço unitário do produto
          Text(
            "Preço: ${real.format(widget.product?.price ?? 0)}",
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          // Seção de quantidade e cálculo de total
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: () {
                  if (quantity > 1) {
                    setState(() {
                      quantity--;
                    });
                  }
                },
                icon: const Icon(Icons.remove_circle,
                    color: MyColors.primaryColor),
              ),
              Text(
                quantity.toString(),
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    quantity++;
                  });
                },
                icon:
                    const Icon(Icons.add_circle, color: MyColors.primaryColor),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Exibe o total calculado
          Text(
            "Total: ${real.format((widget.product?.price ?? 0) * quantity)}",
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: MyColors.primaryColor,
            ),
          ),
          const Spacer(),
          // Botão de remover do carrinho
          isEditingCart
              ? ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[300],
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: () => handleRemoveCart(),
                  child: (isLoadingRemove)
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          "Remover do Carrinho",
                          style: TextStyle(fontSize: 18, color: Colors.black),
                        ),
                )
              : const SizedBox(height: 0),
          // Botão de adicionar ao carrinho
          const Spacer(),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: MyColors.primaryColorLight,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            onPressed: () => handleSendCart(quantity),
            child: (isLoading)
                ? const CircularProgressIndicator(color: Colors.white)
                : Text(
                    textButton,
                    style: const TextStyle(fontSize: 18, color: Colors.black),
                  ),
          ),
        ],
      ),
    );
  }

  handleSendCart(int quantity) async {
    if (widget.product == null) return;

    setState(() {
      isLoading = true;
    });

    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    ProductModel product = widget.product!;
    product.quantity = quantity;
    if (isEditingCart) {
      cartProvider.editProduct(product);
    } else {
      cartProvider.addProduct(product);
    }

    setState(() {
      isLoading = false;
    });

    Navigator.pop(context);
  }

  handleRemoveCart() async {
    if (widget.product == null) return;

    setState(() {
      isLoadingRemove = true;
    });

    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    ProductModel product = widget.product!;
    cartProvider.removeProduct(product);

    setState(() {
      isLoadingRemove = false;
    });

    Navigator.pop(context);
  }
}
