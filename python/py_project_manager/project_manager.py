# python\py_project_manager\project_manager.py

import shutil
import tempfile
import uuid
import json

from pathlib import Path
from datetime import datetime
from typing import Any, Optional, Dict

from PySide6.QtCore import (
    QObject,
    QUrl,
    Slot,
    Signal,
    Property,
    QFileSystemWatcher,
)

from PySide6.QtQml import QQmlPropertyMap, QJSValue

from python.py_utils.decorators.decorators_qml_registration_module.decorators_qml_registration_module import QmlRegistrationModule


QML_IMPORT_TYPE = "singleton"
Singleton_Type_Register = "singleton_instance_register"
QML_IMPORT_NAME = "python.py_project_manager.interface_in_qml"
QML_MODULE_MAJOR_VERSION = 1
QML_MODULE_MINOR_VERSION = 0


@QmlRegistrationModule(
    QML_IMPORT_NAME,
    QML_MODULE_MAJOR_VERSION,
    QML_MODULE_MINOR_VERSION,
    QML_IMPORT_TYPE
)
class ProjectManager(QObject):

    signalLoadFile = Signal()
    signalErrorLoad = Signal(str, str)

    def __init__(self, json_menager, parent=None):
        super().__init__(parent)

        self._json_menager = json_menager

        self._items = QQmlPropertyMap(self)

        # текущий файл проекта
        self._project_file: Optional[Path] = None

        # watcher для hot reload
        self._watcher = QFileSystemWatcher(self)
        self._watcher.fileChanged.connect(self._on_file_changed)

    def get_parametrs_qml_module(self):
        return QML_IMPORT_TYPE, Singleton_Type_Register, QML_IMPORT_NAME, QML_MODULE_MAJOR_VERSION, QML_MODULE_MINOR_VERSION

    # =====================================================
    # HOT RELOAD
    # =====================================================

    def _add_watch(self):
        if not self._project_file:
            return

        path = str(self._project_file)

        if path not in self._watcher.files():
            self._watcher.addPath(path)

    def _on_file_changed(self, path):
        if not Path(path).exists():
            return

        print("[HOT RELOAD] файл изменился:", path)

        self._reload_project()

        if path not in self._watcher.files():
            self._watcher.addPath(path)

    def _reload_project(self):
        if not self._project_file:
            return

        try:

            with open(self._project_file, "r", encoding="utf-8") as f:
                data = json.load(f)

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
            print("[ERR] reload_project:", e)


    # =====================================================
    # CREATE PROJECT
    # =====================================================
    @Slot("QVariant", result="QVariant")
    def create_project(self, dict_data):
        try:

            if isinstance(dict_data, QJSValue):
                dict_data = dict_data.toVariant()

            installation_name = dict_data["installationName"]

            project_path = Path(QUrl(dict_data["projectPath"]).toLocalFile())

            project_file = project_path / f"{installation_name}.json"

            id_uuic = str(uuid.uuid4())

            if not project_file.exists():

                default_project = {

                    "id_uuic": id_uuic,
                    "installationName": installation_name,
                    "typeInstallation": dict_data["typeInstallation"],
                    "numberINF": dict_data["numberINF"],
                    "numberInstallation": dict_data["numberInstallation"],
                    "yearInstallation": dict_data["yearInstallation"],

                    "project_file": str(project_file),

                    "previewInstallation": dict_data["previewInstallation"],
                    "user": dict_data["user"],
                    "position_users": dict_data["position_users"],

                    "created": datetime.now().isoformat(),
                    "last_saved": datetime.now().isoformat(),

                    "scene": {},
                    "nodes": {},
                    "connections": {}

                }

                with open(project_file, "w", encoding="utf-8") as f:
                    json.dump(default_project, f, indent=4, ensure_ascii=False)

            print("[OK] проект создан")

            return default_project

        except Exception as e:

            print("[ERR] create_project:", e)

            return {}

    # =====================================================
    # LOAD PROJECT
    # =====================================================
    @Slot(str)
    def loadProject(self, project_path):
        try:
            if project_path.startswith("file:///"):
                path = Path(QUrl(project_path).toLocalFile())
            else:
                path = Path(project_path)

            if not path.exists():
                raise FileNotFoundError(path)

            self._project_file = path

            with open(path, "r", encoding="utf-8") as f:
                data = json.load(f)

            if data is None:
                data = {}

            # правильная очистка
            for key in list(self._items.keys()):
                self._items.clear(key)

            for key, value in data.items():
                self._items.insert(key, value)

            self._add_watch()

            self.signalLoadFile.emit()

            print("[OK] проект загружен")

        except Exception as e:
            print("[ERR] loadProject:", e)


    # =====================================================
    # PROPERTY QML
    # =====================================================
    @Property(QQmlPropertyMap, notify=signalLoadFile)
    def itemsProjectData(self):
        return self._items

    # =========================================================================
    # Получение элементов сцены из файла
    # =========================================================================
    @Slot(result="QVariant")
    def load_elements_scene(self):
        items = self._json_menager.read_json_file(self._project_file, "") or {}
        return items.get("scene", {})
    # =====================================================
    # SAVE SCENE
    # =====================================================
    @Slot("QVariant")
    def save_scene_elements(self, graphics_dict):
        try:

            if not self._project_file:
                return

            items = self._json_menager.read_json_file(self._project_file, "") or {}

            items["scene"] = graphics_dict

            self._json_menager.write_json_file(self._project_file, "", items)

            self.signalLoadFile.emit()

            print("[OK] Scene сохранён")

        except Exception as e:

            self.signalErrorLoad.emit("save_scene_elements", str(e))


    # =========================================================================
    # ЧАСТИЧНОЕ ОБНОВЛЕНИЕ ЭЛЕМЕНТА СЦЕНЫ С ОТКАТОМ ПРИ ОШИБКЕ
    # =========================================================================
    @Slot(str, "QVariantMap", result=bool)
    def update_scene_element(self, id_widget: str, update_data: Dict[str, Any]) -> bool:
        """
        Частично обновляет данные элемента в блоке block_graphics БЕЗ перезаписи всей сцены.

        Атомарная операция с откатом:
        1. Создаёт резервную копию
        2. Находит элемент по id_widget в иерархии {group: {subtype: {id: data}}}
        3. Обновляет только указанные поля (geometry, sizeProperties)
        4. Сохраняет файл
        5. При ошибке — восстанавливает из резервной копии

        Возвращает: True при успехе, False при ошибке
        """
        if not id_widget or not isinstance(id_widget, str):
            print(f"[ERR] update_element_in_config: неверный id_widget '{id_widget}'")
            return False

        # === 1. Создаём временную резервную копию с уникальным именем ===
        backup_path = self._create_backup()
        if not backup_path:
            return False

        try:
            # === 2. Загружаем текущую конфигурацию ===
            items = self._json_menager.read_json_file(self._project_file,"") or {}

            if "scene" not in items:
                print("[ERR] update_element_in_config: scene отсутствует в конфигурации")
                self._restore_from_backup(backup_path)
                return False

            # === 3. Находим элемент по id_widget в иерархии ===
            found = False
            target_element = None
            target_path = ("", "", "")  # (group, subtype, id_widget)

            for group, subtypes in items["scene"].items():
                # Пропускаем служебные блоки (например, "Camera_Settings")
                if not isinstance(subtypes, dict) or group.startswith("Camera_"):
                    continue

                for subtype, elements in subtypes.items():
                    if not isinstance(elements, dict):
                        continue

                    if id_widget in elements:
                        target_element = elements[id_widget]
                        target_path = (group, subtype, id_widget)
                        found = True
                        break
                if found:
                    break

            if not found:
                print(f"[WARN] update_element_in_config: элемент '{id_widget}' не найден в конфигурации")
                self._restore_from_backup(backup_path)
                return False

            # === 4. Валидация и обновление данных ===
            # Обновляем геометрию
            if "geometry" in update_data and isinstance(update_data["geometry"], dict):
                if "geometry" not in target_element:
                    target_element["geometry"] = {}

                for prop in ("relX", "relY", "relW", "relH"):
                    if prop in update_data["geometry"]:
                        value = update_data["geometry"][prop]
                        if isinstance(value, (int, float)):
                            target_element["geometry"][prop] = float(value)
                        else:
                            print(f"[WARN] update_element_in_config: игнорируем некорректное значение geometry.{prop}={value}")

            # Обновляем свойства размеров
            if "sizeProperties" in update_data and isinstance(update_data["sizeProperties"], dict):
                if "sizeProperties" not in target_element:
                    target_element["sizeProperties"] = {}

                for prop_name, value in update_data["sizeProperties"].items():
                    if isinstance(value, (int, float)):
                        target_element["sizeProperties"][prop_name] = float(value)
                    else:
                        print(f"[WARN] update_element_in_config: игнорируем некорректное значение sizeProperties.{prop_name}={value}")

            # === 5. Сохраняем ОБНОВЛЁННУЮ конфигурацию ===
            self._json_menager.write_json_file( path_folder=self._project_file, file_name="", items=items)

            # === 6. Перерегистрируем наблюдение (файл мог быть заменён) ===
            self._add_watch()
            self.signalLoadFile.emit()

            # === 7. Удаляем резервную копию при успехе ===
            self._create_backup()

            timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
            print(f"[SAVE] Элемент '{id_widget}' обновлён ({timestamp})")
            return True

        except Exception as e:
            # === ОТКАТ ПРИ ЛЮБОЙ ОШИБКЕ ===
            print(f"[ERR] update_element: ошибка при обновлении '{id_widget}': {e}")
            import traceback
            traceback.print_exc()

            self._restore_from_backup(backup_path)
            return False

    # =====================================================
    # BACKUP
    # =====================================================
    def _create_backup(self) -> Optional[str]:
        try:
            if not self._project_file:
                return None

            backup_dir = Path(tempfile.gettempdir()) / "hmi_backups"

            backup_dir.mkdir(exist_ok=True)

            timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")

            backup_file = backup_dir / f"{self._project_file.name}.bak_{timestamp}"

            shutil.copy2(self._project_file, backup_file)

            return str(backup_file)

        except Exception as e:

            print("[ERR] create_backup:", e)

            return None

    def _restore_from_backup(self, backup_path):
        try:

            if not self._project_file:
                return False

            shutil.copy2(backup_path, self._project_file)

            self._reload_project()

            return True

        except Exception as e:

            print("[ERR] restore_backup:", e)

            return False

    # =====================================================
    # КАМЕРА - ЗАГРУЗКА
    # =====================================================
    @Slot(result="QVariant")
    def load_camera_params(self, default: Any = None) -> Optional[dict]:
        try:
            items = self._json_menager.read_json_file( self._project_file, "" ) or {}
            # Проверяем наличие внутри block_graphics
            if "scene" not in items:
                return default

            if "Camera_Settings" not in items["scene"]:
                return default

            camera_data = items["scene"]["Camera_Settings"]

            return {
                "zoom": float(camera_data.get("zoom", 1.0)),
                "offsetX": float(camera_data.get("offsetX", 0)),
                "offsetY": float(camera_data.get("offsetY", 0))
            }

        except Exception as e:
            print(f"[ERR] load_camera_params: {e}")
            return default


    # =====================================================
    # КАМЕРА - СОХРАНЕНИЕ
    # =====================================================
    @Slot("QVariant")
    def save_camera_params(self, camera_data) -> bool:
        try:
            # Универсальное преобразование
            if hasattr(camera_data, "toVariant"):
                camera_data = camera_data.toVariant()

            if not isinstance(camera_data, dict):
                raise TypeError(
                    f"camera_data must be dict, got {type(camera_data)}"
                )

            items = self._json_menager.read_json_file(
                self._project_file,
                ""
            ) or {}
            if "scene" not in items:
                items["scene"] = {}

            items["scene"]["Camera_Settings"] = {
                "zoom": float(camera_data.get("zoom", 1.0)),
                "offsetX": float(camera_data.get("offsetX", 0)),
                "offsetY": float(camera_data.get("offsetY", 0))
            }
            self._json_menager.write_json_file(
                path_folder=self._project_file,
                file_name="",
                items=items
            )
            return True
        except Exception as e:
            print(f"[ERR] save_camera_params: {e}")
            return False
