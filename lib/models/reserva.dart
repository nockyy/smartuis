// lib/models/reserva.dart
import 'package:flutter/material.dart'; // Necesitas TimeOfDay

class Reserva {
  String tipo;
  DateTime fecha;
  TimeOfDay hora;

  Reserva({required this.tipo, required this.fecha, required this.hora});

  // Si necesitas convertir Reserva a JSON para enviar al backend:
  Map<String, dynamic> toJson() {
    return {
      'tipo': tipo,
      'fecha': fecha.toIso8601String().split('T')[0], // Formato 'YYYY-MM-DD'
      'hora': '${hora.hour.toString().padLeft(2, '0')}:${hora.minute.toString().padLeft(2, '0')}', // Formato 'HH:MM'
    };
  }

  // Si necesitas crear Reserva desde un JSON (por ejemplo, al recibirla del backend):
  factory Reserva.fromJson(Map<String, dynamic> json) {
    return Reserva(
      tipo: json['tipo'] as String,
      fecha: DateTime.parse(json['fecha'] as String),
      hora: TimeOfDay(
        hour: int.parse((json['hora'] as String).split(':')[0]),
        minute: int.parse((json['hora'] as String).split(':')[1]),
      ),
    );
  }
}