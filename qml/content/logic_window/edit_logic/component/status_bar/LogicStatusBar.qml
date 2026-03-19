// qml\content\logic_window\edit_logic\component\status_bar\LogicStatusBar.qml
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import qml.managers
import qml.registers

Item {
    id: root

    property real zoomScene: QmlLogicMapScene.zoomLogicScene
    property int countElementsScene: QmlRegisterComponentLogicMap.count

    Rectangle {
        anchors.fill: parent
        color: "#2b2d30"

        RowLayout {
            anchors.fill: parent
            anchors.margins: 8

            Label {
                text: `Zoom: ${Math.round(root.zoomScene * 100)}%`
                color: "#aaa"
            }

            Label {
                text: `Blocks: ${root.countElementsScene}`
                color: "#aaa"
            }

            Label {
                text: "Connections: 0"
                color: "#aaa"
            }

            Item { Layout.fillWidth: true }

            Label {
                text: "Saved"
                color: "#4caf50"
            }
        }
    }
}
