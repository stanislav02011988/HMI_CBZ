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

    property real widthProgressBar: 40
    property real heightProgressBar: 200
    property real paddingProgressBar: 4
    property real spasingProgressBar: 0
    property real borderWidthProgressBar: 2
    property int borderRadiusProgressBar: 4
    property int sizeTextProgressBar: 16

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
                    id: rew
                    anchors.fill: parent
                    spacing: 0
                    // ==========================================
                    // Положение прогресса смещение
                    // ==========================================
                    Item {
                        Layout.fillHeight: true;
                        Layout.preferredWidth: spasingProgressBar * scale
                    }

                    // ==========================================
                    // ПРОГРЕСС-БАР
                    // ==========================================
                    CustomProgressBar {
                        Layout.preferredWidth: widthProgressBar * scale
                        Layout.preferredHeight: heightProgressBar * scale
                        parent: rew
                        vertical: true
                        visible_border_progress: true
                        borderRadius: borderRadiusProgressBar * scale
                        padding: paddingProgressBar * scale
                        borderWidth: borderWidthProgressBar * scale
                        sizeText: sizeTextProgressBar * scale
                    }

                    // ==========================================
                    // НАЗВАНИЕ СИЛОСА
                    // ==========================================
                    ColumnLayout{
                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 20
                            Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
                            color: "transparent"
                            clip: true
                        }

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
                                transformOrigin: Item.Center
                            }
                        }
                    }
                }
            }
        }
    }

    // ==========================================================
    // 6. API УПРАВЛЕНИЯ РАЗМЕРАМИ С ГРУППИРОВКОЙ
    // ==========================================================
    function getPropertiesSize() {
        return [
            {
                idGroupeProperty: "box",
                nameGroupeProperty: "Свойства линий",
                name: "containerRadius",
                value: containerRadius,
                min: 0,
                max: 100,
                step: 1,
                label: "Радиус"
            },
            {
                idGroupeProperty: "box",
                nameGroupeProperty: "Свойства линий",
                name: "borderWidth",
                value: borderWidth,
                min: 0,
                max: 100,
                step: 0.1,
                label: "Толщина линии"
            },

            // Группа: Текст
            {
                idGroupeProperty: "text",
                nameGroupeProperty: "Свойства текста название элемента",
                name: "textSize",
                value: textSize,
                min: 8,
                max: 50,
                step: 1,
                label: "Размер шрифта"
            },

            // Группа: Прогресс-бар
            {
                idGroupeProperty: "progressBar",
                nameGroupeProperty: "Свойства прогресс-бара",
                name: "widthProgressBar",
                value: widthProgressBar,
                min: 1,
                max: 500,
                step: 1,
                label: "Ширина"
            },
            {
                idGroupeProperty: "progressBar",
                nameGroupeProperty: "Свойства прогресс-бара",
                name: "heightProgressBar",
                value: heightProgressBar,
                min: 1,
                max: 500,
                step: 1,
                label: "Высота"
            },
            {
                idGroupeProperty: "progressBar",
                nameGroupeProperty: "Свойства прогресс-бара",
                name: "spasingProgressBar",
                value: spasingProgressBar,
                min: 0,
                max: 100,
                step: 1,
                label: "Положение"
            },
            {
                idGroupeProperty: "progressBar",
                nameGroupeProperty: "Свойства прогресс-бара",
                name: "borderWidthProgressBar",
                value: borderWidthProgressBar,
                min: 0,
                max: 100,
                step: 1,
                label: "Толщина линии прогресса"
            },
            {
                idGroupeProperty: "progressBar",
                nameGroupeProperty: "Свойства прогресс-бара",
                name: "borderRadiusProgressBar",
                value: borderRadiusProgressBar,
                min: 0,
                max: 100,
                step: 1,
                label: "Радиус скругления контура"
            },
            {
                idGroupeProperty: "progressBar",
                nameGroupeProperty: "Свойства прогресс-бара",
                name: "sizeTextProgressBar",
                value: sizeTextProgressBar,
                min: 0,
                max: 100,
                step: 1,
                label: "Размер текста процентов"
            }
        ];
    }

    function setPropertySize(name, value) {
        if (root.hasOwnProperty(name)) {
            root[name] = value
        } else {
            console.warn("Property not found:", name)
        }
    }

    // ==========================================================
    // 7. EXPORT / IMPORT СВОЙСТВ РАМЕРОВ
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

