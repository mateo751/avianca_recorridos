import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' as xlsio;
import 'package:taxi_recorridos_app/page/home_page.dart';

class RegistroExcelPage extends StatefulWidget {
  final User user;

  const RegistroExcelPage({required this.user, Key? key}) : super(key: key);

  @override
  _RegistroExcelPageState createState() => _RegistroExcelPageState();
}

class _RegistroExcelPageState extends State<RegistroExcelPage> {
  String? _filtroTipo; // null = Todos
  DateTime? _fechaDesde;
  DateTime? _fechaHasta;

  bool _isLoading = false;
  List<Map<String, dynamic>> _datos = [];

  @override
  void initState() {
    super.initState();
    _cargarDatos(); // carga inicial
  }

  Future<void> _cargarDatos() async {
    // Validación simple de rango
    if (_fechaDesde != null &&
        _fechaHasta != null &&
        _fechaDesde!.isAfter(_fechaHasta!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El rango de fechas es inválido')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      Query<Map<String, dynamic>> query = FirebaseFirestore.instance
          .collection('recorridos')
          .where('userId', isEqualTo: widget.user.uid);

      // Filtro por tipo (requiere índice: userId Asc + tipoRecorrido Asc + fecha Desc)
      if (_filtroTipo != null && _filtroTipo!.isNotEmpty) {
        query = query.where('tipoRecorrido', isEqualTo: _filtroTipo);
      }

      // Rango por fecha (inclusive en el día final)
      if (_fechaDesde != null) {
        final inicio = DateTime(
          _fechaDesde!.year,
          _fechaDesde!.month,
          _fechaDesde!.day,
        );
        query = query.where(
          'fecha',
          isGreaterThanOrEqualTo: Timestamp.fromDate(inicio),
        );
      }
      if (_fechaHasta != null) {
        final finDia = DateTime(
          _fechaHasta!.year,
          _fechaHasta!.month,
          _fechaHasta!.day,
        ).add(const Duration(days: 1));
        query = query.where('fecha', isLessThan: Timestamp.fromDate(finDia));
      }

      // orderBy por el mismo campo del rango
      query = query.orderBy('fecha', descending: true);

      final snapshot = await query.get();

      _datos =
          snapshot.docs.map((doc) {
            final data = doc.data();

            DateTime? fecha;
            final rawFecha = data['fecha'];
            if (rawFecha is Timestamp) {
              fecha = rawFecha.toDate();
            } else if (rawFecha is DateTime) {
              fecha = rawFecha;
            }

            return {
              'tipoRecorrido': (data['tipoRecorrido'] ?? '').toString(),
              'fecha': fecha ?? DateTime.fromMillisecondsSinceEpoch(0),
              'hora': (data['hora'] ?? '').toString(),
              'destino': (data['destino'] ?? '').toString(),
              'pasajeros': (data['pasajeros'] ?? '').toString(),
              'nombreCliente': (data['nombreCliente'] ?? '').toString(),
              'equipaje': (data['equipaje'] ?? '').toString(),
            };
          }).toList();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al cargar datos: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _quitarFiltro() {
    setState(() {
      _filtroTipo = null;
      _fechaDesde = null;
      _fechaHasta = null;
    });
    _cargarDatos();
  }

  Future<void> _exportarExcel() async {
    if (_datos.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No hay datos para exportar')),
      );
      return;
    }

    try {
      final workbook = xlsio.Workbook();
      final sheet = workbook.worksheets[0];

      // Encabezados
      final columnas = [
        'Tipo Recorrido',
        'Fecha',
        'Hora',
        'Destino',
        'Pasajeros',
        'Nombre Cliente',
        'Equipaje',
      ];

      for (int i = 0; i < columnas.length; i++) {
        final cell = sheet.getRangeByIndex(1, i + 1);
        cell.setText(columnas[i]);
        cell.cellStyle.bold = true;
        cell.cellStyle.backColor = '#D9E1F2';
      }

      // Datos
      for (int i = 0; i < _datos.length; i++) {
        final fila = _datos[i];
        sheet.getRangeByIndex(i + 2, 1).setText(fila['tipoRecorrido']);
        sheet.getRangeByIndex(i + 2, 2).setDateTime(fila['fecha'] as DateTime);
        sheet.getRangeByIndex(i + 2, 2).numberFormat = 'dd/MM/yyyy';
        sheet.getRangeByIndex(i + 2, 3).setText(fila['hora']);
        sheet.getRangeByIndex(i + 2, 4).setText(fila['destino']);
        sheet.getRangeByIndex(i + 2, 5).setText(fila['pasajeros'].toString());
        sheet.getRangeByIndex(i + 2, 6).setText(fila['nombreCliente']);
        sheet.getRangeByIndex(i + 2, 7).setText(fila['equipaje']);
      }

      // Ajuste de ancho de columnas
      for (int c = 1; c <= columnas.length; c++) {
        sheet.autoFitColumn(c);
      }

      final List<int> bytes = workbook.saveAsStream();
      workbook.dispose();

      final dir = await getApplicationDocumentsDirectory();
      final path =
          '${dir.path}/recorridos_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.xlsx';
      final file = File(path);
      await file.writeAsBytes(bytes, flush: true);

      await OpenFile.open(path);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al exportar: $e')));
    }
  }

  Future<void> _seleccionarFechaDesde() async {
    final fecha = await showDatePicker(
      context: context,
      initialDate: _fechaDesde ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder:
          (context, child) => Theme(
            data: Theme.of(context).copyWith(
              colorScheme: const ColorScheme.light(
                primary: Color(0xFFE41E1E),
                onPrimary: Colors.white,
                surface: Colors.white,
                onSurface: Colors.black,
              ),
            ),
            child: child!,
          ),
    );
    if (fecha != null) {
      setState(() => _fechaDesde = fecha);
    }
  }

  Future<void> _seleccionarFechaHasta() async {
    final fecha = await showDatePicker(
      context: context,
      initialDate: _fechaHasta ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder:
          (context, child) => Theme(
            data: Theme.of(context).copyWith(
              colorScheme: const ColorScheme.light(
                primary: Color(0xFFE41E1E),
                onPrimary: Colors.white,
                surface: Colors.white,
                onSurface: Colors.black,
              ),
            ),
            child: child!,
          ),
    );
    if (fecha != null) {
      setState(() => _fechaHasta = fecha);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tipos = ['Entrada', 'Salida', 'Cancelada - Pagada', 'Maletas'];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Registro Recorridos - Excel'),
        backgroundColor: const Color(0xFFE41E1E),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => HomePage(user: widget.user)),
            );
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: _exportarExcel,
            tooltip: 'Descargar Excel',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            // Filtros
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    // Filtrar por tipo
                    DropdownButtonFormField<String?>(
                      value: _filtroTipo,
                      decoration: InputDecoration(
                        labelText: 'Filtrar por tipo',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      items: [
                        const DropdownMenuItem<String?>(
                          value: null,
                          child: Text('Todos'),
                        ),
                        ...tipos
                            .map(
                              (t) => DropdownMenuItem<String?>(
                                value: t,
                                child: Text(t),
                              ),
                            )
                            .toList(),
                      ],
                      onChanged: (val) => setState(() => _filtroTipo = val),
                    ),
                    const SizedBox(height: 12),

                    // Filtrar por fechas
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: _seleccionarFechaDesde,
                            child: InputDecorator(
                              decoration: InputDecoration(
                                labelText: 'Desde',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                _fechaDesde != null
                                    ? DateFormat(
                                      'dd/MM/yyyy',
                                    ).format(_fechaDesde!)
                                    : 'Seleccione fecha',
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: InkWell(
                            onTap: _seleccionarFechaHasta,
                            child: InputDecorator(
                              decoration: InputDecoration(
                                labelText: 'Hasta',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                _fechaHasta != null
                                    ? DateFormat(
                                      'dd/MM/yyyy',
                                    ).format(_fechaHasta!)
                                    : 'Seleccione fecha',
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: _cargarDatos,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFE41E1E),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('Aplicar filtro'),
                        ),
                        ElevatedButton(
                          onPressed: _quitarFiltro,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey.shade400,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('Quitar filtro'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Tabla
            _isLoading
                ? const Expanded(
                  child: Center(child: CircularProgressIndicator()),
                )
                : _datos.isEmpty
                ? const Expanded(
                  child: Center(child: Text('No hay datos para mostrar')),
                )
                : Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text('Tipo')),
                        DataColumn(label: Text('Fecha')),
                        DataColumn(label: Text('Hora')),
                        DataColumn(label: Text('Destino')),
                        DataColumn(label: Text('Pasajeros')),
                        DataColumn(label: Text('Cliente')),
                        DataColumn(label: Text('Equipaje')),
                      ],
                      rows:
                          _datos.map((dato) {
                            return DataRow(
                              cells: [
                                DataCell(Text(dato['tipoRecorrido'])),
                                DataCell(
                                  Text(
                                    DateFormat(
                                      'dd/MM/yyyy',
                                    ).format(dato['fecha'] as DateTime),
                                  ),
                                ),
                                DataCell(Text(dato['hora'])),
                                DataCell(Text(dato['destino'])),
                                DataCell(Text(dato['pasajeros'].toString())),
                                DataCell(Text(dato['nombreCliente'])),
                                DataCell(Text(dato['equipaje'])),
                              ],
                            );
                          }).toList(),
                    ),
                  ),
                ),
          ],
        ),
      ),
    );
  }
}
