import cv2
import numpy as np
from PyQt6.QtWidgets import (QMainWindow, QWidget, QVBoxLayout, QHBoxLayout, 
                             QPushButton, QLabel, QFileDialog, QFrame, QProgressBar)
from PyQt6.QtGui import QPixmap, QImage, QPainter, QColor, QPen, QConicalGradient
from PyQt6.QtCore import Qt, QRectF

# --- CLASE PARA EL GRÁFICO CIRCULAR DEL IAA ---
class CircularProgress(QWidget):
    def __init__(self, parent=None):
        super().__init__(parent)
        self.value = 0
        self.setFixedSize(220, 220)

    def set_value(self, value):
        self.value = value
        self.update()

    def paintEvent(self, event):
        width = self.width()
        height = self.height()
        margin = 20
        rect = QRectF(margin, margin, width - 2*margin, height - 2*margin)
        
        painter = QPainter(self)
        painter.setRenderHint(QPainter.RenderHint.Antialiasing)

        # Fondo del círculo (gris oscuro)
        pen = QPen()
        pen.setWidth(15)
        pen.setColor(QColor("#2C323D"))
        painter.setPen(pen)
        painter.drawEllipse(rect)

        # Arco de progreso (verde a rojo según severidad)
        pen.setColor(QColor("#00E676") if self.value < 20 else QColor("#FF5252"))
        pen.setCapStyle(Qt.PenCapStyle.RoundCap)
        painter.setPen(pen)
        # El ángulo se mide en 1/16 de grado. 360 grados * 16 = 5760.
        span_angle = int(-self.value * 57.6) 
        painter.drawArc(rect, 90 * 16, span_angle)

        # Texto central
        painter.setPen(QColor("#FFFFFF"))
        font = painter.font()
        font.setPointSize(28)
        font.setBold(True)
        painter.setFont(font)
        painter.drawText(rect, Qt.AlignmentFlag.AlignCenter, f"{int(self.value)}%")

