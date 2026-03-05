import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {

    color: "#81848c"

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 8

        Label {
            text: "Properties"
            font.pixelSize: 16
            color: "white"
        }

        Rectangle {

            Layout.fillWidth: true
            Layout.fillHeight: true
            radius: 6
            color: "#2d2f33"

            Label {
                anchors.centerIn: parent
                text: "Selected Block Properties"
                color: "#888"
            }
        }
    }
}
