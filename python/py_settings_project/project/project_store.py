# python\py_settings_project\project\project_store.py
import shutil
from pathlib import Path
from datetime import datetime

from PySide6.QtCore import QObject, Signal
from PySide6.QtQml import QJSValue

class ProjectStore(QObject):

    projectsChanged = Signal()

    def __init__(self, json_manager, file_path, file_name, parent=None):
        super().__init__(parent)

        self._json_manager = json_manager
        self._file_path = file_path
        self._file_name = file_name

        self._settings = {}
        self._projects = []

    # -------------------------------------------------

    def load(self, settings):
        self._settings = settings
        self._projects = settings.get("projects", [])

        self.projectsChanged.emit()

    # -------------------------------------------------

    def projects(self):
        return self._projects

    # -------------------------------------------------
    def _save(self):
        self._settings["projects"] = self._projects

        self._json_manager.write_json_file(
            path_folder=self._file_path,
            file_name=self._file_name,
            items=self._settings
        )

        self.projectsChanged.emit()


    def reload(self):
        self._reload()

    # -------------------------------------------------
    def add_project(self, dict_data):
        try:
            # Приводим данные к dict
            if isinstance(dict_data, QJSValue):
                data = dict_data.toVariant()
            else:
                data = dict_data  # <-- важно, иначе data не существует

            # Проверка на словарь
            if not isinstance(data, dict):
                print("[ProjectStore] invalid project data:", data)
                return

            # Добавляем в список созданных проектов
            project = {
                "id_uuic": data.get("id_uuic"),
                "installationName": data.get("installationName", "Новый проект"),
                "typeInstallation": data.get("typeInstallation"),
                "numberINF": data.get("numberINF"),
                "numberInstallation": data.get("numberInstallation"),
                "yearInstallation": data.get("yearInstallation"),
                "project_file": data.get("project_file"),
                "previewInstallation": data.get("previewInstallation"),
                "user": data.get("user"),
                "position_users": data.get("position_users"),
                "created": data.get("created") or datetime.now().isoformat(),
                "last_saved": data.get("last_saved") or datetime.now().isoformat(),
                "check_auto_load": False,
                "isActivateProject": False
            }

            # Добавляем проект в список
            self._projects.append(project)

            # Сохраняем настройки
            self._save()

            print("[ProjectStore] project added:", project["installationName"])

        except Exception as e:
            print("[ProjectStore][ERR] add_project:", e)



    # -------------------------------------------------
    def remove_project(self, id_uuic):
        project = None

        for p in self._projects:
            if p["id_uuic"] == id_uuic:
                project = p
                break

        if not project:
            return False

        path = project.get("project_file")

        if path:
            p = Path(path)
            if p.exists():

                if p.is_file():
                    p.unlink()

                if p.is_dir():
                    shutil.rmtree(p)

        self._projects.remove(project)

        self._save()

        return True



    # -------------------------------------------------
    def set_auto_load(self, id_uuic, check):
        for p in self._projects:
            if p["id_uuic"] == id_uuic:
                p["check_auto_load"] = check
            else:
                p["check_auto_load"] = False

        self._save()


    # -------------------------------------------------
    def activate_project(self, id_uuic):
        for p in self._projects:
            if p["id_uuic"] == id_uuic:
                p["isActivateProject"] = True
            else:
                p["isActivateProject"] = False

        self._save()

    # -------------------------------------------------
    def get_auto_load_project(self):
        for p in self._projects:
            if p.get("check_auto_load"):
                # делаем активным
                self.activate_project(p["id_uuic"])
                return {
                    "id_uuic": p["id_uuic"],
                    "projectPath": p.get("project_file", ""),
                    "isActivateProject": True
                }

        return None


