from python.py_data_base.users.users_database_connect import UsersDataBaseConnect


class DB_Manager:
    def __init__(self, manajer_json):
        super().__init__()

        self.manager_json = manajer_json

        self.db_users = UsersDataBaseConnect()

        self._load_json_database_settings()
        self._init_database_users()


    def _load_json_database_settings(self):
        self.manager_json.read_json_file(
            "files_settings/json_files/settings/project_settings/database_settings",
            "database_settings.json"
        )

    def _init_database_users(self):
        self.db_users.init_settings(
            folder=self.manager_json.items['db_users']['folder'],
            name=self.manager_json.items['db_users']['name'],
            echo=self.manager_json.items['db_users']['echo']

        )
        self.db_users.engine_db()
        self.db_users.createDB()
