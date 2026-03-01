# This Python file uses the following encoding: utf-8
import sys
import os
import socket
import rc_qrc
from pathlib import Path

# === Защита от двойного запуска ===
def is_already_running(port):
    sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    try:
        sock.bind(("127.0.0.1", port))
        return False
    except OSError:
        return True
    finally:
        sock.close()

if is_already_running(port = hash("MyUniqueAppName_HMI_CBZ") % 10000 + 20000):
    print(" Данная программа уже запущена!")
    sys.exit(1)

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
from python.py_utils.time_menager.time_menager import TimeManager

from python.py_data_base.db_menager import DB_Menager
from python.py_auth_menager.auth_menager import AuthMenager
from python.py_settings_project.settings_project import SettingsProject
from python.py_menager_theme.menager_theme import MenagerTheme

from python.py_register_component_object.RegisterComponentObject import RegisterComponentObject

class Project:
    def __init__(self):
        super().__init__()
        # Разрешение локального чтения для QML
        os.environ["QML_XHR_ALLOW_FILE_READ"] = "1"

        self._file_path = "files_settings/json_files/settings/project_settings"
        self._file_name = "project_settings.json"

        self.base_path = Path(__file__).resolve().parent

        # --- 1. Активация Сервисов ---
        self.py_message_handler = PyMessageHandler()        
        self.qml_registration_module = QmlRegistrationModule()
        self.time_menager = TimeManager()

        # --- 2. Загрузка настроек базы данных ---
        self.menager_json = Menager_Json()
        self.db_menager = DB_Menager(self.menager_json)

        self.auth_menager = AuthMenager(self.db_menager.db_users._engine_db())
        self.settings_project = SettingsProject(self._file_path, self._file_name, self.db_menager, self.menager_json)
        self.menager_theme = MenagerTheme()

        self.register_component_object = RegisterComponentObject()

        # --- Активация регистрации Qml модулей ----
        self.register_qml_module_auth_menager()
        self.register_qml_module_settings_project()
        self.register_qml_module_menager_theme()
        self.register_qml_module_time_menager()
        self.register_qml_register_component_object()

        # --- 3. Приложение ---
        self.app = QGuiApplication(sys.argv)
        self.engine = QQmlApplicationEngine()
        self.engine.addImportPath(str(self.base_path))

        # --- Запуск ---
        self._load_main_qml()

    def register_qml_module_auth_menager(self):
        self.qml_registration_module.registration_module(self.auth_menager)

    def register_qml_module_settings_project(self):
        self.qml_registration_module.registration_module(self.settings_project)

    def register_qml_module_menager_theme(self):
        try:
                path_file = self.menager_json.read_json_file(self._file_path, self._file_name)
                self.menager_theme.load_theme(path_file["block_graphic_settings"]["theme_path"])
                self.qml_registration_module.registration_module(self.menager_theme)
        except Exception as e:
            print(f"[main.py] : 68 ->  Ошибка в функции 'def register_qml_module_menager_theme(self)': {e}")

    def register_qml_module_time_menager(self):
        self.qml_registration_module.registration_module(self.time_menager)

    def register_qml_register_component_object(self):
        self.qml_registration_module.registration_module(self.register_component_object)

    def _load_main_qml(self):
        """Загружаем QML."""
        # qml_file = self.base_path / "qml/content/splesh_screen/SpleshScreen.qml"
        qml_file = self.base_path / "qml/content/main_window/MainWindow.qml"
        self.engine.load(qml_file)
        if not self.engine.rootObjects():
            del self.engine
            sys.exit(-1)
        sys.exit(self.app.exec())

if __name__ == "__main__":
    Project()
