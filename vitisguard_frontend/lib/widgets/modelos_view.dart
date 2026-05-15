import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../theme/app_colors.dart';
import 'glass_card.dart';
import 'responsive.dart';
import 'dotted_border.dart';
import '../l10n/app_localizations.dart';
import 'package:flutter/services.dart';
import '../services/database_helper.dart';
import '../widgets/global_state.dart';
import 'dart:io';

class ModelosView extends StatefulWidget {
  const ModelosView({super.key});

  @override
  State<ModelosView> createState() => _ModelosViewState();
}

class _ModelosViewState extends State<ModelosView> {
  // --- ESTADO INTERACTIVO ---
  int? _expandedIndex;

  // ¡OJO AQUÍ! Sin la palabra "final" para que podamos agregarle modelos después
  List<Map<String, dynamic>> _modelos = [];

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarModelos();
  }

  Future<void> _cargarModelos() async {
    final datos = await DatabaseHelper().getModelos();

    // --- NUEVO: Buscamos cuál es el modelo activo y lo avisamos ---
    for (var modelo in datos) {
      if (modelo['activo'] == 1) {
        modeloActivoGlobal.value = modelo['nombre']; // ¡Le hablamos al Sidebar!
        break; // Como ya lo encontramos, detenemos la búsqueda
      }
    }
    setState(() {
      _modelos = datos;
      _isLoading = false;
    });
  }

  // --- LÓGICA REAL: Seleccionar y agregar archivo de modelo ---
  Future<void> _importarModelo(AppLocalizations l10n) async {
    FilePickerResult? result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['h5', 'pt', 'pb', 'txt'],
    );

    if (result != null) {
      String fileName = result.files.single.name;
      String filePath = result.files.single.path ?? "Ruta desconocida";

      TextEditingController descController = TextEditingController();
      TextEditingController precController = TextEditingController();
      TextEditingController imgController = TextEditingController();

      bool? confirmar = await showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: const Color(0xFF1A1F24),
            title: Text(
              l10n.detallesDelModelo,
              style: const TextStyle(color: Colors.white),
            ),
            content: SingleChildScrollView(
              // Añadimos scroll por si el teclado tapa los campos
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.archivoModelo(fileName),
                    style: const TextStyle(
                      color: AppColors.accent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // --- CAMPO DESCRIPCIÓN ---
                  Text(
                    l10n.descripcionModelo,
                    style: const TextStyle(
                      color: AppColors.textSoft,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildPopupTextField(
                    descController,
                    l10n.descripcionModeloHint,
                    maxLines: 3,
                  ),

                  const SizedBox(height: 16),

                  // --- CAMPO PRECISIÓN ---
                  Text(
                    l10n.campoPrecision,
                    style: const TextStyle(
                      color: AppColors.textSoft,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildPopupTextField(
                    precController,
                    l10n.campoPrecisionHint,
                    isNumber: true,
                    isPercent: true,
                  ),

                  const SizedBox(height: 16),

                  // --- CAMPO IMÁGENES ---
                  Text(
                    l10n.campoImagenes,
                    style: const TextStyle(
                      color: AppColors.textSoft,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildPopupTextField(
                    imgController,
                    l10n.campoImagenesHint,
                    isNumber: true,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(
                  l10n.botonCancelarDescripcion,
                  style: const TextStyle(color: AppColors.textSoft),
                ),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                ),
                child: Text(
                  l10n.botonGuardarDescripcion,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          );
        },
      );

      if (confirmar != true) return;

      // --- NUEVO: COPIAR EL ARCHIVO FÍSICAMENTE AL BACKEND ---
      // =========================================================
      try {
        final archivoOrigen = File(filePath);

        // 1. Nos aseguramos de que la carpeta de destino exista
        final directorioDestino = Directory('../assets/models');
        if (!await directorioDestino.exists()) {
          await directorioDestino.create(recursive: true);
        }

        // 2. Armamos la ruta final y copiamos el archivo
        final rutaDestino = '${directorioDestino.path}/$fileName';
        await archivoOrigen.copy(rutaDestino);

        debugPrint("✅ Archivo copiado exitosamente a: $rutaDestino");
      } catch (e) {
        debugPrint("❌ Error copiando el archivo: $e");
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                "Error al copiar el modelo a la carpeta del servidor.",
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
        return; // Detenemos todo. Si no se copia físicamente, no lo guardamos en SQLite.
      }
      // =========================================================

      String descripcionFinal = descController.text.trim();
      if (descripcionFinal.isEmpty) {
        descripcionFinal =
            "Modelo personalizado importado por el usuario.\nRuta local: $filePath"; //traducir!!!!
      } else {
        descripcionFinal = "$descripcionFinal\n\nRuta local: $filePath";
      }

      final now = DateTime.now();
      final fechaHoy =
          "${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}";

      // 1. PREPARAMOS LOS DATOS
      final nuevoModelo = {
        "nombre": fileName,
        "tipo": "Personalizado",
        "precision": precController.text.isEmpty
            ? "N/A"
            : "${precController.text}%",
        "imagenes": imgController.text.isEmpty
            ? "?"
            : "${imgController.text} ${l10n.imagenes}",
        "fecha": fechaHoy,
        "detalles": descripcionFinal,
        "activo": 0, // 0 significa Inactivo en SQLite
      };

      // 2. GUARDAMOS EN SQLITE (TU BASE DE DATOS)
      await DatabaseHelper().insertarModelo(nuevoModelo);

      // 3. RECARGAMOS LA PANTALLA
      _cargarModelos();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Modelo '$fileName' agregado correctamente."),
            backgroundColor: AppColors.accent,
          ),
        );
      }
    }
  }

  // FUNCIÓN AUXILIAR PARA NO REPETIR CÓDIGO DE DISEÑO DE LOS TEXTFIELDS
  Widget _buildPopupTextField(
    TextEditingController controller,
    String hint, {
    int maxLines = 1,
    bool isNumber = false,
    bool isPercent = false,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: isNumber
          ? const TextInputType.numberWithOptions(decimal: true)
          : TextInputType.text,
      style: const TextStyle(color: Colors.white),
      inputFormatters: [
        if (isNumber && !isPercent)
          FilteringTextInputFormatter
              .digitsOnly, // Solo números enteros para imágenes
        if (isPercent) ...[
          FilteringTextInputFormatter.allow(
            RegExp(r'^\d*\.?\d*'),
          ), // Permite números y un punto decimal
          _Max100Formatter(), // Nuestro validador personalizado para el 100%
        ],
      ],

      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white38),
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.border),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.accent),
        ),
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
        Text(
          l10n.tituloModelos,
          style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        Text(
          l10n.subtituloModelos,
          style: const TextStyle(color: AppColors.textSoft, fontSize: 14),
        ),
        const SizedBox(height: 24),

        if (_isLoading)
          const Center(
            child: CircularProgressIndicator(color: AppColors.accent),
          )
        else if (_modelos.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Text(
              "No hay modelos disponibles. Importa uno nuevo.",
              style: TextStyle(color: AppColors.textSoft),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _modelos.length,
            itemBuilder: (context, index) {
              return _buildModelCard(_modelos[index], index, isMobile, l10n);
            },
          ),

        const SizedBox(height: 10),
        _buildImportArea(isMobile, l10n),
      ],
    );
  }

  Widget _buildModelCard(
    Map<String, dynamic> modelo,
    int index,
    bool isMobile,
    AppLocalizations l10n,
  ) {
    final bool isActivo = modelo['activo'] == 1;
    final bool isExpanded = _expandedIndex == index;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: GlassCard(
        padding: EdgeInsets.all(isMobile ? 16 : 24),
        child: Column(
          children: [
            isMobile
                ? Column(
                    children: [
                      Row(
                        children: [
                          _buildModelIcon(isActivo),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              modelo["nombre"],
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildModelSpecs(modelo, l10n),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildStatusBadge(modelo, isActivo, index, l10n),
                          _buildDetailsButton(isExpanded, index, l10n),
                        ],
                      ),
                    ],
                  )
                : Row(
                    children: [
                      _buildModelIcon(isActivo),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              modelo["nombre"],
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            _buildModelSpecs(modelo, l10n),
                          ],
                        ),
                      ),
                      const SizedBox(width: 20),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          _buildStatusBadge(modelo, isActivo, index, l10n),
                          const SizedBox(height: 12),
                          _buildDetailsButton(isExpanded, index, l10n),
                        ],
                      ),
                    ],
                  ),

            if (isExpanded)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.only(top: 20),
                margin: const EdgeInsets.only(top: 20),
                decoration: const BoxDecoration(
                  border: Border(top: BorderSide(color: Colors.white10)),
                ),
                child: Text(
                  modelo['detalles'],
                  style: const TextStyle(
                    color: AppColors.textSoft,
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildModelIcon(bool isActivo) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isActivo ? AppColors.accentSoft : Colors.black26,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isActivo
              ? AppColors.accent.withOpacity(0.5)
              : AppColors.border,
        ),
      ),
      child: Icon(
        Icons.extension_outlined,
        color: isActivo ? AppColors.accent : AppColors.textSoft,
        size: 28,
      ),
    );
  }

  Widget _buildModelSpecs(Map<String, dynamic> modelo, AppLocalizations l10n) {
    return DefaultTextStyle(
      style: const TextStyle(
        color: AppColors.textSoft,
        fontSize: 13,
        height: 1.6,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("${l10n.tipoModelo} ${modelo["tipo"]}"),
                Text(
                  "${l10n.entrenadoCon} ${modelo["imagenes"]} ${l10n.imagenes}",
                ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("${l10n.precision} ${modelo["precision"]}"),
                Text("${l10n.fecha} ${modelo["fecha"]}"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(
    Map<String, dynamic> modelo,
    bool isActivo,
    int index,
    AppLocalizations l10n,
  ) {
    if (isActivo) {
      return Row(
        children: [
          const Icon(Icons.check_circle, color: AppColors.accent, size: 16),
          const SizedBox(width: 6),
          Text(
            l10n.activo,
            style: const TextStyle(
              color: AppColors.accent,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      );
    } else {
      return ElevatedButton(
        onPressed: () async {
          await DatabaseHelper().activarModelo(modelo['id']);
          _cargarModelos();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: const BorderSide(color: AppColors.border),
          ),
        ),
        child: Text(l10n.activar, style: const TextStyle(color: Colors.white)),
      );
    }
  }

  Widget _buildDetailsButton(
    bool isExpanded,
    int index,
    AppLocalizations l10n,
  ) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _expandedIndex = isExpanded ? null : index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.black26,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Text(
              l10n.verDetalles,
              style: const TextStyle(color: AppColors.textSoft, fontSize: 13),
            ),
            const SizedBox(width: 6),
            Icon(
              isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
              color: AppColors.textSoft,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImportArea(bool isMobile, AppLocalizations l10n) {
    return DottedBorderContainer(
      color: AppColors.border,
      strokeWidth: 2,
      dashPattern: const [8, 4],
      borderRadius: 24,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(isMobile ? 24 : 32),
        child: isMobile
            ? Column(
                children: [
                  _buildImportText(l10n),
                  const SizedBox(height: 20),
                  _buildImportButton(l10n),
                ],
              )
            : Row(
                children: [
                  Expanded(child: _buildImportText(l10n)),
                  const SizedBox(width: 20),
                  _buildImportButton(l10n),
                ],
              ),
      ),
    );
  }

  Widget _buildImportText(AppLocalizations l10n) {
    return Row(
      children: [
        const Icon(
          Icons.cloud_upload_outlined,
          color: AppColors.textSoft,
          size: 40,
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.importarModelo,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                l10n.arrastraModelo,
                style: const TextStyle(color: AppColors.textSoft, fontSize: 14),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildImportButton(AppLocalizations l10n) {
    return ElevatedButton(
      onPressed: () => _importarModelo(l10n),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.accentSoft,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.accent),
        ),
      ),
      child: Text(
        l10n.seleccionarArchivo,
        style: const TextStyle(
          color: AppColors.accent,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

// Esta clase revisa que el número no pase de 100
class _Max100Formatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) return newValue;

    double? value = double.tryParse(newValue.text);
    if (value == null)
      return oldValue; // Si no es un número válido, no deja escribir

    if (value > 100) {
      return const TextEditingValue(
        text: "100",
        selection: TextSelection.collapsed(offset: 3),
      );
    }
    return newValue;
  }
}
