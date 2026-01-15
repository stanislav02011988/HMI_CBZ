import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: root
    width: parent ? parent.width : 800
    height: parent ? parent.height : 800

    property int font_text: 10

    property string name_installation
    property string type_installation
    property string version_manuals
    property string path_manuals

    // --- Сигнал для родителя ---
    signal menuActionTriggered(string action)

    property int border_radius: 0

    Rectangle {
        id: bg
        anchors.fill: parent
        color: "#eeeeee"
        border.color: "#898989"
        border.width: 1
        radius: root.border_radius

        // --- Меню слева ---
        MenuBar {
            id: menuBar

            signal menuActionTriggered(string action)

            anchors.leftMargin: 1
            anchors.rightMargin: 1
            anchors.topMargin: 1
            anchors.bottomMargin: 1

            Menu { title: "Файл"
                MenuItem { text: "Новый"; onTriggered: menuBar.menuActionTriggered("file_new") }
                MenuItem { text: "Открыть"; onTriggered: menuBar.menuActionTriggered("file_open") }
                MenuItem { text: "Выход"; onTriggered: menuBar.menuActionTriggered("file_exit") }
            }

            Menu { title: "Правка"
                MenuItem { text: "Копировать"; onTriggered: menuBar.menuActionTriggered("edit_copy") }
                MenuItem { text: "Вставить"; onTriggered: menuBar.menuActionTriggered("edit_paste") }
            }

            Menu { title: "Документация"
                MenuItem {
                    text: "Открыть руководство" + " " + root.name_installation + " " + root.type_installation + "ver." + root.version_manuals
                    // onTriggered: pyPdfOpener.openPdf("qrc:/manuals/resources/manuals/extec/x44/X44-RU-10401.pdf")
                }
            }

            delegate: MenuBarItem {
                id: menuBarItem

                contentItem: Text {
                    text: menuBarItem.text
                    font: menuBarItem.font
                    opacity: enabled ? 1.0 : 0.3
                    color: menuBarItem.highlighted ? "#ffffff" : "#21be2b"
                    horizontalAlignment: Text.AlignVCenter
                    verticalAlignment: Text.AlignVCenter
                    elide: Text.ElideRight
                }

                background: Rectangle {
                    implicitWidth: 40
                    implicitHeight: root.height
                    opacity: enabled ? 1 : 0.3
                    color: menuBarItem.highlighted ? "#21be2b" : "transparent"
                }
            }

            background: Rectangle {
                implicitWidth: root.width
                implicitHeight: root.height
                color: "transparent"

                Rectangle {
                    color: "transparent"
                    width: parent.width
                    height: 1
                    anchors.bottom: parent.bottom
                }
            }
        }

        Rectangle {
            id: container_btn
            x: 271
            width: 100
            color: "transparent"
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.rightMargin: 0
            anchors.topMargin: 0
            anchors.bottomMargin: 0

            // --- Переключатель темы справа ---
            RowLayout {
                spacing: 5
                anchors.verticalCenter: parent.verticalCenter

                Text {
                    // text: isRuntimeM ? AppTheme.currentTheme : "light"
                    verticalAlignment: Text.AlignVCenter
                    // color: isRuntimeM ? AppTheme.text : "black"
                }

                Switch {
                    implicitWidth: 40
                    implicitHeight: 40
                    // checked: AppTheme ? AppTheme.currentTheme === "dark" : false
                    // onToggled: {
                    //     if (AppTheme) AppTheme.toggleTheme()
                    // }
                }
            }
        }
    }
}
