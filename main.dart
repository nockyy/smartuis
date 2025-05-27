import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class Reserva {
  String tipo;
  DateTime fecha;
  TimeOfDay hora;

  Reserva({required this.tipo, required this.fecha, required this.hora});
}

Reserva? reservaGlobal;
bool pedidoConfirmado = false;

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

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              Image.asset(
                'assets/logo.jpeg',
                height: 120,
              ),
              const SizedBox(height: 20),
              Center(
                child: Text(
                  'smart UIS comedores',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green[800]),
                ),
              ),
              const SizedBox(height: 30),
              const TextField(
                decoration: InputDecoration(labelText: 'Usuario'),
              ),
              const SizedBox(height: 12),
              const TextField(
                obscureText: true,
                decoration: InputDecoration(labelText: 'Contraseña'),
              ),
              TextButton(
                onPressed: () {},
                child: const Text('¿Olvidaste tu contraseña?'),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const InstructionsPage()),
                  );
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                child: const Text('Entrar'),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.facebook, color: Colors.blue),
                  SizedBox(width: 20),
                  Icon(Icons.g_mobiledata, color: Colors.red),
                  SizedBox(width: 20),
                  Icon(Icons.apple, color: Colors.black),
                ],
              ),
              const Spacer(),
              Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const RegisterPage()),
                    );
                  },
                  child: const Text('¿No tienes una cuenta? Regístrate'),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final List<String> _selectedServices = [];

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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: const Text('Registro de datos'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const TextField(
                decoration: InputDecoration(labelText: 'Correo Electrónico'),
              ),
              const TextField(
                decoration: InputDecoration(labelText: 'Apellido'),
              ),
              const TextField(
                decoration: InputDecoration(labelText: 'Nombre'),
              ),
              const TextField(
                decoration: InputDecoration(labelText: 'Código Estudiantil'),
              ),
              const TextField(
                obscureText: true,
                decoration: InputDecoration(labelText: 'Contraseña'),
              ),
              const TextField(
                obscureText: true,
                decoration: InputDecoration(labelText: 'Confirmar Contraseña'),
              ),
              const SizedBox(height: 20),
              Text('Servicios adjudicados', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.green[800])),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8.0,
                children: [
                  _buildServiceChip('Desayuno'),
                  _buildServiceChip('Almuerzo'),
                  _buildServiceChip('Cena'),
                ],
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                  );
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                child: const Text('Registrarse'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildServiceChip(String service) {
    final isSelected = _selectedServices.contains(service);
    return ActionChip(
      label: Text(service),
      backgroundColor: isSelected ? Colors.green[700] : Colors.grey[300],
      labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black),
      onPressed: () => _toggleService(service),
      side: BorderSide(color: isSelected ? Colors.green : Colors.transparent),
    );
  }
}

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

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  void _showCancelConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text("Confirmar Cancelación"),
          content: const Text("¿Estás seguro de que quieres cancelar tu reserva?"),
          actions: <Widget>[
            TextButton(
              child: const Text("Volver"),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text("Confirmar"),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                setState(() {
                  reservaGlobal = null;
                  pedidoConfirmado = false;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Reserva cancelada exitosamente!')),
                );
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF7AC943),
        title: const Text(
          '221039 Daniel Muñoz',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const LoginPage()),
            );
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            Stack(
              alignment: Alignment.topRight,
              children: [
                const CircleAvatar(
                  radius: 150,
                  backgroundImage: AssetImage('assets/avatar.jpeg'),
                ),
                if (!pedidoConfirmado)
                  InkWell(
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const RewardsPage())).then((_) {
                        setState(() {});
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Image.asset(
                        'assets/hielo.jpeg',
                        height: 30,
                        width: 30,
                      ),
                    ),
                  ),
                if (pedidoConfirmado)
                  InkWell(
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const RewardsPage())).then((_) {
                        setState(() {});
                      });
                    },
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Image.asset(
                            'assets/fire.jpeg',
                            height: 30,
                            width: 30,
                          ),
                        ),
                        const Text(
                          '1', // Always display '1' when confirmed for the initial streak
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  MealToggle(label: 'Desayuno'),
                  MealToggle(label: 'Almuerzo', selected: true),
                  MealToggle(label: 'Cena'),
                ],
              ),
            ),
            const SizedBox(height: 20),
            if (reservaGlobal != null)
              Column(
                children: [
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 30),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF7AC943),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'Reserva activa:',
                          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${reservaGlobal!.tipo} - ${reservaGlobal!.fecha.day}/${reservaGlobal!.fecha.month}/${reservaGlobal!.fecha.year} - ${reservaGlobal!.hora.format(context)}',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const ReservationPage()));
                    },
                    icon: const Icon(Icons.restaurant),
                    label: const Text('Ver Reserva'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const QRPage())).then((result) {
                        setState(() {});
                      });
                    },
                    icon: const Icon(Icons.qr_code),
                    label: const Text('Ver QR'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton.icon(
                    onPressed: _showCancelConfirmationDialog,
                    icon: const Icon(Icons.cancel),
                    label: const Text('Cancelar Reserva'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  ),
                ],
              )
            else
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 30),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF7AC943),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    const Center(
                      child: Text(
                        'No tienes ninguna reserva activa',
                        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const ReservationPage())).then((_) {
                          setState(() {});
                        });
                      },
                      icon: const Icon(Icons.calendar_month),
                      label: const Text('Reservar Ahora'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: const Color(0xFF7AC943),
        unselectedItemColor: Colors.grey,
        currentIndex: 0,
        onTap: (index) {
          if (index == 0) {
          } else if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ReservationPage()),
            ).then((_) {
              setState(() {});
            });
          } else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ProfilePage()),
            ).then((_) {
              setState(() {});
            });
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            label: 'Reserva',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Config.',
          ),
        ],
      ),
    );
  }
}

