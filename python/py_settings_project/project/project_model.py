# python\py_settings_project\project\project_model.py
from PySide6.QtCore import QAbstractListModel, Qt, QModelIndex, Slot


class ProjectModel(QAbstractListModel):

    InstallationNameRole = Qt.UserRole + 1
    PreviewRole = Qt.UserRole + 2
    CreatedRole = Qt.UserRole + 3
    LastSavedRole = Qt.UserRole + 4
    IdRole = Qt.UserRole + 5
    AutoLoadRole = Qt.UserRole + 6
    ProjectFileRole = Qt.UserRole + 7
    IsActivateProject = Qt.UserRole + 8
    TypeInstallation = Qt.UserRole + 9
    NumberINF = Qt.UserRole + 10

    def __init__(self, store, parent=None):

        super().__init__(parent)

        self._store = store

        self._projects = []
        self._filtered = []

        store.projectsChanged.connect(self._reload)

    # -------------------------------------------------
    def roleNames(self):
        return {

            self.InstallationNameRole: b'installationName',
            self.PreviewRole: b'previewInstallation',
            self.CreatedRole: b'created',
            self.LastSavedRole: b'last_saved',
            self.IdRole: b'id_uuic',
            self.AutoLoadRole: b'check_auto_load',
            self.ProjectFileRole: b'project_file',
            self.IsActivateProject: b'isActivateProject',
            self.TypeInstallation: b'typeInstallation',
            self.NumberINF: b'numberINF'
        }

    # -------------------------------------------------
    def rowCount(self, parent=QModelIndex()):
        return len(self._filtered)

    # -------------------------------------------------
    def data(self, index, role):
        if not index.isValid():
            return None

        p = self._filtered[index.row()]

        if role == self.InstallationNameRole:
            return p["installationName"]

        if role == self.PreviewRole:
            return p["previewInstallation"]

        if role == self.CreatedRole:
            return p["created"]

        if role == self.LastSavedRole:
            return p["last_saved"]

        if role == self.IdRole:
            return p["id_uuic"]

        if role == self.AutoLoadRole:
            return p["check_auto_load"]

        if role == self.ProjectFileRole:
            return p["project_file"]

        if role == self.IsActivateProject:
            return p["isActivateProject"]

        if role == self.TypeInstallation:
            return p["typeInstallation"]

        if role == self.NumberINF:
            return p["numberINF"]

    # -------------------------------------------------
    def _reload(self):
        self.beginResetModel()
        self._projects = self._store.projects()
        self._filtered = self._projects.copy()
        self.endResetModel()

    # -------------------------------------------------

    @Slot(str)
    def search(self, text):
        text = text.lower()

        self.beginResetModel()

        if text == "":
            self._filtered = self._projects.copy()

        else:

            self._filtered = [

                p for p in self._projects

                if text in p["installationName"].lower()
            ]

        self.endResetModel()



    # -------------------------------------------------
    @Slot("QVariant")
    def addProject(self, data_dict):
        self._store.add_project(data_dict)

    # -------------------------------------------------
    @Slot(str)
    def removeProject(self, id_uuic):
        self._store.remove_project(id_uuic)

    # -------------------------------------------------
    @Slot(str, bool)
    def setAutoLoad(self, id_uuic, check):
        self._store.set_auto_load(id_uuic, check)

    # -------------------------------------------------
    @Slot(str)
    def setActivateProject(self, id_uuic):
        self._store.activate_project(id_uuic)

    # -------------------------------------------------
    @Slot(result="QVariant")
    def getAutoLoadProject(self):
        project = self._store.get_auto_load_project()
        return project if project else {}

