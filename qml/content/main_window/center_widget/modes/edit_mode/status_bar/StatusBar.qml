// qml\content\main_window\center_widget\modes\edit_mode\status_bar\StatusBar.qml
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import qml.registers

Item {
    id: root

    Layout.fillWidth: true
    height: 30

    property real zoomScene
    property int countElementsScene: QmlRegisterComponentObject.count
    property string stateSaveFile: QmlRegisterComponentObject.isDirty ? "No Saved" : "Saved"

    Rectangle {
        anchors.fill: parent
        color: "#2b2d30"
        radius: 4

        RowLayout {
            anchors.fill: parent
            anchors.margins: 5
            spacing: 10

            Label {
                text: `Zoom: ${Math.round(root.zoomScene * 100)}%`
                color: "#aaa"
            }

            Label {
                text: `Blocks: ${root.countElementsScene}`
                color: "#aaa"
            }

            Item { Layout.fillHeight: true; Layout.fillWidth: true }

            Label {
                text: root.stateSaveFile
                color: "#4caf50"
            }
        }
    }
}


