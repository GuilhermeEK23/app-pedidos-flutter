import 'package:app_colono/_common/modal_product.dart';
import 'package:app_colono/_common/my_colors.dart';
import 'package:app_colono/models/product_model.dart';
import 'package:app_colono/services/product_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../_common/modal_edit_product.dart';

class ListProductWidget extends StatelessWidget {
  final bool isAdmin;
  final NumberFormat real = NumberFormat.currency(locale: 'pt_BR', name: 'R\$');
  final ProductModel product;
  final ProductService productService;

  ListProductWidget({
    super.key,
    required this.product,
    required this.productService,
    required this.isAdmin,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              blurRadius: 3,
              color: Colors.black.withAlpha(100),
              spreadRadius: 1,
              offset: const Offset(2, 2),
            ),
          ],
          borderRadius: BorderRadius.circular(16),
        ),
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                color: MyColors.lightGreen.withAlpha(300),
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            ListTile(
              leading: SizedBox(
                child: (product.imagePath != null)
                    ? Image.asset(
                        product.imagePath!,
                        width: 50,
                      )
                    : const Icon(
                        Icons.photo,
                        size: 50,
                      ),
              ),
              title: Text(
                product.description,
                style: const TextStyle(fontWeight: FontWeight.w400),
              ),
              subtitle: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    product.categorie,
                    style: const TextStyle(fontWeight: FontWeight.w300),
                  ),
                  Text(
                    real.format(product.price),
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              trailing: isAdmin
                  ? IconButton(
                      onPressed: () {
                        SnackBar snackBar = SnackBar(
                          backgroundColor: Colors.red,
                          content:
                              Text("Deseja remover ${product.description}?"),
                          action: SnackBarAction(
                            label: "REMOVER",
                            textColor: Colors.white,
                            onPressed: () {
                              productService.removeProduct(
                                  idProduct: product.id);
                            },
                          ),
                        );

                        ScaffoldMessenger.of(context).showSnackBar(snackBar);
                      },
                      icon: const Icon(Icons.delete),
                    )
                  : null,
              onTap: () {
                isAdmin
                    ? showModalEditProduct(
                        context, product: product, productService)
                    : showModalProduct(
                        context, product: product, productService, false);
              },
            ),
          ],
        ),
      ),
    );
  }
}
