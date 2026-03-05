import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Controls.Material

Rectangle {

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
            text: "Run Mode"
        }

        Button {
            text: "Close"
            onClicked: Qt.quit()
        }
    }
}
