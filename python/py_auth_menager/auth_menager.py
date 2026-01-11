import os
import jwt
import bcrypt
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
    loginFailed = Signal(str, str)

    registerSuccess = Signal()
    registerFailed = Signal(str)

    keyRegistrationSuccess = Signal(str)
    keyRegistrationFailed = Signal(str)

    def __init__(self, engine, parent=None):
        super().__init__(parent)
        self._engine = engine

        self._public_key = self._load_public_key()

    def get_parametrs_qml_module(self):
        return QML_IMPORT_TYPE, Singleton_Type_Register, QML_IMPORT_NAME, QML_MODULE_MAJOR_VERSION, QML_MODULE_MINOR_VERSION

    @Slot(str, str)
    def login(self, username, password):
        try:
            with Session(self._engine) as session:
                # Ищем пользователя только по логину
                user = session.query(Users).filter_by(login=username).first()

                if not user:
                    self.loginFailed.emit("[AuthMenager] Ошибка ввода!!! Неверное имя пользователя", "login_user")
                    return
                if bcrypt.checkpw(
                    password.encode('utf-8'),
                    user.password.encode('utf-8')
                ):
                    self.loginSuccess.emit()
                else:
                    self.loginFailed.emit("[AuthMenager] Ошибка ввода!!! Неверный пароль", "password_user")

        except Exception as e:
            self.loginFailed.emit("[AuthMenager] Ошибка базы данных:", str(e))

    @Slot(str, str, str, str, str, str, str, str)
    def register(
        self,
        last_name: str,
        first_name: str,
        second_name: str,
        tab_number: str,
        position_users: str,
        login: str,
        password: str,
        access_group: str
    ):
        try:
            # Хэшируем пароль
            hashed_pw = bcrypt.hashpw(password.encode('utf-8'), bcrypt.gensalt()).decode()

            with Session(self._engine) as session:
                # Проверка уникальности логина
                if session.query(Users).filter_by(login=login).first():
                    self.registerFailed.emit("Логин уже занят")
                    return

                from datetime import datetime
                user = Users(
                    last_name=last_name,
                    first_name=first_name,
                    second_name=second_name,
                    tab_number=tab_number,
                    position_users=position_users,
                    login=login,
                    password=hashed_pw,
                    day_registration=datetime.now().strftime("%Y-%m-%d"),
                    access_group=access_group
                )
                session.add(user)
                session.commit()
                self.registerSuccess.emit()

        except Exception as e:
            self.registerFailed.emit(f"Ошибка регистрации: {str(e)}")

    def _load_public_key(self) -> str:
        key_path = "res/keys/public.pem"
        key_path = os.path.abspath(key_path)

        if not os.path.exists(key_path):
            raise FileNotFoundError(f"Публичный ключ не найден: {key_path}")

        with open(key_path, "r", encoding="utf-8") as f:
            return f.read().strip()

    @Slot(str)
    def processRegistrationKey(self, file_path: str):
        try:
            if not os.path.isfile(file_path):
                self.keyRegistrationFailed.emit("Файл ключа не найден")
                return

            with open(file_path, 'r', encoding='utf-8') as f:
                token = f.read().strip()

            if not token:
                self.keyRegistrationFailed.emit("Файл ключа пуст")
                return

            # Используем загруженный ключ
            payload = jwt.decode(
                token,
                self._public_key,  # ← теперь из файла
                algorithms=["RS256"]
            )

            if payload.get("iss").get("FIO") != "Неберикутя Станислав Александрович":
                self.keyRegistrationFailed.emit("Недействительный издатель ключа")
                return

            access_group = payload.get("type")
            if access_group not in ("admin", "user"):
                self.keyRegistrationFailed.emit("Неизвестная группа доступа")
                return
            self.keyRegistrationSuccess.emit(access_group)

        except jwt.ExpiredSignatureError:
            self.keyRegistrationFailed.emit("Срок действия ключа истёк")
        except jwt.InvalidTokenError:
            self.keyRegistrationFailed.emit("Недействительный ключ: повреждён или подделан")
        except Exception as e:
            self.keyRegistrationFailed.emit(f"Ошибка обработки ключа: {str(e)}")
