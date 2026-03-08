from pathlib import Path
from typing import Any, Optional, Dict

from PySide6.QtCore import QObject, Slot, Signal, Property, QFileSystemWatcher, QTimer
from PySide6.QtQml import QQmlPropertyMap
import shutil
import tempfile
from datetime import datetime

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
                self._file_path,
                self._file_name
            ) or {}

            if "block_graphics" not in items:
                items["block_graphics"] = {}

            items["block_graphics"]["Camera_Settings"] = {
                "zoom": float(camera_data.get("zoom", 1.0)),
                "offsetX": float(camera_data.get("offsetX", 0)),
                "offsetY": float(camera_data.get("offsetY", 0))
            }

            self._json_menager.write_json_file(
                path_folder=self._file_path,
                file_name=self._file_name,
                items=items
            )

            return True

        except Exception as e:
            print(f"[ERR] save_camera_params: {e}")
            return False



    # =====================================================
    # КАМЕРА - ЗАГРУЗКА
    # =====================================================
    @Slot(result="QVariant")
    def load_camera_params(self, default: Any = None) -> Optional[dict]:
        try:
            items = self._json_menager.read_json_file(
                self._file_path,
                self._file_name
            ) or {}

            # Проверяем наличие внутри block_graphics
            if "block_graphics" not in items:
                return default

            if "Camera_Settings" not in items["block_graphics"]:
                return default

            camera_data = items["block_graphics"]["Camera_Settings"]

            return {
                "zoom": float(camera_data.get("zoom", 1.0)),
                "offsetX": float(camera_data.get("offsetX", 0)),
                "offsetY": float(camera_data.get("offsetY", 0))
            }

        except Exception as e:
            print(f"[ERR] load_camera_params: {e}")
            return default


    # =====================================================
    # КАМЕРА - СБРОС
    # =====================================================
    @Slot()
    def reset_camera_params(self) -> bool:
        try:
            items = self._json_menager.read_json_file(
                self._file_path,
                self._file_name
            ) or {}

            if "block_graphics" in items and \
               "Camera_Settings" in items["block_graphics"]:

                del items["block_graphics"]["Camera_Settings"]

                self._json_menager.write_json_file(
                    path_folder=self._file_path,
                    file_name=self._file_name,
                    items=items
                )

            return True

        except Exception as e:
            print(f"[ERR] reset_camera_params: {e}")
            return False


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

    # =========================================================================
    # ЧАСТИЧНОЕ ОБНОВЛЕНИЕ ЭЛЕМЕНТА СЦЕНЫ С ОТКАТОМ ПРИ ОШИБКЕ
    # =========================================================================
    @Slot(str, "QVariantMap", result=bool)
    def update_element_in_config(self, id_widget: str, update_data: Dict[str, Any]) -> bool:
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
            items = self._json_menager.read_json_file(
                self._file_path,
                self._file_name
            ) or {}

            if "block_graphics" not in items:
                print("[ERR] update_element_in_config: block_graphics отсутствует в конфигурации")
                self._restore_from_backup(backup_path)
                return False

            # === 3. Находим элемент по id_widget в иерархии ===
            found = False
            target_element = None
            target_path = ("", "", "")  # (group, subtype, id_widget)

            for group, subtypes in items["block_graphics"].items():
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
            self._json_menager.write_json_file(
                path_folder=self._file_path,
                file_name=self._file_name,
                items=items
            )

            # === 6. Перерегистрируем наблюдение (файл мог быть заменён) ===
            self._add_watch()
            self.signalLoadFile.emit()

            # === 7. Удаляем резервную копию при успехе ===
            self._cleanup_backup(backup_path)

            timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
            print(f"[SAVE] Элемент '{id_widget}' обновлён ({timestamp})")
            return True

        except Exception as e:
            # === ОТКАТ ПРИ ЛЮБОЙ ОШИБКЕ ===
            print(f"[ERR] update_element_in_config: ошибка при обновлении '{id_widget}': {e}")
            import traceback
            traceback.print_exc()

            self._restore_from_backup(backup_path)
            return False

    # =========================================================================
    # ВСПОМОГАТЕЛЬНЫЕ МЕТОДЫ ДЛЯ ОТКАТА
    # =========================================================================
    def _create_backup(self) -> Optional[str]:
        """Создаёт резервную копию файла конфигурации в безопасном месте"""
        try:
            # Используем временную директорию для изоляции
            backup_dir = Path(tempfile.gettempdir()) / "hmi_backups"
            backup_dir.mkdir(exist_ok=True, parents=True)

            timestamp = datetime.now().strftime("%Y%m%d_%H%M%S_%f")
            backup_name = f"{self._file_name}.bak_{timestamp}"
            backup_path = str(backup_dir / backup_name)

            # Копируем файл с сохранением метаданных
            shutil.copy2(self._full_file_path, backup_path)

            # Ограничиваем количество резервных копий (удаляем старые)
            self._cleanup_old_backups(backup_dir, max_backups=10)

            print(f"[BACKUP] Создана резервная копия: {backup_path}")
            return backup_path

        except Exception as e:
            print(f"[ERR] _create_backup: не удалось создать резервную копию: {e}")
            return None

    def _restore_from_backup(self, backup_path: str) -> bool:
        """Восстанавливает конфигурацию из резервной копии"""
        try:
            if not Path(backup_path).exists():
                print(f"[ERR] _restore_from_backup: резервная копия не найдена: {backup_path}")
                return False

            # Восстанавливаем файл
            shutil.copy2(backup_path, self._full_file_path)

            # Перезагружаем данные
            self.load_file_settings()

            # Перерегистрируем наблюдение
            self._add_watch()

            print(f"[RESTORE] Конфигурация восстановлена из: {backup_path}")
            return True

        except Exception as e:
            print(f"[ERR] _restore_from_backup: не удалось восстановить из {backup_path}: {e}")
            return False

    def _cleanup_backup(self, backup_path: str) -> None:
        """Удаляет резервную копию после успешной операции"""
        try:
            Path(backup_path).unlink(missing_ok=True)
            print(f"[CLEANUP] Резервная копия удалена: {backup_path}")
        except Exception as e:
            print(f"[WARN] _cleanup_backup: не удалось удалить {backup_path}: {e}")

    def _cleanup_old_backups(self, backup_dir: Path, max_backups: int = 10) -> None:
        """Ограничивает количество резервных копий для экономии места"""
        try:
            if not backup_dir.exists():
                return

            # Получаем все бэкапы, сортируем по времени (новые последние)
            backups = sorted(
                [f for f in backup_dir.glob(f"{self._file_name}.bak_*")],
                key=lambda x: x.stat().st_mtime
            )

            # Удаляем самые старые, если превышено ограничение
            for old_backup in backups[:-max_backups]:
                try:
                    old_backup.unlink()
                    print(f"[CLEANUP] Удалён старый бэкап: {old_backup.name}")
                except Exception as e:
                    print(f"[WARN] Не удалось удалить старый бэкап {old_backup}: {e}")

        except Exception as e:
            print(f"[WARN] _cleanup_old_backups: ошибка очистки: {e}")
