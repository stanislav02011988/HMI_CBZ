import os
from pathlib import Path
from PySide6.QtCore import QObject, Slot, Signal, Property
from PySide6.QtQml import QQmlPropertyMap

from python.py_utils.decorators.decorators_qml_registration_module.decorators_qml_registration_module import QmlRegistrationModule


QML_IMPORT_TYPE = "singleton"
Singleton_Type_Register = "singleton_instance_register"
QML_IMPORT_NAME = "python.py_settings_project.interface_settings_project"
QML_MODULE_MAJOR_VERSION = 1
QML_MODULE_MINOR_VERSION = 0

@QmlRegistrationModule(QML_IMPORT_NAME, QML_MODULE_MAJOR_VERSION, QML_MODULE_MINOR_VERSION, QML_IMPORT_TYPE)
class SettingsProject(QObject):

    signalLoadFile = Signal()
    signalErrorLoad = Signal(str, str)

    def __init__(self, file_path, file_name, db_engine, json_menager, parent=None):
        super().__init__(parent)

        self._file_path = file_path
        self._file_name = file_name

        self._db_engine = db_engine
        self._json_menager = json_menager

        self._items = QQmlPropertyMap(self)
        self._items_keys = []

        self.checking_file_path()

    def get_parametrs_qml_module(self):
        return QML_IMPORT_TYPE, Singleton_Type_Register, QML_IMPORT_NAME, QML_MODULE_MAJOR_VERSION, QML_MODULE_MINOR_VERSION

    def checking_file_path(self):
        try:
            file_path = Path(self._file_path) / self._file_name
            if file_path.is_file():
                self.load_file_settings()
                return True
            else:
                self.signalErrorLoad.emit(
                    "[SettingsProject] Ф->checking_file_path: файл отсутствует",
                    str(file_path)
                )
                return False
        except Exception as e:
            self.signalErrorLoad.emit(
                "[SettingsProject] Ошибка при проверке файла",
                str(e)
            )
            return False

    @Slot("QVariant")
    def write_block_user_settings_project(self, dict_user):
        items = self._json_menager.read_json_file(self._file_path, self._file_name)
        items["block_user"] = {
            "id_user": dict_user["id_user"],
            "last_name": dict_user["last_name"],
            "first_name": dict_user["first_name"],
            "second_name": dict_user["second_name"],
            "tab_number": dict_user["tab_number"],
            "position_users": dict_user["position_users"],
            "access_group": dict_user["access_group"],
            "time_in": dict_user["time_in"],
            "time_out": "---"
        }
        self._json_menager.write_json_file(path_folder=self._file_path, file_name=self._file_name, items=items)

    @Slot()
    def load_file_settings(self):
        try:
            data = self._json_menager.read_json_file(self._file_path, self._file_name)
            if data is None:
                data = {}

            # Очищаем старые ключи
            for key in list(self._items.keys()):
                self._items.clear(key)

            # Заполняем QQmlPropertyMap новыми данными
            for key, value in data.items():
                self._items.insert(key, value)

            self.signalLoadFile.emit()

        except Exception as e:
            self.signalErrorLoad.emit(
                "[SettingsProject] Ошибка загрузки данных",
                str(e)
            )

    @Property(QQmlPropertyMap, notify=signalLoadFile)
    def itemsFileSettingsDict(self):
        return self._items

    @Slot(str)
    def save_theme(self, name_theme):
        data = self._json_menager.read_json_file(self._file_path, self._file_name)
        data["block_graphic_settings"]["theme_path"] = f"qrc:/json_file_theme/files_settings/json_files/settings/project_settings/theme/{name_theme}.json"
        self._json_menager.write_json_file(path_folder=self._file_path, file_name=self._file_name, items=data)
