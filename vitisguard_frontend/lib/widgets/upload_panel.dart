import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../theme/app_colors.dart';
import '../services/database_helper.dart';
import '../l10n/app_localizations.dart';
import 'dotted_border.dart';
import '../widgets/global_state.dart';

class UploadPanel extends StatefulWidget {
  final Function(
    String diagnostico,
    double confianza,
    double indice,
    String ruta,
    int areaTotal,
    int areaAfectada,
  )?
  onAnalysisComplete;

  const UploadPanel({super.key, this.onAnalysisComplete});

  @override
  State<UploadPanel> createState() => _UploadPanelState();
}

class _UploadPanelState extends State<UploadPanel> {
  File? _imageFile;
  bool _analysisDone = false;
  bool _isAnalyzing = false;

  // ================= SELECCIONAR IMAGEN =================
  Future<void> _pickImage() async {
    if (_analysisDone) {
      _clearImage();
    }

    FilePickerResult? result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'png', 'jpeg', 'avif'],
      allowMultiple: false,
    );

    if (result != null) {
      setState(() {
        _imageFile = File(result.files.single.path!);
        _analysisDone = false;
        _isAnalyzing = false;
      });
    }
  }

  // ================= LIMPIAR IMAGEN =================
  void _clearImage() {
    setState(() {
      _imageFile = null;
      _analysisDone = false;
      _isAnalyzing = false;
    });

    // Limpia también el panel derecho
    if (widget.onAnalysisComplete != null) {
      widget.onAnalysisComplete!("--", 0.0, 0.0, "", 0, 0);
    }
  }

  // ================= CONEXIÓN A PYTHON =================
  Future<void> _analizarImagenEnBackend(File imagen) async {
    final l10n = AppLocalizations.of(context)!;
    final dbHelper = DatabaseHelper();

    // Activamos loader
    setState(() {
      _isAnalyzing = true;
      _analysisDone = false;
    });

    // SnackBar analizando
    if (mounted) {
      ScaffoldMessenger.of(context).clearSnackBars();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("${l10n.mensajeGuardado}..."),
          backgroundColor: AppColors.accentSoft,
          duration: const Duration(seconds: 2),
        ),
      );
    }

    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('http://127.0.0.1:8000/api/analyze'),
      );

      request.files.add(await http.MultipartFile.fromPath('file', imagen.path));

      // --- NUEVO: Flutter le dice a Python qué modelo usar ---
      request.fields['model_name'] = modeloActivoGlobal.value;

      var streamedResponse = await request.send();

      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);

        // ================= EXTRAER DATOS =================

        double indiceReal = (data['iaa_severity'] ?? 0).toDouble();

        int areaTotalReal = data['total_area_px'] ?? 0;

        int areaAfectadaReal = data['affected_area_px'] ?? 0;

        Map<String, dynamic> pathogens = data['pathogens'] ?? {};

        String diagnosticoReal = pathogens.isNotEmpty
            ? pathogens.keys.first
            : "Hoja Sana";

        // Traducciones
        if (diagnosticoReal == "Powdery_Mildew") {
          diagnosticoReal = "Mildiu (Oídio)";
        }

        if (diagnosticoReal == "Birds_Eye_Rot") {
          diagnosticoReal = "Antracnosis";
        }

        // ================= GUARDAR EN SQLITE =================

        await dbHelper.insertarAnalisis({
          "fecha": DateTime.now().toString().substring(0, 16),
          "diagnostico": diagnosticoReal,
          "severidad": indiceReal < 15.0
              ? "Leve"
              : (indiceReal < 30.0 ? "Moderada" : "Severa"),
          "indice": "${indiceReal.toStringAsFixed(1)}%",
          "ruta_imagen": imagen.path,
          "area_total": areaTotalReal,
          "area_afectada": areaAfectadaReal,
        });

        // ================= ACTUALIZAR ESTADO =================

        setState(() {
          _analysisDone = true;
          _isAnalyzing = false;
        });

        // ================= SNACKBAR ÉXITO =================

        if (mounted) {
          ScaffoldMessenger.of(context).clearSnackBars();

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.mensajeGuardado),
              backgroundColor: AppColors.accent,
              duration: const Duration(seconds: 3),
            ),
          );
        }

        // ================= ENVIAR DATOS AL DASHBOARD =================

        if (widget.onAnalysisComplete != null) {
          widget.onAnalysisComplete!(
            diagnosticoReal,
            95.0,
            indiceReal,
            imagen.path,
            areaTotalReal,
            areaAfectadaReal,
          );
        }
      } else {
        throw Exception("Error del servidor: ${response.statusCode}");
      }
    } catch (e) {
      print("Error conectando con el servidor: $e");

      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("${l10n.errorComunicacion} (Python)"),
            backgroundColor: AppColors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isAnalyzing = false;
        });
      }
    }
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.image_search, color: AppColors.accent, size: 28),
              const SizedBox(width: 12),
              Text(
                l10n.tituloCargar,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // ================= ÁREA DE CARGA =================
          GestureDetector(
            onTap: _pickImage,
            child: DottedBorderContainer(
              color: AppColors.textSoft.withOpacity(0.5),
              strokeWidth: 2,
              dashPattern: const [8, 4],
              borderRadius: 16,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 30),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: _imageFile == null
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.energy_savings_leaf_outlined,
                            size: 54,
                            color: AppColors.accent,
                          ),

                          const SizedBox(height: 16),

                          Text(
                            l10n.arrastraImagen,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),

                          const SizedBox(height: 8),

                          Text(
                            l10n.o,
                            style: const TextStyle(color: AppColors.textSoft),
                          ),

                          const SizedBox(height: 12),

                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.accent,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.upload_rounded,
                                  color: Colors.black,
                                  size: 20,
                                ),

                                const SizedBox(width: 8),

                                Text(
                                  l10n.botonSeleccionar,
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 16),

                          Text(
                            l10n.formatos,
                            style: const TextStyle(
                              color: AppColors.textSoft,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      )
                    : Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Stack(
                          alignment: Alignment.topRight,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.file(
                                _imageFile!,
                                height: 200,
                                width: double.infinity,
                                fit: BoxFit.contain,
                              ),
                            ),

                            if (!_analysisDone && !_isAnalyzing)
                              Positioned(
                                top: 10,
                                right: 10,
                                child: GestureDetector(
                                  onTap: _clearImage,
                                  child: Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: const BoxDecoration(
                                      color: AppColors.red,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.close,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // ================= CONSEJOS =================
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.lightbulb_outline,
                      color: AppColors.accent,
                      size: 20,
                    ),

                    const SizedBox(width: 10),

                    Text(
                      l10n.tituloTips,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                _buildTip(Icons.wb_sunny_outlined, l10n.tip1),
                _buildTip(Icons.eco_outlined, l10n.tip2),
                _buildTip(Icons.crop_free, l10n.tip3),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // ================= BOTÓN ANALIZAR =================
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton.icon(
              onPressed: _imageFile == null || _isAnalyzing
                  ? null
                  : () async {
                      if (!_analysisDone) {
                        await _analizarImagenEnBackend(File(_imageFile!.path));
                      } else {
                        _clearImage();
                      }
                    },

              icon: _isAnalyzing
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.black,
                        strokeWidth: 2,
                      ),
                    )
                  : Icon(
                      _analysisDone
                          ? Icons.refresh
                          : Icons.energy_savings_leaf_outlined,
                    ),

              label: Text(
                _isAnalyzing
                    ? "Analizando IA..."
                    : (_analysisDone
                          ? l10n.continuarAnalisis
                          : l10n.botonAnalizar),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              style: ElevatedButton.styleFrom(
                backgroundColor: _imageFile == null
                    ? Colors.grey
                    : (_analysisDone ? Colors.white24 : AppColors.accent),

                foregroundColor: _analysisDone ? Colors.white : Colors.black,

                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================= WIDGET TIP =================
  Widget _buildTip(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: AppColors.textSoft, size: 18),

          const SizedBox(width: 12),

          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: AppColors.textSoft, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
