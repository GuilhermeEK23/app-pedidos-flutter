import 'package:app_colono/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<UserModel> getUserById(String userId) async {
    DocumentSnapshot snapshot =
        await _firestore.collection('users').doc(userId).get();

    if (!snapshot.exists || snapshot.data() == null) {
      throw Exception('Usuário não encontrado');
    }

    return UserModel.fromMap(snapshot.data() as Map<String, dynamic>);
  }

  Future<void> createUser(UserModel user) async {
    await _firestore.collection('users').doc(user.id).set(user.toMap());
  }

  Future<void> updatePixKey(String userId, String pixKey) async {
    await _firestore.collection('users').doc(userId).set(
      {"keyPix": pixKey},
      SetOptions(merge: true),
    );
  }
}
