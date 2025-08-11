import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class PerfilPage extends StatefulWidget {
  const PerfilPage({Key? key}) : super(key: key);

  @override
  State<PerfilPage> createState() => _PerfilPageState();
}

class _PerfilPageState extends State<PerfilPage> {
  final user = FirebaseAuth.instance.currentUser;
  String? _fechaRegistro;

  @override
  void initState() {
    super.initState();
    _cargarDatosUsuario();
  }

  Future<void> _cargarDatosUsuario() async {
    final doc =
        await FirebaseFirestore.instance
            .collection('usuarios')
            .doc(user!.uid)
            .get();

    if (doc.exists && doc.data()!.containsKey('fechaRegistro')) {
      final timestamp = doc['fechaRegistro'] as Timestamp;
      final fecha = timestamp.toDate();
      final formato = DateFormat('dd/MM/yyyy');
      setState(() {
        _fechaRegistro = formato.format(fecha);
      });
    } else {
      final ahora = DateTime.now();
      final nuevaFecha = Timestamp.fromDate(ahora);
      await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(user!.uid)
          .set({'fechaRegistro': nuevaFecha});
      final formato = DateFormat('dd/MM/yyyy');
      setState(() {
        _fechaRegistro = formato.format(ahora);
      });
    }
  }

  Future<void> _cambiarContrasena() async {
    if (user != null && user!.email != null) {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: user!.email!);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Se envió un correo para cambiar la contraseña.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0C2A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A40),
        title: const Text('Mi Perfil', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.cyanAccent),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Card(
              color: const Color(0xFF1A1A40),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: ListTile(
                leading: const Icon(Icons.mail, color: Colors.cyanAccent),
                title: const Text(
                  'Correo electrónico',
                  style: TextStyle(color: Colors.white70),
                ),
                subtitle: Text(
                  user?.email ?? '',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Card(
              color: const Color(0xFF1A1A40),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: ListTile(
                leading: const Icon(
                  Icons.calendar_today,
                  color: Colors.cyanAccent,
                ),
                title: const Text(
                  'Fecha de registro',
                  style: TextStyle(color: Colors.white70),
                ),
                subtitle: Text(
                  _fechaRegistro ?? 'Cargando...',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
              ),
              icon: const Icon(Icons.lock_reset, color: Colors.white),
              label: const Text(
                'Cambiar contraseña',
                style: TextStyle(color: Colors.white),
              ),
              onPressed: _cambiarContrasena,
            ),
          ],
        ),
      ),
    );
  }
}
