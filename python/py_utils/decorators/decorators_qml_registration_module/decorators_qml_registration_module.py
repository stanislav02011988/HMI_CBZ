import inspect
from pathlib import Path
from PySide6.QtQml import qmlRegisterType

from .generators.qmldir_generator import QmldirGenerator
from .generators.qmltypes_generator import QmlTypesGenerator


class QmlRegistrationModule:
    """
    Главный декоратор для регистрации QML-модуля.
    Создаёт структуру каталогов и файлы:
      - qmldir
      - <source_filename>.qmltypes
    Также регистрирует тип в QML:
      - qmlRegisterType()
      - qmlRegisterSingletonInstance()
    """

    def __init__(self, qml_import_name: str,
                 major: int = 1,
                 minor: int = 0,
                 registration_type: str = "type"):
        """
        :param qml_import_name: Имя модуля (например 'Interface.ThemeProject')
        :param major: Основная версия модуля
        :param minor: Минорная версия модуля
        :param registration_type: 'type' или 'singleton'
        """
        self.qml_import_name = qml_import_name
        self.major = major
        self.minor = minor
        self.registration_type = registration_type.lower().strip()
        self.folder_path = Path(qml_import_name.replace(".", "/"))

    def __call__(self, cls):
        # --- Определяем исходный файл и имя класса ---
        self.class_name = cls.__name__
        self.source_path = Path(inspect.getfile(cls)).resolve()
        self.source_file = self.source_path.stem

        # --- Создаём папку модуля, если её нет ---
        self.folder_path.mkdir(parents=True, exist_ok=True)

        # --- Пути к файлам ---
        files = {
            "qmldir": self.folder_path / "qmldir",
            "qmltypes": self.folder_path / f"{self.source_file}.qmltypes",
        }

        # --- Генераторы ---
        QmldirGenerator(self.qml_import_name, files["qmldir"], files["qmltypes"]).generate()
        QmlTypesGenerator(cls, self.qml_import_name, files["qmltypes"], self.source_path).generate()

        # --- Добавляем служебную информацию в класс ---
        cls.QML_IMPORT_NAME = self.qml_import_name
        cls.QML_IMPORT_PATH = str(self.folder_path)
        cls.QML_MODULE_DECORATOR = self
        return cls

