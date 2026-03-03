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
            anchors.fill: parent
            anchors.margins: 30
            sourceComponent: previewComponents.getPreviewComponent(root.selectedSubtypeId)
        }
    }

    function resetPreviewPanel() { root.selectedSubtypeId = "" }
}
