//Silos.qml
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Controls.Material
import Qt5Compat.GraphicalEffects

import qml.controls.button.toggle_button
import qml.controls.button.shutter
import qml.controls.button.valve
import qml.controls.progress_bar
import qml.controls.tool_tip

import qml.utils.controllers_signals

Item {
    id: root

    // === АДАПТИВНАЯ СИСТЕМА РАЗМЕРОВ (точно как в весах) ===
    readonly property real baseUnitW: width > 0 ? width / 80 : 1    // 80px = 100% ширины
    readonly property real baseUnitH: height > 0 ? height / 240 : 1  // 200px = 100% высоты

    // Уникальный ID эелемента Силоса
    property string id_silos: "silos.cement.1"
    property string name_silos: "Силос"

    property string name_progress_bar: "silos.cement.1.progressBar"
    property string address_progress_bar: ""
    property real level_cement_silos: 0  // 0.0 - 1.0

    property string id_valve_air: "silos.cement.1.valve.air"
    property string name_valve_air: ""

    property string id_shutter_silos: "silos.cement.1.shutter.silos"
    property string name_shutter_silos: ""

    property string id_el_motor_shnek: "silos.cement.1.el.motor.shnek"
    property string name_el_motor_shnek: ""
    property int state_el_motor: 0

    property string id_shutter_el_motor_shnek: "silos.cement.1.shutter.el.motor.shnek"
    property string name_shutter_el_motor_shnek: ""
    property int state_shutter_el_motor_shnek: 0
    property bool type_dosage_mode: false

    //Глобальное свойство Ручной режим весов
    property bool manualModeEnabled: false
    property bool accessCheck: false

    // === СВОЙСТВА СИЛОСА ===
    property string name_silos_color: "#333333"
    property real size_text_name_silos: 14
    property bool bold_text_name_silos: false
    property string name_silos_border_color: "transparent"    

    property var elMotorSignalConnect: null
    property var shutterShnekSignalConnect: null
    // === СИГНАЛ ДЛЯ УДАЛЕНИЯ (обязательно!) ===
    signal removeRequested()

    // === ТЕНЬ И ОСНОВНОЙ КОНТЕЙНЕР ===
    Item {
        anchors.fill: parent

        DropShadow {
            anchors.fill: silosContainer
            source: silosContainer
            radius: Math.max(4, baseUnitW * 3)
            samples: 16
            color: "#60000000"
            horizontalOffset: Math.max(1, baseUnitW * 1.5)
            verticalOffset: Math.max(1, baseUnitH * 1.5)
        }

        // === КНОПКА УДАЛЕНИЯ В ПРАВОМ ВЕРХНЕМ УГЛУ ===
        Rectangle {
            id: removeBtn
            width: 20
            height: 20
            color: "#f44336"
            radius: 10
            border.color: "white"
            border.width: 1
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.rightMargin: 3
            anchors.topMargin: 3
            visible: root.accessCheck

            Text {
                anchors.centerIn: parent
                text: "×"
                color: "white"
                font.pixelSize: 16
                font.bold: true
            }

            MouseArea {
                anchors.fill: parent
                onClicked: root.removeRequested()  // ← Вызывает сигнал
            }

            // CustomToolTip {
            //     id: toolTipBtnHand
            //     target: removeBtn
            //     customText: "Кнопка Удаления Силоса"
            //     customDelay: 1000
            //     showOnDisabledOnly: false
            //     backgroundColor: "#2c3e50"
            //     borderColor: "#3498db"
            //     fontSize: 13
            // }
        }

        Rectangle {
            id: silosContainer
            anchors.fill: parent
            color: "transparent"

            ColumnLayout {
                anchors.fill: parent
                spacing: baseUnitH * 2


                // === ВЕРХНЯЯ ЧАСТЬ: СИЛОС С ПРОГРЕСС-БАРОМ ===
                Rectangle {
                    id: silosBody
                    Layout.preferredWidth: parent.width * 1
                    Layout.preferredHeight: parent.height * 0.95
                    Layout.alignment: Qt.AlignHCenter
                    color: "transparent"
                    radius: baseUnitW * 3
                    border.color: "#777777"
                    border.width: baseUnitW * 1.5

                    RowLayout {
                        anchors.fill: parent
                        spacing: baseUnitW * 0

                        // Прогресс-бар заполнения
                        CustomProgressBar {
                            Layout.preferredWidth: parent.width * 0.35
                            Layout.preferredHeight: parent.height * 0.9
                            Layout.leftMargin: 5
                            vertical: true
                            visible_border_progress: true
                            blockCount: 1
                            blockSpacing: 1
                            borderRadius: baseUnitW * 2
                            padding: baseUnitW * 4
                            value: root.level_cement_silos
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            color: "transparent"
                            border.color: root.name_silos_border_color
                            clip: true

                            Text {
                                anchors.centerIn: parent
                                text: root.name_silos
                                font.family: "Times New Roman"
                                font.pixelSize: Math.max(root.size_text_name_silos, baseUnitW * 8)
                                font.bold: root.bold_text_name_silos
                                color: root.name_silos_color
                                verticalAlignment: Text.AlignBottom
                                horizontalAlignment: Text.AlignBottom
                                rotation: -90
                                transformOrigin: Item.Bottom
                            }
                        }
                    }

                    // === КЛАПАН ВОЗДУХА (оригинальное расположение) ===
                    Rectangle {
                        id: valveAirContainer
                        width: silosBody.width * 0.3
                        height: silosBody.height * 0.1
                        color: "transparent"
                        anchors.right: silosBody.right
                        anchors.bottom: silosBody.bottom
                        anchors.rightMargin: -root.baseUnitW * 10
                        anchors.bottomMargin: root.baseUnitH * 6

                        BtnValveAir {
                            id_valve_air: root.id_valve_air
                            name_valve_air: root.name_valve_air
                            anchors.fill: parent
                            anchors.margins: root.baseUnitW * 1.5
                        }
                    }
                }

                // === Кнопка затвора силоса ===
                BtnShutterModeToggle {
                    id: btnShutterSilos
                    Layout.preferredWidth: parent.width * 0.7
                    Layout.preferredHeight: parent.height * 0.05
                    Layout.alignment: Qt.AlignHCenter

                    id_shutter_silos: root.id_shutter_silos
                    name_shutter_silos: root.name_shutter_silos
                    controlMode: root.manualModeEnabled
                }

                // Верхняя линия
                Rectangle {
                    id: lineBtnShutterSilosElMotor
                    Layout.preferredWidth: parent.width * 0.05
                    Layout.preferredHeight: parent.height * 0.15
                    Layout.alignment: Qt.AlignHCenter
                    radius: baseUnitW * 1
                    color: "transparent"
                }

                // Корпус электродвигателя с кнопкой
                Rectangle {
                    Layout.preferredWidth: parent.width * 0.6
                    Layout.preferredHeight: parent.height * 0.25
                    Layout.alignment: Qt.AlignHCenter
                    color: "transparent"
                    radius: baseUnitW * 15
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
                    color: "transparent"
                }

                // === Теругольный затвор цементного шнека ===
                BtnShutterModeToggle {
                    id: btnShutterScales
                    Layout.preferredWidth: parent.width * 0.3
                    Layout.preferredHeight: parent.height * 0.1
                    Layout.alignment: Qt.AlignHCenter
                    visible: true

                    id_shutter_silos: root.id_shutter_el_motor_shnek
                    name_shutter_silos: root.name_shutter_el_motor_shnek
                    controlMode: root.manualModeEnabled
                    dosageMode: root.type_dosage_mode
                    state: root.state_shutter_el_motor_shnek
                }
            }
        }
    }

    function activateWarkShutterAndElMotor(state:int){
        switch (state) {
            case 0:
                // Остановка
                lineBtnShutterSilosElMotor.color = "transparent"
                btnElMotorShnek.state = state
                lineElMotorShutterShnek.color = "transparent"
                btnShutterScales.state = state
                break

            case 1:
                // Запуск
                lineBtnShutterSilosElMotor.color = "green"
                btnElMotorShnek.state = state
                lineElMotorShutterShnek.color = "green"
                btnShutterScales.state = state
                break

            case 2:
                // Ожидание
                lineBtnShutterSilosElMotor.color = "yellow"
                btnElMotorShnek.state = state
                lineElMotorShutterShnek.color = "yellow"
                btnShutterScales.state = state
                break

            case 3:
                // Ошибка
                lineBtnShutterSilosElMotor.color = "red"
                btnElMotorShnek.state = state
                lineElMotorShutterShnek.color = "red"
                btnShutterScales.state = state
                break
        }
    }

    Component.onCompleted: {
        // При подключении:
        if (root.elMotorSignalConnect) {
            btnElMotorShnek.signalActivateStartStopElMotor.disconnect(root.elMotorSignalConnect)
        }
        root.elMotorSignalConnect = btnElMotorShnek.signalActivateStartStopElMotor.connect(function(state) {
            root.activateWarkShutterAndElMotor(state)
        })

        if (root.shutterShnekSignalConnect) {
            btnShutterScales.signalStateShutter.disconnect(root.shutterShnekSignalConnect)
        }
        root.shutterShnekSignalConnect = btnShutterScales.signalStateShutter.connect(function(state) {
            root.activateWarkShutterAndElMotor(state)
        })
    }
    Component.onDestruction: {
        if (root.elMotorSignalConnect) {
            btnElMotorShnek.signalActivateStartStopElMotor.disconnect(root.elMotorSignalConnect)
        }
        if (root.shutterShnekSignalConnect) {
            btnElMotorShnek.signalActivateStartStopElMotor.disconnect(root.shutterShnekSignalConnect)
        }
    }
}
