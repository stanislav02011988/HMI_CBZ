from python.py_data_base.users.users_database_connect import UsersDataBaseConnect


class DB_Menager:
    def __init__(self, manajer_json):
        super().__init__()

        self.manager_json = manajer_json

        self.db_users = UsersDataBaseConnect()

        self._load_json_database_settings()        


    def _load_json_database_settings(self):
        items = self.manager_json.read_json_file(
            "files_settings/json_files/settings/project_settings/database_settings",
            "database_settings.json"
        )

        self.db_users.init_settings(
            folder=items['db_users']['folder'],
            name=items['db_users']['name'],
            echo=items['db_users']['echo']

        )
        self.db_users.createDB()

