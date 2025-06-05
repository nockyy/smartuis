import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:http/http.dart' as http; // Importación para hacer peticiones HTTP
import 'dart:convert'; // Importación para codificar/decodificar JSON

// URL BASE DE TU API DE BACKEND
// ¡IMPORTANTE! Ajusta esta URL según tu entorno:
// Si estás usando un emulador de Android:
const String BASE_API_URL = "http://10.0.2.2:3000";

// Si estás usando un simulador iOS o dispositivo físico Android/iOS (y tu ordenador está en la misma red):
// const String BASE_API_URL = "http://TU_IP_LOCAL:3000"; // Reemplaza TU_IP_LOCAL con la IP de tu ordenador (ej: 192.168.1.10)
// Para Flutter Web:
// const String BASE_API_URL = "http://localhost:3000";


// Clase para manejar las operaciones de la API (sustituye a MongoDatabase)
class ApiDatabase {
  // El backend ya se encarga de la conexión a MongoDB, no necesitamos un 'connect' aquí.

  static Future<Map<String, dynamic>?> loginUser(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$BASE_API_URL/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print("Login exitoso. Datos del usuario: ${data['user']}");
        return data['user']; // El backend devuelve el usuario bajo la clave 'user'
      } else {
        final errorData = json.decode(response.body);
        print("Error de login en API: ${errorData['message']} (Status: ${response.statusCode})");
        return null;
      }
    } catch (e) {
      print("Error al hacer petición de login: $e");
      return null;
    }
  }

  static Future<bool> insertUser(Map<String, dynamic> userData) async {
    try {
      final response = await http.post(
        Uri.parse('$BASE_API_URL/register'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(userData),
      );

      if (response.statusCode == 201) {
        print("Usuario insertado con éxito via API: ${userData['email']}");
        return true;
      } else {
        final errorData = json.decode(response.body);
        print("Error al insertar usuario via API: ${errorData['message']} (Status: ${response.statusCode})");
        return false;
      }
    } catch (e) {
      print("Error al hacer petición de registro: $e");
      return false;
    }
  }

  static Future<Reserva?> getActiveReservation(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$BASE_API_URL/reservations/$userId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        // Asegúrate de que los campos existan y sean del tipo correcto
        return Reserva(
          tipo: data['tipo'] ?? '', // Default si 'tipo' es nulo
          fecha: DateTime.parse(data['fecha']),
          hora: TimeOfDay(
            hour: int.parse(data['hora'].split(':')[0]),
            minute: int.parse(data['hora'].split(':')[1]),
          ),
        );
      } else if (response.statusCode == 404) {
        print("No se encontró reserva activa para userId: $userId");
        return null; // No hay reserva activa
      } else {
        final errorData = json.decode(response.body);
        print("Error al obtener reserva activa via API: ${errorData['message']} (Status: ${response.statusCode})");
        return null;
      }
    } catch (e) {
      print("Error al hacer petición de obtener reserva: $e");
      return null;
    }
  }

  static Future<bool> updateReserva(String userId, Reserva reserva) async {
    try {
      final response = await http.post( // Usamos POST para crear/actualizar (upsert en el backend)
        Uri.parse('$BASE_API_URL/reservations'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'userId': userId,
          'tipo': reserva.tipo,
          'fecha': reserva.fecha.toIso8601String().split('T')[0], // Enviar solo la fecha YYYY-MM-DD
          'hora': '${reserva.hora.hour.toString().padLeft(2, '0')}:${reserva.hora.minute.toString().padLeft(2, '0')}', // Formato HH:MM
        }),
      );

      if (response.statusCode == 200) {
        print("Reserva actualizada/insertada con éxito via API para userId: $userId");
        return true;
      } else {
        final errorData = json.decode(response.body);
        print("Error al actualizar reserva via API: ${errorData['message']} (Status: ${response.statusCode})");
        return false;
      }
    } catch (e) {
      print("Error al hacer petición de actualizar reserva: $e");
      return false;
    }
  }

  static Future<bool> deleteReserva(String userId, String tipoReserva) async {
    try {
      final response = await http.delete(
        Uri.parse('$BASE_API_URL/reservations/$userId/$tipoReserva'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        print("Reserva '$tipoReserva' eliminada con éxito via API para userId: $userId");
        return true;
      } else {
        final errorData = json.decode(response.body);
        print("Error al eliminar reserva via API: ${errorData['message']} (Status: ${response.statusCode})");
        return false;
      }
    } catch (e) {
      print("Error al hacer petición de eliminar reserva: $e");
      return false;
    }
  }

  static Future<bool> updatePassword(String userId, String newPassword) async {
    try {
      final response = await http.put(
        Uri.parse('$BASE_API_URL/users/$userId/password'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'newPassword': newPassword}),
      );

      if (response.statusCode == 200) {
        print("Contraseña actualizada con éxito via API para userId: $userId");
        return true;
      } else {
        final errorData = json.decode(response.body);
        print("Error al actualizar contraseña via API: ${errorData['message']} (Status: ${response.statusCode})");
        return false;
      }
    } catch (e) {
      print("Error al hacer petición de actualizar contraseña: $e");
      return false;
    }
  }

  static Future<bool> updateUserData(String userId, Map<String, dynamic> dataToUpdate) async {
    try {
      final response = await http.put(
        Uri.parse('$BASE_API_URL/users/$userId'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(dataToUpdate),
      );

      if (response.statusCode == 200) {
        print("Datos de usuario actualizados con éxito via API para userId: $userId");
        return true;
      } else {
        final errorData = json.decode(response.body);
        print("Error al actualizar datos de usuario via API: ${errorData['message']} (Status: ${response.statusCode})");
        return false;
      }
    } catch (e) {
      print("Error al hacer petición de actualizar datos de usuario: $e");
      return false;
    }
  }

  static Future<List<Reserva>> getReservationsHistory(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$BASE_API_URL/reservations/history/$userId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        return jsonList.map((doc) => Reserva(
          tipo: doc['tipo'] ?? '', // Default si 'tipo' es nulo
          fecha: DateTime.parse(doc['fecha']),
          hora: TimeOfDay(
            hour: int.parse(doc['hora'].split(':')[0]),
            minute: int.parse(doc['hora'].split(':')[1]),
          ),
        )).toList();
      } else {
        final errorData = json.decode(response.body);
        print("Error al obtener historial de reservas via API: ${errorData['message']} (Status: ${response.statusCode})");
        return [];
      }
    } catch (e) {
      print("Error al hacer petición de historial de reservas: $e");
      return [];
    }
  }
}

