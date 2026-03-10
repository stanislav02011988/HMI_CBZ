# python\py_register_component_object\register_component_object.py
"""
Менеджер регистрации компонентов сцены
Хранит ссылки на все созданные виджеты и позволяет быстро найти элемент по ID
"""
from PySide6.QtCore import QObject, Signal, Slot, Property
from typing import Dict, Any, List, Optional

from python.py_utils.decorators.decorators_qml_registration_module.decorators_qml_registration_module import QmlRegistrationModule

QML_IMPORT_TYPE = "singleton"
Singleton_Type_Register = "singleton_instance_register"
QML_IMPORT_NAME = "python.py_register_component_object.interface_qml"
QML_MODULE_MAJOR_VERSION = 1
QML_MODULE_MINOR_VERSION = 0


@QmlRegistrationModule(QML_IMPORT_NAME, QML_MODULE_MAJOR_VERSION, QML_MODULE_MINOR_VERSION, QML_IMPORT_TYPE)
class RegisterComponentObject(QObject):
    """Бэкенд-регистратор объектов сцены"""

    # Сигналы
    elementAdded = Signal(str)      # id_widget
    elementRemoved = Signal(str)    # id_widget
    registryChanged = Signal()

    def __init__(self, parent=None):
        super().__init__(parent)

        # O(1) индекс
        self._elements_by_id: Dict[str, Dict[str, Any]] = {}

        # Для обхода и экспорта
        self._elements_list: List[Dict[str, Any]] = []

    def get_parametrs_qml_module(self):
        return QML_IMPORT_TYPE, Singleton_Type_Register, QML_IMPORT_NAME, QML_MODULE_MAJOR_VERSION, QML_MODULE_MINOR_VERSION

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
        print(f"[DEL] Удалён элемент: {id_widget} Осталось элементов в сцене {self.count }")
        return True


    # =========================================================================
    # O(1) GET
    # =========================================================================
    @Slot(str, result="QVariant")
    def getElementById(self, id_widget: str) -> Optional[dict]:
        return self._elements_by_id.get(id_widget)

    @Slot(str, result=QObject)
    def getElementWrapper(self, id_widget: str):
        record = self._elements_by_id.get(id_widget)
        return record["wrapper"] if record else None

    @Slot(str, result=QObject)
    def getElementWidgetRef(self, id_widget: str):
        record = self._elements_by_id.get(id_widget)
        return record["widgetRef"] if record else None

    @Slot(QObject, result="QVariant")
    def getElementByWrapper(self, wrapper_ref):
        """Получить запись элемента по ссылке на обёртку"""
        for record in self._elements_list:
            if record.get("wrapperRef") == wrapper_ref:
                return record
        return None

    # =========================================================================
    # GET ALL IDS
    # =========================================================================
    @Slot(result="QVariant")
    def getAllIds(self) -> List[str]:
        return list(self._elements_by_id.keys())

    # =========================================================================
    # ВСПОМОГАТЕЛЬНЫЙ МЕТОД ЭКСПОРТА
    # =========================================================================
    def _export_element_data(self, record: Dict[str, Any]) -> Optional[Dict[str, Any]]:
        """
        Экспортирует данные ОДНОГО элемента в формате, совместимом с exportSceneData()
        Возвращает структуру:
        {
            "id_widget": str,
            "name_widget": str,
            "componentGroupe": str,
            "subtype": str,
            "geometry": { "relX": float, "relY": float, "relW": float, "relH": float },
            "sizeProperties": dict
        }
        """
        widget = record.get("widgetRef")
        wrapper = record.get("wrapperRef")

        if not widget or not wrapper:
            return None

        # Базовые свойства
        element_id = widget.property("id_widget")
        if not element_id:
            return None

        group = widget.property("componentGroupe")
        subtype = widget.property("subtype")
        name = widget.property("name_widget")

        # Геометрия обёртки
        geometry = {
            "relX": wrapper.property("relX"),
            "relY": wrapper.property("relY"),
            "relW": wrapper.property("relW"),
            "relH": wrapper.property("relH")
        }

        # Свойства размеров виджета
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

    # =========================================================================
    # EXPORT ОДНОГО ЭЛЕМЕНТА (публичный слот для QML)
    # =========================================================================
    @Slot(str, result="QVariant")
    def exportElementData(self, id_widget: str) -> Dict[str, Any]:
        """
        Экспортирует данные конкретного элемента по его ID
        Используется для частичного сохранения без перезаписи всей сцены
        """
        record = self._elements_by_id.get(id_widget)
        if not record:
            print(f"[WARN] exportElementData: элемент не найден - {id_widget}")
            return {}

        data = self._export_element_data(record)
        return data if data else {}

    # =========================================================================
    # EXPORT
    # =========================================================================
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

            # =====================================================
            # SIZE PROPERTIES
            # =====================================================
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

        return result


    # =========================================================================
    # Очистка
    # =========================================================================
    @Slot()
    def clear(self):
        self._elements_by_id.clear()
        self._elements_list.clear()
        self.registryChanged.emit()
        print("[INFO] Регистр очищен")
