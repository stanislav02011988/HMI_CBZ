import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects

import qml.content.main_window.top_bar.conteiner_clock
import qml.content.main_window.top_bar.conteiner_day
import qml.content.main_window.top_bar.conteiner_data_installation
import qml.content.main_window.top_bar.conteiner_data_user

Item {
    id: root
    width: parent
    height: parent

    Rectangle {
        id: bg
        anchors.fill: parent
        color: "transparent"
        border.color: "#00999999"
        border.width: 1
        radius: 0

        layer.enabled: true
        layer.effect: DropShadow {
            color: "#40000000"
            radius: 8
            samples: 16
            verticalOffset: 2
        }

        RowLayout {
            id: rowLayoutContainer
            anchors.fill: parent
            spacing: 5

            ConteinerClock {}

            ConteinerDay {}            

            ConteinerDataUser {}

            ConteinerDataInstallation {}

            Item {
                // color: "#00ffffff"
                // radius: 4
                // border.color: "transparent"
                // border.width: 1

                Layout.fillHeight: true
                Layout.fillWidth: true
            }
        }
    }
}

