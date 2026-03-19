from PySide6.QtCore import QObject, Signal
import uuid
from typing import Any, List, Optional

class TreeNode:
    """
    Узел дерева. Представляет элемент интерфейса (Проект, Программа, Раздел).
    """
    def __init__(self, name: str, node_type: str, data: Any = None, parent: 'TreeNode' = None):
        self.id = str(uuid.uuid4()) if not data or 'id' not in data else data.get('id', str(uuid.uuid4()))
        self.name = name
        self.type = node_type  # 'project', 'program', 'folder'
        self.data = data or {} # Дополнительные данные из JSON
        self.parent = parent
        self.children: List['TreeNode'] = []

    def add_child(self, child: 'TreeNode'):
        child.parent = self
        self.children.append(child)

    def find_by_id(self, target_id: str) -> Optional['TreeNode']:
        if self.id == target_id:
            return self
        for child in self.children:
            found = child.find_by_id(target_id)
            if found:
                return found
        return None

    def to_dict(self) -> dict:
        """Сериализация для отладки или передачи в QML как QVariant (если нужно)"""
        return {
            "id": self.id,
            "name": self.name,
            "type": self.type,
            "children": [c.to_dict() for c in self.children]
        }


class TreeViewStore(QObject):
        # Сигнал об изменении структуры всего дерева
    layoutChanged = Signal()
    dataChangedSignal = Signal()

    def __init__(self, parent=None):
        super().__init__(parent)
        self._root: Optional[TreeNode] = None

    def load_project(self, project_dict: dict):
        self._root = None
        meta = project_dict.get("meta", {})
        project_name = meta.get("nameProject", "Unnamed Project")

        # Корень проекта
        root_node = TreeNode(name=project_name, node_type="project", data=meta)

        programs = project_dict.get("logic", {}).get("programs", {})
        for prog_name, prog_data in programs.items():
            prog_node = TreeNode(name=prog_name, node_type="program", data=prog_data, parent=root_node)
            root_node.add_child(prog_node)

            # Добавляем разделы nodes, connections
            for section_name in ["nodes", "connections"]:
                section_data = prog_data.get(section_name, {})
                sec_node = TreeNode(name=section_name, node_type="folder", data=section_data, parent=prog_node)
                prog_node.add_child(sec_node)

            # Обрабатываем scene отдельно, рекурсивно строим дерево до уровня элементов
            scene_data = prog_data.get("scene", {})
            scene_node = TreeNode(name="scene", node_type="folder", data=scene_data, parent=prog_node)
            prog_node.add_child(scene_node)

            for group_name, group_content in scene_data.items():  # Exemple: GroupeCement
                group_node = TreeNode(name=group_name, node_type="group", data=group_content, parent=scene_node)
                scene_node.add_child(group_node)

                for subtype_name, subtype_content in group_content.items():  # Exemple: scales, shutter
                    subtype_node = TreeNode(name=subtype_name, node_type="subtype", data=subtype_content, parent=group_node)
                    group_node.add_child(subtype_node)

                    for elem_id, elem_data in subtype_content.items():  # Exemple: scales_1_cement_1
                        element_node = TreeNode(
                            name=elem_data.get("name_widget", elem_id),
                            node_type="element",
                            data=elem_data,
                            parent=subtype_node
                        )
                        subtype_node.add_child(element_node)

        self._root = root_node
        self.layoutChanged.emit()

    @property
    def root(self) -> Optional[TreeNode]:
        return self._root

    def get_node_by_id(self, node_id: str) -> Optional[TreeNode]:
        if not self._root:
            return None
        return self._root.find_by_id(node_id)

    def add_program(self, name: str):
        """Добавление новой программы в дерево"""
        if not self._root:
            return

        new_prog_data = {
            "name": name,
            "cycle_ms": 100,
            "scene": {},
            "nodes": {},
            "connections": {},
            "scene_camera_settings": {}
        }

        prog_node = TreeNode(
            name=name,
            node_type="program",
            data=new_prog_data,
            parent=self._root
        )
        self._root.add_child(prog_node)

        # Добавляем подразделы
        for section_name in ["scene", "nodes", "connections"]:
            sec_node = TreeNode(name=section_name, node_type="folder", data={}, parent=prog_node)
            prog_node.add_child(sec_node)

        self.layoutChanged.emit()
        # Возвращаем ID созданного узла, чтобы бэкенд мог сохранить его в JSON
        return prog_node.id

    def remove_node(self, node_id: str):
        """Удаление узла (программы)"""
        if not self._root:
            return

        # Ищем родителя удаляемого узла
        # Простой поиск: если удаляем не корень, ищем кого-то, у кого этот узел в children
        def remove_from_children(parent: TreeNode):
            for i, child in enumerate(parent.children):
                if child.id == node_id:
                    parent.children.pop(i)
                    return True
                if remove_from_children(child):
                    return True
            return False

        if node_id != self._root.id:
            if remove_from_children(self._root):
                self.layoutChanged.emit()

    def rename_node(self, node_id: str, new_name: str):
        node = self.get_node_by_id(node_id)
        if node:
            node.name = new_name
            # Для программ нужно также обновить ключ в словаре данных, но здесь упрощенно
            if node.type == "program":
                node.data["name"] = new_name
            self.dataChangedSignal.emit()
