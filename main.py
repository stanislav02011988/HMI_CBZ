# This Python file uses the following encoding: utf-8
import sys
import os
# import rc_qml
from pathlib import Path

# Отключаем DPI-масштабирование Windows
if sys.platform == "win32":
    os.environ["QT_AUTO_SCREEN_SCALE_FACTOR"] = "0"
    os.environ["QT_ENABLE_HIGHDPI_SCALING"] = "0"
    os.environ["QT_SCALE_FACTOR"] = "1"
    os.environ["QT_DPI_ADJUSTMENT"] = "false"

from PySide6.QtGui import QGuiApplication
from PySide6.QtQml import QQmlApplicationEngine

from python.py_utils.qml_registration_module.qml_registration_module import QmlRegistrationModule

from python.py_utils.massage_handler.message_handler import PyMessageHandler
from python.py_utils.utils_json.json_menager import Menager_Json
from python.py_data_base.db_menager import DB_Menager
from python.py_auth_menager.auth_menager import AuthMenager
from python.py_settings_project.settings_project import SettingsProject

class Project:
    def __init__(self):
        super().__init__()
        # Разрешение локального чтения для QML
        os.environ["QML_XHR_ALLOW_FILE_READ"] = "1"

        self.base_path = Path(__file__).resolve().parent

        # --- 1. Активация Сервисов ---
        self.py_message_handler = PyMessageHandler()        
        self.qml_registration_module = QmlRegistrationModule()

        # --- 2. Загрузка настроек базы данных ---
        self.menager_json = Menager_Json()
        self.db_menager = DB_Menager(self.menager_json)

        self.auth_menager = AuthMenager(self.db_menager.db_users._engine_db())
        self.settings_project = SettingsProject(self.db_menager, self.menager_json)

        # --- Активация регистрации Qml модулей ----
        self.register_qml_module_auth_menager()

        # --- 3. Приложение ---
        self.app = QGuiApplication(sys.argv)
        self.engine = QQmlApplicationEngine()
        self.engine.addImportPath(str(self.base_path))

        # --- Запуск ---
        self._load_main_qml()

    def register_qml_module_auth_menager(self):
        self.qml_registration_module.registration_module(self.auth_menager)
        self.qml_registration_module.registration_module(self.settings_project)

    def _load_main_qml(self):
        """Загружаем QML."""
        qml_file = self.base_path / "qml/splesh_screen/SpleshScreen.qml"
        # qml_file = self.base_path / "qml/windows/main_window/MainWindow.qml"
        self.engine.load(qml_file)
        if not self.engine.rootObjects():
            del self.engine
            sys.exit(-1)
        sys.exit(self.app.exec())

if __name__ == "__main__":
    Project()
