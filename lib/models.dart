class Task {
  final int id;
  final String titre;
  final DateTime echeance;
  final bool terminee;
  final String? description; // facultative -> String?
  final int? coursId;

  const Task({
    required this.id,
    required this.titre,
    required this.echeance,
    this.terminee = false,
    this.description,
    this.coursId,
  });

  Task copyWith({
    String? titre,
    DateTime? echeance,
    bool? terminee,
    String? description,
    int? coursId,
  }) =>
      Task(
        id: id,
        titre: titre ?? this.titre,
        echeance: echeance ?? this.echeance,
        terminee: terminee ?? this.terminee,
        description: description ?? this.description,
        coursId: coursId ?? this.coursId,
      );

  factory Task.fromJson(Map<String, dynamic> json) => Task(
        id: json['id'] as int,
        titre: json['titre'] as String,
        echeance: DateTime.parse(json['echeance'] as String),
        terminee: json['terminee'] as bool? ?? false,
        description: json['description'] as String?,
        coursId: json['coursId'] as int?,
      );
}

class Course {
  final int id;
  final String nom;
  final String enseignant;

  const Course({
    required this.id,
    required this.nom,
    required this.enseignant,
  });

  Course copyWith({String? nom, String? enseignant}) => Course(
        id: id,
        nom: nom ?? this.nom,
        enseignant: enseignant ?? this.enseignant,
      );

  factory Course.fromJson(Map<String, dynamic> json) => Course(
        id: json['id'] as int,
        nom: json['nom'] as String,
        enseignant: json['enseignant'] as String,
      );
}

class User {
  final int id;
  final String nom;
  final String email;

  const User({required this.id, required this.nom, required this.email});

  User copyWith({String? nom, String? email}) => User(
        id: id,
        nom: nom ?? this.nom,
        email: email ?? this.email,
      );

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json['id'] as int,
        nom: json['nom'] as String,
        email: json['email'] as String,
      );
}
