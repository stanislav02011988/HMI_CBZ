# python\py_project_manager\q_abstractlist_model\model.py
from PySide6.QtCore import QAbstractListModel, Qt, QModelIndex, Slot


class Model(QAbstractListModel):

    NameRole = Qt.UserRole + 1
    TypeRole = Qt.UserRole + 2
    LevelRole = Qt.UserRole + 3
    IdRole = Qt.UserRole + 4
    ParentRole = Qt.UserRole + 5
    IsLastRole = Qt.UserRole + 6

    def __init__(self, store, parent=None):
        super().__init__(parent)

        self._store = store
        self._nodes = []

        store.treeChanged.connect(self._reload)

    # -------------------------------------

    def roleNames(self):
        return {
            self.NameRole: b"name",
            self.TypeRole: b"type",
            self.LevelRole: b"level",
            self.IdRole: b"id",
            self.ParentRole: b"parent",
            self.IsLastRole: b"isLast"
        }

    # -------------------------------------

    def rowCount(self, parent=QModelIndex()):
        return len(self._nodes)

    # -------------------------------------
    def data(self, index, role):
        if not index.isValid():
            return None
        node = self._nodes[index.row()]

        if role == self.NameRole:
            return node["name"]
        if role == self.TypeRole:
            return node["type"]
        if role == self.LevelRole:
            return node["level"]
        if role == self.IdRole:
            return node["id"]
        if role == self.ParentRole:
            return node["parent"]
        if role == self.IsLastRole:
            return node["isLast"]

        return None

    #МЕТОД для QML: получение данных по индексу строки
    @Slot(int, result="QVariant")
    def getDataAtRow(self, row: int):
        if 0 <= row < len(self._nodes):
            node = self._nodes[row]
            return {
                "name": node["name"],
                "type": node["type"],
                "level": node["level"],
                "id": node["id"],
                "parent": node["parent"],
                "isLast": node["isLast"]
            }
        return {}
    # -------------------------------------
    def _reload(self):
        self.beginResetModel()
        self._nodes = self._store.nodes().copy()
        self.endResetModel()

    # -------------------------------------

    @Slot(str, str)
    def addFile(self, parent_id, name):
        self._store.add_file(parent_id, name)

    # -------------------------------------

    @Slot(str)
    def removeFile(self, node_id):
        self._store.remove_file(node_id)

    # -------------------------------------

    @Slot(str, str)
    def renameFile(self, node_id, new_name):
        self._store.rename_file(node_id, new_name)
