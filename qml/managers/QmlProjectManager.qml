// qml\managers\QmlProjectManager.qml
pragma Singleton
import QtQuick

import qml.settings.project_settings
import qml.managers

import python.py_project_manager.interface_in_qml

QtObject {
    id: root

    //---- Данные установки (завода) "meta"
    property string id_uuic: ProjectManager.itemsProjectData.meta?.id_uuic || ""
    property string nameProject: ProjectManager.itemsProjectData.meta?.nameProject || ""
    property string installationName: ProjectManager.itemsProjectData.meta?.installationName || ""
    property string typeInstallation: ProjectManager.itemsProjectData.meta?.typeInstallation || ""
    property string numberINF: ProjectManager.itemsProjectData.meta?.numberINF || ""
    property string numberInstallation: ProjectManager.itemsProjectData.meta?.numberInstallation || ""
    property string yearInstallation: ProjectManager.itemsProjectData.meta?.yearInstallation || ""

    //======== Данные Проектов    
    property var dataElementScaene: ProjectManager.itemsProjectData.scene ? ProjectManager.itemsProjectData.scene : ({})
    property var dataCameraScaene: ProjectManager.itemsProjectData.scene ? ProjectManager.itemsProjectData.scene : ({})

    //======== Сохранение и Загрузка данных Центральной Сцены Элементов QmlProjectSettings ========
    function saveSceneElements(dict_scene){ ProjectManager.save_scene_elements(dict_scene) }
    function updateSceneOneElement (id_widget, dict_scene) { ProjectManager.update_scene_element(id_widget, dict_scene) }

    //======== Сохранение и Загрузка данных камеры сцены и зум QmlProjectSettings =====================================
    function loadCameraParams() { return ProjectManager.load_camera_params() }
    function saveCameraParams(cameraData) { ProjectManager.save_camera_params(cameraData) }
    function resetCameraParams() { return ProjectManager.reset_camera_params() }

    function createProject(dict) {
        QmlProjectSettings.model.addProject(ProjectManager.create_project(dict))
    }

    function loadProject(id_uuic, projectFilePath) {
        ProjectManager.loadProject(projectFilePath)
        QmlProjectSettings.model.setActivateProject(id_uuic)
    }
    
    function removeProject(id_uuic){
        QmlSceneManager.clearScene()
        QmlProjectSettings.model.removeProject(id_uuic)
    }

    //============ Модлель данных для древа проекта =======================
    property var treeViewModel: ProjectManager.tree_view_model ? ProjectManager.tree_view_model : ({})
    function getDataProgramsProject(namePrograms) { return ProjectManager.get_data_programs_project(namePrograms) }

    //======== Сохранение и Загрузка СЦЕНЫ КАРТЫ ЛОГИКИ Программы=====================================
    function addNewFileProgramsProject(namePrograms) {return ProjectManager.add_new_file_programs_project(namePrograms)}
    function loadCameraParamsSceneLogicMap(nameProgram) { return ProjectManager.load_camera_params_scenelogic_map(nameProgram) }
    function saveElementSceneLogicMap(nameProgram, dict_scene) { ProjectManager.save_elements_scene_logic_map(nameProgram, dict_scene)}
    function saveCameraParamsSceneLogicMap (nameProgram, cameraData) { ProjectManager.save_camera_params_scene_logic_map(nameProgram, cameraData) }
    function updateSceneOneElementLogicMap (nameProgram, id_widget, dict_scene) { ProjectManager.update_scene_one_element_logic_map(nameProgram, id_widget, dict_scene) }
    function removeProgramm(nameProgram) { ProjectManager.remove_programm(nameProgram) }

    Component.onCompleted: {
        var project = QmlProjectSettings.model.getAutoLoadProject()
        if(project.projectPath){
            ProjectManager.loadProject(project.projectPath)
        }
    }
}
