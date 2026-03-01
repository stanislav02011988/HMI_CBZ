//module qml.content.main_window.main_window_widgets.center_widget.component.silos SilosVertical.qml
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Controls.Material
import Qt5Compat.GraphicalEffects

import qml.controls.button
import qml.controls.button.toggle_button
import qml.controls.button.shutter
import qml.controls.button.valve
import qml.controls.progress_bar
import qml.controls.tool_tip
import qml.controls.drop_shadow

import qml.utils.controllers_signals

Item {
    id: root

    // === АДАПТИВНАЯ СИСТЕМА РАЗМЕРОВ (точно как в весах) ===
    readonly property real baseUnitW: width > 0 ? width / 80 : 1    // 80px = 100% ширины
    readonly property real baseUnitH: height > 0 ? height / 240 : 1  // 200px = 100% высоты

    // Уникальный ID эелемента Силоса
    property string id_widget: ""
    property string name_widget: ""

    property var signalBus: null

    property var exposedSignals: ({
        "shutterOpened": "Сигнал изменения состояния затвора",
        "shutterError":  "Ошибка затвора"
    })

    property var exposedSlots: ({
        "open":        "Открыть",
        "close":       "Закрыть",
        "resetError":  "Сброс ошибки"
    })

    // --- ЭМИТ СОБЫТИЯ ПРИ ИЗМЕНЕНИИ РУЧНОГО РЕЖИМА ---
    onManualModeEnabledChanged: {
        if (signalBus && id_widget) {
            signalBus.emit("handModeActivated", id_widget, { value: manualModeEnabled })
        }
    }

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
        CustomButton {
            id: closeBtn
            m_width: 20
            m_height: 20
            m_background_color: "transparent"
            m_colorText: "black"
            text: "X"

            anchors.right: parent.right
            anchors.top: parent.top
            anchors.rightMargin: 3
            anchors.topMargin: 3
            visible: root.accessCheck
            z: 10
            onClicked: root.removeRequested()
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
                    border.color: "#504e4e"
                    border.width: baseUnitW * 1.5

                    // MouseArea для отслеживания наведения (НЕ перехватывает клики!)
                    MouseArea {
                        id: silosMouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        acceptedButtons: Qt.NoButton  // Клики проходят к дочерним элементам (кнопкам и т.д.)
                    }

                    CustomToolTip {
                        id: toolTipSilosMouseArea
                        target: silosMouseArea
                        customDelay: 500
                        showOnDisabledOnly: false
                        backgroundColor: "#2c3e50"
                        borderColor: "#3498db"
                        fontSize: 13
                    }

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
                                text: root.name_widget
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
            }
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
