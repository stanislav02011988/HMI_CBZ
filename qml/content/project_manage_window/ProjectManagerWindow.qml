// qml/windows/ProjectManagerWindow.qml
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import qml.settings.project_settings
import qml.managers
import "./dialog_new_project"

Window {
    id: root
    width: 1200
    height: 800
    visible: true
    title: "Project Manager"
    color: "#666"

    ProjectModel { id: projectModel }

    ColumnLayout {
        anchors.fill: parent
        spacing: 8

        RowLayout {
            Layout.fillWidth: true
            spacing: 8
            height: 40

            Button { text: "Новый проект"; onClicked: dialogNewProject.open() }
            TextField {
                id: searchField
                Layout.fillWidth: true
                placeholderText: "Поиск..."
                onTextChanged: {
                    searchDelay.restart()
                }
            }
        }

        GridView {
            id: gridProjects
            Layout.fillWidth: true
            Layout.fillHeight: true
            model: projectModel.visibleProjects
            cellWidth: 250
            cellHeight: 200
            clip: true
            cacheBuffer: 800

            delegate: ProjectDelegate {
                projectData: modelData
                onEditRequested: (path) => { root.applyProject(path) }
                onDeleteRequested: QmlProjectManager.removeProject(modelData.id_uuic)
            }
        }
    }

    Timer {
        id: searchDelay
        interval: 200
        repeat: false
        onTriggered: projectModel.search(searchField.text)
    }

    DialogNewProject {
        id: dialogNewProject
        modal: true
    }

    function applyProject(path) {
        QmlProjectManager.loadProject(path)
        root.close()
    }

    function loadDataProject() {
        projectModel.clear()

        // берем проекты из Python QmlProjectManager
        var projects = QmlProjectSettings.listProjects || []

        if (!projects || projects.length === 0) {
            projectModel.appendProjects([{
                id_uuic: "",
                installationName: "",
                typeInstallation: "",
                numberINF: "",
                numberInstallation: "",
                yearInstallation: "",
                project_file: "",
                previewInstallation: "",
                user: "",
                position_users: "",
                created: "",
                last_saved: ""
            }])
        } else {
            projectModel.appendProjects(projects)
        }
    }

    // Вызываем при старте окна
    Component.onCompleted: {
        loadDataProject()
    }
}
