# python\py_register_component_logic_map\register_component_logic_map.py
"""
Менеджер регистрации компонентов сцены
Хранит ссылки на все созданные виджеты и позволяет быстро найти элемент по ID
"""
from PySide6.QtCore import QObject, Signal, Slot, Property
from typing import Dict, Any, List, Optional

from python.py_utils.decorators.decorators_qml_registration_module.decorators_qml_registration_module import QmlRegistrationModule

QML_IMPORT_TYPE = "singleton"
Singleton_Type_Register = "singleton_instance_register"
QML_IMPORT_NAME = "python.py_register_component_logic_map.interface_qml"
QML_MODULE_MAJOR_VERSION = 1
QML_MODULE_MINOR_VERSION = 0


@QmlRegistrationModule(QML_IMPORT_NAME, QML_MODULE_MAJOR_VERSION, QML_MODULE_MINOR_VERSION, QML_IMPORT_TYPE)
class RegisterComponentLogicMap(QObject):
    """Бэкенд-регистратор объектов логической сцены"""

    # Сигналы
    elementAdded = Signal(str)      # id_widget
    elementRemoved = Signal(str)    # id_widget
    registryChanged = Signal()

    dirtyChanged = Signal()

    def __init__(self, parent=None):
        super().__init__(parent)

        # O(1) индекс
        self._elements_by_id: Dict[str, Dict[str, Any]] = {}

        # Для обхода и экспорта
        self._elements_list: List[Dict[str, Any]] = []

        self._is_dirty = False

    def get_parametrs_qml_module(self):
        return QML_IMPORT_TYPE, Singleton_Type_Register, QML_IMPORT_NAME, QML_MODULE_MAJOR_VERSION, QML_MODULE_MINOR_VERSION

    # =========================================================================
    # ВНУТРЕННЯЯ ЛОГИКА ИЗМЕНЕНИЙ (DIRTY FLAG)
    # =========================================================================
    def _set_dirty(self, value: bool):
        """Внутренний метод установки флага изменений"""
        if self._is_dirty != value:
            self._is_dirty = value
            self.dirtyChanged.emit()
            if value:
                print("[INFO] Scene modified: unsaved changes detected.")
            else:
                print("[INFO] Scene saved: no pending changes.")

    # =========================================================================
    # PROPERTY isDirty (ГЛАВНОЕ ИЗМЕНЕНИЕ)
    # =========================================================================
    @Property(bool, notify=dirtyChanged)
    def isDirty(self) -> bool:
        """
        Возвращает True, если в списке элементов были изменения,
        которые еще не были сохранены в файл.
        """
        return self._is_dirty

    # =========================================================================
    # SLOT: Сброс флага после сохранения
    # =========================================================================
    @Slot()
    def markSaved(self):
        """
        Вызывается после успешного сохранения файла конфигурации.
        Сбрасывает флаг изменений в False.
        """
        self._set_dirty(False)

    # =========================================================================
    # PROPERTY count (для QML биндингов)
    # =========================================================================
    @Property(int, notify=registryChanged)
    def count(self) -> int:
        return len(self._elements_list)

    # =========================================================================
    # REGISTER
    # =========================================================================
    @Slot(QObject, QObject, result=bool)
    def registerElement(self, wrapper_ref, widget_ref):
        if wrapper_ref is None or widget_ref is None:
            return False

        element_id = widget_ref.property("id_widget")
        if not element_id:
            return False

        if element_id in self._elements_by_id:
            return False

        record = {
            "id_widget": element_id,
            "widgetRef": widget_ref,
            "wrapperRef": wrapper_ref
        }

        self._elements_by_id[element_id] = record
        self._elements_list.append(record)

        self.elementAdded.emit(element_id)
        self.registryChanged.emit()
        self._set_dirty(True)
        return True

    # =========================================================================
    # UNREGISTER
    # =========================================================================
    @Slot(QObject, result=bool)
    def unregisterElement(self, wrapper_ref) -> bool:
        if wrapper_ref is None:
            return False

        id_widget = None
        # === ИСПРАВЛЕНО: используем правильный ключ "wrapperRef" ===
        for key, record in self._elements_by_id.items():
            if record.get("wrapperRef") == wrapper_ref:
                id_widget = key
                break

        if id_widget is None:
            print("[WARN] unregisterElement: обёртка не найдена в реестре")
            return False

        record = self._elements_by_id.pop(id_widget)
        self._elements_list.remove(record)

        self.elementRemoved.emit(id_widget)
        self.registryChanged.emit()
        self._set_dirty(True)
        # print(f"[DEL] Удалён элемент: {id_widget} Осталось элементов в сцене {self.count }")
        return True

    # =========================================================================
    # O(1) GET
    # =========================================================================
    @Slot(str, result="QVariant")
    def getElementById(self, id_widget: str) -> Optional[dict]:
        return self._elements_by_id.get(id_widget)

    # =========================================================================
    # Очистка
    # =========================================================================
    @Slot()
    def clear(self):
        self._elements_by_id.clear()
        self._elements_list.clear()
        self.registryChanged.emit()
        print("[INFO] Регистр очищен")

    # =========================================================================
    # EXPORT HELPERS (без изменений логики dirty, так как только читают)
    # =========================================================================
    def _export_element_data(self, record: Dict[str, Any]) -> Optional[Dict[str, Any]]:
        widget = record.get("widgetRef")
        wrapper = record.get("wrapperRef")

        if not widget or not wrapper:
            return None

        element_id = widget.property("id_widget")
        if not element_id:
            return None

        group = widget.property("componentGroupe")
        subtype = widget.property("subtype")
        name = widget.property("name_widget")

        geometry = {
            "relX": wrapper.property("relX"),
            "relY": wrapper.property("relY"),
            "relW": wrapper.property("relW"),
            "relH": wrapper.property("relH")
        }

        size_props = {}
        if hasattr(widget, "exportPropertiesSize"):
            try:
                size_props = widget.exportPropertiesSize()
            except Exception as e:
                print(f"[WARN] exportPropertiesSize failed for {element_id}: {e}")

        return {
            "id_widget": element_id,
            "name_widget": name,
            "componentGroupe": group,
            "subtype": subtype,
            "geometry": geometry,
            "sizeProperties": size_props
        }

    @Slot(str, result="QVariant")
    def exportElementData(self, id_widget: str) -> Dict[str, Any]:
        record = self._elements_by_id.get(id_widget)
        if not record:
            print(f"[WARN] exportElementData: элемент не найден - {id_widget}")
            return {}

        data = self._export_element_data(record)
        return data if data else {}

    @Slot(result="QVariant")
    def exportSceneData(self):
        result = {}
        for record in self._elements_list:
            widget = record["widgetRef"]
            wrapper = record["wrapperRef"]

            group = widget.property("componentGroupe")
            subtype = widget.property("subtype")
            element_id = widget.property("id_widget")

            if group not in result:
                result[group] = {}

            if subtype not in result[group]:
                result[group][subtype] = {}

            size_props = {}
            if hasattr(widget, "exportPropertiesSize"):
                try:
                    size_props = widget.exportPropertiesSize()
                except Exception:
                    size_props = {}

            result[group][subtype][element_id] = {
                "id_widget": element_id,
                "name_widget": widget.property("name_widget"),
                "componentGroupe": group,
                "subtype": subtype,
                "geometry": {
                    "relX": wrapper.property("relX"),
                    "relY": wrapper.property("relY"),
                    "relW": wrapper.property("relW"),
                    "relH": wrapper.property("relH")
                },
                "sizeProperties": size_props
            }

            self.markSaved()
        return result
