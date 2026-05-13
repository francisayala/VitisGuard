import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'glass_card.dart';
import 'severity_bar.dart';
import 'responsive.dart';
import '../l10n/app_localizations.dart';

class ResultsPanel extends StatelessWidget {
  // --- AÑADIMOS LAS COMPUERTAS PARA RECIBIR LOS DATOS ---
  final double indice;
  final String diagnostico;
  final String? rutaImagen; // Nueva propiedad para la ruta de la imagen
  final int areaTotal;
  final int areaAfectada;

  const ResultsPanel({
    super.key,
    this.indice = 0.0,
    this.diagnostico = "--",
    this.rutaImagen,
    this.areaTotal = 0,
    this.areaAfectada = 0,
  });

  @override
  Widget build(BuildContext context) {
    // 1. Inicializamos las herramientas necesarias
    final l10n = AppLocalizations.of(context)!;
    final bool isMobile = Responsive.isMobile(context);

    // Cambiamos el texto de espera si ya hay un diagnóstico
    final String estadoTexto = indice > 0 ? diagnostico : l10n.estadoEsperando;
    final Color borderColor = indice > 0 ? AppColors.accent : Colors.white10;

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// HEADER
          Row(
            children: [
              Icon(
                Icons.analytics_outlined,
                color: AppColors.accent,
                size: isMobile ? 22 : 28,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  l10n.tituloResultados,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: isMobile ? 20 : 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            estadoTexto, // <--- AHORA ES DINÁMICO
            style: TextStyle(
              color: indice > 0 ? Colors.white : AppColors.textSoft,
              fontSize: 15,
              fontWeight: indice > 0 ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          const SizedBox(height: 26),

          /// MAIN RESULT CARD
          Container(
            padding: EdgeInsets.all(isMobile ? 18 : 24),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.15),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: borderColor,
              ), // <--- Borde cambia de color
            ),
            child: isMobile
                ? Column(
                    children: [
                      _leftInfo(isMobile, l10n),
                      const SizedBox(height: 28),
                      _circleIndicator(isMobile, borderColor),
                    ],
                  )
                : Row(
                    children: [
                      Expanded(child: _leftInfo(isMobile, l10n)),
                      const SizedBox(width: 20),
                      _circleIndicator(isMobile, borderColor),
                    ],
                  ),
          ),
          const SizedBox(height: 24),

          /// MINI CARDS
          isMobile
              ? Column(
                  children: [
                    _miniCard(
                      isMobile,
                      l10n.areaTotal,
                      "${areaTotal} px²",
                      Icons.crop_square,
                      AppColors.accent,
                    ),
                    const SizedBox(height: 18),
                    _miniCard(
                      isMobile,
                      l10n.areaAfectada,
                      "${areaAfectada} px²",
                      Icons.blur_on,
                      AppColors.red,
                    ),
                  ],
                )
              : Row(
                  children: [
                    Expanded(
                      child: _miniCard(
                        isMobile,
                        l10n.areaTotal,
                        "${areaTotal} px²",
                        Icons.crop_square,
                        AppColors.accent,
                      ),
                    ),
                    const SizedBox(width: 18),
                    Expanded(
                      child: _miniCard(
                        isMobile,
                        l10n.areaAfectada,
                        "${areaAfectada} px²",
                        Icons.blur_on,
                        AppColors.red,
                      ),
                    ),
                  ],
                ),
          const SizedBox(height: 28),

          /// SEVERITY
          Text(
            l10n.nivelSeveridad,
            style: TextStyle(
              fontSize: isMobile ? 16 : 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          const SeverityBar(),
          const SizedBox(height: 30),

          /// INFO CARD
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(isMobile ? 18 : 22),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              color: Colors.black.withOpacity(0.15),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.info_outline, color: AppColors.textSoft),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        l10n.infoAdicional,
                        style: TextStyle(
                          fontSize: isMobile ? 16 : 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Text(
                  l10n.textoAyudaAnalisis,
                  style: TextStyle(
                    color: AppColors.textSoft,
                    height: 1.6,
                    fontSize: isMobile ? 13 : 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// ================= WIDGETS DE APOYO =================

  Widget _leftInfo(bool isMobile, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.indiceAfectacion,
          style: TextStyle(
            color: AppColors.textSoft,
            fontSize: isMobile ? 14 : 16,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          "${indice.toStringAsFixed(2)}%", // <--- NÚMERO DINÁMICO
          style: TextStyle(
            fontSize: isMobile ? 38 : 54,
            fontWeight: FontWeight.bold,
            color: indice > 0 ? AppColors.accent : Colors.white54,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          l10n.severidadEtiqueta,
          style: const TextStyle(color: AppColors.textSoft),
        ),
      ],
    );
  }

  Widget _circleIndicator(bool isMobile, Color borderColor) {
    return Container(
      width: isMobile ? 120 : 150,
      height: isMobile ? 120 : 150,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: borderColor,
          width: isMobile ? 10 : 14,
        ), // <--- BORDE DINÁMICO
      ),
      child: Center(
        child: Text(
          "${indice.toInt()}%", // <--- NÚMERO DINÁMICO
          style: TextStyle(
            fontSize: isMobile ? 28 : 34,
            fontWeight: FontWeight.bold,
            color: indice > 0 ? Colors.white : Colors.white54,
          ),
        ),
      ),
    );
  }

  Widget _miniCard(
    bool isMobile,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 18 : 22),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.15),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: isMobile ? 26 : 32),
          const SizedBox(height: 18),
          Text(
            title,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: AppColors.textSoft,
              fontSize: isMobile ? 13 : 15,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
              fontSize: isMobile ? 22 : 28,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
