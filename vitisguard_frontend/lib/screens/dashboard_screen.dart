import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/sidebar.dart';
import '../widgets/upload_panel.dart';
import '../widgets/history_view.dart';
import '../widgets/responsive.dart';
import '../widgets/results_view.dart';
import '../widgets/reportes_view.dart';
import '../widgets/modelos_view.dart';
import '../widgets/configuracion_view.dart';
import '../l10n/app_localizations.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int selectedIndex = 0;

  // --- MEMORIA CENTRAL (Donde viven los datos reales) ---
  double _indice = 0.0;
  double _confianza = 0.0;
  String _diagnostico = "--";
  String? _rutaImagenActual;
  int _areaTotal = 0;
  int _areaAfectada = 0;

  // Función que recibe los datos desde el panel de carga (UploadPanel)
  void _actualizarResultados(
    String diag,
    double conf,
    double ind,
    String ruta,
    int aTotal,
    int aAfectada,
  ) {
    setState(() {
      _diagnostico = diag;
      _confianza = conf;
      _indice = ind;
      _rutaImagenActual = ruta;
      _areaTotal = aTotal;
      _areaAfectada = aAfectada;
      // IMPORTANTE: En el diseño de 2 columnas, no cambiamos de pestaña,
      // nos quedamos en la pestaña 0 para ver ambos paneles.
    });
  }

  // Función que recibe los datos desde el Historial
  void _cargarAnalisisHistorico(Map<String, dynamic> data) {
    setState(() {
      _diagnostico = data["diagnostico"] ?? "--";
      _indice = double.tryParse(data["indice"].replaceAll('%', '')) ?? 0.0;
      _rutaImagenActual = data["ruta_imagen"];
      _areaTotal = data["area_total"] ?? 0;
      _areaAfectada = data["area_afectada"] ?? 0;
      _confianza = 94.0;
      selectedIndex =
          1; // Al cargar del historial con el ojito cambiamos a la pestana de resultados
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = Responsive.isMobile(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: isMobile
          ? Drawer(
              backgroundColor: AppColors.sidebar,
              child: Sidebar(
                selectedIndex: selectedIndex,
                onItemSelected: (index) {
                  setState(() => selectedIndex = index);
                  Navigator.pop(context);
                },
              ),
            )
          : null,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(isMobile, l10n),
            Expanded(
              child: Row(
                children: [
                  if (!isMobile)
                    Sidebar(
                      selectedIndex: selectedIndex,
                      onItemSelected: (index) =>
                          setState(() => selectedIndex = index),
                    ),
                  Expanded(child: _buildCurrentPage(isMobile, l10n)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= LÓGICA DE PESTAÑAS (NAVEGACIÓN) =================
  Widget _buildCurrentPage(bool isMobile, AppLocalizations l10n) {
    final padding = EdgeInsets.all(isMobile ? 16 : 28);

    if (selectedIndex == 0) {
      // 0. PESTAÑA ANÁLISIS: Tu diseño perfecto de 2 columnas
      return SingleChildScrollView(
        padding: padding,
        child: isMobile ? _mobileLayout() : _desktopLayout(),
      );
    } else if (selectedIndex == 1) {
      // 1. PESTAÑA RESULTADOS: Vista enfocada a los datos
      return SingleChildScrollView(
        padding: padding,
        child: Center(
          child: SizedBox(
            width: 800,
            child: ResultsView(
              indice: _indice,
              confianza: _confianza,
              diagnostico: _diagnostico,
              rutaImagen: _rutaImagenActual,
              areaTotal: _areaTotal,
              areaAfectada: _areaAfectada,
              onNuevoAnalisis: () => setState(() {
                _diagnostico = "--";
                selectedIndex = 0; // Regresa al inicio
              }),
            ),
          ),
        ),
      );
    } else if (selectedIndex == 2) {
      // 2. PESTAÑA HISTORIAL: (¡Agregamos el Scroll para quitar el error amarillo!)
      return SingleChildScrollView(
        padding: padding,
        child: HistoryView(onViewDetail: _cargarAnalisisHistorico),
      );
    } else if (selectedIndex == 3) {
      // 3. PESTAÑA REPORTES
      return SingleChildScrollView(
        padding: padding,
        child: const ReportesView(),
      );
    } else if (selectedIndex == 4) {
      // 4. PESTAÑA MODELOS
      return SingleChildScrollView(
        padding: padding,
        child: const ModelosView(),
      );
    } else if (selectedIndex == 5) {
      // 5. PESTAÑA CONFIGURACIÓN
      return SingleChildScrollView(
        padding: padding,
        child: const ConfiguracionView(),
      );
    }

    // Por seguridad, si hay un índice inválido:
    return const SizedBox.shrink();
  }

  // ================= LAYOUTS QUE MANTIENEN EL PANEL DERECHO =================

  Widget _desktopLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // PANEL IZQUIERDO (CARGA)
        Expanded(
          flex: 5, // Toma el 50% del espacio
          child: UploadPanel(onAnalysisComplete: _actualizarResultados),
        ),
        const SizedBox(width: 24),
        // PANEL DERECHO (RESULTADOS) - ¡NO LO BORRAMOS!
        Expanded(
          flex: 6, // Toma un poco más de espacio para las gráficas
          child: ResultsView(
            indice: _indice,
            confianza: _confianza,
            diagnostico: _diagnostico,
            rutaImagen: _rutaImagenActual,
            areaTotal: _areaTotal,
            areaAfectada: _areaAfectada,

            modoCompleto: false,
            onNuevoAnalisis: () => setState(() {
              _diagnostico = "--";
              _indice = 0.0;
              _areaTotal = 0;
              _areaAfectada = 0;
            }),
          ),
        ),
      ],
    );
  }

  Widget _mobileLayout() {
    return Column(
      children: [
        UploadPanel(onAnalysisComplete: _actualizarResultados),
        const SizedBox(height: 20),
        ResultsView(
          indice: _indice,
          confianza: _confianza,
          diagnostico: _diagnostico,
          rutaImagen: _rutaImagenActual,
          areaTotal: _areaTotal,
          areaAfectada: _areaAfectada,
        ),
      ],
    );
  }

  // --- TOP BAR ---
  Widget _buildTopBar(bool isMobile, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(bottom: BorderSide(color: AppColors.border, width: 1.5)),
      ),
      child: Row(
        children: [
          // ¡Aquí está el salvavidas aplicado correctamente!
          if (isMobile)
            Builder(
              builder: (BuildContext innerContext) {
                return IconButton(
                  icon: const Icon(Icons.menu),
                  onPressed: () => Scaffold.of(innerContext).openDrawer(),
                );
              },
            ),
          const Text(
            "VitisGuard",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const Spacer(),
          const Icon(Icons.notifications_none, color: Colors.white70),
        ],
      ),
    );
  }
}
