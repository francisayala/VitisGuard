import 'package:flutter/material.dart';

// Este es nuestro "comunicador global".
// Empieza diciendo "Cargando..." pero enseguida cambiará.
final ValueNotifier<String> modeloActivoGlobal = ValueNotifier<String>(
  "Cargando modelo...",
);
