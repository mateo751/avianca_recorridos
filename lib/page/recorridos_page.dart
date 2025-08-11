import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:taxi_recorridos_app/page/home_page.dart';

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
      backgroundColor: const Color(0xFF0B0C2A),
      appBar: AppBar(
        title: const Text(
          'Registro de Recorrido',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF1A1A40),
        iconTheme: const IconThemeData(color: Colors.cyanAccent),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => HomePage(user: widget.user)),
            );
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildCard('Tipo de Recorrido', _buildTipoRecorrido()),
              const SizedBox(height: 20),
              _buildCard('Fecha', _buildDatePicker()),
              const SizedBox(height: 20),
              _buildCard('Hora', _buildHoraDropdown()),
              if (_otraHora)
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: TextFormField(
                    controller: _horaManualController,
                    style: const TextStyle(color: Colors.white),
                    decoration: _inputStyle('Especificar hora'),
                    validator: (value) {
                      if (_otraHora && (value == null || value.isEmpty)) {
                        return 'Ingrese la hora';
                      }
                      return null;
                    },
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
                  style: const TextStyle(color: Colors.white),
                  decoration: _inputStyle('Nombre del cliente'),
                  validator:
                      (value) =>
                          value == null || value.isEmpty
                              ? 'Ingrese el nombre'
                              : null,
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                icon: const Icon(Icons.save, size: 24, color: Colors.white),
                label: const Text(
                  'GUARDAR RECORRIDO',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
                onPressed: _guardarRecorrido,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00EFFF),
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 30,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 10,
                  shadowColor: Colors.cyanAccent,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputStyle(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.white70),
      filled: true,
      fillColor: const Color(0xFF2B2B50),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }

  Widget _buildCard(String title, Widget child) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A40),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.cyanAccent.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }

  Widget _buildTipoRecorrido() {
    final tipos = ['Entrada', 'Salida', 'Cancelada - Pagada', 'Maletas'];
    return Wrap(
      spacing: 10,
      children:
          tipos.map((tipo) {
            final selected = _tipoRecorrido == tipo;
            return ChoiceChip(
              label: Text(tipo),
              selected: selected,
              onSelected: (_) => setState(() => _tipoRecorrido = tipo),
              selectedColor: Colors.cyanAccent,
              backgroundColor: Colors.grey.shade800,
              labelStyle: TextStyle(
                color: selected ? Colors.black : Colors.white,
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
                  colorScheme: const ColorScheme.dark(
                    primary: Colors.cyanAccent,
                    surface: Color(0xFF1A1A40),
                    onSurface: Colors.white,
                  ),
                ),
                child: child!,
              ),
        );
        if (fecha != null) setState(() => _fecha = fecha);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFF2B2B50),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _fecha != null
                  ? DateFormat('dd/MM/yyyy').format(_fecha!)
                  : 'Seleccione una fecha',
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
            const Icon(Icons.calendar_today, color: Colors.cyanAccent),
          ],
        ),
      ),
    );
  }

  Widget _buildHoraDropdown() {
    return DropdownButtonFormField<String>(
      value: _horaSeleccionada,
      dropdownColor: const Color(0xFF2B2B50),
      decoration: _inputStyle('Seleccione una hora'),
      icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
      style: const TextStyle(color: Colors.white),
      items: [
        ..._horasDisponibles.map(
          (h) => DropdownMenuItem(
            value: h,
            child: Text(h, style: const TextStyle(color: Colors.white)),
          ),
        ),
        const DropdownMenuItem(
          value: 'otro',
          child: Text('Otra hora', style: TextStyle(color: Colors.white)),
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
      hint: const Text(
        'Seleccione una hora',
        style: TextStyle(color: Colors.white70),
      ),
    );
  }

  Widget _buildDestinoDropdown() {
    return DropdownButtonFormField<String>(
      value: _destino,
      dropdownColor: const Color(0xFF2B2B50),
      decoration: _inputStyle('Seleccione un destino'),
      icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
      style: const TextStyle(color: Colors.white),
      items:
          _destinos
              .map(
                (d) => DropdownMenuItem(
                  value: d,
                  child: Text(d, style: const TextStyle(color: Colors.white)),
                ),
              )
              .toList(),
      onChanged: (value) => setState(() => _destino = value),
      validator: (value) => value == null ? 'Seleccione un destino' : null,
      hint: const Text(
        'Seleccione un destino',
        style: TextStyle(color: Colors.white70),
      ),
    );
  }

  Widget _buildPasajerosSelector() {
    return Wrap(
      spacing: 10,
      children: List.generate(4, (i) {
        final num = i + 1;
        final selected = _pasajeros == num;
        return ChoiceChip(
          label: Text('$num'),
          selected: selected,
          onSelected: (_) => setState(() => _pasajeros = num),
          selectedColor: Colors.cyanAccent,
          backgroundColor: Colors.grey.shade800,
          labelStyle: TextStyle(color: selected ? Colors.black : Colors.white),
        );
      }),
    );
  }

  Widget _buildEquipajeSwitch() {
    return Wrap(
      spacing: 10,
      children:
          ['Sí', 'No'].map((e) {
            final bool selected = _equipaje == (e == 'Sí');
            return ChoiceChip(
              label: Text(e),
              selected: selected,
              onSelected: (_) => setState(() => _equipaje = (e == 'Sí')),
              selectedColor: Colors.cyanAccent,
              backgroundColor: Colors.grey.shade800,
              labelStyle: TextStyle(
                color: selected ? Colors.black : Colors.white,
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
          const SnackBar(
            content: Text('Por favor completa todos los campos obligatorios.'),
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
          const SnackBar(content: Text('Recorrido registrado con éxito')),
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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error al guardar: $e')));
      }
    }
  }
}
