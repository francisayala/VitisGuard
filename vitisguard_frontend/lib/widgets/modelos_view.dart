import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'glass_card.dart';
import 'responsive.dart';
import 'dotted_border.dart';
import '../l10n/app_localizations.dart'; // <--- Importamos los idiomas

class ModelosView extends StatelessWidget {
  const ModelosView({super.key});

  final List<Map<String, dynamic>> _modelos = const [
    {
      "nombre": "VitisGuard CNN v1.2",
      "tipo": "CNN",
      "precision": "94.2%",
      "imagenes": "15,230",
      "fecha": "10/05/2024",
      "activo": true,
    },
    {
      "nombre": "VitisGuard CNN v1.1",
      "tipo": "CNN",
      "precision": "91.1%",
      "imagenes": "12,450",
      "fecha": "15/12/2023",
      "activo": false,
    },
    {
      "nombre": "VitisGuard Mobile v1.0",
      "tipo": "MobileNet",
      "precision": "88.7%",
      "imagenes": "8,700",
      "fecha": "20/11/2023",
      "activo": false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final bool isMobile = Responsive.isMobile(context);
    final l10n = AppLocalizations.of(context)!; // <--- Inicializamos

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.tituloModelos, // <--- TRADUCIDO
          style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        Text(
          l10n.subtituloModelos, // <--- TRADUCIDO
          style: const TextStyle(color: AppColors.textSoft, fontSize: 14),
        ),
        const SizedBox(height: 24),
        ..._modelos
            .map((modelo) => _buildModelCard(modelo, isMobile, l10n))
            .toList(),
        const SizedBox(height: 10),
        _buildImportArea(isMobile, l10n),
      ],
    );
  }

  Widget _buildModelCard(
    Map<String, dynamic> modelo,
    bool isMobile,
    AppLocalizations l10n,
  ) {
    final bool isActivo = modelo["activo"];
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: GlassCard(
        padding: EdgeInsets.all(isMobile ? 16 : 24),
        child: isMobile
            ? Column(
                children: [
                  Row(
                    children: [
                      _buildModelIcon(isActivo),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          modelo["nombre"], // Nombre del modelo (fijo)
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
                      _buildStatusBadge(isActivo, l10n),
                      _buildDetailsButton(l10n),
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
                          modelo["nombre"], // Nombre del modelo (fijo)
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
                      _buildStatusBadge(isActivo, l10n),
                      const SizedBox(height: 12),
                      _buildDetailsButton(l10n),
                    ],
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
                Text("${l10n.tipoModelo} ${modelo["tipo"]}"), // <--- TRADUCIDO
                Text(
                  "${l10n.entrenadoCon} ${modelo["imagenes"]} ${l10n.imagenes}",
                ), // <--- TRADUCIDO
              ],
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${l10n.precision} ${modelo["precision"]}",
                ), // <--- TRADUCIDO
                Text("${l10n.fecha} ${modelo["fecha"]}"), // <--- TRADUCIDO
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(bool isActivo, AppLocalizations l10n) {
    if (isActivo) {
      return Row(
        children: [
          const Icon(Icons.check_circle, color: AppColors.accent, size: 16),
          const SizedBox(width: 6),
          Text(
            l10n.activo, // <--- TRADUCIDO
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
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: const BorderSide(color: AppColors.border),
          ),
        ),
        child: Text(
          l10n.activar,
          style: const TextStyle(color: Colors.white),
        ), // <--- TRADUCIDO
      );
    }
  }

  Widget _buildDetailsButton(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Text(
            l10n.verDetalles, // <--- TRADUCIDO
            style: const TextStyle(color: AppColors.textSoft, fontSize: 13),
          ),
          const SizedBox(width: 6),
          const Icon(
            Icons.keyboard_arrow_down,
            color: AppColors.textSoft,
            size: 16,
          ),
        ],
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
                l10n.importarModelo, // <--- TRADUCIDO
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                l10n.arrastraModelo, // <--- TRADUCIDO
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
      onPressed: () {},
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.accentSoft,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.accent),
        ),
      ),
      child: Text(
        l10n.seleccionarArchivo, // <--- TRADUCIDO
        style: const TextStyle(
          color: AppColors.accent,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
