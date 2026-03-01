# backend/managers/component_object_register.py
"""
Менеджер регистрации компонентов сцены
Хранит ссылки на все созданные виджеты и позволяет быстро найти элемент по ID
"""
from PySide6.QtCore import QObject, Signal, Slot, Property
from PySide6.QtQml import QJSValue
from typing import Dict, Any, List, Optional
import datetime

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

    @Slot(QObject, "QVariant", QObject, result=bool)
    def registerElement(self, wrapper, config, widget_ref) -> bool:

        # --- Конвертация QJSValue → dict ---
        if isinstance(config, QJSValue):
            config = config.toVariant()

        if not isinstance(config, dict):
            print("[ERR] registerElement: config не является dict")
            return False

        if "id_widget" not in config:
            print("[ERR] registerElement: id_widget отсутствует")
            return False

        element_id = config["id_widget"]

        if element_id in self._elements_by_id:
            print(f"[WARN] ID '{element_id}' уже существует")
            return False

        record = {
            "id": element_id,
            "wrapper": wrapper,
            "widgetRef": widget_ref,
            "config": dict(config),
            "createdAt": datetime.datetime.now().isoformat()
        }

        self._elements_by_id[element_id] = record
        self._elements_list.append(record)

        self.elementAdded.emit(element_id)
        self.registryChanged.emit()

        print(f"[OK] Зарегистрирован элемент: {element_id}")
        return True

    # =========================================================================
    # UNREGISTER
    # =========================================================================

    @Slot(QObject, result=bool)
    def unregisterElement(self, wrapper) -> bool:

        if wrapper is None:
            return False

        element_id = None

        for key, record in self._elements_by_id.items():
            if record["wrapper"] == wrapper:
                element_id = key
                break

        if not element_id:
            return False

        record = self._elements_by_id.pop(element_id)
        self._elements_list.remove(record)

        self.elementRemoved.emit(element_id)
        self.registryChanged.emit()

        print(f"[DEL] Удалён элемент: {element_id}")  # ← Исправлено: без эмодзи и селекторов
        return True

    # =========================================================================
    # O(1) GET
    # =========================================================================

    @Slot(str, result="QVariant")
    def getElementById(self, element_id: str) -> Optional[dict]:
        return self._elements_by_id.get(element_id)

    @Slot(str, result=QObject)
    def getElementWrapper(self, element_id: str):
        record = self._elements_by_id.get(element_id)
        return record["wrapper"] if record else None

    @Slot(str, result=QObject)
    def getElementWidgetRef(self, element_id: str):
        record = self._elements_by_id.get(element_id)
        return record["widgetRef"] if record else None

    # =========================================================================
    # GET ALL IDS
    # =========================================================================

    @Slot(result="QVariant")
    def getAllIds(self) -> List[str]:
        return list(self._elements_by_id.keys())

    # =========================================================================
    # EXPORT
    # =========================================================================

    @Slot(result="QVariant")
    def exportSceneData(self) -> List[dict]:

        export_data = []

        for record in self._elements_list:

            wrapper = record["wrapper"]

            if wrapper is None:
                continue

            export_data.append({
                "type": getattr(wrapper, "widgetData", {}).get("type", ""),
                "relX": getattr(wrapper, "relX", 0.0),
                "relY": getattr(wrapper, "relY", 0.0),
                "relW": getattr(wrapper, "relW", 0.0),
                "relH": getattr(wrapper, "relH", 0.0),
                "widgetConfig": record["config"]
            })

        return export_data

    # =========================================================================
    # CLEAR
    # =========================================================================

    @Slot()
    def clear(self):

        self._elements_by_id.clear()
        self._elements_list.clear()

        self.registryChanged.emit()
        print("[INFO] Регистр полностью очищен")  # ← Исправлено: без эмодзи

    # =========================================================================
    # CONTAINS
    # =========================================================================

    @Slot(str, result=bool)
    def contains(self, element_id: str) -> bool:
        return element_id in self._elements_by_id
