import 'package:flutter/material.dart';
import 'dart:io';
import '../theme/app_colors.dart';
import 'glass_card.dart';
import 'severity_bar.dart';
import 'responsive.dart';
import '../l10n/app_localizations.dart';

class ResultsView extends StatelessWidget {
  final double indice;
  final double confianza;
  final String diagnostico;
  final String? rutaImagen;
  final String fecha;
  final int areaTotal;
  final int areaAfectada;
  final VoidCallback? onNuevoAnalisis;

  // ---> EL INTERRUPTOR MÁGICO <---
  final bool modoCompleto;

  const ResultsView({
    super.key,
    this.indice = 0.0,
    this.confianza = 0.0,
    this.diagnostico = "--",
    this.rutaImagen,
    this.fecha = "",
    this.areaTotal = 0,
    this.areaAfectada = 0,
    this.onNuevoAnalisis,
    this.modoCompleto = true,
  });

  String _obtenerFechaActual() {
    final now = DateTime.now();
    return "${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year} - ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = Responsive.isMobile(context);
    final l10n = AppLocalizations.of(context)!;

    final String fechaMostrar = fecha.isNotEmpty
        ? fecha
        : _obtenerFechaActual();
    String textoSeveridad = indice < 15.0
        ? "Leve"
        : (indice < 30.0 ? "Moderada" : "Severa");
    Color colorSeveridad = indice < 15.0
        ? Colors.green
        : (indice < 30.0 ? Colors.orange : AppColors.red);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// ================= HEADER (SIEMPRE SE MUESTRA) =================
        Text(
          l10n.tituloResultados,
          style: TextStyle(
            fontSize: isMobile ? 24 : 32,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Icon(
              Icons.circle,
              size: 10,
              color: indice > 0 ? colorSeveridad : Colors.grey,
            ),
            const SizedBox(width: 8),
            Text(
              indice > 0
                  ? "${l10n.completadoEl} $fechaMostrar"
                  : "Esperando imagen...",
              style: const TextStyle(color: AppColors.textSoft, fontSize: 14),
            ),
          ],
        ),
        const SizedBox(height: 24),

        /// ================= CUERPO =================
        // SI EL INTERRUPTOR ESTÁ APAGADO (Pestaña Análisis): Solo mostramos métricas
        if (!modoCompleto)
          _buildRightColumn(
            context,
            isMobile,
            l10n,
            textoSeveridad,
            colorSeveridad,
          )
        // SI EL INTERRUPTOR ESTÁ ENCENDIDO (Pestaña Resultados): Mostramos las 2 columnas
        else
          isMobile
              ? Column(
                  children: [
                    _buildLeftColumn(context, isMobile, l10n),
                    const SizedBox(height: 20),
                    _buildRightColumn(
                      context,
                      isMobile,
                      l10n,
                      textoSeveridad,
                      colorSeveridad,
                    ),
                  ],
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 5,
                      child: _buildLeftColumn(context, isMobile, l10n),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      flex: 6,
                      child: _buildRightColumn(
                        context,
                        isMobile,
                        l10n,
                        textoSeveridad,
                        colorSeveridad,
                      ),
                    ),
                  ],
                ),
      ],
    );
  }

  // --- COLUMNA IZQUIERDA (FOTO RECTANGULAR Y DIAGNÓSTICO) ---
  Widget _buildLeftColumn(
    BuildContext context,
    bool isMobile,
    AppLocalizations l10n,
  ) {
    return Column(
      children: [
        AspectRatio(
          aspectRatio: 16 / 10,
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Colors.black26,
              border: Border.all(color: AppColors.border),
              image: rutaImagen != null && rutaImagen!.isNotEmpty
                  ? DecorationImage(
                      image: FileImage(File(rutaImagen!)),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: rutaImagen == null || rutaImagen!.isEmpty
                ? const Center(
                    child: Icon(
                      Icons.image_not_supported,
                      size: 60,
                      color: Colors.white54,
                    ),
                  )
                : null,
          ),
        ),
        const SizedBox(height: 20),
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Diagnóstico",
                style: TextStyle(color: AppColors.textSoft, fontSize: 13),
              ),
              const SizedBox(height: 12),
              const Text(
                "Se detectaron signos compatibles con:",
                style: TextStyle(color: AppColors.text, fontSize: 14),
              ),
              const SizedBox(height: 8),
              Text(
                diagnostico,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Text(
                    "Confianza: ",
                    style: TextStyle(color: AppColors.textSoft, fontSize: 13),
                  ),
                  Text(
                    "${confianza.toStringAsFixed(1)}%",
                    style: const TextStyle(
                      color: AppColors.accent,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // --- COLUMNA DERECHA (MÉTRICAS Y BOTONES) ---
  Widget _buildRightColumn(
    BuildContext context,
    bool isMobile,
    AppLocalizations l10n,
    String textoSeveridad,
    Color colorSeveridad,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GlassCard(
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          l10n.indiceAfectacion,
                          style: const TextStyle(
                            color: AppColors.textSoft,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.info_outline,
                          size: 16,
                          color: AppColors.textSoft,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.severidadEtiqueta,
                      style: const TextStyle(
                        color: AppColors.textSoft,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "${indice.toStringAsFixed(1)}%",
                      style: TextStyle(
                        fontSize: isMobile ? 48 : 64,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      textoSeveridad,
                      style: TextStyle(
                        color: colorSeveridad,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: colorSeveridad.withOpacity(0.5),
                    width: 8,
                  ),
                ),
                child: Center(
                  child: Text(
                    "${indice.toInt()}%",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: _miniMetric(
                l10n.areaTotal,
                "${areaTotal.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} px²",
                Icons.crop_square,
                AppColors.accent,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _miniMetric(
                l10n.areaAfectada,
                "${areaAfectada.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} px²",
                Icons.blur_on,
                AppColors.red,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.nivelSeveridad,
                style: const TextStyle(color: AppColors.textSoft, fontSize: 15),
              ),
              const SizedBox(height: 20),
              const SeverityBar(),
            ],
          ),
        ),
        const SizedBox(height: 20),
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.recomendaciones,
                style: const TextStyle(color: AppColors.textSoft, fontSize: 15),
              ),
              const SizedBox(height: 16),
              _bulletPoint(l10n.rec1),
              _bulletPoint(l10n.rec2),
              _bulletPoint(l10n.rec3),
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(
                    backgroundColor: AppColors.accentSoft,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(color: AppColors.border),
                    ),
                  ),
                  child: Text(
                    l10n.verTratamiento,
                    style: const TextStyle(color: AppColors.accent),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (modoCompleto)
          Padding(
            padding: const EdgeInsets.only(top: 30, bottom: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    if (onNuevoAnalisis != null)
                      onNuevoAnalisis!();
                    else
                      Navigator.maybePop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.card,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 20,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: const BorderSide(color: AppColors.border),
                    ),
                  ),
                  child: const Text(
                    "Nueva imagen",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Generación de reporte en desarrollo..."),
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 20,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    "Exportar reporte",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _miniMetric(String title, String value, IconData icon, Color color) {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(color: AppColors.textSoft, fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _bulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check, color: AppColors.accent, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14, color: AppColors.text),
            ),
          ),
        ],
      ),
    );
  }
}
