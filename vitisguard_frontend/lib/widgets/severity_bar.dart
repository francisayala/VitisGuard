import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../l10n/app_localizations.dart'; // <--- Importamos las traducciones

class SeverityBar extends StatelessWidget {
  const SeverityBar({super.key});

  @override
  Widget build(BuildContext context) {
    // Inicializamos la herramienta de idiomas
    final l10n = AppLocalizations.of(context)!;

    return Column(
      children: [
        /// BARRA DE COLORES
        Row(
          children: [
            _buildSegment(AppColors.accent, isFirst: true),
            _buildSegment(Colors.yellow),
            _buildSegment(Colors.orange),
            _buildSegment(AppColors.red, isLast: true),
          ],
        ),
        const SizedBox(height: 12),

        /// ETIQUETAS TRADUCIDAS
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildLabel(l10n.sinAfectacion), // <--- TRADUCIDO
            _buildLabel(l10n.leve), // <--- TRADUCIDO
            _buildLabel(l10n.moderada), // <--- TRADUCIDO
            _buildLabel(l10n.severa), // <--- TRADUCIDO
          ],
        ),
      ],
    );
  }

  // --- WIDGETS DE APOYO ---

  Widget _buildSegment(
    Color color, {
    bool isFirst = false,
    bool isLast = false,
  }) {
    return Expanded(
      child: Container(
        height: 10,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.horizontal(
            left: isFirst ? const Radius.circular(5) : Radius.zero,
            right: isLast ? const Radius.circular(5) : Radius.zero,
          ),
          border: Border.all(color: Colors.black12, width: 0.5),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Expanded(
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: AppColors.textSoft,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
