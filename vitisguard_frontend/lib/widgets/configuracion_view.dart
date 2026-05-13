import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import 'responsive.dart';

import '../l10n/app_localizations.dart';
import '../../main.dart';

class ConfiguracionView extends StatefulWidget {
  const ConfiguracionView({super.key});

  @override
  State<ConfiguracionView> createState() => _ConfiguracionViewState();
}

class _ConfiguracionViewState extends State<ConfiguracionView> {
  int _currentTab = 0;

  /// INTERNAL VALUES
  String _temaSeleccionado = "dark";

  bool _notificacionesEnabled = true;
  bool _sonidosEnabled = true;
  bool _autoUpdateEnabled = true;

  @override
  Widget build(BuildContext context) {
    final bool isMobile = Responsive.isMobile(context);

    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        /// ================= HEADER =================
        Text(
          l10n.configuracion,

          style: TextStyle(
            fontSize: isMobile ? 24 : 32,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 24),

        /// ================= TABS =================
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,

          child: Row(
            children: [
              _buildTab(l10n.general, 0),

              const SizedBox(width: 32),

              _buildTab(l10n.analisis, 1),

              const SizedBox(width: 32),

              _buildTab(l10n.rutas, 2),

              const SizedBox(width: 32),

              _buildTab(l10n.apariencia, 3),
            ],
          ),
        ),

        Container(
          height: 1,
          width: double.infinity,

          color: AppColors.border,

          margin: const EdgeInsets.only(bottom: 24),
        ),

        /// ================= TAB CONTENT =================
        if (_currentTab == 0)
          _buildGeneralTab(l10n)
        else
          Center(
            child: Padding(
              padding: const EdgeInsets.all(40),

              child: Text(
                "Opciones de ${_getTabName(_currentTab, l10n)} en construcción...",

                style: const TextStyle(color: AppColors.textSoft),
              ),
            ),
          ),
      ],
    );
  }

  /// ================= TAB NAMES =================
  String _getTabName(int index, AppLocalizations l10n) {
    switch (index) {
      case 1:
        return l10n.analisis;

      case 2:
        return l10n.rutas;

      case 3:
        return l10n.apariencia;

      default:
        return "";
    }
  }

  /// ================= TAB BUTTON =================
  Widget _buildTab(String title, int index) {
    final bool isActive = _currentTab == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _currentTab = index;
        });
      },

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

          const SizedBox(height: 12),

          Container(
            height: 3,
            width: 80,

            color: isActive ? AppColors.accent : Colors.transparent,
          ),
        ],
      ),
    );
  }

  /// ================= GENERAL TAB =================
  Widget _buildGeneralTab(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        /// ================= LANGUAGE =================
        _buildSectionTitle(l10n.idioma),

        Container(
          width: double.infinity,

          padding: const EdgeInsets.symmetric(horizontal: 16),

          decoration: BoxDecoration(
            color: AppColors.card,

            borderRadius: BorderRadius.circular(12),

            border: Border.all(color: AppColors.border),
          ),

          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: MyApp.localeNotifier.value.languageCode,

              dropdownColor: AppColors.card,

              style: const TextStyle(color: Colors.white, fontSize: 15),

              icon: const Icon(
                Icons.keyboard_arrow_down,
                color: AppColors.textSoft,
              ),

              items: const [
                DropdownMenuItem(value: 'es', child: Text("Español")),

                DropdownMenuItem(value: 'en', child: Text("English")),

                DropdownMenuItem(value: 'ru', child: Text("Русский")),
              ],

              onChanged: (newValue) {
                if (newValue != null) {
                  MyApp.localeNotifier.value = Locale(newValue);

                  setState(() {});
                }
              },
            ),
          ),
        ),

        const SizedBox(height: 32),

        /// ================= THEME =================
        _buildSectionTitle(l10n.tema),

        Container(
          padding: const EdgeInsets.all(6),

          decoration: BoxDecoration(
            color: AppColors.card,

            borderRadius: BorderRadius.circular(16),

            border: Border.all(color: AppColors.border),
          ),

          child: Wrap(
            spacing: 8,
            runSpacing: 8,

            children: [
              _buildThemeOption(value: "light", label: l10n.claro),

              _buildThemeOption(value: "dark", label: l10n.oscuro),

              _buildThemeOption(value: "system", label: l10n.sistema),
            ],
          ),
        ),

        const SizedBox(height: 32),

        /// ================= NOTIFICATIONS =================
        _buildSectionTitle(l10n.notificaciones),

        Container(
          decoration: BoxDecoration(
            color: AppColors.card,

            borderRadius: BorderRadius.circular(16),

            border: Border.all(color: AppColors.border),
          ),

          child: Column(
            children: [
              _buildSwitchRow(
                l10n.habilitarNotificaciones,

                _notificacionesEnabled,

                (val) {
                  setState(() {
                    _notificacionesEnabled = val;
                  });
                },
              ),

              const Divider(color: AppColors.border, height: 1),

              _buildSwitchRow(l10n.sonidos, _sonidosEnabled, (val) {
                setState(() {
                  _sonidosEnabled = val;
                });
              }),
            ],
          ),
        ),

        const SizedBox(height: 32),

        /// ================= UPDATES =================
        _buildSectionTitle(l10n.actualizaciones),

        Container(
          padding: const EdgeInsets.all(20),

          decoration: BoxDecoration(
            color: AppColors.card,

            borderRadius: BorderRadius.circular(16),

            border: Border.all(color: AppColors.border),
          ),

          child: Responsive.isMobile(context)
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,

                      children: [
                        Expanded(
                          child: Text(
                            l10n.buscarAuto,

                            style: const TextStyle(fontSize: 15),
                          ),
                        ),

                        Switch(
                          value: _autoUpdateEnabled,

                          onChanged: (val) {
                            setState(() {
                              _autoUpdateEnabled = val;
                            });
                          },

                          activeColor: AppColors.accent,
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    _buildUpdateBtn(l10n.botonActualizar),
                  ],
                )
              : Row(
                  children: [
                    Expanded(
                      child: Text(
                        l10n.buscarAuto,

                        style: const TextStyle(fontSize: 15),
                      ),
                    ),

                    Switch(
                      value: _autoUpdateEnabled,

                      onChanged: (val) {
                        setState(() {
                          _autoUpdateEnabled = val;
                        });
                      },

                      activeColor: AppColors.accent,
                    ),

                    const SizedBox(width: 20),

                    _buildUpdateBtn(l10n.botonActualizar),
                  ],
                ),
        ),
      ],
    );
  }

  /// ================= SECTION TITLE =================
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),

      child: Text(
        title,

        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }

  /// ================= THEME OPTION =================
  Widget _buildThemeOption({required String value, required String label}) {
    final bool isSelected = _temaSeleccionado == value;

    return GestureDetector(
      onTap: () {
        setState(() {
          _temaSeleccionado = value;
        });
      },

      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),

        decoration: BoxDecoration(
          color: isSelected ? Colors.black26 : Colors.transparent,

          borderRadius: BorderRadius.circular(10),

          border: isSelected ? Border.all(color: AppColors.border) : null,
        ),

        child: Row(
          mainAxisSize: MainAxisSize.min,

          children: [
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,

              color: isSelected ? AppColors.accent : AppColors.textSoft,

              size: 20,
            ),

            const SizedBox(width: 8),

            Text(
              label,

              style: TextStyle(
                color: isSelected ? Colors.white : AppColors.textSoft,

                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// ================= SWITCH ROW =================
  Widget _buildSwitchRow(String title, bool value, Function(bool) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),

      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,

        children: [
          Expanded(child: Text(title, style: const TextStyle(fontSize: 15))),

          Switch(
            value: value,

            onChanged: onChanged,

            activeColor: AppColors.accent,
          ),
        ],
      ),
    );
  }

  /// ================= UPDATE BUTTON =================
  Widget _buildUpdateBtn(String label) {
    return ElevatedButton(
      onPressed: () {},

      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.transparent,

        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),

        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),

          side: const BorderSide(color: AppColors.border),
        ),
      ),

      child: Text(label, style: const TextStyle(color: Colors.white)),
    );
  }
}
