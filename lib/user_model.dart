class User {
  final String id;
  final String email;
  final String displayName;
  final String photoUrl;
  final List<String> preferredGenres;
  final bool useDarkMode;

  User({
    required this.id,
    required this.email, 
    required this.displayName,
    this.photoUrl = '',
    this.preferredGenres = const [],
    this.useDarkMode = false,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json['id'] ?? '',
    email: json['email'] ?? '',
    displayName: json['displayName'] ?? 'User',
    photoUrl: json['photoUrl'] ?? '',
    preferredGenres: json['preferredGenres'] != null
        ? List<String>.from(json['preferredGenres'])
        : const [],
    useDarkMode: json['useDarkMode'] ?? false,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'displayName': displayName,
    'photoUrl': photoUrl,
    'preferredGenres': preferredGenres,
    'useDarkMode': useDarkMode,
  };

  User copyWith({
    String? id,
    String? email,
    String? displayName,
    String? photoUrl,
    List<String>? preferredGenres,
    bool? useDarkMode,
  }) => User(
    id: id ?? this.id,
    email: email ?? this.email,
    displayName: displayName ?? this.displayName,
    photoUrl: photoUrl ?? this.photoUrl,
    preferredGenres: preferredGenres ?? this.preferredGenres,
    useDarkMode: useDarkMode ?? this.useDarkMode,
  );
}