class MealToggle extends StatelessWidget {
  final String label;
  final bool selected;

  const MealToggle({super.key, required this.label, this.selected = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: selected ? const Color(0xFF7AC943) : Colors.grey.shade300,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: selected ? Colors.white : Colors.black,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/logo.jpeg', height: 150),
            const SizedBox(height: 20),
            Text(
              'Smart UIS Comedores',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.green[800],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ReservationPage extends StatefulWidget {
  const ReservationPage({super.key});

  @override
  State<ReservationPage> createState() => _ReservationPageState();
}

class _ReservationPageState extends State<ReservationPage> {
  String selectedMeal = 'Almuerzo';
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();

  @override
  void initState() {
    super.initState();
    if (reservaGlobal != null) {
      selectedMeal = reservaGlobal!.tipo;
      selectedDate = reservaGlobal!.fecha;
      selectedTime = reservaGlobal!.hora;
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
      locale: const Locale('es', 'ES'),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime,
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
          child: child!,
        );
      },
    );
    if (picked != null && picked != selectedTime) {
      setState(() {
        selectedTime = picked;
      });
    }
  }

  void _showReservationConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text("Confirmar Reserva"),
          content: Text(
              "¿Estás seguro de que quieres reservar $selectedMeal para el ${selectedDate.day}/${selectedDate.month}/${selectedDate.year} a las ${selectedTime.format(context)}?"),
          actions: <Widget>[
            TextButton(
              child: const Text("Volver"),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: const Text("Confirmar"),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _saveReservation();
              },
            ),
          ],
        );
      },
    );
  }

  void _saveReservation() {
    setState(() {
      reservaGlobal = Reserva(
        tipo: selectedMeal,
        fecha: selectedDate,
        hora: selectedTime,
      );
      pedidoConfirmado = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('¡Reserva guardada exitosamente!')),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reservar comida'),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              value: selectedMeal,
              items: ['Desayuno', 'Almuerzo', 'Cena']
                  .map((meal) => DropdownMenuItem(
                        value: meal,
                        child: Text(meal),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  selectedMeal = value!;
                });
              },
              decoration: const InputDecoration(
                labelText: 'Tipo de comida',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              title: Text('Fecha: ${selectedDate.day}/${selectedDate.month}/${selectedDate.year}'),
              trailing: const Icon(Icons.calendar_today),
              onTap: () => _selectDate(context),
            ),
            ListTile(
              title: Text('Hora: ${selectedTime.format(context)}'),
              trailing: const Icon(Icons.access_time),
              onTap: () => _selectTime(context),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _showReservationConfirmationDialog,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: const Text('Reservar'),
            ),
            const SizedBox(height: 30),
            if (reservaGlobal != null)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green[100],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Tienes una reserva activa:', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text('Comida: ${reservaGlobal!.tipo}'),
                    Text('Fecha: ${reservaGlobal!.fecha.day}/${reservaGlobal!.fecha.month}/${reservaGlobal!.fecha.year}'),
                    Text('Hora: ${reservaGlobal!.hora.format(context)}'),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class QRPage extends StatelessWidget {
  const QRPage({super.key});

  @override
  Widget build(BuildContext context) {
    if (reservaGlobal == null) {
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

    final String qrData =
        'Tipo: ${reservaGlobal!.tipo}\nFecha: ${reservaGlobal!.fecha.day}/${reservaGlobal!.fecha.month}/${reservaGlobal!.fecha.year}\nHora: ${reservaGlobal!.hora.format(context)}';

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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                  child: const Text('Volver'),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Add the confirmed reservation to history
                    if (reservaGlobal != null) {
                      historyList.add(reservaGlobal!);
                    }
                    reservaGlobal = null;
                    pedidoConfirmado = true; // Set to true when confirmed, indicating a streak
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  child: const Text('Pedido Confirmado'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class RewardsPage extends StatefulWidget {
  const RewardsPage({super.key});

  @override
  State<RewardsPage> createState() => _RewardsPageState();
}

class _RewardsPageState extends State<RewardsPage> {
  @override
  Widget build(BuildContext context) {
    int displayStreak = streakCount;
    int displayPoints = points;
    bool canClaim = false;

    // Logic to determine points/streak to display and if claim is possible
    if (pedidoConfirmado && streakCount == 0) {
      displayStreak = 1;
      displayPoints = 100;
      canClaim = true;
    } else if (pedidoConfirmado && streakCount > 0) {
      canClaim = true;
    }

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
              '$displayStreak racha = 100 pts.',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 10),
            Text(
              '${points} pts.', // Always show actual accumulated points here
              style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: canClaim
                  ? () {
                      setState(() {
                        streakCount += 1;
                        points += 100;
                        pedidoConfirmado = false; // Reset after claiming the streak
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

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

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
            () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const UpdateDataPage()));
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

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial de Reservas'),
        backgroundColor: Colors.green,
      ),
      body: historyList.isEmpty
          ? const Center(
              child: Text('No tienes reservas confirmadas en tu historial.'),
            )
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
                        Text(
                          'Tipo: ${reserva.tipo}',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 4),
                        Text('Fecha: ${reserva.fecha.day}/${reserva.fecha.month}/${reserva.fecha.year}'),
                        Text('Hora: ${reserva.hora.format(context)}'),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class UpdateDataPage extends StatelessWidget {
  const UpdateDataPage({super.key});

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
            const TextField(
              decoration: InputDecoration(labelText: 'Nombre'),
            ),
            const SizedBox(height: 12),
            const TextField(
              decoration: InputDecoration(labelText: 'Apellido'),
            ),
            const SizedBox(height: 12),
            const TextField(
              decoration: InputDecoration(labelText: 'Correo Electrónico'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Datos actualizados!')),
                );
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: const Text('Guardar Cambios'),
            ),
          ],
        ),
      ),
    );
  }
}

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final TextEditingController _currentPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmNewPasswordController = TextEditingController();

  void _changePassword() {
    if (_newPasswordController.text != _confirmNewPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Las nuevas contraseñas no coinciden.')),
      );
    } else if (_newPasswordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('La nueva contraseña no puede estar vacía.')),
      );
    } else {
      // Here you would typically add logic to validate the current password
      // and update it in your backend/local storage.
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Contraseña cambiada exitosamente!')),
      );
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
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
            TextField(
              controller: _currentPasswordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Contraseña Actual'),
            ),
            const SizedBox(height: 12),
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
