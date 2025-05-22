import 'package:flutter/material.dart';

void main() {
  runApp(SmartUISApp());
}

class SmartUISApp extends StatelessWidget {
  const SmartUISApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginPage(),
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
              TextField(
                decoration: InputDecoration(labelText: 'Usuario'),
              ),
              const SizedBox(height: 12),
              TextField(
                obscureText: true,
                decoration: InputDecoration(labelText: 'Contraseña'),
              ),
              TextButton(
                onPressed: () {},
                child: Text('¿Olvidaste tu contraseña?'),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => HomePage()),
                    );
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                child: Text('Entrar'),
                
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
                      MaterialPageRoute(builder: (context) => RegisterPage()),
                    );
                  },
                  child: Text('¿No tienes una cuenta? Regístrate'),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Text('Registro de datos'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                decoration: InputDecoration(labelText: 'Correo Electrónico'),
              ),
              TextField(
                decoration: InputDecoration(labelText: 'Apellido'),
              ),
              TextField(
                decoration: InputDecoration(labelText: 'Nombre'),
              ),
              TextField(
                decoration: InputDecoration(labelText: 'Código Estudiantil'),
              ),
              TextField(
                obscureText: true,
                decoration: InputDecoration(labelText: 'Contraseña'),
              ),
              TextField(
                obscureText: true,
                decoration: InputDecoration(labelText: 'Confirmar Contraseña'),
              ),
              const SizedBox(height: 20),
              Text('Servicios adjudicados', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.green)),
              const SizedBox(height: 10),
              Chip(label: Text('Desayuno')),
              const SizedBox(height: 30),
              const SizedBox(height: 10),
              Chip(label: Text('Almuerzo')),
              const SizedBox(height: 30),
              const SizedBox(height: 10),
              Chip(label: Text('Cena')),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => LoginPage()),
                    );},
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                child: Text('Registrarse'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class HomePage extends StatelessWidget {
  const HomePage({super.key});

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
                      MaterialPageRoute(builder: (context) => LoginPage()),
                    );
          },
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          const CircleAvatar(
            radius: 150,
            backgroundImage: AssetImage('assets/avatar.jpeg'),
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
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 30),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Color(0xFF7AC943),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Center(
              child: Text(
                'No tienes ninguna reserva activa',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: const Color(0xFF7AC943),
        unselectedItemColor: Colors.grey,
        currentIndex: 0,
        onTap: (index) {},
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

