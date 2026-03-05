import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects

import qml.managers
import qml.settings.project_settings
import qml.settings.menager_theme
import qml.utils.menadger_windows

import qml.controls.switch
import qml.controls.menu_bar

Item {
    id: root
    width: parent.width
    height: parent.height

    property color colorDefault: "#67aa25"
    property color colorMouseOver: "#7ece2d"
    property color colorPressed: "#558b1f"

    Rectangle {
        id: bg
        anchors.fill: parent
        color: "transparent"
        border.color: "#504e4e"
        border.width: 1
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

            CustomMenuBar {
                id: topBar
                height: bg.height
                Layout.fillWidth: true
                Layout.fillHeight: true
                accessUser: QmlProjectSettings.access_group
                onMenuActionTriggered: (action) => {
                    switch (action) {
                        case "file_new":
                            console.log("Создать новый файл")
                            // сюда код для нового файла
                            break

                        case "file_open":
                            console.log("Открыть файл")
                            // сюда код для открытия файла
                            break

                        case "file_exit":
                            Qt.quit()
                            break

                        case "edit_mode_scene":
                            QmlSceneManager.activateEditMode()
                            break

                        case "logic_map":
                            MenagerWindows.showWindow("qrc:/qml/content/logic_window/logic/LogicMapWindow.qml")
                            break

                        case "edit_mode_logic":
                            MenagerWindows.showWindow("qrc:/qml/content/logic_window/edit_logic/EditLogicMapWindow.qml")
                            break

                        default:
                            console.log("Неизвестное действие:", action)
                            break
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
