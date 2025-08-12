import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:taxi_recorridos_app/page/home_page.dart';
import 'package:taxi_recorridos_app/widgets/bottom_nav.dart';

class RecorridosPage extends StatefulWidget {
  final User user;

  const RecorridosPage({required this.user});

  @override
  _RecorridosPageState createState() => _RecorridosPageState();
}

class _RecorridosPageState extends State<RecorridosPage> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _horaManualController = TextEditingController();

  String? _tipoRecorrido;
  DateTime? _fecha;
  String? _horaSeleccionada;
  bool _otraHora = false;
  String? _destino;
  int? _pasajeros;
  bool? _equipaje;

  final List<String> _horasDisponibles = [
    '17h00',
    '18h00',
    '18h40',
    '21h00',
    '23h00',
    '01h30',
    '02h20',
    '05h00',
    '05h30',
  ];
  final List<String> _destinos = ['Aeropuerto', 'Norte', 'Sur', 'Valles'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Fondo blanco
      // Drawer con estilo moderno
      drawer: BottomNavBar.createDrawer(context),
      appBar: AppBar(
        title: const Text(
          'Registro de Recorrido',
          style: TextStyle(
            color: Colors.black87, // Texto negro
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white, // AppBar blanco
        elevation: 0, // Sin sombra
        iconTheme: const IconThemeData(color: Colors.black87), // Iconos negros
        leading: Builder(
          builder:
              (context) => IconButton(
                icon: const Icon(Icons.menu), // Icono hamburguesa
                onPressed: () => Scaffold.of(context).openDrawer(),
              ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => HomePage(user: widget.user)),
              );
            },
          ),
        ],
        // Línea sutil en la parte inferior
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: Colors.grey.withOpacity(0.2), height: 1),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: 10),
              _buildCard('Tipo de Recorrido', _buildTipoRecorrido()),
              const SizedBox(height: 20),
              _buildCard('Fecha', _buildDatePicker()),
              const SizedBox(height: 20),
              _buildCard('Hora', _buildHoraDropdown()),
              if (_otraHora)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.grey.withOpacity(0.2),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextFormField(
                      controller: _horaManualController,
                      style: const TextStyle(color: Colors.black87),
                      decoration: _inputStyle('Especificar hora'),
                      validator: (value) {
                        if (_otraHora && (value == null || value.isEmpty)) {
                          return 'Ingrese la hora';
                        }
                        return null;
                      },
                    ),
                  ),
                ),
              const SizedBox(height: 20),
              _buildCard('Destino', _buildDestinoDropdown()),
              const SizedBox(height: 20),
              _buildCard('Número de Pasajeros', _buildPasajerosSelector()),
              const SizedBox(height: 20),
              _buildCard('¿Lleva equipaje?', _buildEquipajeSwitch()),
              const SizedBox(height: 20),
              _buildCard(
                'Datos del Cliente',
                TextFormField(
                  controller: _nombreController,
                  style: const TextStyle(color: Colors.black87),
                  decoration: _inputStyle('Nombre del cliente'),
                  validator:
                      (value) =>
                          value == null || value.isEmpty
                              ? 'Ingrese el nombre'
                              : null,
                ),
              ),
              const SizedBox(height: 40),

              // Botón de guardar
              Container(
                width: double.infinity,
                height: 56,
                decoration: BoxDecoration(
                  color: const Color(0xFFE41E1E), // Color rojo de Avianca
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFE41E1E).withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  icon: const Icon(
                    Icons.save_outlined,
                    size: 24,
                    color: Colors.white,
                  ),
                  label: const Text(
                    'GUARDAR RECORRIDO',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onPressed: _guardarRecorrido,
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputStyle(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey.shade500),
      filled: true,
      fillColor: Colors.grey.withOpacity(0.05),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.withOpacity(0.2)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.withOpacity(0.2)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE41E1E), width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }

  Widget _buildCard(String title, Widget child) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.2), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildTipoRecorrido() {
    final tipos = ['Entrada', 'Salida', 'Cancelada - Pagada', 'Maletas'];
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children:
          tipos.map((tipo) {
            final selected = _tipoRecorrido == tipo;
            return FilterChip(
              label: Text(tipo),
              selected: selected,
              onSelected: (_) => setState(() => _tipoRecorrido = tipo),
              selectedColor: const Color(0xFFE41E1E).withOpacity(0.1),
              backgroundColor: const Color.fromARGB(
                255,
                201,
                200,
                200,
              ).withOpacity(0.1),
              checkmarkColor: const Color(0xFFE41E1E),
              labelStyle: TextStyle(
                color: selected ? const Color(0xFFE41E1E) : Colors.black87,
                fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
              ),
              side: BorderSide(
                color:
                    selected
                        ? const Color(0xFFE41E1E)
                        : const Color.fromARGB(
                          255,
                          201,
                          200,
                          200,
                        ).withOpacity(0.3),
                width: selected ? 2 : 1,
              ),
            );
          }).toList(),
    );
  }

  Widget _buildDatePicker() {
    return InkWell(
      onTap: () async {
        final fecha = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(2020),
          lastDate: DateTime(2030),
          builder:
              (context, child) => Theme(
                data: Theme.of(context).copyWith(
                  colorScheme: const ColorScheme.light(
                    primary: Color(0xFFE41E1E), // Color rojo de Avianca
                    onPrimary: Colors.white,
                    surface: Colors.white,
                    onSurface: Colors.black,
                  ),
                ),
                child: child!,
              ),
        );
        if (fecha != null) setState(() => _fecha = fecha);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 201, 200, 200).withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.withOpacity(0.2)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _fecha != null
                  ? DateFormat('dd/MM/yyyy').format(_fecha!)
                  : 'Seleccione una fecha',
              style: TextStyle(
                color:
                    _fecha != null
                        ? Colors.black87
                        : const Color.fromARGB(255, 201, 200, 200),
                fontSize: 16,
              ),
            ),
            const Icon(Icons.calendar_today_outlined, color: Color(0xFFE41E1E)),
          ],
        ),
      ),
    );
  }

  Widget _buildHoraDropdown() {
    return DropdownButtonFormField<String>(
      value: _horaSeleccionada,
      dropdownColor: Colors.white,
      decoration: _inputStyle('Seleccione una hora'),
      icon: const Icon(Icons.arrow_drop_down, color: Colors.black54),
      style: const TextStyle(color: Colors.black87),
      items: [
        ..._horasDisponibles.map(
          (h) => DropdownMenuItem(
            value: h,
            child: Text(h, style: const TextStyle(color: Colors.black87)),
          ),
        ),
        const DropdownMenuItem(
          value: 'otro',
          child: Text('Otra hora', style: TextStyle(color: Colors.black87)),
        ),
      ],
      onChanged: (value) {
        setState(() {
          _horaSeleccionada = value;
          _otraHora = value == 'otro';
          if (!_otraHora) _horaManualController.clear();
        });
      },
      validator: (value) => value == null ? 'Seleccione una hora' : null,
      hint: Text(
        'Seleccione una hora',
        style: TextStyle(color: const Color.fromARGB(255, 201, 200, 200)),
      ),
    );
  }

  Widget _buildDestinoDropdown() {
    return DropdownButtonFormField<String>(
      value: _destino,
      dropdownColor: Colors.white,
      decoration: _inputStyle('Seleccione un destino'),
      icon: const Icon(Icons.arrow_drop_down, color: Colors.black54),
      style: const TextStyle(color: Colors.black87),
      items:
          _destinos
              .map(
                (d) => DropdownMenuItem(
                  value: d,
                  child: Text(d, style: const TextStyle(color: Colors.black87)),
                ),
              )
              .toList(),
      onChanged: (value) => setState(() => _destino = value),
      validator: (value) => value == null ? 'Seleccione un destino' : null,
      hint: Text(
        'Seleccione un destino',
        style: TextStyle(color: const Color.fromARGB(255, 201, 200, 200)),
      ),
    );
  }

  Widget _buildPasajerosSelector() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: List.generate(4, (i) {
        final num = i + 1;
        final selected = _pasajeros == num;
        return FilterChip(
          label: Text('$num'),
          selected: selected,
          onSelected: (_) => setState(() => _pasajeros = num),
          selectedColor: const Color(0xFFE41E1E).withOpacity(0.1),
          backgroundColor: const Color.fromARGB(
            255,
            201,
            200,
            200,
          ).withOpacity(0.1),
          checkmarkColor: const Color(0xFFE41E1E),
          labelStyle: TextStyle(
            color: selected ? const Color(0xFFE41E1E) : Colors.black87,
            fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
          ),
          side: BorderSide(
            color:
                selected
                    ? const Color(0xFFE41E1E)
                    : const Color.fromARGB(255, 201, 200, 200).withOpacity(0.3),
            width: selected ? 2 : 1,
          ),
        );
      }),
    );
  }

  Widget _buildEquipajeSwitch() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children:
          ['Sí', 'No'].map((e) {
            final bool selected = _equipaje == (e == 'Sí');
            return FilterChip(
              label: Text(e),
              selected: selected,
              onSelected: (_) => setState(() => _equipaje = (e == 'Sí')),
              selectedColor: const Color(0xFFE41E1E).withOpacity(0.1),
              backgroundColor: const Color.fromARGB(
                255,
                201,
                200,
                200,
              ).withOpacity(0.1),
              checkmarkColor: const Color(0xFFE41E1E),
              labelStyle: TextStyle(
                color: selected ? const Color(0xFFE41E1E) : Colors.black87,
                fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
              ),
              side: BorderSide(
                color:
                    selected
                        ? const Color(0xFFE41E1E)
                        : const Color.fromARGB(
                          255,
                          201,
                          200,
                          200,
                        ).withOpacity(0.3),
                width: selected ? 2 : 1,
              ),
            );
          }).toList(),
    );
  }

  void _guardarRecorrido() async {
    if (_formKey.currentState?.validate() ?? false) {
      if (_tipoRecorrido == null ||
          _fecha == null ||
          (_otraHora && _horaManualController.text.isEmpty) ||
          (!_otraHora && _horaSeleccionada == null) ||
          _destino == null ||
          _pasajeros == null ||
          _equipaje == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Por favor completa todos los campos obligatorios.',
            ),
            backgroundColor: const Color(0xFFE41E1E),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
        return;
      }

      try {
        await FirebaseFirestore.instance.collection('recorridos').add({
          'userId': widget.user.uid,
          'tipoRecorrido': _tipoRecorrido,
          'fecha': _fecha,
          'hora': _otraHora ? _horaManualController.text : _horaSeleccionada,
          'destino': _destino,
          'pasajeros': _pasajeros,
          'nombreCliente': _nombreController.text.trim(),
          'equipaje': _equipaje == true ? 'Sí' : 'No',
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Recorrido registrado con éxito'),
            backgroundColor: const Color(0xFF4CAF50),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );

        setState(() {
          _tipoRecorrido = null;
          _fecha = null;
          _horaSeleccionada = null;
          _horaManualController.clear();
          _otraHora = false;
          _destino = null;
          _pasajeros = null;
          _equipaje = null;
          _nombreController.clear();
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar: $e'),
            backgroundColor: const Color(0xFFE41E1E),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }
}
