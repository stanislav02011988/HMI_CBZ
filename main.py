# This Python file uses the following encoding: utf-8
import sys
import os
# import rc_qml
from pathlib import Path

from PySide6.QtGui import QGuiApplication
from PySide6.QtQml import QQmlApplicationEngine

from python.py_utils.qml_registration_module.qml_registration_module import QmlRegistrationModule

from python.py_utils.massage_handler.message_handler import PyMessageHandler
from python.py_utils.utils_json.json_menager import Menager_Json
from python.py_data_base.db_menager import DB_Menager
from python.py_auth_menager.auth_menager import AuthMenager

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

        # --- Активация регистрации Qml модулей ----
        self.register_qml_module_auth_menager()

        # --- 3. Приложение ---
        self.app = QGuiApplication(sys.argv)
        self.engine = QQmlApplicationEngine()
        self.engine.addImportPath(str(self.base_path))
        # self.engine.addImportPath(str(self.base_path / "qml/utils"))

        # --- Запуск ---
        self._load_main_qml()

    def register_qml_module_auth_menager(self):
        self.qml_registration_module.registration_module(self.auth_menager)



    def _load_main_qml(self):
        """Загружаем QML."""
        qml_file = self.base_path / "qml/splesh_screen/SpleshScreen.qml"
        self.engine.load(qml_file)
        if not self.engine.rootObjects():
            del self.engine
            sys.exit(-1)
        sys.exit(self.app.exec())

if __name__ == "__main__":
    Project()
