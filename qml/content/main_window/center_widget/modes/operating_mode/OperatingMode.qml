// OperatingMode.qml
import QtQuick
import QtQuick.Controls

import qml.settings.project_settings
import qml.managers
import qml.content.main_window.center_widget.modes.edit_mode.dialog_add_elements.element_preview
import qml.content.main_window.center_widget.modes.edit_mode

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

    // ============================================================
    // ИНИЦИАЛИЗАЦИЯ
    // ============================================================
    Component.onCompleted: {
        QmlSceneManager.configure({
            sceneController: root,
            sceneContainer: sceneContainer,
            wrapperComponent: wrapperComponent,
            previewComponents: previewComponents,            
            editMode: root.editMode
        })

        QmlSceneManager.loadScene()
    }
}