// -----------------------------------------------------------------------------
// Clases y variables globales existentes (se mantienen o adaptan ligeramente)
// -----------------------------------------------------------------------------

class Reserva {
  String tipo;
  DateTime fecha;
  TimeOfDay hora;

  Reserva({required this.tipo, required this.fecha, required this.hora});
}

Reserva? reservaGlobal;
bool pedidoConfirmado = false;

// Los valores de streakCount y points deberían venir del objeto de usuario
// que se obtiene al iniciar sesión o al actualizar el perfil.
// Los mantengo aquí como ejemplo, pero idealmente se actualizarían con los datos del usuario logueado.
int streakCount = 0;
int points = 0;

List<Reserva> historyList = [];

void main() {
  runApp(const SmartUISApp());
}

class SmartUISApp extends StatelessWidget {
  const SmartUISApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', ''),
        Locale('es', ''),
      ],
    );
  }
}

// Clase para manejar el usuario actualmente logueado
class CurrentUser {
  String id; // Ahora el ID es un String directo del backend
  String email;
  String nombre;
  String apellido;
  String codigoEstudiantil;
  List<String> services;
  int streakCount;
  int points;

  // Eliminamos 'password' de aquí. La contraseña no debe estar en el cliente.
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

  factory CurrentUser.fromJson(Map<String, dynamic> json) {
    return CurrentUser(
      id: json['id'] as String, // El backend envía el _id como 'id'
      email: json['email'] as String,
      nombre: json['nombre'] as String,
      apellido: json['apellido'] as String,
      codigoEstudiantil: json['codigoEstudiantil'] as String,
      services: List<String>.from(json['services'] ?? []),
      streakCount: json['streakCount'] as int,
      points: json['points'] as int,
    );
  }
}

CurrentUser? currentUser; // Variable global para el usuario actual

