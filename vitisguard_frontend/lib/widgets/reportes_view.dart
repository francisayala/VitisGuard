import 'package:flutter/material.dart';
import 'dart:io';
import '../theme/app_colors.dart';
import '../services/database_helper.dart';
import 'responsive.dart';
import '../l10n/app_localizations.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart'; // <--- Importamos tu diccionario

class ReportesView extends StatefulWidget {
  const ReportesView({super.key});

  @override
  State<ReportesView> createState() => _ReportesViewState();
}

class _ReportesViewState extends State<ReportesView> {
  List<Map<String, dynamic>> _historial = [];
  List<Map<String, dynamic>> _misReportesGuardados = [];
  int? _selectedIndex;
  bool _verMisReportes = false;

  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _descController = TextEditingController();

  bool _incImagen = true;
  bool _incResultados = true;
  bool _incRecomendaciones = true;
  bool _incInfoHoja = true;

  @override
  void initState() {
    super.initState();
    _cargarHistorial();
    _resetNombreReporte();
  }

  void _resetNombreReporte() {
    final now = DateTime.now();
    _nombreController.text =
        "Reporte ${now.day.toString().padLeft(2, '0')}-${now.month.toString().padLeft(2, '0')}-${now.year}";
  }

  Future<void> _cargarHistorial() async {
    final datos = await DatabaseHelper().obtenerHistorial();
    final reportes = await DatabaseHelper().obtenerReportes();
    setState(() {
      _historial = datos;
      _misReportesGuardados = reportes;
    });
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _descController.dispose();
    super.dispose();
  }

