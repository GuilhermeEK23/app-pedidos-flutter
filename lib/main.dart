import 'package:app_colono/_common/my_colors.dart';
import 'package:app_colono/components/cart_provider.dart';
import 'package:app_colono/screens/home_screen.dart';
import 'package:app_colono/screens/login_screen.dart';
import 'package:app_colono/services/user_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'package:app_colono/models/user_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => CartProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final GlobalKey<ScaffoldMessengerState> rootScaffoldMessengerKey =
        GlobalKey<ScaffoldMessengerState>();

    return MaterialApp(
      scaffoldMessengerKey: rootScaffoldMessengerKey,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        appBarTheme: const AppBarTheme(
          backgroundColor: MyColors.primaryColor,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: MyColors.primaryColorLight,
        ),
      ),
      title: 'App Colono',
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.userChanges(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          User firebaseUser = FirebaseAuth.instance.currentUser!;
          UserService userService = UserService();
          return FutureBuilder<UserModel>(
              future: userService.getUserById(firebaseUser.uid),
              builder: (context, userSnapshot) {
                if (userSnapshot.hasData) {
                  return HomeScreen(user: userSnapshot.data!);
                }
                return Container(
                  color: Colors.white,
                  child: const Center(child: CircularProgressIndicator()),
                );
              });
        } else {
          return const LoginScreen();
        }
      },
    );
  }
}