// -----------------------------------------------------------------------------
// Splash Screen
// -----------------------------------------------------------------------------
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeAndNavigate();
  }

  Future<void> _initializeAndNavigate() async {
    // Ya no necesitas llamar a connect aquí, el backend se encarga de la DB
    // await ApiDatabase.connect(); // ¡ELIMINADO!

    // Simular un tiempo de carga
    await Future.delayed(const Duration(seconds: 3));

    // Navegar a la página de inicio de sesión
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Aquí puedes colocar tu logo o un indicador de carga
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
            ),
            SizedBox(height: 20),
            Text(
              'Cargando Smart UIS Comedores...',
              style: TextStyle(fontSize: 18, color: Colors.green),
            ),
          ],
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Login Page
// -----------------------------------------------------------------------------
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _login() async {
    final String email = _emailController.text;
    final String password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, ingresa tu email y contraseña.')),
      );
      return;
    }

    // Usar ApiDatabase en lugar de MongoDatabase
    final userDoc = await ApiDatabase.loginUser(email, password);

    if (!mounted) return;

    if (userDoc != null) {
      currentUser = CurrentUser.fromJson(userDoc);
      print("Usuario logueado: ${currentUser!.email}, ID: ${currentUser!.id}");

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Inicio de sesión exitoso!')),
      );
      // Redirigir a InstructionsPage como lo tenías originalmente
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const InstructionsPage()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Credenciales incorrectas o error al iniciar sesión.')),
      );
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/logo.jpeg', height: 100), // Usando logo.jpeg de tu código original
              const SizedBox(height: 40),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Correo Institucional',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Contraseña',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _login,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Entrar',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const RegisterPage()),
                  );
                },
                child: const Text(
                  '¿No tienes cuenta? Regístrate aquí',
                  style: TextStyle(color: Colors.green),
                ),
              ),
              TextButton(
                onPressed: () {
                  // Lógica para recuperar contraseña
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Funcionalidad de recuperar contraseña pendiente.')),
                  );
                },
                child: const Text(
                  '¿Olvidaste tu contraseña?',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Register Page
// -----------------------------------------------------------------------------
class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _apellidoController = TextEditingController();
  final TextEditingController _codigoEstudiantilController = TextEditingController();

  final List<String> _selectedServices = []; // Inicialmente vacío

  void _register() async {
    final String email = _emailController.text;
    final String password = _passwordController.text;
    final String confirmPassword = _confirmPasswordController.text;
    final String nombre = _nombreController.text;
    final String apellido = _apellidoController.text;
    final String codigoEstudiantil = _codigoEstudiantilController.text;

    if (email.isEmpty || password.isEmpty || confirmPassword.isEmpty ||
        nombre.isEmpty || apellido.isEmpty || codigoEstudiantil.isEmpty ||
        _selectedServices.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, llena todos los campos y selecciona al menos un servicio.')),
      );
      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Las contraseñas no coinciden.')),
      );
      return;
    }

    final userData = {
      'email': email,
      'password': password,
      'nombre': nombre,
      'apellido': apellido,
      'codigoEstudiantil': codigoEstudiantil,
      'services': _selectedServices,
      'streakCount': 0, // Valores iniciales
      'points': 0,      // Valores iniciales
    };

    // Usar ApiDatabase en lugar de MongoDatabase
    bool success = await ApiDatabase.insertUser(userData);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Usuario registrado con éxito!')),
      );
      Navigator.pop(context); // Volver a la página de login
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al registrar usuario. El email ya podría estar registrado o hay un problema en el servidor.')),
      );
    }
  }

  void _toggleService(String service) {
    setState(() {
      if (_selectedServices.contains(service)) {
        _selectedServices.remove(service);
      } else {
        _selectedServices.add(service);
      }
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nombreController.dispose();
    _apellidoController.dispose();
    _codigoEstudiantilController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registro'),
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Correo Institucional'),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Contraseña'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _confirmPasswordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Confirmar Contraseña'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _nombreController,
              decoration: const InputDecoration(labelText: 'Nombre'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _apellidoController,
              decoration: const InputDecoration(labelText: 'Apellido'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _codigoEstudiantilController,
              decoration: const InputDecoration(labelText: 'Código Estudiantil'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            const Text('Selecciona los servicios de comedor:', style: TextStyle(fontSize: 16)),
            CheckboxListTile( // Usando CheckboxListTile para una mejor UI/UX
              title: const Text('Almuerzo'),
              value: _selectedServices.contains('Almuerzo'),
              onChanged: (bool? value) {
                setState(() {
                  if (value == true) {
                    _selectedServices.add('Almuerzo');
                  } else {
                    _selectedServices.remove('Almuerzo');
                  }
                });
              },
            ),
            CheckboxListTile(
              title: const Text('Cena'),
              value: _selectedServices.contains('Cena'),
              onChanged: (bool? value) {
                setState(() {
                  if (value == true) {
                    _selectedServices.add('Cena');
                  } else {
                    _selectedServices.remove('Cena');
                  }
                });
              },
            ),
            // Si quieres desayuno, también puedes agregarlo aquí
            // CheckboxListTile(
            //   title: const Text('Desayuno'),
            //   value: _selectedServices.contains('Desayuno'),
            //   onChanged: (bool? value) {
            //     setState(() {
            //       if (value == true) {
            //         _selectedServices.add('Desayuno');
            //       } else {
            //         _selectedServices.remove('Desayuno');
            //       }
            //     });
            //   },
            // ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _register,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: const Text('Registrarse'),
            ),
          ],
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Instructions Page (Se mantiene igual a tu versión anterior)
// -----------------------------------------------------------------------------
class InstructionsPage extends StatelessWidget {
  const InstructionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: const Text('Instrucciones'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '¡Bienvenid@!',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.green[800]),
            ),
            const SizedBox(height: 16),
            const Text(
              'Smart UIS Comedores te permite:',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 10),
            const Text('• Reservar un turno para el servicio que poseas.', style: TextStyle(fontSize: 16)),
            const Text('• Conocer el tiempo de espera a tu turno.', style: TextStyle(fontSize: 16)),
            const Text('• Cancelar un turno reservado antes de tiempo.', style: TextStyle(fontSize: 16)),
            const Spacer(),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const HomePage()),
                  );
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                child: const Text('Continuar'),
              ),
            )
          ],
        ),
      ),
    );
  }
}


