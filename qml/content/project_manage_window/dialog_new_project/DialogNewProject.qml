// qml\content\project_logic_manage_window\dialog_new_project_logic\DialogNewProjectLogic.qml
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs
import QtQuick.Controls.Material

import qml.settings.project_settings
import qml.managers

Popup {
    id: root
    width: 400
    height: 600
    modal: true
    focus: true
    background: Rectangle {
        color: "white"
        radius: 8
        border.color: "#555"
        border.width: 1
    }

    property string pathPreviewImageInstallation: ""

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 12

        Text {
            text: "Создать новый проект"
            color: "black"
            font.bold: true
            font.pixelSize: 14
            horizontalAlignment: Text.AlignHCenter
            Layout.alignment: Qt.AlignHCenter
        }

        TextField {
            id: inputInstallationName
            placeholderText: "Введите название установки"
            Layout.fillWidth: true
            font.pixelSize: 12
        }

        TextField {
            id: inputTypeInstallation
            placeholderText: "Введите тип установки"
            Layout.fillWidth: true
            font.pixelSize: 12
        }

        TextField {
            id: inputNumberINF
            placeholderText: "Введите инвентарный номер установки"
            Layout.fillWidth: true
            font.pixelSize: 12
        }

        TextField {
            id: inputNumberInstallation
            placeholderText: "Введите заводской номер установки"
            Layout.fillWidth: true
            font.pixelSize: 12
        }

        TextField {
            id: inputYearInstallation
            placeholderText: "Введите год производства установки"
            Layout.fillWidth: true
            font.pixelSize: 12
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            Image {
                id: previewImageInstallation
                Layout.fillHeight: true
                Layout.fillWidth: true
                source: pathPreviewImageInstallation
                fillMode: Image.PreserveAspectFit
                // visible: model.previewInstallation !== undefined && model.previewInstallation !== ""
            }

            Button {
                text: "..."
                onClicked: fileImageDialog.open()
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            TextField {
                id: inputProjectPath
                placeholderText: "Выберите путь"
                Layout.fillWidth: true
                font.pixelSize: 12
            }

            Button {
                text: "..."
                onClicked: folderDialog.open()
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            Button {
                text: "Создать"
                Layout.alignment: Qt.AlignRight
                onClicked: {
                    if (inputInstallationName.text === "" || inputProjectPath.text === "") return
                    QmlProjectManager.createProject(createProjectInstallation())
                    root.close()
                }
            }

            Button {
                text: "Отмена"
                Layout.alignment: Qt.AlignRight
                onClicked: root.close()
            }
        }
    }

    function createProjectInstallation(){
        var data = {
            installationName: inputInstallationName.text,
            typeInstallation: inputTypeInstallation.text,
            numberINF: inputNumberINF.text,
            numberInstallation: inputNumberInstallation.text,
            yearInstallation: inputYearInstallation.text,
            projectPath: inputProjectPath.text,
            previewInstallation: root.pathPreviewImageInstallation,
            user: QmlProjectSettings.last_name + " " + QmlProjectSettings.first_name + " " + QmlProjectSettings.second_name,
            position_users: QmlProjectSettings.position_users
        }
        return data
    }

    FolderDialog {
        id: folderDialog
        title: "Выберите папку для проекта"
        onAccepted: {
            if (folderDialog.selectedFolder !== undefined && folderDialog.selectedFolder !== "") {
                inputProjectPath.text = folderDialog.selectedFolder
            }
        }
    }

    FileDialog {
        id: fileImageDialog
        title: "Выберите папку для проекта"
        onAccepted: {
            if (fileImageDialog.selectedFile !== undefined && fileImageDialog.selectedFile !== "") {
                pathPreviewImageInstallation = fileImageDialog.selectedFile
            }
        }
    }
}
