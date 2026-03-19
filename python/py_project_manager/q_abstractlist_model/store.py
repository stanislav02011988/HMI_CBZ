# python\py_project_manager\q_abstractlist_model\store.py
from PySide6.QtCore import QObject, Signal
import uuid


class Store(QObject):

    treeChanged = Signal()

    def __init__(self, parent=None):
        super().__init__(parent)

        self._nodes = []

    # -------------------------------------

    def load_project(self, project_dict):

        self._nodes.clear()

        name = project_dict["meta"]["nameProject"]
        root_id = "root"

        # =============================
        # ROOT PROJECT
        # =============================
        self._nodes.append({
            "id": root_id,
            "name": name,
            "type": "project",
            "level": 0,
            "parent": None,
            "isLast": True
        })

        programs = project_dict.get("logic", {}).get("programs", {})

        keys = list(programs.keys())

        for i, program_name in enumerate(keys):

            is_last = i == len(keys) - 1

            self._nodes.append({
                "id": program_name,
                "name": program_name,
                "type": "file",
                "level": 1,
                "parent": root_id,
                "isLast": is_last
            })

        self.treeChanged.emit()


    # -------------------------------------

    def nodes(self):
        return self._nodes

    # -------------------------------------

    def add_file(self, parent_id, name):
        new_id = str(uuid.uuid4())

        parent = None
        parent_level = 0

        for n in self._nodes:
            if n["id"] == parent_id:
                parent = n
                parent_level = n["level"]

        if parent is None:
            return

        self._nodes.append({
            "id": new_id,
            "name": name,
            "type": "file",
            "level": parent_level + 1,
            "parent": parent_id,
            "isLast": False
        })

        self.treeChanged.emit()

    # -------------------------------------

    def remove_file(self, node_id):
        to_remove = []

        for n in self._nodes:
            if n["id"] == node_id:
                to_remove.append(n)

        for r in to_remove:
            self._nodes.remove(r)

        self.treeChanged.emit()

    # -------------------------------------

    def rename_file(self, node_id, new_name):
        for n in self._nodes:
            if n["id"] == node_id:
                n["name"] = new_name

        self.treeChanged.emit()
