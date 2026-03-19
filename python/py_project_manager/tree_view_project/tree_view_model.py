from PySide6.QtCore import QAbstractItemModel, QModelIndex, Qt, Slot
from .tree_view_store import TreeNode


class TreeViewModel(QAbstractItemModel):

    NameRole = Qt.UserRole + 1
    TypeRole = Qt.UserRole + 2
    LevelRole = Qt.UserRole + 3
    IdRole = Qt.UserRole + 4
    ParentRole = Qt.UserRole + 5
    IsLastRole = Qt.UserRole + 6
    HasChildrenRole = Qt.UserRole + 7
    BranchMaskRole = Qt.UserRole + 8

    def __init__(self, store, parent=None):
        super().__init__(parent)
        self._store = store
        self._store.layoutChanged.connect(self.beginResetModel)
        self._store.layoutChanged.connect(self.endResetModel)

    def roleNames(self):
        return {
            self.NameRole: b"name",
            self.TypeRole: b"type",
            self.LevelRole: b"level",
            self.IdRole: b"id",           # Доступно в QML как model.id
            self.ParentRole: b"parent",
            self.IsLastRole: b"isLast",
            self.HasChildrenRole: b"hasChildren",
            self.BranchMaskRole: b"branchMask"
        }

    def rowCount(self, parent=QModelIndex()) -> int:
        if not self._store.root:
            return 0

        # Если запрос к корню дерева (невалидный индекс) -> возвращаем 1 (сам узел Project)
        if not parent.isValid():
            return 1

        # Иначе смотрим детей конкретного узла
        node = parent.internalPointer()
        return len(node.children)

    def columnCount(self, parent=QModelIndex()) -> int:
        return 1

    def index(self, row: int, column: int, parent=QModelIndex()) -> QModelIndex:
        if column != 0 or row < 0:
            return QModelIndex()

        # Если родителя нет, создаем индекс для самого Корня (Project)
        # Он всегда один, поэтому row должен быть 0
        if not parent.isValid():
            if row == 0:
                return self.createIndex(row, column, self._store.root)
            return QModelIndex()

        # Создаем индекс для детей указанного родителя
        parent_node = parent.internalPointer()
        if row >= len(parent_node.children):
            return QModelIndex()

        return self.createIndex(row, column, parent_node.children[row])

    def parent(self, index: QModelIndex) -> QModelIndex:
        if not index.isValid():
            return QModelIndex()

        child_node = index.internalPointer()
        parent_node = child_node.parent

        # 1. Если у узла вообще нет родителя (это сам root хранилища) -> возвращаем невалидный индекс
        if not parent_node:
            return QModelIndex()

        # 2. ГЛАВНОЕ ИСПРАВЛЕНИЕ:
        # Если родитель узла - это наш корневой объект (_store.root),
        # значит этот узел (Программа) лежит внутри Проекта.
        # Мы должны вернуть ИНДЕКС проекта, чтобы TreeView знал, что вкладывать его внутрь.
        if parent_node == self._store.root:
            # Проект всегда находится по адресу row=0, column=0 от невалидного родителя
            return self.createIndex(0, 0, self._store.root)

        # 3. Обычный случай: родитель тоже имеет родителя (например, папка внутри программы)
        grandparent = parent_node.parent
        if grandparent:
            # Находим ряд родителя в списке детей его родителя (дедушки)
            row = grandparent.children.index(parent_node)
            return self.createIndex(row, 0, parent_node)

        #Fallback (не должно достигаться при правильной структуре)
        return QModelIndex()

    def data(self, index: QModelIndex, role=Qt.DisplayRole):
        if not index.isValid():
            return None
        node = index.internalPointer()

        # Проверка на пустое имя, чтобы избежать "Безымянная"
        display_name = node.name if node.name else "Unnamed"

        if role in (Qt.DisplayRole, self.NameRole):
            return display_name
        elif role == self.TypeRole:
            return node.type
        elif role == self.IdRole:
            return node.id
        elif role == self.LevelRole:
            # Считаем уровень: Project=0, Program=1, Folder=2
            level = 0
            curr = node
            while curr.parent:
                level += 1
                curr = curr.parent
            return level
        elif role == self.IsLastRole:
            if node.parent:
                return node.parent.children[-1] == node
            return True # Корень считаем последним для логики отрисовки
        elif role == self.HasChildrenRole:
            return len(node.children) > 0

        elif role == self.BranchMaskRole:
            return self._branch_mask(node)

        return None

    def _node_from_index(self, index: QModelIndex) -> TreeNode:
        if not index.isValid():
            return self._store.root
        return index.internalPointer()

    def _branch_mask(self, node: TreeNode) -> int:
        """
        Маска веток дерева.
        Каждый бит = рисовать ли вертикальную линию на уровне.
        """

        mask = 0
        level = 0

        parent = node.parent

        while parent and parent.parent:

            # если родитель НЕ последний → линия продолжается
            if parent.parent.children[-1] != parent:
                mask |= (1 << level)

            parent = parent.parent
            level += 1

        return mask

    @Slot(QModelIndex, result="QVariant")
    def getNodeData(self, index: QModelIndex) -> dict:
        if not index.isValid():
            return {}
        node = self._node_from_index(index)
        return {
            "name": node.name,
            "type": node.type,
            "id": node.id,
            "level": self.data(index, self.LevelRole),
            "hasChildren": len(node.children) > 0,
            "isLast": self.data(index, self.IsLastRole),
            "branchMask": self.data(index, self.BranchMaskRole)
        }

    @Slot(str, result=str)
    def addProgramSlot(self, program_name: str) -> str:
        new_id = self._store.add_program(program_name)
        return new_id if new_id else ""

    @Slot(str, result=bool)
    def removeProgramSlot(self, node_id: str) -> bool:
        node = self._store.get_node_by_id(node_id)
        if node and node.type == "program":
            self._store.remove_node(node_id)
            return True
        return False

    @Slot(str, str, result=bool)
    def renameNodeSlot(self, node_id: str, new_name: str) -> bool:
        node = self._store.get_node_by_id(node_id)
        if node:
            self._store.rename_node(node_id, new_name)
            return True
        return False
