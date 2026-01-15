import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import qml.windows.main_window.component.top_bar

Window {
    id: root
    minimumWidth: 1000
    minimumHeight: 600
    title: qsTr("Главное окно")
    visible: false    
    color: "#00ffffff"

    // flags: Qt.Window | Qt.WindowTitleHint | Qt.WindowSystemMenuHint | Qt.WindowMinimizeButtonHint | Qt.WindowCloseButtonHint

    Component.onCompleted: {
        root.showMaximized()
    }

    Rectangle {
        id: bg
        color: "transparent"
        anchors.fill: parent

        ColumnLayout {
            id: layoutContent
            anchors.fill: parent
            anchors.margins: 2

            LayoutItemProxy {
                target: customMenuBar
                height: 45
                Layout.fillWidth: true
            }

            LayoutItemProxy {
                target: secondBar
                height: 40
                Layout.fillWidth: true
            }

            LayoutItemProxy {
                target: mainContent
                Layout.fillWidth: true
                Layout.fillHeight: true
            }

            LayoutItemProxy {
                target: bottom_bar
                height: 40
                Layout.fillWidth: true
            }
        }
    }

    CustomTopBar {
        id: customMenuBar
        border_radius: 6
    }

    Rectangle {
        id: secondBar

        color: "red"

        Label {
            id: label1
            text: qsTr("Доп меню")
            anchors.fill: parent
            horizontalAlignment: Text.AlignHCenter
        }
    }

    Rectangle {
        id: mainContent
        Layout.fillWidth: true
        Layout.fillHeight: true
        color: "green"

        Label {
            id: label2
            text: qsTr("Основной контейнер")
            anchors.fill: parent
            horizontalAlignment: Text.AlignHCenter
        }
    }

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
