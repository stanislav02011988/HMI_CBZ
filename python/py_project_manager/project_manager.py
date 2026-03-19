# python\py_project_manager\project_manager.py
import os
import shutil
import tempfile
import uuid
import json

from pathlib import Path
from datetime import datetime
from typing import Any, Optional, Dict

from PySide6.QtCore import QObject, QUrl, Slot, Signal, Property, QFileSystemWatcher
from PySide6.QtQml import QJSValue

# from python.py_project_manager.q_abstractlist_model.model import Model
# from python.py_project_manager.q_abstractlist_model.store import Store
from python.py_project_manager.tree_view_project.tree_view_model import TreeViewModel
from python.py_project_manager.tree_view_project.tree_view_store import TreeViewStore
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

        self._project_data: Dict[str, Any] = {}

        self._tree_view_store = TreeViewStore(self)
        self._tree_view_model = TreeViewModel(self._tree_view_store, self)

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
            data = self._json_menager.read_json_file(self._project_file, "")

            if data is None:
                data = {}

            self._project_data = data

            self.signalLoadFile.emit()

        except Exception as e:
            print("[ERR] reload_project:", e)



    # =====================================================
    # CREATE PROJECT
    # =====================================================
    @Slot("QVariant", result="QVariant")
    def create_project(self, dict_data):
        try:
            # =========================================================
            # ПРИВОДИМ ДАННЫЕ К PYTHON DICT
            # =========================================================
            if isinstance(dict_data, QJSValue):
                data = dict_data.toVariant()
            else:
                data = dict_data

            if not isinstance(data, dict):
                print("[project_manager.py] invalid project data:", data)
                return {}

            # =========================================================
            # ДАННЫЕ ПРОЕКТА
            # =========================================================
            installation_name = data.get("installationName")
            typeInstallation = data.get("typeInstallation")
            numberINF = data.get("numberINF")
            numberInstallation = data.get("numberInstallation")

            nameProject = (
            f"{installation_name} {typeInstallation}"
            f" ном.уст. {numberInstallation}"
            f" инв.ном. {numberINF}"
            )

            project_path = Path(QUrl(data["projectPath"]).toLocalFile())
            project_file = (project_path / nameProject).with_suffix(".json")

            id_uuic = str(uuid.uuid4())

            now = datetime.now().strftime("%d.%m.%Y  %H:%M")

            # =========================================================
            # СТРУКТУРА ПРОЕКТА
            # =========================================================

            default_project = {
                # =====================================================
                # META ДАННЫЕ ПРОЕКТА
                # =====================================================
                "meta": {
                    "id_uuic": id_uuic,
                    "installationName": installation_name,
                    "typeInstallation": typeInstallation,
                    "numberINF": numberINF,
                    "numberInstallation": numberInstallation,
                    "yearInstallation": data.get("yearInstallation"),
                    "nameProject": nameProject,
                    "project_file": str(project_file),

                    "previewInstallation": data.get("previewInstallation"),

                    "user": data.get("user"),
                    "position_users": data.get("position_users"),

                    "created": now,
                    "last_saved": now
                },

                # =====================================================
                # HMI СЦЕНА (ГЛАВНАЯ СХЕМА УСТАНОВКИ)
                # =====================================================
                "scene": {},

                # =====================================================
                # LOGIC СИСТЕМА
                # =====================================================
                "logic": {

                    "programs": {

                        # ---------------------------------------------
                        # ГЛАВНАЯ ПРОГРАММА
                        # ---------------------------------------------
                        "main": {

                            "name": "Main Program",

                            # цикл выполнения программы
                            "cycle_ms": 100,

                            # сцена редактора логики (FBD)
                            "scene": {},

                            # логические блоки
                            "nodes": {},

                            # связи между блоками
                            "connections": {}

                        }

                    }

                },

                # =====================================================
                # ПЕРЕМЕННЫЕ ПРОЕКТА
                # =====================================================
                "variables": {

                    "inputs": {},
                    "outputs": {},
                    "globals": {}

                },

                # =====================================================
                # РЕСУРСЫ
                # =====================================================
                "resources": {},

                # =====================================================
                # ДОПОЛНИТЕЛЬНЫЕ ФАЙЛЫ
                # =====================================================
                "files": {}

            }

            # =========================================================
            # СОЗДАНИЕ ФАЙЛА ПРОЕКТА
            # =========================================================
            if not project_file.exists():

                project_path.mkdir(parents=True, exist_ok=True)

                with open(project_file, "w", encoding="utf-8") as f:
                    json.dump(
                        default_project,
                        f,
                        indent=4,
                        ensure_ascii=False
                    )

            print("[project_manager.py] [OK] проект создан")

            return default_project

        except Exception as e:
            print("[project_manager.py][ERR] create_project:", e)
            return {}



    @Slot(str, result=bool)
    def add_new_file_programs_project(self, name_program):
        try:

            if not self._project_file:
                return False

            default_dict = {
                "name": name_program,
                "cycle_ms": 100,
                "scene": {},
                "scene_camera_settings": {},
                "nodes": {},
                "connections": {}
            }

            self._project_data["logic"]["programs"][name_program] = default_dict

            # сохранить JSON
            self._json_menager.write_json_file(
                self._project_file,
                "",
                self._project_data
            )

            # ОБНОВИТЬ STORE
            self._store.load_project(self._project_data)

            self.signalLoadFile.emit()

            print("[OK] Program file added:", name_program)

            return True

        except Exception as e:
            self.signalErrorLoad.emit("add_program", str(e))
            return False

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

            data = self._json_menager.read_json_file(self._project_file, "")

            if data is None:
                data = {}

            self._project_data = data
            self.load_dict_project_in_tree_view_model(self._project_data)

            self._add_watch()
            self.signalLoadFile.emit()

            print("[OK] проект загружен")

        except Exception as e:
            print("[ERR] loadProject:", e)


    # =====================================================
    # PROPERTY QML
    # =====================================================
    @Property("QVariantMap", notify=signalLoadFile)
    def itemsProjectData(self):
        return self._project_data

    # -------------------------------------
    def load_dict_project_in_tree_view_model(self, project_dict):
        self._tree_view_store.load_project(project_dict)

    # -------------------------------------
    @Property(QObject, constant=True)
    def tree_view_model(self):
        return self._tree_view_model

    # =========================================================================
    # Получение элементов сцены из файла
    # =========================================================================
    @Slot(result="QVariant")
    def load_elements_scene(self):
        return self._project_data.get("scene", {})
    # =====================================================
    # SAVE SCENE
    # =====================================================
    @Slot("QVariant")
    def save_scene_elements(self, graphics_dict):
        try:
            if not self._project_file:
                return

            self._project_data["scene"] = graphics_dict
            self._save_project_manager()
            print("[OK] Scene сохранён")
        except Exception as e:
            self.signalErrorLoad.emit("save_scene_elements", str(e))

    # =====================================================
    # SAVE SCENE LOGIC MAP
    # =====================================================
    @Slot(str, "QVariant")
    def save_elements_scene_logic_map(self, name_programs, graphics_dict):
        try:
            if not self._project_file:
                return
            self._project_data["logic"]["programs"][name_programs]["scene"] = graphics_dict
            self._save_project_manager()

            print("[OK] SceneLogicMap сохранён")
        except Exception as e:
            self.signalErrorLoad.emit("save_scene_elements", str(e))

    # =====================================================
    # SCENE LOGIC MAP SAVE CAMERA PAREMS
    # =====================================================
    @Slot(str, "QVariant")
    def save_camera_params_scene_logic_map(self, name_program, camera_data) -> bool:
        try:
            # =====================================================
            # НОРМАЛИЗАЦИЯ ДАННЫХ
            # =====================================================
            if hasattr(camera_data, "toVariant"):
                data = camera_data.toVariant()
            else:
                data = camera_data

            if not isinstance(data, dict):
                raise TypeError(f"camera_data must be dict, got {type(data)}")

            # =====================================================
            # ВАЛИДАЦИЯ ПУТИ
            # =====================================================
            programs = self._project_data.get("logic", {}).get("programs", {})

            if name_program not in programs:
                raise KeyError(f"Program '{name_program}' not found")

            program = programs[name_program]

            # =====================================================
            # СОХРАНЕНИЕ
            # =====================================================
            if "scene_camera_settings" not in program:
                program["scene_camera_settings"] = {}

            program["scene_camera_settings"] = {
                "zoom": float(data.get("zoom", 1.0)),
                "offsetX": float(data.get("offsetX", 0)),
                "offsetY": float(data.get("offsetY", 0))
            }

            print("[OK - 433] save_camera_params_scene_logic_map:", name_program, program["scene_camera_settings"])

            # =====================================================
            # ЗАПИСЬ В ФАЙЛ
            # =====================================================
            self._save_project_manager()

            return True

        except Exception as e:
            print(f"[ERR - 447] save_camera_params_scene_logic_map: {repr(e)}")
            return False

    # =========================================================================
    # ЧАСТИЧНОЕ ОБНОВЛЕНИЕ ЭЛЕМЕНТА СЦЕНЫ С ОТКАТОМ ПРИ ОШИБКЕ
    # =========================================================================
    @Slot(str, "QVariantMap", result=bool)
    def update_scene_element(self, id_widget: str, update_data: Dict[str, Any]) -> bool:
        if not id_widget or not isinstance(id_widget, str):
            print(f"[ERR] update_element_in_config: неверный id_widget '{id_widget}'")
            return False

        backup_path = self._create_backup()
        if not backup_path:
            return False

        try:
            if "scene" not in self._project_data:
                print("[ERR] update_element_in_config: scene отсутствует в конфигурации")
                self._restore_from_backup(backup_path)
                return False

            # Поиск элемента
            found = False
            target_element = None

            for group, subtypes in self._project_data["scene"].items():
                if not isinstance(subtypes, dict) or group.startswith("Camera_"):
                    continue
                for subtype, elements in subtypes.items():
                    if not isinstance(elements, dict):
                        continue
                    if id_widget in elements:
                        target_element = elements[id_widget]
                        found = True
                        break
                if found:
                    break

            if not found:
                print(f"[WARN] update_element_in_config: элемент '{id_widget}' не найден")
                self._restore_from_backup(backup_path)
                return False

            # === ОБНОВЛЕНИЕ ГЕОМЕТРИИ ===
            if "geometry" in update_data:
                geom_data = update_data["geometry"]
                if isinstance(geom_data, dict):
                    if "geometry" not in target_element or not isinstance(target_element["geometry"], dict):
                        target_element["geometry"] = {}

                    for prop in ("relX", "relY", "relW", "relH"):
                        if prop in geom_data:
                            val = geom_data[prop]
                            if isinstance(val, (int, float)):
                                target_element["geometry"][prop] = float(val)
                            else:
                                print(f"[WARN] Игнор geometry.{prop}: неверный тип {type(val)}")
                else:
                    print(f"[ERR] geometry должен быть dict, получено: {type(geom_data)}")

            # === ОБНОВЛЕНИЕ SIZE PROPERTIES (ИСПРАВЛЕНО) ===
            if "sizeProperties" in update_data:
                size_data = update_data["sizeProperties"]

                # Критическая проверка: входящие данные должны быть словарем
                if isinstance(size_data, dict):
                    # Гарантируем, что целевое поле - словарь
                    if "sizeProperties" not in target_element or not isinstance(target_element["sizeProperties"], dict):
                        target_element["sizeProperties"] = {}

                    target_dict = target_element["sizeProperties"]

                    for key, value in size_data.items():
                        if isinstance(value, (int, float)):
                            target_dict[key] = float(value)
                        else:
                            print(f"[WARN] Игнор sizeProperties.{key}: неверный тип {type(value)}")
                else:
                    # ВОТ ЗДЕСЬ ЛОВИМ ВАШУ ОШИБКУ
                    print(f"[CRITICAL ERR] sizeProperties должен быть dict! Получено: {type(size_data)} = {size_data}")
                    print("Откат изменений для защиты структуры JSON.")
                    self._restore_from_backup(backup_path)
                    return False

            # Сохранение
            self._json_menager.write_json_file(
                path_folder=self._project_file,
                file_name="",
                items=self._project_data
            )

            self._add_watch()
            self.signalLoadFile.emit()
            self._cleanup_backups(backup_path)
            print(f"[SAVE] Элемент '{id_widget}' обновлён успешно.")
            print(f"[SAVE] Элемент резервная копия файла '{backup_path}'")
            return True

        except Exception as e:
            print(f"[ERR] update_element: критическая ошибка {e}")
            import traceback
            traceback.print_exc()
            self._restore_from_backup(backup_path)
            return False

    @Slot(str, "QVariantMap", result=bool)
    def update_scene_one_element_logic_map(self, prop_name: str, id_widget: str, update_data: Dict[str, Any]) -> bool:
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

            if "scene" not in self._project_data["logic"]["programs"][prop_name]:
                print("[ERR] update_element_in_config: scene отсутствует в конфигурации")
                self._restore_from_backup(backup_path)
                return False

            # === 3. Находим элемент по id_widget в иерархии ===
            found = False
            target_element = None
            target_path = ("", "", "")  # (group, subtype, id_widget)

            for group, subtypes in self._project_data["logic"]["programs"][prop_name]["scene"].items():
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
            self._json_menager.write_json_file( path_folder=self._project_file, file_name="", items=self._project_data)

            # === 6. Перерегистрируем наблюдение (файл мог быть заменён) ===
            self._add_watch()
            self.signalLoadFile.emit()

            # === 7. Удаляем резервную копию при успехе ===
            self._cleanup_backups(backup_path)

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

    def _cleanup_backups(self, backup_path):
        try:
            if backup_path and os.path.exists(backup_path):
                os.remove(backup_path)
                # print(f"[INFO] Временный бэкап удален: {backup_path}")
        except Exception as clean_err:
            print(f"[WARN] Не удалось удалить временный бэкап: {clean_err}")
            # Это не критично, просто файл останется в temp до перезагрузки ОС или очистки пользователем

        return True

    def _cleanup_old_backups(self, max_age_seconds=3600):
        """Удаляет бэкапы старше указанного времени"""
        import time
        backup_dir = Path(tempfile.gettempdir()) / "hmi_backups"
        if not backup_dir.exists():
            return

        now = time.time()
        for file in backup_dir.glob("*.bak_*"):
            if now - file.stat().st_mtime > max_age_seconds:
                try:
                    file.unlink()
                    print(f"[CLEANUP] Удален старый бэкап: {file.name}")
                except Exception:
                    pass
    # =====================================================
    # КАМЕРА - ЗАГРУЗКА
    # =====================================================
    @Slot(result="QVariant")
    def load_camera_params(self, default: Any = None) -> Optional[dict]:
        try:

            if "scene" not in self._project_data:
                return default

            if "Camera_Settings" not in self._project_data["scene"]:
                return default

            camera_data = self._project_data["scene"]["Camera_Settings"]

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
                raise TypeError(f"camera_data must be dict, got {type(camera_data)}")

            if "camera_Settings" not in self._project_data:
                self._project_data["camera_Settings"] = {}

            self._project_data["camera_Settings"] = {
                "zoom": float(camera_data.get("zoom", 1.0)),
                "offsetX": float(camera_data.get("offsetX", 0)),
                "offsetY": float(camera_data.get("offsetY", 0))
            }
            self._save_project_manager()
            return True
        except Exception as e:
            print(f"[ERR] save_camera_params: {e}")
            return False

    # =====================================================
    # Получение Из проекта данных программ
    # =====================================================
    @Slot(str, result="QVariantMap")
    def get_data_programs_project(self, name_programs):
        return self._project_data.get('logic', {}).get('programs', {}).get(name_programs, {})

    # =====================================================
    # КАМЕРА - ЗАГРУЗКА
    # =====================================================
    @Slot(str, result="QVariant")
    def load_camera_params_scene_logic_map(self, nameProgram, default: Any = None) -> Optional[dict]:
        try:
            if "scene_camera_settings" not in self._project_data["logic"]["programs"][nameProgram]:
                return default

            camera_data = self._project_data["logic"]["programs"][nameProgram]["scene_camera_settings"]

            return {
                "zoom": float(camera_data.get("zoom", 1.0)),
                "offsetX": float(camera_data.get("offsetX", 0)),
                "offsetY": float(camera_data.get("offsetY", 0))
            }

        except Exception as e:
            print(f"[ERR] load_camera_params: {e}")
            return default

    @Slot(str, result=bool)
    def remove_programm(self, name_programm):
        self._store.remove_file(name_programm)
        del self._project_data['logic']["programs"][name_programm]
        self._save_project_manager()

    # =====================================================
    # Методы сохранения
    # =====================================================
    def _save_project_manager(self):
        """Сохранение текущих настроек в файл"""
        try:
            self._json_menager.write_json_file(path_folder=self._project_file, file_name="", items=self._project_data)

            self._add_watch()
            self.signalLoadFile.emit()

        except Exception as e:
            print(f"[project_manager] save error: {e}")
