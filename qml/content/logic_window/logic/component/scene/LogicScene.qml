import QtQuick
import QtQuick.Controls

Rectangle {

    color: "#1e1f22"

    Label {
        anchors.centerIn: parent
        text: "Logic Scene (Infinite Canvas)"
        color: "#555"
    }

    Column {

        spacing: 8

        anchors.top: parent.top
        anchors.right: parent.right
        anchors.margins: 10

        Rectangle {

            width: 30
            height: 30
            radius: 4
            color: "#3a3d41"

            Label {
                anchors.centerIn: parent
                text: "S"
                color: "white"
            }
        }

        Rectangle {

            width: 30
            height: 30
            radius: 4
            color: "#3a3d41"

            Label {
                anchors.centerIn: parent
                text: "J"
                color: "white"
            }
        }
    }
}