# --- VENTANA PRINCIPAL CON DISEÑO DARK ---
class VitisGuardMainWindow(QMainWindow):
    def __init__(self, controller):
        super().__init__()
        self.controller = controller
        self.current_image_path = None
        
        self.setWindowTitle("VitisGuard Pro - Sistema de Diagnóstico")
        self.resize(1200, 800)
        
        # Aplicamos el estilo Dark que viste en tu imagen
        self.setStyleSheet("""
            QMainWindow { background-color: #1A1F24; }
            QWidget#Sidebar { background-color: #11151A; border-right: 1px solid #2C323D; }
            QLabel { color: #FFFFFF; font-family: 'Segoe UI'; }
            QPushButton { 
                background-color: #2C323D; color: white; border-radius: 8px; 
                padding: 10px; font-weight: bold; border: None;
            }
            QPushButton:hover { background-color: #3E4552; }
            QPushButton#BtnAction { background-color: #2E7D32; }
            QPushButton#BtnAction:hover { background-color: #388E3C; }
            QFrame#Card { background-color: #24292E; border-radius: 12px; }
            QProgressBar {
                border: 2px solid #2C323D; border-radius: 5px; text-align: center; background-color: #1A1F24;
            }
            QProgressBar::chunk { background-color: #FF5252; width: 10px; }
        """)
        
        self.init_ui()

    def init_ui(self):
        main_layout = QHBoxLayout()
        main_layout.setContentsMargins(0, 0, 0, 0)
        main_layout.setSpacing(0)

        # 1. SIDEBAR IZQUIERDO
        sidebar = QFrame()
        sidebar.setObjectName("Sidebar")
        sidebar.setFixedWidth(200)
        sidebar_layout = QVBoxLayout(sidebar)
        
        logo = QLabel("VitisGuard")
        logo.setStyleSheet("font-size: 20px; font-weight: bold; color: #00E676; margin-bottom: 30px;")
        sidebar_layout.addWidget(logo)
        
        sidebar_layout.addWidget(QPushButton("📊 Detección"))
        sidebar_layout.addWidget(QPushButton("📜 Historial"))
        sidebar_layout.addWidget(QPushButton("⚙️ Configuración"))
        sidebar_layout.addStretch()
        
        main_layout.addWidget(sidebar)

        # 2. ÁREA CENTRAL (Visualización e Inferencia)
        center_area = QVBoxLayout()
        center_area.setContentsMargins(30, 30, 30, 30)

        # Card para la imagen
        image_card = QFrame()
        image_card.setObjectName("Card")
        img_layout = QVBoxLayout(image_card)
        self.lbl_image = QLabel("Vista previa de la hoja")
        self.lbl_image.setAlignment(Qt.AlignmentFlag.AlignCenter)
        self.lbl_image.setFixedSize(600, 450)
        self.lbl_image.setStyleSheet("border: 1px solid #3E4552;")
        img_layout.addWidget(self.lbl_image)
        
        center_area.addWidget(image_card)

        # Botones de Acción
        action_layout = QHBoxLayout()
        self.btn_load = QPushButton("📁 Cargar Imagen")
        self.btn_load.clicked.connect(self.load_image)
        
        self.btn_analyze = QPushButton("🚀 ANALIZAR")
        self.btn_analyze.setObjectName("BtnAction")
        self.btn_analyze.setEnabled(False)
        self.btn_analyze.clicked.connect(self.run_analysis)
        
        action_layout.addWidget(self.btn_load)
        action_layout.addWidget(self.btn_analyze)
        center_area.addLayout(action_layout)
        
        main_layout.addLayout(center_area)

        # 3. PANEL DERECHO (Resultados y Estadísticas)
        right_panel = QVBoxLayout()
        right_panel.setContentsMargins(10, 30, 30, 30)

        # Card del IAA (Gráfico circular)
        iaa_card = QFrame()
        iaa_card.setObjectName("Card")
        iaa_layout = QVBoxLayout(iaa_card)
        iaa_layout.addWidget(QLabel("Severidad (IAA)"), alignment=Qt.AlignmentFlag.AlignCenter)
        
        self.iaa_circle = CircularProgress()
        iaa_layout.addWidget(self.iaa_circle, alignment=Qt.AlignmentFlag.AlignCenter)
        
        right_panel.addWidget(iaa_card)

        # Card de Diagnóstico (Nivel de afectación)
        diag_card = QFrame()
        diag_card.setObjectName("Card")
        diag_layout = QVBoxLayout(diag_card)
        diag_layout.addWidget(QLabel("Nivel de Afectación"))
        
        self.progress_severity = QProgressBar()
        self.progress_severity.setValue(0)
        diag_layout.addWidget(self.progress_severity)
        
        self.lbl_diag = QLabel("Sin detección")
        self.lbl_diag.setStyleSheet("color: #00E676; font-weight: bold;")
        diag_layout.addWidget(self.lbl_diag)
        
        right_panel.addWidget(diag_card)
        
        main_layout.addLayout(right_panel)

        container = QWidget()
        container.setLayout(main_layout)
        self.setCentralWidget(container)

    # --- LÓGICA DE FUNCIONAMIENTO ---

    def load_image(self):
        path, _ = QFileDialog.getOpenFileName(self, "Seleccionar Hoja", "", "Images (*.png *.jpg *.jpeg)")
        if path:
            self.current_image_path = path
            pixmap = QPixmap(path)
            self.lbl_image.setPixmap(pixmap.scaled(600, 450, Qt.AspectRatioMode.KeepAspectRatio))
            self.btn_analyze.setEnabled(True)

    def run_analysis(self):
        # Aquí conectamos con el controlador que ya tenemos
        try:
            res = self.controller.analyze_and_save(self.current_image_path)
            iaa = res["metrics"]["iaa"]
            
            # Actualizamos la UI al estilo de tu imagen
            self.iaa_circle.set_value(iaa)
            self.progress_severity.setValue(int(iaa))
            
            if iaa == 0: self.lbl_diag.setText("SANO"); self.lbl_diag.setStyleSheet("color: #00E676;")
            elif iaa < 15: self.lbl_diag.setText("LEVE"); self.lbl_diag.setStyleSheet("color: #FFEB3B;")
            else: self.lbl_diag.setText("SEVERO"); self.lbl_diag.setStyleSheet("color: #FF5252;")

            # Dibujamos las máscaras
            if res["formatted_data"]:
                self.draw_result(res["formatted_data"])

        except Exception as e:
            print(f"Error: {e}")

    def draw_result(self, data):
        # Lógica de pintado con OpenCV (Igual a la anterior para mostrar resultados)
        img = cv2.imread(self.current_image_path)
        overlay = img.copy()
        for mask, label in zip(data['masks'], data['labels']):
            m_resized = cv2.resize(mask, (img.shape[1], img.shape[0]))
            color = (0, 255, 0) if label == 'Healthy' else (0, 0, 255)
            overlay[m_resized > 0] = color
        
        blended = cv2.addWeighted(overlay, 0.5, img, 0.5, 0)
        rgb = cv2.cvtColor(blended, cv2.COLOR_BGR2RGB)
        h, w, ch = rgb.shape
        qt_img = QImage(rgb.data, w, h, ch*w, QImage.Format.Format_RGB888)
        self.lbl_image.setPixmap(QPixmap.fromImage(qt_img).scaled(600, 450, Qt.AspectRatioMode.KeepAspectRatio))