import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();
  bool _loading = false;

  void _showSnackbar(String message, {bool success = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: success ? Colors.green : Colors.red,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _register() {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirm = _confirmController.text.trim();

    if (email.isEmpty || password.isEmpty || confirm.isEmpty) {
      _showSnackbar('Completa todos los campos');
      return;
    }

    if (password != confirm) {
      _showSnackbar('Las contraseñas no coinciden');
      return;
    }

    setState(() => _loading = true);

    FirebaseAuth.instance
        .createUserWithEmailAndPassword(email: email, password: password)
        .then((_) async {
          if (!mounted) return;
          _showSnackbar('✅ Registro exitoso', success: true);
          await Future.delayed(const Duration(seconds: 2));
          if (mounted) Navigator.pop(context); // Volver al login
        })
        .catchError((e) async {
          // Si el error es causado por Pigeon, igual mostramos éxito
          if (!mounted) return;
          final user = FirebaseAuth.instance.currentUser;
          if (user != null) {
            _showSnackbar('✅ Registro exitoso', success: true);
            await Future.delayed(const Duration(seconds: 2));
            if (mounted) Navigator.pop(context); // Volver al login
          } else {
            _showSnackbar('⚠️ Error durante el registro');
          }
        })
        .whenComplete(() {
          if (mounted) setState(() => _loading = false);
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Registro'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: ListView(
            shrinkWrap: true,
            children: [
              Image.asset('lib/assets/logoAvianca.png', height: 80),
              const SizedBox(height: 20),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Correo'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Contraseña'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _confirmController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Confirmar contraseña',
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _loading ? null : _register,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child:
                    _loading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Registrarse'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
