import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'responsive.dart';
import '../l10n/app_localizations.dart'; // <--- Importamos los idiomas

class ReportesView extends StatefulWidget {
  const ReportesView({super.key});

  @override
  State<ReportesView> createState() => _ReportesViewState();
}

class _ReportesViewState extends State<ReportesView> {
  int _currentTab = 0; // 0 = Generar reporte, 1 = Mis reportes

  // Estados de los Checkboxes
  bool _incImagen = true;
  bool _incResultados = true;
  bool _incRecomendaciones = true;
  bool _incInformacion = true;

  @override
  Widget build(BuildContext context) {
    final bool isMobile = Responsive.isMobile(context);
    final l10n = AppLocalizations.of(context)!; // <--- Inicializamos

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// ================= TÍTULO =================
        Text(
          l10n.tituloDocReporte, // <--- TRADUCIDO
          style: TextStyle(
            fontSize: isMobile ? 24 : 32,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 24),

        /// ================= PESTAÑAS (TABS) =================
        Row(
          children: [
            _buildTab(l10n.tabGenerar, 0), // <--- TRADUCIDO
            const SizedBox(width: 20),
            _buildTab(l10n.tabMisReportes, 1), // <--- TRADUCIDO
          ],
        ),
        Container(
          height: 1,
          width: double.infinity,
          color: AppColors.border,
          margin: const EdgeInsets.only(bottom: 24),
        ),

        /// ================= CONTENIDO DE LA PESTAÑA =================
        if (_currentTab == 0)
          isMobile
              ? Column(
                  children: [
                    _buildFormColumn(l10n),
                    const SizedBox(height: 40),
                    _buildPreviewColumn(l10n),
                  ],
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 4, child: _buildFormColumn(l10n)),
                    const SizedBox(width: 40),
                    Expanded(flex: 5, child: _buildPreviewColumn(l10n)),
                  ],
                )
        else
          const Center(
            child: Padding(
              padding: EdgeInsets.all(40.0),
              child: Text(
                "Aquí aparecerá el historial de PDF generados...",
                style: TextStyle(color: AppColors.textSoft),
              ),
            ),
          ),
      ],
    );
  }

  // --- WIDGETS DE TABS ---
  Widget _buildTab(String title, int index) {
    final isActive = _currentTab == index;
    return GestureDetector(
      onTap: () => setState(() => _currentTab = index),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              color: isActive ? AppColors.accent : AppColors.textSoft,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            height: 3,
            width: 120, // Ancho de la línea verde
            color: isActive ? AppColors.accent : Colors.transparent,
          ),
        ],
      ),
    );
  }

  // --- COLUMNA IZQUIERDA: FORMULARIO ---
  Widget _buildFormColumn(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.infoReporte, // <--- TRADUCIDO
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),

        _inputLabel(l10n.nombreReporte), // <--- TRADUCIDO
        _customTextField("Reporte 20/05/2024"),
        const SizedBox(height: 16),

        _inputLabel(l10n.descReporte), // <--- TRADUCIDO
        _customTextField("Análisis de hojas de parcela norte", maxLines: 3),
        const SizedBox(height: 16),

        _inputLabel(l10n.seleccionarAnalisis), // <--- TRADUCIDO
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.black26,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: l10n.seleccionarAnalisis, // <--- TRADUCIDO
              dropdownColor: AppColors.card,
              style: const TextStyle(color: Colors.white),
              items: [
                DropdownMenuItem(
                  value: l10n.seleccionarAnalisis,
                  child: Text(l10n.seleccionarAnalisis),
                ),
              ],
              onChanged: (val) {},
            ),
          ),
        ),
        const SizedBox(height: 24),

        Text(
          l10n.incluirReporte, // <--- TRADUCIDO
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),

        _customCheckbox(
          l10n.chkImagen, // <--- TRADUCIDO
          _incImagen,
          (val) => setState(() => _incImagen = val!),
        ),
        _customCheckbox(
          l10n.chkResultados, // <--- TRADUCIDO
          _incResultados,
          (val) => setState(() => _incResultados = val!),
        ),
        _customCheckbox(
          l10n.chkRecomendaciones, // <--- TRADUCIDO
          _incRecomendaciones,
          (val) => setState(() => _incRecomendaciones = val!),
        ),
        _customCheckbox(
          l10n.chkInfoHoja, // <--- TRADUCIDO
          _incInformacion,
          (val) => setState(() => _incInformacion = val!),
        ),

        const SizedBox(height: 30),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.description_outlined),
            label: Text(
              l10n.btnGenerar, // <--- TRADUCIDO
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accentSoft,
              foregroundColor: AppColors.accent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: AppColors.accent),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _inputLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(color: AppColors.textSoft, fontSize: 13),
      ),
    );
  }

  Widget _customTextField(String hint, {int maxLines = 1}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: TextField(
        maxLines: maxLines,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white70),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
        ),
      ),
    );
  }

  Widget _customCheckbox(String title, bool value, Function(bool?) onChanged) {
    return Theme(
      data: ThemeData(unselectedWidgetColor: AppColors.textSoft),
      child: CheckboxListTile(
        title: Text(
          title,
          style: const TextStyle(color: Colors.white70, fontSize: 14),
        ),
        value: value,
        onChanged: onChanged,
        activeColor: AppColors.accent,
        checkColor: Colors.black,
        contentPadding: EdgeInsets.zero,
        controlAffinity: ListTileControlAffinity.leading,
        dense: true,
      ),
    );
  }

  // --- COLUMNA DERECHA: VISTA PREVIA (HOJA BLANCA) ---
  Widget _buildPreviewColumn(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.vistaPrevia, // <--- TRADUCIDO
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),

        // LA HOJA DE PAPEL BLANCA
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            color: const Color(
              0xFFF8FAFC,
            ), // Blanco ligeramente grisáceo de papel
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Logo en el PDF
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shield, color: Color(0xFF2E7D32), size: 24),
                  SizedBox(width: 8),
                  Text(
                    "VitisGuard",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                l10n.tituloDocReporte, // <-- Título oficial del documento (lo dejamos fijo)
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Divider(color: Colors.black26, height: 30, thickness: 1),

              // Contenido del PDF (Imagen y Datos)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Imagen miniatura
                  if (_incImagen)
                    Expanded(
                      flex: 4,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          "https://images.unsplash.com/photo-1558293842-c0fd3db86157?q=80&w=300&auto=format&fit=crop",
                          height: 120,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  if (_incImagen) const SizedBox(width: 20),

                  // Textos de resultados
                  if (_incResultados)
                    Expanded(
                      flex: 5,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _pdfLabel(l10n.diagnostico), // <--- TRADUCIDO
                          _pdfValue("Mildiu (Plasmopara viticola)"),
                          const SizedBox(height: 8),
                          _pdfLabel(l10n.indiceAfectacion), // <--- TRADUCIDO
                          _pdfValue("12.45%"),
                          const SizedBox(height: 8),
                          _pdfLabel(
                            l10n.colSeveridad,
                          ), // <--- TRADUCIDO ("Severidad")
                          _pdfValue(l10n.leve), // <--- TRADUCIDO ("Leve")
                          const SizedBox(height: 8),
                          _pdfLabel(l10n.colFecha), // <--- TRADUCIDO ("Fecha")
                          _pdfValue("20/05/2024 - 10:45 a. m."),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 30),

              // Recomendaciones PDF
              if (_incRecomendaciones) ...[
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    l10n.recomendaciones,
                    style: const TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                _pdfBullet(l10n.rec1),
                _pdfBullet(l10n.rec2),
                _pdfBullet(l10n.rec3),
              ],

              const SizedBox(height: 40),
              const Divider(color: Colors.black12, thickness: 1),
              const Text(
                "VitisGuard - Detección de Patógenos en Vitis vinifera L.",
                style: TextStyle(color: Colors.black38, fontSize: 10),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _pdfLabel(String text) {
    return Text(
      text,
      style: const TextStyle(color: Colors.black54, fontSize: 12),
    );
  }

  Widget _pdfValue(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.black87,
        fontSize: 13,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _pdfBullet(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "•",
            style: TextStyle(color: Colors.black54, fontSize: 14),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: Colors.black87, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
