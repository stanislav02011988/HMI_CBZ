import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Controls.Material
import Qt5Compat.GraphicalEffects

import qml.controls.button.toggle_button
import qml.controls.truncated_cone
import qml.controls.triangle
import qml.controls.progress_bar
import qml.controls.tool_tip

import qml.settings.project_settings

Item {
    id: root

    // ==========================================================
    // ЭТАЛОННЫЙ РАЗМЕР (для редактора)
    // ==========================================================
    property real referenceWidth: 100
    property real referenceHeight: 100

    // ==========================================================
    // SCALE
    // ==========================================================
    property real scaleX: width  > 0 ? width  / referenceWidth  : 1
    property real scaleY: height > 0 ? height / referenceHeight : 1
    property real scale: Math.min(scaleX, scaleY)

    // ==========================================================
    // SIZE CONFIG
    // ==========================================================
    property int containerRadius: 6
    property real borderWidth: 2

    property real widthContainer: 0.5
    property real heightContainer: 0.5

    property real shadowRadius: 6
    property real shadowOffsetX: 2
    property real shadowOffsetY: 2

    property int buttonSize: 20

    // ==========================================================
    // БИЗНЕС СВОЙСТВА
    // ==========================================================
    property string subtype: ""
    property string componentGroupe: ""

    property string id_widget: ""
    property string name_widget: ""

    property bool manualModeEnabled: false
    property bool type_dosage_mode: false
    property int state_el_motor: 0

    // ==========================================================
    // КОНТЕНТ (ВАЖНО)
    // ==========================================================
    ColumnLayout {
        id: content
        anchors.centerIn: parent
        spacing: 0

        Rectangle {
            id: body

            implicitWidth: referenceWidth * widthContainer
            implicitHeight: referenceHeight * heightContainer

            Layout.alignment: Qt.AlignHCenter

            color: "transparent"
            radius: containerRadius * scale

            border.color: "#777777"
            border.width: borderWidth * scale

            CustomToggleButton {

                id: btnElMotorShnek

                anchors.centerIn: parent

                width: buttonSize * scale
                height: buttonSize * scale

                m_radius: width / 2

                m_background_color: "transparent"
                m_color_hovered: "#888"
                m_color_start: "#666666"

                checkable: false
                state: root.state_el_motor
            }
        }
    }

    // ==========================================================
    // АВТОРАЗМЕР ВИДЖЕТА
    // ==========================================================
    implicitWidth: content.implicitWidth
    implicitHeight: content.implicitHeight

    // ==========================================================
    // ТЕНЬ
    // ==========================================================
    layer.enabled: true
    layer.effect: DropShadow {
        color: "#60000000"
        radius: shadowRadius
        horizontalOffset: shadowOffsetX * scale
        verticalOffset: shadowOffsetY * scale
    }

    // ==========================================================
    // API РЕДАКТОРА
    // ==========================================================
    function getPropertiesSize() {

        return [

            { name: "buttonSize", value: buttonSize, min: 10, max: 60, step: 1,
              label: "Размер", description: "Размер кнопок" },

            { name: "widthContainer", value: widthContainer, min: 0.01, max: 1, step: 0.01,
              label: "Ширина", description: "Ширина контейнера" },

            { name: "heightContainer", value: heightContainer, min: 0.01, max: 1, step: 0.01,
              label: "Высота", description: "Высота контейнера" },

            { name: "containerRadius", value: containerRadius, min: 0, max: 30, step: 1,
              label: "Радиус", description: "Радиус скругления границы" },

            { name: "borderWidth", value: borderWidth, min: 0.5, max: 5, step: 0.1,
              label: "Толщина линии", description: "Толщина линии виджета" }
        ]
    }

    function setPropertySize(name, value) {
        if (root.hasOwnProperty(name))
            root[name] = value
    }

    // ==========================================================
    // EXPORT / IMPORT
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

            if (root.hasOwnProperty(key))
                root[key] = data[key]
        }
    }
}

