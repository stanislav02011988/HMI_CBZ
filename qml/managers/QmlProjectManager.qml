// qml\managers\QmlProjectManager.qml
pragma Singleton
import QtQuick

import qml.settings.project_settings
import qml.managers

import python.py_project_manager.interface_in_qml
import python.py_settings_project.interface_settings_project

QtObject {
    id: root
    signal signalAddedProject()

    function createProject(dict) {
        var data = ProjectManager.create_project(dict)
        SettingsProject.add_project(data)
    }

    function loadProject(projectFilePath) {
        ProjectManager.loadProject(projectFilePath)
        QmlSceneManager.loadScene()
    }

    //---- Данные установки (завода)
    property var dict: ProjectManager.itemsProjectData ? ProjectManager.itemsProjectData : ({})

    property string id_uuic: ProjectManager.itemsProjectData?.id_uuic || ""
    property string installationName: ProjectManager.itemsProjectData?.installationName || ""
    property string typeInstallation: ProjectManager.itemsProjectData?.typeInstallation || ""
    property string numberINF: ProjectManager.itemsProjectData?.numberINF || ""
    property string numberInstallation: ProjectManager.itemsProjectData?.numberInstallation || ""
    property string yearInstallation: ProjectManager.itemsProjectData?.yearInstallation || ""

    property var dataElementScaene: ProjectManager.itemsProjectData.scene ? ProjectManager.itemsProjectData.scene : ({})
    property var dataCameraScaene: ProjectManager.itemsProjectData.scene ? ProjectManager.itemsProjectData.scene : ({})

    //======== Сохранение и Загрузка данных Центральной Сцены Элементов QmlProjectSettings ========
    function saveSceneElements(dict_scene){ ProjectManager.save_scene_elements(dict_scene) }
    function updateSceneOneElement (id_widget, dict_scene) { ProjectManager.update_scene_element(id_widget, dict_scene) }

    //======== Сохранение и Загрузка данных камеры сцены и зум QmlProjectSettings =====================================
    function loadCameraParams() { return ProjectManager.load_camera_params() }
    function saveCameraParams(cameraData) { ProjectManager.save_camera_params(cameraData) }
    function resetCameraParams() { return ProjectManager.reset_camera_params() }
}
