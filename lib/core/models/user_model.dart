import 'package:equatable/equatable.dart';

class UserModel extends Equatable {
  final int idUser;
  final String username;
  final String role;

  const UserModel({
    required this.idUser,
    required this.username,
    required this.role,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      idUser: map['id_user'] as int,
      username: map['username'] as String,
      role: map['role'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id_user': idUser,
      'username': username,
      'role': role,
    };
  }

  @override
  List<Object?> get props => [idUser, username, role];
}