// -----------------------------------------------------------------------------
// Home Page
// -----------------------------------------------------------------------------
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  String? _selectedMealType; // 'Almuerzo' o 'Cena'

  @override
  void initState() {
    super.initState();
    _loadUserAndReservation();
  }

  Future<void> _loadUserAndReservation() async {
    if (currentUser == null) {
      print("Error: currentUser es nulo al cargar HomePage.");
      return;
    }
    // Cargar la reserva activa del usuario
    reservaGlobal = await ApiDatabase.getActiveReservation(currentUser!.id);
    print("Reserva cargada al iniciar Home: $reservaGlobal");

    // Actualizar streakCount y points desde el currentUser (si se traen en el login)
    setState(() {
      if (currentUser != null) {
        streakCount = currentUser!.streakCount;
        points = currentUser!.points;
      }
      // Inicializar los campos de selección con la reserva existente si la hay
      if (reservaGlobal != null) {
        _selectedMealType = reservaGlobal!.tipo;
        _selectedDate = reservaGlobal!.fecha;
        _selectedTime = reservaGlobal!.hora;
        pedidoConfirmado = true; // Si hay una reserva activa, se considera confirmada
      } else {
        pedidoConfirmado = false; // No hay reserva activa
      }
    });
  }


  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)), // Puedes reservar hasta 30 días en el futuro
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(primary: Colors.green, onPrimary: Colors.white),
            buttonTheme: const ButtonThemeData(textTheme: ButtonTextTheme.primary),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(primary: Colors.green, onPrimary: Colors.white),
            buttonTheme: const ButtonThemeData(textTheme: ButtonTextTheme.primary),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  void _makeReservation() async {
    if (_selectedMealType == null || _selectedDate == null || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, selecciona el tipo de comida, fecha y hora.')),
      );
      return;
    }

    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: No hay usuario logueado para hacer la reserva.')),
      );
      return;
    }

    // Verificar si el servicio está disponible para el usuario
    if (!currentUser!.services.contains(_selectedMealType)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No tienes acceso al servicio de $_selectedMealType.')),
      );
      return;
    }

    final newReservation = Reserva(
      tipo: _selectedMealType!,
      fecha: _selectedDate!,
      hora: _selectedTime!,
    );

    // Usar ApiDatabase en lugar de MongoDatabase
    bool success = await ApiDatabase.updateReserva(currentUser!.id, newReservation);

    if (!mounted) return;

    if (success) {
      setState(() {
        reservaGlobal = newReservation;
        pedidoConfirmado = true; // Establecer a true si la reserva fue exitosa
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reserva realizada con éxito!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al realizar la reserva. Inténtalo de nuevo.')),
      );
    }
  }

  void _showCancelConfirmationDialog(BuildContext context) {
    if (reservaGlobal == null) return;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Cancelar Reserva"),
          content: Text("¿Estás seguro de que deseas cancelar la reserva de ${reservaGlobal!.tipo} para el ${reservaGlobal!.fecha.toLocal().toString().split(' ')[0]} a las ${reservaGlobal!.hora.format(context)}?"),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("No"),
            ),
            TextButton(
              onPressed: () async {
                if (currentUser == null) return;
                // Usar ApiDatabase en lugar de MongoDatabase
                bool success = await ApiDatabase.deleteReserva(currentUser!.id, reservaGlobal!.tipo);

                if (!mounted) return;

                if (success) {
                  setState(() {
                    reservaGlobal = null;
                    pedidoConfirmado = false; // Restablecer
                    _selectedMealType = null; // Limpiar selección
                    _selectedDate = null;
                    _selectedTime = null;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Reserva cancelada con éxito!')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Error al cancelar la reserva. Inténtalo de nuevo.')),
                  );
                }
                Navigator.of(context).pop();
              },
              child: const Text("Sí", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart UIS Comedores'),
        backgroundColor: Colors.green,
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfilePage()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (currentUser != null)
              Card(
                elevation: 4,
                margin: const EdgeInsets.symmetric(vertical: 10),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Bienvenido, ${currentUser!.nombre} ${currentUser!.apellido}!',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green),
                      ),
                      const SizedBox(height: 8),
                      Text('Código Estudiantil: ${currentUser!.codigoEstudiantil}'),
                      Text('Email: ${currentUser!.email}'),
                      Text('Servicios: ${currentUser!.services.join(', ')}'),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.star, color: Colors.amber),
                          Text(' Racha: ${currentUser!.streakCount}'), // Usar streakCount del currentUser
                          SizedBox(width: 20),
                          Icon(Icons.emoji_events, color: Colors.blue),
                          Text(' Puntos: ${currentUser!.points}'), // Usar points del currentUser
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 20),
            if (reservaGlobal != null && pedidoConfirmado)
              Card(
                elevation: 4,
                margin: const EdgeInsets.symmetric(vertical: 10),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Tu Reserva Actual:',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      Text('Tipo: ${reservaGlobal!.tipo}'),
                      Text('Fecha: ${reservaGlobal!.fecha.toLocal().toString().split(' ')[0]}'),
                      Text('Hora: ${reservaGlobal!.hora.format(context)}'),
                      const SizedBox(height: 10),
                      Center(
                        child: QrImageView(
                          data: 'Reserva ID: ${currentUser!.id} - Tipo: ${reservaGlobal!.tipo} - Fecha: ${reservaGlobal!.fecha.toIso8601String().split('T')[0]} - Hora: ${reservaGlobal!.hora.format(context)}',
                          version: QrVersions.auto,
                          size: 200.0,
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Align(
                        alignment: Alignment.centerRight,
                        child: ElevatedButton(
                          onPressed: () => _showCancelConfirmationDialog(context),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                          child: const Text('Cancelar Reserva'),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              Card(
                elevation: 4,
                margin: const EdgeInsets.symmetric(vertical: 10),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Hacer Nueva Reserva:',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'Tipo de Comida',
                          border: OutlineInputBorder(),
                        ),
                        value: _selectedMealType,
                        items: (currentUser?.services ?? []).map((String service) {
                          return DropdownMenuItem<String>(
                            value: service,
                            child: Text(service),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedMealType = newValue;
                          });
                        },
                      ),
                      const SizedBox(height: 10),
                      ListTile(
                        title: Text(_selectedDate == null ? 'Seleccionar Fecha' : 'Fecha: ${_selectedDate!.toLocal().toString().split(' ')[0]}'),
                        trailing: const Icon(Icons.calendar_today),
                        onTap: () => _selectDate(context),
                      ),
                      ListTile(
                        title: Text(_selectedTime == null ? 'Seleccionar Hora' : 'Hora: ${_selectedTime!.format(context)}'),
                        trailing: const Icon(Icons.access_time),
                        onTap: () => _selectTime(context),
                      ),
                      const SizedBox(height: 20),
                      Center(
                        child: ElevatedButton(
                          onPressed: _makeReservation,
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                          child: const Text('Confirmar Reserva'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'Historial',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.qr_code),
            label: 'QR',
          ),
        ],
        currentIndex: 0, // Inicia en la pestaña de inicio
        selectedItemColor: Colors.green,
        onTap: (index) {
          if (index == 1) { // Historial
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const HistoryPage()),
            );
          } else if (index == 2) { // QR
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const QRPage()),
            );
          }
          // Si es 0 (Inicio), ya estamos aquí, no hacemos nada
        },
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Profile Page
// -----------------------------------------------------------------------------
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    // Si necesitas recargar los datos del usuario desde la DB, puedes llamar a una API aquí.
    // Por ahora, usamos el currentUser global que se carga en el login.
    if (currentUser == null) {
      print("Error: No hay usuario logueado en la página de perfil.");
      // Podrías redirigir al login si esto ocurre.
      return;
    }
    // Asegurarse de que streakCount y points estén actualizados si el backend los envía
    setState(() {
      streakCount = currentUser!.streakCount; // Actualizar la variable global
      points = currentUser!.points;           // Actualizar la variable global
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Perfil'),
        backgroundColor: Colors.green,
      ),
      body: currentUser == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 4,
              margin: const EdgeInsets.only(bottom: 20),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Datos Personales', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.person),
                      title: const Text('Nombre Completo'),
                      subtitle: Text('${currentUser!.nombre} ${currentUser!.apellido}'),
                    ),
                    ListTile(
                      leading: const Icon(Icons.school),
                      title: const Text('Código Estudiantil'),
                      subtitle: Text(currentUser!.codigoEstudiantil),
                    ),
                    ListTile(
                      leading: const Icon(Icons.email),
                      title: const Text('Correo Institucional'),
                      subtitle: Text(currentUser!.email),
                    ),
                    ListTile(
                      leading: const Icon(Icons.fastfood),
                      title: const Text('Servicios Activos'),
                      subtitle: Text(currentUser!.services.join(', ')),
                    ),
                  ],
                ),
              ),
            ),
            Card(
              elevation: 4,
              margin: const EdgeInsets.only(bottom: 20),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Estadísticas', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.star, color: Colors.amber),
                      title: const Text('Racha de Reservas (Streak)'),
                      subtitle: Text('${currentUser!.streakCount} días'), // Usar del objeto currentUser
                    ),
                    ListTile(
                      leading: const Icon(Icons.emoji_events, color: Colors.blue),
                      title: const Text('Puntos Acumulados'),
                      subtitle: Text('${currentUser!.points} puntos'), // Usar del objeto currentUser
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: Column(
                children: [
                  ElevatedButton.icon(
                    onPressed: () async {
                      final bool? updated = await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const UpdateDataPage()),
                      );
                      if (updated == true) {
                        // Después de actualizar, recargar los datos del usuario.
                        // Lo más seguro es volver a hacer una petición de login o un endpoint específico para el usuario.
                        // Para simplificar, si se actualizó, podemos asumir que se actualizó el objeto global.
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Datos actualizados con éxito!')),
                        );
                        // Idealmente, recargar currentUser aquí si la API de actualización retorna el usuario completo.
                        // Por ahora, como el método de actualización en la página UpdateDataPage actualiza el currentUser localmente,
                        // no necesitamos una llamada extra aquí. Solo un setState para que el widget se redibuje.
                        setState(() {});
                      }
                    },
                    icon: const Icon(Icons.edit),
                    label: const Text('Actualizar Datos'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    ),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton.icon(
                    onPressed: () async {
                      final bool? passwordChanged = await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ChangePasswordPage()),
                      );
                      if (passwordChanged == true) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Contraseña actualizada con éxito!')),
                        );
                      }
                    },
                    icon: const Icon(Icons.lock_reset),
                    label: const Text('Cambiar Contraseña'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    ),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton.icon(
                    onPressed: () {
                      currentUser = null; // Limpiar usuario al cerrar sesión
                      reservaGlobal = null; // Limpiar reserva al cerrar sesión
                      pedidoConfirmado = false;
                      historyList = [];
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => const LoginPage()),
                            (Route<dynamic> route) => false,
                      );
                    },
                    icon: const Icon(Icons.logout),
                    label: const Text('Cerrar Sesión'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Update Data Page
// -----------------------------------------------------------------------------
class UpdateDataPage extends StatefulWidget {
  const UpdateDataPage({super.key});

  @override
  State<UpdateDataPage> createState() => _UpdateDataPageState();
}

class _UpdateDataPageState extends State<UpdateDataPage> {
  late TextEditingController _nombreController;
  late TextEditingController _apellidoController;
  late TextEditingController _emailController;
  final List<String> _selectedServices = [];

  @override
  void initState() {
    super.initState();
    // Inicializar controladores con los datos del usuario actual
    _nombreController = TextEditingController(text: currentUser?.nombre ?? '');
    _apellidoController = TextEditingController(text: currentUser?.apellido ?? '');
    _emailController = TextEditingController(text: currentUser?.email ?? '');
    if (currentUser != null) {
      _selectedServices.addAll(currentUser!.services);
    }
  }

  void _updateData() async {
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: No hay usuario logueado.')),
      );
      return;
    }

    final Map<String, dynamic> dataToUpdate = {
      'nombre': _nombreController.text,
      'apellido': _apellidoController.text,
      'email': _emailController.text,
      'services': _selectedServices,
    };

    // Usar ApiDatabase en lugar de MongoDatabase
    bool success = await ApiDatabase.updateUserData(currentUser!.id, dataToUpdate);

    if (!mounted) return;

    if (success) {
      // Actualizar el objeto currentUser global después de una actualización exitosa
      // Esto es crucial para que los cambios se reflejen en la app.
      setState(() {
        currentUser!.nombre = _nombreController.text;
        currentUser!.apellido = _apellidoController.text;
        currentUser!.email = _emailController.text;
        currentUser!.services = _selectedServices;
      });
      Navigator.pop(context, true); // Volver y pasar true para indicar éxito
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al actualizar datos. Inténtalo de nuevo.')),
      );
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _apellidoController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Actualizar Datos'),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nombreController,
              decoration: const InputDecoration(labelText: 'Nombre'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _apellidoController,
              decoration: const InputDecoration(labelText: 'Apellido'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Correo Institucional'),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 20),
            const Text('Servicios de comedor:', style: TextStyle(fontSize: 16)),
            CheckboxListTile(
              title: const Text('Almuerzo'),
              value: _selectedServices.contains('Almuerzo'),
              onChanged: (bool? value) {
                setState(() {
                  if (value == true) {
                    _selectedServices.add('Almuerzo');
                  } else {
                    _selectedServices.remove('Almuerzo');
                  }
                });
              },
            ),
            CheckboxListTile(
              title: const Text('Cena'),
              value: _selectedServices.contains('Cena'),
              onChanged: (bool? value) {
                setState(() {
                  if (value == true) {
                    _selectedServices.add('Cena');
                  } else {
                    _selectedServices.remove('Cena');
                  }
                });
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _updateData,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: const Text('Guardar Cambios'),
            ),
          ],
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Change Password Page
// -----------------------------------------------------------------------------
class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  // Eliminado el controlador de contraseña actual si no se va a validar en el cliente.
  // Si la validación es con el backend, solo necesitas la nueva contraseña.
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmNewPasswordController = TextEditingController();

  void _changePassword() async { // Hacer el método async
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: No hay usuario logueado.')),
      );
      return;
    }

    final String newPassword = _newPasswordController.text;
    final String confirmNewPassword = _confirmNewPasswordController.text;

    if (newPassword.isEmpty || newPassword != confirmNewPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('La nueva contraseña no coincide o está vacía.')),
      );
      return;
    }

    // Usar ApiDatabase para actualizar la contraseña en el backend
    bool success = await ApiDatabase.updatePassword(currentUser!.id, newPassword);

    if (!mounted) return; // Asegurarse de que el widget sigue montado

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Contraseña actualizada con éxito!')),
      );
      Navigator.pop(context, true); // Volver y pasar true para indicar éxito
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al cambiar contraseña. Inténtalo de nuevo.')),
      );
    }
  }

  @override
  void dispose() {
    // _currentPasswordController.dispose(); // Eliminar si no se usa
    _newPasswordController.dispose();
    _confirmNewPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cambiar Contraseña'),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Si el backend valida la contraseña actual, aquí deberías pedirla.
            // Por simplicidad, por ahora solo pedimos la nueva contraseña.
            // Si necesitas validar la contraseña actual, tendrías que enviar
            // tanto la contraseña actual como la nueva al backend.
            /*
            TextField(
              controller: _currentPasswordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Contraseña Actual'),
            ),
            const SizedBox(height: 12),
            */
            TextField(
              controller: _newPasswordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Nueva Contraseña'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _confirmNewPasswordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Confirmar Nueva Contraseña'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _changePassword,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: const Text('Cambiar Contraseña'),
            ),
          ],
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// History Page
// -----------------------------------------------------------------------------
class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    if (currentUser == null) {
      print("Error: No hay usuario logueado para cargar el historial.");
      setState(() {
        historyList = []; // Limpiar historial si no hay usuario
      });
      return;
    }
    // Usar ApiDatabase en lugar de MongoDatabase
    final fetchedHistory = await ApiDatabase.getReservationsHistory(currentUser!.id);
    setState(() {
      historyList = fetchedHistory;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial de Reservas'),
        backgroundColor: Colors.green,
      ),
      body: historyList.isEmpty
          ? const Center(child: Text('No tienes reservas en tu historial.'))
          : ListView.builder(
        itemCount: historyList.length,
        itemBuilder: (context, index) {
          final reserva = historyList[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Tipo: ${reserva.tipo}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Text('Fecha: ${reserva.fecha.day}/${reserva.fecha.month}/${reserva.fecha.year}'),
                  Text('Hora: ${reserva.hora.format(context)}'),
                  // Puedes añadir más detalles aquí si tu objeto Reserva tiene más campos
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// QR Page
// -----------------------------------------------------------------------------
class QRPage extends StatelessWidget {
  const QRPage({super.key});

  @override
  Widget build(BuildContext context) {
    if (reservaGlobal == null || currentUser == null) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.green,
          title: const Text('Código QR'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('No hay reserva activa para mostrar.', style: TextStyle(fontSize: 18, color: Colors.grey)),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                child: const Text('Volver a Inicio'),
              ),
            ],
          ),
        ),
      );
    }

    // Datos del QR ahora incluyen el ID del usuario para mayor unicidad y validación
    final String qrData =
        'Reserva ID: ${currentUser!.id}\nTipo: ${reservaGlobal!.tipo}\nFecha: ${reservaGlobal!.fecha.day}/${reservaGlobal!.fecha.month}/${reservaGlobal!.fecha.year}\nHora: ${reservaGlobal!.hora.format(context)}';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: const Text('Código QR'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Reserva para ${reservaGlobal!.tipo}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            QrImageView(
              data: qrData,
              version: QrVersions.auto,
              size: 250.0,
            ),
            const SizedBox(height: 20),
            Text(
              'Fecha: ${reservaGlobal!.fecha.day}/${reservaGlobal!.fecha.month}/${reservaGlobal!.fecha.year}',
              style: const TextStyle(fontSize: 16),
            ),
            Text(
              'Hora: ${reservaGlobal!.hora.format(context)}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 30),
            // Eliminamos el botón "Pedido Confirmado" de la página de QR.
            // La confirmación del pedido y el manejo de racha/puntos debería
            // ser manejado por el backend o en otro punto de la aplicación
            // (ej. cuando se escanea el QR en el comedor).
            // Si tu lógica requiere que el usuario haga clic para confirmar la racha,
            // ese botón debería estar en una página más apropiada.
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Simplemente vuelve atrás
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
              child: const Text('Volver'),
            ),
          ],
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Rewards Page
// -----------------------------------------------------------------------------
class RewardsPage extends StatefulWidget {
  const RewardsPage({super.key});

  @override
  State<RewardsPage> createState() => _RewardsPageState();
}

class _RewardsPageState extends State<RewardsPage> {
  @override
  Widget build(BuildContext context) {
    // Accede a los valores directamente desde currentUser
    int displayStreak = currentUser?.streakCount ?? 0;
    int displayPoints = currentUser?.points ?? 0;

    // La lógica de canClaim debería venir del backend si un streak/puntos ya se reclamó.
    // Por ahora, si hay reserva activa y no se ha "confirmado" el pedido,
    // podríamos permitir reclamar la racha para la reserva *actual*.
    // Esto es una simplificación y la lógica real de negocio debe estar en el backend.
    bool canClaim = pedidoConfirmado; // Si hay un pedido activo (reservaGlobal != null) se puede reclamar

    return Scaffold(
      appBar: AppBar(
        title: const Text('Recompensas'),
        backgroundColor: Colors.green,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Image.asset(
              'assets/fire.jpeg',
              height: 100,
            ),
            const SizedBox(height: 10),
            Text(
              'Puntos acumulados',
              style: TextStyle(fontSize: 18, color: Colors.green[800]),
            ),
            Text(
              '$displayStreak racha = 100 pts.', // Muestra la racha actual del usuario
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 10),
            Text(
              '${displayPoints} pts.', // Muestra los puntos actuales del usuario
              style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              // Este botón debería interactuar con el backend para actualizar racha y puntos
              // y marcar la reserva como "usada" o "confirmada" para evitar dobles reclamos.
              onPressed: canClaim
                  ? () async {
                if (currentUser == null) return;
                // Llama a una API en tu backend para reclamar la recompensa
                // Esto es un ejemplo, necesitarías un endpoint API real para esto.
                // Por ejemplo, await ApiDatabase.claimReward(currentUser!.id);
                // Si la recompensa se reclama con éxito:
                setState(() {
                  // Actualiza localmente (idealmente, estos valores vendrían del backend)
                  currentUser!.streakCount += 1;
                  currentUser!.points += 100;
                  // Reinicia la variable local para que no se pueda reclamar la misma reserva.
                  // Esto debería ser un estado que el backend maneje por reserva.
                  pedidoConfirmado = false;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('¡Recompensa reclamada! +100 puntos y +1 racha')),
                );
              }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              ),
              child: const Text(
                'Reclamar recompensa',
                style: TextStyle(fontSize: 18),
              ),
            ),
            const SizedBox(height: 30),
            Text(
              'Canjea marcos para perfil',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.green[800]),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: 15,
                itemBuilder: (context, index) {
                  return Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey, width: 2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text('${100 + index * 10} pts.'),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Profile Page
// -----------------------------------------------------------------------------
class ProfilePage2 extends StatelessWidget {
  const ProfilePage2({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF7AC943),
        title: const Text('Perfil', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          Center(
            child: Stack(
              alignment: Alignment.bottomRight,
              children: [
                const CircleAvatar(
                  radius: 80,
                  backgroundImage: AssetImage('assets/avatar.jpeg'),
                ),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(Icons.edit, color: Colors.white, size: 20),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _buildProfileOption(
            context,
            'Actualización de datos',
            'Cambiar',
            () async { // Hacer async para esperar el pop con resultado
              final bool? updated = await Navigator.push(context, MaterialPageRoute(builder: (_) => const UpdateDataPage()));
              if (updated == true) {
                // Cuando UpdateDataPage regresa true, se sabe que los datos se actualizaron.
                // En este punto, no se necesita un setState aquí en ProfilePage porque
                // UpdateDataPage ya actualizó currentUser global y ProfilePage es StatelessWidget.
                // Si ProfilePage fuera StatefulWidget, podrías hacer setState para forzar el redibujo.
                // Dado que es StatelessWidget, los cambios en currentUser se reflejarán si se vuelve a la página.
                // Si necesitas que los datos del perfil se actualicen de inmediato sin salir de la página,
                // ProfilePage debería ser un StatefulWidget y recargar currentUser en un setState.
              }
            },
          ),
          _buildProfileOption(
            context,
            'Mis recompensas',
            'Ver',
            () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const RewardsPage()));
            },
          ),
          _buildProfileOption(
            context,
            'Historial',
            'Ver',
            () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const HistoryPage()));
            },
          ),
          _buildProfileOption(
            context,
            'Cambiar contraseña',
            'Ir',
            () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const ChangePasswordPage()));
            },
          ),
          _buildProfileOption(
            context,
            'Cerrar Sesión',
            '',
            () {
              currentUser = null; // Limpiar usuario al cerrar sesión
              reservaGlobal = null; // Limpiar reserva al cerrar sesión
              pedidoConfirmado = false;
              historyList = [];
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
                (Route<dynamic> route) => false,
              );
            },
            leadingIcon: Icons.logout,
            showArrow: false,
          ),
        ],
      ),
    );
  }

  Widget _buildProfileOption(BuildContext context, String title, String actionText, VoidCallback onTap, {IconData? leadingIcon, bool showArrow = true}) {
    return Column(
      children: [
        ListTile(
          leading: leadingIcon != null ? Icon(leadingIcon, color: Colors.grey[700]) : null,
          title: Text(title),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(actionText, style: TextStyle(color: Colors.grey[600])),
              if (showArrow) const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            ],
          ),
          onTap: onTap,
        ),
        const Divider(height: 1, indent: 16, endIndent: 16),
      ],
    );
  }
}