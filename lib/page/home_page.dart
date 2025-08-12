import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
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
  // Variable _selectedIndex eliminada - ya no se necesita
  List<Map<String, dynamic>> _registrosRecientes = [];
  bool _cargandoRegistros = true;

  @override
  void initState() {
    super.initState();
    _cargarRegistrosRecientes();
  }

  Future<void> _cargarRegistrosRecientes() async {
    try {
      final snapshot =
          await FirebaseFirestore.instance
              .collection('recorridos')
              .where('userId', isEqualTo: widget.user.uid)
              .orderBy('fecha', descending: true)
              .limit(5) // Solo los 5 más recientes
              .get();

      final datos =
          snapshot.docs
              .map((doc) {
                final data = doc.data();
                data['id'] = doc.id;
                return data;
              })
              .where((r) => r['nombreCliente'] != null && r['fecha'] != null)
              .toList();

      setState(() {
        _registrosRecientes = datos;
        _cargandoRegistros = false;
      });
    } catch (e) {
      print('Error al cargar registros: $e');
      setState(() {
        _cargandoRegistros = false;
      });
    }
  }

  Widget _buildAviancaHeader(BuildContext scaffoldContext) {
    return Container(
      width: double.infinity,
      color: Colors.white,
      child: SafeArea(
        bottom: false,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          child: Row(
            children: [
              // Menú hamburguesa - Funcional
              GestureDetector(
                onTap: () {
                  Scaffold.of(scaffoldContext).openDrawer();
                },
                child: Container(
                  child: Column(
                    children: [
                      Container(
                        width: 25,
                        height: 3,
                        color: Colors.black,
                        margin: EdgeInsets.only(bottom: 4),
                      ),
                      Container(
                        width: 20,
                        height: 3,
                        color: Colors.black,
                        margin: EdgeInsets.only(bottom: 4),
                      ),
                      Container(width: 25, height: 3, color: Colors.black),
                    ],
                  ),
                ),
              ),
              Spacer(),
              // Logo Avianca
              Container(
                height: 40,
                child: Image.asset('lib/assets/logoAvianca.png', height: 500),
              ),
              Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserWelcome() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Color(0xFFE8E8E8),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.black,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.person, color: Colors.white, size: 30),
          ),
          SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hola, ${widget.user.email ?? "Usuario"}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Conectado al sistema !',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRegistrosTable() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Color(0xFFE8E8E8),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          // Header de la tabla
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
            decoration: BoxDecoration(
              color: Color(0xFFE8E8E8),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(15),
                topRight: Radius.circular(15),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    'Cliente',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      fontSize: 14,
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    'Tipo',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      fontSize: 14,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'Fecha',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      fontSize: 14,
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    'Hora',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      fontSize: 14,
                    ),
                  ),
                ),
                Container(
                  width: 30,
                  child: Icon(Icons.filter_list, color: Colors.black, size: 20),
                ),
              ],
            ),
          ),
          // Contenido de la tabla
          if (_cargandoRegistros)
            Container(
              padding: EdgeInsets.all(40),
              child: Center(
                child: CircularProgressIndicator(color: Color(0xFFE41E1E)),
              ),
            )
          else if (_registrosRecientes.isEmpty)
            Container(
              padding: EdgeInsets.all(40),
              child: Text(
                'No hay registros recientes',
                style: TextStyle(color: Colors.grey[600], fontSize: 16),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: _registrosRecientes.length,
              itemBuilder: (context, index) {
                final registro = _registrosRecientes[index];
                final fecha = (registro['fecha'] as Timestamp).toDate();

                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Colors.grey[300]!, width: 0.5),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(
                          registro['nombreCliente'] ?? '',
                          style: TextStyle(color: Colors.black, fontSize: 13),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Text(
                          registro['tipoRecorrido'] ?? '',
                          style: TextStyle(color: Colors.black, fontSize: 13),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          DateFormat('dd/MM/yyyy').format(fecha),
                          style: TextStyle(color: Colors.black, fontSize: 13),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Text(
                          registro['hora'] ?? '',
                          style: TextStyle(color: Colors.black, fontSize: 13),
                        ),
                      ),
                      Container(width: 30), // Espacio para el ícono de filtro
                    ],
                  ),
                );
              },
            ),
          // Botón para registrar nuevo recorrido
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(15),
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => RecorridosPage(user: widget.user),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFE41E1E),
                padding: EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Registrar nuevo recorrido',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    final actions = [
      {
        'label': 'Perfil',
        'icon': Icons.person_outline,
        'onTap':
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PerfilPage()),
            ),
      },
      {
        'label': 'Soporte',
        'icon': Icons.support_agent,
        'onTap':
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SoportePage()),
            ),
      },
      {
        'label': 'Recorridos',
        'icon': Icons.route,
        'onTap':
            () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => RecorridosPage(user: widget.user),
              ),
            ),
      },
    ];

    return Container(
      margin: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children:
            actions.map((action) {
              return Expanded(
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 5),
                  child: ElevatedButton(
                    onPressed: action['onTap'] as VoidCallback,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Color(0xFFE41E1E),
                      elevation: 2,
                      padding: EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide(color: Color(0xFFE41E1E), width: 1),
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(action['icon'] as IconData, size: 24),
                        SizedBox(height: 5),
                        Text(
                          action['label'] as String,
                          style: TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // Drawer (menú lateral) se mantiene
      drawer: BottomNavBar.createDrawer(context),
      body: Builder(
        builder: (BuildContext scaffoldContext) {
          return Column(
            children: [
              _buildAviancaHeader(scaffoldContext),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildUserWelcome(),
                      _buildRegistrosTable(),
                      SizedBox(height: 20),
                      _buildQuickActions(),
                      SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
      // bottomNavigationBar eliminado completamente
    );
  }
}
