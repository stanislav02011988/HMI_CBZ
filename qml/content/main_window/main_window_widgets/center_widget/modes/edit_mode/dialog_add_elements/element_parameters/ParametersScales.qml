// element_parameters/ParametersScales.qml
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window
import QtQuick.Controls.Material

ColumnLayout {
    id: root
    Layout.fillWidth: true
    spacing: 16

    property var formData: ({ name: "", id: "" })

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
            placeholderText: "Например: scales.cement.1"
            color: "white"
            font.pixelSize: 14
            background: Rectangle {
                radius: 6; color: "#2d2d2d"
                border.color: activeFocus ? "#2196F3" : "#555555"
                border.width: 1
            }
        }
        Text {
            text: "Используется для связи с ПЛК"
            color: "#777777"
            font.pixelSize: 11
        }
    }
}
