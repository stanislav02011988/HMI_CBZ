# This Python file uses the following encoding: utf-8
import json
import sys
from pathlib import Path
from PySide6.QtCore import QObject, Property, Signal, Slot, QFileSystemWatcher, QTimer
from PySide6.QtQml import QQmlPropertyMap

from python.py_utils.decorators.decorators_qml_registration_module.decorators_qml_registration_module import QmlRegistrationModule

QML_IMPORT_TYPE = "singleton"
Singleton_Type_Register = "singleton_instance_register"
QML_IMPORT_NAME = "python.py_menager_theme.interface_qml_menager_theme"
QML_MODULE_MAJOR_VERSION = 1
QML_MODULE_MINOR_VERSION = 0


@QmlRegistrationModule(QML_IMPORT_NAME, QML_MODULE_MAJOR_VERSION, QML_MODULE_MINOR_VERSION, QML_IMPORT_TYPE)
class MenagerTheme(QObject):
    themeChanged = Signal()

    def __init__(self, parent=None):
        super().__init__(parent)
        self._colors = QQmlPropertyMap(self)
        self._colors_keys = []  # список ключей для отслеживания
        self._current_theme_path = ""  # QRC-путь (для toggle)
        self._current_file_path = ""   # реальный путь на диске

        # Наблюдатель за файлом
        self._watcher = QFileSystemWatcher(self)
        self._watcher.fileChanged.connect(self._on_theme_file_changed)

        # Таймер для защиты от дребезга
        self._reload_timer = QTimer(self)
        self._reload_timer.setSingleShot(True)
        self._reload_timer.timeout.connect(self._do_reload_theme)

    def get_parametrs_qml_module(self):
        return QML_IMPORT_TYPE, Singleton_Type_Register, QML_IMPORT_NAME, QML_MODULE_MAJOR_VERSION, QML_MODULE_MINOR_VERSION

    def _normalize_path(self, path: str) -> str:
        """Преобразует QRC-путь в локальный путь."""
        if path.startswith("file:///"):
            path = path.replace("file:///", "", 1)
        if path.startswith("qrc:/json_file_theme/"):
            path = path.replace("qrc:/json_file_theme/", "", 1)
        return path



    def _update_watcher(self, new_file_path: str):
        """Обновляет наблюдение за файлом темы."""
        if self._current_file_path and self._current_file_path in self._watcher.files():
            self._watcher.removePath(self._current_file_path)

        if new_file_path and Path(new_file_path).exists():
            self._watcher.addPath(new_file_path)
            self._current_file_path = new_file_path
        else:
            self._current_file_path = ""

    def _on_theme_file_changed(self, path: str):
        """Обработчик изменения файла — запускает debounce-таймер."""
        if path == self._current_file_path:
            # Перерегистрируем файл на случай замены
            if Path(path).exists():
                self._update_watcher(path)
            else:
                self._update_watcher("")
            self._reload_timer.start(150)

    def _update_colors_from_dict(self, new_theme: dict):
        """Безопасно обновляет QQmlPropertyMap без временного состояния 'undefined'."""
        current_keys = set(self._colors_keys)
        new_keys = set(new_theme.keys())

        # Обновляем или добавляем ключи
        for key in new_keys:
            self._colors.insert(key, new_theme[key])

        # Удаляем устаревшие ключи
        for key in current_keys - new_keys:
            self._colors.clear(key)

        # Обновляем кэш ключей
        self._colors_keys = list(new_keys)

    def _do_reload_theme(self):
        """Перезагружает тему из файла при его изменении."""
        if not self._current_file_path or not Path(self._current_file_path).exists():
            return
        try:
            with open(self._current_file_path, "r", encoding="utf-8") as f:
                new_theme = json.load(f)
            self._update_colors_from_dict(new_theme)
            self.themeChanged.emit()
        except Exception as e:
            print(f"[ThemeManager] Ошибка перезагрузки темы: {e}")


    @Slot(str)
    def load_theme(self, qrc_theme_path: str):
        """Загружает тему по QRC-пути и начинает отслеживать её файл."""
        if not isinstance(qrc_theme_path, str) or not qrc_theme_path:
            print("[ThemeManager] Пустой или недопустимый путь")
            return

        try:
            local_path = self._normalize_path(qrc_theme_path)
            if not Path(local_path).exists():
                print(f"[ThemeManager] Файл не найден: {local_path}")
                return

            with open(local_path, "r", encoding="utf-8") as f:
                new_theme = json.load(f)

            self._current_theme_path = qrc_theme_path
            self._update_watcher(local_path)
            self._update_colors_from_dict(new_theme)
            self.themeChanged.emit()

        except json.JSONDecodeError as e:
            print(f"[ThemeManager] Ошибка JSON в файле '{local_path}': {e}")
        except Exception as e:
            print(f"[ThemeManager] Ошибка загрузки темы: {e}")

    @Slot()
    def toggle_theme(self):
        """Переключает между light.json и dark.json."""
        if not self._current_theme_path:
            print("[ThemeManager] Нет текущей темы для переключения")
            return

        path = self._current_theme_path
        if path.endswith("light.json"):
            new_path = path[:-10] + "dark.json"
        elif path.endswith("dark.json"):
            new_path = path[:-9] + "light.json"
        else:
            print("[ThemeManager] Неизвестный формат. Ожидалось .../light.json или .../dark.json")
            return

        self.load_theme(new_path)

    @Property(str, notify=themeChanged)
    def currentThemePath(self):
        return self._current_theme_path

    @Property(QQmlPropertyMap, notify=themeChanged)
    def colorsDict(self):
        return self._colors    