  // --- EL MOTOR GENERADOR DE PDF ---
  Future<void> _generarYDescargarPDF(
    Map<String, dynamic> data,
    AppLocalizations l10n,
  ) async {
    final pdf = pw.Document();

    // 1. Cargamos fuentes que soporten Ruso, Español e Inglés
    final fuenteNormal = await PdfGoogleFonts.robotoRegular();
    final fuenteNegrita = await PdfGoogleFonts.robotoBold();

    // 2. Preparamos la imagen si está seleccionada
    pw.ImageProvider? imageProvider;
    if (_incImagen && data['ruta_imagen'] != null) {
      final file = File(data['ruta_imagen']);

      if (file.existsSync()) {
        final extension = file.path.toLowerCase();

        // Validamos formatos soportados por pdf
        final soportado =
            extension.endsWith('.jpg') ||
            extension.endsWith('.jpeg') ||
            extension.endsWith('.png');

        if (soportado) {
          try {
            final imageBytes = await file.readAsBytes();
            imageProvider = pw.MemoryImage(imageBytes);
          } catch (e) {
            debugPrint('Error cargando imagen PDF: $e');
          }
        } else {
          debugPrint('Formato no soportado para PDF: $extension');
        }
      }
    }

    // 3. Estructura del Documento
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        theme: pw.ThemeData.withFont(base: fuenteNormal, bold: fuenteNegrita),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.center,
                children: [
                  pw.Text(
                    "VitisGuard",
                    style: pw.TextStyle(
                      fontSize: 24,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.green800,
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 20),
              pw.Center(
                child: pw.Text(
                  l10n.tituloDocReporte,
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Divider(thickness: 1.5),
              pw.SizedBox(height: 20),

              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  if (_incImagen && imageProvider != null)
                    pw.Expanded(
                      flex: 5,
                      child: pw.Image(
                        imageProvider,
                        height: 180,
                        fit: pw.BoxFit.cover,
                      ),
                    ),
                  if (_incImagen) pw.SizedBox(width: 20),

                  if (_incResultados)
                    pw.Expanded(
                      flex: 5,
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          _pdfInfoField(l10n.diagnostico, data['diagnostico']),
                          _pdfInfoField(
                            l10n.indiceAfectacion,
                            data['indice'].toString(),
                          ),
                          _pdfInfoField(l10n.colSeveridad, data['severidad']),
                          _pdfInfoField(l10n.colFecha, data['fecha']),
                        ],
                      ),
                    ),
                ],
              ),
              pw.SizedBox(height: 30),

              if (_incRecomendaciones) ...[
                pw.Text(
                  l10n.recomendaciones,
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 10),
                _pdfBullet(l10n.rec1),
                _pdfBullet(l10n.rec2),
                _pdfBullet(l10n.rec3),
              ],
              pw.Spacer(),
              pw.Divider(thickness: 0.5),
              pw.Center(
                child: pw.Text(
                  "VitisGuard - Detección de Patógenos en Vitis vinifera L.",
                  style: const pw.TextStyle(color: PdfColors.grey, fontSize: 9),
                ),
              ),
            ],
          );
        },
      ),
    );
    final nombreLimpio = _nombreController.text.trim().replaceAll(
      RegExp(r'[\\/:*?"<>|]'),
      '-',
    );

    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename: '$nombreLimpio.pdf',
    );
    // 2. GUARDAR EN LA BASE DE DATOS REAL
    await DatabaseHelper().guardarReporte({
      'nombre_archivo': '$nombreLimpio.pdf',
      'fecha_creacion': DateTime.now().toString().split('.')[0],
      'analisis_id': data['id'],
    });

    // 3. Refrescar la lista de reportes
    _cargarHistorial();
  }

  pw.Widget _pdfInfoField(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 10),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            label,
            style: const pw.TextStyle(color: PdfColors.grey700, fontSize: 10),
          ),
          pw.Text(
            value,
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
          ),
        ],
      ),
    );
  }

  pw.Widget _pdfBullet(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 5),
      child: pw.Row(
        children: [
          pw.Text("> ", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          pw.Expanded(
            child: pw.Text(text, style: const pw.TextStyle(fontSize: 11)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = Responsive.isMobile(context);
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ================= HEADER Y TABS =================
        Text(
          l10n.tituloReportes,
          style: TextStyle(
            fontSize: isMobile ? 24 : 32,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 20),

        // ================= PESTAÑAS INTERACTIVAS =================
        Row(
          children: [
            _buildTab(
              l10n.tabGenerar,
              !_verMisReportes,
              () => setState(() => _verMisReportes = false),
            ),

            const SizedBox(width: 24),

            _buildTab(
              l10n.tabMisReportes,
              _verMisReportes,
              () => setState(() => _verMisReportes = true),
            ),
          ],
        ),

        const SizedBox(height: 30),
        const Divider(color: Colors.white10, height: 1),
        const SizedBox(height: 30),

        // ================= CAMBIO DINÁMICO DE VISTA =================
        _verMisReportes
            ? _buildListaReportesReal(l10n)
            : (isMobile
                  ? Column(
                      children: [
                        _buildFormulario(l10n),
                        const SizedBox(height: 40),
                        _buildVistaPrevia(l10n),
                      ],
                    )
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 4, child: _buildFormulario(l10n)),

                        const SizedBox(width: 40),

                        Expanded(flex: 6, child: _buildVistaPrevia(l10n)),
                      ],
                    )),
      ],
    );
  }

  // --- 1. FORMULARIO IZQUIERDO ---
  Widget _buildFormulario(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.infoReporte,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),

        // Nombre del reporte
        Text(
          l10n.nombreReporte,
          style: const TextStyle(color: AppColors.textSoft, fontSize: 13),
        ),
        const SizedBox(height: 8),
        _buildTextField(
          _nombreController,
          "Ej. Reporte Parcela Norte",
        ), // Hint estático
        const SizedBox(height: 20),

        // Descripción
        Text(
          l10n.descReporte,
          style: const TextStyle(color: AppColors.textSoft, fontSize: 13),
        ),
        const SizedBox(height: 8),
        _buildTextField(
          _descController,
          "Añade notas adicionales...",
          maxLines: 3,
        ), // Hint estático
        const SizedBox(height: 20),

        // Dropdown Seleccionar Análisis
        Text(
          l10n.seleccionarAnalisis,
          style: const TextStyle(color: AppColors.textSoft, fontSize: 13),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.black26,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              isExpanded: true,
              dropdownColor: AppColors.card,
              value: _selectedIndex,
              hint: Text(
                l10n.seleccionarAnalisis,
                style: const TextStyle(color: AppColors.textSoft),
              ),
              icon: const Icon(
                Icons.arrow_drop_down,
                color: AppColors.textSoft,
              ),
              items: List.generate(_historial.length, (index) {
                final item = _historial[index];
                return DropdownMenuItem(
                  value: index,
                  child: Text(
                    "${item['fecha']} - ${item['diagnostico']}",
                    style: const TextStyle(color: Colors.white),
                  ),
                );
              }),
              onChanged: (value) {
                setState(() {
                  _selectedIndex = value;
                });
              },
            ),
          ),
        ),
        const SizedBox(height: 30),

        // Checkboxes
        Text(
          l10n.incluirReporte,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        _buildCheckbox(
          l10n.chkImagen,
          _incImagen,
          (val) => setState(() => _incImagen = val!),
        ),
        _buildCheckbox(
          l10n.chkResultados,
          _incResultados,
          (val) => setState(() => _incResultados = val!),
        ),
        _buildCheckbox(
          l10n.chkRecomendaciones,
          _incRecomendaciones,
          (val) => setState(() => _incRecomendaciones = val!),
        ),
        _buildCheckbox(
          l10n.chkInfoHoja,
          _incInfoHoja,
          (val) => setState(() => _incInfoHoja = val!),
        ),
        const SizedBox(height: 30),

        // Botón Generar
        SizedBox(
          width: double.infinity,
          height: 55,
          child: ElevatedButton.icon(
            onPressed: _selectedIndex == null
                ? null
                : () async {
                    // Llamamos a la función real que acabamos de pegar
                    await _generarYDescargarPDF(
                      _historial[_selectedIndex!],
                      l10n,
                    );
                  },
            icon: const Icon(Icons.picture_as_pdf, color: Colors.white),
            label: Text(
              l10n.btnGenerar,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
              disabledBackgroundColor: AppColors.card,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // --- 2. VISTA PREVIA DERECHA (EL "PAPEL") ---
  Widget _buildVistaPrevia(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.vistaPrevia,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),

        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(40),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: _selectedIndex == null
              ? SizedBox(
                  height: 400,
                  child: Center(
                    child: Text(
                      "${l10n.seleccionarAnalisis}...",
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  ),
                )
              : _buildDocumentoPDF(_historial[_selectedIndex!], l10n),
        ),
      ],
    );
  }

  // --- DIBUJO DEL DOCUMENTO ESTILO PDF ---
  Widget _buildDocumentoPDF(Map<String, dynamic> data, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.shield, color: AppColors.accent, size: 28),
            const SizedBox(width: 8),
            const Text(
              "VitisGuard",
              style: TextStyle(
                color: Colors.black,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Center(
          child: Text(
            l10n.tituloDocReporte,
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 20),
        const Divider(color: Colors.black12, thickness: 2),
        const SizedBox(height: 20),

        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_incImagen)
              Expanded(
                flex: 5,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    File(data['ruta_imagen']),
                    height: 180,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            if (_incImagen) const SizedBox(width: 30),

            if (_incResultados)
              Expanded(
                flex: 5,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.diagnostico,
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    Text(
                      data['diagnostico'],
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    Text(
                      l10n.indiceAfectacion,
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    Text(
                      data['indice'],
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    Text(
                      l10n.colSeveridad,
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    Text(
                      data['severidad'],
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    Text(
                      l10n.colFecha,
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    Text(
                      data['fecha'],
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        const SizedBox(height: 40),

        if (_incRecomendaciones) ...[
          Text(
            l10n.recomendaciones,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _pdfBulletPoint(l10n.rec1),
          _pdfBulletPoint(l10n.rec2),
          _pdfBulletPoint(l10n.rec3),
        ],
        const SizedBox(height: 60),

        const Center(
          child: Text(
            "VitisGuard - Detección de Patógenos en Vitis vinifera L.",
            style: TextStyle(color: Colors.grey, fontSize: 10),
          ),
        ),
      ],
    );
  }

  // --- UTILIDADES ---
  Widget _buildTextField(
    TextEditingController controller,
    String hint, {
    int maxLines = 1,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: AppColors.textSoft),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
        ),
      ),
    );
  }

  Widget _buildCheckbox(String label, bool value, Function(bool?) onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 24,
            height: 24,
            child: Checkbox(
              value: value,
              onChanged: onChanged,
              activeColor: AppColors.accent,
              checkColor: Colors.white,
              side: const BorderSide(color: AppColors.textSoft),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 14),
          ),
        ],
      ),
    );
  }

  // ================= TAB INTERACTIVO =================
  Widget _buildTab(String label, bool active, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: active ? AppColors.accent : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: active ? AppColors.accent : AppColors.textSoft,
            fontWeight: active ? FontWeight.bold : FontWeight.normal,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  // ================= LISTA REAL DE REPORTES =================
  Widget _buildListaReportesReal(AppLocalizations l10n) {
    if (_misReportesGuardados.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            const Icon(Icons.folder_open, size: 70, color: AppColors.textSoft),

            const SizedBox(height: 20),

            Text(
              l10n.tabMisReportes,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            const Text(
              "Todavía no has generado reportes.",
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSoft, fontSize: 14),
            ),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.tabMisReportes,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 20),

          ...List.generate(_misReportesGuardados.length, (index) {
            final reporte = _misReportesGuardados[index];

            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.black26,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.picture_as_pdf,
                    color: Colors.redAccent,
                    size: 34,
                  ),

                  const SizedBox(width: 16),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          reporte['nombre_archivo'] ?? 'Reporte.pdf',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),

                        const SizedBox(height: 6),

                        Text(
                          reporte['fecha_creacion'] ?? '',
                          style: const TextStyle(
                            color: AppColors.textSoft,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),

                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.visibility, color: AppColors.accent),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _pdfBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "•",
            style: TextStyle(color: Colors.black, fontSize: 18, height: 1),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: Colors.black87, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
