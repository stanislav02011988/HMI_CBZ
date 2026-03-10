// OperatingMode.qml
import QtQuick
import QtQuick.Controls

import qml.managers
import qml.settings.project_settings
import qml.controls.elements_scene
import qml.content.main_window.center_widget.modes.edit_mode

Item {
    id: root
    anchors.fill: parent

    property bool editMode: false

    // ==============================
    // Параметры камеры
    // ==============================
    property real zoom: 1.0
    property real minZoom: 0.2
    property real maxZoom: 5.0

    property real offsetX: 0
    property real offsetY: 0

    // === ДОБАВИТЬ: доступ из QmlSceneManager ===
    property alias viewport: viewport
    property alias world: world

    // ==============================
    // VIEWPORT
    // ==============================
    Item {
        id: viewport
        anchors.fill: parent
        clip: true

        // ==========================
        // WORLD (двигаем и масштабируем)
        // ==========================
        // ==========================
        // WORLD
        // ==========================
        Item {
            id: world
            x: root.offsetX
            y: root.offsetY
            width: viewport.width
            height: viewport.height
            scale: root.zoom
            transformOrigin: Item.TopLeft
        }
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
            sceneContainer: world
            sceneController: root
        }
    }

    // ============================================================
    // ИНИЦИАЛИЗАЦИЯ
    // ============================================================
    Component.onCompleted: {
        QmlSceneManager.configure({
            sceneController: root,
            sceneContainer: world,
            wrapperComponent: wrapperComponent,
            previewComponents: previewComponents,
            editMode: root.editMode
        })
        QmlSceneManager.loadScene()
    }

    // ============================================================
    // РАМКА РЕЖИМА (для визуального отличия edit режима)
    // ============================================================
    Rectangle {
        anchors.fill: parent
        color: "transparent"
        border.color: "gray"
        border.width: 1
        radius: 4
        z: 1000
    }
}
