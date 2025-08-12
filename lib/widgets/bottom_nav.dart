import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:taxi_recorridos_app/auth/login_page.dart';
import 'package:taxi_recorridos_app/page/home_page.dart';
import 'package:taxi_recorridos_app/page/recorridos_page.dart';
import 'package:taxi_recorridos_app/page/perfil_page.dart';
import 'package:taxi_recorridos_app/page/soporte_page.dart';

class BottomNavBar extends StatefulWidget {
  final int selectedIndex;

  const BottomNavBar({Key? key, required this.selectedIndex}) : super(key: key);

  @override
  _BottomNavBarState createState() => _BottomNavBarState();

  // Método estático para crear el Drawer con estilo blanco moderno
  static Widget createDrawer(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white, // Fondo blanco
      child: SafeArea(
        child: Column(
          children: [
            // Header del drawer
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.white, // Fondo blanco para el header
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'CATEGORIES',
                        style: TextStyle(
                          color: Colors.black, // Texto negro
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.close,
                          color: Colors.black,
                        ), // Icono negro
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Lista de opciones del menú
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Column(
                  children: [
                    _buildDrawerItem(
                      context,
                      icon: Icons.home_outlined,
                      title: 'Inicio',
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder:
                                (_) => HomePage(
                                  user: FirebaseAuth.instance.currentUser!,
                                ),
                          ),
                        );
                      },
                    ),
                    _buildDrawerItem(
                      context,
                      icon: Icons.edit_outlined,
                      title: 'Registro',
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder:
                                (_) => RecorridosPage(
                                  user: FirebaseAuth.instance.currentUser!,
                                ),
                          ),
                        );
                      },
                    ),
                    _buildDrawerItem(
                      context,
                      icon: Icons.person_outline,
                      title: 'Perfil',
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const PerfilPage()),
                        );
                      },
                    ),
                    _buildDrawerItem(
                      context,
                      icon: Icons.support_agent_outlined,
                      title: 'Soporte',
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const SoportePage(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

            // Botón de Log out en la parte inferior con estilo verde
            Container(
              padding: const EdgeInsets.all(20),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.withOpacity(0.2)),
                ),
                child: ListTile(
                  leading: const Icon(
                    Icons.logout_outlined,
                    color: Color.fromARGB(
                      255,
                      255,
                      0,
                      0,
                    ), // Verde para el icono
                    size: 24,
                  ),
                  title: const Text(
                    'Cerrar sesión',
                    style: TextStyle(
                      color: Color.fromARGB(
                        255,
                        255,
                        0,
                        0,
                      ), // Verde para el texto
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  onTap: () async {
                    Navigator.pop(context);
                    await FirebaseAuth.instance.signOut();
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginPage()),
                      (route) => false,
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Método para crear cada item del drawer con estilo blanco
  static Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: Colors.black87, // Iconos en negro
          size: 24,
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.black87, // Texto en negro
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        // Efecto hover/tap sutil
        hoverColor: Colors.grey.withOpacity(0.05),
        splashColor: Colors.grey.withOpacity(0.1),
      ),
    );
  }
}

class _BottomNavBarState extends State<BottomNavBar> {
  void _onItemTapped(BuildContext context, int index) async {
    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => HomePage(user: FirebaseAuth.instance.currentUser!),
          ),
        );
        break;
      case 1:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder:
                (_) => RecorridosPage(user: FirebaseAuth.instance.currentUser!),
          ),
        );
        break;
      case 2:
        await FirebaseAuth.instance.signOut();
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginPage()),
          (route) => false,
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.bottomCenter,
      children: [
        Container(
          height: 80,
          decoration: const BoxDecoration(
            color: Color(0xFF1A1A40),
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
            boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10)],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                icon: Icon(
                  Icons.home,
                  color:
                      widget.selectedIndex == 0
                          ? Colors.cyanAccent
                          : Colors.white70,
                ),
                onPressed: () => _onItemTapped(context, 0),
              ),
              const SizedBox(width: 60),
              IconButton(
                icon: Icon(
                  Icons.logout,
                  color:
                      widget.selectedIndex == 2
                          ? Colors.cyanAccent
                          : Colors.white70,
                ),
                onPressed: () => _onItemTapped(context, 2),
              ),
            ],
          ),
        ),
        Positioned(
          top: -20,
          child: GestureDetector(
            onTap: () => _onItemTapped(context, 1),
            child: Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [Color(0xFF00EFFF), Color(0xFF3B8AC4)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.cyanAccent,
                    blurRadius: 12,
                    spreadRadius: 1,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: const Center(
                child: Icon(Icons.add, color: Colors.white, size: 36),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
