import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import qml.managers
import qml.settings.project_settings

import qml.content.main_window.top_bar
import qml.content.main_window.top_bar_button
import qml.content.main_window.center_widget



Window {
    id: root
    minimumWidth: 1000
    minimumHeight: 600
    title: qsTr("Главное окно")
    visible: true
    color: "#00ffffff"

    visibility: Window.Maximized

    // flags: Qt.Window | Qt.WindowTitleHint | Qt.WindowSystemMenuHint | Qt.WindowMinimizeButtonHint | Qt.WindowCloseButtonHint

    Rectangle {
        id: bg
        color: "#dfd8d8"
        anchors.fill: parent

        ColumnLayout {
            id: layoutContent
            anchors.fill: parent
            anchors{
                leftMargin: 4
                topMargin: 4
                rightMargin: 4
                bottomMargin: 4
            }

            LayoutItemProxy {
                target: customTopBarButton
                height: 40
                Layout.fillWidth: true
            }

            LayoutItemProxy {
                target: customTopBar
                height: 50
                Layout.fillWidth: true
            }

            LayoutItemProxy {
                target: centerWidget
                Layout.fillWidth: true
                Layout.fillHeight: true
            }

            LayoutItemProxy {
                target: panelControls
                height: 100
                Layout.fillWidth: true
            }

            LayoutItemProxy {
                target: bottom_bar
                height: 40
                Layout.fillWidth: true
            }
        }
    }

    CustomTopBarButton {
        id: customTopBarButton
        parent: parent
    }

    CustomTopBar { id: customTopBar }

    CenterWidget { id: centerWidget; anchors.fill: parent }

    Rectangle { id: panelControls; color: "green";}

    Rectangle {
        id: bottom_bar

        color: "yellow"

        Label {
            id: label3
            text: qsTr("Статус бар")
            anchors.fill: parent
            horizontalAlignment: Text.AlignHCenter
        }
    }
}
