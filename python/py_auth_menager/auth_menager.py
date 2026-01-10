from PySide6.QtCore import QObject, Slot, Signal
from sqlalchemy.orm import Session

from python.py_data_base.users.models.model_user.users import Users
from python.py_utils.decorators.decorators_qml_registration_module.decorators_qml_registration_module import QmlRegistrationModule


QML_IMPORT_TYPE = "singleton"
Singleton_Type_Register = "singleton_instance_register"
QML_IMPORT_NAME = "python.py_auth_menager.interface_auth_menager"
QML_MODULE_MAJOR_VERSION = 1
QML_MODULE_MINOR_VERSION = 0

@QmlRegistrationModule(QML_IMPORT_NAME, QML_MODULE_MAJOR_VERSION, QML_MODULE_MINOR_VERSION, QML_IMPORT_TYPE)
class AuthMenager(QObject):
    loginSuccess = Signal()
    loginFailed = Signal(str)

    def __init__(self, engine, parent=None):
        super().__init__(parent)
        self._engine = engine

    def get_parametrs_qml_module(self):
        return QML_IMPORT_TYPE, Singleton_Type_Register, QML_IMPORT_NAME, QML_MODULE_MAJOR_VERSION, QML_MODULE_MINOR_VERSION

    @Slot(str, str)
    def login(self, username, password):
        try:
            with Session(self._engine) as session:
                user = session.query(Users).filter_by(login=username, password=password).first()
                if user:
                    self.loginSuccess.emit()
                    print("[AuthMenager] Успешно!!!!")
                else:
                    self.loginFailed.emit("[AuthMenager] Неверное имя пользователя или пароль")
                    print("[AuthMenager] Ошибка!!!!")
        except Exception as e:
            self.loginFailed.emit(f"Ошибка базы данных: {str(e)}")
