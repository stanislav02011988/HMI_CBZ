import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects

import qml.settings.menager_theme

import qml.controls.switch

Item {
    id: root
    width: parent.width
    height: parent.height

    Rectangle {
        id: bg
        anchors.fill: parent
        color: "transparent"
        border.color: "#999"
        border.width: 2
        radius: 6

        // // Тень (опционально)
        layer.enabled: true
        layer.effect: DropShadow {
            color: "#40000000"
            radius: 8
            samples: 16
            verticalOffset: 2
        }

        Rectangle {
            id: container_menu
            width: bg.width / 2
            Layout.fillHeight: true
            anchors{
                left: bg.left
                top: bg.top
            }
            color: "transparent"

            MenuBar {
                id: menuBar
                anchors.fill: parent

                signal menuActionTriggered(string action)

                background: Rectangle {
                    color: "transparent"
                }

                Menu { title: "Файл"
                    MenuItem { text: "Новый"; onTriggered: menuBar.menuActionTriggered("file_new") }
                    MenuItem { text: "Открыть"; onTriggered: menuBar.menuActionTriggered("file_open") }
                    MenuItem { text: "Выход"; onTriggered: menuBar.menuActionTriggered("file_exit") }
                }

                Menu { title: "Правка 1"
                    MenuItem { text: "Копировать"; onTriggered: menuBar.menuActionTriggered("edit_copy") }
                    MenuItem { text: "Вставить"; onTriggered: menuBar.menuActionTriggered("edit_paste") }
                }

                Menu { title: "Правка 2"
                    MenuItem { text: "Копировать"; onTriggered: menuBar.menuActionTriggered("edit_copy") }
                    MenuItem { text: "Вставить"; onTriggered: menuBar.menuActionTriggered("edit_paste") }
                }

                Menu { title: "Правка 3"
                    MenuItem { text: "Копировать"; onTriggered: menuBar.menuActionTriggered("edit_copy") }
                    MenuItem { text: "Вставить"; onTriggered: menuBar.menuActionTriggered("edit_paste") }
                }

                Menu { title: "Правка 4"
                    MenuItem { text: "Копировать"; onTriggered: menuBar.menuActionTriggered("edit_copy") }
                    MenuItem { text: "Вставить"; onTriggered: menuBar.menuActionTriggered("edit_paste") }
                }

                delegate: MenuBarItem {
                    id: menuBarItem
                    contentItem: Text {
                        text: menuBarItem.text
                        font: menuBarItem.font
                        opacity: enabled ? 1.0 : 0.3
                        color: menuBarItem.highlighted ? "#ffffff" : "black"
                        horizontalAlignment: Text.AlignVCenter
                        verticalAlignment: Text.AlignVCenter
                        elide: Text.ElideRight
                    }

                    background: Rectangle {
                        width: menuBarItem.width
                        height: root.height - 6
                        opacity: enabled ? 1 : 0.3
                        radius: 4
                        color: menuBarItem.highlighted ? "#21be2b" : "transparent"
                    }
                }
            }
        }

        Rectangle {
            width: 100
            height: bg.height
            anchors{
                right: bg.right
                top: bg.top
            }
            color: "transparent"

            RowLayout {
                spacing: 5
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter

                Text {
                    text: QmlMenagerTheme.name_theme
                    font.family: "Times New Roman"
                    font.bold: true
                    font.pointSize: 14
                    verticalAlignment: Text.AlignVCenter
                    color: "black"
                }

                CustomSwitch {
                    id: themeSwitch

                    // Привязка состояния из менеджера темы
                    checked: QmlMenagerTheme ? QmlMenagerTheme.name_theme === "dark" : false

                    // Кастомные цвета (опционально)
                    trackColorOn: "#21be2b"
                    trackColorOff: "#aaaaaa"

                    // Реакция на переключение
                    onToggled: (newChecked) => {
                        if (QmlMenagerTheme) {
                            QmlMenagerTheme.toggleTheme()
                        }
                    }
                }
            }
        }
    }
}
