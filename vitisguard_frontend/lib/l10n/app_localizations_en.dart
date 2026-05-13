// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get configuracion => 'Settings';

  @override
  String get idioma => 'Language';

  @override
  String get general => 'General';

  @override
  String get analisis => 'Analysis';

  @override
  String get rutas => 'Paths';

  @override
  String get apariencia => 'Appearance';

  @override
  String get tema => 'Theme';

  @override
  String get claro => 'Light';

  @override
  String get oscuro => 'Dark';

  @override
  String get sistema => 'System';

  @override
  String get notificaciones => 'Notifications';

  @override
  String get habilitarNotificaciones => 'Enable notifications';

  @override
  String get sonidos => 'Sounds';

  @override
  String get actualizaciones => 'Updates';

  @override
  String get buscarAuto => 'Check for updates automatically';

  @override
  String get botonActualizar => 'Check for updates';

  @override
  String get tituloCargar => '1. Upload image';

  @override
  String get subtituloCargar => 'Upload an image of a grapevine leaf.';

  @override
  String get arrastraImagen => 'Drag your image here';

  @override
  String get o => 'or';

  @override
  String get botonSeleccionar => 'Select image';

  @override
  String get formatos => 'Formats: JPG, PNG, JPEG | Max: 10 MB';

  @override
  String get tituloTips => 'Tips for better results';

  @override
  String get tip1 => 'Use clear and well-lit images';

  @override
  String get tip2 => 'Focus on the leaf and avoid backgrounds';

  @override
  String get tip3 => 'Include the entire leaf in the image';

  @override
  String get botonAnalizar => 'Analyze leaf';

  @override
  String get tituloResultados => '2. Analysis results';

  @override
  String get estadoEsperando => 'Status: Waiting for image...';

  @override
  String get indiceAfectacion => 'Infection index';

  @override
  String get severidadEtiqueta => '(Severity)';

  @override
  String get areaTotal => 'Total Area';

  @override
  String get areaAfectada => 'Affected Area';

  @override
  String get nivelSeveridad => 'Severity Level';

  @override
  String get sinAfectacion => 'No affection';

  @override
  String get leve => 'Mild';

  @override
  String get moderada => 'Moderate';

  @override
  String get severa => 'Severe';

  @override
  String get infoAdicional => 'Additional information';

  @override
  String get textoAyudaAnalisis =>
      'The analysis will appear here once you upload and process a leaf image.';

  @override
  String get diagnostico => 'Diagnosis';

  @override
  String get recomendaciones => 'Recommendations';

  @override
  String get descargarReporte => 'Download Report';

  @override
  String get nuevoAnalisis => 'New Analysis';

  @override
  String get enfermedadDetectada => 'Detected Disease';

  @override
  String get confianza => 'Confidence';

  @override
  String get signosCompatibles => 'Signs detected compatible with:';

  @override
  String get verTratamiento => 'View suggested treatment';

  @override
  String get rec1 => 'Remove heavily affected leaves';

  @override
  String get rec2 => 'Improve ventilation between plants';

  @override
  String get rec3 => 'Apply recommended preventive treatment';

  @override
  String get tituloHistorial => 'Analysis History';

  @override
  String get buscarAnalisis => 'Search analysis...';

  @override
  String get filtrar => 'Filter';

  @override
  String get colFecha => 'Date';

  @override
  String get colImagen => 'Image';

  @override
  String get colSeveridad => 'Severity';

  @override
  String get colIndice => 'Index';

  @override
  String get colAcciones => 'Actions';

  @override
  String get tituloReportes => 'Reports';

  @override
  String get tabGenerar => 'Generate report';

  @override
  String get tabMisReportes => 'My reports';

  @override
  String get infoReporte => 'Report information';

  @override
  String get nombreReporte => 'Report name';

  @override
  String get descReporte => 'Description (optional)';

  @override
  String get seleccionarAnalisis => 'Select analysis';

  @override
  String get incluirReporte => 'Include in report';

  @override
  String get chkImagen => 'Original image';

  @override
  String get chkResultados => 'Analysis results';

  @override
  String get chkRecomendaciones => 'Recommendations';

  @override
  String get chkInfoHoja => 'Leaf information';

  @override
  String get btnGenerar => 'Generate report';

  @override
  String get vistaPrevia => 'Report preview';

  @override
  String get tituloDocReporte => 'Phytopathological Analysis Report';

  @override
  String get tituloModelos => 'Available models';

  @override
  String get subtituloModelos => 'Manage available AI models in the system';

  @override
  String get tipoModelo => 'Type:';

  @override
  String get entrenadoCon => 'Trained with:';

  @override
  String get imagenes => 'images';

  @override
  String get precision => 'Accuracy:';

  @override
  String get fecha => 'Date:';

  @override
  String get activo => 'Active';

  @override
  String get activar => 'Activate';

  @override
  String get verDetalles => 'View details';

  @override
  String get importarModelo => 'Import new model';

  @override
  String get arrastraModelo => 'Drag and drop the model file (.h5, .pt, .pb)';

  @override
  String get seleccionarArchivo => 'Select file';

  @override
  String get completadoEl => 'Completed on';

  @override
  String get menuAnalisis => 'Analysis';

  @override
  String get menuResultados => 'Results';

  @override
  String get menuHistorial => 'History';

  @override
  String get menuReportes => 'Reports';

  @override
  String get menuModelos => 'Models';

  @override
  String get menuConfiguracion => 'Settings';

  @override
  String get modeloCNN => 'CNN Model v1.2';

  @override
  String get mensajeGuardado => 'Analysis saved to local history';

  @override
  String get continuarAnalisis => 'Continue with the analysis';
}
