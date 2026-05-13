1. Arquitectura del Proyecto (Formato Texto)
   La arquitectura se divide en capas de responsabilidad para garantizar la modularidad y la facilidad de mantenimiento:
   Raíz del Proyecto:
   assets/: Almacenamiento de modelos de redes neuronales (archivos .tflite o .onnx) y etiquetas de clases.
   lib/: Código fuente principal estructurado por funcionalidades.
   test/: Pruebas unitarias e integrales para validar la precisión de la segmentación.

Capa Común (lib/common/):
config/: Parámetros globales, umbrales de confianza (thresholds) y configuración del modelo.
database/: Implementación de la base de datos local (Drift/SQLite) para el historial de análisis.
models/: Entidades de dominio que representan las hojas, enfermedades y reportes de severidad.
repositories/: Abstracciones para el acceso a datos y almacenamiento de imágenes.

Capa de Funcionalidades (lib/features/):
Cada módulo (Detección, Analítica, Catálogo) se divide en subcapas:
presentation/: Interfaces de usuario (UI) y gestión de la cámara.
domain/: Lógica de negocio específica del módulo.
data/: Repositorios específicos y fuentes de datos locales.Capa de Servicios (lib/services/):
ai_inference_service: Gestión del motor de Deep Learning para segmentación de instancia.severity_calculator_service: Algoritmo matemático para el cálculo del área afectada en la hoja.
