import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../theme/app_colors.dart';
import 'glass_card.dart';
import 'responsive.dart';
import 'dotted_border.dart';
import '../l10n/app_localizations.dart';

// --- AHORA ES STATEFUL PARA MANEJAR LA INTERACTIVIDAD ---
class ModelosView extends StatefulWidget {
  const ModelosView({super.key});

  @override
  State<ModelosView> createState() => _ModelosViewState();
}

class _ModelosViewState extends State<ModelosView> {
  // --- ESTADO INTERACTIVO ---
  int _modeloActivoIndex = 0; // El primero empieza activo
  int? _expandedIndex; // Para saber cuál tarjeta está desplegada

  final List<Map<String, dynamic>> _modelos = [
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

  // --- LÓGICA: Seleccionar archivo de modelo ---
  Future<void> _importarModelo(AppLocalizations l10n) async {
    FilePickerResult? result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['h5', 'pt', 'pb'], // Formatos de IA
    );

    if (result != null) {
      String fileName = result.files.single.name;
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Modelo '$fileName' importado con éxito (Simulación)",
            ), // Puedes pasarlo a l10n luego
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

        // --- LISTA DE MODELOS GENERADA DINÁMICAMENTE ---
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
            // --- PARTE SUPERIOR (TU DISEÑO ORIGINAL) ---
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

            // --- PARTE INFERIOR (DESPLEGABLE DE DETALLES) ---
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
        onPressed: () => setState(
          () => _modeloActivoIndex = index,
        ), // <--- Funcionalidad de Activar
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
          _expandedIndex = isExpanded
              ? null
              : index; // <--- Funcionalidad de Desplegar
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
              isExpanded
                  ? Icons.keyboard_arrow_up
                  : Icons.keyboard_arrow_down, // <--- Flecha dinámica
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
      onPressed: () => _importarModelo(l10n), // <--- Funcionalidad de Importar
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
