# This Python file uses the following encoding: utf-8
import json
import sys
from pathlib import Path
from PySide6.QtCore import QObject, Property, Signal, Slot
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
        self._colors_keys = []
        self._current_theme_path = ""  # Храним исходный qrc-путь

        # Определяем корень приложения
        if getattr(sys, 'frozen', False):
            self._app_root = Path(sys.executable).parent
        else:
            # Подстройте под вашу структуру!
            self._app_root = Path(__file__).parent.parent.parent.parent.resolve()

    def get_parametrs_qml_module(self):
        return QML_IMPORT_TYPE, Singleton_Type_Register, QML_IMPORT_NAME, QML_MODULE_MAJOR_VERSION, QML_MODULE_MINOR_VERSION

    def _normalize_path(self, path: str) -> str:
        if path.startswith("file:///"):
            path = path.replace("file:///", "", 1)
        if path.startswith("qrc:/json_file_theme/"):
            path = path.replace("qrc:/json_file_theme/", "", 1)
        return path

    @Slot(str)
    def load_theme(self, qrc_theme_path: str):
        """Загружает тему по QRC-пути, но читает файл из файловой системы"""
        if not isinstance(qrc_theme_path, str) or not qrc_theme_path:
            print("[ThemeManager]  Пустой или недопустимый путь")
            return

        try:
            local_path = self._normalize_path(qrc_theme_path)

            with open(local_path, "r", encoding="utf-8") as f:
                new_theme = json.load(f)

            for k in list(self._colors_keys):
                try:
                    self._colors_keys.remove(k)
                except Exception:
                    try:
                        self._colors.insert(k, "")
                    except Exception:
                        pass

            self._colors_keys.clear()

            for k, v in new_theme.items():
                try:
                    self._colors.insert(k, v)
                except Exception as e:
                    print(f"[ThemeManager]  Не удалось вставить ключ {k}: {e}")
                    continue
                self._colors_keys.append(k)

            self._current_theme_path = qrc_theme_path
            self.themeChanged.emit()
            # print(f"[ThemeManager]  Тема загружена: {local_path}")

        except json.JSONDecodeError as e:
            print(f"[ThemeManager]  Ошибка JSON в файле '{local_path}': {e}")
        except Exception as e:
            print(f"[ThemeManager]  Ошибка загрузки темы: {e}")

    @Slot()
    def toggle_theme(self):
        """Переключает между light.json и dark.json"""
        if not self._current_theme_path:
            print("[ThemeManager] ️ Нет текущей темы для переключения")
            return

        path = self._current_theme_path
        if path.endswith("light.json"):
            new_path = path[:-10] + "dark.json"
        elif path.endswith("dark.json"):
            new_path = path[:-9] + "light.json"
        else:
            print("[ThemeManager] ️ Неизвестный формат. Ожидалось .../light.json или .../dark.json")
            return

        self.load_theme(new_path)

    @Property(str, notify=themeChanged)
    def currentThemePath(self):
        return self._current_theme_path

    @Property(QQmlPropertyMap, notify=themeChanged)
    def colorsDict(self):
        return self._colors
