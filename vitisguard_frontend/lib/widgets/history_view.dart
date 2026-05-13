import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'glass_card.dart';
import 'responsive.dart';
import '../l10n/app_localizations.dart';
import '../services/database_helper.dart';
import 'dart:io';

class HistoryView extends StatefulWidget {
  // --- EL PUENTE: Definimos que HistoryView puede enviar datos hacia afuera ---
  final Function(Map<String, dynamic> analisis)? onViewDetail;

  const HistoryView({super.key, this.onViewDetail});

  @override
  State<HistoryView> createState() => _HistoryViewState();
}

class _HistoryViewState extends State<HistoryView> {
  final ScrollController _scrollController = ScrollController();
  List<Map<String, dynamic>> _historialReal = [];

  @override
  void initState() {
    super.initState();
    _cargarHistorial();
  }

  Future<void> _cargarHistorial() async {
    final datos = await DatabaseHelper().obtenerHistorial();
    setState(() {
      _historialReal = datos;
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Color _getSeverityColor(String? sev) {
    if (sev == null) return Colors.white70;
    if (sev.contains("Leve")) return Colors.greenAccent;
    if (sev.contains("Moderada")) return Colors.orangeAccent;
    return Colors.redAccent;
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = Responsive.isMobile(context);
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.menuHistorial,
          style: TextStyle(
            fontSize: isMobile ? 24 : 32,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 24),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: isMobile ? 200 : 350,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.black26,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: TextField(
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: l10n.buscarAnalisis,
                  hintStyle: const TextStyle(color: AppColors.textSoft),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: AppColors.textSoft,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.only(top: isMobile ? 12 : 14),
                ),
              ),
            ),
            Container(
              height: 50,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.black26,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.filter_alt_outlined,
                    color: AppColors.textSoft,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    l10n.filtrar,
                    style: const TextStyle(color: AppColors.textSoft),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.keyboard_arrow_down,
                    color: AppColors.textSoft,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        if (_historialReal.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(50.0),
              child: Text(
                "No hay registros disponibles.",
                style: TextStyle(color: AppColors.textSoft),
              ),
            ),
          )
        else
          GlassCard(
            padding: const EdgeInsets.all(0),
            child: Column(
              children: [
                LayoutBuilder(
                  builder: (context, constraints) {
                    final double tableWidth = constraints.maxWidth > 800
                        ? constraints.maxWidth
                        : 800;

                    return Scrollbar(
                      controller: _scrollController,
                      thumbVisibility: true,
                      child: SingleChildScrollView(
                        controller: _scrollController,
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.only(bottom: 16),
                        child: SizedBox(
                          width: tableWidth,
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 18,
                                ),
                                decoration: const BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(color: AppColors.border),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    _tableHeader(l10n.colFecha, flex: 4),
                                    _tableHeader(
                                      l10n.colImagen,
                                      flex: 2,
                                      alignCenter: true,
                                    ),
                                    _tableHeader(l10n.diagnostico, flex: 3),
                                    _tableHeader(l10n.colSeveridad, flex: 2),
                                    _tableHeader(l10n.colIndice, flex: 2),
                                    _tableHeader(
                                      l10n.colAcciones,
                                      flex: 3,
                                      alignCenter: true,
                                    ),
                                  ],
                                ),
                              ),
                              ..._historialReal
                                  .map((data) => _tableRow(data))
                                  .toList(),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    border: Border(top: BorderSide(color: AppColors.border)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.chevron_left, color: AppColors.textSoft),
                      const SizedBox(width: 16),
                      _pageNumber("1", isActive: true),
                      const Icon(
                        Icons.chevron_right,
                        color: AppColors.textSoft,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _tableHeader(
    String text, {
    required int flex,
    bool alignCenter = false,
  }) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        textAlign: alignCenter ? TextAlign.center : TextAlign.left,
        style: const TextStyle(
          color: AppColors.textSoft,
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
      ),
    );
  }

  Widget _tableRow(Map<String, dynamic> data) {
    final statusColor = _getSeverityColor(data["severidad"]);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.white10)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Text(
              data["fecha"] ?? "--",
              style: const TextStyle(fontSize: 13),
            ),
          ),
          Expanded(
            flex: 2,
            child: Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(
                  File(data["ruta_imagen"]),
                  width: 40,
                  height: 40,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.broken_image, color: Colors.red),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              data["diagnostico"] ?? "--",
              style: const TextStyle(fontSize: 14),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              data["severidad"] ?? "--",
              style: TextStyle(color: statusColor, fontSize: 13),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              data["indice"] ?? "0%",
              style: TextStyle(
                color: statusColor,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // --- AQUÍ CONECTAMOS EL OJITO ---
                _actionButton(
                  Icons.visibility_outlined,
                  onTap: () {
                    if (widget.onViewDetail != null) {
                      widget.onViewDetail!(
                        data,
                      ); // Llama a la función del Dashboard
                    }
                  },
                ),
                const SizedBox(width: 8),
                _actionButton(Icons.download_outlined),
                const SizedBox(width: 8),
                _actionButton(Icons.delete_outline, color: AppColors.textSoft),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- FUNCIÓN CORREGIDA: Ahora acepta el parámetro 'onTap' ---
  Widget _actionButton(
    IconData icon, {
    Color color = Colors.white70,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.border),
        ),
        child: Icon(icon, size: 16, color: color),
      ),
    );
  }

  Widget _pageNumber(String number, {bool isActive = false}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isActive ? AppColors.accentSoft : Colors.transparent,
        borderRadius: BorderRadius.circular(6),
        border: isActive ? Border.all(color: AppColors.accent) : null,
      ),
      child: Text(
        number,
        style: TextStyle(
          color: isActive ? AppColors.accent : AppColors.textSoft,
          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }
}
