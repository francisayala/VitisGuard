import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_ru.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
    Locale('ru'),
  ];

  /// No description provided for @configuracion.
  ///
  /// In es, this message translates to:
  /// **'Configuración'**
  String get configuracion;

  /// No description provided for @idioma.
  ///
  /// In es, this message translates to:
  /// **'Idioma'**
  String get idioma;

  /// No description provided for @general.
  ///
  /// In es, this message translates to:
  /// **'General'**
  String get general;

  /// No description provided for @analisis.
  ///
  /// In es, this message translates to:
  /// **'Análisis'**
  String get analisis;

  /// No description provided for @rutas.
  ///
  /// In es, this message translates to:
  /// **'Rutas'**
  String get rutas;

  /// No description provided for @apariencia.
  ///
  /// In es, this message translates to:
  /// **'Apariencia'**
  String get apariencia;

  /// No description provided for @tema.
  ///
  /// In es, this message translates to:
  /// **'Tema'**
  String get tema;

  /// No description provided for @claro.
  ///
  /// In es, this message translates to:
  /// **'Claro'**
  String get claro;

  /// No description provided for @oscuro.
  ///
  /// In es, this message translates to:
  /// **'Oscuro'**
  String get oscuro;

  /// No description provided for @sistema.
  ///
  /// In es, this message translates to:
  /// **'Sistema'**
  String get sistema;

  /// No description provided for @notificaciones.
  ///
  /// In es, this message translates to:
  /// **'Notificaciones'**
  String get notificaciones;

  /// No description provided for @habilitarNotificaciones.
  ///
  /// In es, this message translates to:
  /// **'Habilitar notificaciones'**
  String get habilitarNotificaciones;

  /// No description provided for @sonidos.
  ///
  /// In es, this message translates to:
  /// **'Sonidos'**
  String get sonidos;

  /// No description provided for @actualizaciones.
  ///
  /// In es, this message translates to:
  /// **'Actualizaciones'**
  String get actualizaciones;

  /// No description provided for @buscarAuto.
  ///
  /// In es, this message translates to:
  /// **'Buscar actualizaciones automáticamente'**
  String get buscarAuto;

  /// No description provided for @botonActualizar.
  ///
  /// In es, this message translates to:
  /// **'Buscar actualizaciones'**
  String get botonActualizar;

  /// No description provided for @tituloCargar.
  ///
  /// In es, this message translates to:
  /// **'1. Cargar imagen'**
  String get tituloCargar;

  /// No description provided for @subtituloCargar.
  ///
  /// In es, this message translates to:
  /// **'Sube una imagen de una hoja de vid.'**
  String get subtituloCargar;

  /// No description provided for @arrastraImagen.
  ///
  /// In es, this message translates to:
  /// **'Arrastra tu imagen aquí'**
  String get arrastraImagen;

  /// No description provided for @o.
  ///
  /// In es, this message translates to:
  /// **'o'**
  String get o;

  /// No description provided for @botonSeleccionar.
  ///
  /// In es, this message translates to:
  /// **'Seleccionar imagen'**
  String get botonSeleccionar;

  /// No description provided for @formatos.
  ///
  /// In es, this message translates to:
  /// **'Formatos: JPG, PNG, JPEG | Max: 10 MB'**
  String get formatos;

  /// No description provided for @tituloTips.
  ///
  /// In es, this message translates to:
  /// **'Consejos para mejores resultados'**
  String get tituloTips;

  /// No description provided for @tip1.
  ///
  /// In es, this message translates to:
  /// **'Usa imágenes claras y bien iluminadas'**
  String get tip1;

  /// No description provided for @tip2.
  ///
  /// In es, this message translates to:
  /// **'Enfoca la hoja y evita fondos'**
  String get tip2;

  /// No description provided for @tip3.
  ///
  /// In es, this message translates to:
  /// **'Incluye toda la hoja en la imagen'**
  String get tip3;

  /// No description provided for @botonAnalizar.
  ///
  /// In es, this message translates to:
  /// **'Analizar hoja'**
  String get botonAnalizar;

  /// No description provided for @tituloResultados.
  ///
  /// In es, this message translates to:
  /// **'2. Resultados del análisis'**
  String get tituloResultados;

  /// No description provided for @estadoEsperando.
  ///
  /// In es, this message translates to:
  /// **'Estado: Esperando imagen...'**
  String get estadoEsperando;

  /// No description provided for @indiceAfectacion.
  ///
  /// In es, this message translates to:
  /// **'Índice de afectación'**
  String get indiceAfectacion;

  /// No description provided for @severidadEtiqueta.
  ///
  /// In es, this message translates to:
  /// **'(Severidad)'**
  String get severidadEtiqueta;

  /// No description provided for @areaTotal.
  ///
  /// In es, this message translates to:
  /// **'Área Total'**
  String get areaTotal;

  /// No description provided for @areaAfectada.
  ///
  /// In es, this message translates to:
  /// **'Área Afectada'**
  String get areaAfectada;

  /// No description provided for @nivelSeveridad.
  ///
  /// In es, this message translates to:
  /// **'Nivel de Severidad'**
  String get nivelSeveridad;

  /// No description provided for @sinAfectacion.
  ///
  /// In es, this message translates to:
  /// **'Sin afectación'**
  String get sinAfectacion;

  /// No description provided for @leve.
  ///
  /// In es, this message translates to:
  /// **'Leve'**
  String get leve;

  /// No description provided for @moderada.
  ///
  /// In es, this message translates to:
  /// **'Moderada'**
  String get moderada;

  /// No description provided for @severa.
  ///
  /// In es, this message translates to:
  /// **'Severa'**
  String get severa;

  /// No description provided for @infoAdicional.
  ///
  /// In es, this message translates to:
  /// **'Información adicional'**
  String get infoAdicional;

  /// No description provided for @textoAyudaAnalisis.
  ///
  /// In es, this message translates to:
  /// **'El análisis se mostrará aquí una vez que cargues y proceses una imagen de hoja.'**
  String get textoAyudaAnalisis;

  /// No description provided for @diagnostico.
  ///
  /// In es, this message translates to:
  /// **'Diagnóstico'**
  String get diagnostico;

  /// No description provided for @recomendaciones.
  ///
  /// In es, this message translates to:
  /// **'Recomendaciones'**
  String get recomendaciones;

  /// No description provided for @descargarReporte.
  ///
  /// In es, this message translates to:
  /// **'Descargar Reporte'**
  String get descargarReporte;

  /// No description provided for @nuevoAnalisis.
  ///
  /// In es, this message translates to:
  /// **'Nuevo Análisis'**
  String get nuevoAnalisis;

  /// No description provided for @enfermedadDetectada.
  ///
  /// In es, this message translates to:
  /// **'Enfermedad Detectada'**
  String get enfermedadDetectada;

  /// No description provided for @confianza.
  ///
  /// In es, this message translates to:
  /// **'Confianza'**
  String get confianza;

  /// No description provided for @signosCompatibles.
  ///
  /// In es, this message translates to:
  /// **'Se detectaron signos compatibles con:'**
  String get signosCompatibles;

  /// No description provided for @verTratamiento.
  ///
  /// In es, this message translates to:
  /// **'Ver tratamiento sugerido'**
  String get verTratamiento;

  /// No description provided for @rec1.
  ///
  /// In es, this message translates to:
  /// **'Eliminar hojas muy afectadas'**
  String get rec1;

  /// No description provided for @rec2.
  ///
  /// In es, this message translates to:
  /// **'Mejorar la ventilación entre plantas'**
  String get rec2;

  /// No description provided for @rec3.
  ///
  /// In es, this message translates to:
  /// **'Aplicar tratamiento preventivo recomendado'**
  String get rec3;

  /// No description provided for @tituloHistorial.
  ///
  /// In es, this message translates to:
  /// **'Historial de análisis'**
  String get tituloHistorial;

  /// No description provided for @buscarAnalisis.
  ///
  /// In es, this message translates to:
  /// **'Buscar análisis...'**
  String get buscarAnalisis;

  /// No description provided for @filtrar.
  ///
  /// In es, this message translates to:
  /// **'Filtrar'**
  String get filtrar;

  /// No description provided for @colFecha.
  ///
  /// In es, this message translates to:
  /// **'Fecha'**
  String get colFecha;

  /// No description provided for @colImagen.
  ///
  /// In es, this message translates to:
  /// **'Imagen'**
  String get colImagen;

  /// No description provided for @colSeveridad.
  ///
  /// In es, this message translates to:
  /// **'Severidad'**
  String get colSeveridad;

  /// No description provided for @colIndice.
  ///
  /// In es, this message translates to:
  /// **'Índice'**
  String get colIndice;

  /// No description provided for @colAcciones.
  ///
  /// In es, this message translates to:
  /// **'Acciones'**
  String get colAcciones;

  /// No description provided for @tituloReportes.
  ///
  /// In es, this message translates to:
  /// **'Reportes'**
  String get tituloReportes;

  /// No description provided for @tabGenerar.
  ///
  /// In es, this message translates to:
  /// **'Generar reporte'**
  String get tabGenerar;

  /// No description provided for @tabMisReportes.
  ///
  /// In es, this message translates to:
  /// **'Mis reportes'**
  String get tabMisReportes;

  /// No description provided for @infoReporte.
  ///
  /// In es, this message translates to:
  /// **'Información del reporte'**
  String get infoReporte;

  /// No description provided for @nombreReporte.
  ///
  /// In es, this message translates to:
  /// **'Nombre del reporte'**
  String get nombreReporte;

  /// No description provided for @descReporte.
  ///
  /// In es, this message translates to:
  /// **'Descripción (opcional)'**
  String get descReporte;

  /// No description provided for @seleccionarAnalisis.
  ///
  /// In es, this message translates to:
  /// **'Seleccionar análisis'**
  String get seleccionarAnalisis;

  /// No description provided for @incluirReporte.
  ///
  /// In es, this message translates to:
  /// **'Incluir en el reporte'**
  String get incluirReporte;

  /// No description provided for @chkImagen.
  ///
  /// In es, this message translates to:
  /// **'Imagen original'**
  String get chkImagen;

  /// No description provided for @chkResultados.
  ///
  /// In es, this message translates to:
  /// **'Resultados del análisis'**
  String get chkResultados;

  /// No description provided for @chkRecomendaciones.
  ///
  /// In es, this message translates to:
  /// **'Recomendaciones'**
  String get chkRecomendaciones;

  /// No description provided for @chkInfoHoja.
  ///
  /// In es, this message translates to:
  /// **'Información de la hoja'**
  String get chkInfoHoja;

  /// No description provided for @btnGenerar.
  ///
  /// In es, this message translates to:
  /// **'Generar reporte'**
  String get btnGenerar;

  /// No description provided for @vistaPrevia.
  ///
  /// In es, this message translates to:
  /// **'Vista previa del reporte'**
  String get vistaPrevia;

  /// No description provided for @tituloDocReporte.
  ///
  /// In es, this message translates to:
  /// **'Reporte de Análisis Fitopatológico'**
  String get tituloDocReporte;

  /// No description provided for @tituloModelos.
  ///
  /// In es, this message translates to:
  /// **'Modelos disponibles'**
  String get tituloModelos;

  /// No description provided for @subtituloModelos.
  ///
  /// In es, this message translates to:
  /// **'Gestiona los modelos de IA disponibles en el sistema'**
  String get subtituloModelos;

  /// No description provided for @tipoModelo.
  ///
  /// In es, this message translates to:
  /// **'Tipo:'**
  String get tipoModelo;

  /// No description provided for @entrenadoCon.
  ///
  /// In es, this message translates to:
  /// **'Entrenado con:'**
  String get entrenadoCon;

  /// No description provided for @imagenes.
  ///
  /// In es, this message translates to:
  /// **'imágenes'**
  String get imagenes;

  /// No description provided for @precision.
  ///
  /// In es, this message translates to:
  /// **'Precisión:'**
  String get precision;

  /// No description provided for @fecha.
  ///
  /// In es, this message translates to:
  /// **'Fecha:'**
  String get fecha;

  /// No description provided for @activo.
  ///
  /// In es, this message translates to:
  /// **'Activo'**
  String get activo;

  /// No description provided for @activar.
  ///
  /// In es, this message translates to:
  /// **'Activar'**
  String get activar;

  /// No description provided for @verDetalles.
  ///
  /// In es, this message translates to:
  /// **'Ver detalles'**
  String get verDetalles;

  /// No description provided for @importarModelo.
  ///
  /// In es, this message translates to:
  /// **'Importar nuevo modelo'**
  String get importarModelo;

  /// No description provided for @arrastraModelo.
  ///
  /// In es, this message translates to:
  /// **'Arrastra y suelta el archivo del modelo (.h5, .pt, .pb)'**
  String get arrastraModelo;

  /// No description provided for @seleccionarArchivo.
  ///
  /// In es, this message translates to:
  /// **'Seleccionar archivo'**
  String get seleccionarArchivo;

  /// No description provided for @completadoEl.
  ///
  /// In es, this message translates to:
  /// **'Completado el'**
  String get completadoEl;

  /// No description provided for @menuAnalisis.
  ///
  /// In es, this message translates to:
  /// **'Análisis'**
  String get menuAnalisis;

  /// No description provided for @menuResultados.
  ///
  /// In es, this message translates to:
  /// **'Resultados'**
  String get menuResultados;

  /// No description provided for @menuHistorial.
  ///
  /// In es, this message translates to:
  /// **'Historial'**
  String get menuHistorial;

  /// No description provided for @menuReportes.
  ///
  /// In es, this message translates to:
  /// **'Reportes'**
  String get menuReportes;

  /// No description provided for @menuModelos.
  ///
  /// In es, this message translates to:
  /// **'Modelos'**
  String get menuModelos;

  /// No description provided for @menuConfiguracion.
  ///
  /// In es, this message translates to:
  /// **'Configuración'**
  String get menuConfiguracion;

  /// No description provided for @modeloCNN.
  ///
  /// In es, this message translates to:
  /// **'Modelo CNN v1.2'**
  String get modeloCNN;

  /// No description provided for @mensajeGuardado.
  ///
  /// In es, this message translates to:
  /// **'Análisis guardado en el historial local'**
  String get mensajeGuardado;

  /// No description provided for @continuarAnalisis.
  ///
  /// In es, this message translates to:
  /// **'Continuar con el análisis'**
  String get continuarAnalisis;

  /// No description provided for @errorComunicacion.
  ///
  /// In es, this message translates to:
  /// **'Error comunicándose con el servidor. Por favor, intenta nuevamente.'**
  String get errorComunicacion;

  /// No description provided for @errorGenerarArchivo.
  ///
  /// In es, this message translates to:
  /// **'Todavía no has generado reportes.'**
  String get errorGenerarArchivo;

  /// No description provided for @errorNoseEncuentraArchivo.
  ///
  /// In es, this message translates to:
  /// **'El archivo no se encuentra. ¿Fue borrado manualmente?'**
  String get errorNoseEncuentraArchivo;

  /// No description provided for @descripcionAdicional.
  ///
  /// In es, this message translates to:
  /// **'Descripción / Notas adicionales:'**
  String get descripcionAdicional;

  /// No description provided for @detallesDelModelo.
  ///
  /// In es, this message translates to:
  /// **'Detalles del modelo'**
  String get detallesDelModelo;

  /// Indica el nombre del archivo seleccionado
  ///
  /// In es, this message translates to:
  /// **'Archivo: {fileName}'**
  String archivoModelo(String fileName);

  /// No description provided for @descripcionModelo.
  ///
  /// In es, this message translates to:
  /// **'Escribe una descripción para este modelo:'**
  String get descripcionModelo;

  /// No description provided for @descripcionModeloHint.
  ///
  /// In es, this message translates to:
  /// **'Ej. Modelo entrenado con hojas de viña infectadas...'**
  String get descripcionModeloHint;

  /// No description provided for @botonGuardarDescripcion.
  ///
  /// In es, this message translates to:
  /// **'Guardar'**
  String get botonGuardarDescripcion;

  /// No description provided for @botonCancelarDescripcion.
  ///
  /// In es, this message translates to:
  /// **'Cancelar'**
  String get botonCancelarDescripcion;

  /// No description provided for @campoPrecision.
  ///
  /// In es, this message translates to:
  /// **'Precisión (ej: 94.2%)'**
  String get campoPrecision;

  /// No description provided for @campoPrecisionHint.
  ///
  /// In es, this message translates to:
  /// **'95%'**
  String get campoPrecisionHint;

  /// No description provided for @campoImagenes.
  ///
  /// In es, this message translates to:
  /// **'Cantidad de imágenes'**
  String get campoImagenes;

  /// No description provided for @campoImagenesHint.
  ///
  /// In es, this message translates to:
  /// **'10,000'**
  String get campoImagenesHint;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es', 'ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'ru':
      return AppLocalizationsRu();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
