import os
from pathlib import Path
from PySide6.QtCore import QObject, Slot, Signal, Property, QFileSystemWatcher, QTimer
from PySide6.QtQml import QQmlPropertyMap

from python.py_utils.decorators.decorators_qml_registration_module.decorators_qml_registration_module import QmlRegistrationModule


QML_IMPORT_TYPE = "singleton"
Singleton_Type_Register = "singleton_instance_register"
QML_IMPORT_NAME = "python.py_settings_project.interface_settings_project"
QML_MODULE_MAJOR_VERSION = 1
QML_MODULE_MINOR_VERSION = 0


@QmlRegistrationModule(
    QML_IMPORT_NAME,
    QML_MODULE_MAJOR_VERSION,
    QML_MODULE_MINOR_VERSION,
    QML_IMPORT_TYPE
)
class SettingsProject(QObject):

    signalLoadFile = Signal()
    signalErrorLoad = Signal(str, str)

    def __init__(self, file_path, file_name, db_engine, json_menager, parent=None):
        super().__init__(parent)

        self._file_path = file_path
        self._file_name = file_name
        self._full_file_path = str(Path(file_path) / file_name)
        self._db_engine = db_engine
        self._json_menager = json_menager

        self._items = QQmlPropertyMap(self)

        # === Наблюдатель за файлом ===
        self._watcher = QFileSystemWatcher(self)
        self._watcher.fileChanged.connect(self._on_file_changed)

        # Таймер для защиты от дребезга (debounce)
        self._reload_timer = QTimer(self)
        self._reload_timer.setSingleShot(True)
        self._reload_timer.timeout.connect(self._do_reload)

        # Добавляем файл в наблюдение
        self._add_watch()

        self.checking_file_path()

    def _add_watch(self):
        """Добавить файл в наблюдение, если его там нет."""
        if self._full_file_path not in self._watcher.files():
            self._watcher.addPath(self._full_file_path)

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

    def _on_file_changed(self, path: str):
        """Обработчик изменения файла — запускает debounce-таймер."""
        if path == self._full_file_path:
            # Файл мог быть удалён или заменён — перерегистрируем наблюдение
            self._add_watch()
            # Запускаем таймер (если уже запущен — сбрасывается)
            self._reload_timer.start(150)  # 150 мс — надёжнее 100

    @Slot()
    def _do_reload(self):
        """Фактическая перезагрузка — только после паузы в событиях."""
        if not Path(self._full_file_path).exists():
            return  # файл исчез — игнорируем

        self.load_file_settings()

    @Slot()
    def load_file_settings(self):
        try:
            data = self._json_menager.read_json_file(self._file_path, self._file_name)
            if data is None:
                data = {}

            current_keys = set(self._items.keys())
            new_keys = set(data.keys())

            for key in current_keys - new_keys:
                self._items.clear(key)

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

    # === ВСПОМОГАТЕЛЬНЫЕ МЕТОДЫ ===
    def _get_current_timestamp(self) -> str:
        """Получение текущей временной метки в ISO формате"""
        from datetime import datetime
        return datetime.now().isoformat()

    @Slot(str)
    def save_theme(self, name_theme) -> None:
        data = self._json_menager.read_json_file(self._file_path, self._file_name) or {}
        data.setdefault("block_theme_app", {})["theme_path"] = (
            f"qrc:/json_file_theme/files_settings/json_files/settings/project_settings/theme/{name_theme}.json"
        )
        self._json_menager.write_json_file(path_folder=self._file_path, file_name=self._file_name, items=data)
        self._add_watch()
        self.signalLoadFile.emit()

    @Slot("QVariant")
    def save_block_user_settings_project(self, dict_user) -> None:
        items = self._json_menager.read_json_file(self._file_path, self._file_name) or {}
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
        self._add_watch()
        self.signalLoadFile.emit()

    @Slot("QVariant")
    def save_block_settings_time_us_format(self, usFormat: bool) -> None:
        items = self._json_menager.read_json_file(self._file_path, self._file_name) or {}
        items.setdefault("block_time_settings", {})["use24HourFormat"] = usFormat
        self._json_menager.write_json_file(path_folder=self._file_path, file_name=self._file_name, items=items)
        self._add_watch()
        self.signalLoadFile.emit()

    @Slot("QVariant")
    def save_block_installation_settings(self, dict_installation) -> None:
        items = self._json_menager.read_json_file(self._file_path, self._file_name) or {}
        items["block_installation_settings"] = {
            "name_installation": dict_installation["name_installation"],
            "type_installation": dict_installation["type_installation"],
            "inf_number": dict_installation["inf_number"],
            "installation_number": dict_installation["installation_number"],
            "year_installation": dict_installation["year_installation"]
        }
        self._json_menager.write_json_file(path_folder=self._file_path, file_name=self._file_name, items=items)
        self._add_watch()
        self.signalLoadFile.emit()
    #
    # Сохранения элементов сцены в файл
    #
    @Slot("QVariant")
    def save_block_graphics(self, graphics_dict) -> None:
        try:
            items = self._json_menager.read_json_file(
                self._file_path,
                self._file_name
            ) or {}

            items["block_graphics"] = graphics_dict

            self._json_menager.write_json_file(
                path_folder=self._file_path,
                file_name=self._file_name,
                items=items
            )

            self._add_watch()
            self.signalLoadFile.emit()

            print("[OK] block_graphics сохранён")

        except Exception as e:
            self.signalErrorLoad.emit(
                "[SettingsProject] Ошибка сохранения block_graphics",
                str(e)
            )
    #
    # Получение элементов сцены из файла
    #
    @Slot(result="QVariant")
    def get_block_graphics(self):
        items = self._json_menager.read_json_file(
            self._file_path,
            self._file_name
        ) or {}

        return items.get("block_graphics", {})
