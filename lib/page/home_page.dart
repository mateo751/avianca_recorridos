import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:taxi_recorridos_app/page/registro_excel.dart';
import 'package:taxi_recorridos_app/page/perfil_page.dart';
import 'package:taxi_recorridos_app/page/soporte_page.dart';
import 'package:taxi_recorridos_app/widgets/bottom_nav.dart';

class HomePage extends StatefulWidget {
  final User user;

  const HomePage({Key? key, required this.user}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  int _selectedTile = 0;
  final PageController _pageController = PageController();

  final List<String> imageUrls = [
    'https://media.istockphoto.com/id/1454401772/es/vector/velocidad-abstracta-inicio-de-negocios-lanzamiento-de-producto-con-concepto-de-autom%C3%B3vil.jpg?s=612x612&w=0&k=20&c=tK05m2RbDREhnFXJim8MF8BqxWMKZovyHUUllrM854M=',
    'https://media.istockphoto.com/id/890204750/es/foto/concepto-de-transporte-y-dise%C3%B1o.jpg?s=170667a&w=0&k=20&c=LN0xKQ2hLqolsIA7T1MRfXMr9eIRr5CUsKuWzFBXsGQ=',
  ];

  final List<Map<String, dynamic>> options = [
    {'label': 'Inicio', 'icon': Icons.dashboard_customize},
    {'label': 'Registros', 'icon': Icons.receipt_long},
    {'label': 'Perfil', 'icon': Icons.person},
    {'label': 'Soporte', 'icon': Icons.support_agent},
  ];

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0C2A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Panel de Control',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            shadows: [Shadow(color: Colors.cyanAccent, blurRadius: 10)],
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            SizedBox(
              height: 160,
              child: PageView.builder(
                controller: _pageController,
                itemCount: imageUrls.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.network(
                        imageUrls[index],
                        fit: BoxFit.cover,
                        width: double.infinity,
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A40),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.cyanAccent.withOpacity(0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 25,
                    backgroundColor: Colors.cyanAccent,
                    child: Icon(Icons.person, size: 28, color: Colors.black),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hola, ${widget.user.email ?? "Usuario"}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const Text(
                          'Conectado al sistema',
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.bolt, color: Colors.cyanAccent, size: 28),
                ],
              ),
            ),
            const SizedBox(height: 30),
            Expanded(
              child: GridView.builder(
                itemCount: options.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 20,
                  crossAxisSpacing: 20,
                ),
                itemBuilder: (context, index) {
                  final item = options[index];
                  final isSelected = _selectedTile == index;

                  return GestureDetector(
                    onTap: () {
                      setState(() => _selectedTile = index);

                      if (item['label'] == 'Registros') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const RegistroExcelPage(),
                          ),
                        );
                      } else if (item['label'] == 'Perfil') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const PerfilPage()),
                        );
                      } else if (item['label'] == 'Soporte') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const SoportePage(),
                          ),
                        );
                      }
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        gradient:
                            isSelected
                                ? const LinearGradient(
                                  colors: [
                                    Color(0xFF00EFFF),
                                    Color(0xFF008EFF),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                )
                                : null,
                        color: isSelected ? null : const Color(0xFF1A1A40),
                        boxShadow:
                            isSelected
                                ? [
                                  BoxShadow(
                                    color: Colors.cyanAccent.withOpacity(0.4),
                                    blurRadius: 12,
                                    offset: const Offset(0, 6),
                                  ),
                                ]
                                : [],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            item['icon'],
                            color:
                                isSelected ? Colors.white : Colors.cyanAccent,
                            size: 36,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            item['label'],
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.white70,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavBar(selectedIndex: _selectedIndex),
    );
  }
}
