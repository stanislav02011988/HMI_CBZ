import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Controls.Material
import Qt5Compat.GraphicalEffects

import qml.controls.button
import qml.controls.button.shutter
import qml.controls.button.valve
import qml.controls.progress_bar
import qml.controls.tool_tip

import qml.utils.controllers_signals

Item {
    id: root

    // === Базовые единицы для внутренних элементов ===
        // Рассчитываем от ФАКТИЧЕСКИХ размеров компонента (которые задаёт лейаут)
    readonly property real baseUnitW: width > 0 ? width / 80 : 1
    readonly property real baseUnitH: height > 0 ? height / 80 : 1

    property bool manualModeEnabled: ControllersSignalsCementScales.handModeChanged
    property bool deActivateShnek: false

    // --- состояния открытия затвора Силоса---
    // 0=закрыто, 1=открыто, 2=ожидание PLC, 3=ошибка
    property int statusShutterSilos: 0
    property int statusShutterScales: 0


    Item {
        anchors.fill: parent

        DropShadow {
            anchors.fill: bgElMotor
            source: bgElMotor
            radius: Math.max(4, baseUnitW * 3)
            samples: 16
            color: "#60000000"
            horizontalOffset: Math.max(1, baseUnitW * 1.5)
            verticalOffset: Math.max(1, baseUnitH * 1.5)
        }

        // === ЭЛЕКТРОДВИГАТЕЛЬ ===
        Rectangle {
            id: bgElMotor
            anchors.fill: parent  // Заполняем ВЕСЬ доступный размер компонента
            color: "transparent"
            visible: true

            ColumnLayout {
                anchors.fill: parent
                spacing: baseUnitH * 1

                // Верхняя линия
                Rectangle {
                    Layout.preferredWidth: parent.width * 0.1
                    Layout.preferredHeight: parent.height * 0.2
                    Layout.alignment: Qt.AlignHCenter
                    radius: baseUnitW * 1
                    color: {
                        if (root.statusShutterSilos === 0){ return "transparent" }
                        else if (root.statusShutterSilos === 1) { return "green" }
                        else if (root.statusShutterSilos === 2) { return "yellow" }
                        else if (root.statusShutterSilos === 3) { return "red" }
                    }
                }

                // Корпус электродвигателя с кнопкой
                Rectangle {
                    Layout.preferredWidth: parent.width * 0.6
                    Layout.preferredHeight: parent.height * 0.4
                    Layout.alignment: Qt.AlignHCenter
                    color: "transparent"
                    radius: baseUnitW * 15
                    border.color: "#777777"
                    border.width: baseUnitW * 2

                    CustomToggleButton {
                        anchors.centerIn: parent
                        width: parent.width * 0.5
                        height: parent.height * 0.54
                        m_radius: width / 2

                        m_background_color: "transparent"
                        m_color_hovered: "#888"
                        m_color_checked: "#666666"

                        // Доступна ТОЛЬКО в ручном режиме
                        enabled: root.manualModeEnabled
                        checked: root.manualModeEnabled ? root.deActivateShnek : true
                    }
                }

                // Нижняя линия
                Rectangle {
                    Layout.preferredWidth: parent.width * 0.1
                    Layout.preferredHeight: parent.height * 0.2
                    Layout.alignment: Qt.AlignHCenter
                    radius: baseUnitW * 1
                    color: {
                        if (root.statusShutterScales === 0){ return "transparent" }
                        else if (root.statusShutterScales === 1) { return "green" }
                        else if (root.statusShutterScales === 2) { return "yellow" }
                        else if (root.statusShutterScales === 3) { return "red" }
                    }
                }

                // === Теругольный затвор цементного шнека ===
                BtnShutterModeToggle {
                    Layout.preferredWidth: parent.width * 0.3
                    Layout.preferredHeight: parent.height * 0.1
                    Layout.alignment: Qt.AlignHCenter
                    visible: true
                }
            }
        }
    }
}
