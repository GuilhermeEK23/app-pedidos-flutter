import 'package:app_colono/_common/my_colors.dart';
import 'package:app_colono/_common/snackbar.dart';
import 'package:app_colono/components/decoration.dart';
import 'package:app_colono/services/autentication_service.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool isLogin = true;
  bool isLoading = false;
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _repeatPasswordController =
      TextEditingController();

  final AutenticationService _autenticationService = AutenticationService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [MyColors.darkGreen, MyColors.lightGreen],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: isLoading
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : Form(
                    key: _formKey,
                    child: Center(
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Image.asset(
                              "assets/images/logo.png",
                              height: 150,
                            ),
                            const Text(
                              "App Colono",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 25,
                              ),
                            ),
                            const SizedBox(
                              height: 32,
                            ),
                            if (!isLogin)
                              TextFormField(
                                controller: _nameController,
                                decoration: getLoginInputDecoration("Nome"),
                                validator: (String? value) {
                                  if (value!.isEmpty) {
                                    return "O nome não pode ser vazio";
                                  }
                                  if (value.length < 4) {
                                    return "O nome está muito curto";
                                  }
                                  return null;
                                },
                              ),
                            const SizedBox(
                              height: 8,
                            ),
                            TextFormField(
                              controller: _emailController,
                              decoration: getLoginInputDecoration("Email"),
                              validator: (String? value) {
                                if (value!.isEmpty) {
                                  return "O e-mail não pode ser vazio";
                                }
                                if (value.length < 5) {
                                  return "O e-mail está muito curto";
                                }
                                if (!value.contains("@")) {
                                  return "O e-mail não é válido";
                                }
                                return null;
                              },
                            ),
                            const SizedBox(
                              height: 8,
                            ),
                            TextFormField(
                              controller: _passwordController,
                              decoration: getLoginInputDecoration("Senha"),
                              obscureText: true,
                              validator: (String? value) {
                                if (value!.isEmpty) {
                                  return "A senha não pode ser vazia";
                                }
                                if (value.length < 6) {
                                  return "A senha deve ter no mínimo 6 carácteres";
                                }
                                return null;
                              },
                            ),
                            const SizedBox(
                              height: 8,
                            ),
                            if (!isLogin)
                              TextFormField(
                                controller: _repeatPasswordController,
                                decoration:
                                    getLoginInputDecoration("Confirme a Senha"),
                                obscureText: true,
                                validator: (String? value) {
                                  if (value!.isEmpty) {
                                    return "O confirmar senha não pode estar vazio";
                                  }
                                  if (value.length < 6) {
                                    return "A senha deve ter no mínimo 6 carácteres";
                                  }
                                  if (value != _passwordController.text) {
                                    return "As senhas não estão iguais";
                                  }
                                  return null;
                                },
                              ),
                            const SizedBox(
                              height: 32,
                            ),
                            ElevatedButton(
                              onPressed: () {
                                handleButton();
                              },
                              style: ButtonStyle(
                                backgroundColor: WidgetStateProperty.all(
                                  MyColors.greenButton,
                                ),
                              ),
                              child: Text(
                                (isLogin) ? "Entrar" : "Cadastrar",
                                style: const TextStyle(color: Colors.black),
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  isLogin = !isLogin;
                                  _nameController.text = "";
                                  _emailController.text = "";
                                  _passwordController.text = "";
                                  _repeatPasswordController.text = "";
                                });
                              },
                              style: ButtonStyle(
                                elevation: WidgetStateProperty.all(0),
                                backgroundColor:
                                    WidgetStateProperty.all(Colors.transparent),
                              ),
                              child: Text(
                                (isLogin)
                                    ? "Ainda não tem uma conta? Cadastre-se!"
                                    : "Já tem uma conta? Entrar!",
                                style: const TextStyle(color: Colors.black),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  handleButton() async {
    String name = _nameController.text;
    String email = _emailController.text;
    String password = _passwordController.text;

    if (_formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });

      if (isLogin) {
        String? error = await _autenticationService.loginUser(
          email: email,
          password: password,
        );

        if (mounted) {
          // Verifica se o widget ainda está montado antes de atualizar o estado
          setState(() {
            isLoading = false;
          });

          if (error != null) {
            showSnackbar(context: context, text: error);
          }
        }
      } else {
        String? error = await _autenticationService.createUser(
          name: name,
          email: email,
          password: password,
        );
        if (mounted) {
          setState(() {
            isLoading = false;
          });

          if (error != null) {
            showSnackbar(context: context, text: error);
          }
        }
      }
    }
  }
}
