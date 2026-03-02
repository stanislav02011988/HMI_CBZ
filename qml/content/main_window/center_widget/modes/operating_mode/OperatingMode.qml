// OperatingMode.qml
import QtQuick
import QtQuick.Controls

import qml.settings.project_settings
import qml.managers
import qml.content.main_window.center_widget.modes.edit_mode.dialog_add_elements.element_preview
import "../edit_mode/edit_mode_internal"

Item {
    id: root
    anchors.fill: parent

    property bool editMode

    Item {
        id: sceneContainer
        anchors.fill: parent
    }

    // =========================================================================
    // ПРЕВЬЮ КОМПОНЕНТОВ
    // =========================================================================
    PreviewComponents { id: previewComponents }

    // =========================================================================
    // КОМПОНЕНТ ОБЁРТКИ
    // =========================================================================
    Component {
        id: wrapperComponent
        EditableItem {
            editMode: root.editMode
        }
    }

    Component.onCompleted: {
        QmlSceneManager.configure({
            componentRegister: QmlRegisterComponentObject,
            projectSettings: QmlProjectSettings,
            sceneContainer: sceneContainer,
            wrapperComponent: wrapperComponent,
            previewComponents: previewComponents,
            editModeRoot: root,
            editMode: root.editMode
        })

        QmlSceneManager.loadScene()
    }
}
