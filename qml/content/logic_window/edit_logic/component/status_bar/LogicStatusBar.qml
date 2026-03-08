// qml\content\logic_window\edit_logic\component\status_bar\LogicStatusBar.qml
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {

    color: "#2b2d30"

    RowLayout {
        anchors.fill: parent
        anchors.margins: 8

        Label {
            text: "Zoom: 100%"
            color: "#aaa"
        }

        Label {
            text: "Blocks: 0"
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
