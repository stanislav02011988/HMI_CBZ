import os
from PySide6.QtCore import QObject, Slot

from python.py_utils.decorators.decorators_qml_registration_module.decorators_qml_registration_module import QmlRegistrationModule


QML_IMPORT_TYPE = "singleton"
Singleton_Type_Register = "singleton_instance_register"
QML_IMPORT_NAME = "python.py_settings_project.interface_settings_project"
QML_MODULE_MAJOR_VERSION = 1
QML_MODULE_MINOR_VERSION = 0

@QmlRegistrationModule(QML_IMPORT_NAME, QML_MODULE_MAJOR_VERSION, QML_MODULE_MINOR_VERSION, QML_IMPORT_TYPE)
class SettingsProject(QObject):
    def __init__(self, db_engine, json_menager, parent=None):
        super().__init__(parent)

        self._file_path = "files_settings/json_files/settings/project_settings"
        self._file_name = "project_settings.json"

        self._db_engine = db_engine
        self._json_menager = json_menager

        if not os.path.exists(os.path.join(self._file_path, self._file_name)):
            items = {
                "block_user": {},
                "block_graphic_settings": {}
            }
            self._json_menager.write_json_file(self._file_path, self._file_name, items)
            print(f"Файл создан: {os.path.join(self._file_path, self._file_name)}")
        else:
            print(f"Файл уже существует: {os.path.join(self._file_path, self._file_name)}")

    def get_parametrs_qml_module(self):
        return QML_IMPORT_TYPE, Singleton_Type_Register, QML_IMPORT_NAME, QML_MODULE_MAJOR_VERSION, QML_MODULE_MINOR_VERSION

    @Slot("QVariant")
    def write_block_user_settings_project(self, dict_user):
        self._json_menager.read_json_file(self._file_path, self._file_name)
        self._json_menager.items["block_user"] = {
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
        self._json_menager.write_json_file(path_folder=self._file_path, file_name=self._file_name, items=self._json_menager.items)
        self._json_menager.clear_items()

    def read_block_graphic_settings(self):
        pass
