class signupModel {
  final String uid;
  final String name;
  final String email;
  final String phone;
  final String role; 

  signupModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
  });

  // obj ->fire
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'phone': phone,
      'role': role,
    };
  }

  // fire->obj
  factory signupModel.fromMap(Map<String, dynamic> map) {
    return signupModel(
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      role: map['role'] ?? '',
    );
  }
}
