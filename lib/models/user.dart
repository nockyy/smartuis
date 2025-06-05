// lib/models/user.dart
class CurrentUser {
  String id; // Usamos 'id' aquí para que coincida con lo que el backend envía (generalmente el _id de MongoDB)
  String email;
  String nombre;
  String apellido;
  String codigoEstudiantil;
  List<String> services; // Lista de strings para los servicios (Almuerzo, Cena, etc.)
  int streakCount;
  int points;

  CurrentUser({
    required this.id,
    required this.email,
    required this.nombre,
    required this.apellido,
    required this.codigoEstudiantil,
    required this.services,
    required this.streakCount,
    required this.points,
  });

  // Constructor factory para crear una instancia de CurrentUser desde un Map<String, dynamic> (JSON)
  factory CurrentUser.fromJson(Map<String, dynamic> json) {
    return CurrentUser(
      id: json['id'] as String, // Asume que el backend envía el _id como 'id'
      email: json['email'] as String,
      nombre: json['nombre'] as String,
      apellido: json['apellido'] as String,
      codigoEstudiantil: json['codigoEstudiantil'] as String,
      // Manejo de 'services': Asegúrate de que siempre sea una lista de Strings
      services: List<String>.from(json['services'] ?? []),
      streakCount: json['streakCount'] as int,
      points: json['points'] as int,
    );
  }

  // Método para convertir CurrentUser a JSON si necesitas enviarlo de vuelta al backend
  // (por ejemplo, para actualizar datos del perfil, excluyendo la contraseña)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'nombre': nombre,
      'apellido': apellido,
      'codigoEstudiantil': codigoEstudiantil,
      'services': services,
      'streakCount': streakCount,
      'points': points,
    };
  }
}