import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Controls.Material
import Qt5Compat.GraphicalEffects

import qml.controls.button.toggle_button
import qml.controls.button.shutter
import qml.controls.truncated_cone
import qml.controls.triangle
import qml.controls.progress_bar
import qml.controls.tool_tip

import qml.settings.project_settings

import qml.utils.controllers_signals

Item {
    id: root

    property string subtype: ""
    property string componentGroupe: ""

    property string id_widget: ""
    property string name_widget: ""

    property string id_btn_shutter_shnek: ""
    property string name_btn_shutter_shnek: ""

    property var sceneBus
    property var exposedSignals: ["shutterOpened"] // можно расширить
    property var exposedSlots: ["setEnabled", "setVisible"]

    // --- ЭМИТ СОБЫТИЯ ПРИ ИЗМЕНЕНИИ РУЧНОГО РЕЖИМА ---
    onManualModeEnabledChanged: {
        if (sceneBus && id_widget) {
            sceneBus.emit("handModeActivated", id_widget, { value: manualModeEnabled })
        }
    }

    property bool manualModeEnabled: false
    property bool type_dosage_mode: false
    property int state_el_motor: 0

    // === АДАПТИВНАЯ СИСТЕМА РАЗМЕРОВ (точно как в весах) ===
    readonly property real baseUnitW: width > 0 ? width / 80 : 1    // 80px = 100% ширины
    readonly property real baseUnitH: height > 0 ? height / 240 : 1  // 200px = 100% высоты

    //===== Коэф.размеров элюдвигателя шнека
    property real kofWidthRectangleElMotor: 0.6
    property real kofHeightRectangleElMotor: 0.25

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        // Корпус электродвигателя с кнопкой
        Rectangle {
            Layout.preferredWidth: parent.width * root.kofWidthRectangleElMotor
            Layout.preferredHeight: parent.height * root.kofHeightRectangleElMotor
            Layout.alignment: Qt.AlignHCenter
            color: "transparent"
            radius: baseUnitH * 15
            border.color: "#777777"
            border.width: baseUnitW * 2

            CustomToggleButton {
                id: btnElMotorShnek
                anchors.centerIn: parent
                width: parent.width * 0.5
                height: parent.height * 0.54
                m_radius: width / 2

                m_background_color: "transparent"
                m_color_hovered: "#888"
                m_color_start: "#666666"

                // Доступна ТОЛЬКО в ручном режиме
                checkable: false
                enabled: root.manualModeEnabled
                state: root.state_el_motor

                onPressed: {setWait()}
                onReleased: {setClosed()}
            }
        }

        // Нижняя линия
        Rectangle {
            id: lineElMotorShutterShnek
            Layout.preferredWidth: parent.width * 0.05
            Layout.preferredHeight: parent.height * 0.15
            Layout.alignment: Qt.AlignHCenter
            radius: baseUnitW * 1
            color: {
                switch (root.state_el_motor) {
                    case 0:
                        // Остановка
                        return "transparent"
                    case 1:
                        // Запуск
                        return "green"
                    case 2:
                        // Ожидание
                        return "yellow"
                    case 3:
                        // Ошибка
                        return "red"
                }
            }
        }

        // === Теругольный затвор цементного шнека ===
        BtnShutterModeToggle {
            id: btnShutterScales
            Layout.preferredWidth: parent.width * 0.3
            Layout.preferredHeight: parent.height * 0.1
            Layout.alignment: Qt.AlignHCenter
            visible: true
        }
    }

    function activateWarkShutterAndElMotor(state:int){
        switch (state) {
            case 0:
                // Остановка
                lineBtnShutterSilosElMotor.color = "transparent"
                break

            case 1:
                // Запуск
                lineBtnShutterSilosElMotor.color = "green"
                break

            case 2:
                // Ожидание
                lineBtnShutterSilosElMotor.color = "yellow"
                break

            case 3:
                // Ошибка
                lineBtnShutterSilosElMotor.color = "red"
                break
        }
    }
}
