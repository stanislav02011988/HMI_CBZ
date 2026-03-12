// CustomTopBar.qml
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import qml.registers

Item {
    id: root
    width: parent ? parent.width : 600
    height: 40

    signal menuActionTriggered(string action)

    property string accessUser: "user"

    // ------------------------------------------------------------
    // БАЗОВОЕ МЕНЮ
    // ------------------------------------------------------------
    property var baseMenuModel: [
        {
            label: "Файл",
            items: [
                { text: "Управление проектами", action: "project_manager_open" },
                { text: "Выход", action: "file_exit" }
            ]
        },
        {
            label: "Справка",
            items: [
                { text: "О программе", action: "help_about" },
                { text: "Руководство пользователя", action: "help_manual" }
            ]
        },
        {
            label: "Диагностика",
            items: [
                { text: "Карта логики", action: "logic_map" }
            ]
        }
    ]

    // ------------------------------------------------------------
    // МЕНЮ РЕДАКТИРОВАНИЯ
    // ------------------------------------------------------------
    property var editMenu: {
        return {
            label: "Режим редактирования",
            items: [
                { text: "Cхемы Сцены", action: "edit_mode_scene" },
                { text: "Cхемы Логики", action: "edit_mode_logic" },
                { text: "Cхемы ПЛК", action: "edit_mode_plc" }
            ]
        }
    }

    // ------------------------------------------------------------
    // ДИНАМИЧЕСКАЯ МОДЕЛЬ (реактивная!)
    // ------------------------------------------------------------
    property var finalMenuModel: []

    onAccessUserChanged: {
        finalMenuModel = accessUser === "admin" ? baseMenuModel.concat([editMenu]) : baseMenuModel
    }

    Component.onCompleted: {
        finalMenuModel = accessUser === "admin" ? baseMenuModel.concat([editMenu]) : baseMenuModel
    }

    RowLayout {
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        spacing: 4

        Repeater {
            model: root.finalMenuModel

            Item {
                Layout.fillHeight: true
                Layout.minimumWidth: labelText.implicitWidth + 24

                Rectangle {
                    id: buttonBg
                    anchors.fill: parent
                    anchors.margins: 4
                    color: mouseArea.containsMouse || popup.opened
                          ? "#21be2b"
                          : "transparent"
                    radius: 4
                    // border.color: "#cccccc"
                    border.color: "transparent"
                    border.width: 1

                    Text {
                        id: labelText  // ← даём id для измерения
                        anchors.centerIn: parent
                        text: modelData.label
                        font.family: "Arial"
                        font.pixelSize: 16
                        color: mouseArea.containsMouse || popup.opened
                               ? "#ffffff"
                               : "#000000"
                    }
                }

                MouseArea {
                    id: mouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: popup.open()
                }

                Popup {
                    id: popup
                    y: parent.height + 2
                    width: 200
                    padding: 0
                    closePolicy: Popup.CloseOnPressOutside

                    background: Rectangle {
                        color: "#ffffff"
                        border.color: "#cccccc"
                        radius: 4
                    }

                    // Сохраняем длину массива items верхнего уровня
                    property int itemCount: modelData.items ? modelData.items.length : 0

                    Column {
                        spacing: 0
                        width: parent.width

                        Repeater {
                            model: modelData.items

                            Rectangle {
                                width: parent.width
                                height: 35
                                color: itemMouse.containsMouse ? "#e0e0e0" : "transparent"
                                radius: 4

                                Text {
                                    anchors.verticalCenter: parent.verticalCenter
                                    x: 12
                                    text: modelData.text
                                    font.family: "Arial"
                                    font.pixelSize: 14
                                    color: "#000000"
                                    elide: Text.ElideRight
                                    width: parent.width - 24
                                }

                                MouseArea {
                                    id: itemMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    onClicked: {
                                        popup.close()
                                        root.menuActionTriggered(modelData.action)
                                    }
                                }
                                //----- Сепораторатор
                                Rectangle {
                                    anchors.bottom: parent.bottom
                                    height: 1
                                    width: parent.width
                                    color: "#dddddd"
                                    // Теперь используем itemCount из Popup
                                    visible: index < popup.itemCount - 1
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
