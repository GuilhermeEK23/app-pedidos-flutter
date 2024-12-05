import 'package:app_colono/_common/snackbar.dart';
import 'package:app_colono/models/user_model.dart';
import 'package:app_colono/services/order_service.dart';
import 'package:app_colono/services/product_service.dart';
import 'package:app_colono/services/user_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  final UserModel user;
  final bool isAdmin;

  const ProfileScreen({super.key, required this.user, required this.isAdmin});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _keyController = TextEditingController();
  final OrderService _orderService = OrderService();
  final ProductService _productService = ProductService();
  final UserService _userService = UserService();

  bool isEditingName = false; // Controla o estado de edição
  bool isEditingKey = false; // Controla o estado de edição da chave PIX
  int totalOrders = 0;
  int totalProducts = 0;
  double totalSpent = 0.0;

  @override
  void initState() {
    super.initState();
    _nameController.text =
        widget.user.name; // Inicializa o controlador com o nome atual
    _keyController.text = widget.user.keyPix ??
        ""; // Inicializa o controlador com a chave PIX atual
    // Carregar estatísticas reais do usuário (pedidos, produtos, gastos)
    loadUserStats();
  }

  Future<void> loadUserStats() async {
    // Aqui você deverá buscar os dados do banco de dados e preencher as variáveis `totalOrders`, `totalProducts` e `totalSpent`

    if (widget.isAdmin) {
      var totalOrdersFirebase = await _orderService.getTotalOrders();
      var totalProductsFirebase = await _productService.getTotalProducts();
      var totalSpentFirebase = await _orderService.getTotalSales();
      setState(() {
        totalOrders = totalOrdersFirebase;
        totalProducts = totalProductsFirebase;
        totalSpent = totalSpentFirebase;
      });
    } else {
      var totalOrdersFirebase =
          await _orderService.getTotalOrdersUser(widget.user.id);
      var totalProductsFirebase =
          await _productService.getTotalProductsPurchased(widget.user.id);
      var totalSpentFirebase =
          await _orderService.getTotalSpent(widget.user.id);
      setState(() {
        totalOrders = totalOrdersFirebase; // Exemplo
        totalProducts = totalProductsFirebase; // Exemplo
        totalSpent = totalSpentFirebase; // Exemplo
      });
    }
  }

  Future<void> updateUserName() async {
    // Atualiza o nome do usuário no backend ou banco de dados
    await _firebaseAuth.currentUser!.updateDisplayName(_nameController.text);
    setState(() {
      widget.user.name = _nameController.text;
      isEditingName = false; // Bloqueia novamente o campo após salvar
    });
  }

  Future<void> updateKey() async {
    // Atualiza a chave PIX do administrador no firebase
    await _userService.updatePixKey(widget.user.id, _keyController.text);
    setState(() {
      widget.user.keyPix = _keyController.text;
      isEditingKey = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              color: Colors.grey[100],
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Informações do Perfil",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      _firebaseAuth.signOut();
                    },
                    child: const Row(
                      children: [
                        Text("Sair"),
                        SizedBox(width: 8),
                        Icon(Icons.logout),
                      ],
                    ),
                  )
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Text("Nome: ", style: TextStyle(fontSize: 16)),
                      Expanded(
                        child: TextField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            hintText: "Digite seu nome",
                          ),
                          enabled:
                              isEditingName, // Controla o bloqueio do campo
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            if (isEditingName) {
                              updateUserName(); // Salva o nome e bloqueia o campo
                              showSnackbar(
                                  context: context,
                                  text:
                                      "Nome de Usuário atualizado com sucesso",
                                  isError: false);
                            } else {
                              isEditingName =
                                  true; // Desbloqueia o campo para edição
                            }
                          });
                        },
                        icon: Icon(isEditingName ? Icons.check : Icons.edit),
                        tooltip: isEditingName ? "Salvar Nome" : "Editar Nome",
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Text("Email: ", style: TextStyle(fontSize: 13)),
                      Expanded(
                        child: Text(widget.user.email,
                            style: const TextStyle(fontSize: 12)),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          // TODO: Navegar para a tela de mudança de senha
                        },
                        child: const Text(
                          "Trocar Senha",
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                  widget.isAdmin
                      ? Column(
                          children: [
                            const SizedBox(height: 20),
                            Row(
                              children: [
                                const Text("Chave PIX: ",
                                    style: TextStyle(fontSize: 15)),
                                Expanded(
                                  child: TextField(
                                    controller: _keyController,
                                    decoration: const InputDecoration(
                                        hintText: "Digite sua chave PIX",
                                        hintStyle: TextStyle(fontSize: 15)),
                                    enabled:
                                        isEditingKey, // Controla o bloqueio do campo
                                  ),
                                ),
                                IconButton(
                                  onPressed: () {
                                    setState(() {
                                      if (isEditingKey) {
                                        updateKey(); // Salva a chave PIX e bloqueia o campo
                                        showSnackbar(
                                            context: context,
                                            text:
                                                "Chave PIX atualizada com sucesso",
                                            isError: false);
                                      } else {
                                        isEditingKey =
                                            true; // Desbloqueia o campo para edição
                                      }
                                    });
                                  },
                                  icon: Icon(
                                      isEditingKey ? Icons.check : Icons.edit),
                                  tooltip: isEditingKey
                                      ? "Salvar chave PIX"
                                      : "Editar chave PIX",
                                ),
                              ],
                            ),
                          ],
                        )
                      : Container(),
                  const SizedBox(height: 20),
                  const Text(
                    "Estatísticas",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          ListTile(
                            title: Text(widget.isAdmin
                                ? "Total de Pedidos"
                                : "Pedidos Realizados"),
                            trailing: Text("$totalOrders"),
                          ),
                          const Divider(),
                          ListTile(
                            title: Text(widget.isAdmin
                                ? "Total de Produtos"
                                : "Produtos Comprados"),
                            trailing: Text("$totalProducts"),
                          ),
                          const Divider(),
                          ListTile(
                            title: Text(widget.isAdmin
                                ? "Total de Ganhos"
                                : "Total Gasto"),
                            trailing: Text(
                              "R\$ ${totalSpent.toStringAsFixed(2)}",
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
