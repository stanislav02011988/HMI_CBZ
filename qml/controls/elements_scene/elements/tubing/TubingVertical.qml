import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Controls.Material
import Qt5Compat.GraphicalEffects

Item {
    id: root

    // ==========================================================
    // 1. ЭТАЛОННЫЙ РАЗМЕР
    // ==========================================================
    property real referenceWidth: 5
    property real referenceHeight: 100

    implicitWidth: referenceWidth
    implicitHeight: referenceHeight

    // ==========================================================
    // 2. МАСШТАБ
    // ==========================================================
    property real scaleX: width  > 0 ? width  / referenceWidth  : 1
    property real scaleY: height > 0 ? height / referenceHeight : 1
    property real scale: Math.min(scaleX, scaleY)

    // ==========================================================
    // 3. КОНФИГУРАЦИЯ РАЗМЕРОВ
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
    // 4. БИЗНЕС СВОЙСТВА
    // ==========================================================
    property string subtype: ""
    property string componentGroupe: ""

    property string id_widget: ""
    property string name_widget: ""

    property bool manualModeEnabled: false
    property bool type_dosage_mode: false
    property int state: 0

    // ==========================================================
    // 5. ОСНОВНОЙ КОНТЕЙНЕР
    // ==========================================================

    layer.enabled: true
    layer.effect: DropShadow {
        color: "#60000000"
        radius: shadowRadius
        horizontalOffset: shadowOffsetX * scale
        verticalOffset: shadowOffsetY * scale
    }

    Rectangle {
        width: parent.width * scale
        height: parent.height * scale
        Layout.alignment: Qt.AlignHCenter
        border.width: borderWidth * scale
        radius: containerRadius * scale
        border.color: "#666"
        color: {
            switch (root.state) {
                case 0:
                    // Остановка
                    return "#666"
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

    // ==========================================================
    // 6. API РЕДАКТОРА Размеры элементов
    // ==========================================================
    function getPropertiesSize() {

        return [

            { name: "widthContainer", value: widthContainer, min: 0.01, max: 1, step: 0.01,
              label: "Ширина", description: "Ширина контейнера" },

            { name: "heightContainer", value: heightContainer, min: 0.01, max: 1, step: 0.01,
              label: "Высота", description: "Высота контейнеоа" },

            { name: "containerRadius", value: containerRadius, min: 0, max: 30, step: 1,
              label: "Радиус", description: "Радиус скругления границы виджета" },

            { name: "borderWidth", value: borderWidth, min: 0.5, max: 5, step: 0.1,
              label: "Толщина линии", description: "Толщина линии виджета" }
        ]
    }

    function setPropertySize(name, value) {
        if (root.hasOwnProperty(name)) {
            root[name] = value
        }
    }

    // ==========================================================
    // 7. EXPORT / IMPORT
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
