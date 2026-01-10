import os

from sqlalchemy import create_engine

from python.py_data_base.users.base import Base


class UsersDataBaseConnect:
    def __init__(self):

        self.folder = None
        self.name = None
        self.echo = None

        self.path = None

    def init_settings(self, folder, name, echo):
        self.folder = folder
        self.name = name
        self.echo = echo
        self.path = os.path.join(folder, name)

        if not os.path.exists(folder):
            os.makedirs(folder)

    def _engine_db(self):
        return create_engine(f'sqlite:///{self.path}', echo=self.echo)

    def createDB(self):
        Base.metadata.create_all(self._engine_db())
