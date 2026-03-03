// ===============================================================
// SilosVertical.qml
// Production-версия с адаптивной системой масштабирования
// ===============================================================

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

Item {
    id: root

    // ==========================================================
    // 1. ЭТАЛОННЫЙ РАЗМЕР (Reference Geometry)
    // ==========================================================
    property real referenceWidth: 120
    property real referenceHeight: 320

    // ==========================================================
    // 2. МАСШТАБИРОВАНИЕ
    // ==========================================================
    property real scaleX: width  > 0 ? width  / referenceWidth  : 1
    property real scaleY: height > 0 ? height / referenceHeight : 1
    property real scale: Math.min(scaleX, scaleY)

    // ==========================================================
    // 3. КОНФИГУРАЦИЯ ВСЕХ РАЗМЕРОВ (РАЗДЕЛЬНО)
    // ==========================================================
    property int containerRadius: 6
    property real borderWidth: 1.5

    property real shadowRadius: 6
    property real shadowOffsetX: 2
    property real shadowOffsetY: 2

    property real progressBarWidthRatio: 0.35
    property real progressBarHeightRatio: 0.9
    property real progressPadding: 4

    property real valveWidthRatio: 0.3
    property real valveHeightRatio: 0.1

    property real shutterButtonHeightRatio: 0.06

    property real connectorLineWidthRatio: 0.05
    property real connectorLineHeightRatio: 0.15

    property int textSize: 14

    // ==========================================================
    // 4. БИЗНЕС-СВОЙСТВА
    // ==========================================================
    property string componentGroupe: ""
    property string subtype: ""

    property string id_widget: ""
    property string name_widget: ""
    property real level_cement_silos: 0

    property string id_valve_air: ""
    property string name_valve_air: ""

    // ==========================================================
    // 5. ОСНОВНОЙ КОНТЕЙНЕР С ТЕНЬЮ
    // ==========================================================
    Item {
        anchors.fill: parent

        DropShadow {
            anchors.fill: silosContainer
            source: silosContainer
            radius: shadowRadius * scale
            samples: 16
            color: "#60000000"
            horizontalOffset: shadowOffsetX * scale
            verticalOffset: shadowOffsetY * scale
        }

        Rectangle {
            id: silosContainer
            anchors.fill: parent
            color: "transparent"

            ColumnLayout {
                anchors.fill: parent
                spacing: 4 * scale

                // ==================================================
                // ТЕЛО СИЛОСА
                // ==================================================
                Rectangle {
                    id: silosBody
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    radius: containerRadius * scale
                    border.color: "#504e4e"
                    border.width: borderWidth * scale
                    color: "transparent"

                    RowLayout {
                        anchors.fill: parent
                        spacing: 0

                        // ==========================================
                        // ПРОГРЕСС-БАР
                        // ==========================================
                        CustomProgressBar {
                            Layout.preferredWidth: parent.width * progressBarWidthRatio
                            Layout.preferredHeight: parent.height * progressBarHeightRatio
                            vertical: true
                            visible_border_progress: true
                            borderRadius: containerRadius * scale
                            padding: progressPadding * scale
                            value: root.level_cement_silos
                        }

                        // ==========================================
                        // НАЗВАНИЕ СИЛОСА
                        // ==========================================
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            color: "transparent"
                            clip: true

                            Text {
                                anchors.centerIn: parent
                                text: root.name_widget
                                font.pixelSize: textSize * scale
                                font.bold: true
                                color: "#333333"

                                rotation: -90
                                transformOrigin: Item.Bottom
                            }
                        }
                    }

                    // ==========================================
                    // КЛАПАН ВОЗДУХА
                    // ==========================================
                    Rectangle {
                        width: silosBody.width * valveWidthRatio
                        height: silosBody.height * valveHeightRatio
                        anchors.right: silosBody.right
                        anchors.bottom: silosBody.bottom
                        color: "transparent"

                        BtnValveAir {
                            anchors.fill: parent
                            id_valve_air: root.id_valve_air
                            name_valve_air: root.name_valve_air
                        }
                    }
                }

                // ==================================================
                // КНОПКА ЗАТВОРА
                // ==================================================
                BtnShutterModeToggle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: parent.height * shutterButtonHeightRatio
                }
            }
        }
    }

    // ==========================================================
    // 6. API УПРАВЛЕНИЯ РАЗМЕРАМИ
    // ==========================================================
    function getPropertiesSize() {
        return [
            { name: "referenceWidth", value: referenceWidth, min: 50, max: 500, step: 5,
              label: "Ширина контейнера", description: "Основная ширина виджета" },
            { name: "referenceHeight", value: referenceHeight, min: 100, max: 800, step: 5,
              label: "Высота контейнера", description: "Основная высота виджета" },
            { name: "progressBarWidthRatio", value: progressBarWidthRatio, min: 0.1, max: 1.0, step: 0.01,
              label: "Прогресс-бар: ширина", description: "Ширина прогресс-бара внутри силоса" },
            { name: "progressBarHeightRatio", value: progressBarHeightRatio, min: 0.1, max: 1.0, step: 0.01,
              label: "Прогресс-бар: высота", description: "Высота прогресс-бара внутри силоса" },
            { name: "textSize", value: textSize, min: 8, max: 50, step: 1,
              label: "Размер текста", description: "Размер шрифта названия силоса" },
            { name: "shutterButtonHeightRatio", value: shutterButtonHeightRatio, min: 0.02, max: 0.2, step: 0.01,
              label: "Кнопка затвора: высота", description: "Высота кнопки затвора" },
            { name: "containerRadius", value: containerRadius, min: 0, max: 30, step: 1,
              label: "Скругление контейнера", description: "Радиус скругления углов контейнера силоса" },
            { name: "borderWidth", value: borderWidth, min: 0.5, max: 5, step: 0.1,
              label: "Ширина границы контейнера", description: "Толщина линии границы силоса" }
        ]
    }

    function setPropertySize(name, value) {
        if (root.hasOwnProperty(name)) {
            root[name] = value
        } else {
            console.warn("Property not found:", name)
        }
    }
}
