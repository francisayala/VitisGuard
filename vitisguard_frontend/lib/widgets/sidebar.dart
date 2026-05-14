import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../l10n/app_localizations.dart';
import '../widgets/global_state.dart';

class Sidebar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;

  const Sidebar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!; // <--- Inicializamos

    return Container(
      width: 250,
      decoration: const BoxDecoration(
        color: AppColors.sidebar,
        border: Border(right: BorderSide(color: AppColors.border)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Un pequeño espacio superior para que los botones no queden pegados al techo
            const SizedBox(height: 14),

            // Opciones del Menú (TRADUCIDAS)
            _item(Icons.analytics_outlined, l10n.menuAnalisis, 0),
            _item(Icons.bar_chart_outlined, l10n.menuResultados, 1),
            _item(Icons.history, l10n.menuHistorial, 2),
            _item(Icons.description_outlined, l10n.menuReportes, 3),
            _item(Icons.extension_outlined, l10n.menuModelos, 4),
            _item(Icons.settings_outlined, l10n.menuConfiguracion, 5),

            // Esto empuja la tarjeta inferior hacia abajo del todo
            const Spacer(),

            // Tarjeta inferior de VitisGuard / Perfil
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    backgroundColor: AppColors.accent,
                    child: Text(
                      "VG",
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "VitisGuard",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        // NUEVO CÓDIGO: El Sidebar escucha los cambios en vivo
                        ValueListenableBuilder<String>(
                          valueListenable: modeloActivoGlobal,
                          builder: (context, nombreDelModelo, child) {
                            return Text(
                              nombreDelModelo, // Aquí se imprime lo que diga el Walkie-Talkie
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: AppColors.textSoft,
                                fontSize: 12,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Componente visual de cada botón del menú
  Widget _item(IconData icon, String title, int index) {
    final active = selectedIndex == index;

    return GestureDetector(
      onTap: () {
        onItemSelected(index);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        decoration: BoxDecoration(
          color: active ? AppColors.accentSoft : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            Icon(icon, color: active ? AppColors.accent : Colors.white70),
            const SizedBox(width: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                color: active ? AppColors.accent : Colors.white70,
                fontWeight: active ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
