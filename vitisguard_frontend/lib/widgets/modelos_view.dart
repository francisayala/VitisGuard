import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../theme/app_colors.dart';
import 'glass_card.dart';
import 'responsive.dart';
import 'dotted_border.dart';
import '../l10n/app_localizations.dart';

class ModelosView extends StatefulWidget {
  const ModelosView({super.key});

  @override
  State<ModelosView> createState() => _ModelosViewState();
}

class _ModelosViewState extends State<ModelosView> {
  // --- ESTADO INTERACTIVO ---
  int _modeloActivoIndex = 0;
  int? _expandedIndex;

  // ¡OJO AQUÍ! Sin la palabra "final" para que podamos agregarle modelos después
  List<Map<String, dynamic>> _modelos = [];
  bool _inicializado = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Llenamos la lista la primera vez que se abre la pantalla
    if (!_inicializado) {
      // final l10n = AppLocalizations.of(context)!; // Lo usaremos luego para los detalles si quieres
      _modelos = [
        {
          "nombre": "VitisGuard CNN v1.2",
          "tipo": "CNN",
          "precision": "94.2%",
          "imagenes": "15,230",
          "fecha": "10/05/2024",
          "detalles":
              "Modelo más reciente con arquitectura optimizada para detección temprana de Oídio y Mildiu. Se añadieron 2,780 imágenes nuevas al dataset de entrenamiento para mejorar la precisión en hojas jóvenes.",
        },
        {
          "nombre": "VitisGuard CNN v1.1",
          "tipo": "CNN",
          "precision": "91.1%",
          "imagenes": "12,450",
          "fecha": "15/12/2023",
          "detalles":
              "Versión estable anterior. Buen rendimiento general pero con un 3% de falsos positivos en condiciones de alta iluminación.",
        },
        {
          "nombre": "VitisGuard Mobile v1.0",
          "tipo": "MobileNet",
          "precision": "88.7%",
          "imagenes": "8,700",
          "fecha": "20/11/2023",
          "detalles":
              "Modelo ligero diseñado para dispositivos móviles con bajos recursos. La inferencia es 2 veces más rápida pero sacrifica un poco de precisión.",
        },
      ];
      _inicializado = true;
    }
  }

  // --- LÓGICA REAL: Seleccionar y agregar archivo de modelo ---
  Future<void> _importarModelo(AppLocalizations l10n) async {
    FilePickerResult? result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: [
        'h5',
        'pt',
        'pb',
        'txt',
      ], // Formatos de IA (y txt para pruebas)
    );

    // Si el usuario seleccionó un archivo
    if (result != null) {
      String fileName = result.files.single.name;
      String filePath = result.files.single.path ?? "Ruta desconocida";

      // 1. CREAMOS UN CONTROLADOR PARA LA CAJA DE TEXTO
      TextEditingController descController = TextEditingController();

      // 2. MOSTRAMOS EL POPUP (CUADRO DE DIÁLOGO)
      // Esperamos a ver qué responde el usuario (true = Guardar, false/null = Cancelar)
      bool? confirmar = await showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: const Color(
              0xFF1A1F24,
            ), // Un tono oscuro para que combine con tu app
            title: Text(
              l10n.detallesDelModelo,
              style: TextStyle(color: Colors.white),
            ),
            content: Column(
              mainAxisSize: MainAxisSize
                  .min, // Para que el cuadro no ocupe toda la pantalla
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
                Text(
                  l10n.descripcionModelo,
                  style: TextStyle(color: AppColors.textSoft, fontSize: 14),
                ),
                const SizedBox(height: 8),
                // La caja donde vas a escribir
                TextField(
                  controller: descController,
                  maxLines: 3,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: l10n.descripcionModeloHint,
                    hintStyle: const TextStyle(color: Colors.white38),
                    enabledBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: AppColors.border),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: AppColors.accent),
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () =>
                    Navigator.of(context).pop(false), // Botón Cancelar
                child: Text(
                  l10n.botonCancelarDescripcion,
                  style: TextStyle(color: AppColors.textSoft),
                ),
              ),
              ElevatedButton(
                onPressed: () =>
                    Navigator.of(context).pop(true), // Botón Guardar
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                ),
                child: Text(
                  l10n.botonGuardarDescripcion,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          );
        },
      );

      // Si el usuario presionó "Cancelar" o hizo clic afuera del cuadro, detenemos todo aquí.
      if (confirmar != true) return;

      // 3. ARMAMOS LA DESCRIPCIÓN FINAL
      String descripcionFinal = descController.text.trim();

      // Si el usuario le dio a guardar pero no escribió nada, le ponemos una por defecto
      if (descripcionFinal.isEmpty) {
        descripcionFinal =
            "Modelo personalizado importado por el usuario.\nRuta local: $filePath";
      } else {
        // Si sí escribió, le pegamos la ruta de tu PC al final para que no se pierda el dato
        descripcionFinal = "$descripcionFinal\n\nRuta local: $filePath";
      }

      final now = DateTime.now();
      final fechaHoy =
          "${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}";

      // 4. AGREGAMOS EL MODELO A LA LISTA CON TU TEXTO
      setState(() {
        _modelos.add({
          "nombre": fileName,
          "tipo": "Personalizado",
          "precision": "Evaluando...",
          "imagenes": "?",
          "fecha": fechaHoy,
          "detalles": descripcionFinal, // <--- AQUÍ SE INYECTA TU TEXTO
        });
      });

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
    final bool isActivo = _modeloActivoIndex == index;
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
                          _buildStatusBadge(isActivo, index, l10n),
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
                          _buildStatusBadge(isActivo, index, l10n),
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

  Widget _buildStatusBadge(bool isActivo, int index, AppLocalizations l10n) {
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
        onPressed: () => setState(() => _modeloActivoIndex = index),
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
