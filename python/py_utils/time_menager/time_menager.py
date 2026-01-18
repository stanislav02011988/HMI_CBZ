from PySide6.QtCore import QTimer, QObject, Signal, QTime, Slot

from python.py_utils.decorators.decorators_qml_registration_module.decorators_qml_registration_module import QmlRegistrationModule

QML_IMPORT_NAME = "python.py_utils.time_menager.interface_qml_menager_time"
QML_MODULE_MAJOR_VERSION = 1
QML_MODULE_MINOR_VERSION = 0
QML_IMPORT_TYPE = "singleton"
Singleton_Type_Register = "singleton_instance_register"

@QmlRegistrationModule(
    QML_IMPORT_NAME,
    QML_MODULE_MAJOR_VERSION,
    QML_MODULE_MINOR_VERSION,
    QML_IMPORT_TYPE
)
class TimeManager(QObject):
    timeUpdated = Signal(int, int, int, bool)

    def __init__(self):
        super().__init__()
        self.timer = QTimer(self)
        self.timer.timeout.connect(self.update_time)
        self.blink = True

    def get_parametrs_qml_module(self):
        return QML_IMPORT_TYPE, Singleton_Type_Register, QML_IMPORT_NAME, QML_MODULE_MAJOR_VERSION, QML_MODULE_MINOR_VERSION
    @Slot()
    def start_timer(self):
        if not self.timer.isActive():
            self.update_time()
            self.timer.start(1000)

    def update_time(self):
        current_time = QTime.currentTime()
        h = current_time.hour()
        m = current_time.minute()
        s = current_time.second()
        self.blink = not self.blink
        self.timeUpdated.emit(h, m, s, self.blink)
