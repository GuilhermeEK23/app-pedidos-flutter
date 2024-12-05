import 'package:app_colono/_common/my_colors.dart';
import 'package:app_colono/components/decoration.dart';
import 'package:app_colono/models/product_model.dart';
import 'package:app_colono/services/product_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';

showModalEditProduct(BuildContext context, ProductService productService,
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
      return ModalEditProduct(
        product: product,
        productService: productService,
      );
    },
  );
}

class ModalEditProduct extends StatefulWidget {
  final ProductModel? product;
  final ProductService productService;
  const ModalEditProduct(
      {super.key, this.product, required this.productService});

  @override
  State<ModalEditProduct> createState() => _ModalEditProductState();
}

class _ModalEditProductState extends State<ModalEditProduct> {
  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _categorieCtrl = TextEditingController();
  final TextEditingController _priceCtrl = TextEditingController();
  final TextEditingController _stockCtrl = TextEditingController();

  bool isLoading = false;
  bool isEditingProduct = false;

  @override
  void initState() {
    super.initState();
    if (widget.product != null) {
      _nameCtrl.text = widget.product!.description;
      _categorieCtrl.text = widget.product!.categorie;
      _priceCtrl.text = widget.product!.price.toString();
      _stockCtrl.text = widget.product!.stock.toString();
    } else {
      isEditingProduct = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
      height: MediaQuery.of(context).size.height * 0.9,
      child: Form(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        (widget.product != null)
                            ? "Editar ${widget.product!.description}"
                            : "Adicionar Produto",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(
                        Icons.close,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const Divider(),
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(
                      height: 16,
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 18),
                      child: Text(
                        "Nome",
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                    const SizedBox(
                      height: 3,
                    ),
                    TextFormField(
                      enabled: isEditingProduct,
                      controller: _nameCtrl,
                      decoration: getLoginInputDecoration("Nome do produto"),
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 18),
                      child: Text(
                        "Categoria",
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                    const SizedBox(
                      height: 3,
                    ),
                    TextFormField(
                      enabled: isEditingProduct,
                      controller: _categorieCtrl,
                      decoration:
                          getLoginInputDecoration("Categoria do produto"),
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 18),
                      child: Text(
                        "Preço",
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                    const SizedBox(
                      height: 3,
                    ),
                    TextFormField(
                      enabled: isEditingProduct,
                      controller: _priceCtrl,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))
                      ],
                      decoration: getLoginInputDecoration("Preço do produto"),
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 18),
                      child: Text(
                        "Estoque",
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                    const SizedBox(
                      height: 6,
                    ),
                    TextFormField(
                      enabled: isEditingProduct,
                      controller: _stockCtrl,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))
                      ],
                      decoration: getLoginInputDecoration("Estoque do produto"),
                    ),
                  ],
                ),
              ],
            ),
            ElevatedButton(
              onPressed: () {
                isEditingProduct ? handleSend() : setState(() {
                  isEditingProduct = true;
                });
              },
              child: (isLoading)
                  ? const SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(
                        color: MyColors.primaryColorLight,
                      ),
                    )
                  : Text(
                      (widget.product != null)
                          ? (isEditingProduct ? "Salvar" : "Editar")
                          : "Cadastrar Produto",
                      style: const TextStyle(color: Colors.black),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  convertToDouble(String value) {
    try {
      return double.parse(value);
    } catch (e) {
      // Retorna null ou um valor padrão caso a conversão falhe
      return null;
    }
  }

  handleSend() {
    setState(() {
      isLoading = true;
    });

    String name = _nameCtrl.text;
    String categorie = _categorieCtrl.text;
    double price = convertToDouble(_priceCtrl.text);
    double stock = convertToDouble(_stockCtrl.text);

    ProductModel product = ProductModel(
      id: (widget.product == null) ? const Uuid().v1() : widget.product!.id,
      description: name,
      categorie: categorie,
      price: price,
      stock: stock,
      imagePath: null,
    );

    widget.productService.addProduct(product).then((value) {
      setState(() {
        isLoading = false;
      });
    });
    Navigator.pop(context);
  }
}
