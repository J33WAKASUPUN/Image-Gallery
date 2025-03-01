class User {
  final String id;
  final String name;
  final String email;
  final String profilePicture;
  final String token;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.profilePicture,
    required this.token,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    print('Creating User from JSON:');
    print('ID: ${json['_id'] ?? json['id']}');
    print('Name: ${json['name']}');
    print('Email: ${json['email']}');
    print('Has profile picture: ${json['profilePicture'] != null}');
    print('Token present: ${json['token'] != null}');

    return User(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      profilePicture: json['profilePicture'] ?? '',
      token: json['token'] ?? '',
    );
  }

  bool get hasProfilePicture => profilePicture.isNotEmpty;
  
  bool get isBase64ProfilePicture => profilePicture.startsWith('data:');
}