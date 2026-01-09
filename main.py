# This Python file uses the following encoding: utf-8
import sys
import os
# import rc_qml
from pathlib import Path

from PySide6.QtGui import QGuiApplication
from PySide6.QtQml import QQmlApplicationEngine

from python.py_utils.massage_handler.message_handler import PyMessageHandler
from python.py_utils.utils_json.json_manager import Manager_Json
from python.py_data_base.db_manager import DB_Manager

class Project:
    def __init__(self):
        super().__init__()
        # Разрешение локального чтения для QML
        os.environ["QML_XHR_ALLOW_FILE_READ"] = "1"

        self.base_path = Path(__file__).resolve().parent

        # --- 1. Активация Сервисов ---
        self.py_message_handler = PyMessageHandler()        

        # --- 2. Загрузка настроек базы данных ---
        self.manager_json = Manager_Json()
        self.db_manager = DB_Manager(self.manager_json)

        # --- 3. Приложение ---
        self.app = QGuiApplication(sys.argv)
        self.engine = QQmlApplicationEngine()
        self.engine.addImportPath(str(self.base_path))
        # self.engine.addImportPath(str(self.base_path / "qml/utils"))

        # --- Запуск ---
        self._load_main_qml()



    def _load_main_qml(self):
        """Загружаем QML."""
        qml_file = self.base_path / "ui/qml/splesh_screen/splesh_screen.qml"
        self.engine.load(qml_file)
        if not self.engine.rootObjects():
            del self.engine
            sys.exit(-1)
        sys.exit(self.app.exec())

if __name__ == "__main__":
    Project()
