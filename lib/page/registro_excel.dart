import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:excel/excel.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:firebase_auth/firebase_auth.dart'; // <- IMPORTANTE
import 'dart:io';

class RegistroExcelPage extends StatefulWidget {
  const RegistroExcelPage({Key? key}) : super(key: key);

  @override
  State<RegistroExcelPage> createState() => _RegistroExcelPageState();
}

class _RegistroExcelPageState extends State<RegistroExcelPage> {
  List<Map<String, dynamic>> _registros = [];
  List<Map<String, dynamic>> _registrosFiltrados = [];
  DateTime? _fechaInicio;
  DateTime? _fechaFin;
  String? _tipoSeleccionado;

  @override
  void initState() {
    super.initState();
    _cargarRegistros();
  }

  Future<void> _cargarRegistros() async {
    final usuario = FirebaseAuth.instance.currentUser;

    if (usuario == null) {
      return;
    }

    try {
      final snapshot =
          await FirebaseFirestore.instance
              .collection('recorridos')
              .where('userId', isEqualTo: usuario.uid)
              .orderBy('fecha') // ordenar por fecha ASCENDENTE
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
        _registros = datos;
        _registrosFiltrados = datos;
      });
    } catch (e) {
      print('Error al cargar registros: $e');
    }
  }

  void _filtrar() {
    setState(() {
      _registrosFiltrados =
          _registros.where((registro) {
            final fecha = (registro['fecha'] as Timestamp).toDate();
            final cumpleFecha =
                (_fechaInicio == null ||
                    fecha.isAfter(
                      _fechaInicio!.subtract(const Duration(days: 1)),
                    )) &&
                (_fechaFin == null ||
                    fecha.isBefore(_fechaFin!.add(const Duration(days: 1))));
            final cumpleTipo =
                _tipoSeleccionado == null ||
                _tipoSeleccionado == registro['tipoRecorrido'];
            return cumpleFecha && cumpleTipo;
          }).toList();
    });
  }

  void _quitarFiltros() {
    setState(() {
      _fechaInicio = null;
      _fechaFin = null;
      _tipoSeleccionado = null;
      _registrosFiltrados = _registros;
    });
  }

  Future<void> _exportarExcel() async {
    final excel = Excel.createExcel();
    final sheet = excel['Registros'];
    sheet.appendRow([
      'Cliente',
      'Tipo',
      'Fecha',
      'Hora',
      'Destino',
      'Pasajeros',
      'Equipaje',
    ]);

    for (var r in _registrosFiltrados) {
      final fecha = (r['fecha'] as Timestamp).toDate();
      sheet.appendRow([
        r['nombreCliente'] ?? '',
        r['tipoRecorrido'] ?? '',
        DateFormat('dd/MM/yyyy').format(fecha),
        r['hora'] ?? '',
        r['destino'] ?? '',
        r['pasajeros'].toString(),
        r['equipaje'] ?? '',
      ]);
    }

    final permiso = await Permission.manageExternalStorage.request();
    if (permiso.isGranted) {
      final dir = await getExternalStorageDirectory();
      final path = '${dir!.path}/recorridos_filtrados.xlsx';
      final file = File(path);
      await file.writeAsBytes(excel.encode()!);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Archivo guardado y listo para abrir.')),
      );

      OpenFile.open(path);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Permiso de almacenamiento denegado')),
      );
    }
  }

  Widget _buildTabla() {
    return Expanded(
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            headingRowColor: MaterialStateProperty.all(const Color(0xFF3B8AC4)),
            columns: const [
              DataColumn(
                label: Text('Cliente', style: TextStyle(color: Colors.white)),
              ),
              DataColumn(
                label: Text('Tipo', style: TextStyle(color: Colors.white)),
              ),
              DataColumn(
                label: Text('Fecha', style: TextStyle(color: Colors.white)),
              ),
              DataColumn(
                label: Text('Hora', style: TextStyle(color: Colors.white)),
              ),
              DataColumn(
                label: Text('Destino', style: TextStyle(color: Colors.white)),
              ),
              DataColumn(
                label: Text('Pasajeros', style: TextStyle(color: Colors.white)),
              ),
              DataColumn(
                label: Text('Equipaje', style: TextStyle(color: Colors.white)),
              ),
              DataColumn(
                label: Text('Acciones', style: TextStyle(color: Colors.white)),
              ),
            ],
            rows:
                _registrosFiltrados.map((r) {
                  final fecha = (r['fecha'] as Timestamp).toDate();
                  return DataRow(
                    cells: [
                      DataCell(
                        Text(
                          r['nombreCliente'],
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      DataCell(
                        Text(
                          r['tipoRecorrido'],
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      DataCell(
                        Text(
                          DateFormat('dd/MM/yyyy').format(fecha),
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      DataCell(
                        Text(r['hora'], style: TextStyle(color: Colors.white)),
                      ),
                      DataCell(
                        Text(
                          r['destino'],
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      DataCell(
                        Text(
                          '${r['pasajeros']}',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      DataCell(
                        Text(
                          r['equipaje'],
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      DataCell(
                        Row(
                          children: [
                            IconButton(
                              icon: Icon(
                                Icons.edit,
                                color: Colors.yellowAccent,
                              ),
                              onPressed: () async {
                                final fechaActual =
                                    (r['fecha'] as Timestamp).toDate();
                                final nombreCtrl = TextEditingController(
                                  text: r['nombreCliente'],
                                );
                                final horaCtrl = TextEditingController(
                                  text: r['hora'],
                                );
                                final destinoCtrl = TextEditingController(
                                  text: r['destino'],
                                );
                                final pasajerosCtrl = TextEditingController(
                                  text: r['pasajeros'].toString(),
                                );
                                final equipajeCtrl = TextEditingController(
                                  text: r['equipaje'],
                                );
                                String tipoRecorrido = r['tipoRecorrido'];
                                DateTime? nuevaFecha = fechaActual;

                                await showDialog(
                                  context: context,
                                  builder:
                                      (context) => AlertDialog(
                                        backgroundColor: const Color(
                                          0xFF1A1A40,
                                        ),
                                        title: const Text(
                                          'Editar Recorrido',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                        content: SingleChildScrollView(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              _buildEditLabel('Cliente'),
                                              _buildEditField(nombreCtrl),
                                              _buildEditLabel('Hora'),
                                              _buildEditField(horaCtrl),
                                              _buildEditLabel('Destino'),
                                              _buildEditField(destinoCtrl),
                                              _buildEditLabel('Pasajeros'),
                                              _buildEditField(pasajerosCtrl),
                                              _buildEditLabel('Equipaje'),
                                              _buildEditField(equipajeCtrl),
                                              _buildEditLabel('Tipo Recorrido'),
                                              DropdownButton<String>(
                                                dropdownColor: Color(
                                                  0xFF2B2B50,
                                                ),
                                                value: tipoRecorrido,
                                                items:
                                                    [
                                                          'Entrada',
                                                          'Salida',
                                                          'Cancelada - Pagada',
                                                          'Maletas',
                                                        ]
                                                        .map(
                                                          (
                                                            tipo,
                                                          ) => DropdownMenuItem(
                                                            value: tipo,
                                                            child: Text(
                                                              tipo,
                                                              style: TextStyle(
                                                                color:
                                                                    Colors
                                                                        .white,
                                                              ),
                                                            ),
                                                          ),
                                                        )
                                                        .toList(),
                                                onChanged:
                                                    (value) => setState(
                                                      () =>
                                                          tipoRecorrido =
                                                              value!,
                                                    ),
                                              ),
                                              const SizedBox(height: 10),
                                              _buildEditLabel('Fecha'),
                                              ElevatedButton(
                                                onPressed: () async {
                                                  final fechaSeleccionada = await showDatePicker(
                                                    context: context,
                                                    initialDate:
                                                        nuevaFecha ??
                                                        DateTime.now(),
                                                    firstDate: DateTime(2020),
                                                    lastDate: DateTime(2035),
                                                    builder:
                                                        (
                                                          context,
                                                          child,
                                                        ) => Theme(
                                                          data: ThemeData.dark().copyWith(
                                                            colorScheme:
                                                                const ColorScheme.dark(
                                                                  primary:
                                                                      Colors
                                                                          .cyanAccent,
                                                                  surface: Color(
                                                                    0xFF1A1A40,
                                                                  ),
                                                                ),
                                                          ),
                                                          child: child!,
                                                        ),
                                                  );
                                                  if (fechaSeleccionada != null)
                                                    nuevaFecha =
                                                        fechaSeleccionada;
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      Colors.cyanAccent,
                                                ),
                                                child: Text(
                                                  'Seleccionar Fecha',
                                                  style: TextStyle(
                                                    color: Colors.black,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(height: 16),
                                              ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      Colors.greenAccent,
                                                ),
                                                onPressed: () async {
                                                  final nuevaData = {
                                                    'nombreCliente':
                                                        nombreCtrl.text,
                                                    'hora': horaCtrl.text,
                                                    'destino': destinoCtrl.text,
                                                    'pasajeros':
                                                        int.tryParse(
                                                          pasajerosCtrl.text,
                                                        ) ??
                                                        1,
                                                    'equipaje':
                                                        equipajeCtrl.text,
                                                    'tipoRecorrido':
                                                        tipoRecorrido,
                                                    'fecha': Timestamp.fromDate(
                                                      nuevaFecha!,
                                                    ),
                                                  };
                                                  await FirebaseFirestore
                                                      .instance
                                                      .collection('recorridos')
                                                      .doc(r['id'])
                                                      .update(nuevaData);
                                                  Navigator.of(context).pop();
                                                  _cargarRegistros();
                                                },
                                                child: Text(
                                                  'Guardar Cambios',
                                                  style: TextStyle(
                                                    color: Colors.black,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                );
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.redAccent),
                              onPressed: () async {
                                await FirebaseFirestore.instance
                                    .collection('recorridos')
                                    .doc(r['id'])
                                    .delete();
                                _cargarRegistros();
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildEditLabel(String label) => Padding(
    padding: const EdgeInsets.only(top: 10.0, bottom: 4),
    child: Text(label, style: TextStyle(color: Colors.white70)),
  );

  Widget _buildEditField(TextEditingController controller) => TextField(
    controller: controller,
    style: TextStyle(color: Colors.white),
    decoration: InputDecoration(
      filled: true,
      fillColor: Color(0xFF2B2B50),
      border: OutlineInputBorder(),
      hintStyle: TextStyle(color: Colors.white54),
    ),
  );

  Widget _buildFiltros() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A40),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            "Filtro por fechas",
            style: TextStyle(color: Colors.white),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2B2B50),
                  ),
                  onPressed: () async {
                    final fecha = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2035),
                      builder:
                          (context, child) => Theme(
                            data: ThemeData.dark().copyWith(
                              colorScheme: const ColorScheme.dark(
                                primary: Colors.cyanAccent,
                                surface: Color(0xFF1A1A40),
                              ),
                            ),
                            child: child!,
                          ),
                    );
                    if (fecha != null) setState(() => _fechaInicio = fecha);
                  },
                  child: Text(
                    _fechaInicio != null
                        ? 'Desde: ${DateFormat('dd/MM/yyyy').format(_fechaInicio!)}'
                        : 'Seleccionar inicio',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2B2B50),
                  ),
                  onPressed: () async {
                    final fecha = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2035),
                      builder:
                          (context, child) => Theme(
                            data: ThemeData.dark().copyWith(
                              colorScheme: const ColorScheme.dark(
                                primary: Colors.cyanAccent,
                                surface: Color(0xFF1A1A40),
                              ),
                            ),
                            child: child!,
                          ),
                    );
                    if (fecha != null) setState(() => _fechaFin = fecha);
                  },
                  child: Text(
                    _fechaFin != null
                        ? 'Hasta: ${DateFormat('dd/MM/yyyy').format(_fechaFin!)}'
                        : 'Seleccionar fin',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
            value: _tipoSeleccionado,
            dropdownColor: const Color(0xFF2B2B50),
            decoration: const InputDecoration(
              filled: true,
              fillColor: Color(0xFF2B2B50),
              hintText: 'Filtrar por tipo',
              hintStyle: TextStyle(color: Colors.white),
              border: OutlineInputBorder(),
            ),
            style: const TextStyle(color: Colors.white),
            iconEnabledColor: Colors.white,
            items:
                ['Entrada', 'Salida', 'Cancelada - Pagada', 'Maletas']
                    .map(
                      (tipo) => DropdownMenuItem(
                        value: tipo,
                        child: Text(
                          tipo,
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    )
                    .toList(),
            onChanged: (value) => setState(() => _tipoSeleccionado = value),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.cyanAccent,
                ),
                onPressed: _filtrar,
                icon: const Icon(Icons.filter_alt, color: Colors.black),
                label: const Text(
                  'Aplicar Filtros',
                  style: TextStyle(color: Colors.black),
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                ),
                onPressed: _quitarFiltros,
                child: const Text(
                  'Quitar Filtros',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0C2A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A40),
        title: const Text(
          'Registros en Excel',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: IconThemeData(color: Colors.cyanAccent),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.download_for_offline,
              color: Colors.cyanAccent,
            ),
            onPressed: _exportarExcel,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildFiltros(),
            const SizedBox(height: 10),
            Expanded(child: _buildTabla()),
          ],
        ),
      ),
    );
  }
}
