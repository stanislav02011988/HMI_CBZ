import QtQuick 2.15

Item {
    id: root
    anchors.fill: parent
    z: 1

    property bool gridEnabled: false
    property int gridSpacing: 20
    property string gridColor: "#1a1a2e"
    property real gridOpacity: 0.3

    Repeater {
        id: verticalRepeater
        model: root.gridEnabled
               ? Math.ceil(root.width / root.gridSpacing)
               : 0

        Rectangle {
            x: index * root.gridSpacing
            width: 1
            height: root.height
            color: root.gridColor
            opacity: root.gridOpacity
        }
    }

    Repeater {
        id: horizontalRepeater
        model: root.gridEnabled
               ? Math.ceil(root.height / root.gridSpacing)
               : 0

        Rectangle {
            y: index * root.gridSpacing
            height: 1
            width: root.width
            color: root.gridColor
            opacity: root.gridOpacity
        }
    }


    // =========================================================================
    // ИЗМЕНЕНИЕ НАСТРОЕК СЕТКИ
    // =========================================================================
    function toggleGrid(enabled) {
        root.gridEnabled = enabled
        // console.log(` Сетка: ${enabled ? "включена" : "выключена"}`)
    }

    function setGridSpacing(spacing) {
        root.gridSpacing = Math.max(10, Math.min(100, spacing))
    }
}
