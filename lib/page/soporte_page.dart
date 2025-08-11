import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class SoportePage extends StatefulWidget {
  const SoportePage({Key? key}) : super(key: key);

  @override
  State<SoportePage> createState() => _SoportePageState();
}

class _SoportePageState extends State<SoportePage> {
  Future<void> _abrirUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo abrir el enlace')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0C2A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A40),
        title: const Text(
          'Soporte Técnico',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.cyanAccent),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              color: const Color(0xFF1A1A40),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Información de contacto',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.cyanAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Desarrollador: Ing. William Jacome',
                      style: TextStyle(color: Colors.white),
                    ),
                    Text(
                      'Número: 0986006211',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Card(
              color: const Color(0xFF1A1A40),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.cyanAccent,
                      ),
                      icon: const Icon(Icons.facebook, color: Colors.black),
                      label: const Text(
                        'Ir a Facebook',
                        style: TextStyle(color: Colors.black),
                      ),
                      onPressed:
                          () => _abrirUrl(
                            'https://www.facebook.com/javierjacome11/',
                          ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.greenAccent,
                      ),
                      icon: const Icon(Icons.message, color: Colors.black),
                      label: const Text(
                        'Chatear por WhatsApp',
                        style: TextStyle(color: Colors.black),
                      ),
                      onPressed: () => _abrirUrl('https://wa.me/593986006211'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
