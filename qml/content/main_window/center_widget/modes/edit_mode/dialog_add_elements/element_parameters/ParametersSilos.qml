// element_parameters/ParametersSilos.qml
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Window 2.15
import QtQuick.Controls.Material 2.15

ColumnLayout {
    id: root
    Layout.fillWidth: true
    spacing: 16

    property var formData: ({ name: "", id: "", motorId: "" })
    property real levelPreSilos: 0
    property var silosSubtypesModel: null
    property string selectedSubtype: ""
    property int selectedSubtypeIndex: -1

    // НАЗВАНИЕ
    ColumnLayout {
        Layout.fillWidth: true
        spacing: 6
        Label { text: "Название элемента *"; color: "#bbbbbb"; font.pixelSize: 13 }
        TextField {
            Layout.fillWidth: true
            text: root.formData.name
            onTextChanged: root.formData.name = text
            placeholderText: "Введите название"
            color: "white"
            font.pixelSize: 14
            background: Rectangle {
                radius: 6; color: "#2d2d2d"
                border.color: activeFocus ? "#2196F3" : "#555555"
                border.width: 1
            }
        }
    }

    // ID ЭЛЕМЕНТА
    ColumnLayout {
        Layout.fillWidth: true
        spacing: 6
        Label { text: "Уникальный ID *"; color: "#bbbbbb"; font.pixelSize: 13 }
        TextField {
            Layout.fillWidth: true
            text: root.formData.id
            onTextChanged: root.formData.id = text
            placeholderText: "Например: silos.cement.1"
            color: "white"
            font.pixelSize: 14
            background: Rectangle {
                radius: 6; color: "#2d2d2d"
                border.color: activeFocus ? "#2196F3" : "#555555"
                border.width: 1
            }
        }
        Text {
            text: "Используется для связи с ПЛК и конфигурации"
            color: "#777777"
            font.pixelSize: 11
        }
    }

    // ID ДВИГАТЕЛЯ
    ColumnLayout {
        Layout.fillWidth: true
        spacing: 6
        visible: {
            if (!root.silosSubtypesModel || root.selectedSubtypeIndex < 0) return false
            var item = root.silosSubtypesModel.get(root.selectedSubtypeIndex)
            return item && item.hasOwnProperty("hasMotor") ? item.hasMotor : false
        }
        Label { text: "ID электродвигателя *"; color: "#bbbbbb"; font.pixelSize: 13 }
        TextField {
            Layout.fillWidth: true
            text: root.formData.motorId
            onTextChanged: root.formData.motorId = text
            placeholderText: "Например: motor.silos.1"
            color: "white"
            font.pixelSize: 14
            background: Rectangle {
                radius: 6; color: "#2d2d2d"
                border.color: activeFocus ? "#2196F3" : "#555555"
                border.width: 1
            }
        }
    }

    // УРОВЕНЬ ЗАПОЛНЕНИЯ
    ColumnLayout {
        Layout.fillWidth: true
        spacing: 6
        Label { text: "Начальный уровень заполнения"; color: "#bbbbbb"; font.pixelSize: 13 }
        RowLayout {
            Layout.fillWidth: true
            spacing: 12
            Slider {
                Layout.fillWidth: true
                from: 0; to: 1; value: root.levelPreSilos
                stepSize: 0.01
                onValueChanged: root.levelPreSilos = value
                wheelEnabled: true
                background: Rectangle {
                    y: parent.height/2 - height/2
                    width: parent.width; height: 4; radius: 2
                    color: "#444444"
                }
                handle: Rectangle {
                    x: parent.leftPadding + (parent.availableWidth - width) * parent.visualPosition
                    y: parent.height/2 - height/2
                    width: 18; height: 18; radius: 9
                    color: "#2196F3"
                    border.color: "white"; border.width: 2
                }
            }
            Text {
                text: Math.round(root.levelPreSilos * 100) + "%"
                color: "#2196F3"
                font.pixelSize: 14
                font.bold: true
                Layout.alignment: Qt.AlignVCenter
            }
        }
    }
}
