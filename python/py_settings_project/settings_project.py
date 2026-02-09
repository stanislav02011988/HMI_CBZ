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
    signalSilosElementAdded = Signal(str)    # ID добавленного/обновлённого силоса
    signalSilosElementRemoved = Signal(str)  # ID удалённого силоса

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

    # === РАБОТА С ЭЛЕМЕНТАМИ СИЛОСОВ ===

    @Slot("QVariant", result=bool)
    def save_silos_element(self, element_config) -> bool:
        try:
            # === КРИТИЧЕСКОЕ ИСПРАВЛЕНИЕ: преобразование QJSValue → dict ===
            if hasattr(element_config, 'toVariant'):
                element_config = element_config.toVariant()
            elif not isinstance(element_config, dict):
                raise ValueError(f"Неверный тип данных: {type(element_config)}")

            # Валидация обязательных полей
            if not element_config or 'id' not in element_config or 'name' not in element_config:
                raise ValueError("Отсутствуют обязательные поля: id, name")

            silos_id = str(element_config['id']).strip()
            if not silos_id:
                raise ValueError("ID силоса не может быть пустым")

            # Чтение текущей конфигурации
            config = self._json_menager.read_json_file(self._file_path, self._file_name) or {}

            # Создание структуры если её нет
            config.setdefault('block_graphic_settings', {})
            config['block_graphic_settings'].setdefault('widget_cement_silos', {})

            # === СОХРАНЯЕМ ВСЕ ПОЛЯ ИЗ КОНФИГУРАЦИИ (включая пути) ===
            # Формируем запись силоса с сохранением ВСЕХ полей из element_config
            silos_record = {}
            for key, value in element_config.items():
                # Преобразуем значения в безопасные типы
                if isinstance(value, (str, int, float, bool)):
                    silos_record[key] = value
                elif isinstance(value, dict):
                    silos_record[key] = value
                else:
                    silos_record[key] = str(value)

            # Гарантируем наличие обязательных полей
            # silos_record.setdefault('name_silos', element_config.get('name', ''))
            # silos_record.setdefault('id_motor', element_config.get('motorId', ''))
            # silos_record.setdefault('level', float(element_config.get('level', 0.0)))
            # silos_record.setdefault('type', element_config.get('type', 'silos'))
            # silos_record.setdefault('timestamp', element_config.get('timestamp', self._get_current_timestamp()))

            # Сохранение/обновление записи
            config['block_graphic_settings']['widget_cement_silos'][silos_id] = silos_record

            # Запись обновлённой конфигурации
            self._json_menager.write_json_file(
                path_folder=self._file_path,
                file_name=self._file_name,
                items=config
            )

            # Обновление наблюдателя и уведомление интерфейса
            self._add_watch()
            self.signalLoadFile.emit()
            self.signalSilosElementAdded.emit(silos_id)

            return True

        except Exception as e:
            # Безопасное получение ID для сообщения об ошибке
            silos_id_safe = "unknown"
            try:
                if hasattr(element_config, 'toVariant'):
                    ec_dict = element_config.toVariant()
                    silos_id_safe = ec_dict.get('id', 'unknown') if isinstance(ec_dict, dict) else 'unknown'
                elif isinstance(element_config, dict):
                    silos_id_safe = element_config.get('id', 'unknown')
            except:
                pass

            error_msg = f"Ошибка сохранения силоса {silos_id_safe}: {str(e)}"
            self.signalErrorLoad.emit("[SettingsProject] save_silos_element", error_msg)
            return False

    @Slot(str, result=bool)
    def remove_silos_element(self, silos_id: str) -> bool:
        """Удаление элемента силоса из конфигурации"""
        try:
            if not silos_id or not silos_id.strip():
                raise ValueError("ID силоса не может быть пустым")

            silos_id = silos_id.strip()

            # Чтение текущей конфигурации
            config = self._json_menager.read_json_file(self._file_path, self._file_name) or {}

            # Проверка существования силоса
            if ('block_graphic_settings' in config and
                'widget_cement_silos' in config['block_graphic_settings'] and
                silos_id in config['block_graphic_settings']['widget_cement_silos']):

                # Удаление записи
                del config['block_graphic_settings']['widget_cement_silos'][silos_id]

                # Если секция стала пустой, удаляем её
                if not config['block_graphic_settings']['widget_cement_silos']:
                    del config['block_graphic_settings']['widget_cement_silos']

                # Запись обновлённой конфигурации
                self._json_menager.write_json_file(
                    path_folder=self._file_path,
                    file_name=self._file_name,
                    items=config
                )

                # Обновление наблюдателя и уведомление интерфейса
                self._add_watch()
                self.signalLoadFile.emit()
                self.signalSilosElementRemoved.emit(silos_id)

                return True
            else:
                # Силос не найден - не считаем это ошибкой
                self.signalSilosElementRemoved.emit(silos_id)
                return True

        except Exception as e:
            error_msg = f"Ошибка удаления силоса {silos_id}: {str(e)}"
            self.signalErrorLoad.emit("[SettingsProject] remove_silos_element", error_msg)
            return False

    @Slot(str, result="QVariant")
    def get_silos_element(self, silos_id: str) -> dict:
        """Получение конфигурации элемента силоса по ID"""
        try:
            if not silos_id or not silos_id.strip():
                return {}

            silos_id = silos_id.strip()

            # Чтение текущей конфигурации
            config = self._json_menager.read_json_file(self._file_path, self._file_name) or {}

            # Поиск силоса
            if ('block_graphic_settings' in config and
                'widget_cement_silos' in config['block_graphic_settings'] and
                silos_id in config['block_graphic_settings']['widget_cement_silos']):

                silos_data = config['block_graphic_settings']['widget_cement_silos'][silos_id]
                return {
                    'id': silos_id,
                    'level': silos_data.get('level', 0.0),
                    'motorId': silos_data.get('id_motor', ''),
                    'name': silos_data.get('name_silos', ''),
                    'path_file_element': silos_data.get('path_file_element', ''),
                    'subtype': silos_data.get('subtype', ''),
                    'timestamp': silos_data.get('timestamp', ''),
                    'type': silos_data.get('type', 'silos')
                }

            return {}

        except Exception as e:
            error_msg = f"Ошибка получения силоса {silos_id}: {str(e)}"
            self.signalErrorLoad.emit("[SettingsProject] get_silos_element", error_msg)
            return {}

    @Slot(result="QVariant")
    def get_all_silos_elements(self) -> dict:
        """Получение всех элементов силосов"""
        try:
            # Чтение текущей конфигурации
            config = self._json_menager.read_json_file(self._file_path, self._file_name) or {}

            # Извлечение силосов
            if ('block_graphic_settings' in config and
                'widget_cement_silos' in config['block_graphic_settings']):

                silos_dict = config['block_graphic_settings']['widget_cement_silos']
                result = {}
                for silos_id, silos_data in silos_dict.items():
                    result[silos_id] = {
                        'id': silos_id,
                        'level': silos_data.get('level', 0.0),
                        'motorId': silos_data.get('id_motor', ''),
                        'name': silos_data.get('name_silos', ''),
                        'path_file_element': silos_data.get('path_file_element', ''),
                        'subtype': silos_data.get('subtype', ''),
                        'timestamp': silos_data.get('timestamp', ''),
                        'type': silos_data.get('type', 'silos')
                    }

                return result

            return {}

        except Exception as e:
            error_msg = f"Ошибка получения списка силосов: {str(e)}"
            self.signalErrorLoad.emit("[SettingsProject] get_all_silos_elements", error_msg)
            return {}

    @Slot(str, result=bool)
    def silos_element_exists(self, silos_id: str) -> bool:
        """Проверка существования элемента силоса по ID"""
        try:
            if not silos_id or not silos_id.strip():
                return False

            silos_id = silos_id.strip()

            # Чтение текущей конфигурации
            config = self._json_menager.read_json_file(self._file_path, self._file_name) or {}

            return ('block_graphic_settings' in config and
                   'widget_cement_silos' in config['block_graphic_settings'] and
                   silos_id in config['block_graphic_settings']['widget_cement_silos'])

        except Exception as e:
            error_msg = f"Ошибка проверки существования силоса {silos_id}: {str(e)}"
            self.signalErrorLoad.emit("[SettingsProject] silos_element_exists", error_msg)
            return False

    # === ВСПОМОГАТЕЛЬНЫЕ МЕТОДЫ ===

    def _get_current_timestamp(self) -> str:
        """Получение текущей временной метки в ISO формате"""
        from datetime import datetime
        return datetime.now().isoformat()

    @Slot(str)
    def save_theme(self, name_theme) -> None:
        data = self._json_menager.read_json_file(self._file_path, self._file_name) or {}
        data.setdefault("block_graphic_settings", {})["theme_path"] = (
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
