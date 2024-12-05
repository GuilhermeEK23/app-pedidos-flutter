class UserModel {
  String id;
  String name;
  String email;
  int typeUser;
  String? keyPix;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.typeUser,
    this.keyPix,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'],
      name: map['name'],
      email: map['email'],
      typeUser: map['typeUser'],
      keyPix: map['keyPix'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'typeUser': typeUser,
      'keyPix': keyPix,
    };
  }
}
