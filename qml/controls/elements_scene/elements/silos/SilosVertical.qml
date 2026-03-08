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
import qml.controls.progress_bar
import qml.controls.tool_tip
import qml.controls.drop_shadow

Item {
    id: root

    // ==========================================================
    // 1. ЭТАЛОННЫЙ РАЗМЕР (Reference Geometry)
    // ==========================================================
    property real referenceWidth: 120
    property real referenceHeight: 240

    implicitWidth: referenceWidth
    implicitHeight: referenceHeight

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
    property real progressBarSpasing: 0.01

    property int textSize: 14

    // ==========================================================
    // 4. БИЗНЕС-СВОЙСТВА
    // ==========================================================
    property string componentGroupe: ""
    property string subtype: ""

    property string id_widget: ""
    property string name_widget: ""
    property real level_silos: 0

    property string id_valve_air: ""
    property string name_valve_air: ""

    // ==========================================================
    // 5. ОСНОВНОЙ КОНТЕЙНЕР С ТЕНЬЮ
    // ==========================================================
    layer.enabled: true
    layer.effect: DropShadow {
        color: "#60000000"
        radius: shadowRadius
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
                    // Положение прогресса смещение
                    // ==========================================
                    Item { Layout.fillHeight: true; Layout.preferredWidth: parent.width * progressBarSpasing}
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
                        value: root.level_silos
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
            { name: "progressBarSpasing", value: progressBarSpasing, min: 0.01, max: 1, step: 0.01,
              label: "Прогресс-бар: положение", description: "Положение" },
            { name: "textSize", value: textSize, min: 8, max: 50, step: 1,
              label: "Размер текста", description: "Размер шрифта названия силоса" },
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

    // ==========================================================
    // 7. EXPORT / IMPORT СВОЙСТВ
    // ==========================================================
    function exportPropertiesSize() {
        var props = getPropertiesSize()
        var result = {}

        for (var i = 0; i < props.length; i++) {
            var p = props[i]
            result[p.name] = root[p.name]
        }

        return result
    }

    function importProperties(data) {
        if (!data)
            return

        for (let key in data) {
            if (root.hasOwnProperty(key)) {
                root[key] = data[key]
            }
        }
    }
}
