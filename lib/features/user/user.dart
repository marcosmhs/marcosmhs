import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';

part 'user.g.dart';

@HiveType(typeId: 0)
class User {
  @HiveField(0)
  late String id;
  @HiveField(1)
  late String email;
  @HiveField(2)
  late String password;
  @HiveField(3)
  late String token;
  @HiveField(4)
  late String name;

  late bool _passwordChanged = false;

  User({
    this.id = '',
    this.email = '',
    this.password = '',
    this.token = '',
    this.name = '',
  });

  void setPassword(String value) {
    password = value;
    _passwordChanged = true;
  }

  bool get isPasswordChanged {
    return _passwordChanged;
  }

  factory User.fromDocument(DocumentSnapshot doc) {
    final data = doc.data()! as Map<String, dynamic>;
    return User.fromMap(map: data);
  }

  static User fromMap({required Map<String, dynamic> map, String setEmail = '', String setToken = ''}) {
    var u = User();

    u = User(
      id: map['id'] ?? '',
      email: setEmail.isNotEmpty ? setEmail : map['email'] ?? '',
      password: map['password'] ?? '',
      token: setToken.isNotEmpty ? setToken : map['token'] ?? '',
      name: map['name'] ?? '',
    );
    return u;
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> r = {};
    r = {
      'id': id,
      'email': email,
      'password': password,
      'token': token,
      'name': name,
    };

    return r;
  }
}
