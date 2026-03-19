from PySide6.QtCore import QObject, Signal, Slot

from python.py_utils.decorators.decorators_qml_registration_module.decorators_qml_registration_module import QmlRegistrationModule

QML_IMPORT_TYPE = "singleton"
Singleton_Type_Register = "singleton_instance_register"
QML_IMPORT_NAME = "python.py_bus_manager.interface_qml"
QML_MODULE_MAJOR_VERSION = 1
QML_MODULE_MINOR_VERSION = 0


@QmlRegistrationModule(
    QML_IMPORT_NAME,
    QML_MODULE_MAJOR_VERSION,
    QML_MODULE_MINOR_VERSION,
    QML_IMPORT_TYPE
)
class BusManager(QObject):

    # topic,event,payload
    message = Signal(str, str, "QVariant")

    def __init__(self):
        super().__init__()

        # только для отладки
        self._subscriptions = set()

    def get_parametrs_qml_module(self):
        return (
            QML_IMPORT_TYPE,
            Singleton_Type_Register,
            QML_IMPORT_NAME,
            QML_MODULE_MAJOR_VERSION,
            QML_MODULE_MINOR_VERSION
        )

    # -----------------------------------------------------
    # SUBSCRIBE
    # -----------------------------------------------------

    @Slot(str)
    def subscribe(self, topic):
        if topic not in self._subscriptions:
            self._subscriptions.add(topic)
            print(f"[Bus] subscribe -> {topic}")

    # -----------------------------------------------------
    # PUBLISH
    # -----------------------------------------------------

    @Slot(str, str, "QVariant")
    def publish(self, topic, event, payload):
        print(f"[Bus] publish {topic} {event}")
        self.message.emit(topic, event, payload)
