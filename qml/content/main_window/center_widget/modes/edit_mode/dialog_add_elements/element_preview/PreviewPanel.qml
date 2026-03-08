// qml.content.main_window.main_window_widgets.center_widget.modes.edit_mode.dialog_add_elements.element_preview/PreviewPanel.qml
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import qml.controls.elements_scene

ColumnLayout {
    id: root
    Layout.preferredWidth: 300
    Layout.fillHeight: true

    property bool isVisible: false
    property string selectedSubtypeId: ""

    property string elementName: ""
    onElementNameChanged: {
        if (previewLoader.item && previewLoader.item.hasOwnProperty("name_widget")) {
            previewLoader.item.name_widget = elementName
        }
    }
    property string levelSilos: ""
    onLevelSilosChanged: {
        if (previewLoader.item && previewLoader.item.hasOwnProperty("level_silos")) {
            previewLoader.item.level_silos = levelSilos
        }
    }

    visible: root.isVisible

    PreviewComponents { id: previewComponents }

    Label {
        text: "Предпросмотр элемента"
        font.bold: true
        font.pixelSize: 16
        color: "white"
        Layout.topMargin: 5
    }

    Rectangle {
        Layout.fillWidth: true
        Layout.fillHeight: true
        color: "#252525"
        radius: 8
        border.color: "#444444"
        border.width: 1

        Loader {
            id: previewLoader
            anchors.centerIn: parent
            sourceComponent: previewComponents.getPreviewComponent(root.selectedSubtypeId)
            onLoaded: {
                    if (item && item.hasOwnProperty("name_widget")) {
                        item.name_widget = root.elementName
                    }
                    if (item && item.hasOwnProperty("level_silos")) {
                        item.level_silos = root.levelSilos
                    }
                }
            scale: {
                if (!item || !parent) return 1.0

                const maxWidth = parent.width * 0.85
                const maxHeight = parent.height * 0.85

                if (item.implicitWidth <= maxWidth && item.implicitHeight <= maxHeight)
                    return 1.0

                const scaleX = maxWidth / item.implicitWidth
                const scaleY = maxHeight / item.implicitHeight
                return Math.min(scaleX, scaleY)
            }
        }
    }

    function resetPreviewPanel() { root.selectedSubtypeId = ""; previewLoader.scale = 1.0 }
}
