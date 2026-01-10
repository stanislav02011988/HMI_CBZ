# This Python file uses the following encoding: utf-8
from PySide6.QtQml import qmlRegisterSingletonType, qmlRegisterSingletonInstance, qmlRegisterType

class QmlRegistrationModule:
    def __init__(self):
        super().__init__()


    def registration_module(self, cls):
        choice_type_registr, singleton_type_register, path_module, major, minor = cls.get_parametrs_qml_module()

        if choice_type_registr == "type":
            self._qml_register_type(cls, path_module, major, minor)
        else:
            match singleton_type_register:
                case "singleton_type_register":
                    self._qml_register_singleton_type(cls, path_module, major, minor)
                case "singleton_instance_register":
                    self._qml_registr_singleton_instance(cls, path_module, major, minor)

    def _qml_register_type(self, cls, path_module, major, minor):
        qmlRegisterType(cls.__class__, path_module, major, minor, f"{cls.__class__.__name__}")

    def _qml_register_singleton_type(self, cls, path_module, major, minor):
        qmlRegisterSingletonType(cls.__class__, path_module, major, minor, f"{cls.__class__.__name__}")

    def _qml_registr_singleton_instance(self, cls, path_module, major, minor):
        qmlRegisterSingletonInstance(cls.__class__, path_module, major, minor, f"{cls.__class__.__name__}", cls)
