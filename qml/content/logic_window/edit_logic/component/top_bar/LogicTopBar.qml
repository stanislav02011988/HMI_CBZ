// content\logic_window\edit_logic\component\top_bar\LogicTopBar.qml
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Controls.Material

Item {
    id: root


    Rectangle {
        anchors.fill: parent
        color: "#81848c"

        RowLayout {
            anchors.fill: parent
            anchors.margins: 10

            Label {
                text: "Logic Map"
                font.pixelSize: 18
                color: "white"
            }

            Item { Layout.fillWidth: true }

            Button {
                Layout.fillHeight: true
                Layout.preferredWidth: 150
                text: "Run Mode"
            }

            Button {
                Layout.fillHeight: true
                Layout.preferredWidth: 150
                text: "Close"
                onClicked: Qt.quit()
            }
        }
    }
}
