import json
import os

class Manager_Json:
    def __init__(self):
        super().__init__()

        self.items = {}

    def _joing_path_file(self, path_folder, file_name):
        app_path = os.path.abspath(os.getcwd())
        path = os.path.join(app_path, path_folder)
        return os.path.normpath(os.path.join(path, file_name))

    def write_json_file(self, path_folder, file_name, items):
        # WRITE JSON FILE
        with open(self._joing_path_file(path_folder, file_name), "w", encoding='utf-8') as write:
            json.dump(items, write, indent=4, ensure_ascii=False)

    def read_json_file(self, path_folder, file_name):
        # READ JSON FILE
        with open(self._joing_path_file(path_folder, file_name), "r", encoding='utf-8') as reader:
            self.items = json.loads(reader.read())

    def update_json_file(self, path_folder, file_name, items):
        with open(self._joing_path_file(path_folder, file_name), 'r+', encoding='utf-8') as f:
            dic = json.loads(f.read())
            dic.update(items)
            json.dump(dic, f, indent=4, ensure_ascii=False)

    def clear_items(self):
        self.items.clear()
