import 'package:app_colono/models/user_model.dart';
import 'package:app_colono/services/user_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AutenticationService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final UserService _userService = UserService();

  Future<String?> createUser({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      UserCredential userCredential =
          await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await userCredential.user!.updateDisplayName(name);
      UserModel user = UserModel(
          id: userCredential.user!.uid,
          name: name,
          email: email,
          typeUser: 0,
          keyPix: "");
      _userService.createUser(user);

      return null;
    } on FirebaseAuthException catch (e) {
      if (e.code == "email-already-in-use") {
        return "Usuário já está cadastrado";
      }
      if (e.code == "invalid-email") {
        return "Email inválido";
      }
      return "Erro desconhecido";
    }
  }

  Future<String?> loginUser(
      {required String email, required String password}) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);
      return null;
    } on FirebaseAuthException catch (e) {
      if (e.code == "invalid-credential") {
        return "Login inválido";
      }
      return "Erro desconhecido";
    }
  }

  Future<void> logoutUser() {
    return _firebaseAuth.signOut();
  }
}
