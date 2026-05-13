import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'glass_card.dart';
import 'responsive.dart';
import '../l10n/app_localizations.dart';
import '../services/database_helper.dart';
import 'dart:io';
import 'dart:math';

class HistoryView extends StatefulWidget {
  final Function(Map<String, dynamic> analisis)? onViewDetail;

  const HistoryView({super.key, this.onViewDetail});

  @override
  State<HistoryView> createState() => _HistoryViewState();
}

class _HistoryViewState extends State<HistoryView> {
  final ScrollController _scrollController = ScrollController();
  List<Map<String, dynamic>> _historialReal = [];

  // --- VARIABLES DE PAGINACIÓN ---
  int _paginaActual = 1;
  final int _itemsPorPagina =
      8; // Puedes ajustar este número según tus necesidades

  @override
  void initState() {
    super.initState();
    _cargarHistorial();
  }

  Future<void> _cargarHistorial() async {
    final datos = await DatabaseHelper().obtenerHistorial();
    setState(() {
      _historialReal = datos;
      _paginaActual = 1; // Reseteamos a la página 1 al cargar
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

  // --- LÓGICA MATEMÁTICA DE LA PAGINACIÓN ---
  int get _totalPaginas => (_historialReal.length / _itemsPorPagina).ceil();

  List<Map<String, dynamic>> get _itemsPaginaActual {
    int start = (_paginaActual - 1) * _itemsPorPagina;
    int end = min(start + _itemsPorPagina, _historialReal.length);
    if (start >= _historialReal.length) return []; // Seguridad
    return _historialReal.sublist(start, end);
  }

  void _cambiarPagina(int nuevaPagina) {
    if (nuevaPagina >= 1 && nuevaPagina <= _totalPaginas) {
      setState(() {
        _paginaActual = nuevaPagina;
      });
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
                              // USAMOS LA LISTA RECORTADA (PAGINADA) EN VEZ DEL HISTORIAL COMPLETO
                              ..._itemsPaginaActual
                                  .map((data) => _tableRow(data))
                                  .toList(),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),

                // --- BOTONES DE PAGINACIÓN DINÁMICOS ---
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    border: Border(top: BorderSide(color: AppColors.border)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Flecha Izquierda (Anterior)
                      IconButton(
                        onPressed: _paginaActual > 1
                            ? () => _cambiarPagina(_paginaActual - 1)
                            : null,
                        icon: Icon(
                          Icons.chevron_left,
                          color: _paginaActual > 1
                              ? AppColors.text
                              : AppColors.textSoft.withOpacity(0.3),
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Generar números de página
                      ...List.generate(_totalPaginas, (index) {
                        int numeroPagina = index + 1;
                        // Lógica básica para no mostrar 100 números, solo los cercanos
                        if (_totalPaginas > 5) {
                          if (numeroPagina != 1 &&
                              numeroPagina != _totalPaginas &&
                              (numeroPagina < _paginaActual - 1 ||
                                  numeroPagina > _paginaActual + 1)) {
                            // Mostrar puntos suspensivos si hay saltos grandes
                            if (numeroPagina == 2 ||
                                numeroPagina == _totalPaginas - 1) {
                              return const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 8),
                                child: Text(
                                  "...",
                                  style: TextStyle(color: AppColors.textSoft),
                                ),
                              );
                            }
                            return const SizedBox.shrink();
                          }
                        }

                        return GestureDetector(
                          onTap: () => _cambiarPagina(numeroPagina),
                          child: _pageNumber(
                            numeroPagina.toString(),
                            isActive: numeroPagina == _paginaActual,
                          ),
                        );
                      }),

                      const SizedBox(width: 8),
                      // Flecha Derecha (Siguiente)
                      IconButton(
                        onPressed: _paginaActual < _totalPaginas
                            ? () => _cambiarPagina(_paginaActual + 1)
                            : null,
                        icon: Icon(
                          Icons.chevron_right,
                          color: _paginaActual < _totalPaginas
                              ? AppColors.text
                              : AppColors.textSoft.withOpacity(0.3),
                        ),
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
                _actionButton(
                  Icons.visibility_outlined,
                  onTap: () {
                    if (widget.onViewDetail != null) {
                      widget.onViewDetail!(data);
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
