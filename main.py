# This Python file uses the following encoding: utf-8
import sys
import os
# import rc_qml
from pathlib import Path

from PySide6.QtGui import QGuiApplication
from PySide6.QtQml import QQmlApplicationEngine

from python.py_utils.massage_handler.message_handler import PyMessageHandler
from python.py_utils.utils_json.json_manager import Manager_Json
from python.py_data_base.database_connect import DataBaseConnect

class Project:
    def __init__(self):
        super().__init__()
        # Разрешение локального чтения для QML
        os.environ["QML_XHR_ALLOW_FILE_READ"] = "1"

        self.base_path = Path(__file__).resolve().parent

        # --- 1. Активация Сервисов ---
        self.py_message_handler = PyMessageHandler()
        self.manager_json = Manager_Json()
        self.db = DataBaseConnect()

        # --- 2. Загрузка настроек базы данных ---
        self._load_json_database_settings()
        self._init_database_users()

        # --- 3. Приложение ---
        self.app = QGuiApplication(sys.argv)
        self.engine = QQmlApplicationEngine()
        self.engine.addImportPath(str(self.base_path))
        # self.engine.addImportPath(str(self.base_path / "qml/utils"))

        # --- Запуск ---
        self._load_main_qml()

    def _load_json_database_settings(self):
        self.manager_json.read_json_file(
            "files_settings/json_files/settings/project_settings/database_settings",
            "database_settings.json"
        )

    def _init_database_users(self):
        self.db.init_settings(
            folder=self.manager_json.items['db_users']['folder'],
            name=self.manager_json.items['db_users']['name'],
            echo=self.manager_json.items['db_users']['echo']

        )
        self.db.engine_db()
        self.db.createDB()

    def _load_main_qml(self):
        """Загружаем QML."""
        qml_file = self.base_path / "ui/qml/main_window/main.qml"
        self.engine.load(qml_file)
        if not self.engine.rootObjects():
            del self.engine
            sys.exit(-1)
        sys.exit(self.app.exec())

if __name__ == "__main__":
    Project()
