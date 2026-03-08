// module qml.content.main_window.main_window_widgets.center_widget.controllers_widget.edit_mode.panel_button_edit_mode PanelButtonEditMode.qml
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import qml.controls.button
import qml.controls.button.toggle_button

Item {
    id: root
    width: 200
    height: 150

    signal signalGridEnable(bool check)
    signal signalClearScenes()
    signal addElementRequested()
    signal signalSave()    

    Rectangle {
        id: bg
        anchors.fill: parent
        color: "transparent"
        border.color: "black"
        border.width: 1
        radius: 6

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 4
            spacing: 4

            Text {
                text: "Панель кнопок"
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                font.pixelSize: 12
                font.family: "Times New Roman"
            }

            Button {
                Layout.fillWidth: true
                Layout.preferredHeight: 30
                text: "Добавить элементы"
                onClicked: root.addElementRequested()  // ← вызываем сигнал
            }

            RowLayout {
                Layout.fillWidth: true
                Layout.preferredHeight: 30
                Text {
                    text: "Сетка"
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    font.pixelSize: 12
                    font.family: "Times New Roman"
                }
                CustomToggleButtonText {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    text: checked ? "▢ Выкл" : "▣ Вкл"
                    checkable: true
                    onCheckedChanged: root.signalGridEnable(checked)
                }
            }

            Button {
                Layout.fillWidth: true
                Layout.preferredHeight: 30
                text: "🗑️ Очистить всё"
                onClicked: root.signalClearScenes()
            }

            Button {
                Layout.fillWidth: true
                Layout.preferredHeight: 30
                text: "Сохранить сцену CTRL+S"
                onClicked: root.signalSave()
            }
        }
    }
}
