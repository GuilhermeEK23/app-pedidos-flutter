import 'package:app_colono/_common/modal_edit_product.dart';
import 'package:app_colono/models/order_model.dart';
import 'package:app_colono/models/product_model.dart';
import 'package:app_colono/models/user_model.dart';
import 'package:app_colono/screens/cart_screen.dart';
import 'package:app_colono/screens/order_screen.dart';
import 'package:app_colono/screens/product_screen.dart';
import 'package:app_colono/screens/profile_screen.dart';
import 'package:app_colono/services/order_service.dart';
import 'package:app_colono/services/product_service.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  final UserModel user;
  const HomeScreen({super.key, required this.user});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late bool isAdmin;
  int actualPage = 1;
  late PageController pageController;
  late List<String> titlePages;
  final ProductService productService = ProductService();
  final OrderService orderService = OrderService();

  @override
  void initState() {
    super.initState();
    pageController = PageController(initialPage: actualPage);
  }

  void setPageActual(int index) {
    setState(() {
      actualPage = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    isAdmin = (widget.user.typeUser == 1) ? true : false;

    titlePages = [
      isAdmin ? "Pedidos" : "Meu Carrinho",
      "Produtos",
      "Meu Perfil"
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(titlePages[actualPage]),
        centerTitle: true,
      ),
      body: PageView(
        controller: pageController,
        onPageChanged: setPageActual,
        children: [
          isAdmin
              ? StreamBuilder(
                  stream: orderService.connectStreamOrders(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    } else if (snapshot.hasData &&
                        snapshot.data != null &&
                        snapshot.data!.docs.isNotEmpty) {
                      // Lista temporária de pedidos para armazenar os dados
                      List<OrderModel> listOrders = [];

                      for (var doc in snapshot.data!.docs) {
                        listOrders.add(OrderModel.fromMap(doc.data()));
                      }

                      return OrderScreen(listOrders: listOrders);
                    } else {
                      return const Center(
                        child: Text("Sem pedidos!"),
                      );
                    }
                  },
                )
              : CartScreen(user: widget.user),
          StreamBuilder(
            stream: productService.connectStreamProducts(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              } else if (snapshot.hasData &&
                  snapshot.data != null &&
                  snapshot.data!.docs.isNotEmpty) {
                List<ProductModel> listProducts = [];

                for (var doc in snapshot.data!.docs) {
                  listProducts.add(ProductModel.fromMap(doc.data()));
                }

                return ProductScreen(
                  listProducts: listProducts,
                  isAdmin: isAdmin,
                );
              } else {
                return const Center(
                  child: Text("Sem produtos!"),
                );
              }
            },
          ),
          ProfileScreen(
            user: widget.user,
            isAdmin: isAdmin,
          ),
        ],
      ),
      floatingActionButton: (actualPage == 1 && isAdmin)
          ? FloatingActionButton(
              child: const Icon(Icons.add),
              onPressed: () {
                showModalEditProduct(context, productService);
              },
            )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: actualPage,
        items: [
          BottomNavigationBarItem(
            icon: Icon(isAdmin
                ? Icons.format_list_bulleted_rounded
                : Icons.shopping_cart),
            label: isAdmin ? "Pedidos" : "Carrinho",
          ),
          const BottomNavigationBarItem(
              icon: Icon(Icons.storefront_sharp), label: "Produtos"),
          const BottomNavigationBarItem(
              icon: Icon(Icons.person), label: "Perfil"),
        ],
        onTap: (page) {
          pageController.animateToPage(
            page,
            duration: const Duration(microseconds: 400),
            curve: Curves.ease,
          );
        },
      ),
    );
  }
}
